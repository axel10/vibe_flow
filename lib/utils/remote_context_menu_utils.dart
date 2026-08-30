import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import '../dialogs/remote_playlist_dialog.dart';
import '../dialogs/song_details_dialog.dart';
import '../l10n/app_localizations.dart';
import '../models/music_file.dart';
import '../player/audio/audio_riverpod.dart';
import '../player/audio/playback_source.dart';
import '../player/remote/clients/subsonic_client.dart';
import '../player/remote/clients/webdav_client.dart';
import '../player/remote/proxy/remote_media_resolver.dart';
import '../player/remote/remote_server_models.dart';
import '../pages/remote/remote_download_manager_page.dart';
import '../player/remote/services/remote_download_service.dart';
import '../widgets/library_selection_scope.dart';
import 'app_snack_bar.dart';
import 'song_context_menu_utils.dart';

/// Helper to fetch tracks of an album on-demand if not already supplied
Future<List<MusicFile>> _fetchAlbumTracks(
  SubsonicClient client,
  RemoteServer server,
  String albumId,
) async {
  try {
    final album = await client.getAlbum(albumId);
    final songList = album?['song'] as List?;
    if (songList != null && songList.isNotEmpty) {
      final List<MusicFile> parsed = [];
      for (final item in songList) {
        if (item is Map<String, dynamic>) {
          parsed.add(
            RemoteMediaResolver.buildMusicFileFromSubsonic(item, server),
          );
        }
      }
      return parsed;
    }
  } catch (_) {}
  return [];
}

/// Helper to fetch tracks of an artist on-demand
Future<List<MusicFile>> _fetchArtistTracks(
  SubsonicClient client,
  RemoteServer server,
  String artistId,
) async {
  try {
    final artistMap = await client.getArtist(artistId);
    if (artistMap != null) {
      final dynamic rawAlbums = artistMap['album'];
      final List<Map<String, dynamic>> albumList = [];
      if (rawAlbums is List) {
        albumList.addAll(rawAlbums.whereType<Map<String, dynamic>>());
      } else if (rawAlbums is Map<String, dynamic>) {
        albumList.add(rawAlbums);
      }

      final List<MusicFile> allSongs = [];
      for (final al in albumList) {
        final aId = al['id'] as String?;
        if (aId != null) {
          final fullAlbum = await client.getAlbum(aId);
          final sData = fullAlbum?['song'] as List?;
          if (sData != null) {
            for (final s in sData) {
              if (s is Map<String, dynamic>) {
                allSongs.add(
                  RemoteMediaResolver.buildMusicFileFromSubsonic(s, server),
                );
              }
            }
          }
        }
      }
      return allSongs;
    }
  } catch (_) {}
  return [];
}

/// Shows context menu for a remote Navidrome album.
Future<void> showRemoteAlbumContextMenu({
  required BuildContext context,
  required Offset globalPosition,
  required WidgetRef ref,
  required RemoteServer server,
  required String password,
  required String albumId,
  required String albumTitle,
  required String artistName,
  String? coverArtId,
  List<MusicFile>? songs,
  VoidCallback? onViewDetails,
  VoidCallback? onViewArtist,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;
  final l10n = AppLocalizations.of(context)!;
  final client = SubsonicClient(server: server, password: password);
  final isMobile = Platform.isAndroid || Platform.isIOS;

  if (isMobile) {
    // BottomSheet for mobile
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      albumTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.play_arrow_rounded),
                    title: Text(l10n.playAll),
                    onTap: () => Navigator.pop(ctx, 'play'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shuffle_rounded),
                    title: Text(l10n.shufflePlay),
                    onTap: () => Navigator.pop(ctx, 'shuffle'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.queue_play_next_rounded),
                    title: Text(l10n.playNext),
                    onTap: () => Navigator.pop(ctx, 'play_next'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.queue_music_rounded),
                    title: Text(l10n.addToQueue),
                    onTap: () => Navigator.pop(ctx, 'add_to_queue'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.playlist_add_rounded),
                    title: Text(l10n.addToServerPlaylist),
                    onTap: () => Navigator.pop(ctx, 'add_to_server_playlist'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_border_rounded),
                    title: Text(l10n.starItem),
                    onTap: () => Navigator.pop(ctx, 'star'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text(l10n.downloadAlbum),
                    onTap: () => Navigator.pop(ctx, 'download'),
                  ),
                  if (onViewDetails != null)
                    ListTile(
                      leading: const Icon(Icons.album_rounded),
                      title: Text(l10n.viewAlbumDetails),
                      onTap: () => Navigator.pop(ctx, 'view_details'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!context.mounted || selected == null) return;
    await _handleAlbumMenuSelection(
      selected: selected,
      context: context,
      ref: ref,
      client: client,
      server: server,
      password: password,
      albumId: albumId,
      albumTitle: albumTitle,
      artistName: artistName,
      songs: songs,
      onViewDetails: onViewDetails,
      onViewArtist: onViewArtist,
    );
    return;
  }

  // Desktop PopupMenu
  final items = <PopupMenuEntry<String>>[
    buildContextMenuItem<String>(
      value: 'play',
      label: l10n.playAll,
      icon: Icons.play_arrow_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'shuffle',
      label: l10n.shufflePlay,
      icon: Icons.shuffle_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'play_next',
      label: l10n.playNext,
      icon: Icons.queue_play_next_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'add_to_queue',
      label: l10n.addToQueue,
      icon: Icons.queue_music_rounded,
      context: context,
    ),
    const PopupMenuDivider(),
    buildContextMenuItem<String>(
      value: 'add_to_server_playlist',
      label: l10n.addToServerPlaylist,
      icon: Icons.playlist_add_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'star',
      label: l10n.starItem,
      icon: Icons.favorite_border_rounded,
      context: context,
    ),
    const PopupMenuDivider(),
    buildContextMenuItem<String>(
      value: 'download',
      label: l10n.downloadAlbum,
      icon: Icons.download_rounded,
      context: context,
    ),
    const PopupMenuDivider(),
    if (onViewDetails != null)
      buildContextMenuItem<String>(
        value: 'view_details',
        label: l10n.viewAlbumDetails,
        icon: Icons.album_rounded,
        context: context,
      ),
    if (onViewArtist != null)
      buildContextMenuItem<String>(
        value: 'view_artist',
        label: l10n.viewArtistDetails,
        icon: Icons.person_rounded,
        context: context,
      ),
    buildContextMenuItem<String>(
      value: 'copy_title',
      label: l10n.copyAlbumTitle,
      icon: Icons.copy_rounded,
      context: context,
    ),
  ];

  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    ),
    items: items,
  );

  if (!context.mounted || selected == null) return;
  await _handleAlbumMenuSelection(
    selected: selected,
    context: context,
    ref: ref,
    client: client,
    server: server,
    password: password,
    albumId: albumId,
    albumTitle: albumTitle,
    artistName: artistName,
    songs: songs,
    onViewDetails: onViewDetails,
    onViewArtist: onViewArtist,
  );
}

Future<void> _handleAlbumMenuSelection({
  required String selected,
  required BuildContext context,
  required WidgetRef ref,
  required SubsonicClient client,
  required RemoteServer server,
  required String password,
  required String albumId,
  required String albumTitle,
  required String artistName,
  List<MusicFile>? songs,
  VoidCallback? onViewDetails,
  VoidCallback? onViewArtist,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final audio = ref.read(audioServiceProvider);

  Future<List<MusicFile>> getOrFetchSongs() async {
    if (songs != null && songs.isNotEmpty) return songs;
    showToast('Loading album tracks...');
    return await _fetchAlbumTracks(client, server, albumId);
  }

  switch (selected) {
    case 'play':
      final trackList = await getOrFetchSongs();
      if (trackList.isNotEmpty) {
        await audio.playPlaylist(
          trackList,
          source: PlaybackSource(
            type: PlaybackSourceType.album,
            id: 'remote-${server.id}-$albumId',
            name: albumTitle,
          ),
        );
      }
      break;
    case 'shuffle':
      final trackList = await getOrFetchSongs();
      if (trackList.isNotEmpty) {
        await audio.playPlaylist(
          List.of(trackList)..shuffle(),
          source: PlaybackSource(
            type: PlaybackSourceType.album,
            id: 'remote-${server.id}-$albumId',
            name: albumTitle,
          ),
        );
      }
      break;
    case 'play_next':
      final trackList = await getOrFetchSongs();
      if (trackList.isNotEmpty) {
        await audio.enqueueNext(trackList);
        showToast(l10n.addedToQueue);
      }
      break;
    case 'add_to_queue':
      final trackList = await getOrFetchSongs();
      if (trackList.isNotEmpty) {
        await audio.appendToQueue(trackList);
        showToast(l10n.addedToQueue);
      }
      break;
    case 'add_to_server_playlist':
      final trackList = await getOrFetchSongs();
      if (trackList.isNotEmpty && context.mounted) {
        await RemoteAddToPlaylistDialog.show(
          context,
          ref: ref,
          server: server,
          password: password,
          songs: trackList,
        );
      }
      break;
    case 'star':
      final ok = await client.star(albumId: albumId);
      showToast(ok ? l10n.starredSuccess : 'Star failed');
      break;
    case 'download':
      final trackList = await getOrFetchSongs();
      if (trackList.isNotEmpty && context.mounted) {
        final notifier = ref.read(remoteDownloadTasksProvider.notifier);
        await notifier.enqueueSubsonicTracks(
          server: server,
          password: password,
          songs: trackList,
          collectionName: albumTitle,
        );
        if (context.mounted) {
          AppSnackBar.show(
            context,
            ref,
            SnackBar(
              content: Text(l10n.batchAddedToDownloadQueue(trackList.length)),
              action: SnackBarAction(
                label: l10n.viewDownloadProgress,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
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
      break;
    case 'view_details':
      onViewDetails?.call();
      break;
    case 'view_artist':
      onViewArtist?.call();
      break;
    case 'copy_title':
      await Clipboard.setData(ClipboardData(text: albumTitle));
      break;
  }
}

/// Shows context menu for a remote song.
Future<void> showRemoteSongContextMenu({
  required BuildContext context,
  required Offset globalPosition,
  required WidgetRef ref,
  required RemoteServer server,
  required String password,
  required MusicFile song,
  List<MusicFile>? playlist,
  VoidCallback? onViewAlbum,
  VoidCallback? onViewArtist,
  VoidCallback? onRemoveFromPlaylist,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;
  final l10n = AppLocalizations.of(context)!;
  final client = SubsonicClient(server: server, password: password);
  final isMobile = Platform.isAndroid || Platform.isIOS;

  // Extract subsonic trackId
  final trackId = RemoteMediaResolver.extractSubsonicTrackId(song) ??
      (song.id != null && song.id! > 0 ? song.id.toString() : '');

  if (isMobile) {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      song.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${song.artist ?? l10n.unknownArtist} · ${song.album ?? l10n.unknownAlbum}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.queue_play_next_rounded),
                    title: Text(l10n.playNext),
                    onTap: () => Navigator.pop(ctx, 'play_next'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.queue_music_rounded),
                    title: Text(l10n.addToQueue),
                    onTap: () => Navigator.pop(ctx, 'add_to_queue'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.playlist_add_rounded),
                    title: Text(l10n.addToServerPlaylist),
                    onTap: () => Navigator.pop(ctx, 'add_to_server_playlist'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.library_add_outlined),
                    title: Text(l10n.addToLocalPlaylist),
                    onTap: () => Navigator.pop(ctx, 'add_to_local_playlist'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_border_rounded),
                    title: Text(l10n.starItem),
                    onTap: () => Navigator.pop(ctx, 'star'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text(l10n.downloadSong),
                    onTap: () => Navigator.pop(ctx, 'download'),
                  ),
                  if (onRemoveFromPlaylist != null)
                    ListTile(
                      leading: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
                      title: Text(l10n.removeFromPlaylist, style: const TextStyle(color: Colors.redAccent)),
                      onTap: () => Navigator.pop(ctx, 'remove_from_playlist'),
                    ),
                  if (onViewAlbum != null)
                    ListTile(
                      leading: const Icon(Icons.album_rounded),
                      title: Text(l10n.viewAlbum),
                      onTap: () => Navigator.pop(ctx, 'view_album'),
                    ),
                  if (onViewArtist != null)
                    ListTile(
                      leading: const Icon(Icons.person_rounded),
                      title: Text(l10n.viewArtist),
                      onTap: () => Navigator.pop(ctx, 'view_artist'),
                    ),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(l10n.songProperties),
                    onTap: () => Navigator.pop(ctx, 'details'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!context.mounted || selected == null) return;
    await _handleSongMenuSelection(
      selected: selected,
      context: context,
      ref: ref,
      client: client,
      server: server,
      password: password,
      song: song,
      trackId: trackId,
      onViewAlbum: onViewAlbum,
      onViewArtist: onViewArtist,
      onRemoveFromPlaylist: onRemoveFromPlaylist,
    );
    return;
  }

  // Desktop PopupMenu
  final items = <PopupMenuEntry<String>>[
    buildContextMenuItem<String>(
      value: 'play_next',
      label: l10n.playNext,
      icon: Icons.queue_play_next_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'add_to_queue',
      label: l10n.addToQueue,
      icon: Icons.queue_music_rounded,
      context: context,
    ),
    const PopupMenuDivider(),
    buildContextMenuItem<String>(
      value: 'add_to_server_playlist',
      label: l10n.addToServerPlaylist,
      icon: Icons.playlist_add_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'add_to_local_playlist',
      label: l10n.addToLocalPlaylist,
      icon: Icons.library_add_outlined,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'star',
      label: l10n.starItem,
      icon: Icons.favorite_border_rounded,
      context: context,
    ),
    const PopupMenuDivider(),
    buildContextMenuItem<String>(
      value: 'download',
      label: l10n.downloadSong,
      icon: Icons.download_rounded,
      context: context,
    ),
    if (onRemoveFromPlaylist != null) ...[
      const PopupMenuDivider(),
      buildContextMenuItem<String>(
        value: 'remove_from_playlist',
        label: l10n.removeFromPlaylist,
        icon: Icons.remove_circle_outline_rounded,
        context: context,
      ),
    ],
    const PopupMenuDivider(),
    if (onViewAlbum != null)
      buildContextMenuItem<String>(
        value: 'view_album',
        label: l10n.viewAlbum,
        icon: Icons.album_rounded,
        context: context,
      ),
    if (onViewArtist != null)
      buildContextMenuItem<String>(
        value: 'view_artist',
        label: l10n.viewArtist,
        icon: Icons.person_rounded,
        context: context,
      ),
    buildContextMenuItem<String>(
      value: 'details',
      label: l10n.songProperties,
      icon: Icons.info_outline_rounded,
      context: context,
    ),
    const PopupMenuDivider(),
    buildContextMenuItem<String>(
      value: 'copy_title',
      label: l10n.copyTitle,
      icon: Icons.title_rounded,
      context: context,
    ),
    if (song.artist != null && song.artist!.isNotEmpty)
      buildContextMenuItem<String>(
        value: 'copy_artist',
        label: l10n.copyArtistName,
        icon: Icons.person_rounded,
        context: context,
      ),
  ];

  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    ),
    items: items,
  );

  if (!context.mounted || selected == null) return;
  await _handleSongMenuSelection(
    selected: selected,
    context: context,
    ref: ref,
    client: client,
    server: server,
    password: password,
    song: song,
    trackId: trackId,
    onViewAlbum: onViewAlbum,
    onViewArtist: onViewArtist,
    onRemoveFromPlaylist: onRemoveFromPlaylist,
  );
}

Future<void> _handleSongMenuSelection({
  required String selected,
  required BuildContext context,
  required WidgetRef ref,
  required SubsonicClient client,
  required RemoteServer server,
  required String password,
  required MusicFile song,
  required String trackId,
  VoidCallback? onViewAlbum,
  VoidCallback? onViewArtist,
  VoidCallback? onRemoveFromPlaylist,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final audio = ref.read(audioServiceProvider);

  switch (selected) {
    case 'play_next':
      await audio.enqueueNext([song]);
      showToast(l10n.addedToQueue);
      break;
    case 'add_to_queue':
      await audio.appendToQueue([song]);
      showToast(l10n.addedToQueue);
      break;
    case 'add_to_server_playlist':
      if (context.mounted) {
        await RemoteAddToPlaylistDialog.show(
          context,
          ref: ref,
          server: server,
          password: password,
          songs: [song],
        );
      }
      break;
    case 'add_to_local_playlist':
      final playlistService = ref.read(playlistServiceProvider);
      if (context.mounted) {
        await showAddSongsToPlaylistDialog(context, playlistService, [song]);
      }
      break;
    case 'star':
      final ok = await client.star(id: trackId);
      showToast(ok ? l10n.starredSuccess : 'Star failed');
      break;
    case 'download':
      final notifier = ref.read(remoteDownloadTasksProvider.notifier);
      await notifier.enqueueSubsonicTrack(
        server: server,
        password: password,
        song: song,
        trackId: trackId,
      );
      if (context.mounted) {
        AppSnackBar.show(
          context,
          ref,
          SnackBar(
            content: Text(l10n.addedToDownloadQueue),
            action: SnackBarAction(
              label: l10n.viewDownloadProgress,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const RemoteDownloadManagerPage(),
                  ),
                );
              },
            ),
          ),
        );
      }
      break;
    case 'remove_from_playlist':
      onRemoveFromPlaylist?.call();
      break;
    case 'view_album':
      onViewAlbum?.call();
      break;
    case 'view_artist':
      onViewArtist?.call();
      break;
    case 'details':
      if (context.mounted) {
        await showSongDetailsDialog(context, song);
      }
      break;
    case 'copy_title':
      await Clipboard.setData(ClipboardData(text: song.displayName));
      break;
    case 'copy_artist':
      if (song.artist != null) {
        await Clipboard.setData(ClipboardData(text: song.artist!));
      }
      break;
  }
}

/// Shows context menu for a remote Navidrome artist.
Future<void> showRemoteArtistContextMenu({
  required BuildContext context,
  required Offset globalPosition,
  required WidgetRef ref,
  required RemoteServer server,
  required String password,
  required String artistId,
  required String artistName,
  VoidCallback? onViewDetails,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;
  final l10n = AppLocalizations.of(context)!;
  final client = SubsonicClient(server: server, password: password);
  final isMobile = Platform.isAndroid || Platform.isIOS;

  if (isMobile) {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.play_arrow_rounded),
                    title: Text(l10n.playAll),
                    onTap: () => Navigator.pop(ctx, 'play_all'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shuffle_rounded),
                    title: Text(l10n.shufflePlay),
                    onTap: () => Navigator.pop(ctx, 'shuffle'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.queue_play_next_rounded),
                    title: Text(l10n.playNext),
                    onTap: () => Navigator.pop(ctx, 'play_next'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.queue_music_rounded),
                    title: Text(l10n.addToQueue),
                    onTap: () => Navigator.pop(ctx, 'add_to_queue'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_border_rounded),
                    title: Text(l10n.starItem),
                    onTap: () => Navigator.pop(ctx, 'star'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text(l10n.downloadArtist),
                    onTap: () => Navigator.pop(ctx, 'download'),
                  ),
                  if (onViewDetails != null)
                    ListTile(
                      leading: const Icon(Icons.person_rounded),
                      title: Text(l10n.viewArtistDetails),
                      onTap: () => Navigator.pop(ctx, 'view_details'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!context.mounted || selected == null) return;
    await _handleArtistMenuSelection(
      selected: selected,
      context: context,
      ref: ref,
      client: client,
      server: server,
      password: password,
      artistId: artistId,
      artistName: artistName,
      onViewDetails: onViewDetails,
    );
    return;
  }

  // Desktop PopupMenu
  final items = <PopupMenuEntry<String>>[
    buildContextMenuItem<String>(
      value: 'play_all',
      label: l10n.playAll,
      icon: Icons.play_arrow_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'shuffle',
      label: l10n.shufflePlay,
      icon: Icons.shuffle_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'play_next',
      label: l10n.playNext,
      icon: Icons.queue_play_next_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'add_to_queue',
      label: l10n.addToQueue,
      icon: Icons.queue_music_rounded,
      context: context,
    ),
    const PopupMenuDivider(),
    buildContextMenuItem<String>(
      value: 'star',
      label: l10n.starItem,
      icon: Icons.favorite_border_rounded,
      context: context,
    ),
    const PopupMenuDivider(),
    buildContextMenuItem<String>(
      value: 'download',
      label: l10n.downloadArtist,
      icon: Icons.download_rounded,
      context: context,
    ),
    const PopupMenuDivider(),
    if (onViewDetails != null)
      buildContextMenuItem<String>(
        value: 'view_details',
        label: l10n.viewArtistDetails,
        icon: Icons.person_rounded,
        context: context,
      ),
    buildContextMenuItem<String>(
      value: 'copy_name',
      label: l10n.copyArtistName,
      icon: Icons.copy_rounded,
      context: context,
    ),
  ];

  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    ),
    items: items,
  );

  if (!context.mounted || selected == null) return;
  await _handleArtistMenuSelection(
    selected: selected,
    context: context,
    ref: ref,
    client: client,
    server: server,
    password: password,
    artistId: artistId,
    artistName: artistName,
    onViewDetails: onViewDetails,
  );
}

Future<void> _handleArtistMenuSelection({
  required String selected,
  required BuildContext context,
  required WidgetRef ref,
  required SubsonicClient client,
  required RemoteServer server,
  required String password,
  required String artistId,
  required String artistName,
  VoidCallback? onViewDetails,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final audio = ref.read(audioServiceProvider);

  Future<List<MusicFile>> getArtistSongs() async {
    showToast('Loading artist tracks...');
    return await _fetchArtistTracks(client, server, artistId);
  }

  switch (selected) {
    case 'play_all':
      final trackList = await getArtistSongs();
      if (trackList.isNotEmpty) {
        await audio.playPlaylist(
          trackList,
          source: PlaybackSource(
            type: PlaybackSourceType.artist,
            id: 'remote-${server.id}-$artistId',
            name: artistName,
          ),
        );
      }
      break;
    case 'shuffle':
      final trackList = await getArtistSongs();
      if (trackList.isNotEmpty) {
        await audio.playPlaylist(
          List.of(trackList)..shuffle(),
          source: PlaybackSource(
            type: PlaybackSourceType.artist,
            id: 'remote-${server.id}-$artistId',
            name: artistName,
          ),
        );
      }
      break;
    case 'play_next':
      final trackList = await getArtistSongs();
      if (trackList.isNotEmpty) {
        await audio.enqueueNext(trackList);
        showToast(l10n.addedToQueue);
      }
      break;
    case 'add_to_queue':
      final trackList = await getArtistSongs();
      if (trackList.isNotEmpty) {
        await audio.appendToQueue(trackList);
        showToast(l10n.addedToQueue);
      }
      break;
    case 'star':
      final ok = await client.star(artistId: artistId);
      showToast(ok ? l10n.starredSuccess : 'Star failed');
      break;
    case 'download':
      final trackList = await getArtistSongs();
      if (trackList.isNotEmpty && context.mounted) {
        final notifier = ref.read(remoteDownloadTasksProvider.notifier);
        await notifier.enqueueSubsonicTracks(
          server: server,
          password: password,
          songs: trackList,
          collectionName: artistName,
        );
        if (context.mounted) {
          AppSnackBar.show(
            context,
            ref,
            SnackBar(
              content: Text(l10n.batchAddedToDownloadQueue(trackList.length)),
              action: SnackBarAction(
                label: l10n.viewDownloadProgress,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
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
      break;
    case 'view_details':
      onViewDetails?.call();
      break;
    case 'copy_name':
      await Clipboard.setData(ClipboardData(text: artistName));
      break;
  }
}

/// Helper to fetch tracks of a playlist on-demand if not already supplied
Future<List<MusicFile>> _fetchPlaylistTracks(
  SubsonicClient client,
  RemoteServer server,
  String playlistId,
) async {
  try {
    final playlist = await client.getPlaylist(playlistId);
    final songList = playlist?['entry'] as List?;
    if (songList != null && songList.isNotEmpty) {
      final List<MusicFile> parsed = [];
      for (final item in songList) {
        if (item is Map<String, dynamic>) {
          parsed.add(
            RemoteMediaResolver.buildMusicFileFromSubsonic(item, server),
          );
        }
      }
      return parsed;
    }
  } catch (_) {}
  return [];
}

/// Shows context menu for a remote Navidrome playlist.
Future<void> showRemotePlaylistContextMenu({
  required BuildContext context,
  required Offset globalPosition,
  required WidgetRef ref,
  required RemoteServer server,
  required String password,
  required String playlistId,
  required String playlistName,
  List<MusicFile>? songs,
  VoidCallback? onViewDetails,
  VoidCallback? onRename,
  VoidCallback? onDelete,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;
  final l10n = AppLocalizations.of(context)!;
  final client = SubsonicClient(server: server, password: password);
  final isMobile = Platform.isAndroid || Platform.isIOS;

  if (isMobile) {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.playlist_play_rounded, size: 28),
                    title: Text(
                      playlistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      songs != null
                          ? l10n.songCount(songs.length)
                          : l10n.playlist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.play_arrow_rounded),
                    title: Text(l10n.playAll),
                    onTap: () => Navigator.pop(ctx, 'play_all'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.queue_play_next_rounded),
                    title: Text(l10n.playNext),
                    onTap: () => Navigator.pop(ctx, 'play_next'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.queue_music_rounded),
                    title: Text(l10n.addToQueue),
                    onTap: () => Navigator.pop(ctx, 'add_to_queue'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text(l10n.downloadAlbum),
                    onTap: () => Navigator.pop(ctx, 'download'),
                  ),
                  if (onRename != null)
                    ListTile(
                      leading: const Icon(Icons.edit_rounded),
                      title: Text(l10n.renamePlaylist),
                      onTap: () => Navigator.pop(ctx, 'rename'),
                    ),
                  if (onDelete != null)
                    ListTile(
                      leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      title: Text(l10n.deletePlaylist, style: const TextStyle(color: Colors.redAccent)),
                      onTap: () => Navigator.pop(ctx, 'delete'),
                    ),
                  if (onViewDetails != null)
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(l10n.viewAlbumDetails),
                      onTap: () => Navigator.pop(ctx, 'view_details'),
                    ),
                  ListTile(
                    leading: const Icon(Icons.copy_rounded),
                    title: Text(l10n.copyTitle),
                    onTap: () => Navigator.pop(ctx, 'copy_name'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!context.mounted || selected == null) return;
    await _handlePlaylistMenuSelection(
      selected: selected,
      context: context,
      ref: ref,
      client: client,
      server: server,
      password: password,
      playlistId: playlistId,
      playlistName: playlistName,
      songs: songs,
      onViewDetails: onViewDetails,
      onRename: onRename,
      onDelete: onDelete,
    );
    return;
  }

  // Desktop PopupMenu
  final items = <PopupMenuEntry<String>>[
    buildContextMenuItem<String>(
      value: 'play_all',
      label: l10n.playAll,
      icon: Icons.play_arrow_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'play_next',
      label: l10n.playNext,
      icon: Icons.queue_play_next_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'add_to_queue',
      label: l10n.addToQueue,
      icon: Icons.queue_music_rounded,
      context: context,
    ),
    const PopupMenuDivider(),
    buildContextMenuItem<String>(
      value: 'download',
      label: l10n.downloadAlbum,
      icon: Icons.download_rounded,
      context: context,
    ),
    if (onRename != null) ...[
      const PopupMenuDivider(),
      buildContextMenuItem<String>(
        value: 'rename',
        label: l10n.renamePlaylist,
        icon: Icons.edit_rounded,
        context: context,
      ),
    ],
    if (onDelete != null)
      buildContextMenuItem<String>(
        value: 'delete',
        label: l10n.deletePlaylist,
        icon: Icons.delete_outline_rounded,
        context: context,
      ),
    const PopupMenuDivider(),
    if (onViewDetails != null)
      buildContextMenuItem<String>(
        value: 'view_details',
        label: l10n.viewAlbumDetails,
        icon: Icons.info_outline_rounded,
        context: context,
      ),
    buildContextMenuItem<String>(
      value: 'copy_name',
      label: l10n.copyTitle,
      icon: Icons.title_rounded,
      context: context,
    ),
  ];

  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    ),
    items: items,
  );

  if (!context.mounted || selected == null) return;
  await _handlePlaylistMenuSelection(
    selected: selected,
    context: context,
    ref: ref,
    client: client,
    server: server,
    password: password,
    playlistId: playlistId,
    playlistName: playlistName,
    songs: songs,
    onViewDetails: onViewDetails,
    onRename: onRename,
    onDelete: onDelete,
  );
}

Future<void> _handlePlaylistMenuSelection({
  required String selected,
  required BuildContext context,
  required WidgetRef ref,
  required SubsonicClient client,
  required RemoteServer server,
  required String password,
  required String playlistId,
  required String playlistName,
  List<MusicFile>? songs,
  VoidCallback? onViewDetails,
  VoidCallback? onRename,
  VoidCallback? onDelete,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final audio = ref.read(audioServiceProvider);

  Future<List<MusicFile>> getPlaylistSongs() async {
    if (songs != null && songs.isNotEmpty) return songs;
    return await _fetchPlaylistTracks(client, server, playlistId);
  }

  switch (selected) {
    case 'play_all':
      final trackList = await getPlaylistSongs();
      if (trackList.isNotEmpty) {
        await audio.playPlaylist(
          trackList,
          source: PlaybackSource(
            type: PlaybackSourceType.playlist,
            id: 'remote-${server.id}-$playlistId',
            name: playlistName,
          ),
        );
      }
      break;
    case 'play_next':
      final trackList = await getPlaylistSongs();
      if (trackList.isNotEmpty) {
        await audio.enqueueNext(trackList);
        showToast(l10n.addedToQueue);
      }
      break;
    case 'add_to_queue':
      final trackList = await getPlaylistSongs();
      if (trackList.isNotEmpty) {
        await audio.appendToQueue(trackList);
        showToast(l10n.addedToQueue);
      }
      break;
    case 'download':
      final trackList = await getPlaylistSongs();
      if (trackList.isNotEmpty && context.mounted) {
        final notifier = ref.read(remoteDownloadTasksProvider.notifier);
        await notifier.enqueueSubsonicTracks(
          server: server,
          password: password,
          songs: trackList,
          collectionName: playlistName,
        );
        if (context.mounted) {
          AppSnackBar.show(
            context,
            ref,
            SnackBar(
              content: Text(l10n.batchAddedToDownloadQueue(trackList.length)),
              action: SnackBarAction(
                label: l10n.viewDownloadProgress,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
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
      break;
    case 'rename':
      onRename?.call();
      break;
    case 'delete':
      onDelete?.call();
      break;
    case 'view_details':
      onViewDetails?.call();
      break;
    case 'copy_name':
      await Clipboard.setData(ClipboardData(text: playlistName));
      break;
  }
}

String _formatWebDavFileSize(int bytes) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB'];
  var i = 0;
  double size = bytes.toDouble();
  while (size >= 1024 && i < suffixes.length - 1) {
    size /= 1024;
    i++;
  }
  return '${size.toStringAsFixed(1)} ${suffixes[i]}';
}

/// Helper to fetch tracks of a WebDAV folder on-demand
Future<List<MusicFile>> _fetchWebDavFolderAudioFiles(
  WebDavClient client,
  RemoteServer server,
  String folderPath,
) async {
  try {
    final list = await client.listFiles(folderPath);
    return list
        .where((item) => item.isAudio)
        .map((item) => RemoteMediaResolver.buildMusicFileFromWebDav(item, server))
        .toList();
  } catch (_) {
    return [];
  }
}

/// Shows context menu for a remote WebDAV file (audio or generic file).
Future<void> showWebDavFileContextMenu({
  required BuildContext context,
  required Offset globalPosition,
  required WidgetRef ref,
  required RemoteServer server,
  required String password,
  required WebDavFile file,
  List<MusicFile>? currentAudioFiles,
  VoidCallback? onPlay,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;
  final l10n = AppLocalizations.of(context)!;
  final isMobile = Platform.isAndroid || Platform.isIOS;
  final isAudio = file.isAudio;
  final virtualUri = RemoteMediaResolver.buildWebDavUri(server.id, file.path);
  final meta = ref.read(scannerServiceProvider).metadataMap[virtualUri];
  final song = isAudio ? RemoteMediaResolver.buildMusicFileFromWebDav(file, server, metadata: meta) : null;

  if (isMobile) {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      isAudio ? Icons.music_note_rounded : Icons.insert_drive_file_outlined,
                      color: isAudio ? Theme.of(ctx).colorScheme.primary : null,
                      size: 28,
                    ),
                    title: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _formatWebDavFileSize(file.contentLength),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(height: 1),
                  if (isAudio) ...[
                    ListTile(
                      leading: const Icon(Icons.play_arrow_rounded),
                      title: Text(l10n.play),
                      onTap: () => Navigator.pop(ctx, 'play'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.queue_play_next_rounded),
                      title: Text(l10n.playNext),
                      onTap: () => Navigator.pop(ctx, 'play_next'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.queue_music_rounded),
                      title: Text(l10n.addToQueue),
                      onTap: () => Navigator.pop(ctx, 'add_to_queue'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.library_add_outlined),
                      title: Text(l10n.addToLocalPlaylist),
                      onTap: () => Navigator.pop(ctx, 'add_to_local_playlist'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_rounded),
                      title: Text(l10n.downloadSong),
                      onTap: () => Navigator.pop(ctx, 'download'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(l10n.songProperties),
                      onTap: () => Navigator.pop(ctx, 'details'),
                    ),
                  ],
                  ListTile(
                    leading: const Icon(Icons.title_rounded),
                    title: Text(l10n.copyTitle),
                    onTap: () => Navigator.pop(ctx, 'copy_title'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.link_rounded),
                    title: Text(l10n.copyAlbumTitle.contains('复制') ? '复制文件路径' : 'Copy File Path'),
                    onTap: () => Navigator.pop(ctx, 'copy_path'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!context.mounted || selected == null) return;
    await _handleWebDavFileMenuSelection(
      selected: selected,
      context: context,
      ref: ref,
      server: server,
      password: password,
      file: file,
      song: song,
      currentAudioFiles: currentAudioFiles,
      onPlay: onPlay,
    );
    return;
  }

  // Desktop PopupMenu
  final items = <PopupMenuEntry<String>>[
    if (isAudio) ...[
      buildContextMenuItem<String>(
        value: 'play',
        label: l10n.play,
        icon: Icons.play_arrow_rounded,
        context: context,
      ),
      buildContextMenuItem<String>(
        value: 'play_next',
        label: l10n.playNext,
        icon: Icons.queue_play_next_rounded,
        context: context,
      ),
      buildContextMenuItem<String>(
        value: 'add_to_queue',
        label: l10n.addToQueue,
        icon: Icons.queue_music_rounded,
        context: context,
      ),
      const PopupMenuDivider(),
      buildContextMenuItem<String>(
        value: 'add_to_local_playlist',
        label: l10n.addToLocalPlaylist,
        icon: Icons.library_add_outlined,
        context: context,
      ),
      buildContextMenuItem<String>(
        value: 'download',
        label: l10n.downloadSong,
        icon: Icons.download_rounded,
        context: context,
      ),
      const PopupMenuDivider(),
      buildContextMenuItem<String>(
        value: 'details',
        label: l10n.songProperties,
        icon: Icons.info_outline_rounded,
        context: context,
      ),
      const PopupMenuDivider(),
    ],
    buildContextMenuItem<String>(
      value: 'copy_title',
      label: l10n.copyTitle,
      icon: Icons.title_rounded,
      context: context,
    ),
    buildContextMenuItem<String>(
      value: 'copy_path',
      label: l10n.copyAlbumTitle.contains('复制') ? '复制文件路径' : 'Copy File Path',
      icon: Icons.link_rounded,
      context: context,
    ),
  ];

  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    ),
    items: items,
  );

  if (!context.mounted || selected == null) return;
  await _handleWebDavFileMenuSelection(
    selected: selected,
    context: context,
    ref: ref,
    server: server,
    password: password,
    file: file,
    song: song,
    currentAudioFiles: currentAudioFiles,
    onPlay: onPlay,
  );
}

Future<void> _handleWebDavFileMenuSelection({
  required String selected,
  required BuildContext context,
  required WidgetRef ref,
  required RemoteServer server,
  required String password,
  required WebDavFile file,
  required MusicFile? song,
  List<MusicFile>? currentAudioFiles,
  VoidCallback? onPlay,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final audio = ref.read(audioServiceProvider);

  switch (selected) {
    case 'play':
      if (onPlay != null) {
        onPlay();
      } else if (song != null) {
        final list = currentAudioFiles ?? [song];
        final initialIndex = list.indexWhere((s) => s.path == song.path);
        await audio.playPlaylist(
          list,
          initialIndex: initialIndex >= 0 ? initialIndex : 0,
        );
      }
      break;
    case 'play_next':
      if (song != null) {
        await audio.enqueueNext([song]);
        showToast(l10n.addedToQueue);
      }
      break;
    case 'add_to_queue':
      if (song != null) {
        await audio.appendToQueue([song]);
        showToast(l10n.addedToQueue);
      }
      break;
    case 'add_to_local_playlist':
      if (song != null && context.mounted) {
        final playlistService = ref.read(playlistServiceProvider);
        await showAddSongsToPlaylistDialog(context, playlistService, [song]);
      }
      break;
    case 'download':
      final notifier = ref.read(remoteDownloadTasksProvider.notifier);
      await notifier.enqueueWebDavFile(
        server: server,
        password: password,
        file: file,
      );
      if (context.mounted) {
        AppSnackBar.show(
          context,
          ref,
          SnackBar(
            content: Text(l10n.addedToDownloadQueue),
            action: SnackBarAction(
              label: l10n.viewDownloadProgress,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const RemoteDownloadManagerPage(),
                  ),
                );
              },
            ),
          ),
        );
      }
      break;
    case 'details':
      if (song != null && context.mounted) {
        await showSongDetailsDialog(context, song);
      }
      break;
    case 'copy_title':
      await Clipboard.setData(ClipboardData(text: file.name));
      break;
    case 'copy_path':
      await Clipboard.setData(ClipboardData(text: file.path));
      break;
  }
}

/// Shows context menu for a remote WebDAV folder.
/// Shows bottom sheet for a remote WebDAV folder, aligned with showFolderBottomSheet design.
Future<String?> showWebDavFolderBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required RemoteServer server,
  required String password,
  required WebDavFile folder,
  VoidCallback? onOpen,
  void Function(String folderPath)? onMultiSelect,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final client = WebDavClient(server: server, password: password);
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
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(ctx),
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
                                  child: const Icon(
                                    Icons.folder_rounded,
                                    size: 30,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      folder.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      folder.path,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          _buildWebDavBottomSheetItem(
                            context: context,
                            value: 'play_all',
                            label: l10n.playAll,
                            icon: Icons.play_arrow_rounded,
                            iconColor: theme.colorScheme.primary,
                          ),
                          _buildWebDavBottomSheetItem(
                            context: context,
                            value: 'shuffle',
                            label: l10n.shufflePlay,
                            icon: Icons.shuffle_rounded,
                          ),
                          _buildWebDavBottomSheetItem(
                            context: context,
                            value: 'play_next',
                            label: l10n.playNext,
                            icon: Icons.queue_play_next_rounded,
                          ),
                          _buildWebDavBottomSheetItem(
                            context: context,
                            value: 'add_to_queue',
                            label: l10n.addToQueue,
                            icon: Icons.queue_music_rounded,
                          ),
                          _buildWebDavBottomSheetItem(
                            context: context,
                            value: 'add_to_playlist',
                            label: l10n.playlist,
                            icon: Icons.playlist_add_rounded,
                          ),
                          _buildWebDavBottomSheetItem(
                            context: context,
                            value: 'download_folder',
                            label: l10n.copyAlbumTitle.contains('复制')
                                ? '下载文件夹全部音频'
                                : 'Download All Audio in Folder',
                            icon: Icons.download_rounded,
                          ),
                          if (onOpen != null)
                            _buildWebDavBottomSheetItem(
                              context: context,
                              value: 'open',
                              label: l10n.openFolderLocation.contains('打开')
                                  ? '打开文件夹'
                                  : 'Open Folder',
                              icon: Icons.folder_open_rounded,
                            ),
                          _buildWebDavBottomSheetItem(
                            context: context,
                            value: 'multi_select',
                            label: l10n.selectFolders,
                            icon: Icons.checklist_rounded,
                          ),
                          const Divider(height: 1),
                          _buildWebDavBottomSheetItem(
                            context: context,
                            value: 'copy_name',
                            label: l10n.copyAlbumTitle.contains('复制')
                                ? '复制文件夹名称'
                                : 'Copy Folder Name',
                            icon: Icons.copy_rounded,
                          ),
                          _buildWebDavBottomSheetItem(
                            context: context,
                            value: 'copy_path',
                            label: l10n.copyAlbumTitle.contains('复制')
                                ? '复制文件夹路径'
                                : 'Copy Folder Path',
                            icon: Icons.link_rounded,
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
  } finally {
    if (ref.read(librarySelectionScopeProvider) ==
        LibrarySelectionScope.bottomSheet) {
      ref
          .read(librarySelectionScopeProvider.notifier)
          .setScope(previousScope);
    }
  }

  if (!context.mounted || selected == null) return null;

  if (selected == 'multi_select') {
    onMultiSelect?.call(folder.path);
    return selected;
  }

  await _handleWebDavFolderMenuSelection(
    selected: selected,
    context: context,
    ref: ref,
    client: client,
    server: server,
    password: password,
    folder: folder,
    onOpen: onOpen,
  );

  return selected;
}

Widget _buildWebDavBottomSheetItem({
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

/// Shows context menu / bottom sheet for a remote WebDAV folder.
Future<void> showWebDavFolderContextMenu({
  required BuildContext context,
  required Offset globalPosition,
  required WidgetRef ref,
  required RemoteServer server,
  required String password,
  required WebDavFile folder,
  VoidCallback? onOpen,
  void Function(String folderPath)? onMultiSelect,
}) async {
  await showWebDavFolderBottomSheet(
    context: context,
    ref: ref,
    server: server,
    password: password,
    folder: folder,
    onOpen: onOpen,
    onMultiSelect: onMultiSelect,
  );
}

Future<void> _handleWebDavFolderMenuSelection({
  required String selected,
  required BuildContext context,
  required WidgetRef ref,
  required WebDavClient client,
  required RemoteServer server,
  required String password,
  required WebDavFile folder,
  VoidCallback? onOpen,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final audio = ref.read(audioServiceProvider);

  Future<List<MusicFile>> getAudioFiles() async {
    showToast('Loading folder audio...');
    return await _fetchWebDavFolderAudioFiles(client, server, folder.path);
  }

  switch (selected) {
    case 'play_all':
      final trackList = await getAudioFiles();
      if (trackList.isNotEmpty) {
        await audio.playPlaylist(
          trackList,
          source: PlaybackSource(
            type: PlaybackSourceType.folder,
            id: 'webdav-${server.id}-${folder.path}',
            name: folder.name,
          ),
        );
      } else {
        showToast('No audio files in this folder');
      }
      break;
    case 'shuffle':
      final trackList = await getAudioFiles();
      if (trackList.isNotEmpty) {
        await audio.playPlaylist(
          List.of(trackList)..shuffle(),
          source: PlaybackSource(
            type: PlaybackSourceType.folder,
            id: 'webdav-${server.id}-${folder.path}',
            name: folder.name,
          ),
        );
      } else {
        showToast('No audio files in this folder');
      }
      break;
    case 'play_next':
      final trackList = await getAudioFiles();
      if (trackList.isNotEmpty) {
        await audio.enqueueNext(trackList);
        showToast(l10n.addedToQueue);
      } else {
        showToast('No audio files in this folder');
      }
      break;
    case 'add_to_queue':
      final trackList = await getAudioFiles();
      if (trackList.isNotEmpty) {
        await audio.appendToQueue(trackList);
        showToast(l10n.addedToQueue);
      } else {
        showToast('No audio files in this folder');
      }
      break;
    case 'add_to_playlist':
      final trackList = await getAudioFiles();
      if (trackList.isNotEmpty && context.mounted) {
        final playlistService = ref.read(playlistServiceProvider);
        await showAddSongsToPlaylistDialog(context, playlistService, trackList);
      } else if (context.mounted) {
        showToast('No audio files in this folder');
      }
      break;
    case 'download_folder':
      try {
        final list = await client.listFiles(folder.path);
        final audioItems = list.where((i) => !i.isDirectory && i.isAudio).toList();
        if (audioItems.isEmpty) {
          showToast(l10n.noActiveDownloads);
          return;
        }
        if (context.mounted) {
          final notifier = ref.read(remoteDownloadTasksProvider.notifier);
          await notifier.enqueueWebDavFiles(
            server: server,
            password: password,
            files: audioItems,
          );
          if (context.mounted) {
            AppSnackBar.show(
              context,
              ref,
              SnackBar(
                content: Text(l10n.batchAddedToDownloadQueue(audioItems.length)),
                action: SnackBarAction(
                  label: l10n.viewDownloadProgress,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
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
      } catch (e) {
        showToast('Failed to load folder: $e');
      }
      break;
    case 'open':
      onOpen?.call();
      break;
    case 'copy_name':
      await Clipboard.setData(ClipboardData(text: folder.name));
      break;
    case 'copy_path':
      await Clipboard.setData(ClipboardData(text: folder.path));
      break;
  }
}

