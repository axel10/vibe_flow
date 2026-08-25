// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/macos_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('macOS Store 01 (EN) - Immersive Playback (Render Window & 2880x1800 Poster)', (tester) async {
    await loadMacosTestFonts();

    // 1. Prepare artwork and song data
    Uint8List? artworkBytes;
    const coverPath = '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_01.jpg';
    final coverFile = File(coverPath);
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    } else {
      final relativeCover = File('test_covers/cover_01.jpg');
      if (relativeCover.existsSync()) {
        artworkBytes = Uint8List.fromList(relativeCover.readAsBytesSync());
      }
    }

    const demoLrc = '''[00:00.00]Neon After Rain - Lin Zhou
[00:15.00](Intro)
[00:42.10]Raindrops blurring out the traffic lights
[00:46.35]We’re just shadows chasing compromised nights
[00:51.20]You said forever was a guaranteed thing
[00:55.80]But forever’s getting shorter, or so it seems
''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 1.8);
    const songPath =
        '/Users/axel10/Music/Vynody Music/Demo Music/en/Demo Music/01 - Neon After Rain.mp3';

    final demoSong = MusicFile(
      id: 1,
      path: songPath,
      name: '01 - Neon After Rain.mp3',
      title: 'Neon After Rain',
      artist: 'Lin Zhou',
      album: 'City Glimmer',
      durationMillis: 192000,
      artworkBytes: artworkBytes,
      waveformBlob: waveformBlob,
      lyrics: lyrics,
    );

    final currentPosition = const Duration(seconds: 84);

    final snapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: demoSong,
      position: currentPosition,
      duration: const Duration(seconds: 192),
      volume: 0.82,
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
      dynamicStartColor: const Color(0xFF00E676),
      dynamicEndColor: const Color(0xFF0A2318),
      currentThemeColorsMap: const {
        'darkVibrant': Color(0xFF00E676),
        'vibrant': Color(0xFF69F0AE),
        'dominant': Color(0xFF00C853),
        'darkMuted': Color(0xFF0D281E),
        'lightVibrant': Color(0xFFB9F6CA),
      },
      isLyricsActive: false,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    // 2. Capture 1080p native macOS App Window
    final windowBytes = await captureMacosWindow(
      tester: tester,
      song: demoSong,
      snapshot: snapshot,
      locale: const Locale('en'),
      saveWindowFileName: ScreenshotPaths.raw('macos_window_01_playback.png', lang: 'en'),
      configureSettings: (s) {
        s.visualizerColor = const Color(0xFFFFA066);
      },
    );

    // 3. Render 2880x1800 macOS Store Poster
    await renderMacosStorePoster(
      tester: tester,
      windowBytes: windowBytes,
      config: MacosPosterConfig(
        tagText: 'ALL-FORMAT LOSSLESS PLAYBACK',
        tagColor: const Color(0xFF69F0AE),
        title: 'Immersive Playback',
        subtitle: 'Pure Lossless Decoding · Dynamic Spectrum & Real-Time Waveforms',
        backgroundGradient: const [
          Color(0xFF0D241C),
          Color(0xFF081410),
          Color(0xFF030706),
        ],
        glowColors: const [
          Color(0x2E00E676),
          Color(0x1A00B0FF),
          Colors.transparent,
        ],
        outputFileName: ScreenshotPaths.store('macos_store_01_playback.png', lang: 'en'),
      ),
    );
  });

  testWidgets('macOS Store 02 (EN) - Focused Lyrics (Render Window & 2880x1800 Poster)', (tester) async {
    await loadMacosTestFonts();

    // 1. Prepare artwork and song data
    Uint8List? artworkBytes;
    const coverPath = '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_04.jpg';
    final coverFile = File(coverPath);
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    } else {
      final relativeCover = File('test_covers/cover_04.jpg');
      if (relativeCover.existsSync()) {
        artworkBytes = Uint8List.fromList(relativeCover.readAsBytesSync());
      }
    }

    const demoLrc = '''[00:00.00]Walking Home at Sunset - Soda Pop
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
[02:49.50]The road ahead is clear and bright''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 1.8);
    const songPath =
        '/Users/axel10/Music/Vynody Music/Demo Music/en/Demo Music/04 - Walking Home at Sunset.mp3';

    final demoSong = MusicFile(
      id: 4,
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

    // Active climax line: 01:15.00 "When the city slows its busy pace"
    final currentPosition = const Duration(seconds: 75);

    final snapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: demoSong,
      position: currentPosition,
      duration: const Duration(seconds: 251, milliseconds: 970),
      volume: 0.82,
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
      currentThemeColorsMap: const {
        'darkVibrant': Color(0xFFFF5252),
        'vibrant': Color(0xFFFF6E40),
        'dominant': Color(0xFFC83A3A),
        'darkMuted': Color(0xFF3E1C2B),
        'lightVibrant': Color(0xFFFFB4AB),
      },
      isLyricsActive: true,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    final lyricsState = LyricsControllerState(
      hasLyrics: true,
      currentLyricsLines: lyrics.syncedLines,
      lyricsTranslationLanguageCode: 'en',
    );

    // 2. Capture 1080p native macOS App Window
    final windowBytes = await captureMacosWindow(
      tester: tester,
      song: demoSong,
      snapshot: snapshot,
      lyricsState: lyricsState,
      lyrics: lyrics,
      locale: const Locale('en'),
      saveWindowFileName: ScreenshotPaths.raw('macos_window_02_lyrics.png', lang: 'en'),
      configureSettings: (s) {
        s.lyricsStyle = LyricsStyle.apple;
        s.collapseButtonsInLandscapeLyrics = true;
        s.visualizerColor = const Color(0xFFFF7272);
      },
    );

    // 3. Render 2880x1800 macOS Store Poster
    await renderMacosStorePoster(
      tester: tester,
      windowBytes: windowBytes,
      config: MacosPosterConfig(
        tagText: 'FULLSCREEN IMMERSIVE LYRICS',
        tagColor: const Color(0xFFFF8E72),
        title: 'Focused Lyrics',
        subtitle: 'Fluid Line-by-Line Flow · Dynamic Blur & Real-Time Sync',
        backgroundGradient: const [
          Color(0xFF201322),
          Color(0xFF100B17),
          Color(0xFF050408),
        ],
        glowColors: const [
          Color(0x3DC83A3A),
          Color(0x217A2062),
          Colors.transparent,
        ],
        outputFileName: ScreenshotPaths.store('macos_store_02_lyrics.png', lang: 'en'),
      ),
    );
  });

  testWidgets('macOS Store 03 (EN) - Album Gallery (Render Window & 2880x1800 Poster)', (tester) async {
    await loadMacosTestFonts();

    // 1. Prepare demo library data and active song
    const basePath = '/Users/axel10/Music/Vynody Music/Demo Music/en/Demo Music';
    final demoData = createDemoLibraryData(
      basePath: basePath,
      demoItems: defaultDemoListEn,
    );

    // Active featured album song: 'Walking Home at Sunset' - Soda Pop (Summer Slow Motion)
    final activeSong = demoData.songs[3];

    final snapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: activeSong,
      position: const Duration(seconds: 76),
      duration: Duration(milliseconds: activeSong.durationMillis ?? 251970),
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
      dynamicStartColor: const Color(0xFFF59E0B),
      dynamicEndColor: const Color(0xFF1E1528),
      currentThemeColorsMap: const {
        'darkVibrant': Color(0xFFF59E0B),
        'vibrant': Color(0xFFFBBF24),
        'dominant': Color(0xFFD97706),
        'darkMuted': Color(0xFF26180C),
        'lightVibrant': Color(0xFFFDE68A),
      },
      isLyricsActive: false,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    final scannerService = MockScannerService(
      rootFolders: [
        MusicFolder(path: basePath, name: 'Demo Music', files: demoData.songs),
      ],
      metadataMap: demoData.metadataMap,
    );

    // 2. Capture 1080p native macOS App Window
    final windowBytes = await captureMacosWindow(
      tester: tester,
      song: activeSong,
      snapshot: snapshot,
      initialIndex: 2,
      locale: const Locale('en'),
      customBody: const MainLayout(
        args: [],
        initialIndex: 2,
        initialLibraryTabIndex: 4,
        initialAlbums3DView: true,
        initialAlbums3DIndex: 9,
      ),
      scannerService: scannerService,
      extraOverrides: [
        albumLibraryProvider.overrideWith((ref) => Stream.value(demoData.albums)),
      ],
      saveWindowFileName: ScreenshotPaths.raw('macos_window_03_coverflow.png', lang: 'en'),
      configureSettings: (s) {
        s.visualizerColor = const Color(0xFFF59E0B);
      },
    );

    // 3. Render 2880x1800 macOS Store Poster
    await renderMacosStorePoster(
      tester: tester,
      windowBytes: windowBytes,
      config: MacosPosterConfig(
        tagText: 'CLASSIC VINYL AESTHETICS',
        tagColor: const Color(0xFFFBBF24),
        title: 'Album Gallery',
        subtitle: 'Classic 3D Album Wall · Swift Categorization & Smart Library',
        backgroundGradient: const [
          Color(0xFF26180C),
          Color(0xFF140D07),
          Color(0xFF070503),
        ],
        glowColors: const [
          Color(0x3DD97706),
          Color(0x1CF59E0B),
          Colors.transparent,
        ],
        outputFileName: ScreenshotPaths.store('macos_store_03_coverflow.png', lang: 'en'),
      ),
    );
  });

  testWidgets('macOS Store 04 (EN) - Studio Equalizer (Render Window & 2880x1800 Poster)', (tester) async {
    await loadMacosTestFonts();

    // 1. Prepare artwork and song data
    Uint8List? artworkBytes;
    final coverFile = File('/Volumes/Untitled/projects/vibe_flow/test_covers/03 - Moon at 2AM.jpg');
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

    const demoLrc = '''[00:00.00]Moon at 2AM - White Noise Forest
[00:15.00](Intro)
[00:42.10]City lights are slowly fading down
[00:46.35]Only moonlight dancing on the ground
[00:51.20]Through the headphones melodies unwound
[00:55.80]Every quiet story finally found
''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 2.1);
    const songPath =
        '/Users/axel10/Music/Vynody Music/Demo Music/en/Demo Music/03 - Moon at 2AM.mp3';

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

    final currentPosition = const Duration(seconds: 48, milliseconds: 200);

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

    final snapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: demoSong,
      position: currentPosition,
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
      currentThemeColorsMap: const {
        'darkVibrant': Color(0xFF0284C7),
        'vibrant': Color(0xFF38BDF8),
        'dominant': Color(0xFF0369A1),
        'darkMuted': Color(0xFF0F172A),
        'lightVibrant': Color(0xFFBAE6FD),
      },
      isLyricsActive: false,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    final lyricsState = LyricsControllerState(
      hasLyrics: true,
      currentLyricsLines: lyrics.syncedLines,
      lyricsTranslationLanguageCode: 'en',
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

    // 2. Capture 1080p native macOS App Window with Equalizer Panel floating over Playback view
    final windowBytes = await captureMacosWindow(
      tester: tester,
      song: demoSong,
      snapshot: snapshot,
      lyricsState: lyricsState,
      lyrics: lyrics,
      initialIndex: 1,
      locale: const Locale('en'),
      customBody: const Stack(
        fit: StackFit.expand,
        children: [
          MainLayout(
            args: [],
            initialIndex: 1,
          ),
          EqualizerPanel(),
        ],
      ),
      scannerService: scannerService,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF38BDF8),
        brightness: Brightness.dark,
      ),
      saveWindowFileName: ScreenshotPaths.raw('macos_window_04_equalizer.png', lang: 'en'),
      configureSettings: (s) {
        s.equalizerBandCount = 10;
        s.visualizerColor = const Color(0xFF38BDF8);
      },
    );

    // 3. Render 2880x1800 macOS Store Poster
    await renderMacosStorePoster(
      tester: tester,
      windowBytes: windowBytes,
      config: MacosPosterConfig(
        tagText: 'STUDIO ACOUSTIC ENGINE',
        tagColor: const Color(0xFF38BDF8),
        title: 'Studio Equalizer',
        subtitle: '5~20 Band Precision EQ · Rich Acoustic Presets & Bass Boost',
        backgroundGradient: const [
          Color(0xFF0E1A30),
          Color(0xFF08101D),
          Color(0xFF04060A),
        ],
        glowColors: const [
          Color(0x3D38BDF8),
          Color(0x1C6366F1),
          Colors.transparent,
        ],
        outputFileName: ScreenshotPaths.store('macos_store_04_equalizer.png', lang: 'en'),
      ),
    );
  });

  testWidgets('macOS Store 05 (EN) - Multi-Device Hub (Render Window & 2880x1800 Poster)', (tester) async {
    await loadMacosTestFonts();

    // 1. Prepare artwork and song data for bottom mini player
    Uint8List? artworkBytes;
    final coverFile = File('/Volumes/Untitled/projects/vibe_flow/test_covers/03 - Moon at 2AM.jpg');
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

    const demoLrc = '''[00:00.00]Moon at 2AM - White Noise Forest
[00:15.00](Intro)
[00:42.10]City lights are slowly fading down
[00:46.35]Only moonlight dancing on the ground
[00:51.20]Through the headphones melodies unwound
[00:55.80]Every quiet story finally found
''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 2.1);
    const songPath =
        '/Users/axel10/Music/Vynody Music/Demo Music/en/Demo Music/03 - Moon at 2AM.mp3';

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
      dynamicStartColor: const Color(0xFF38BDF8),
      dynamicEndColor: const Color(0xFF0F172A),
      currentThemeColorsMap: const {
        'darkVibrant': Color(0xFF0284C7),
        'vibrant': Color(0xFF38BDF8),
        'dominant': Color(0xFF0369A1),
        'darkMuted': Color(0xFF0F172A),
        'lightVibrant': Color(0xFFBAE6FD),
      },
      isLyricsActive: false,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
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

    // 2. Capture 1080p native macOS App Window on Sharing Page (Tab Index 4)
    final windowBytes = await captureMacosWindow(
      tester: tester,
      song: demoSong,
      snapshot: snapshot,
      initialIndex: 4,
      locale: const Locale('en'),
      scannerService: scannerService,
      extraOverrides: [
        sharingServiceProvider.overrideWith((ref) => MockSharingService(ref)),
        sharingServerStateProvider.overrideWith(() => MockSharingServerStateNotifier()),
        hostConnectedClientsProvider.overrideWith(() => MockHostConnectedClientsNotifier()),
        trustedDevicesProvider.overrideWith(() => MockTrustedDevicesNotifier()),
        discoveredDevicesProvider.overrideWith(
          (ref) => Stream.value(defaultMacosDiscoveredDevices),
        ),
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF38BDF8),
        brightness: Brightness.dark,
      ),
      saveWindowFileName: ScreenshotPaths.raw('macos_window_05_multidevice.png', lang: 'en'),
      configureSettings: (s) {
        s.lanSharingEnabled = true;
        s.allowRemoteControl = true;
        s.lanSharingFolderPath = '/Users/axel10/Music/Vynody Music';
        s.visualizerColor = const Color(0xFF38BDF8);
      },
    );

    // 3. Render 2880x1800 macOS Store Poster
    await renderMacosStorePoster(
      tester: tester,
      windowBytes: windowBytes,
      config: MacosPosterConfig(
        tagText: 'CROSS-PLATFORM SECURE SYNC',
        tagColor: const Color(0xFF38BDF8),
        title: 'Multi-Device Hub',
        subtitle: 'End-to-End TLS Encryption · Lossless LAN Transfer & Remote Play',
        backgroundGradient: const [
          Color(0xFF0D1B2A),
          Color(0xFF08111D),
          Color(0xFF04060A),
        ],
        glowColors: const [
          Color(0x3D38BDF8),
          Color(0x1C0284C7),
          Colors.transparent,
        ],
        outputFileName: ScreenshotPaths.store('macos_store_05_multidevice.png', lang: 'en'),
      ),
    );
  });
}
