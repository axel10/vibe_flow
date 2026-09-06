import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_core/audio_core.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/playback_queue_processor.dart';
import 'package:vynody/player/audio/waveform_service.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/settings/settings_service.dart';

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String appSupportPath;
  _FakePathProvider(this.appSupportPath);

  @override
  Future<String?> getApplicationSupportPath() async => appSupportPath;
  @override
  Future<String?> getTemporaryPath() async => appSupportPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late MetadataDatabase db;
  late AudioCoreController player;
  late SettingsService settingsService;
  late WaveformService waveformService;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('queue_meta_pass_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    db = MetadataDatabase();
    await db.ensureOpen();
  });

  tearDownAll(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'remote_prefetch_count': 0});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs);
    player = AudioCoreController();
    waveformService = WaveformService(db: db, player: player);
  });

  test('PlaybackQueueProcessor Fast Pass immediately resolves metadata and thumbnail for all missing songs in queue', () async {
    // 1. Pre-insert metadata in DB for a track that is placed far beyond currentIndex + 3
    final farSongPath = '${tempDir.path}/track_far.mp3';
    await File(farSongPath).writeAsString('dummy mp3 content');

    await db.insertOrUpdateSong(SongMetadata(
      path: farSongPath,
      title: 'Far Track Title',
      artist: 'Far Artist',
      album: 'Far Album',
      duration: 215000,
      thumbnailPath: '${tempDir.path}/thumb_far.jpg',
    ));

    final currentSongPath = '${tempDir.path}/track_current.mp3';
    await File(currentSongPath).writeAsString('dummy current content');

    final playlist = [
      MusicFile(path: currentSongPath, name: 'track_current.mp3'),
      MusicFile(path: '${tempDir.path}/track_1.mp3', name: 'track_1.mp3'),
      MusicFile(path: '${tempDir.path}/track_2.mp3', name: 'track_2.mp3'),
      MusicFile(path: '${tempDir.path}/track_3.mp3', name: 'track_3.mp3'),
      MusicFile(path: '${tempDir.path}/track_4.mp3', name: 'track_4.mp3'),
      MusicFile(path: farSongPath, name: 'track_far.mp3'), // Index 5 (beyond currentIndex + 3)
    ];

    final processor = PlaybackQueueProcessor(
      db: db,
      player: player,
      settingsService: settingsService,
      waveformService: waveformService,
    );

    final updatedPaths = <String, Map<String, dynamic>>{};

    await processor.processQueue(
      playlist: playlist,
      currentFilePath: currentSongPath,
      onUpdate: (path, updates) {
        (updatedPaths[path] ??= {}).addAll(updates);
      },
    );

    // Verify that the far song (at index 5) received its metadata and thumbnail in the fast pass!
    expect(updatedPaths.containsKey(farSongPath), isTrue);
    final farUpdates = updatedPaths[farSongPath]!;
    expect(farUpdates['title'], 'Far Track Title');
    expect(farUpdates['artist'], 'Far Artist');
    expect(farUpdates['album'], 'Far Album');
    expect(farUpdates['durationMillis'], 215000);
    expect(farUpdates['thumbnailPath'], '${tempDir.path}/thumb_far.jpg');
  });
}
