import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../../models/music_file.dart';

import '../remote_server_models.dart';
import '../remote_server_storage.dart';
import '../clients/subsonic_client.dart';
import '../clients/webdav_client.dart';
import 'local_stream_cache_proxy.dart';

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
  final LocalStreamCacheProxy proxy;

  RemoteMediaResolver({
    required this.storage,
    required this.proxy,
  });

  /// Checks if a file path is a remote virtual URI.
  static bool isRemoteUri(String path) {
    return path.startsWith('subsonic://') || path.startsWith('webdav://');
  }

  /// Parses a remote virtual URI.
  static RemoteUriInfo? parseUri(String uriString) {
    if (!isRemoteUri(uriString)) return null;
    try {
      final uri = Uri.parse(uriString);
      if (uri.scheme == 'subsonic') {
        final serverId = uri.host;
        final trackId = uri.pathSegments.isNotEmpty ? uri.pathSegments.join('/') : '';
        return RemoteUriInfo(
          type: RemoteServerType.subsonic,
          serverId: serverId,
          trackIdOrPath: trackId,
          queryParameters: uri.queryParameters,
        );
      } else if (uri.scheme == 'webdav') {
        final serverId = uri.host;
        final rawPath = uri.path;
        return RemoteUriInfo(
          type: RemoteServerType.webdav,
          serverId: serverId,
          trackIdOrPath: rawPath,
          queryParameters: uri.queryParameters,
        );
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
      final uri = Uri.tryParse(song.path);
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

  /// Resolves a remote virtual URI synchronously if server and password are cached.
  String resolvePlayableUrlSync(String remoteUri, {int? maxBitRate}) {
    final info = parseUri(remoteUri);
    if (info == null) {
      return remoteUri;
    }

    final servers = storage.loadServers();
    final server = servers.firstWhere(
      (s) => s.id == info.serverId,
      orElse: () => throw StateError('Server with ID ${info.serverId} not found'),
    );

    final password = storage.getPasswordSync(server.id) ?? '';

    if (info.type == RemoteServerType.subsonic) {
      final client = SubsonicClient(server: server, password: password);
      final streamUrl = client.buildStreamUrl(
        info.trackIdOrPath,
        maxBitRate: maxBitRate ?? server.maxBitRate,
      );

      return proxy.buildProxyUrl(
        remoteUrl: streamUrl,
        serverId: server.id,
        trackId: info.trackIdOrPath,
      );
    } else {
      final client = WebDavClient(server: server, password: password);
      final fullUrl = client.buildFullUrl(info.trackIdOrPath);

      return proxy.buildProxyUrl(
        remoteUrl: fullUrl,
        headers: client.authHeaders,
        serverId: server.id,
        trackId: info.trackIdOrPath,
      );
    }
  }

  /// Resolves a remote virtual URI into a playable local proxy stream URL.
  Future<String> resolvePlayableUrl(String remoteUri, {int? maxBitRate}) async {
    final info = parseUri(remoteUri);
    if (info == null) {
      return remoteUri;
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

      return proxy.buildProxyUrl(
        remoteUrl: streamUrl,
        serverId: server.id,
        trackId: info.trackIdOrPath,
      );
    } else {
      final client = WebDavClient(server: server, password: password);
      final fullUrl = client.buildFullUrl(info.trackIdOrPath);

      return proxy.buildProxyUrl(
        remoteUrl: fullUrl,
        headers: client.authHeaders,
        serverId: server.id,
        trackId: info.trackIdOrPath,
      );
    }
  }

  /// Resolves a remote virtual URI into a local cached audio file path (downloading if necessary).
  Future<String> resolvePlayableLocalPath(String remoteUri, {int? maxBitRate}) async {
    final info = parseUri(remoteUri);
    if (info == null) {
      return remoteUri;
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

      final cached = await proxy.cacheManager.ensureTrackCached(
        serverId: server.id,
        trackIdOrPath: info.trackIdOrPath,
        remoteUrl: streamUrl,
      );
      return cached.path;
    } else {
      final client = WebDavClient(server: server, password: password);
      final fullUrl = client.buildFullUrl(info.trackIdOrPath);

      final cached = await proxy.cacheManager.ensureTrackCached(
        serverId: server.id,
        trackIdOrPath: info.trackIdOrPath,
        remoteUrl: fullUrl,
        headers: client.authHeaders,
      );
      return cached.path;
    }
  }

  /// Synchronously returns the deterministic local cache file path for a remote URI.
  String resolvePlayableLocalPathSync(String remoteUri) {
    final info = parseUri(remoteUri);
    if (info == null) return remoteUri;

    final dir = proxy.cacheManager.cacheDirectorySync;
    final serverDir = p.join(dir.path, info.serverId);
    final hash = md5.convert(utf8.encode(info.trackIdOrPath)).toString();
    return p.join(serverDir, '$hash.cache');
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
    RemoteServer server,
  ) {
    final uri = buildWebDavUri(server.id, file.path);
    final title = p.basenameWithoutExtension(file.name);

    return MusicFile(
      path: uri,
      name: file.name,
      title: title,
      isMissing: false,
    );
  }

  /// Returns the artwork image URL if available for the given remote song.
  Future<String?> getArtworkUrl(MusicFile song, {int size = 400}) async {
    final info = parseUri(song.path);
    if (info == null) return null;

    final servers = storage.loadServers();
    final server = servers.firstWhereOrNull((s) => s.id == info.serverId);
    if (server == null) return null;
    final password = await storage.getPassword(server.id) ?? '';

    if (info.type == RemoteServerType.subsonic) {
      var coverId = song.artworkPath?.replaceFirst('subsonic-cover://', '') ?? info.trackIdOrPath;
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
}
