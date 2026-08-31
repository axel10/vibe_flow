import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_taglib/flutter_taglib.dart' as taglib;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import '../clients/webdav_client.dart';
import '../proxy/remote_media_resolver.dart';
import '../remote_server_models.dart';
import '../../metadata/metadata_database.dart';

/// Helper for asynchronously extracting and caching audio metadata from WebDAV servers
/// using lightweight HTTP Range requests via flutter_taglib.
class WebDavMetadataHelper {
  /// Fetches audio metadata for a single WebDAV file via HTTP Range requests.
  ///
  /// If the server does NOT support HTTP Range requests or if opening fails,
  /// this method immediately logs the reason and returns `null` without downloading
  /// the full file.
  static Future<SongMetadata?> fetchWebDavSongMetadata({
    required WebDavFile file,
    required RemoteServer server,
    required String password,
  }) async {
    if (!file.isAudio) return null;

    final client = WebDavClient(server: server, password: password);
    final virtualUri = RemoteMediaResolver.buildWebDavUri(server.id, file.path);
    final fullUrl = client.buildFullUrl(file.path);
    final headers = client.authHeaders;

    if (!taglib.TagLibFile.isSupported) {
      debugPrint('[WebDAV Metadata] flutter_taglib is not supported on this platform.');
      return null;
    }

    try {
      final tagData = await taglib.TagLibFile.readMetadataAsync(
        fullUrl,
        headers: headers,
        audioPropertiesStyle: taglib.TagLibAudioPropertiesStyle.fast,
        readCover: true,
        timeout: const Duration(seconds: 10),
      );

      if (tagData == null) {
        debugPrint(
          '[WebDAV Metadata] Skip metadata for "${file.name}": '
          'Server does not support HTTP Range requests or file is unreadable (${taglib.TagLibFile.lastError ?? "read failed"}). '
          'Falling back to filename.',
        );
        return null;
      }

      final title = tagData.title.trim();
      final artist = tagData.artist.trim();
      final album = tagData.album.trim();
      final genre = tagData.genre.trim();
      final duration = tagData.duration.inMilliseconds;
      final trackNumber = tagData.track;

      String? savedThumbnailPath;
      try {
        if (tagData.hasCover && tagData.coverData != null && tagData.coverData!.isNotEmpty) {
          final coverBytes = tagData.coverData!;
          final md5Hex = md5.convert(coverBytes).toString();
          final supportDir = await getApplicationSupportDirectory();
          final thumbnailsDir = Directory(p.join(supportDir.path, 'thumbnails'));
          if (!thumbnailsDir.existsSync()) {
            await thumbnailsDir.create(recursive: true);
          }
          final thumbFile = File(p.join(thumbnailsDir.path, '${md5Hex}_thumb.jpg'));
          if (!thumbFile.existsSync()) {
            await thumbFile.writeAsBytes(coverBytes);
          }
          savedThumbnailPath = thumbFile.path;

          final db = MetadataDatabase();
          await db.insertOrUpdateArtworkCache(
            ArtworkCacheRecord(
              md5: md5Hex,
              thumbnailPath: savedThumbnailPath,
              updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        }
      } catch (e) {
        debugPrint('[WebDAV Metadata] Failed to save cover thumbnail for "${file.name}": $e');
      }

      final songMetadata = SongMetadata(
        path: virtualUri,
        title: title.isNotEmpty ? title : p.basenameWithoutExtension(file.name),
        album: album.isNotEmpty ? album : 'Unknown',
        artist: artist.isNotEmpty ? artist : 'Unknown',
        duration: duration > 0 ? duration : null,
        trackNumber: trackNumber > 0 ? trackNumber : null,
        thumbnailPath: savedThumbnailPath,
        lastModifiedTime: file.lastModified?.millisecondsSinceEpoch ?? 0,
        genres: genre.isNotEmpty ? [genre] : null,
      );

      final db = MetadataDatabase();
      await db.insertOrUpdateSong(songMetadata);

      return songMetadata;
    } catch (e) {
      debugPrint('[WebDAV Metadata] Error reading metadata for "${file.name}": $e');
      return null;
    }
  }

  /// Concurrently processes a list of WebDAV audio files with a pool of workers.
  static Future<void> processBatchMetadata({
    required List<WebDavFile> files,
    required RemoteServer server,
    required String password,
    required void Function(String virtualUri, SongMetadata metadata) onMetadataLoaded,
    int concurrency = 3,
    bool Function()? isCancelled,
  }) async {
    final audioFiles = files.where((f) => f.isAudio).toList();
    if (audioFiles.isEmpty) return;

    final queue = List<WebDavFile>.from(audioFiles);
    final workerCount = concurrency.clamp(1, 4);

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        if (isCancelled?.call() == true) return;
        final file = queue.removeAt(0);

        final meta = await fetchWebDavSongMetadata(
          file: file,
          server: server,
          password: password,
        );

        if (isCancelled?.call() == true) return;

        if (meta != null) {
          final virtualUri = RemoteMediaResolver.buildWebDavUri(server.id, file.path);
          onMetadataLoaded(virtualUri, meta);
        }
      }
    }

    final workers = List.generate(
      workerCount.clamp(1, queue.length),
      (_) => worker(),
    );
    await Future.wait(workers);
  }
}
