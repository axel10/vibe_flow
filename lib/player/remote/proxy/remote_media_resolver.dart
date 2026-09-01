import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../../models/music_file.dart';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';

import 'package:audio_core/audio_core.dart';
import '../remote_server_models.dart';
import '../remote_server_storage.dart';
import '../clients/subsonic_client.dart';
import '../clients/webdav_client.dart';
import '../../metadata/metadata_database.dart';

class RemoteUriInfo {
  final RemoteServerType type;
  final String serverId;
  final String trackIdOrPath;
  final Map<String, String> queryParameters;

  const RemoteUriInfo({
    required this.type,
    required this.serverId,
    required this.trackIdOrPath,
    this.queryParameters = const {},
  });
}

class RemoteMediaResolver {
  final RemoteServerStorage storage;
  final AudioStreamCacheManager cacheManager;

  RemoteMediaResolver({
    required this.storage,
    AudioStreamCacheManager? cacheManager,
  }) : cacheManager = cacheManager ?? AudioStreamCacheManager();

  /// Checks if a file path is a remote virtual URI.
  static bool isRemoteUri(String path) {
    return path.startsWith('subsonic://') || path.startsWith('webdav://');
  }

  /// Parses a remote virtual URI.
  static RemoteUriInfo? parseUri(String uriString) {
    if (!isRemoteUri(uriString)) return null;
    try {
      final schemeEnd = uriString.indexOf('://');
      if (schemeEnd > 0) {
        final scheme = uriString.substring(0, schemeEnd).toLowerCase();
        final rest = uriString.substring(schemeEnd + 3);
        final slashIdx = rest.indexOf('/');
        final queryIdx = rest.indexOf('?');

        final serverId = slashIdx >= 0
            ? rest.substring(0, slashIdx)
            : (queryIdx >= 0 ? rest.substring(0, queryIdx) : rest);

        String rawPath = slashIdx >= 0
            ? (queryIdx >= 0
                ? rest.substring(slashIdx, queryIdx)
                : rest.substring(slashIdx))
            : '';

        Map<String, String> queryParams = const {};
        if (queryIdx >= 0) {
          final queryStr = rest.substring(queryIdx + 1);
          try {
            queryParams = Uri.splitQueryString(queryStr);
          } catch (_) {}
        }

        if (scheme == 'subsonic') {
          var trackId = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
          try {
            trackId = Uri.decodeFull(trackId);
          } catch (_) {}
          return RemoteUriInfo(
            type: RemoteServerType.subsonic,
            serverId: serverId,
            trackIdOrPath: trackId,
            queryParameters: queryParams,
          );
        } else if (scheme == 'webdav') {
          var cleanPath = rawPath.isNotEmpty ? rawPath : '/';
          if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';
          try {
            cleanPath = Uri.decodeFull(cleanPath);
          } catch (_) {}
          return RemoteUriInfo(
            type: RemoteServerType.webdav,
            serverId: serverId,
            trackIdOrPath: cleanPath,
            queryParameters: queryParams,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// Builds a Subsonic virtual URI.
  static String buildSubsonicUri(String serverId, String trackId) {
    return 'subsonic://$serverId/$trackId';
  }

  /// Extracts Subsonic track ID from a [MusicFile] or URI path.
  static String? extractSubsonicTrackId(MusicFile song) {
    final info = parseUri(song.path);
    if (info != null &&
        info.type == RemoteServerType.subsonic &&
        info.trackIdOrPath.isNotEmpty) {
      return info.trackIdOrPath;
    }
    if (song.path.startsWith('subsonic://')) {
      final uri = Uri.tryParse(song.path) ?? Uri.tryParse(Uri.encodeFull(song.path));
      if (uri != null && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.join('/');
      }
    }
    if (song.path.contains('/track_')) {
      return song.path.split('/track_').last;
    }
    if (song.id != null && song.id! > 0) {
      return song.id.toString();
    }
    return null;
  }

  /// Builds a WebDAV virtual URI.
  static String buildWebDavUri(String serverId, String relativePath) {
    var clean = relativePath.trim();
    if (!clean.startsWith('/')) clean = '/$clean';
    return 'webdav://$serverId$clean';
  }

  /// Converts a cacheKey (e.g. `serverId:path`) back to its virtual URI (`webdav://...` or `subsonic://...`).
  static String? uriFromCacheKey(String cacheKey) {
    final idx = cacheKey.indexOf(':');
    if (idx <= 0) return null;
    final serverId = cacheKey.substring(0, idx);
    var trackIdOrPath = cacheKey.substring(idx + 1);
    try {
      trackIdOrPath = Uri.decodeFull(trackIdOrPath);
    } catch (_) {}
    if (trackIdOrPath.startsWith('/')) {
      return buildWebDavUri(serverId, trackIdOrPath);
    } else {
      return buildSubsonicUri(serverId, trackIdOrPath);
    }
  }

  /// Resolves a remote virtual URI into a [ResolvedAudioUri] with URL, headers, and cacheKey for [AudioCoreController].
  Future<ResolvedAudioUri> resolvePlayableSource(String remoteUri, {int? maxBitRate}) async {
    final info = parseUri(remoteUri);
    if (info == null) {
      return ResolvedAudioUri(uri: remoteUri);
    }

    final servers = storage.loadServers();
    final server = servers.firstWhere(
      (s) => s.id == info.serverId,
      orElse: () => throw StateError('Server with ID ${info.serverId} not found'),
    );

    final password = await storage.getPassword(server.id) ?? '';

    if (info.type == RemoteServerType.subsonic) {
      final client = SubsonicClient(server: server, password: password);
      final streamUrl = client.buildStreamUrl(
        info.trackIdOrPath,
        maxBitRate: maxBitRate ?? server.maxBitRate,
      );

      return ResolvedAudioUri(
        uri: streamUrl,
        cacheKey: '${server.id}:${info.trackIdOrPath}',
      );
    } else {
      final client = WebDavClient(server: server, password: password);
      final streamUrl = client.buildStreamUrl(info.trackIdOrPath);

      return ResolvedAudioUri(
        uri: streamUrl,
        headers: client.authHeaders,
        cacheKey: '${server.id}:${info.trackIdOrPath}',
      );
    }
  }

  /// Resolves a remote virtual URI into a local cached audio file path (downloading if necessary).
  Future<String> resolvePlayableLocalPath(String remoteUri, {int? maxBitRate}) async {
    final info = parseUri(remoteUri);
    if (info == null) {
      return remoteUri;
    }

    final resolved = await resolvePlayableSource(remoteUri, maxBitRate: maxBitRate);
    final cacheKey = resolved.cacheKey ?? remoteUri;

    final cached = await cacheManager.ensureTrackCached(
      cacheKey: cacheKey,
      remoteUrl: resolved.uri,
      headers: resolved.headers,
    );
    return cached.path;
  }

  /// Synchronously returns the deterministic local cache file path for a remote URI.
  String resolvePlayableLocalPathSync(String remoteUri) {
    final info = parseUri(remoteUri);
    if (info == null) return remoteUri;

    final dir = cacheManager.cacheDirectorySync;
    final hash = md5.convert(utf8.encode('${info.serverId}:${info.trackIdOrPath}')).toString();
    var ext = p.extension(info.trackIdOrPath);
    if (ext.contains('?')) {
      ext = ext.split('?').first;
    }
    if (ext.isEmpty || ext.length > 6 || !ext.startsWith('.')) {
      ext = '.cache';
    }
    final primaryPath = p.join(dir.path, '$hash$ext');
    if (ext != '.cache' && !File(primaryPath).existsSync()) {
      final legacyPath = p.join(dir.path, '$hash.cache');
      if (File(legacyPath).existsSync()) {
        return legacyPath;
      }
    }
    return primaryPath;
  }

  /// Constructs a [MusicFile] model from a Subsonic track JSON object.
  static MusicFile buildMusicFileFromSubsonic(
    Map<String, dynamic> trackJson,
    RemoteServer server,
  ) {
    final trackId = trackJson['id'] as String? ?? '';
    final title = trackJson['title'] as String? ?? '';
    final artist = trackJson['artist'] as String?;
    final album = trackJson['album'] as String?;
    final trackNumber = trackJson['track'] as int?;
    final durationSeconds = trackJson['duration'] as int? ?? 0;
    final coverArt = trackJson['coverArt'] as String?;
    final suffix = trackJson['suffix'] as String? ?? 'mp3';

    final uri = buildSubsonicUri(server.id, trackId);
    return MusicFile(
      path: uri,
      name: '$title.$suffix',
      title: title,
      artist: artist,
      album: album,
      trackNumber: trackNumber,
      durationMillis: durationSeconds * 1000,
      artworkPath: coverArt != null ? 'subsonic-cover://${server.id}/$coverArt' : null,
      isMissing: false,
    );
  }

  /// Constructs a [MusicFile] model from a [WebDavFile].
  static MusicFile buildMusicFileFromWebDav(
    WebDavFile file,
    RemoteServer server, {
    SongMetadata? metadata,
  }) {
    final uri = buildWebDavUri(server.id, file.path);
    final fallbackTitle = p.basenameWithoutExtension(file.name);

    return MusicFile(
      path: uri,
      name: file.name,
      title: metadata != null && metadata.title.isNotEmpty ? metadata.title : fallbackTitle,
      artist: metadata != null && metadata.artist.isNotEmpty && metadata.artist != 'Unknown' ? metadata.artist : null,
      album: metadata != null && metadata.album.isNotEmpty && metadata.album != 'Unknown' ? metadata.album : null,
      trackNumber: metadata?.trackNumber,
      durationMillis: metadata?.duration,
      thumbnailPath: metadata?.thumbnailPath,
      artworkPath: metadata?.artworkPath,
      isMissing: false,
    );
  }

  /// Returns the artwork image URL if available for the given remote song.
  Future<String?> getArtworkUrl(MusicFile song, {int size = 400}) async {
    return getArtworkUrlFromUri(song.path, coverArtId: song.artworkPath, size: size);
  }

  /// Returns the artwork image URL if available for the given remote URI or cover art ID.
  Future<String?> getArtworkUrlFromUri(String remotePath, {String? coverArtId, int size = 400}) async {
    final info = parseUri(remotePath);
    if (info == null) return null;

    final servers = storage.loadServers();
    final server = servers.firstWhereOrNull((s) => s.id == info.serverId);
    if (server == null) return null;
    final password = await storage.getPassword(server.id) ?? '';

    if (info.type == RemoteServerType.subsonic) {
      var coverId = (coverArtId != null && coverArtId.isNotEmpty)
          ? coverArtId.replaceFirst('subsonic-cover://', '')
          : info.trackIdOrPath;
      if (coverId.startsWith('${server.id}/')) {
        coverId = coverId.substring('${server.id}/'.length);
      }
      final client = SubsonicClient(server: server, password: password);
      return client.buildCoverArtUrl(coverId, size: size);
    }
    return null;
  }

  /// Fetches raw artwork bytes for the given remote URI or cover art ID.
  Future<Uint8List?> getArtworkBytes(String remotePath, {String? coverArtId, int size = 500}) async {
    final info = parseUri(remotePath);
    if (info == null) return null;

    final servers = storage.loadServers();
    final server = servers.firstWhereOrNull((s) => s.id == info.serverId);
    if (server == null) return null;
    final password = await storage.getPassword(server.id) ?? '';

    if (info.type == RemoteServerType.subsonic) {
      var resolvedCoverId = (coverArtId != null && coverArtId.isNotEmpty)
          ? coverArtId.replaceFirst('subsonic-cover://', '')
          : info.trackIdOrPath;
      if (resolvedCoverId.startsWith('${server.id}/')) {
        resolvedCoverId = resolvedCoverId.substring('${server.id}/'.length);
      }
      final client = SubsonicClient(server: server, password: password);
      return client.getCoverArtBytes(resolvedCoverId, size: size);
    }
    return null;
  }

  /// Fetches lyrics for the given remote song.
  Future<String?> fetchLyrics(MusicFile song) async {
    final info = parseUri(song.path);
    if (info == null) return null;

    final servers = storage.loadServers();
    final server = servers.firstWhere(
      (s) => s.id == info.serverId,
      orElse: () => throw StateError('Server not found'),
    );
    final password = await storage.getPassword(server.id) ?? '';

    if (info.type == RemoteServerType.subsonic) {
      final client = SubsonicClient(server: server, password: password);
      return client.getLyrics(
        id: info.trackIdOrPath,
        artist: song.artist,
        title: song.title ?? song.name,
      );
    } else if (info.type == RemoteServerType.webdav) {
      final client = WebDavClient(server: server, password: password);
      // Attempt to find companion .lrc file in the same directory
      final audioPath = info.trackIdOrPath;
      final lrcPath = '${p.withoutExtension(audioPath)}.lrc';
      return client.getFileContent(lrcPath);
    }
    return null;
  }

  /// Downloads or copies a cached remote track to a temporary file for local operations (e.g. transcoding).
  /// Returns the temporary [File].
  Future<File> downloadRemoteTrackToTempFile(
    MusicFile song, {
    void Function(int received, int total)? onProgress,
  }) async {
    final info = parseUri(song.path);
    if (info == null) {
      throw ArgumentError('Not a remote track: ${song.path}');
    }

    final servers = storage.loadServers();
    final server = servers.firstWhere(
      (s) => s.id == info.serverId,
      orElse: () => throw StateError('Server with ID ${info.serverId} not found'),
    );

    final cacheKey = '${server.id}:${info.trackIdOrPath}';

    final tempDir = await getTemporaryDirectory();
    final uniqueId = '${DateTime.now().microsecondsSinceEpoch}_${song.hashCode.abs()}';
    final taskTempDir = Directory(p.join(tempDir.path, 'transcode_temp', uniqueId));
    if (!await taskTempDir.exists()) {
      await taskTempDir.create(recursive: true);
    }

    // Determine extension
    String ext = p.extension(song.name);
    if (ext.isEmpty && info.trackIdOrPath.contains('.')) {
      ext = p.extension(info.trackIdOrPath);
    }
    if (ext.isEmpty) {
      ext = '.tmp';
    }

    final baseName = p.basenameWithoutExtension(song.name.isNotEmpty ? song.name : song.displayName);
    final sanitizedBaseName = baseName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final tempFilePath = p.join(taskTempDir.path, '$sanitizedBaseName$ext');
    final tempFile = File(tempFilePath);

    // 1. Check if audio is already cached in AudioStreamCacheManager
    if (await cacheManager.isTrackCached(cacheKey)) {
      final cachedFile = await cacheManager.getCacheFile(cacheKey);
      if (await cachedFile.exists() && await cachedFile.length() > 0) {
        await cachedFile.copy(tempFile.path);
        onProgress?.call(await tempFile.length(), await tempFile.length());
        return tempFile;
      }
    }

    // 2. Download from remote server
    final password = await storage.getPassword(server.id) ?? '';
    String downloadUrl;
    Map<String, String>? headers;

    if (info.type == RemoteServerType.subsonic) {
      final client = SubsonicClient(server: server, password: password);
      downloadUrl = client.buildDownloadUrl(info.trackIdOrPath);
    } else {
      final client = WebDavClient(server: server, password: password);
      downloadUrl = client.buildStreamUrl(info.trackIdOrPath);
      headers = client.authHeaders;
    }

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(minutes: 10),
        headers: headers,
      ),
    );

    if (server.ignoreSsl) {
      final adapter = dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        };
      }
    }

    await dio.download(
      downloadUrl,
      tempFile.path,
      onReceiveProgress: onProgress,
    );

    return tempFile;
  }
}

