import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';
import '../remote_server_models.dart';

class WebDavFile {
  final String path;
  final String name;
  final bool isDirectory;
  final int contentLength;
  final DateTime? lastModified;
  final String? contentType;

  const WebDavFile({
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.contentLength,
    this.lastModified,
    this.contentType,
  });

  bool get isAudio {
    if (isDirectory) return false;
    final ext = p.extension(name).toLowerCase();
    return const {
      '.mp3',
      '.flac',
      '.wav',
      '.m4a',
      '.aac',
      '.ogg',
      '.opus',
      '.ape',
      '.wma',
      '.dsf',
      '.dff',
      '.alac',
    }.contains(ext);
  }

  bool get isImage {
    if (isDirectory) return false;
    final ext = p.extension(name).toLowerCase();
    return const {'.jpg', '.jpeg', '.png', '.webp'}.contains(ext);
  }

  bool get isLyric {
    if (isDirectory) return false;
    final ext = p.extension(name).toLowerCase();
    return ext == '.lrc';
  }
}

class WebDavClient {
  final RemoteServer server;
  final String password;
  late final Dio _dio;

  WebDavClient({
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
            headers: {'User-Agent': 'Vynody/1.19.0'},
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

  String get baseUrl {
    var raw = server.url.trim();
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      raw = 'http://$raw';
    }
    return raw.replaceAll(RegExp(r'/+$'), '');
  }

  String get basicAuthHeader {
    final credentials = '${server.username}:$password';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  Map<String, String> get authHeaders => {
        'Authorization': basicAuthHeader,
      };

  String buildFullUrl(String relativePath) {
    var path = relativePath.trim();
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return '$baseUrl$path';
  }

  /// Tests WebDAV connection with a Depth: 0 PROPFIND request.
  Future<ConnectionTestResult> testConnection() async {
    try {
      final targetPath = server.customPath?.trim().isNotEmpty == true
          ? server.customPath!
          : '/';
      final url = buildFullUrl(targetPath);

      final response = await _dio.request<String>(
        url,
        options: Options(
          method: 'PROPFIND',
          headers: {
            ...authHeaders,
            'Depth': '0',
            'Content-Type': 'application/xml; charset=utf-8',
          },
          responseType: ResponseType.plain,
        ),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 207) {
        return const ConnectionTestResult.success(
          message: 'WebDAV connected successfully',
          serverVersion: 'WebDAV (HTTP 207 Multi-Status)',
        );
      } else {
        return ConnectionTestResult.failure(
          'HTTP $statusCode: ${response.statusMessage ?? "Unexpected response"}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const ConnectionTestResult.failure(
          '401 Unauthorized: Invalid WebDAV username or password',
        );
      }
      if (e.response?.statusCode == 404) {
        return const ConnectionTestResult.failure(
          '404 Not Found: Specified WebDAV path does not exist',
        );
      }
      return ConnectionTestResult.failure(
        'Connection failed: ${e.message ?? e.toString()}',
      );
    } catch (e) {
      return ConnectionTestResult.failure('Error: $e');
    }
  }

  /// Lists files and directories inside the given path using PROPFIND (Depth: 1).
  Future<List<WebDavFile>> listFiles(String path) async {
    final url = buildFullUrl(path);
    final response = await _dio.request<String>(
      url,
      options: Options(
        method: 'PROPFIND',
        headers: {
          ...authHeaders,
          'Depth': '1',
          'Content-Type': 'application/xml; charset=utf-8',
        },
        responseType: ResponseType.plain,
      ),
    );

    final rawXml = response.data;
    if (rawXml == null || rawXml.isEmpty) return const [];

    return parsePropfindXml(rawXml, requestPath: path);
  }

  /// Parses PROPFIND Multi-Status XML response into a list of [WebDavFile].
  static List<WebDavFile> parsePropfindXml(String xmlString, {String? requestPath}) {
    final document = XmlDocument.parse(xmlString);
    final responseNodes = document.findAllElements('response', namespace: '*');
    final List<WebDavFile> results = [];

    // Normalize target requested path to compare against the first (parent) node
    final normalizedReq = requestPath != null
        ? Uri.decodeFull(requestPath).replaceAll(RegExp(r'/+$'), '')
        : null;

    for (final resp in responseNodes) {
      final hrefEl = resp.findElements('href', namespace: '*').firstOrNull;
      if (hrefEl == null) continue;

      var rawHref = hrefEl.innerText.trim();
      final decodedHref = Uri.decodeFull(rawHref);

      // Skip the container folder itself (parent) if Depth=1
      final normalizedHref = decodedHref.replaceAll(RegExp(r'/+$'), '');
      if (normalizedReq != null && (normalizedHref == normalizedReq || normalizedHref.endsWith(normalizedReq))) {
        // Double check if this is the root node
        if (responseNodes.length > 1 && results.isEmpty) {
          continue;
        }
      }

      final propStat = resp.findElements('propstat', namespace: '*').firstOrNull;
      final prop = propStat?.findElements('prop', namespace: '*').firstOrNull;

      bool isDirectory = false;
      int contentLength = 0;
      DateTime? lastModified;
      String? contentType;

      if (prop != null) {
        final resType = prop.findElements('resourcetype', namespace: '*').firstOrNull;
        if (resType != null && resType.findElements('collection', namespace: '*').isNotEmpty) {
          isDirectory = true;
        }

        final lenEl = prop.findElements('getcontentlength', namespace: '*').firstOrNull;
        if (lenEl != null) {
          contentLength = int.tryParse(lenEl.innerText.trim()) ?? 0;
        }

        final modEl = prop.findElements('getlastmodified', namespace: '*').firstOrNull;
        if (modEl != null) {
          try {
            lastModified = HttpDate.parse(modEl.innerText.trim());
          } catch (_) {}
        }

        final typeEl = prop.findElements('getcontenttype', namespace: '*').firstOrNull;
        if (typeEl != null) {
          contentType = typeEl.innerText.trim();
        }
      }

      var name = p.basename(normalizedHref);
      if (name.isEmpty) {
        name = normalizedHref;
      }

      results.add(
        WebDavFile(
          path: decodedHref,
          name: name,
          isDirectory: isDirectory,
          contentLength: contentLength,
          lastModified: lastModified,
          contentType: contentType,
        ),
      );
    }

    return results;
  }

  /// Downloads text content of a file (e.g. .lrc lyrics file).
  Future<String?> getFileContent(String relativeOrFullPath) async {
    try {
      final url = relativeOrFullPath.startsWith('http://') || relativeOrFullPath.startsWith('https://')
          ? relativeOrFullPath
          : buildFullUrl(relativeOrFullPath);

      final response = await _dio.get<String>(
        url,
        options: Options(
          headers: authHeaders,
          responseType: ResponseType.plain,
        ),
      );
      return response.data;
    } catch (_) {
      return null;
    }
  }
}

