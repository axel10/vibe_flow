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
import '../player/remote/proxy/remote_media_resolver.dart';
import '../player/remote/remote_server_models.dart';
import '../pages/remote/remote_download_manager_page.dart';
import '../player/remote/services/remote_download_service.dart';
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
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;
  final l10n = AppLocalizations.of(context)!;
  final client = SubsonicClient(server: server, password: password);
  final isMobile = Platform.isAndroid || Platform.isIOS;

  // Extract subsonic trackId
  String trackId = song.id.toString();
  if (song.path.contains('/track_')) {
    trackId = song.path.split('/track_').last;
  }

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
      break;
    case 'view_details':
      onViewDetails?.call();
      break;
    case 'copy_name':
      await Clipboard.setData(ClipboardData(text: artistName));
      break;
  }
}
