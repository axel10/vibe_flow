import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';
import '../../models/music_file.dart';
import '../../player/audio/audio_riverpod.dart';
import '../../player/remote/remote_server_models.dart';
import '../../player/remote/remote_server_riverpod.dart';
import '../../player/remote/clients/webdav_client.dart';
import '../../player/remote/proxy/remote_media_resolver.dart';
import '../../l10n/app_localizations.dart';
import '../../player/remote/services/remote_download_service.dart';
import '../../utils/app_snack_bar.dart';
import '../../widgets/desktop_window_title_bar.dart';
import '../../widgets/mini_player_wrapper.dart';
import 'remote_download_manager_page.dart';

class WebDavBrowserPage extends ConsumerStatefulWidget {
  final RemoteServer server;
  final String password;
  final String? initialPath;
  final bool wrapWithMiniPlayer;

  const WebDavBrowserPage({
    super.key,
    required this.server,
    required this.password,
    this.initialPath,
    this.wrapWithMiniPlayer = false,
  });

  @override
  ConsumerState<WebDavBrowserPage> createState() => _WebDavBrowserPageState();
}

class _WebDavBrowserPageState extends ConsumerState<WebDavBrowserPage> {
  late final WebDavClient _client;
  late String _rootPath;
  late String _currentPath;
  bool _isLoading = false;
  String? _error;
  List<WebDavFile> _items = [];

  @override
  void initState() {
    super.initState();
    _client = WebDavClient(
      server: widget.server,
      password: widget.password,
    );
    _rootPath = widget.initialPath ??
        (widget.server.customPath?.trim().isNotEmpty == true
            ? widget.server.customPath!
            : '/');
    _currentPath = _rootPath;
    _loadDirectory(_currentPath);
  }

  bool get _isAtRoot {
    if (_currentPath.isEmpty || _currentPath == '/' || _currentPath == _rootPath) {
      return true;
    }
    final cleanCurrent = _currentPath.endsWith('/') && _currentPath.length > 1
        ? _currentPath.substring(0, _currentPath.length - 1)
        : _currentPath;
    final cleanRoot = _rootPath.endsWith('/') && _rootPath.length > 1
        ? _rootPath.substring(0, _rootPath.length - 1)
        : _rootPath;
    return cleanCurrent == cleanRoot;
  }

  Future<void> _loadDirectory(String path) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPath = path;
    });

    try {
      final list = await _client.listFiles(path);
      // Sort: folders first, then files alphabetically
      list.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      var effectivePath = path;
      if (path == '/' && list.isNotEmpty && list.first.path.startsWith('/dav')) {
        effectivePath = '/dav';
        if (_rootPath == '/') {
          _rootPath = '/dav';
        }
      }

      if (mounted) {
        setState(() {
          _items = list;
          _currentPath = effectivePath;
          _isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final activeSession = ref.read(activeRemoteSessionProvider);
          if (activeSession != null &&
              activeSession.server.id == widget.server.id &&
              activeSession.initialPath != effectivePath) {
            ref
                .read(activeRemoteSessionProvider.notifier)
                .updateInitialPath(effectivePath);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<MusicFile> _getAudioFiles() {
    return _items
        .where((item) => item.isAudio)
        .map((item) => RemoteMediaResolver.buildMusicFileFromWebDav(item, widget.server))
        .toList();
  }

  Future<void> _playFolder({bool shuffle = false}) async {
    final audioFiles = _getAudioFiles();
    if (audioFiles.isEmpty) {
      showToast('No audio files in this folder');
      return;
    }

    final audioService = ref.read(audioServiceProvider);
    final playlist = List<MusicFile>.from(audioFiles);
    if (shuffle) {
      playlist.shuffle();
    }
    await audioService.playPlaylist(playlist);
    showToast('Playing ${playlist.length} songs');
  }

  Future<void> _downloadAllAudio() async {
    final l10n = AppLocalizations.of(context)!;
    final audioItems =
        _items.where((i) => !i.isDirectory && i.isAudio).toList();
    if (audioItems.isEmpty) {
      showToast(l10n.noActiveDownloads);
      return;
    }

    final notifier = ref.read(remoteDownloadTasksProvider.notifier);
    await notifier.enqueueWebDavFiles(
      server: widget.server,
      password: widget.password,
      files: audioItems,
    );

    if (mounted) {
      AppSnackBar.show(
        context,
        ref,
        SnackBar(
          content: Text(l10n.batchAddedToDownloadQueue(audioItems.length)),
          action: SnackBarAction(
            label: l10n.viewDownloadProgress,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RemoteDownloadManagerPage(),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _downloadSingleAudio(WebDavFile item) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(remoteDownloadTasksProvider.notifier);
    await notifier.enqueueWebDavFile(
      server: widget.server,
      password: widget.password,
      file: item,
    );

    if (mounted) {
      AppSnackBar.show(
        context,
        ref,
        SnackBar(
          content: Text(l10n.addedToDownloadQueue),
          action: SnackBarAction(
            label: l10n.viewDownloadProgress,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RemoteDownloadManagerPage(),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  void _navigateToParent() {
    if (_isAtRoot) return;
    var parent = p.dirname(_currentPath);
    if (parent == '.' || parent.isEmpty) {
      parent = _rootPath;
    }
    _loadDirectory(parent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final audioCount = _items.where((i) => i.isAudio).length;
    final isMacOS = Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    Widget content = PopScope(
      canPop: _isAtRoot,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(activeRemoteSessionProvider.notifier).clear();
          return;
        }
        if (!_isAtRoot) {
          _navigateToParent();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Exit',
            onPressed: () {
              ref.read(activeRemoteSessionProvider.notifier).clear();
              Navigator.of(context).maybePop();
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.server.name),
              Text(
                'WebDAV Storage',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            if (audioCount > 0) ...[
              IconButton(
                icon: const Icon(Icons.play_circle_fill_rounded),
                tooltip: 'Play All',
                onPressed: () => _playFolder(shuffle: false),
              ),
              IconButton(
                icon: const Icon(Icons.shuffle_rounded),
                tooltip: 'Shuffle',
                onPressed: () => _playFolder(shuffle: true),
              ),
              IconButton(
                icon: const Icon(Icons.download_for_offline_outlined),
                tooltip: 'Download All Audio',
                onPressed: _downloadAllAudio,
              ),
            ],
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: () => _loadDirectory(_currentPath),
            ),
            IconButton(
              icon: Badge(
                isLabelVisible: ref.watch(activeDownloadsCountProvider) > 0,
                label: Text('${ref.watch(activeDownloadsCountProvider)}'),
                child: const Icon(Icons.download_rounded),
              ),
              tooltip: 'Download Manager',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RemoteDownloadManagerPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Breadcrumbs path header
            _buildBreadcrumbs(theme),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 48,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Error: $_error',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () => _loadDirectory(_currentPath),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _items.isEmpty
                          ? const Center(child: Text('Folder is empty'))
                          : RefreshIndicator(
                              onRefresh: () => _loadDirectory(_currentPath),
                              child: ListView.builder(
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  if (item.isDirectory) {
                                    return ListTile(
                                      leading: const Icon(
                                        Icons.folder_rounded,
                                        color: Colors.amber,
                                        size: 28,
                                      ),
                                      title: Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      trailing: const Icon(Icons.chevron_right_rounded),
                                      onTap: () {
                                        _loadDirectory(item.path);
                                      },
                                    );
                                  }

                                  // Only emphasize audio files
                                  final isAudio = item.isAudio;
                                  final remoteUri = RemoteMediaResolver.buildWebDavUri(
                                    widget.server.id,
                                    item.path,
                                  );
                                  final isPlaying = currentMusic?.path == remoteUri;

                                  return ListTile(
                                    leading: Icon(
                                      isAudio
                                          ? (isPlaying
                                              ? Icons.volume_up_rounded
                                              : Icons.music_note_rounded)
                                          : Icons.insert_drive_file_outlined,
                                      color: isAudio
                                          ? (isPlaying
                                              ? theme.colorScheme.primary
                                              : Colors.blue)
                                          : theme.colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                    ),
                                    title: Text(
                                      item.name,
                                      style: TextStyle(
                                        color: isPlaying
                                            ? theme.colorScheme.primary
                                            : (isAudio
                                                ? null
                                                : theme.colorScheme.onSurfaceVariant
                                                    .withValues(alpha: 0.6)),
                                        fontWeight: isPlaying
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _formatFileSize(item.contentLength),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    trailing: isAudio
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  isPlaying
                                                      ? Icons.pause_circle_rounded
                                                      : Icons.play_circle_rounded,
                                                  size: 28,
                                                  color: theme.colorScheme.primary,
                                                ),
                                                onPressed: () async {
                                                  final audioService =
                                                      ref.read(audioServiceProvider);
                                                  if (isPlaying) {
                                                    await audioService.togglePlay();
                                                    return;
                                                  }
                                                  final audioFiles = _getAudioFiles();
                                                  final target =
                                                      RemoteMediaResolver.buildMusicFileFromWebDav(
                                                    item,
                                                    widget.server,
                                                  );
                                                  final initialIndex =
                                                      audioFiles.indexWhere((s) => s.path == target.path);
                                                  await audioService.playPlaylist(
                                                    audioFiles.isNotEmpty ? audioFiles : [target],
                                                    initialIndex: initialIndex >= 0 ? initialIndex : 0,
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.download_rounded, size: 22),
                                                tooltip: 'Download',
                                                onPressed: () => _downloadSingleAudio(item),
                                              ),
                                            ],
                                          )
                                        : null,
                                    onTap: isAudio
                                        ? () async {
                                            final audioFiles = _getAudioFiles();
                                            final target =
                                                RemoteMediaResolver.buildMusicFileFromWebDav(
                                              item,
                                              widget.server,
                                            );
                                            final initialIndex =
                                                audioFiles.indexWhere((s) => s.path == target.path);
                                            final audioService =
                                                ref.read(audioServiceProvider);
                                            await audioService.playPlaylist(
                                              audioFiles.isNotEmpty ? audioFiles : [target],
                                              initialIndex: initialIndex >= 0 ? initialIndex : 0,
                                            );
                                          }
                                        : null,
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
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

    if (widget.wrapWithMiniPlayer) {
      return MiniPlayerWrapper(child: content);
    }
    return content;
  }

  Widget _buildBreadcrumbs(ThemeData theme) {
    final segments = _currentPath
        .split('/')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward_rounded, size: 20),
            tooltip: 'Up to parent folder',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: _isAtRoot ? null : _navigateToParent,
          ),
          const SizedBox(width: 4),
          const SizedBox(
            height: 16,
            child: VerticalDivider(width: 8, thickness: 1),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _loadDirectory(_rootPath),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_queue_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          const Text('Root', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  for (int i = 0; i < segments.length; i++) ...[
                    const Icon(Icons.chevron_right_rounded, size: 16),
                    InkWell(
                      onTap: () {
                        final targetPath = '/${segments.sublist(0, i + 1).join('/')}';
                        _loadDirectory(targetPath);
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          segments[i],
                          style: TextStyle(
                            fontWeight: i == segments.length - 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: i == segments.length - 1
                                ? theme.colorScheme.primary
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
