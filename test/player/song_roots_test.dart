import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vynody/player/metadata/metadata_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory supportDirectory;

  setUpAll(() async {
    supportDirectory = await Directory.systemTemp.createTemp(
      'song_roots_test_',
    );
    PathProviderPlatform.instance = _TestPathProviderPlatform(
      supportPath: supportDirectory.path,
    );
  });

  tearDownAll(() async {
    try {
      if (await supportDirectory.exists()) {
        await supportDirectory.delete(recursive: true);
      }
    } catch (_) {}
  });

  group('SongRoots reference table tests', () {
    final db = MetadataDatabase();

    test('bind, unbind, and sweep orphan songs with overlapping roots', () async {
      final parentRoot = p.normalize('D:/Music');
      final childRoot = p.normalize('D:/Music/Rock');
      final sharedSong = p.normalize('D:/Music/Rock/shared.mp3');
      final parentOnlySong = p.normalize('D:/Music/Pop/parent.mp3');

      // Insert test songs into DB
      await db.insertOrUpdateSongsMerged([
        SongMetadata(
          path: sharedSong,
          title: 'Shared Song',
          album: 'Test Album',
          artist: 'Test Artist',
        ),
        SongMetadata(
          path: parentOnlySong,
          title: 'Parent Only Song',
          album: 'Test Album',
          artist: 'Test Artist',
        ),
      ]);

      // Bind sharedSong to both parentRoot and childRoot
      await db.bindSongsToRootBatch([sharedSong, parentOnlySong], parentRoot);
      await db.bindSongsToRootBatch([sharedSong], childRoot);

      // Verify unbinding parentRoot only unbinds parentRoot entries
      await db.unbindRootPaths([parentRoot]);

      // Sweep orphan songs
      final result = await db.sweepOrphanSongs();

      // parentOnlySong had no other root bindings -> deleted
      expect(result.deletedPaths, contains(parentOnlySong));

      // sharedSong was still bound to childRoot -> preserved!
      expect(result.deletedPaths.contains(sharedSong), isFalse);

      final sharedMetadata = await db.getSongMetadata(sharedSong);
      expect(sharedMetadata, isNotNull);
    });
  });
}

class _TestPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _TestPathProviderPlatform({required this.supportPath});

  final String supportPath;

  @override
  Future<String?> getApplicationSupportPath() async => supportPath;
}
