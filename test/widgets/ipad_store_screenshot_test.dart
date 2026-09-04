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

import 'helpers/ipad_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate iPad Store Poster 01 (ZH) - 沉浸播放', (tester) async {
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
[00:00.00]把这一天留给你 - 晚风邮局
[00:15.00](前奏吉他与微风)
[00:42.10]雨滴模糊了街角的红绿灯
[00:46.35]我们在夜色里追逐微小的光
[00:51.20]你说永远是一件确定的事情
[00:55.80]但时间总在不经意间悄悄溜走
''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 1.8);

    final demoSong = MusicFile(
      path: '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music/04 - Walking Home at Sunset.mp3',
      name: '04 - Walking Home at Sunset.mp3',
      title: '把这一天留给你',
      artist: '晚风邮局',
      album: '约定的红色夏天',
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
        MusicFolder(path: '/demo_zh', name: 'Demo Music', files: [demoSong])
      ],
    );

    final posterConfig = IpadPosterConfig(
      tagText: '全格式无损播放',
      tagColor: const Color(0xFFFDBA74),
      title: '沉浸播放',
      subtitle: '全格式无损解码 · 灵动频谱与实时声学波形',
      backgroundGradient: const [
        Color(0xFF181124),
        Color(0xFF0D0F18),
        Color(0xFF06070B),
      ],
      glowColor: const Color(0xFFE2824A),
      outputPosterFileName: ScreenshotPaths.store('ipad_store_01_playback.png', lang: 'zh'),
      outputScreenFileName: ScreenshotPaths.raw('ipad_screen_01_playback.png', lang: 'zh'),
    );

    await runTwoStageIpadPosterTest(
      tester: tester,
      posterConfig: posterConfig,
      screenChild: const PlaybackPage(),
      initialFftFrame: fftFrame,
      visualizerStreamController: visualizerStreamController,
      locale: const Locale('zh'),
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

  testWidgets('Generate iPad Store Poster 02 (ZH) - 动感歌词', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = TestSettingsService(prefs);

    settingsService.hasShownCoverTapLyricTip = true;
    settingsService.hasShownLyricsMenuTip = true;
    settingsService.isWaveformProgressBarEnabled = true;
    settingsService.lyricsStyle = LyricsStyle.apple;
    settingsService.lyricsTranslationTargetLanguageCode = 'zh';

    Uint8List? artworkBytes;
    final coverFile = File('/Volumes/Untitled/projects/vibe_flow/test_covers/cover_04.jpg');
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

    const demoLrc = '''
[00:00.00]把这一天留给你 - 晚风邮局
[00:12.00]街角的风吹过红色的墙
[00:16.50]阳光落在旧信纸上
[00:21.00]你写下一个日期
[00:25.50]却没有告诉我理由是什么
[00:30.00]我把那一天圈了又圈
[00:34.50]像害怕它会突然走远
[00:39.00]窗外云朵慢慢变淡
[00:43.50]心里的期待却越来越明显
[00:48.00]如果你也在等
[00:52.50]那就让我听见
[00:57.00]藏在晚风里面
[01:01.50]没有说完的语言
[01:06.00]我把这一天留给你
[01:10.50]把所有温柔都写进日期
[01:15.00]等钟声响起
[01:19.50]等你出现在我眼里
[01:24.00]我把这一天留给你
[01:28.50]不管晴天还是下着小雨
[01:33.00]只要你愿意
[01:37.50]我们就从这里开始相遇
''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 1.8);

    const songPath = '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music/04 - Walking Home at Sunset.mp3';
    final demoSong = MusicFile(
      path: songPath,
      name: '04 - Walking Home at Sunset.mp3',
      title: '把这一天留给你',
      artist: '晚风邮局',
      album: '约定的红色夏天',
      durationMillis: 251970,
      artworkBytes: artworkBytes,
      waveformBlob: waveformBlob,
      lyrics: lyrics,
    );

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
        MusicFolder(path: '/demo_zh', name: 'Demo Music', files: [demoSong])
      ],
    );

    final lyricsState = LyricsControllerState(
      hasLyrics: true,
      currentLyricsLines: lyrics.syncedLines,
      lyricsTranslationLanguageCode: 'zh',
    );

    final lyricsController = MockLyricsController(
      initialState: lyricsState,
      lyrics: lyrics,
    );

    final posterConfig = IpadPosterConfig(
      tagText: '双语同步与逐字光效',
      tagColor: const Color(0xFFFDA4AF),
      title: '动感歌词',
      subtitle: '逐行平滑滚动 · 本地 AI 实时翻译与精细对齐',
      backgroundGradient: const [
        Color(0xFF220F18),
        Color(0xFF130911),
        Color(0xFF07070B),
      ],
      glowColor: const Color(0xFFE11D48),
      outputPosterFileName: ScreenshotPaths.store('ipad_store_02_lyrics.png', lang: 'zh'),
      outputScreenFileName: ScreenshotPaths.raw('ipad_screen_02_lyrics.png', lang: 'zh'),
    );

    await runTwoStageIpadPosterTest(
      tester: tester,
      posterConfig: posterConfig,
      screenChild: const PlaybackPage(),
      initialFftFrame: fftFrame,
      visualizerStreamController: visualizerStreamController,
      locale: const Locale('zh'),
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

  testWidgets('Generate iPad Store Poster 03 (ZH) - 3D 唱片墙', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = TestSettingsService(prefs);

    const basePath = '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music';
    final demoData = createDemoLibraryData(
      basePath: basePath,
      demoItems: defaultDemoList,
    );

    final activeSong = demoData.songs[3];

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

    final posterConfig = IpadPosterConfig(
      tagText: '沉浸式唱片架',
      tagColor: const Color(0xFFFBBF24),
      title: '3D 唱片墙',
      subtitle: '经典拟物黑胶唱片架 · 丝滑翻转与视觉触感',
      backgroundGradient: const [
        Color(0xFF241508),
        Color(0xFF130E0A),
        Color(0xFF070605),
      ],
      glowColor: const Color(0xFFD97706),
      screenBackgroundColor: const Color(0xFF140E0A),
      screenColorScheme: const ColorScheme.dark(
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
      outputPosterFileName: ScreenshotPaths.store('ipad_store_03_coverflow.png', lang: 'zh'),
      outputScreenFileName: ScreenshotPaths.raw('ipad_screen_03_coverflow.png', lang: 'zh'),
    );

    await runTwoStageIpadPosterTest(
      tester: tester,
      posterConfig: posterConfig,
      locale: const Locale('zh'),
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

  testWidgets('Generate iPad Store Poster 04 (ZH) - 专业均衡器', (tester) async {
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

    const songPath = '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music/03 - Moon at 2AM.mp3';
    const coverPath = '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_03.jpg';

    Uint8List? artworkBytes;
    final coverFile = File(coverPath);
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

    const demoLrc = '''
[00:00.00]凌晨两点的月亮 - 白噪森林
[00:15.00](前奏)
[00:42.10]城市的灯光渐渐熄灭
[00:46.35]只有月光在地上跳舞
[00:51.20]耳机里回荡着熟悉的旋律
[00:55.80]所有安静的故事终于被听见
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
      title: '凌晨两点的月亮',
      artist: '白噪森林',
      album: '不眠电台',
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
          path: '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music',
          name: 'Demo Music',
          files: [demoSong],
        ),
      ],
      metadataMap: {
        songPath: SongMetadata(
          id: 3,
          path: songPath,
          title: '凌晨两点的月亮',
          artist: '白噪森林',
          album: '不眠电台',
          duration: 225018,
        ),
      },
    );

    final posterConfig = IpadPosterConfig(
      tagText: '专业声学引擎',
      tagColor: const Color(0xFF38BDF8),
      title: '专业调音',
      subtitle: '5~20 段高精度 EQ · 定制专属声学曲线',
      backgroundGradient: const [
        Color(0xFF0C192E),
        Color(0xFF08101E),
        Color(0xFF060913),
      ],
      glowColor: const Color(0xFF38BDF8),
      outputPosterFileName: ScreenshotPaths.store('ipad_store_04_equalizer.png', lang: 'zh'),
      outputScreenFileName: ScreenshotPaths.raw('ipad_screen_04_equalizer.png', lang: 'zh'),
    );

    await runTwoStageIpadPosterTest(
      tester: tester,
      posterConfig: posterConfig,
      initialFftFrame: fftFrame,
      visualizerStreamController: visualizerStreamController,
      locale: const Locale('zh'),
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

  testWidgets('Generate iPad Store Poster 05 (ZH) - 跨设备互联', (tester) async {
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

    final posterConfig = IpadPosterConfig(
      tagText: '多端无线局域网传输',
      tagColor: const Color(0xFF38BDF8),
      title: '跨设备互联',
      subtitle: '端到端加密无线互联 · 无损局域网同步与多端遥控',
      backgroundGradient: const [
        Color(0xFF0D1B2A),
        Color(0xFF08111D),
        Color(0xFF05080E),
      ],
      glowColor: const Color(0xFF0284C7),
      outputPosterFileName: ScreenshotPaths.store('ipad_store_05_multidevice.png', lang: 'zh'),
      outputScreenFileName: ScreenshotPaths.raw('ipad_screen_05_multidevice.png', lang: 'zh'),
    );

    await runTwoStageIpadPosterTest(
      tester: tester,
      posterConfig: posterConfig,
      screenChild: const SharingPage(),
      locale: const Locale('zh'),
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
