import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'remote_stream_cache_manager.dart';


class LocalStreamCacheProxy {
  final RemoteStreamCacheManager cacheManager;
  HttpServer? _server;
  int? _port;
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 10),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.stream,
      followRedirects: true,
      validateStatus: (status) => status != null && status >= 200 && status < 400,
    ),
  );

  LocalStreamCacheProxy({RemoteStreamCacheManager? cacheManager})
      : cacheManager = cacheManager ?? RemoteStreamCacheManager();

  int? get port => _port;
  bool get isRunning => _server != null;

  /// Starts the local HTTP proxy server on a random loopback port.
  Future<int> start() async {
    if (_server != null) {
      return _port!;
    }
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _port = _server!.port;
    _server!.listen(_handleRequest, onError: (e) {
      debugPrint('[LocalStreamCacheProxy] Server error: $e');
    });
    debugPrint('[LocalStreamCacheProxy] Started listening on 127.0.0.1:$_port');
    return _port!;
  }

  /// Stops the proxy server.
  Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      _port = null;
      debugPrint('[LocalStreamCacheProxy] Proxy stopped.');
    }
  }

  /// Builds a playable local proxy URL for a remote audio stream.
  String buildProxyUrl({
    required String remoteUrl,
    Map<String, String>? headers,
    String? serverId,
    String? trackId,
  }) {
    if (_port == null) {
      throw StateError('Proxy server is not started yet. Call start() first.');
    }
    final uri = Uri(
      scheme: 'http',
      host: '127.0.0.1',
      port: _port,
      path: '/stream',
      queryParameters: {
        'url': remoteUrl,
        if (headers != null && headers.isNotEmpty)
          'headers': Uri.encodeComponent(
            headers.entries.map((e) => '${e.key}:${e.value}').join('||'),
          ),
        ...?serverId != null ? {'serverId': serverId} : null,
        ...?trackId != null ? {'trackId': trackId} : null,
      },

    );
    return uri.toString();
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final path = request.uri.path;
    if (path == '/ping' || path == '/health') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write('OK')
        ..close();
      return;
    }

    if (path != '/stream') {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Found')
        ..close();
      return;
    }

    final targetUrl = request.uri.queryParameters['url'];
    if (targetUrl == null || targetUrl.isEmpty) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Missing "url" query parameter')
        ..close();
      return;
    }

    final rawHeaders = request.uri.queryParameters['headers'];
    final upstreamHeaders = <String, String>{};
    if (rawHeaders != null && rawHeaders.isNotEmpty) {
      final decoded = Uri.decodeComponent(rawHeaders);
      for (final part in decoded.split('||')) {
        final idx = part.indexOf(':');
        if (idx > 0) {
          final k = part.substring(0, idx).trim();
          final v = part.substring(idx + 1).trim();
          upstreamHeaders[k] = v;
        }
      }
    }

    final serverId = request.uri.queryParameters['serverId'] ?? 'default';
    final trackId = request.uri.queryParameters['trackId'] ?? targetUrl;

    try {
      // Check if file is already fully cached
      final isCached = await cacheManager.isTrackCached(
        serverId: serverId,
        trackIdOrPath: trackId,
      );

      if (isCached) {
        final file = await cacheManager.getCacheFile(
          serverId: serverId,
          trackIdOrPath: trackId,
        );
        await _serveLocalFile(request, file);
        return;
      }

      await _proxyUpstreamRequest(request, targetUrl, upstreamHeaders, serverId, trackId);
    } catch (e, stack) {
      debugPrint('[LocalStreamCacheProxy] Error handling stream request: $e\n$stack');
      try {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Proxy Error: $e')
          ..close();
      } catch (_) {}
    }
  }

  Future<void> _serveLocalFile(HttpRequest request, File file) async {
    await cacheManager.touchCacheFile(file);
    final totalLength = await file.length();
    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);

    request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    request.response.headers.set(HttpHeaders.contentTypeHeader, 'audio/mpeg');

    if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
      final rangeStr = rangeHeader.substring(6).trim();
      final parts = rangeStr.split('-');
      final start = int.tryParse(parts[0]) ?? 0;
      final end = parts.length > 1 && parts[1].isNotEmpty
          ? (int.tryParse(parts[1]) ?? totalLength - 1)
          : totalLength - 1;

      final boundedStart = start.clamp(0, totalLength - 1);
      final boundedEnd = end.clamp(boundedStart, totalLength - 1);
      final contentLength = boundedEnd - boundedStart + 1;

      request.response.statusCode = HttpStatus.partialContent;
      request.response.headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes $boundedStart-$boundedEnd/$totalLength',
      );
      request.response.headers.set(
        HttpHeaders.contentLengthHeader,
        contentLength,
      );

      final stream = file.openRead(boundedStart, boundedEnd + 1);
      await request.response.addStream(stream);
      await request.response.close();
    } else {
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.set(HttpHeaders.contentLengthHeader, totalLength);
      await request.response.addStream(file.openRead());
      await request.response.close();
    }
  }

  Future<void> _proxyUpstreamRequest(
    HttpRequest request,
    String targetUrl,
    Map<String, String> upstreamHeaders,
    String serverId,
    String trackId,
  ) async {
    final clientRangeHeader = request.headers.value(HttpHeaders.rangeHeader);
    final reqHeaders = Map<String, dynamic>.from(upstreamHeaders);

    if (clientRangeHeader != null) {
      reqHeaders[HttpHeaders.rangeHeader] = clientRangeHeader;
    }

    final safeUrl = targetUrl.contains(' ') || targetUrl.contains('[') || targetUrl.contains(']')
        ? Uri.encodeFull(targetUrl)
        : targetUrl;

    try {
      final response = await _dio.get<ResponseBody>(
        safeUrl,
        options: Options(
          headers: reqHeaders,
          responseType: ResponseType.stream,
          followRedirects: true,
        ),
      );

      final statusCode = response.statusCode ?? 200;
      request.response.statusCode = statusCode;

      // Forward relevant headers to the audio player
      for (final header in [
        HttpHeaders.contentTypeHeader,
        HttpHeaders.contentLengthHeader,
        HttpHeaders.contentRangeHeader,
        HttpHeaders.acceptRangesHeader,
      ]) {
        final val = response.headers.value(header);
        if (val != null) {
          request.response.headers.set(header, val);
        }
      }

      if (request.response.headers.value(HttpHeaders.acceptRangesHeader) == null) {
        request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      }

      final stream = response.data?.stream;
      if (stream != null) {
        try {
          await request.response.addStream(stream);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[LocalStreamCacheProxy] Proxy upstream request failed: $e');
      try {
        request.response.statusCode = HttpStatus.badGateway;
      } catch (_) {}
    }

    try {
      await request.response.close();
    } catch (_) {}
  }
}
