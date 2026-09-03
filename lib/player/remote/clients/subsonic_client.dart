import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../remote_server_models.dart';

class SubsonicException implements Exception {
  final String message;
  final int? code;
  const SubsonicException(this.message, {this.code});

  @override
  String toString() => message;
}

class SubsonicClient {
  static const String clientName = 'Vynody';
  static const String apiVersion = '1.16.1';

  final RemoteServer server;
  final String password;
  late final Dio _dio;

  SubsonicClient({
    required this.server,
    required this.password,
    Dio? customDio,
  }) {
    _dio = customDio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
            headers: {'User-Agent': 'Vynody/$apiVersion'},
          ),
        );

    if (server.ignoreSsl && customDio == null) {
      final adapter = _dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        };
      }
    }
  }

  /// Normalizes base URL (e.g. removes trailing slash and /rest).
  String get baseUrl {
    var raw = server.url.trim();
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      raw = 'http://$raw';
    }
    raw = raw.replaceAll(RegExp(r'/+$'), '');
    if (raw.endsWith('/rest')) {
      raw = raw.substring(0, raw.length - 5);
    }
    return raw;
  }

  /// Generates Subsonic authentication parameters (token + salt).
  /// Uses a deterministic salt based on server and username so generated media and cover URLs
  /// remain stable across widget builds and scrolls, enabling Flutter ImageCache and HTTP caching.
  Map<String, String> _buildAuthParams() {
    final salt = md5
        .convert(utf8.encode('vynody_${server.id}_${server.username}'))
        .toString()
        .substring(0, 12);
    final token = md5.convert(utf8.encode(password + salt)).toString();

    return {
      'u': server.username,
      't': token,
      's': salt,
      'v': apiVersion,
      'c': clientName,
      'f': 'json',
    };
  }

  /// Constructs a full endpoint URL with required query parameters.
  String buildUrl(String endpoint, [Map<String, dynamic>? query]) {
    final params = Map<String, dynamic>.from(_buildAuthParams());
    if (query != null) {
      params.addAll(query);
    }
    final queryParts = <String>[];
    for (final entry in params.entries) {
      final key = entry.key;
      final val = entry.value;
      if (val is Iterable) {
        for (final item in val) {
          queryParts.add(
            '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(item.toString())}',
          );
        }
      } else if (val != null) {
        queryParts.add(
          '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(val.toString())}',
        );
      }
    }
    final queryString = queryParts.join('&');
    return '$baseUrl/rest/$endpoint?$queryString';
  }

  /// Constructs stream URL for a given track id.
  String buildStreamUrl(String trackId, {int? maxBitRate}) {
    final params = <String, dynamic>{'id': trackId};
    final bitRate = maxBitRate ?? server.maxBitRate;
    if (bitRate != null && bitRate > 0) {
      params['maxBitRate'] = bitRate;
    }
    return buildUrl('stream', params);
  }

  /// Constructs cover art URL for a given cover ID or track ID.
  String buildCoverArtUrl(String coverArtId, {int size = 300}) {
    return buildUrl('getCoverArt', {'id': coverArtId, 'size': size});
  }

  /// Fetches raw cover art bytes. Returns null if cover art is missing, server returns an error, or content is not an image.
  Future<Uint8List?> getCoverArtBytes(String coverArtId, {int size = 300}) async {
    try {
      final url = buildCoverArtUrl(coverArtId, size: size);
      final res = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = res.data;
      if (data == null || data.isEmpty) return null;

      final contentType = res.headers.value('content-type')?.toLowerCase() ?? '';
      if (contentType.contains('json') ||
          contentType.contains('xml') ||
          contentType.contains('text') ||
          contentType.contains('html')) {
        return null;
      }

      final bytes = Uint8List.fromList(data);
      if (!_isValidImage(bytes)) {
        return null;
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  static bool _isValidImage(Uint8List bytes) {
    if (bytes.length < 4) return false;
    final first = bytes[0];
    // Reject common textual responses: '{' (JSON), '<' (XML/HTML), '[' (JSON Array)
    if (first == 0x7B || first == 0x3C || first == 0x5B) return false;

    // JPEG (FF D8)
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
    // PNG (89 50 4E 47)
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
    // GIF (GIF87a / GIF89a: 47 49 46)
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
    // WebP (RIFF .... WEBP)
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
        bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
      return true;
    }
    // BMP (BM: 42 4D)
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) return true;

    return false;
  }

  Future<Map<String, dynamic>> _getSubsonicData(
    String endpoint, [
    Map<String, dynamic>? params,
  ]) async {
    try {
      final url = buildUrl(endpoint, params);
      final response = await _dio.get<dynamic>(url);
      final data = response.data;
      if (data == null) {
        throw const SubsonicException('Empty response from server');
      }
      Map<String, dynamic>? subsonic;
      if (data is Map<String, dynamic>) {
        final sub = data['subsonic-response'];
        if (sub is Map<String, dynamic>) {
          subsonic = sub;
        }
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            final sub = decoded['subsonic-response'];
            if (sub is Map<String, dynamic>) {
              subsonic = sub;
            }
          }
        } catch (_) {}
      }

      if (subsonic == null) {
        throw const SubsonicException('Invalid Subsonic API response');
      }

      final status = subsonic['status'] as String?;
      if (status != 'ok') {
        final error = subsonic['error'] as Map<String, dynamic>?;
        final errorMsg =
            error?['message'] as String? ?? 'Subsonic request failed';
        final code = error?['code'] as int?;
        throw SubsonicException(errorMsg, code: code);
      }
      return subsonic;
    } on DioException catch (e) {
      if (e.response != null) {
        final respData = e.response!.data;
        if (respData is Map<String, dynamic>) {
          final subError = respData['subsonic-response']?['error'];
          if (subError is Map<String, dynamic>) {
            final msg = subError['message'] as String?;
            final code = subError['code'] as int?;
            if (msg != null && msg.isNotEmpty) {
              throw SubsonicException(msg, code: code);
            }
          }
        }
        if (e.response!.statusCode == 401) {
          throw const SubsonicException(
            '401 Unauthorized: Invalid username or password',
          );
        }
        final status = e.response!.statusCode;
        final statusText = e.response!.statusMessage ?? '';
        throw SubsonicException('HTTP $status $statusText'.trim());
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const SubsonicException('Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        final msg = e.error?.toString() ?? e.message;
        throw SubsonicException(
          msg != null && msg.isNotEmpty ? msg : 'Connection error',
        );
      }
      throw SubsonicException(e.message ?? e.toString());
    }
  }

  /// Tests the connection to the Subsonic/Navidrome server.
  Future<ConnectionTestResult> testConnection() async {
    try {
      final subsonic = await _getSubsonicData('ping.view');
      final version = subsonic['version'] as String? ?? 'Unknown';
      final serverVersion = subsonic['serverVersion'] as String?;
      final displayVer = serverVersion != null
          ? '$serverVersion (API v$version)'
          : 'API v$version';

      int? songCount;
      int? albumCount;
      try {
        final scanRes = await _getSubsonicData('getScanStatus.view');
        final scanData = scanRes['scanStatus'];
        if (scanData is Map<String, dynamic>) {
          songCount = scanData['count'] as int?;
        }
      } catch (_) {}

      return ConnectionTestResult.success(
        message: 'Connected successfully',
        serverVersion: displayVer,
        songCount: songCount,
        albumCount: albumCount,
      );
    } on SubsonicException catch (e) {
      return ConnectionTestResult.failure(e.message);
    } catch (e) {
      return ConnectionTestResult.failure('Error: $e');
    }
  }

  /// Fetches the list of artists.
  Future<List<Map<String, dynamic>>> getArtists() async {
    final subsonic = await _getSubsonicData('getArtists.view');
    final artistsRoot = subsonic['artists'];
    if (artistsRoot is Map<String, dynamic>) {
      final indexList = artistsRoot['index'] as List?;
      if (indexList != null) {
        final List<Map<String, dynamic>> allArtists = [];
        for (final index in indexList) {
          final artistList = index['artist'] as List?;
          if (artistList != null) {
            allArtists.addAll(artistList.whereType<Map<String, dynamic>>());
          }
        }
        return allArtists;
      }
    }
    return const [];
  }

  /// Fetches an artist's details including their albums and songs.
  Future<Map<String, dynamic>?> getArtist(String artistId) async {
    final subsonic = await _getSubsonicData('getArtist.view', {'id': artistId});
    final artist = subsonic['artist'];
    if (artist is Map<String, dynamic>) {
      return artist;
    }
    return null;
  }

  /// Fetches extended artist information (biography, etc.) if supported.
  Future<Map<String, dynamic>?> getArtistInfo(String artistId) async {
    try {
      final subsonic =
          await _getSubsonicData('getArtistInfo2.view', {'id': artistId});
      final info = subsonic['artistInfo2'] ?? subsonic['artistInfo'];
      if (info is Map<String, dynamic>) {
        return info;
      }
    } catch (_) {
      try {
        final subsonic =
            await _getSubsonicData('getArtistInfo.view', {'id': artistId});
        final info = subsonic['artistInfo'] ?? subsonic['artistInfo2'];
        if (info is Map<String, dynamic>) {
          return info;
        }
      } catch (_) {}
    }
    return null;
  }

  /// Fetches album list by type (e.g. 'recent', 'newest', 'frequent', 'alphabeticalByName', 'starred', 'random').
  Future<List<Map<String, dynamic>>> getAlbumList({
    String type = 'alphabeticalByName',
    int size = 500,
    int offset = 0,
  }) async {
    final subsonic = await _getSubsonicData('getAlbumList2.view', {
      'type': type,
      'size': size,
      'offset': offset,
    });
    final albumRoot = subsonic['albumList2'] ?? subsonic['albumList'];
    final albumData = albumRoot?['album'];
    if (albumData is List) {
      return albumData.whereType<Map<String, dynamic>>().toList();
    } else if (albumData is Map<String, dynamic>) {
      return [albumData];
    }
    return const [];
  }

  /// Fetches details for an album including its songs.
  Future<Map<String, dynamic>?> getAlbum(String albumId) async {
    final subsonic = await _getSubsonicData('getAlbum.view', {'id': albumId});
    final album = subsonic['album'];
    if (album is Map<String, dynamic>) {
      return album;
    }
    return null;
  }

  /// Fetches details for a single song by ID.
  Future<Map<String, dynamic>?> getSong(String songId) async {
    try {
      final subsonic = await _getSubsonicData('getSong.view', {'id': songId});
      final song = subsonic['song'];
      if (song is Map<String, dynamic>) {
        return song;
      }
    } catch (_) {}
    return null;
  }

  /// Fetches all playlists.
  Future<List<Map<String, dynamic>>> getPlaylists() async {
    final subsonic = await _getSubsonicData('getPlaylists.view');
    final playlists = subsonic['playlists']?['playlist'] as List?;
    if (playlists != null) {
      return playlists.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  /// Fetches details for a playlist including its songs.
  Future<Map<String, dynamic>?> getPlaylist(String playlistId) async {
    final subsonic =
        await _getSubsonicData('getPlaylist.view', {'id': playlistId});
    final playlist = subsonic['playlist'];
    if (playlist is Map<String, dynamic>) {
      return playlist;
    }
    return null;
  }

  /// Fetches starred items (artists, albums, songs) using Subsonic getStarred2.view.
  Future<Map<String, dynamic>> getStarred2({String? musicFolderId}) async {
    final params = <String, dynamic>{};
    if (musicFolderId != null) params['musicFolderId'] = musicFolderId;
    try {
      final subsonic = await _getSubsonicData('getStarred2.view', params);
      final root = subsonic['starred2'] ?? subsonic['starred'];
      if (root is Map<String, dynamic>) {
        return root;
      }
    } catch (_) {
      try {
        final subsonic = await _getSubsonicData('getStarred.view', params);
        final root = subsonic['starred'] ?? subsonic['starred2'];
        if (root is Map<String, dynamic>) {
          return root;
        }
      } catch (_) {}
    }
    return const {};
  }

  /// Fetches starred songs as a list of map entries.
  Future<List<Map<String, dynamic>>> getStarredSongs() async {
    final starred = await getStarred2();
    final songs = starred['song'];
    if (songs is List) {
      return songs.whereType<Map<String, dynamic>>().toList();
    } else if (songs is Map<String, dynamic>) {
      return [songs];
    }
    return const [];
  }

  /// Fetches starred artists as a list of map entries.
  Future<List<Map<String, dynamic>>> getStarredArtists() async {
    final starred = await getStarred2();
    final artists = starred['artist'];
    if (artists is List) {
      return artists.whereType<Map<String, dynamic>>().toList();
    } else if (artists is Map<String, dynamic>) {
      return [artists];
    }
    return const [];
  }

  /// Searches across songs, albums, and artists.
  Future<Map<String, dynamic>> search(String query,
      {int artistCount = 20, int albumCount = 20, int songCount = 50}) async {
    final subsonic = await _getSubsonicData('search3.view', {
      'query': query,
      'artistCount': artistCount,
      'albumCount': albumCount,
      'songCount': songCount,
    });
    final searchResult = subsonic['searchResult3'];
    if (searchResult is Map<String, dynamic>) {
      return searchResult;
    }
    return const {};
  }

  /// Fetches lyrics for a song (by artist & title or id).
  Future<String?> getLyrics({String? artist, String? title, String? id}) async {
    try {
      // 1. Try OpenSubsonic getLyricsBySongId if ID is provided
      if (id != null && id.isNotEmpty) {
        try {
          final subsonic =
              await _getSubsonicData('getLyricsBySongId.view', {'id': id});
          final lyricsList =
              subsonic['lyricsList']?['structuredLyrics'] as List?;
          if (lyricsList != null && lyricsList.isNotEmpty) {
            final first = lyricsList.first;
            if (first is Map<String, dynamic>) {
              // Check for synced or plain lyrics
              final lineList = first['line'] as List?;
              if (lineList != null && lineList.isNotEmpty) {
                // Construct synced LRC format
                final buffer = StringBuffer();
                for (final line in lineList) {
                  if (line is Map<String, dynamic>) {
                    final start = line['start'] as int? ?? 0;
                    final text = line['value'] as String? ?? '';
                    final minutes =
                        (start ~/ 60000).toString().padLeft(2, '0');
                    final seconds =
                        ((start % 60000) ~/ 1000).toString().padLeft(2, '0');
                    final millis =
                        ((start % 1000) ~/ 10).toString().padLeft(2, '0');
                    buffer.writeln('[$minutes:$seconds.$millis]$text');
                  }
                }
                return buffer.toString();
              }
            }
          }
        } catch (_) {}
      }

      // 2. Standard Subsonic getLyrics.view with artist and title
      if (artist != null || title != null) {
        final params = <String, dynamic>{};
        if (artist != null) params['artist'] = artist;
        if (title != null) params['title'] = title;
        final subsonic = await _getSubsonicData('getLyrics.view', params);
        final lyrics = subsonic['lyrics'];
        if (lyrics is Map<String, dynamic>) {
          final content = lyrics['content'] as String?;
          if (content != null && content.trim().isNotEmpty) {
            return content.trim();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Creates a new playlist on the Subsonic server.
  Future<Map<String, dynamic>?> createPlaylist({
    required String name,
    List<String>? songIds,
  }) async {
    final params = <String, dynamic>{'name': name};
    if (songIds != null && songIds.isNotEmpty) {
      params['songId'] = songIds;
    }
    final subsonic = await _getSubsonicData('createPlaylist.view', params);
    final playlist = subsonic['playlist'];
    if (playlist is Map<String, dynamic>) {
      return playlist;
    }
    return null;
  }

  /// Updates an existing playlist on the Subsonic server (adding/removing songs).
  Future<bool> updatePlaylist({
    required String playlistId,
    List<String>? songIdsToAdd,
    List<int>? songIndexesToRemove,
    String? name,
    String? comment,
    bool? isPublic,
  }) async {
    final params = <String, dynamic>{'playlistId': playlistId};
    if (name != null) params['name'] = name;
    if (comment != null) params['comment'] = comment;
    if (isPublic != null) params['public'] = isPublic;
    if (songIdsToAdd != null && songIdsToAdd.isNotEmpty) {
      params['songIdToAdd'] = songIdsToAdd;
    }
    if (songIndexesToRemove != null && songIndexesToRemove.isNotEmpty) {
      params['songIndexToRemove'] = songIndexesToRemove;
    }
    final subsonic = await _getSubsonicData('updatePlaylist.view', params);
    final status = subsonic['status'];
    return status == 'ok';
  }

  /// Deletes a playlist on the Subsonic server.
  Future<bool> deletePlaylist(String playlistId) async {
    final subsonic =
        await _getSubsonicData('deletePlaylist.view', {'id': playlistId});
    final status = subsonic['status'];
    return status == 'ok';
  }

  /// Stars (favorites) a song, album, or artist on the Subsonic server.
  Future<bool> star({
    String? id,
    String? albumId,
    String? artistId,
  }) async {
    final params = <String, dynamic>{};
    if (id != null) params['id'] = id;
    if (albumId != null) params['albumId'] = albumId;
    if (artistId != null) params['artistId'] = artistId;
    if (params.isEmpty) return false;

    try {
      final subsonic = await _getSubsonicData('star.view', params);
      final status = subsonic['status'];
      return status == 'ok';
    } catch (_) {
      return false;
    }
  }

  /// Unstars (removes from favorites) a song, album, or artist on the Subsonic server.
  Future<bool> unstar({
    String? id,
    String? albumId,
    String? artistId,
  }) async {
    final params = <String, dynamic>{};
    if (id != null) params['id'] = id;
    if (albumId != null) params['albumId'] = albumId;
    if (artistId != null) params['artistId'] = artistId;
    if (params.isEmpty) return false;

    try {
      final subsonic = await _getSubsonicData('unstar.view', params);
      final status = subsonic['status'];
      return status == 'ok';
    } catch (_) {
      return false;
    }
  }

  /// Constructs the direct download URL for a track.
  String buildDownloadUrl(String trackId) {
    return buildUrl('download.view', {'id': trackId});
  }
}

