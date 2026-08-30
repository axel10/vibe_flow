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
      '.webm',
      '.aif',
      '.aiff',
      '.caf',
      '.m4b',
      '.m4p',
      '.mid',
      '.midi',
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

  static String safeEncodeUrl(String url) {
    if (url.contains(' ') || url.contains('[') || url.contains(']') || url.contains('{') || url.contains('}')) {
      try {
        return Uri.encodeFull(url);
      } catch (_) {}
    }
    return url;
  }

  String buildStreamUrl(String relativePath) {
    return buildFullUrl(relativePath, includeAuth: true);
  }

  String buildFullUrl(String relativePath, {bool includeAuth = false}) {
    var path = relativePath.trim();
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    final parsedBase = Uri.tryParse(baseUrl) ?? Uri.tryParse(Uri.encodeFull(baseUrl));
    if (parsedBase != null) {
      final authPrefix = includeAuth && server.username.isNotEmpty
          ? '${Uri.encodeComponent(server.username)}${password.isNotEmpty ? ':${Uri.encodeComponent(password)}' : ''}@'
          : '';
      final origin =
          '${parsedBase.scheme}://$authPrefix${parsedBase.host}${parsedBase.hasPort ? ':${parsedBase.port}' : ''}';
      if (parsedBase.path.isNotEmpty && parsedBase.path != '/') {
        final basePath = parsedBase.path.replaceAll(RegExp(r'/+$'), '');
        if (path == basePath || path.startsWith('$basePath/')) {
          return '$origin$path';
        }
        return '$origin$basePath$path';
      }
      return '$origin$path';
    }
    return '$baseUrl$path';
  }

  /// Attempts a PROPFIND Depth: 0 request against a specific path.
  Future<int?> _probePath(String path) async {
    try {
      final url = safeEncodeUrl(buildFullUrl(path));
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
          validateStatus: (status) => status != null,
        ),
      );
      return response.statusCode;
    } catch (_) {
      return null;
    }
  }

  /// Tests WebDAV connection with a Depth: 0 PROPFIND request and auto-detection fallback.
  Future<ConnectionTestResult> testConnection() async {
    final customPath = server.customPath?.trim();
    final hasExplicitCustomPath =
        customPath != null && customPath.isNotEmpty && customPath != '/';
    final initialPath = hasExplicitCustomPath ? customPath : '/';

    try {
      final url = safeEncodeUrl(buildFullUrl(initialPath));

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
        return ConnectionTestResult.success(
          message: 'WebDAV connected successfully',
          serverVersion: 'WebDAV (HTTP 207 Multi-Status)',
          detectedCustomPath: hasExplicitCustomPath ? customPath : null,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return const ConnectionTestResult.failure(
          '401 Unauthorized: Invalid WebDAV username or password',
        );
      }

      // If root path or 404/405 error, probe fallback paths (e.g. AList /dav, NAS /webdav)
      if (!hasExplicitCustomPath || statusCode == 404 || statusCode == 405) {
        const candidatePaths = ['/dav', '/webdav', '/remote.php/webdav'];
        for (final candidate in candidatePaths) {
          if (candidate == initialPath) continue;
          final probeStatus = await _probePath(candidate);
          if (probeStatus == 200 || probeStatus == 207) {
            return ConnectionTestResult.success(
              message:
                  'WebDAV connected successfully (Auto-detected: $candidate)',
              serverVersion: 'WebDAV (Auto-detected: $candidate)',
              detectedCustomPath: candidate,
            );
          }
        }
      }

      if (statusCode == 405) {
        return const ConnectionTestResult.failure(
          '405 Method Not Allowed: The root path does not support WebDAV. If using AList, try setting path to /dav.',
        );
      }
      if (statusCode == 404) {
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

    return const ConnectionTestResult.failure(
      'Unable to connect to WebDAV server',
    );
  }

  /// Lists files and directories inside the given path using PROPFIND (Depth: 1).
  Future<List<WebDavFile>> listFiles(String path) async {
    try {
      final url = safeEncodeUrl(buildFullUrl(path));
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
    } on DioException catch (e) {
      // If root path was requested and returned 405/404, try /dav fallback
      if (path == '/' &&
          (e.response?.statusCode == 405 || e.response?.statusCode == 404)) {
        final fallbackUrl = safeEncodeUrl(buildFullUrl('/dav'));
        final response = await _dio.request<String>(
          fallbackUrl,
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
        if (rawXml != null && rawXml.isNotEmpty) {
          return parsePropfindXml(rawXml, requestPath: '/dav');
        }
      }
      rethrow;
    }
  }

  /// Parses PROPFIND Multi-Status XML response into a list of [WebDavFile].
  static List<WebDavFile> parsePropfindXml(String xmlString, {String? requestPath}) {
    final document = XmlDocument.parse(xmlString);
    final responseNodes = document.findAllElements('response', namespace: '*').toList();
    final List<WebDavFile> results = [];

    // Normalize target requested path (e.g. '/dav' or '/dav/test')
    String? cleanReqPath;
    if (requestPath != null && requestPath.trim().isNotEmpty) {
      var pStr = requestPath.trim();
      try {
        pStr = Uri.decodeFull(pStr).trim();
      } catch (_) {}
      final schemeIdx = pStr.indexOf('://');
      if (schemeIdx > 0) {
        final pathStart = pStr.indexOf('/', schemeIdx + 3);
        pStr = pathStart >= 0 ? pStr.substring(pathStart) : '/';
      }
      pStr = pStr.replaceAll(RegExp(r'/+$'), '');
      if (pStr.isNotEmpty) {
        cleanReqPath = pStr.startsWith('/') ? pStr : '/$pStr';
      }
    }

    for (int i = 0; i < responseNodes.length; i++) {
      final resp = responseNodes[i];
      final hrefEl = resp.findElements('href', namespace: '*').firstOrNull;
      if (hrefEl == null) continue;

      var rawHref = hrefEl.innerText.trim();
      var decodedHref = rawHref;
      try {
        decodedHref = Uri.decodeFull(rawHref);
      } catch (_) {}

      var cleanHref = decodedHref;
      final schemeIdx = cleanHref.indexOf('://');
      if (schemeIdx > 0) {
        final pathStart = cleanHref.indexOf('/', schemeIdx + 3);
        cleanHref = pathStart >= 0 ? cleanHref.substring(pathStart) : '/';
      }
      cleanHref = cleanHref.replaceAll(RegExp(r'/+$'), '');
      if (!cleanHref.startsWith('/')) {
        cleanHref = '/$cleanHref';
      }

      // Skip the container folder itself (parent) in Depth: 1 PROPFIND
      if (responseNodes.length > 1 && i == 0) {
        // RFC 4918: First response node in Depth:1 response is always the target container
        continue;
      }
      if (cleanReqPath != null && cleanHref == cleanReqPath) {
        continue;
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

      var name = p.basename(cleanHref);
      if (name.isEmpty) {
        name = cleanHref;
      }

      results.add(
        WebDavFile(
          path: cleanHref.isEmpty ? '/' : cleanHref,
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
      final rawUrl = relativeOrFullPath.startsWith('http://') || relativeOrFullPath.startsWith('https://')
          ? relativeOrFullPath
          : buildFullUrl(relativeOrFullPath);
      final url = safeEncodeUrl(rawUrl);

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

