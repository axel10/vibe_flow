import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../models/music_file.dart';
import '../../player/audio/audio_riverpod.dart';
import '../../player/remote/remote_server_models.dart';
import '../../player/remote/services/remote_download_service.dart';
import '../../player/sharing/sharing_riverpod.dart';
import '../../utils/file_selector_helper.dart';
import '../../utils/song_context_menu_utils.dart';
import '../../widgets/desktop_window_title_bar.dart';
import '../../widgets/mini_player_wrapper.dart';

class RemoteDownloadManagerPage extends ConsumerStatefulWidget {
  const RemoteDownloadManagerPage({super.key});

  @override
  ConsumerState<RemoteDownloadManagerPage> createState() =>
      _RemoteDownloadManagerPageState();
}

class _RemoteDownloadManagerPageState
    extends ConsumerState<RemoteDownloadManagerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatSpeed(double bytesPerSec) {
    if (bytesPerSec <= 0) return '0 B/s';
    if (bytesPerSec < 1024) return '${bytesPerSec.toStringAsFixed(0)} B/s';
    if (bytesPerSec < 1024 * 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  Future<void> _changeDownloadFolder() async {
    final l10n = AppLocalizations.of(context)!;
    final sharingService = ref.read(sharingServiceProvider);
    final dirPath =
        await FileSelectorHelper.pickDirectory(lockParentWindow: false);
    if (dirPath != null && mounted) {
      await sharingService.updateSharingFolderPath(dirPath);
      showToast(l10n.receiveDirectoryUpdated(dirPath));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tasks = ref.watch(remoteDownloadTasksProvider);
    final activeCount = ref.watch(activeDownloadsCountProvider);
    final totalSpeed = ref.watch(activeTotalSpeedProvider);

    final downloadingTasks = tasks
        .where((t) =>
            t.status == RemoteDownloadStatus.downloading ||
            t.status == RemoteDownloadStatus.pending ||
            t.status == RemoteDownloadStatus.paused ||
            t.status == RemoteDownloadStatus.failed)
        .toList();

    final completedTasks = tasks
        .where((t) =>
            t.status == RemoteDownloadStatus.completed ||
            t.status == RemoteDownloadStatus.cancelled)
        .toList();

    final isMacOS = Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    Widget content = Scaffold(
      appBar: AppBar(
        title: Text(l10n.downloadManager),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: l10n.downloadFolder,
            onPressed: () async {
              final notifier =
                  ref.read(remoteDownloadTasksProvider.notifier);
              final folder = await notifier.getDownloadFolderPath();
              await openFolderLocation(folder);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.downloadingTab),
                  if (activeCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$activeCount',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.completedTab),
                  if (completedTasks.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${completedTasks.length}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Location banner
          _buildDownloadLocationBanner(theme, l10n),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDownloadingTab(
                  context,
                  theme,
                  l10n,
                  downloadingTasks,
                  totalSpeed,
                ),
                _buildCompletedTab(
                  context,
                  theme,
                  l10n,
                  completedTasks,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (showCustomTitleBar || isMacOS) {
      content = Material(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            if (showCustomTitleBar)
              DesktopWindowTitleBar(brightness: theme.brightness)
            else
              const DragToMoveArea(child: SizedBox(height: 32)),
            Expanded(child: content),
          ],
        ),
      );
    }

    return MiniPlayerWrapper(child: content);
  }

  Widget _buildDownloadLocationBanner(ThemeData theme, AppLocalizations l10n) {
    return FutureBuilder<String>(
      future: ref
          .read(remoteDownloadTasksProvider.notifier)
          .getDownloadFolderPath(),
      builder: (context, snapshot) {
        final folder = snapshot.data ?? '...';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.35),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  folder,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _changeDownloadFolder,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    l10n.chooseOtherDirectory,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadingTab(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    List<RemoteDownloadTask> tasks,
    double totalSpeed,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_done_rounded,
              size: 56,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noActiveDownloads,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    final hasActive = tasks.any((t) =>
        t.status == RemoteDownloadStatus.downloading ||
        t.status == RemoteDownloadStatus.pending);
    final hasPaused = tasks.any((t) => t.status == RemoteDownloadStatus.paused);

    return Column(
      children: [
        // Controls Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: Row(
            children: [
              if (totalSpeed > 0) ...[
                Icon(
                  Icons.speed_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatSpeed(totalSpeed),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ] else ...[
                Text(
                  '${tasks.length} ${l10n.downloadingTab.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const Spacer(),
              if (hasActive)
                TextButton.icon(
                  icon: const Icon(Icons.pause_rounded, size: 16),
                  label: Text(l10n.pauseAll),
                  onPressed: () {
                    ref.read(remoteDownloadTasksProvider.notifier).pauseAll();
                  },
                ),
              if (hasPaused)
                TextButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: Text(l10n.resumeAll),
                  onPressed: () {
                    ref.read(remoteDownloadTasksProvider.notifier).resumeAll();
                  },
                ),
              TextButton.icon(
                icon: const Icon(Icons.close_rounded, size: 16),
                label: Text(l10n.cancelAll),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                onPressed: () {
                  ref.read(remoteDownloadTasksProvider.notifier).cancelAll();
                },
              ),
            ],
          ),
        ),
        // Tasks list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildDownloadingTaskCard(context, theme, l10n, task);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadingTaskCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    RemoteDownloadTask task,
  ) {
    final notifier = ref.read(remoteDownloadTasksProvider.notifier);
    final isDownloading = task.status == RemoteDownloadStatus.downloading;
    final isPaused = task.status == RemoteDownloadStatus.paused;
    final isFailed = task.status == RemoteDownloadStatus.failed;
    final isPending = task.status == RemoteDownloadStatus.pending;

    Color statusColor = theme.colorScheme.primary;
    if (isPaused) statusColor = Colors.amber;
    if (isFailed) statusColor = theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Server type chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: task.isSubsonic
                      ? Colors.deepPurple.withValues(alpha: 0.15)
                      : Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.isSubsonic ? 'Navidrome' : 'WebDAV',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: task.isSubsonic
                        ? Colors.deepPurpleAccent
                        : Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.song.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Controls
              if (isDownloading)
                IconButton(
                  icon: const Icon(Icons.pause_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Pause',
                  onPressed: () => notifier.pauseTask(task.id),
                )
              else if (isPaused)
                IconButton(
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Resume',
                  onPressed: () => notifier.resumeTask(task.id),
                )
              else if (isFailed)
                IconButton(
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Retry',
                  onPressed: () => notifier.retryTask(task.id),
                ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                tooltip: 'Cancel',
                onPressed: () => notifier.cancelTask(task.id),
              ),
            ],
          ),
          if (task.song.artist != null && task.song.artist!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              task.song.artist!,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: isDownloading || isPaused || task.progress > 0
                ? task.progress
                : null,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: statusColor,
            minHeight: 5,
            borderRadius: BorderRadius.circular(2.5),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isFailed)
                Expanded(
                  child: Text(
                    task.error ?? 'Download failed',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.error,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else if (isPaused)
                Text(
                  'Paused (${(task.progress * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.amber,
                  ),
                )
              else if (isPending)
                Text(
                  'Waiting in queue...',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Text(
                  '${(task.progress * 100).toStringAsFixed(0)}% · ${_formatSpeed(task.speedBytesPerSec)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              Text(
                '${_formatBytes(task.bytesDownloaded)} / ${_formatBytes(task.totalBytes)}',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTab(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    List<RemoteDownloadTask> tasks,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noCompletedDownloads,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    final notifier = ref.read(remoteDownloadTasksProvider.notifier);

    return Column(
      children: [
        // Completed header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tasks.length} ${l10n.completedTab.toLowerCase()}',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                label: Text(l10n.clearCompleted),
                onPressed: () {
                  notifier.clearCompleted();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildCompletedTaskTile(context, theme, l10n, task);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedTaskTile(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    RemoteDownloadTask task,
  ) {
    final notifier = ref.read(remoteDownloadTasksProvider.notifier);
    final isCancelled = task.status == RemoteDownloadStatus.cancelled;

    return ListTile(
      tileColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCancelled
              ? theme.colorScheme.errorContainer.withValues(alpha: 0.4)
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isCancelled ? Icons.cancel_outlined : Icons.music_note_rounded,
          color: isCancelled
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        task.song.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        isCancelled
            ? 'Cancelled'
            : '${task.song.artist ?? 'Unknown Artist'} · ${_formatBytes(task.bytesDownloaded)}',
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCancelled) ...[
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              tooltip: 'Play',
              onPressed: () async {
                final audioService = ref.read(audioServiceProvider);
                final file = File(task.targetPath);
                if (file.existsSync()) {
                  final localSong = MusicFile(
                    path: task.targetPath,
                    name: p.basename(task.targetPath),
                    title: task.song.title ?? task.song.name,
                    artist: task.song.artist,
                    album: task.song.album,
                  );
                  await audioService.playPlaylist([localSong]);
                } else {
                  showToast('File not found at ${task.targetPath}');
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.folder_open_rounded),
              tooltip: l10n.openFolderLocation,
              onPressed: () async {
                await openFolderLocation(p.dirname(task.targetPath));
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Remove',
            onPressed: () {
              notifier.removeTask(task.id);
            },
          ),
        ],
      ),
    );
  }
}
