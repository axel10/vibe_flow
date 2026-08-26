import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/remote/proxy/remote_stream_cache_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late RemoteStreamCacheManager cacheManager;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vynody_cache_test_');
    cacheManager = RemoteStreamCacheManager(customCacheDirectory: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('getCacheFile generates deterministic path within server directory', () async {
    final file1 = await cacheManager.getCacheFile(
      serverId: 'srv1',
      trackIdOrPath: 'track_001',
    );
    final file2 = await cacheManager.getCacheFile(
      serverId: 'srv1',
      trackIdOrPath: 'track_001',
    );
    final file3 = await cacheManager.getCacheFile(
      serverId: 'srv2',
      trackIdOrPath: 'track_001',
    );

    expect(file1.path, equals(file2.path));
    expect(file1.path, isNot(equals(file3.path)));
    expect(file1.path, contains('srv1'));
  });

  test('getTotalCacheSize calculates accurate size of all cache files', () async {
    final file1 = await cacheManager.getCacheFile(
      serverId: 'srv1',
      trackIdOrPath: 'track_001',
    );
    final file2 = await cacheManager.getCacheFile(
      serverId: 'srv2',
      trackIdOrPath: 'track_002',
    );

    await file1.writeAsBytes(List.filled(100, 1));
    await file2.writeAsBytes(List.filled(250, 2));

    final totalSize = await cacheManager.getTotalCacheSize();
    expect(totalSize, equals(350));
  });

  test('pruneCacheIfNeeded prunes oldest files when exceeding limit', () async {
    final file1 = await cacheManager.getCacheFile(
      serverId: 'srv1',
      trackIdOrPath: 'old_track',
    );
    final file2 = await cacheManager.getCacheFile(
      serverId: 'srv1',
      trackIdOrPath: 'new_track',
    );

    // Write 500 bytes to file1 (old) and file2 (new)
    await file1.writeAsBytes(List.filled(500, 1));
    await file2.writeAsBytes(List.filled(500, 2));

    // Set file1 modified time to 1 hour ago
    await file1.setLastModified(DateTime.now().subtract(const Duration(hours: 1)));
    await file2.setLastModified(DateTime.now());

    expect(await cacheManager.getTotalCacheSize(), equals(1000));

    // Prune with a limit of 800 bytes (target 85% = 680 bytes)
    await cacheManager.pruneCacheIfNeeded(limitBytes: 800);

    // file1 (old) should be pruned, file2 should remain
    expect(await file1.exists(), isFalse);
    expect(await file2.exists(), isTrue);
    expect(await cacheManager.getTotalCacheSize(), equals(500));
  });

  test('clearCache clears specific server or all cache', () async {
    final file1 = await cacheManager.getCacheFile(
      serverId: 'srv1',
      trackIdOrPath: 'track_001',
    );
    final file2 = await cacheManager.getCacheFile(
      serverId: 'srv2',
      trackIdOrPath: 'track_002',
    );

    await file1.writeAsBytes(List.filled(100, 1));
    await file2.writeAsBytes(List.filled(200, 2));

    expect(await cacheManager.getTotalCacheSize(), equals(300));

    // Clear only srv1
    await cacheManager.clearCache(serverId: 'srv1');
    expect(await file1.exists(), isFalse);
    expect(await file2.exists(), isTrue);
    expect(await cacheManager.getTotalCacheSize(), equals(200));

    // Clear all
    await cacheManager.clearCache();
    expect(await file2.exists(), isFalse);
    expect(await cacheManager.getTotalCacheSize(), equals(0));
  });

  test('touchCacheFile updates file modification time', () async {
    final file = await cacheManager.getCacheFile(
      serverId: 'srv1',
      trackIdOrPath: 'track_001',
    );
    await file.writeAsBytes(List.filled(50, 1));

    final pastTime = DateTime.now().subtract(const Duration(days: 2));
    await file.setLastModified(pastTime);
    expect((await file.stat()).modified.isBefore(DateTime.now().subtract(const Duration(days: 1))), isTrue);

    await cacheManager.touchCacheFile(file);
    final modified = (await file.stat()).modified;
    expect(DateTime.now().difference(modified).inSeconds < 5, isTrue);
  });
}
