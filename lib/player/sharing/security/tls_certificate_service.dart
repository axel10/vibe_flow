import 'dart:convert';
import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Service responsible for generating, persisting, and providing self-signed TLS certificates
/// and creating Certificate-Pinned HTTP/WebSocket clients for secure local network communication.
class TlsCertificateService {
  String? _certificatePem;
  String? _privateKeyPem;
  String? _fingerprint;
  SecurityContext? _serverSecurityContext;

  String? get certificatePem => _certificatePem;
  String? get fingerprint => _fingerprint;
  SecurityContext? get serverSecurityContext => _serverSecurityContext;

  /// Gets the directory where security credentials are saved.
  Future<Directory?> _getSecurityDirectory() async {
    try {
      final baseDir = await getApplicationSupportDirectory();
      final secDir = Directory(p.join(baseDir.path, 'security'));
      if (!secDir.existsSync()) {
        secDir.createSync(recursive: true);
      }
      return secDir;
    } catch (e) {
      try {
        final docDir = await getApplicationDocumentsDirectory();
        final secDir = Directory(p.join(docDir.path, 'security'));
        if (!secDir.existsSync()) {
          secDir.createSync(recursive: true);
        }
        return secDir;
      } catch (_) {
        return null;
      }
    }
  }

  /// Initializes or loads the persistent self-signed TLS certificate and private key.
  Future<void> initialize() async {
    try {
      final secDir = await _getSecurityDirectory();
      if (secDir != null) {
        final certFile = File(p.join(secDir.path, 'lan_tls_cert.pem'));
        final keyFile = File(p.join(secDir.path, 'lan_tls_key.pem'));
        final fpFile = File(p.join(secDir.path, 'lan_tls_fp.txt'));

        if (certFile.existsSync() && keyFile.existsSync() && fpFile.existsSync()) {
          final cert = certFile.readAsStringSync().trim();
          final key = keyFile.readAsStringSync().trim();
          final fp = fpFile.readAsStringSync().trim();

          if (cert.isNotEmpty && key.isNotEmpty && fp.isNotEmpty) {
            _certificatePem = cert;
            _privateKeyPem = key;
            _fingerprint = fp;
          }
        }
      }

      if (_certificatePem == null || _privateKeyPem == null || _fingerprint == null) {
        await _generateAndSaveCertificate();
      }

      if (_certificatePem != null && _privateKeyPem != null) {
        _serverSecurityContext = SecurityContext(withTrustedRoots: false);
        _serverSecurityContext!.useCertificateChainBytes(
          utf8.encode(_certificatePem!),
        );
        _serverSecurityContext!.usePrivateKeyBytes(
          utf8.encode(_privateKeyPem!),
        );
      }
    } catch (e) {
      debugPrint('[TlsCertificateService] Initialization error: $e. Regenerating in-memory cert...');
      try {
        await _generateAndSaveCertificate();
        if (_certificatePem != null && _privateKeyPem != null) {
          _serverSecurityContext = SecurityContext(withTrustedRoots: false);
          _serverSecurityContext!.useCertificateChainBytes(
            utf8.encode(_certificatePem!),
          );
          _serverSecurityContext!.usePrivateKeyBytes(
            utf8.encode(_privateKeyPem!),
          );
        }
      } catch (e2) {
        debugPrint('[TlsCertificateService] Failed to generate fallback certificate: $e2');
      }
    }
  }

  /// Generates a new RSA 2048-bit self-signed certificate valid for 20 years.
  Future<void> _generateAndSaveCertificate() async {
    final keyPair = CryptoUtils.generateRSAKeyPair(keySize: 2048);
    final privKey = keyPair.privateKey as RSAPrivateKey;
    final pubKey = keyPair.publicKey as RSAPublicKey;

    final dn = <String, String>{
      'CN': 'Vynody Local Server',
      'O': 'Vynody',
      'OU': 'Local Media Sharing',
    };

    final csr = X509Utils.generateRsaCsrPem(dn, privKey, pubKey);
    final certPem = X509Utils.generateSelfSignedCertificate(
      privKey,
      csr,
      7300, // ~20 years validity
    );
    final keyPem = CryptoUtils.encodeRSAPrivateKeyToPem(privKey);

    // Compute SHA-256 fingerprint from the certificate DER bytes
    final derBytes = CryptoUtils.getBytesFromPEMString(certPem);
    final String fp = sha256.convert(derBytes).toString().toLowerCase();

    _certificatePem = certPem;
    _privateKeyPem = keyPem;
    _fingerprint = fp;

    try {
      final secDir = await _getSecurityDirectory();
      if (secDir != null) {
        final certFile = File(p.join(secDir.path, 'lan_tls_cert.pem'));
        final keyFile = File(p.join(secDir.path, 'lan_tls_key.pem'));
        final fpFile = File(p.join(secDir.path, 'lan_tls_fp.txt'));

        certFile.writeAsStringSync(certPem, flush: true);
        keyFile.writeAsStringSync(keyPem, flush: true);
        fpFile.writeAsStringSync(fp, flush: true);

        // Security hardening: restrict private key file permissions on POSIX systems
        if (!Platform.isWindows) {
          try {
            Process.runSync('chmod', ['600', keyFile.path]);
            Process.runSync('chmod', ['700', secDir.path]);
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('[TlsCertificateService] Warning: Could not persist TLS files to disk: $e');
    }

    debugPrint('[TlsCertificateService] Generated TLS cert with fingerprint: $fp');
  }

  /// Map of host/IP or deviceId to expected SHA-256 certificate fingerprints for LAN devices.
  static final Map<String, String> _hostFingerprints = {};

  /// Normalizes a host or IP string (removes IPv6 square brackets, whitespace, lowercase).
  static String _normalizeHost(String hostOrId) {
    return hostOrId.trim().replaceAll('[', '').replaceAll(']', '').toLowerCase();
  }

  /// Registers a known LAN host/IP or device ID with its expected certificate fingerprint.
  static void registerDeviceFingerprint(String hostOrId, String? fingerprint) {
    if (fingerprint != null && fingerprint.isNotEmpty) {
      _hostFingerprints[_normalizeHost(hostOrId)] = fingerprint.trim().toLowerCase();
    }
  }

  /// Removes a registered device from the fingerprint cache.
  static void unregisterDeviceFingerprint(String hostOrId) {
    _hostFingerprints.remove(_normalizeHost(hostOrId));
  }

  /// Verifies an X.509 certificate against registered fingerprints.
  static bool verifyCertificate(X509Certificate cert, String host, int port) {
    final serverFp = sha256.convert(cert.der).toString().toLowerCase();
    final normalized = _normalizeHost(host);
    final expected = _hostFingerprints[normalized];
    if (expected != null && expected.isNotEmpty) {
      final matches = serverFp == expected;
      if (!matches) {
        debugPrint(
          '[TlsCertificateService] Pinning mismatch for host $host ($normalized). Expected: $expected, Received: $serverFp',
        );
      }
      return matches;
    }

    debugPrint(
      '[TlsCertificateService] Untrusted self-signed cert from $host:$port ($serverFp). No matching pin found.',
    );
    return false;
  }

  /// Creates an HttpClient configured for Certificate Pinning against [expectedFingerprint].
  ///
  /// If [expectedFingerprint] is provided:
  /// Verifies that the SHA-256 hash of the server's DER certificate matches [expectedFingerprint].
  /// Otherwise falls back to registered device fingerprints.
  static HttpClient createPinnedHttpClient({String? expectedFingerprint}) {
    final client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      if (expectedFingerprint != null && expectedFingerprint.isNotEmpty) {
        final serverFp = sha256.convert(cert.der).toString().toLowerCase();
        final expected = expectedFingerprint.trim().toLowerCase();
        final isValid = serverFp == expected;
        if (!isValid) {
          debugPrint(
            '[TlsCertificateService] Certificate pinning failed for $host:$port. '
            'Expected: $expected, Received: $serverFp',
          );
        }
        return isValid;
      }
      return verifyCertificate(cert, host, port);
    };
    return client;
  }
}

/// Global HttpOverrides to ensure Flutter's Image.network / NetworkImage
/// can securely load covers and assets from LAN devices using Certificate Pinning.
class LanHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return TlsCertificateService.verifyCertificate(cert, host, port);
    };
    return client;
  }
}

