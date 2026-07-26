import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vynody/player/library/library_insights_service.dart';
import 'package:vynody/player/metadata/metadata_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LibraryInsights limit tests', () {
    late Directory supportDirectory;

    setUpAll(() async {
      supportDirectory = await Directory.systemTemp.createTemp(
        'library_insights_test_',
      );
      PathProviderPlatform.instance = _TestPathProviderPlatform(
        supportPath: supportDirectory.path,
      );
    });

    setUp(() async {
      await MetadataDatabase().clearAll();
    });

    tearDownAll(() async {
      try {
        if (await supportDirectory.exists()) {
          await supportDirectory.delete(recursive: true);
        }
      } catch (e) {
        print('Failed to delete support directory: $e');
      }
    });

    test('watchRecentlyAddedSongs limits returned records', () async {
      final database = MetadataDatabase();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < 20; i++) {
        await database.insertOrUpdateSong(
          SongMetadata(
            path: '/music/song_$i.mp3',
            title: 'Song $i',
            album: 'Album',
            artist: 'Artist',
            createdAt: now - (i * 1000),
          ),
        );
      }

      final items = await database.watchRecentlyAddedSongs(limit: 5).first;
      expect(items.length, 5);
      expect(items[0].song.title, 'Song 0');
      expect(items[4].song.title, 'Song 4');
    });

    test('watchRecentlyAdded in LibraryInsightsService respects limit', () async {
      final database = MetadataDatabase();
      final service = LibraryInsightsService(database: database);
      final now = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < 10; i++) {
        await database.insertOrUpdateSong(
          SongMetadata(
            path: '/music/track_$i.mp3',
            title: 'Track $i',
            album: 'Album',
            artist: 'Artist',
            createdAt: now - (i * 500),
          ),
        );
      }

      final entries = await service.watchRecentlyAdded(LibraryTimeRange.allTime, limit: 3).first;
      expect(entries.length, 3);
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
