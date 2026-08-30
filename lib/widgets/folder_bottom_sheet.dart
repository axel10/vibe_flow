import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/playback_source.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import '../widgets/library_selection_scope.dart';
import 'package:vynody/utils/app_snack_bar.dart';
import '../dialogs/transcode_dialog.dart';

Future<String?> showFolderBottomSheet(
  BuildContext context,
  WidgetRef ref,
  MusicFolder folder, {
  required bool isRoot,
  void Function(String folderPath)? onMultiSelect,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final audio = ref.read(audioServiceProvider);
  final playlistService = ref.read(playlistServiceProvider);
  final scanner = ref.read(scannerServiceProvider);
  final songs = await scanner.getSongsForFolder(folder);
  if (!context.mounted) return null;

  final canOpenLocation =
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux) &&
      folder.path.trim().isNotEmpty &&
      folder.path != 'system';

  final selectLabel = l10n.selectFolders;
  final removeLabel = l10n.removeDirectory;

  final previousScope = ref.read(librarySelectionScopeProvider);
  ref
      .read(librarySelectionScopeProvider.notifier)
      .setScope(LibrarySelectionScope.bottomSheet);

  final String? selected;
  try {
    selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  elevation: 16,
                  color: theme.colorScheme.surface,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 52,
                                height: 52,
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.4),
                                child: Icon(
                                  isRoot
                                      ? Icons.folder_shared
                                      : Icons.folder_rounded,
                                  size: 30,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    folder.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (isRoot && folder.path.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      folder.path,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.songCount(songs.length),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        _buildFolderBottomSheetItem(
                          context: context,
                          value: 'play_all',
                          label: l10n.playAll,
                          icon: Icons.play_arrow_rounded,
                          enabled: songs.isNotEmpty,
                        ),
                        _buildFolderBottomSheetItem(
                          context: context,
                          value: 'shuffle',
                          label: l10n.shufflePlay,
                          icon: Icons.shuffle_rounded,
                          enabled: songs.isNotEmpty,
                        ),
                        _buildFolderBottomSheetItem(
                          context: context,
                          value: 'play_next',
                          label: l10n.playNext,
                          icon: Icons.queue_play_next_rounded,
                          enabled: songs.isNotEmpty,
                        ),
                        _buildFolderBottomSheetItem(
                          context: context,
                          value: 'add_to_queue',
                          label: l10n.addToQueue,
                          icon: Icons.queue_music_rounded,
                          enabled: songs.isNotEmpty,
                        ),
                        _buildFolderBottomSheetItem(
                          context: context,
                          value: 'add_to_playlist',
                          label: l10n.addToPlaylist,
                          icon: Icons.playlist_add_rounded,
                          enabled: songs.isNotEmpty,
                        ),
                        _buildFolderBottomSheetItem(
                          context: context,
                          value: 'transcode',
                          label: l10n.transcodeAction,
                          icon: Icons.sync_rounded,
                          enabled: songs.isNotEmpty,
                        ),
                        if (canOpenLocation)
                          _buildFolderBottomSheetItem(
                            context: context,
                            value: 'open_folder_location',
                            label: l10n.openFolderLocation,
                            icon: Icons.folder_open_rounded,
                          ),
                        if (isRoot) ...[
                          _buildFolderBottomSheetItem(
                            context: context,
                            value: 'multi_select',
                            label: selectLabel,
                            icon: Icons.checklist_rounded,
                          ),
                          _buildFolderBottomSheetItem(
                            context: context,
                            value: 'remove_root',
                            label: removeLabel,
                            icon: Icons.delete_rounded,
                            iconColor: theme.colorScheme.error,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  } finally {
    if (ref.read(librarySelectionScopeProvider) ==
        LibrarySelectionScope.bottomSheet) {
      ref
          .read(librarySelectionScopeProvider.notifier)
          .setScope(previousScope);
    }
  }

  if (!context.mounted || selected == null) return null;

  switch (selected) {
    case 'play_all':
      await audio.playPlaylist(
        songs,
        source: PlaybackSource(
          type: PlaybackSourceType.folder,
          id: folder.path,
          name: folder.name,
        ),
      );
      break;
    case 'shuffle':
      await audio.playPlaylist(
        List.of(songs)..shuffle(),
        source: PlaybackSource(
          type: PlaybackSourceType.folder,
          id: folder.path,
          name: folder.name,
        ),
      );
      break;
    case 'play_next':
      await audio.enqueueNext(songs);
      break;
    case 'add_to_queue':
      await audio.appendToQueue(songs);
      break;
    case 'add_to_playlist':
      await showAddSongsToPlaylistDialog(context, playlistService, songs);
      break;
    case 'transcode':
      await showTranscodeDialog(context, songs: songs);
      break;
    case 'open_folder_location':
      await openFolderLocation(folder.path);
      break;
    case 'multi_select':
      ref
          .read(librarySelectionScopeProvider.notifier)
          .setScope(LibrarySelectionScope.folderRoot);
      onMultiSelect?.call(folder.path);
      break;
    case 'remove_root':
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(removeLabel),
          content: Text(
            l10n.removeRootDirectoryConfirmation(folder.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );
      if (confirm == true && context.mounted) {
        await scanner.removeRootPath(folder.path);
        if (context.mounted) {
          AppSnackBar.show(
            context,
            ref,
            SnackBar(content: Text(l10n.foldersDeleted(1))),
          );
        }
      }
      break;
  }

  return selected;
}

Widget _buildFolderBottomSheetItem({
  required BuildContext context,
  required String value,
  required String label,
  required IconData icon,
  bool enabled = true,
  Color? iconColor,
}) {
  final theme = Theme.of(context);
  return ListTile(
    leading: Icon(
      icon,
      color: enabled
          ? (iconColor ?? theme.colorScheme.onSurfaceVariant)
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
    ),
    title: Text(
      label,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: enabled
            ? (iconColor ?? theme.colorScheme.onSurface)
            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    ),
    enabled: enabled,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    onTap: () => Navigator.pop(context, value),
  );
}
