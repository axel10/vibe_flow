import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/remote/proxy/local_stream_cache_proxy.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  late LocalStreamCacheProxy proxy;
  late HttpServer mockUpstreamServer;
  late int mockPort;


  setUp(() async {
    // 1. Create a mock upstream audio server
    mockUpstreamServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    mockPort = mockUpstreamServer.port;
    mockUpstreamServer.listen((request) async {
      final data = Uint8List.fromList(List.generate(1000, (i) => i % 256));
      final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);

      if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
        final rangeStr = rangeHeader.substring(6);
        final parts = rangeStr.split('-');
        final start = int.parse(parts[0]);
        final end = parts.length > 1 && parts[1].isNotEmpty
            ? int.parse(parts[1])
            : data.length - 1;
        final sub = data.sublist(start, end + 1);

        request.response.statusCode = HttpStatus.partialContent;
        request.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$end/${data.length}',
        );
        request.response.headers.set(HttpHeaders.contentLengthHeader, sub.length);
        request.response.headers.set(HttpHeaders.contentTypeHeader, 'audio/mpeg');
        request.response.add(sub);
        await request.response.close();
      } else {
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.set(HttpHeaders.contentLengthHeader, data.length);
        request.response.headers.set(HttpHeaders.contentTypeHeader, 'audio/mpeg');
        request.response.add(data);
        await request.response.close();
      }
    });

    // 2. Start proxy
    proxy = LocalStreamCacheProxy();
    await proxy.start();
  });

  tearDown(() async {
    await proxy.stop();
    await mockUpstreamServer.close(force: true);
  });

  test('LocalStreamCacheProxy starts, responds to ping, and builds proxy url', () async {
    expect(proxy.isRunning, isTrue);
    expect(proxy.port, isNotNull);

    final client = HttpClient();
    final pingReq = await client.getUrl(
      Uri.parse('http://127.0.0.1:${proxy.port}/ping'),
    );
    final pingRes = await pingReq.close();
    expect(pingRes.statusCode, HttpStatus.ok);

    final proxyUrl = proxy.buildProxyUrl(
      remoteUrl: 'http://127.0.0.1:$mockPort/stream.mp3',
      serverId: 'test_server',
      trackId: 'track_123',
    );
    expect(proxyUrl, contains('http://127.0.0.1:${proxy.port}/stream'));
  });

  test('LocalStreamCacheProxy proxies full and partial Range requests to upstream', () async {
    final proxyUrl = proxy.buildProxyUrl(
      remoteUrl: 'http://127.0.0.1:$mockPort/stream.mp3',
      serverId: 'test_server',
      trackId: 'track_123',
    );

    final client = HttpClient();

    // Full request
    final req1 = await client.getUrl(Uri.parse(proxyUrl));
    final res1 = await req1.close();
    expect(res1.statusCode, HttpStatus.ok);
    final bytes1 = await res1.fold<List<int>>([], (p, e) => p..addAll(e));
    expect(bytes1.length, 1000);

    // Partial Range request: bytes=100-199
    final req2 = await client.getUrl(Uri.parse(proxyUrl));
    req2.headers.set(HttpHeaders.rangeHeader, 'bytes=100-199');
    final res2 = await req2.close();
    expect(res2.statusCode, HttpStatus.partialContent);
    expect(res2.headers.value(HttpHeaders.contentRangeHeader), 'bytes 100-199/1000');
    final bytes2 = await res2.fold<List<int>>([], (p, e) => p..addAll(e));
    expect(bytes2.length, 100);
    expect(bytes2[0], 100 % 256);
  });
}
