import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/library/playlist_service.dart';
import 'package:vynody/dialogs/transcode_dialog.dart';
import 'package:vynody/dialogs/song_details_dialog.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import 'package:vynody/l10n/app_localizations.dart';

class LibrarySelectionPanel extends ConsumerWidget {
  const LibrarySelectionPanel({
    super.key,
    required this.selectedSongs,
    required this.allSongs,
    required this.onToggleSelectAll,
    required this.onCancel,
    this.onDelete,
    this.deleteLabel,
    this.title,
    this.onOpenLocation,
    this.openLocationLabel,
    this.replaceFavoritesWithSongDetails = false,
    this.hideSongProperties = false,
    this.onPlayNext,
    this.onAddToQueue,
    this.onAddToPlaylist,
    this.onAddToFavorites,
    this.onDownload,
    this.isSelectionEmpty,
    this.isAllSelected,
  });

  final List<MusicFile> selectedSongs;
  final List<MusicFile> allSongs;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;
  final String? deleteLabel;
  final String? title;
  final VoidCallback? onOpenLocation;
  final String? openLocationLabel;
  final bool replaceFavoritesWithSongDetails;
  final bool hideSongProperties;
  final VoidCallback? onPlayNext;
  final VoidCallback? onAddToQueue;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onAddToFavorites;
  final VoidCallback? onDownload;
  final bool? isSelectionEmpty;
  final bool? isAllSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final audio = ref.read(audioServiceProvider);
    final playlistService = ref.read(playlistServiceProvider);

    final isAllSelected = this.isAllSelected ??
        (selectedSongs.length == allSongs.length && allSongs.isNotEmpty);
    final isEmpty = isSelectionEmpty ?? selectedSongs.isEmpty;
    final isSingleSelected = !isEmpty && selectedSongs.length == 1;

    final isRemote = selectedSongs.isNotEmpty &&
        (selectedSongs.first.path.startsWith('subsonic://') ||
            selectedSongs.first.path.startsWith('webdav://'));
    final hasFilePath = isSingleSelected &&
        selectedSongs.isNotEmpty &&
        selectedSongs.first.path.trim().isNotEmpty &&
        !isRemote;
    final canOpenLocation =
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux) &&
        (onOpenLocation != null || hasFilePath);

    final selectAllText = isAllSelected ? l10n.deselectAll : l10n.selectAll;

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final List<Widget> secondaryActionRows = [];
    {
      final secondaryActions = <Widget>[];

      if (replaceFavoritesWithSongDetails) {
        if (!hideSongProperties) {
          secondaryActions.add(
            _buildSelectionActionButton(
              context: context,
              icon: Icons.info_outline_rounded,
              label: l10n.songProperties,
              onPressed: selectedSongs.length == 1
                  ? () => showSongDetailsDialog(context, selectedSongs.first)
                  : null,
            ),
          );
        }
        secondaryActions.add(
          _buildSelectionActionButton(
            context: context,
            icon: Icons.sync_rounded,
            label: l10n.transcodeAction,
            onPressed: isEmpty
                ? null
                : () async {
                    await showTranscodeDialog(
                      context,
                      songs: selectedSongs,
                    );
                    onCancel();
                  },
          ),
        );
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          if (onOpenLocation != null || hasFilePath) {
            secondaryActions.add(
              _buildSelectionActionButton(
                context: context,
                icon: Icons.folder_open_rounded,
                label: openLocationLabel ?? l10n.openFileLocation,
                onPressed: canOpenLocation
                    ? () async {
                        if (onOpenLocation != null) {
                          onOpenLocation!();
                        } else {
                          await openSongFileLocation(
                            selectedSongs.first.path,
                          );
                        }
                        onCancel();
                      }
                    : null,
              ),
            );
          }
        }
        if (onDownload != null) {
          secondaryActions.add(
            _buildSelectionActionButton(
              context: context,
              icon: Icons.download_rounded,
              label: l10n.downloadSong.contains('下载') ? '下载' : 'Download',
              onPressed: isEmpty ? null : onDownload,
            ),
          );
        }
        if (onDelete != null) {
          secondaryActions.add(
            _buildSelectionActionButton(
              context: context,
              icon: Icons.delete_outline_rounded,
              label: deleteLabel ?? l10n.delete,
              onPressed: isEmpty ? null : onDelete,
            ),
          );
        }
      } else {
        secondaryActions.add(
          _buildSelectionActionButton(
            context: context,
            icon: Icons.favorite_rounded,
            label: l10n.addToFavorites,
            onPressed: isEmpty
                ? null
                : () async {
                    if (onAddToFavorites != null) {
                      onAddToFavorites!();
                    } else {
                      await playlistService.addSongsToPlaylist(
                        PlaylistService.favoritePlaylistId,
                        selectedSongs,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.addedToPlaylist(
                                selectedSongs.length,
                                l10n.favorites,
                              ),
                            ),
                          ),
                        );
                      }
                      onCancel();
                    }
                  },
          ),
        );
        secondaryActions.add(
          _buildSelectionActionButton(
            context: context,
            icon: Icons.sync_rounded,
            label: l10n.transcodeAction,
            onPressed: isEmpty
                ? null
                : () async {
                    await showTranscodeDialog(
                      context,
                      songs: selectedSongs,
                    );
                    onCancel();
                  },
          ),
        );
        if (!hideSongProperties) {
          secondaryActions.add(
            _buildSelectionActionButton(
              context: context,
              icon: Icons.info_outline_rounded,
              label: l10n.songProperties,
              onPressed: isSingleSelected
                  ? () => showSongDetailsDialog(context, selectedSongs.first)
                  : null,
            ),
          );
        }
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          if (onOpenLocation != null || hasFilePath) {
            secondaryActions.add(
              _buildSelectionActionButton(
                context: context,
                icon: Icons.folder_open_rounded,
                label: openLocationLabel ?? l10n.openFileLocation,
                onPressed: canOpenLocation
                    ? () async {
                        if (onOpenLocation != null) {
                          onOpenLocation!();
                        } else {
                          await openSongFileLocation(
                            selectedSongs.first.path,
                          );
                        }
                        onCancel();
                      }
                    : null,
              ),
            );
          }
        }
        if (onDownload != null) {
          secondaryActions.add(
            _buildSelectionActionButton(
              context: context,
              icon: Icons.download_rounded,
              label: l10n.downloadSong.contains('下载') ? '下载' : 'Download',
              onPressed: isEmpty ? null : onDownload,
            ),
          );
        }
        if (onDelete != null) {
          secondaryActions.add(
            _buildSelectionActionButton(
              context: context,
              icon: Icons.delete_outline_rounded,
              label: deleteLabel ?? l10n.delete,
              onPressed: isEmpty ? null : onDelete,
            ),
          );
        }
      }

      for (var i = 0; i < secondaryActions.length; i += 4) {
        final chunk = secondaryActions.sublist(
          i,
          i + 4 > secondaryActions.length ? secondaryActions.length : i + 4,
        );
        while (chunk.length < 4) {
          chunk.add(const SizedBox.shrink());
        }
        if (secondaryActionRows.isNotEmpty) {
          secondaryActionRows.add(const SizedBox(height: 8));
        }
        secondaryActionRows.add(
          Row(
            children: [
              Expanded(child: chunk[0]),
              const SizedBox(width: 8),
              Expanded(child: chunk[1]),
              const SizedBox(width: 8),
              Expanded(child: chunk[2]),
              const SizedBox(width: 8),
              Expanded(child: chunk[3]),
            ],
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isLandscape ? 620 : 372),
            child: Material(
              elevation: 16,
              color: theme.colorScheme.surface,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          title ?? l10n.selectedSongs(selectedSongs.length),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onCancel,
                          tooltip: l10n.cancel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSelectionActionButton(
                            context: context,
                            icon: isAllSelected
                                ? Icons.deselect
                                : Icons.select_all,
                            label: selectAllText,
                            onPressed: (allSongs.isEmpty && this.isAllSelected == null)
                                ? null
                                : onToggleSelectAll,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSelectionActionButton(
                            context: context,
                            icon: Icons.queue_play_next_rounded,
                            label: l10n.playNext,
                            onPressed: isEmpty
                                ? null
                                : () async {
                                    if (onPlayNext != null) {
                                      onPlayNext!();
                                    } else {
                                      await audio.enqueueNext(selectedSongs);
                                      onCancel();
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSelectionActionButton(
                            context: context,
                            icon: Icons.queue_music_rounded,
                            label: l10n.addToQueue,
                            onPressed: isEmpty
                                ? null
                                : () async {
                                    if (onAddToQueue != null) {
                                      onAddToQueue!();
                                    } else {
                                      await audio.appendToQueue(selectedSongs);
                                      onCancel();
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSelectionActionButton(
                            context: context,
                            icon: Icons.playlist_add_rounded,
                            label: l10n.playlist,
                            onPressed: isEmpty
                                ? null
                                : () async {
                                    if (onAddToPlaylist != null) {
                                      onAddToPlaylist!();
                                    } else {
                                      await showAddSongsToPlaylistDialog(
                                        context,
                                        playlistService,
                                        selectedSongs,
                                      );
                                      onCancel();
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...secondaryActionRows,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.38,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
