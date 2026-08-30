import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'remote_server_models.dart';
import 'remote_server_riverpod.dart';
import '../../pages/remote/navidrome_album_detail_page.dart';
import '../../pages/remote/navidrome_artist_detail_page.dart';
import '../../pages/remote/navidrome_playlist_detail_page.dart';

class NavidromeNavUtils {
  static void openAlbum(
    BuildContext context,
    WidgetRef ref, {
    required RemoteServer server,
    required String password,
    required String albumId,
    required String albumName,
    String? artistName,
    String? coverArtId,
  }) {
    final session = ref.read(activeRemoteSessionProvider);
    if (session != null && session.server.id == server.id) {
      ref.read(activeRemoteSessionProvider.notifier).pushNavidromeDetail(
            NavidromeAlbumRoute(
              albumId: albumId,
              albumName: albumName,
              artistName: artistName,
              coverArtId: coverArtId,
            ),
          );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NavidromeAlbumDetailPage(
            server: server,
            password: password,
            albumId: albumId,
            albumName: albumName,
            artistName: artistName,
            coverArtId: coverArtId,
          ),
        ),
      );
    }
  }

  static void openArtist(
    BuildContext context,
    WidgetRef ref, {
    required RemoteServer server,
    required String password,
    required String artistId,
    required String artistName,
    String? coverArtId,
    int? albumCount,
  }) {
    final session = ref.read(activeRemoteSessionProvider);
    if (session != null && session.server.id == server.id) {
      ref.read(activeRemoteSessionProvider.notifier).pushNavidromeDetail(
            NavidromeArtistRoute(
              artistId: artistId,
              artistName: artistName,
              coverArtId: coverArtId,
              albumCount: albumCount,
            ),
          );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NavidromeArtistDetailPage(
            server: server,
            password: password,
            artistId: artistId,
            artistName: artistName,
            coverArtId: coverArtId,
            albumCount: albumCount,
          ),
        ),
      );
    }
  }

  static void openPlaylist(
    BuildContext context,
    WidgetRef ref, {
    required RemoteServer server,
    required String password,
    required String playlistId,
    required String playlistName,
    String? coverArtId,
    int? songCount,
    int? duration,
    bool isStarred = false,
    VoidCallback? onPlaylistModified,
  }) {
    final session = ref.read(activeRemoteSessionProvider);
    if (session != null && session.server.id == server.id) {
      ref.read(activeRemoteSessionProvider.notifier).pushNavidromeDetail(
            NavidromePlaylistRoute(
              playlistId: playlistId,
              playlistName: playlistName,
              coverArtId: coverArtId,
              songCount: songCount,
              duration: duration,
              isStarred: isStarred,
            ),
          );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NavidromePlaylistDetailPage(
            server: server,
            password: password,
            playlistId: playlistId,
            playlistName: playlistName,
            coverArtId: coverArtId,
            songCount: songCount,
            duration: duration,
            isStarred: isStarred,
            onPlaylistModified: onPlaylistModified,
          ),
        ),
      );
    }
  }
}
