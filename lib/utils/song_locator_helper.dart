import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as p;
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/remote/clients/subsonic_client.dart';
import 'package:vynody/player/remote/navidrome_navigation.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/remote_server_riverpod.dart';
import 'package:vynody/player/scanner/scanner_path_utils.dart';

class SongHighlightNotifier extends Notifier<String?> {
  Timer? _timer;

  @override
  String? build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return null;
  }

  void highlight(String path, {Duration duration = const Duration(seconds: 2)}) {
    _timer?.cancel();
    state = path;
    _timer = Timer(duration, () {
      state = null;
    });
  }

  void clear() {
    _timer?.cancel();
    state = null;
  }
}

final songHighlightProvider =
    NotifierProvider<SongHighlightNotifier, String?>(SongHighlightNotifier.new);

class SongLocatorHelper {
  static List<MusicFolder>? findFolderHistory(
    MusicFolder root,
    String songPath,
  ) {
    List<MusicFolder>? recurse(MusicFolder folder) {
      for (final file in folder.files) {
        if (p.equals(file.path, songPath)) {
          return [folder];
        }
      }
      for (final sub in folder.subFolders) {
        final res = recurse(sub);
        if (res != null) {
          return [folder, ...res];
        }
      }
      return null;
    }

    return recurse(root);
  }

  static List<MusicFolder>? findFolderHistoryByFolderPath(
    MusicFolder root,
    String targetFolderPath,
  ) {
    List<MusicFolder>? recurse(MusicFolder folder) {
      if (ScannerPathUtils.pathsEqual(folder.path, targetFolderPath)) {
        return [folder];
      }
      for (final sub in folder.subFolders) {
        final res = recurse(sub);
        if (res != null) {
          return [folder, ...res];
        }
      }
      return null;
    }

    return recurse(root);
  }

  static Future<bool> locateCurrentPlayingSong(
    WidgetRef ref,
    BuildContext context, {
    bool showNotFoundToast = true,
  }) async {
    final currentMusic = ref.read(audioCurrentMusicProvider);
    if (currentMusic == null) return false;
    final l10n = AppLocalizations.of(context);
    final songPath = currentMusic.path;

    final remoteInfo = RemoteMediaResolver.parseUri(songPath);
    if (remoteInfo != null) {
      final servers = ref.read(remoteServersProvider).asData?.value ?? [];
      final server =
          servers.firstWhereOrNull((s) => s.id == remoteInfo.serverId);
      if (server == null) {
        if (showNotFoundToast && l10n != null) {
          showToast(l10n.songNotInScannedFolders);
        }
        return false;
      }
      final password = await ref
              .read(remoteServersProvider.notifier)
              .getPassword(server.id) ??
          '';

      if (remoteInfo.type == RemoteServerType.webdav) {
        final targetDir = p.posix.dirname(remoteInfo.trackIdOrPath);
        final rootPath = server.customPath?.trim().isNotEmpty == true
            ? server.customPath!
            : '/';
        final stack =
            ActiveRemoteSession.buildWebDavPathStack(rootPath, targetDir);
        final activeSession = ref.read(activeRemoteSessionProvider);
        if (activeSession == null || activeSession.server.id != server.id) {
          ref.read(activeRemoteSessionProvider.notifier).setSession(
                ActiveRemoteSession(
                  server: server,
                  password: password,
                  rootPath: rootPath,
                  initialPath: targetDir,
                  webDavPathStack: stack,
                  webDavHighlightedSongPath: songPath,
                ),
              );
        } else {
          ref.read(activeRemoteSessionProvider.notifier).setWebDavLocation(
                pathStack: stack,
                highlightedSongPath: songPath,
              );
        }
        ref.read(songHighlightProvider.notifier).highlight(songPath);
        return true;
      } else if (remoteInfo.type == RemoteServerType.subsonic) {
        try {
          final client = SubsonicClient(server: server, password: password);
          final songData = await client.getSong(remoteInfo.trackIdOrPath);
          if (songData != null && context.mounted) {
            final albumId =
                songData['albumId'] as String? ?? songData['parent'] as String?;
            final albumName = songData['album'] as String? ?? 'Album';
            final artistName = songData['artist'] as String?;
            final coverArtId = songData['coverArt'] as String?;
            if (albumId != null) {
              final activeSession = ref.read(activeRemoteSessionProvider);
              if (activeSession == null ||
                  activeSession.server.id != server.id) {
                ref.read(activeRemoteSessionProvider.notifier).setSession(
                      ActiveRemoteSession(
                        server: server,
                        password: password,
                        navidromeDetailStack: [
                          NavidromeAlbumRoute(
                            albumId: albumId,
                            albumName: albumName,
                            artistName: artistName,
                            coverArtId: coverArtId,
                            highlightedSongPath: songPath,
                          ),
                        ],
                      ),
                    );
              } else {
                NavidromeNavUtils.openAlbum(
                  context,
                  ref,
                  server: server,
                  password: password,
                  albumId: albumId,
                  albumName: albumName,
                  artistName: artistName,
                  coverArtId: coverArtId,
                  highlightedSongPath: songPath,
                );
              }
              ref.read(songHighlightProvider.notifier).highlight(songPath);
              return true;
            }
          }
        } catch (_) {}
        if (showNotFoundToast && l10n != null) {
          showToast(l10n.songNotInScannedFolders);
        }
        return false;
      }
    }

    // Local song handling
    final activeSession = ref.read(activeRemoteSessionProvider);
    if (activeSession != null) {
      ref.read(activeRemoteSessionProvider.notifier).clear();
    }

    final scanner = ref.read(scannerServiceProvider);
    List<MusicFolder>? foundHistory;

    for (final root in scanner.rootFolders) {
      foundHistory = findFolderHistory(root, songPath);
      if (foundHistory != null) {
        break;
      }
    }

    if (foundHistory == null && scanner.systemMediaFolder != null) {
      foundHistory = findFolderHistory(
        scanner.systemMediaFolder!,
        songPath,
      );
    }

    if (foundHistory == null) {
      final songMeta = await scanner.getSongMetadata(songPath);
      final isSystemMedia = songMeta != null &&
          ((songMeta.sourceFlags ?? 0) & SongSourceFlags.systemMedia) != 0;

      if (!isSystemMedia) {
        final matchingRootPath = scanner.rootPaths.firstWhereOrNull(
          (root) => ScannerPathUtils.pathContains(root, songPath),
        );
        if (matchingRootPath != null) {
          await scanner.loadRootFolderSongs(matchingRootPath);
        } else {
          for (final rootPath in scanner.rootPaths) {
            await scanner.loadRootFolderSongs(rootPath);
          }
        }
      }

      for (final root in scanner.rootFolders) {
        foundHistory = findFolderHistory(root, songPath);
        if (foundHistory != null) {
          break;
        }
      }

      if (foundHistory == null && scanner.systemMediaFolder != null) {
        foundHistory = findFolderHistory(
          scanner.systemMediaFolder!,
          songPath,
        );
      }
    }

    if (!context.mounted) return false;

    if (foundHistory != null && foundHistory.isNotEmpty) {
      final targetFolder = foundHistory.last;
      final history = foundHistory.sublist(0, foundHistory.length - 1);
      final alreadyInFolder =
          scanner.navigationCurrentFolder?.path == targetFolder.path;

      if (!alreadyInFolder) {
        scanner.setNavigationState(targetFolder, history);
      }

      ref.read(songHighlightProvider.notifier).highlight(currentMusic.path);
      return true;
    } else {
      if (showNotFoundToast && l10n != null) {
        showToast(l10n.songNotInScannedFolders);
      }
      return false;
    }
  }
}
