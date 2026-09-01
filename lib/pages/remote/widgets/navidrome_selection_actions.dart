import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/music_file.dart';
import '../../../player/audio/audio_riverpod.dart';
import '../../../player/audio/playback_source.dart';
import '../../../player/remote/clients/subsonic_client.dart';
import '../../../player/remote/proxy/remote_media_resolver.dart';
import '../../../player/remote/remote_server_models.dart';
import '../../../player/remote/services/remote_download_service.dart';
import '../../../utils/app_snack_bar.dart';
import '../../../utils/remote_context_menu_utils.dart';
import '../../../utils/song_context_menu_utils.dart';
import '../remote_download_manager_page.dart';

class NavidromeSelectionActions {
  static const String starredPlaylistId = '__navidrome_starred_songs__';

  static Future<List<MusicFile>> fetchSelectedSongs({
    required RemoteServer server,
    required String password,
    required bool isAlbumSelectionMode,
    required bool isArtistSelectionMode,
    required bool isPlaylistSelectionMode,
    required bool isSongSelectionMode,
    required Set<String> selectedAlbumIds,
    required Set<String> selectedArtistIds,
    required Set<String> selectedPlaylistIds,
    required Set<String> selectedSongPaths,
    required List<MusicFile> searchedSongs,
  }) async {
    final client = SubsonicClient(
      server: server,
      password: password,
    );
    final List<MusicFile> allSongs = [];
    if (isAlbumSelectionMode) {
      for (final albumId in selectedAlbumIds) {
        final tracks =
            await fetchSubsonicAlbumTracks(client, server, albumId);
        allSongs.addAll(tracks);
      }
    } else if (isArtistSelectionMode) {
      for (final artistId in selectedArtistIds) {
        final tracks =
            await fetchSubsonicArtistTracks(client, server, artistId);
        allSongs.addAll(tracks);
      }
    } else if (isPlaylistSelectionMode) {
      for (final playlistId in selectedPlaylistIds) {
        final tracks =
            await fetchSubsonicPlaylistTracks(client, server, playlistId);
        allSongs.addAll(tracks);
      }
    } else if (isSongSelectionMode) {
      for (final song in searchedSongs) {
        if (selectedSongPaths.contains(song.path)) {
          allSongs.add(song);
        }
      }
    }
    return allSongs;
  }

  static Future<void> playAlbumDirectly({
    required BuildContext context,
    required WidgetRef ref,
    required RemoteServer server,
    required String password,
    required String albumId,
    required String albumTitle,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final client = SubsonicClient(
      server: server,
      password: password,
    );
    try {
      showToast(l10n.loadingAlbumTracks);
      final album = await client.getAlbum(albumId);
      final songList = album?['song'] as List?;
      if (songList != null && songList.isNotEmpty) {
        final List<MusicFile> parsed = [];
        for (final item in songList) {
          if (item is Map<String, dynamic>) {
            parsed.add(
              RemoteMediaResolver.buildMusicFileFromSubsonic(
                item,
                server,
              ),
            );
          }
        }
        if (parsed.isNotEmpty) {
          final audio = ref.read(audioServiceProvider);
          await audio.playPlaylist(
            parsed,
            source: PlaybackSource(
              type: PlaybackSourceType.album,
              id: 'remote-${server.id}-$albumId',
              name: albumTitle,
            ),
          );
        }
      }
    } catch (e) {
      showToast(l10n.playAlbumFailed(e.toString()));
    }
  }

  static Future<void> handleBatchPlayNext({
    required WidgetRef ref,
    required Future<List<MusicFile>> Function() onFetchSongs,
    required VoidCallback onClearSelection,
  }) async {
    final songs = await onFetchSongs();
    if (songs.isEmpty) return;
    final audio = ref.read(audioServiceProvider);
    await audio.enqueueNext(songs);
    onClearSelection();
  }

  static Future<void> handleBatchAddToQueue({
    required WidgetRef ref,
    required Future<List<MusicFile>> Function() onFetchSongs,
    required VoidCallback onClearSelection,
  }) async {
    final songs = await onFetchSongs();
    if (songs.isEmpty) return;
    final audio = ref.read(audioServiceProvider);
    await audio.appendToQueue(songs);
    onClearSelection();
  }

  static Future<void> handleBatchAddToPlaylist({
    required BuildContext context,
    required WidgetRef ref,
    required Future<List<MusicFile>> Function() onFetchSongs,
    required VoidCallback onClearSelection,
  }) async {
    final songs = await onFetchSongs();
    if (songs.isEmpty) return;
    if (!context.mounted) return;
    final playlistService = ref.read(playlistServiceProvider);
    await showAddSongsToPlaylistDialog(context, playlistService, songs);
    onClearSelection();
  }

  static Future<void> handleBatchDownload({
    required BuildContext context,
    required WidgetRef ref,
    required RemoteServer server,
    required String password,
    required Future<List<MusicFile>> Function() onFetchSongs,
    required VoidCallback onClearSelection,
  }) async {
    final songs = await onFetchSongs();
    if (songs.isEmpty) return;
    final notifier = ref.read(remoteDownloadTasksProvider.notifier);
    await notifier.enqueueSubsonicTracks(
      server: server,
      password: password,
      songs: songs,
      collectionName: server.name,
    );
    onClearSelection();
    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppSnackBar.show(
        context,
        ref,
        SnackBar(
          content: Text(l10n.batchAddedToDownloadQueue(songs.length)),
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

  static Future<void> handleBatchDeletePlaylists({
    required RemoteServer server,
    required String password,
    required Set<String> selectedPlaylistIds,
    required VoidCallback onClearSelection,
    required VoidCallback onReloadPlaylists,
  }) async {
    final toDelete = selectedPlaylistIds
        .where((id) => id != starredPlaylistId && id != 'starred_songs')
        .toList();
    if (toDelete.isEmpty) return;
    final client = SubsonicClient(
      server: server,
      password: password,
    );
    for (final plId in toDelete) {
      await client.deletePlaylist(plId);
    }
    onClearSelection();
    onReloadPlaylists();
  }
}
