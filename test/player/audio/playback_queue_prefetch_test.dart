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
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';

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
    tempDir = await Directory.systemTemp.createTemp('queue_prefetch_test_');
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
    SharedPreferences.setMockInitialValues({'remote_prefetch_count': 2});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs);
    player = AudioCoreController();
    waveformService = WaveformService(db: db, player: player);
  });

  test('PlaybackQueueProcessor prefetches upcoming remote tracks based on remotePrefetchCount', () async {
    final prefetchedUris = <String>[];

    final processor = PlaybackQueueProcessor(
      db: db,
      player: player,
      settingsService: settingsService,
      waveformService: waveformService,
      remoteMediaResolverGetter: () async {
        return _MockResolver(onResolve: (uri) {
          prefetchedUris.add(uri);
        });
      },
    );

    final queue = [
      const MusicFile(path: 'subsonic://srv1/track1', name: 'Track 1', title: 'Track 1'),
      const MusicFile(path: 'subsonic://srv1/track2', name: 'Track 2', title: 'Track 2'),
      const MusicFile(path: 'subsonic://srv1/track3', name: 'Track 3', title: 'Track 3'),
      const MusicFile(path: 'subsonic://srv1/track4', name: 'Track 4', title: 'Track 4'),
    ];

    await processor.processQueue(
      playlist: queue,
      currentFilePath: 'subsonic://srv1/track1',
      onUpdate: (path, updates) {},
    );

    // Allow background unawaited prefetch task to run
    await Future.delayed(const Duration(milliseconds: 50));

    // remotePrefetchCount = 2, so it should prefetch track2 and track3
    expect(prefetchedUris, contains('subsonic://srv1/track2'));
    expect(prefetchedUris, contains('subsonic://srv1/track3'));
    expect(prefetchedUris, isNot(contains('subsonic://srv1/track4')));
  });

  test('PlaybackQueueProcessor skips prefetch when remotePrefetchCount is 0', () async {
    settingsService.remotePrefetchCount = 0;
    final prefetchedUris = <String>[];

    final processor = PlaybackQueueProcessor(
      db: db,
      player: player,
      settingsService: settingsService,
      waveformService: waveformService,
      remoteMediaResolverGetter: () async {
        return _MockResolver(onResolve: (uri) {
          prefetchedUris.add(uri);
        });
      },
    );

    final queue = [
      const MusicFile(path: 'subsonic://srv1/track1', name: 'Track 1', title: 'Track 1'),
      const MusicFile(path: 'subsonic://srv1/track2', name: 'Track 2', title: 'Track 2'),
    ];

    await processor.processQueue(
      playlist: queue,
      currentFilePath: 'subsonic://srv1/track1',
      onUpdate: (path, updates) {},
    );

    await Future.delayed(const Duration(milliseconds: 50));
    expect(prefetchedUris, isEmpty);
  });
}

class _MockResolver extends Fake implements RemoteMediaResolver {
  final void Function(String uri) onResolve;
  _MockResolver({required this.onResolve});

  @override
  Future<ResolvedAudioUri> resolvePlayableSource(String remoteUri, {int? maxBitRate}) async {
    onResolve(remoteUri);
    return ResolvedAudioUri(uri: 'http://mock-server.local/stream/$remoteUri', cacheKey: remoteUri);
  }
}
