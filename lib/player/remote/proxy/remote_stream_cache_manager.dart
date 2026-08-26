import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Manages local disk caching for streamed remote audio tracks.
class RemoteStreamCacheManager {
  static const String cacheDirName = 'remote_audio_cache';
  Directory? _cacheDir;
  final Directory? customCacheDirectory;
  final int Function()? maxCacheSizeBytesGetter;
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 10),
      sendTimeout: const Duration(seconds: 15),
      followRedirects: true,
    ),
  );
  final Map<String, Future<File>> _activeDownloads = {};

  RemoteStreamCacheManager({
    this.customCacheDirectory,
    this.maxCacheSizeBytesGetter,
  }) {
    if (customCacheDirectory != null) {
      _cacheDir = customCacheDirectory;
    }
  }

  /// Synchronous fallback directory when async path_provider is not yet called.
  Directory get cacheDirectorySync {
    if (_cacheDir != null) return _cacheDir!;
    final dir = Directory(p.join(Directory.systemTemp.path, cacheDirName));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  /// Initializes cache directory.
  Future<Directory> getCacheDirectory() async {
    if (_cacheDir != null && await _cacheDir!.exists()) {
      return _cacheDir!;
    }
    try {
      final tempDir = await getTemporaryDirectory();
      final targetDir = Directory(p.join(tempDir.path, cacheDirName));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      _cacheDir = targetDir;
      return targetDir;
    } catch (_) {
      // Fallback for tests or systems without path_provider channel
      final targetDir = Directory(p.join(Directory.systemTemp.path, cacheDirName));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      _cacheDir = targetDir;
      return targetDir;
    }
  }

  /// Derives a deterministic local cache file path for a remote track.
  Future<File> getCacheFile({
    required String serverId,
    required String trackIdOrPath,
    String? extension,
  }) async {
    final dir = await getCacheDirectory();
    final serverDir = Directory(p.join(dir.path, serverId));
    if (!await serverDir.exists()) {
      await serverDir.create(recursive: true);
    }

    final hash = md5.convert(utf8.encode(trackIdOrPath)).toString();
    final ext = extension != null && extension.isNotEmpty
        ? (extension.startsWith('.') ? extension : '.$extension')
        : '.cache';
    return File(p.join(serverDir.path, '$hash$ext'));
  }

  /// Checks if a track is fully cached locally.
  Future<bool> isTrackCached({
    required String serverId,
    required String trackIdOrPath,
    String? extension,
  }) async {
    final file = await getCacheFile(
      serverId: serverId,
      trackIdOrPath: trackIdOrPath,
      extension: extension,
    );
    if (!await file.exists()) return false;
    final length = await file.length();
    return length > 0;
  }

  /// Ensures a remote track is fully downloaded and cached locally on disk.
  Future<File> ensureTrackCached({
    required String serverId,
    required String trackIdOrPath,
    required String remoteUrl,
    Map<String, String>? headers,
    String? extension,
  }) async {
    final cachedFile = await getCacheFile(
      serverId: serverId,
      trackIdOrPath: trackIdOrPath,
      extension: extension,
    );

    if (await cachedFile.exists() && await cachedFile.length() > 0) {
      await touchCacheFile(cachedFile);
      return cachedFile;
    }

    final downloadKey = '$serverId:$trackIdOrPath';
    if (_activeDownloads.containsKey(downloadKey)) {
      return _activeDownloads[downloadKey]!;
    }

    final future = _downloadTrack(
      cachedFile: cachedFile,
      remoteUrl: remoteUrl,
      headers: headers,
    );
    _activeDownloads[downloadKey] = future;
    try {
      final res = await future;
      return res;
    } finally {
      _activeDownloads.remove(downloadKey);
    }
  }

  /// Updates access timestamp of a cached file for LRU tracking.
  Future<void> touchCacheFile(File file) async {
    try {
      if (await file.exists()) {
        await file.setLastModified(DateTime.now());
      }
    } catch (_) {}
  }

  /// Prunes oldest cached audio files if total cache size exceeds [limitBytes] or configured limit.
  Future<void> pruneCacheIfNeeded({int? limitBytes}) async {
    final limit = limitBytes ?? maxCacheSizeBytesGetter?.call() ?? 0;
    if (limit <= 0) return; // 0 means unlimited

    final dir = await getCacheDirectory();
    if (!await dir.exists()) return;

    final files = <File>[];
    int totalBytes = 0;

    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && !entity.path.endsWith('.tmp')) {
          files.add(entity);
          totalBytes += await entity.length();
        }
      }
    } catch (_) {}

    if (totalBytes <= limit) return;

    // Sort by last modified time ascending (oldest first)
    final stats = <File, DateTime>{};
    for (final f in files) {
      try {
        stats[f] = (await f.stat()).modified;
      } catch (_) {
        stats[f] = DateTime.fromMillisecondsSinceEpoch(0);
      }
    }
    files.sort((a, b) => (stats[a] ?? DateTime(0)).compareTo(stats[b] ?? DateTime(0)));

    // Clean down to 85% of limit to avoid frequent thrashing
    final targetBytes = (limit * 0.85).toInt();
    for (final f in files) {
      if (totalBytes <= targetBytes) break;
      try {
        final len = await f.length();
        await f.delete();
        totalBytes -= len;
        debugPrint('[RemoteStreamCache] Pruned cached file: ${f.path} ($len bytes)');
      } catch (_) {}
    }
  }

  Future<File> _downloadTrack({
    required File cachedFile,
    required String remoteUrl,
    Map<String, String>? headers,
  }) async {
    final tmpFile = File('${cachedFile.path}.tmp');
    if (await tmpFile.exists()) {
      try {
        await tmpFile.delete();
      } catch (_) {}
    }

    try {
      debugPrint('[RemoteStreamCache] Downloading remote track: $remoteUrl -> ${cachedFile.path}');
      await _dio.download(
        remoteUrl,
        tmpFile.path,
        options: Options(headers: headers),
      );
      if (await tmpFile.exists() && await tmpFile.length() > 0) {
        if (await cachedFile.exists()) {
          await cachedFile.delete();
        }
        await tmpFile.rename(cachedFile.path);
        debugPrint('[RemoteStreamCache] Download complete, size=${await cachedFile.length()} bytes');
        await pruneCacheIfNeeded();
        return cachedFile;
      } else {
        throw StateError('Downloaded empty file for $remoteUrl');
      }
    } catch (e) {
      debugPrint('[RemoteStreamCache] Download failed: $e');
      try {
        if (await tmpFile.exists()) await tmpFile.delete();
      } catch (_) {}
      rethrow;
    }
  }

  /// Clears cache for a specific server or entire remote audio cache.
  Future<void> clearCache({String? serverId}) async {
    final dir = await getCacheDirectory();
    if (serverId != null) {
      final serverDir = Directory(p.join(dir.path, serverId));
      if (await serverDir.exists()) {
        await serverDir.delete(recursive: true);
      }
    } else {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
    }
  }

  /// Calculates total cache size in bytes.
  Future<int> getTotalCacheSize() async {
    final dir = await getCacheDirectory();
    int total = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && !entity.path.endsWith('.tmp')) {
          total += await entity.length();
        }
      }
    } catch (_) {}
    return total;
  }
}
