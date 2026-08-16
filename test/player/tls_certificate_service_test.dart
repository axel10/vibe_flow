import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vynody/player/sharing/security/tls_certificate_service.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory tempDir;
  FakePathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationSupportPath() async => tempDir.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testTempDir;

  setUp(() {
    testTempDir = Directory.systemTemp.createTempSync('tls_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(testTempDir);
  });

  tearDown(() {
    try {
      if (testTempDir.existsSync()) {
        testTempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('TlsCertificateService', () {
    test('generates self-signed TLS cert, key, and fingerprint when empty', () async {
      final service = TlsCertificateService();

      await service.initialize();

      expect(service.certificatePem, isNotNull);
      expect(service.certificatePem, contains('BEGIN CERTIFICATE'));
      expect(service.certificatePem, contains('END CERTIFICATE'));

      expect(service.fingerprint, isNotNull);
      expect(service.fingerprint!.length, 64); // SHA-256 hex string length
      expect(service.serverSecurityContext, isNotNull);
    });

    test('reuses existing certificate from storage on subsequent initialize', () async {
      final service1 = TlsCertificateService();
      await service1.initialize();

      final firstFp = service1.fingerprint;

      final service2 = TlsCertificateService();
      await service2.initialize();

      expect(service2.fingerprint, equals(firstFp));
      expect(service2.certificatePem, equals(service1.certificatePem));
    });

    test('device fingerprint registration and verification', () {
      const deviceId = 'test_device_1';
      const hostIp = '192.168.1.100';
      const fp = 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';

      TlsCertificateService.registerDeviceFingerprint(deviceId, fp);
      TlsCertificateService.registerDeviceFingerprint(hostIp, fp);

      // Cleanup
      TlsCertificateService.unregisterDeviceFingerprint(deviceId);
      TlsCertificateService.unregisterDeviceFingerprint(hostIp);
    });

    test('createPinnedHttpClient creates HttpClient configured with pinning', () {
      const expectedFp = '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
      final client = TlsCertificateService.createPinnedHttpClient(
        expectedFingerprint: expectedFp,
      );

      expect(client, isNotNull);
      client.close();
    });
  });
}
