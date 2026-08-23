import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/pages/albums_tab.dart';
import 'package:vynody/pages/playback_page.dart';
import 'package:vynody/pages/sharing_page.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/library/album_library.dart';
import 'package:vynody/player/lyrics/lyrics_riverpod.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/widgets/equalizer_panel.dart';

import 'helpers/mobile_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate iOS Store Poster 01 (EN) - Immersive Playback', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = TestSettingsService(prefs);

    settingsService.hasShownCoverTapLyricTip = true;
    settingsService.isWaveformProgressBarEnabled = true;
    settingsService.portraitFrequencyGroups = 100;
    settingsService.visualizerStyle = VisualizerStyle.bars;
    settingsService.visualizerOpacity = VisualizerStyle.bars.defaultOpacity;
    settingsService.isVisualizerDynamicColor = false;
    settingsService.visualizerColor = Colors.white;

    Uint8List? artworkBytes;
    final coverFile = File('/Volumes/Untitled/projects/vibe_flow/test_covers/cover_04.jpg');
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

    const demoLrc = '''
[00:00.00]Walking Home at Sunset - Soda Pop
[00:15.00](Guitar & Melody Intro)
[00:42.10]Raindrops blurring out the traffic lights
[00:46.35]We’re just shadows chasing compromised nights
[00:51.20]You said forever was a guaranteed thing
[00:55.80]But forever’s getting shorter, or so it seems
''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 1.8);

    final demoSong = MusicFile(
      path: '/Users/axel10/Music/Vynody Music/Demo Music/en/Demo Music/04 - Walking Home at Sunset.mp3',
      name: '04 - Walking Home at Sunset.mp3',
      title: 'Walking Home at Sunset',
      artist: 'Soda Pop',
      album: 'Summer Slow Motion',
      durationMillis: 252000,
      artworkBytes: artworkBytes,
      waveformBlob: waveformBlob,
      lyrics: lyrics,
    );

    final fftValues = generateFftBandsDefault(count: 100, energy: 0.88);
    final fftFrame = FftFrame(
      position: const Duration(seconds: 85, milliseconds: 400),
      values: fftValues,
      isPlaying: true,
    );

    final snapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: demoSong,
      position: const Duration(seconds: 85, milliseconds: 400),
      duration: const Duration(seconds: 252),
      volume: 0.85,
      isMuted: false,
      playbackQueue: [demoSong],
      currentIndex: 0,
      isRandomMode: false,
      isShuffleRandomMode: false,
      playbackMode: AppPlaybackMode.queue,
      equalizerConfig: EqualizerConfig(
        enabled: false,
        bandCount: 10,
        preampDb: 0.0,
        bassBoostDb: 0.0,
        bassBoostFrequencyHz: 80.0,
        bassBoostQ: 1.0,
        bandGainsDb: Float32List(10),
      ),
      currentVisualizerOptions: const VisualizerOptimizationOptions(
        frequencyGroups: 100,
      ),
      randomHistory: const [],
      randomQueue: const [],
      historyCursor: null,
      deckCursor: null,
      isVisualizerEnabled: true,
      dynamicStartColor: const Color(0xFFE2824A),
      dynamicEndColor: const Color(0xFF1E1B4B),
      isLyricsActive: false,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    final visualizerStreamController = StreamController<FftFrame>.broadcast();
    final audioService = MockAudioService(
      snapshot: snapshot,
      artworkBytes: artworkBytes,
      visualizerStream: visualizerStreamController.stream,
    );

    final scannerService = MockScannerService(
      rootFolders: [
        MusicFolder(path: '/demo_en', name: 'Demo Music', files: [demoSong])
      ],
    );

    final posterConfig = MobilePosterConfig(
      tagText: 'IMMERSIVE AUDIO EXPERIENCE',
      tagColor: Color(0xFFFDBA74),
      title: 'Immersive Playback',
      subtitle: 'Pure Acoustics · Dynamic Spectrum & Custom Backdrops',
      backgroundGradient: [
        Color(0xFF181124),
        Color(0xFF0D0F18),
        Color(0xFF06070B),
      ],
      glowColor: Color(0xFFE2824A),
      outputPosterFileName: ScreenshotPaths.store('ios_store_en_01_playback.png', lang: 'en'),
      outputScreenFileName: ScreenshotPaths.raw('ios_screen_en_01_playback.png', lang: 'en'),
    );

    await runTwoStageMobilePosterTest(
      tester: tester,
      posterConfig: posterConfig,
      screenChild: const PlaybackPage(),
      initialFftFrame: fftFrame,
      visualizerStreamController: visualizerStreamController,
      locale: const Locale('en'),
      overrides: [
        settingsServiceProvider.overrideWith((ref) => settingsService),
        audioServiceProvider.overrideWith((ref) => audioService),
        audioSnapshotProvider.overrideWith((ref) => snapshot),
        isEffectiveWaveformEnabledProvider.overrideWith((ref) => true),
        isProUnlockedProvider.overrideWith((ref) => true),
        scannerServiceProvider.overrideWith((ref) => scannerService),
      ],
    );

    await visualizerStreamController.close();
  });

  testWidgets('Generate iOS Store Poster 02 (EN) - Dynamic Synced Lyrics', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = TestSettingsService(prefs);

    settingsService.hasShownCoverTapLyricTip = true;
    settingsService.hasShownLyricsMenuTip = true;
    settingsService.isWaveformProgressBarEnabled = true;
    settingsService.lyricsStyle = LyricsStyle.apple;
    settingsService.lyricsTranslationTargetLanguageCode = 'en';

    Uint8List? artworkBytes;
    final coverFile = File('/Volumes/Untitled/projects/vibe_flow/test_covers/cover_04.jpg');
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

    const demoLrc = '''
[00:00.00]Walking Home at Sunset - Soda Pop
[00:12.00]Streetlights glowing through the amber dusk
[00:16.50]Shadows fading on the quiet pavement
[00:21.00]You hummed a melody we used to know
[00:25.50]Before the summer turned to memory
[00:30.00]I traced every footstep we ever made
[00:34.50]Like holding onto echoes before they fade
[00:39.00]Golden clouds drift slow across the sky
[00:43.50]And all our quiet hopes begin to rise
[00:48.00]If you're still listening in the breeze
[00:52.50]Let the night carry what we feel
[00:57.00]Every unspoken word tonight
[01:01.50]Will find its way into the light
[01:06.00]I'm walking home with you tonight
[01:10.50]Underneath the softly fading sky
[01:15.00]When the city slows its busy pace
[01:19.50]We find our rhythm in this place
[01:24.00]I'll keep this moment safe in time
[01:28.50]Through every storm or gentle rain
[01:33.00]As long as you are by my side
[01:37.50]The road ahead is clear and bright
[01:42.00]Neon reflections on the glass
[01:46.50]Watching the evening slowly pass
[01:51.00]A quiet breath, a gentle smile
[01:55.50]Let's stay right here a little while
[02:00.00]No need to hurry to the end
[02:04.50]With every step, my closest friend
[02:09.00]The stars are waking one by one
[02:13.50]Our story has only just begun
[02:18.00]I'm walking home with you tonight
[02:22.50]Underneath the softly fading sky
[02:27.00]When the city slows its busy pace
[02:31.50]We find our rhythm in this place
[02:36.00]I'll keep this moment safe in time
[02:40.50]Through every storm or gentle rain
[02:45.00]As long as you are by my side
[02:49.50]The road ahead is clear and bright
''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 1.8);

    const songPath = '/Users/axel10/Music/Vynody Music/Demo Music/en/Demo Music/04 - Walking Home at Sunset.mp3';
    final demoSong = MusicFile(
      path: songPath,
      name: '04 - Walking Home at Sunset.mp3',
      title: 'Walking Home at Sunset',
      artist: 'Soda Pop',
      album: 'Summer Slow Motion',
      durationMillis: 251970,
      artworkBytes: artworkBytes,
      waveformBlob: waveformBlob,
      lyrics: lyrics,
    );

    // Position at early verse line 2: 00:17.00
    final currentPosition = const Duration(seconds: 17);

    final fftValues = generateFftBandsDefault(count: 100, energy: 0.88);
    final fftFrame = FftFrame(
      position: currentPosition,
      values: fftValues,
      isPlaying: true,
    );

    final snapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: demoSong,
      position: currentPosition,
      duration: const Duration(seconds: 251, milliseconds: 970),
      volume: 0.85,
      isMuted: false,
      playbackQueue: [demoSong],
      currentIndex: 0,
      isRandomMode: false,
      isShuffleRandomMode: false,
      playbackMode: AppPlaybackMode.queue,
      equalizerConfig: EqualizerConfig(
        enabled: false,
        bandCount: 10,
        preampDb: 0.0,
        bassBoostDb: 0.0,
        bassBoostFrequencyHz: 80.0,
        bassBoostQ: 1.0,
        bandGainsDb: Float32List(10),
      ),
      currentVisualizerOptions: const VisualizerOptimizationOptions(
        frequencyGroups: 100,
      ),
      randomHistory: const [],
      randomQueue: const [],
      historyCursor: null,
      deckCursor: null,
      isVisualizerEnabled: true,
      dynamicStartColor: const Color(0xFFC83A3A),
      dynamicEndColor: const Color(0xFF1E1528),
      isLyricsActive: true,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    final visualizerStreamController = StreamController<FftFrame>.broadcast();
    final audioService = MockAudioService(
      snapshot: snapshot,
      artworkBytes: artworkBytes,
      visualizerStream: visualizerStreamController.stream,
    );

    final scannerService = MockScannerService(
      rootFolders: [
        MusicFolder(path: '/demo_en', name: 'Demo Music', files: [demoSong])
      ],
    );

    final lyricsState = LyricsControllerState(
      hasLyrics: true,
      currentLyricsLines: lyrics.syncedLines,
      lyricsTranslationLanguageCode: 'en',
    );

    final lyricsController = MockLyricsController(
      initialState: lyricsState,
      lyrics: lyrics,
    );

    final posterConfig = MobilePosterConfig(
      tagText: 'SYNCED LYRICS & GLOW EFFECTS',
      tagColor: Color(0xFFFDA4AF),
      title: 'Dynamic Lyrics',
      subtitle: 'Fluid Apple Music Style · Real-Time AI Sync & Line Highlights',
      backgroundGradient: [
        Color(0xFF220F18),
        Color(0xFF130911),
        Color(0xFF07070B),
      ],
      glowColor: Color(0xFFE11D48),
      outputPosterFileName: ScreenshotPaths.store('ios_store_en_02_lyrics.png', lang: 'en'),
      outputScreenFileName: ScreenshotPaths.raw('ios_screen_en_02_lyrics.png', lang: 'en'),
    );

    await runTwoStageMobilePosterTest(
      tester: tester,
      posterConfig: posterConfig,
      screenChild: const PlaybackPage(),
      initialFftFrame: fftFrame,
      visualizerStreamController: visualizerStreamController,
      locale: const Locale('en'),
      overrides: [
        settingsServiceProvider.overrideWith((ref) => settingsService),
        audioServiceProvider.overrideWith((ref) => audioService),
        audioSnapshotProvider.overrideWith((ref) => snapshot),
        lyricsControllerProvider.overrideWith(() => lyricsController),
        isEffectiveWaveformEnabledProvider.overrideWith((ref) => true),
        isProUnlockedProvider.overrideWith((ref) => true),
        scannerServiceProvider.overrideWith((ref) => scannerService),
      ],
    );

    await visualizerStreamController.close();
  });

  testWidgets('Generate iOS Store Poster 03 (EN) - 3D Cover Flow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = TestSettingsService(prefs);

    const basePath = '/Users/axel10/Music/Vynody Music/Demo Music/en/Demo Music';
    final demoData = createDemoLibraryData(
      basePath: basePath,
      demoItems: defaultDemoListEn,
    );

    final activeSong = demoData.songs[3]; // 'Summer Slow Motion' - Soda Pop

    final snapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: activeSong,
      position: const Duration(seconds: 45),
      duration: Duration(milliseconds: activeSong.durationMillis ?? 252000),
      volume: 0.85,
      isMuted: false,
      playbackQueue: demoData.songs,
      currentIndex: 3,
      isRandomMode: false,
      isShuffleRandomMode: false,
      playbackMode: AppPlaybackMode.queue,
      equalizerConfig: EqualizerConfig(
        enabled: false,
        bandCount: 10,
        preampDb: 0.0,
        bassBoostDb: 0.0,
        bassBoostFrequencyHz: 80.0,
        bassBoostQ: 1.0,
        bandGainsDb: Float32List(10),
      ),
      currentVisualizerOptions: const VisualizerOptimizationOptions(
        frequencyGroups: 100,
      ),
      randomHistory: const [],
      randomQueue: const [],
      historyCursor: null,
      deckCursor: null,
      isVisualizerEnabled: true,
      dynamicStartColor: const Color(0xFFC83A3A),
      dynamicEndColor: const Color(0xFF1E1528),
      isLyricsActive: false,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    final visualizerStreamController = StreamController<FftFrame>.broadcast();
    final audioService = MockAudioService(
      snapshot: snapshot,
      artworkBytes: activeSong.artworkBytes,
      visualizerStream: visualizerStreamController.stream,
    );

    final scannerService = MockScannerService(
      rootFolders: [
        MusicFolder(path: basePath, name: 'Demo Music', files: demoData.songs),
      ],
      metadataMap: demoData.metadataMap,
    );

    final posterConfig = MobilePosterConfig(
      tagText: 'CLASSIC VINYL AESTHETICS',
      tagColor: Color(0xFFFBBF24),
      title: 'Cover Flow',
      subtitle: '3D Album Carousel · Swift Browsing & Smart Library',
      backgroundGradient: [
        Color(0xFF241508),
        Color(0xFF130E0A),
        Color(0xFF070605),
      ],
      glowColor: Color(0xFFD97706),
      screenBackgroundColor: Color(0xFF140E0A),
      screenColorScheme: ColorScheme.dark(
        primary: Color(0xFFF59E0B),
        primaryContainer: Color(0xFF78350F),
        secondary: Color(0xFFD97706),
        secondaryContainer: Color(0xFF382312),
        onSecondaryContainer: Color(0xFFFDE68A),
        surface: Color(0xFF1A130D),
        surfaceContainerLow: Color(0xFF231A12),
        surfaceContainerHighest: Color(0xFF33251A),
        onPrimary: Colors.black,
        onSurface: Colors.white,
        onSurfaceVariant: Color(0xFFD6C7B8),
      ),
      outputPosterFileName: ScreenshotPaths.store('ios_store_en_03_coverflow.png', lang: 'en'),
      outputScreenFileName: ScreenshotPaths.raw('ios_screen_en_03_coverflow.png', lang: 'en'),
    );

    await runTwoStageMobilePosterTest(
      tester: tester,
      posterConfig: posterConfig,
      locale: const Locale('en'),
      screenChild: const SafeArea(
        bottom: false,
        child: AlbumsTab(
          initial3DView: true,
          initial3DIndex: 9,
        ),
      ),
      overrides: [
        settingsServiceProvider.overrideWith((ref) => settingsService),
        audioServiceProvider.overrideWith((ref) => audioService),
        audioSnapshotProvider.overrideWith((ref) => snapshot),
        albumLibraryProvider.overrideWith((ref) => Stream.value(demoData.albums)),
        scannerServiceProvider.overrideWith((ref) => scannerService),
        isProUnlockedProvider.overrideWith((ref) => true),
      ],
    );

    await visualizerStreamController.close();
  });

  testWidgets('Generate iOS Store Poster 04 (EN) - Studio Equalizer', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = TestSettingsService(prefs);

    settingsService.hasShownCoverTapLyricTip = true;
    settingsService.isWaveformProgressBarEnabled = true;
    settingsService.portraitFrequencyGroups = 100;
    settingsService.visualizerStyle = VisualizerStyle.bars;
    settingsService.visualizerOpacity = VisualizerStyle.bars.defaultOpacity;
    settingsService.isVisualizerDynamicColor = true;
    settingsService.equalizerBandCount = 10;

    const songPath = '/Users/axel10/Music/Vynody Music/Demo Music/en/Demo Music/03 - Moon at 2AM.mp3';
    const coverPath = '/Volumes/Untitled/projects/vibe_flow/test_covers/03 - Moon at 2AM.jpg';

    Uint8List? artworkBytes;
    final coverFile = File(coverPath);
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

    const demoLrc = '''
[00:00.00]Moon at 2AM - White Noise Forest
[00:15.00](Intro)
[00:42.10]City lights are slowly fading down
[00:46.35]Only moonlight dancing on the ground
[00:51.20]Through the headphones melodies unwound
[00:55.80]Every quiet story finally found
''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 2.1);

    final lyricsState = LyricsControllerState(
      hasLyrics: true,
      currentLyricsLines: lyrics.syncedLines,
    );

    final lyricsController = MockLyricsController(
      initialState: lyricsState,
      lyrics: lyrics,
    );

    final demoSong = MusicFile(
      id: 3,
      path: songPath,
      name: '03 - Moon at 2AM.mp3',
      title: 'Moon at 2AM',
      artist: 'White Noise Forest',
      album: 'Sleepless Radio',
      durationMillis: 225018,
      artworkBytes: artworkBytes,
      waveformBlob: waveformBlob,
      lyrics: lyrics,
    );

    final eqGains = Float32List.fromList(EqualizerPresets.hifi.referenceGains);
    final eqConfig = EqualizerConfig(
      enabled: true,
      bandCount: 10,
      preampDb: 1.5,
      bassBoostDb: 25.0,
      bassBoostFrequencyHz: 80.0,
      bassBoostQ: 1.0,
      bandGainsDb: eqGains,
    );

    final fftValues = generateFftBandsDefault(count: 100, energy: 0.88);
    final fftFrame = FftFrame(
      position: const Duration(seconds: 48, milliseconds: 200),
      values: fftValues,
      isPlaying: true,
    );

    final snapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: demoSong,
      position: const Duration(seconds: 48, milliseconds: 200),
      duration: const Duration(milliseconds: 225018),
      volume: 0.85,
      isMuted: false,
      playbackQueue: [demoSong],
      currentIndex: 0,
      isRandomMode: false,
      isShuffleRandomMode: false,
      playbackMode: AppPlaybackMode.queue,
      equalizerConfig: eqConfig,
      currentVisualizerOptions: const VisualizerOptimizationOptions(
        frequencyGroups: 100,
      ),
      randomHistory: const [],
      randomQueue: const [],
      historyCursor: null,
      deckCursor: null,
      isVisualizerEnabled: true,
      dynamicStartColor: const Color(0xFF38BDF8),
      dynamicEndColor: const Color(0xFF0F172A),
      isLyricsActive: false,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    final visualizerStreamController = StreamController<FftFrame>.broadcast();
    final audioService = MockAudioService(
      snapshot: snapshot,
      artworkBytes: artworkBytes,
      visualizerStream: visualizerStreamController.stream,
    );

    final scannerService = MockScannerService(
      rootFolders: [
        MusicFolder(
          path: '/Users/axel10/Music/Vynody Music/Demo Music/en/Demo Music',
          name: 'Demo Music',
          files: [demoSong],
        ),
      ],
      metadataMap: {
        songPath: SongMetadata(
          id: 3,
          path: songPath,
          title: 'Moon at 2AM',
          artist: 'White Noise Forest',
          album: 'Sleepless Radio',
          duration: 225018,
        ),
      },
    );

    final posterConfig = MobilePosterConfig(
      tagText: 'PRO 10-BAND / 31-BAND EQ',
      tagColor: Color(0xFF38BDF8),
      title: 'Studio Equalizer',
      subtitle: 'Ultra-Low Latency Engine · Dynamic Gain & Studio Presets',
      backgroundGradient: [
        Color(0xFF0C192E),
        Color(0xFF08101E),
        Color(0xFF060913),
      ],
      glowColor: Color(0xFF38BDF8),
      outputPosterFileName: ScreenshotPaths.store('ios_store_en_04_equalizer.png', lang: 'en'),
      outputScreenFileName: ScreenshotPaths.raw('ios_screen_en_04_equalizer.png', lang: 'en'),
    );

    await runTwoStageMobilePosterTest(
      tester: tester,
      posterConfig: posterConfig,
      initialFftFrame: fftFrame,
      visualizerStreamController: visualizerStreamController,
      locale: const Locale('en'),
      screenChild: const Stack(
        fit: StackFit.expand,
        children: [
          PlaybackPage(),
          EqualizerPanel(),
        ],
      ),
      overrides: [
        settingsServiceProvider.overrideWith((ref) => settingsService),
        audioServiceProvider.overrideWith((ref) => audioService),
        audioSnapshotProvider.overrideWith((ref) => snapshot),
        lyricsControllerProvider.overrideWith(() => lyricsController),
        isEffectiveWaveformEnabledProvider.overrideWith((ref) => true),
        isProUnlockedProvider.overrideWith((ref) => true),
        scannerServiceProvider.overrideWith((ref) => scannerService),
      ],
    );

    await visualizerStreamController.close();
  });

  testWidgets('Generate iOS Store Poster 05 (EN) - Multi-Device Sync', (tester) async {
    SharedPreferences.setMockInitialValues({
      'lan_sharing_enabled': true,
      'allow_remote_control': true,
      'lan_sharing_folder_path': '/Users/axel10/Music/Vynody Music',
    });
    final prefs = await SharedPreferences.getInstance();
    final settingsService = TestSettingsService(prefs);
    settingsService.lanSharingEnabled = true;
    settingsService.allowRemoteControl = true;
    settingsService.lanSharingFolderPath = '/Users/axel10/Music/Vynody Music';

    final posterConfig = MobilePosterConfig(
      tagText: 'CROSS-DEVICE WIRELESS SYNC',
      tagColor: Color(0xFF38BDF8),
      title: 'Multi-Device Hub',
      subtitle: 'End-to-End TLS Encryption · Lossless LAN Transfer & Remote Play',
      backgroundGradient: [
        Color(0xFF0D1B2A),
        Color(0xFF08111D),
        Color(0xFF05080E),
      ],
      glowColor: Color(0xFF0284C7),
      outputPosterFileName: ScreenshotPaths.store('ios_store_en_05_multidevice.png', lang: 'en'),
      outputScreenFileName: ScreenshotPaths.raw('ios_screen_en_05_multidevice.png', lang: 'en'),
    );

    await runTwoStageMobilePosterTest(
      tester: tester,
      posterConfig: posterConfig,
      screenChild: const SharingPage(),
      locale: const Locale('en'),
      overrides: [
        settingsServiceProvider.overrideWith((ref) => settingsService),
        sharingServiceProvider.overrideWith((ref) => MockSharingService(ref)),
        sharingServerStateProvider.overrideWith(() => MockSharingServerStateNotifier()),
        hostConnectedClientsProvider.overrideWith(() => MockHostConnectedClientsNotifier()),
        trustedDevicesProvider.overrideWith(() => MockTrustedDevicesNotifier()),
        discoveredDevicesProvider.overrideWith(
          (ref) => Stream.value(defaultMockDiscoveredDevices.take(3).toList()),
        ),
        audioCurrentMusicProvider.overrideWith((ref) => null),
        isProUnlockedProvider.overrideWith((ref) => true),
      ],
    );
  });
}
