import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/scanner/scanner_service.dart';

class _TestPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _TestPathProviderPlatform({required this.supportPath});

  final String supportPath;

  @override
  Future<String?> getApplicationSupportPath() async => supportPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScannerService Search Filtering', () {
    late Directory supportDirectory;

    setUpAll(() async {
      supportDirectory = await Directory.systemTemp.createTemp(
        'scanner_service_search_test_',
      );
      PathProviderPlatform.instance = _TestPathProviderPlatform(
        supportPath: supportDirectory.path,
      );
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await MetadataDatabase().clearAll();
    });

    tearDownAll(() async {
      try {
        if (await supportDirectory.exists()) {
          await supportDirectory.delete(recursive: true);
        }
      } catch (_) {}
    });

    test('isPathInActiveRoots filters out parent and external directories', () async {
      final scanner = ScannerService(autoInitialize: false);
      
      final tempFolder = await Directory.systemTemp.createTemp('active_root_');
      final subFolder = Directory('${tempFolder.path}/SubFolder')..createSync();
      final externalFolder = await Directory.systemTemp.createTemp('external_root_');

      await scanner.addRootPath(tempFolder.path);

      expect(scanner.isPathInActiveRoots(tempFolder.path), isTrue);
      expect(scanner.isPathInActiveRoots(subFolder.path), isTrue);
      expect(scanner.isPathInActiveRoots(externalFolder.path), isFalse);

      // Parent directory of tempFolder must be false
      final parentPath = tempFolder.parent.path;
      expect(scanner.isPathInActiveRoots(parentPath), isFalse);

      scanner.dispose();
      await tempFolder.delete(recursive: true);
      await externalFolder.delete(recursive: true);
    });
  });
}
