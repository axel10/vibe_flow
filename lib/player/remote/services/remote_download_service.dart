import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as p;
import '../../../models/music_file.dart';
import '../../audio/audio_riverpod.dart';
import '../../sharing/sharing_riverpod.dart';
import '../clients/subsonic_client.dart';
import '../remote_server_models.dart';

final remoteDownloadServiceProvider = Provider<RemoteDownloadService>((ref) {
  return RemoteDownloadService(ref);
});

class RemoteDownloadService {
  final Ref _ref;
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );

  RemoteDownloadService(this._ref);

  /// Resolves the destination directory for downloaded music.
  /// Defaults to 'Vynody Music' (shared with LAN transfer).
  Future<String> getDownloadFolderPath() async {
    final settings = _ref.read(settingsServiceProvider);
    if (settings.hasLanSharingFolderPath) {
      return settings.lanSharingFolderPath;
    }
    final sharingService = _ref.read(sharingServiceProvider);
    return await sharingService.getDefaultSharingFolderPath();
  }

  /// Sanitizes string for filesystem path segment.
  String _sanitize(String? input, {String fallback = 'Unknown'}) {
    if (input == null || input.trim().isEmpty) return fallback;
    return input.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  /// Builds the local destination file path for a remote music track.
  Future<String> buildLocalTrackPath({
    required MusicFile song,
    required String baseFolder,
  }) async {
    final artist = _sanitize(song.artist, fallback: 'Unknown Artist');
    final album = _sanitize(song.album, fallback: 'Unknown Album');
    final trackNum = song.trackNumber;
    final trackPrefix = trackNum != null && trackNum > 0
        ? '${trackNum.toString().padLeft(2, '0')} - '
        : '';
    final title = _sanitize(song.title ?? song.name, fallback: 'Track');

    // Extract extension from song suffix or path
    String ext = '.mp3';
    if (song.path.isNotEmpty) {
      final uri = Uri.tryParse(song.path);
      final rawExt = uri != null ? p.extension(uri.path) : p.extension(song.path);
      if (rawExt.isNotEmpty && rawExt.length <= 5) {
        ext = rawExt;
      }
    }

    final filename = '$trackPrefix$title$ext';
    return p.join(baseFolder, artist, album, filename);
  }

  /// Downloads a single remote track to the local music library.
  Future<bool> downloadTrack({
    required RemoteServer server,
    required String password,
    required MusicFile song,
    required String trackId,
  }) async {
    final client = SubsonicClient(server: server, password: password);
    final baseFolder = await getDownloadFolderPath();

    try {
      final targetPath = await buildLocalTrackPath(
        song: song,
        baseFolder: baseFolder,
      );

      final file = File(targetPath);
      if (file.existsSync() && file.lengthSync() > 0) {
        showToast('Already downloaded: ${song.displayName}');
        return true;
      }

      // Ensure directory exists
      final dir = file.parent;
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      showToast('Downloading: ${song.displayName}');

      final downloadUrl = client.buildDownloadUrl(trackId);
      final tempPath = '$targetPath.part';
      final tempFile = File(tempPath);

      await _dio.download(downloadUrl, tempPath);

      if (tempFile.existsSync() && tempFile.lengthSync() > 0) {
        if (file.existsSync()) {
          file.deleteSync();
        }
        tempFile.renameSync(targetPath);

        // Ensure scanner knows about this directory
        final scanner = _ref.read(scannerServiceProvider);
        await scanner.ready;
        if (!scanner.rootPaths.any((path) => p.equals(path, baseFolder))) {
          await scanner.addRootPath(baseFolder);
        }

        showToast('Saved to local library: ${song.displayName}');
        return true;
      } else {
        if (tempFile.existsSync()) tempFile.deleteSync();
        showToast('Download failed: Empty response from server');
        return false;
      }
    } catch (e) {
      debugPrint('[RemoteDownloadService] Download error: $e');
      showToast('Download failed: $e');
      return false;
    }
  }

  /// Batch downloads multiple tracks (e.g. from an album or artist).
  Future<void> downloadTracks({
    required RemoteServer server,
    required String password,
    required List<MusicFile> songs,
    required String collectionName,
  }) async {
    if (songs.isEmpty) return;
    final client = SubsonicClient(server: server, password: password);
    final baseFolder = await getDownloadFolderPath();

    showToast('Downloading ${songs.length} tracks from "$collectionName"...');

    int successCount = 0;
    for (final song in songs) {
      try {
        // Extract subsonic trackId from song.path (subsonic://{server.id}/track_{id})
        String trackId = song.id.toString();
        if (song.path.contains('/track_')) {
          trackId = song.path.split('/track_').last;
        }

        final targetPath = await buildLocalTrackPath(
          song: song,
          baseFolder: baseFolder,
        );

        final file = File(targetPath);
        if (file.existsSync() && file.lengthSync() > 0) {
          successCount++;
          continue;
        }

        final dir = file.parent;
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }

        final downloadUrl = client.buildDownloadUrl(trackId);
        final tempPath = '$targetPath.part';
        final tempFile = File(tempPath);

        await _dio.download(downloadUrl, tempPath);
        if (tempFile.existsSync() && tempFile.lengthSync() > 0) {
          if (file.existsSync()) file.deleteSync();
          tempFile.renameSync(targetPath);
          successCount++;
        } else {
          if (tempFile.existsSync()) tempFile.deleteSync();
        }
      } catch (e) {
        debugPrint('[RemoteDownloadService] Error downloading track ${song.displayName}: $e');
      }
    }

    // Ensure base directory is registered with scanner
    final scanner = _ref.read(scannerServiceProvider);
    await scanner.ready;
    if (!scanner.rootPaths.any((path) => p.equals(path, baseFolder))) {
      await scanner.addRootPath(baseFolder);
    }

    showToast('Downloaded $successCount/${songs.length} tracks to local library');
  }
}
