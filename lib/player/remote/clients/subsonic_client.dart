import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../remote_server_models.dart';

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
  Map<String, String> _buildAuthParams() {
    final salt = _generateRandomSalt();
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

  static String _generateRandomSalt([int length = 12]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random.secure();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  /// Constructs a full endpoint URL with required query parameters.
  String buildUrl(String endpoint, [Map<String, dynamic>? query]) {
    final params = Map<String, dynamic>.from(_buildAuthParams());
    if (query != null) {
      params.addAll(query);
    }
    final queryString = params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}')
        .join('&');
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

  /// Tests the connection to the Subsonic/Navidrome server.
  Future<ConnectionTestResult> testConnection() async {
    try {
      final url = buildUrl('ping.view');
      final response = await _dio.get<Map<String, dynamic>>(url);
      final data = response.data;
      if (data == null) {
        return const ConnectionTestResult.failure('Empty response from server');
      }

      final subsonic = data['subsonic-response'];
      if (subsonic == null || subsonic is! Map<String, dynamic>) {
        return const ConnectionTestResult.failure('Invalid Subsonic API response');
      }

      if (subsonic['status'] == 'ok') {
        final version = subsonic['version'] as String? ?? 'Unknown';
        final serverVersion = subsonic['serverVersion'] as String?;
        final displayVer = serverVersion != null ? '$serverVersion (API v$version)' : 'API v$version';

        // Optionally fetch song count
        int? songCount;
        int? albumCount;
        try {
          final scanStatusUrl = buildUrl('getScanStatus.view');
          final scanRes = await _dio.get<Map<String, dynamic>>(scanStatusUrl);
          final scanData = scanRes.data?['subsonic-response']?['scanStatus'];
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
      } else {
        final error = subsonic['error'] as Map<String, dynamic>?;
        final errorMsg = error?['message'] as String? ?? 'Authentication failed';
        return ConnectionTestResult.failure(errorMsg);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 401) {
        return const ConnectionTestResult.failure('401 Unauthorized: Invalid username or password');
      }
      return ConnectionTestResult.failure('Connection failed: ${e.message ?? e.toString()}');
    } catch (e) {
      return ConnectionTestResult.failure('Error: $e');
    }
  }

  /// Fetches the list of artists.
  Future<List<Map<String, dynamic>>> getArtists() async {
    final url = buildUrl('getArtists.view');
    final response = await _dio.get<Map<String, dynamic>>(url);
    final artistsRoot = response.data?['subsonic-response']?['artists'];
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

  /// Fetches album list by type (e.g. 'recent', 'newest', 'frequent', 'alphabeticalByName', 'starred', 'random').
  Future<List<Map<String, dynamic>>> getAlbumList({
    String type = 'alphabeticalByName',
    int size = 500,
    int offset = 0,
  }) async {
    final url = buildUrl('getAlbumList2.view', {
      'type': type,
      'size': size,
      'offset': offset,
    });
    final response = await _dio.get<Map<String, dynamic>>(url);
    final subsonic = response.data?['subsonic-response'];
    final albumRoot = subsonic?['albumList2'] ?? subsonic?['albumList'];
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
    final url = buildUrl('getAlbum.view', {'id': albumId});
    final response = await _dio.get<Map<String, dynamic>>(url);
    final album = response.data?['subsonic-response']?['album'];
    if (album is Map<String, dynamic>) {
      return album;
    }
    return null;
  }

  /// Fetches all playlists.
  Future<List<Map<String, dynamic>>> getPlaylists() async {
    final url = buildUrl('getPlaylists.view');
    final response = await _dio.get<Map<String, dynamic>>(url);
    final playlists = response.data?['subsonic-response']?['playlists']?['playlist'] as List?;
    if (playlists != null) {
      return playlists.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  /// Searches across songs, albums, and artists.
  Future<Map<String, dynamic>> search(String query, {int artistCount = 20, int albumCount = 20, int songCount = 50}) async {
    final url = buildUrl('search3.view', {
      'query': query,
      'artistCount': artistCount,
      'albumCount': albumCount,
      'songCount': songCount,
    });
    final response = await _dio.get<Map<String, dynamic>>(url);
    final searchResult = response.data?['subsonic-response']?['searchResult3'];
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
          final url = buildUrl('getLyricsBySongId.view', {'id': id});
          final response = await _dio.get<Map<String, dynamic>>(url);
          final lyricsList = response.data?['subsonic-response']?['lyricsList']?['structuredLyrics'] as List?;
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
                    final minutes = (start ~/ 60000).toString().padLeft(2, '0');
                    final seconds = ((start % 60000) ~/ 1000).toString().padLeft(2, '0');
                    final millis = ((start % 1000) ~/ 10).toString().padLeft(2, '0');
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
        final url = buildUrl('getLyrics.view', params);
        final response = await _dio.get<Map<String, dynamic>>(url);
        final lyrics = response.data?['subsonic-response']?['lyrics'];
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
}

