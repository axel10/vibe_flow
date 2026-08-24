import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dialogs/transcode_dialog.dart';
import '../dialogs/song_details_dialog.dart';
import '../l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/library/playlist_service.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/widgets/song_thumbnail.dart';
import 'app_snack_bar.dart';
import 'playlist_name.dart';

enum SongContextMenuMode { full, title, artistAlbum }

bool isVisibleSongText(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return false;
  final lower = trimmed.toLowerCase();
  return lower != 'unknown' &&
      lower != 'unknown artist' &&
      lower != 'unknown album';
}

Future<void> openSongFileLocation(String filePath) async {
  if (filePath.trim().isEmpty) return;

  final normalizedPath = File(filePath).absolute.path;
  if (!File(normalizedPath).existsSync()) {
    debugPrint(
      '[SongContextMenu] Cannot open file location, file missing: $normalizedPath',
    );
    return;
  }

  try {
    if (Platform.isWindows) {
      final cmd = 'explorer.exe /select,"$normalizedPath"';
      // windows上只能用Process.run(cmd, [])这种方式打开，不要尝试修改
      await Process.run(cmd, []);
    } else if (Platform.isMacOS) {
      await Process.run('open', ['-R', normalizedPath]);
    } else if (Platform.isLinux) {
      final parentDir = File(normalizedPath).parent.path;

      final launchers = <List<String>>[
        ['nautilus', '--select', normalizedPath],
        ['dolphin', '--select', normalizedPath],
        ['nemo', '--no-desktop', normalizedPath],
        ['thunar', parentDir],
        ['xdg-open', parentDir],
      ];

      for (final launcher in launchers) {
        try {
          final result = await Process.run(
            launcher.first,
            launcher.skip(1).toList(growable: false),
          );
          if (result.exitCode == 0) {
            return;
          }
        } catch (_) {
          // Try the next file manager command.
        }
      }
    }
  } catch (e) {
    debugPrint('[SongContextMenu] Failed to open file location: $e');
  }
}

Future<void> openFolderLocation(String folderPath) async {
  if (folderPath.trim().isEmpty) return;

  final normalizedPath = Directory(folderPath).absolute.path;
  if (!Directory(normalizedPath).existsSync()) {
    debugPrint(
      '[FolderContextMenu] Cannot open folder location, folder missing: $normalizedPath',
    );
    return;
  }

  try {
    if (Platform.isWindows) {
      await Process.run('explorer.exe', [normalizedPath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [normalizedPath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [normalizedPath]);
    }
  } catch (e) {
    debugPrint('[FolderContextMenu] Failed to open folder location: $e');
  }
}

String _getRemoveFromQueueLabel(BuildContext context) {
  return AppLocalizations.of(context)!.removeFromQueue;
}

String _getRemoveFromPlaylistLabel(BuildContext context) {
  return AppLocalizations.of(context)!.removeFromPlaylist;
}

Future<void> showSongContextMenu(
  BuildContext context,
  Offset globalPosition, {
  required MusicFile? song,
  List<MusicFile>? songs,
  SongContextMenuMode mode = SongContextMenuMode.full,
  Future<void> Function()? onAddToPlaylist,
  VoidCallback? onPlayNext,
  VoidCallback? onAddToQueue,
  VoidCallback? onRemoveFromQueue,
  VoidCallback? onRemoveFromPlaylist,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;
  final l10n = AppLocalizations.of(context)!;

  final titleText = song?.displayName.trim() ?? '';
  final artistText = song?.artist?.trim() ?? '';
  final albumText = song?.album?.trim() ?? '';
  final hasTitle = titleText.isNotEmpty;
  final hasArtist = isVisibleSongText(artistText);
  final hasAlbum = isVisibleSongText(albumText);
  final isRemoteSong = song != null &&
      (song.path.startsWith('subsonic://') || song.path.startsWith('webdav://'));
  final hasFilePath = song != null && song.path.trim().isNotEmpty;
  final canOpenLocation =
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux) &&
      hasFilePath &&
      !isRemoteSong;


  final items = <PopupMenuEntry<String>>[];

  // 1. Playback actions (Top)
  if (onPlayNext != null) {
    items.add(
      buildContextMenuItem<String>(
        value: 'play_next',
        label: l10n.playNext,
        icon: Icons.queue_play_next_rounded,
        context: context,
      ),
    );
  }
  if (onAddToQueue != null) {
    items.add(
      buildContextMenuItem<String>(
        value: 'add_to_queue',
        label: l10n.addToQueue,
        icon: Icons.queue_music_rounded,
        context: context,
      ),
    );
  }
  if (onRemoveFromQueue != null) {
    items.add(
      buildContextMenuItem<String>(
        value: 'remove_from_queue',
        label: _getRemoveFromQueueLabel(context),
        icon: Icons.playlist_remove_rounded,
        context: context,
      ),
    );
  }
  if (onRemoveFromPlaylist != null) {
    items.add(
      buildContextMenuItem<String>(
        value: 'remove_from_playlist',
        label: _getRemoveFromPlaylistLabel(context),
        icon: Icons.delete_outline_rounded,
        context: context,
      ),
    );
  }

  final hasPlaybackActions =
      onPlayNext != null ||
      onAddToQueue != null ||
      onRemoveFromQueue != null ||
      onRemoveFromPlaylist != null;

  final hasStandardActions =
      mode != SongContextMenuMode.full ||
      canOpenLocation ||
      hasTitle ||
      hasArtist ||
      hasAlbum ||
      song != null ||
      onAddToPlaylist != null;

  if (hasPlaybackActions && hasStandardActions) {
    items.add(const PopupMenuDivider());
  }

  // 2. Standard Metadata / File Actions
  switch (mode) {
    case SongContextMenuMode.full:
      items.addAll([
        buildContextMenuItem<String>(
          value: 'open_file_location',
          enabled: canOpenLocation,
          label: l10n.openFileLocation,
          icon: Icons.folder_open_rounded,
          context: context,
        ),
        buildContextMenuItem<String>(
          value: 'song_details',
          enabled: song != null,
          label: l10n.songProperties,
          icon: Icons.info_outline_rounded,
          context: context,
        ),
        const PopupMenuDivider(),
        buildContextMenuItem<String>(
          value: 'copy_title',
          enabled: hasTitle,
          label: l10n.copyTitle,
          icon: Icons.title_rounded,
          context: context,
        ),
        buildContextMenuItem<String>(
          value: 'copy_album',
          enabled: hasAlbum,
          label: l10n.copyAlbumTitle,
          icon: Icons.album_rounded,
          context: context,
        ),
        buildContextMenuItem<String>(
          value: 'copy_artist',
          enabled: hasArtist,
          label: l10n.copyArtistName,
          icon: Icons.person_rounded,
          context: context,
        ),
        const PopupMenuDivider(),
        buildContextMenuItem<String>(
          value: 'transcode',
          enabled: song != null || (songs != null && songs.isNotEmpty),
          label: l10n.transcodeAction,
          icon: Icons.sync_rounded,
          context: context,
        ),
      ]);
      break;
    case SongContextMenuMode.title:
      items.addAll([
        buildContextMenuItem<String>(
          value: 'copy_title',
          enabled: hasTitle,
          label: l10n.copyTitle,
          icon: Icons.title_rounded,
          context: context,
        ),
        const PopupMenuDivider(),
        buildContextMenuItem<String>(
          value: 'open_file_location',
          enabled: canOpenLocation,
          label: l10n.openFileLocation,
          icon: Icons.folder_open_rounded,
          context: context,
        ),
      ]);
      break;
    case SongContextMenuMode.artistAlbum:
      items.addAll([
        buildContextMenuItem<String>(
          value: 'copy_artist',
          enabled: hasArtist,
          label: l10n.copyArtistName,
          icon: Icons.person_rounded,
          context: context,
        ),
        buildContextMenuItem<String>(
          value: 'copy_album',
          enabled: hasAlbum,
          label: l10n.copyAlbumTitle,
          icon: Icons.album_rounded,
          context: context,
        ),
      ]);
      break;
  }

  if (onAddToPlaylist != null) {
    if (items.isNotEmpty && items.last is! PopupMenuDivider) {
      items.add(const PopupMenuDivider());
    }
    items.add(
      buildContextMenuItem<String>(
        value: 'add_to_playlist',
        label: l10n.addToPlaylist,
        icon: Icons.playlist_add_rounded,
        context: context,
      ),
    );
  }

  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    ),
    items: items,
  );

  if (!context.mounted || selected == null) return;

  switch (selected) {
    case 'play_next':
      onPlayNext?.call();
      break;
    case 'add_to_queue':
      onAddToQueue?.call();
      break;
    case 'remove_from_queue':
      onRemoveFromQueue?.call();
      break;
    case 'remove_from_playlist':
      onRemoveFromPlaylist?.call();
      break;
    case 'copy_title':
      if (hasTitle) {
        await Clipboard.setData(ClipboardData(text: titleText));
      }
      break;
    case 'copy_artist':
      if (hasArtist) {
        await Clipboard.setData(ClipboardData(text: artistText));
      }
      break;
    case 'copy_album':
      if (hasAlbum) {
        await Clipboard.setData(ClipboardData(text: albumText));
      }
      break;
    case 'open_file_location':
      if (canOpenLocation) {
        await openSongFileLocation(song.path);
      }
      break;
    case 'song_details':
      if (song != null) {
        await showSongDetailsDialog(context, song);
      }
      break;
    case 'add_to_playlist':
      if (onAddToPlaylist != null) {
        await onAddToPlaylist();
      }
      break;
    case 'transcode':
      if (songs != null && songs.isNotEmpty) {
        await showTranscodeDialog(context, songs: songs);
      } else if (song != null) {
        await showTranscodeDialog(context, songs: [song]);
      }
      break;
  }
}

Future<void> showAddSongsToPlaylistDialog(
  BuildContext context,
  PlaylistService playlistService,
  List<MusicFile> songs,
) async {
  if (songs.isEmpty) return;

  Future<void> addSongsToPlaylist(Playlist playlist) async {
    await playlistService.addSongsToPlaylist(playlist.id, songs);
    if (!context.mounted) return;
    AppSnackBar.show(
      context,
      null,
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.addedToPlaylist(
            songs.length,
            localizedPlaylistName(context, playlist),
          ),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> showCreatePlaylistDialog() async {
    final controller = TextEditingController();
    String? errorText;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(AppLocalizations.of(dialogContext)!.createPlaylist),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(dialogContext)!.playlistName,
              hintText: AppLocalizations.of(dialogContext)!.enterPlaylistName,
              errorText: errorText,
            ),
            onChanged: (val) {
              if (errorText != null) {
                setState(() {
                  errorText = null;
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                if (playlistService.playlistExists(name)) {
                  setState(() {
                    errorText = AppLocalizations.of(
                      dialogContext,
                    )!.playlistNameExists;
                  });
                  return;
                }

                final playlist = await playlistService.createPlaylist(name);
                await playlistService.addSongsToPlaylist(playlist.id, songs);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (context.mounted) {
                  AppSnackBar.show(
                    context,
                    null,
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.createdPlaylist(name, songs.length),
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              child: Text(AppLocalizations.of(dialogContext)!.createPlaylist),
            ),
          ],
        ),
      ),
    );
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(AppLocalizations.of(dialogContext)!.addToPlaylist),
      content: SizedBox(
        width: double.maxFinite,
        height: 320,
        child: ListView.builder(
          itemCount: playlistService.playlists.length,
          itemBuilder: (itemContext, index) {
            final playlist = playlistService.playlists[index];
            return ListTile(
              leading: const Icon(Icons.playlist_play),
              title: Text(localizedPlaylistName(itemContext, playlist)),
              subtitle: Text(
                AppLocalizations.of(
                  itemContext,
                )!.songCount(playlist.songs.length),
              ),
              onTap: () async {
                Navigator.pop(dialogContext);
                await addSongsToPlaylist(playlist);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(AppLocalizations.of(dialogContext)!.cancel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await showCreatePlaylistDialog();
          },
          child: Text(AppLocalizations.of(dialogContext)!.createNewList),
        ),
      ],
    ),
  );
}

Future<void> showFolderContextMenu(
  BuildContext context,
  Offset globalPosition, {
  required String folderPath,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;
  final l10n = AppLocalizations.of(context)!;

  final canOpenLocation =
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux) &&
      folderPath.trim().isNotEmpty;

  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    ),
    items: [
      buildContextMenuItem<String>(
        value: 'open_folder_location',
        enabled: canOpenLocation,
        label: l10n.openFolderLocation,
        icon: Icons.folder_open_rounded,
        context: context,
      ),
    ],
  );

  if (!context.mounted || selected == null) return;

  if (selected == 'open_folder_location' && canOpenLocation) {
    await openFolderLocation(folderPath);
  }
}

PopupMenuItem<T> buildContextMenuItem<T>({
  required T value,
  required String label,
  required IconData icon,
  required BuildContext context,
  bool enabled = true,
  Color? iconColor,
}) {
  final theme = Theme.of(context);
  final defaultIconColor = theme.colorScheme.onSurfaceVariant;
  return PopupMenuItem<T>(
    value: value,
    enabled: enabled,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: enabled
              ? (iconColor ?? defaultIconColor)
              : defaultIconColor.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: enabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    ),
  );
}

Future<void> showSongBottomSheet(
  BuildContext context,
  WidgetRef ref,
  MusicFile song,
) async {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final audio = ref.read(audioServiceProvider);
  final playlistService = ref.read(playlistServiceProvider);

  final hasFilePath = song.path.trim().isNotEmpty;
  final canOpenLocation =
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux) &&
      hasFilePath;

  final selected = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
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
                onTap:
                    () {}, // Prevent taps on the card itself from closing the sheet
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
                        // Header showing Song title and artwork
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 52,
                                height: 52,
                                child: SongThumbnail(
                                  path: song.path,
                                  id: song.id,
                                  size: 52,
                                  borderRadius: BorderRadius.zero,
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
                                    song.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${song.artist ?? l10n.unknownArtist} · ${song.album ?? l10n.unknownAlbum}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
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
                        // Actions list
                        _buildBottomSheetItem(
                          context: context,
                          value: 'play_next',
                          label: l10n.playNext,
                          icon: Icons.queue_play_next_rounded,
                        ),
                        _buildBottomSheetItem(
                          context: context,
                          value: 'add_to_queue',
                          label: l10n.addToQueue,
                          icon: Icons.queue_music_rounded,
                        ),
                        _buildBottomSheetItem(
                          context: context,
                          value: 'add_to_playlist',
                          label: l10n.addToPlaylist,
                          icon: Icons.playlist_add_rounded,
                        ),
                        _buildBottomSheetItem(
                          context: context,
                          value: 'add_to_favorites',
                          label: l10n.addToFavorites,
                          icon: Icons.favorite_border_rounded,
                        ),
                        _buildBottomSheetItem(
                          context: context,
                          value: 'transcode',
                          label: l10n.transcodeAction,
                          icon: Icons.sync_rounded,
                        ),
                        _buildBottomSheetItem(
                          context: context,
                          value: 'copy_title',
                          label: l10n.copyTitle,
                          icon: Icons.title_rounded,
                        ),
                        _buildBottomSheetItem(
                          context: context,
                          value: 'copy_artist',
                          label: l10n.copyArtistName,
                          icon: Icons.person_rounded,
                        ),
                        if (canOpenLocation)
                          _buildBottomSheetItem(
                            context: context,
                            value: 'open_location',
                            label: l10n.openFileLocation,
                            icon: Icons.folder_open_rounded,
                          ),
                        _buildBottomSheetItem(
                          context: context,
                          value: 'song_details',
                          label: l10n.songProperties,
                          icon: Icons.info_outline_rounded,
                        ),
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

  if (!context.mounted || selected == null) return;

  switch (selected) {
    case 'play_next':
      await audio.enqueueNext([song]);
      break;
    case 'add_to_queue':
      await audio.appendToQueue([song]);
      break;
    case 'add_to_playlist':
      await showAddSongsToPlaylistDialog(context, playlistService, [song]);
      break;
    case 'add_to_favorites':
      await playlistService.addSongToFavorite(song);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.addToFavorites} · ${song.displayName}'),
          ),
        );
      }
      break;
    case 'transcode':
      await showTranscodeDialog(context, songs: [song]);
      break;
    case 'copy_title':
      await Clipboard.setData(ClipboardData(text: song.displayName));
      break;
    case 'copy_artist':
      if (song.artist != null) {
        await Clipboard.setData(ClipboardData(text: song.artist!));
      }
      break;
    case 'open_location':
      await openSongFileLocation(song.path);
      break;
    case 'song_details':
      await showSongDetailsDialog(context, song);
      break;
  }
}

Widget _buildBottomSheetItem({
  required BuildContext context,
  required String value,
  required String label,
  required IconData icon,
  Color? iconColor,
}) {
  final theme = Theme.of(context);
  return ListTile(
    leading: Icon(icon, color: iconColor ?? theme.colorScheme.onSurfaceVariant),
    title: Text(
      label,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: iconColor ?? theme.colorScheme.onSurface,
      ),
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    onTap: () => Navigator.pop(context, value),
  );
}
