import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/pages/playback_page.dart';
import 'package:vynody/player/lyrics/lyrics_riverpod.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/widgets/equalizer_panel.dart';

import 'helpers/mobile_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Finished Store Poster 04 - Equalizer Pro Tuning', (tester) async {
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
    const coverPath = '/Volumes/Untitled/projects/vibe_flow/test_covers/03 - Moon at 2AM.jpg';

    Uint8List? artworkBytes;
    final coverFile = File(coverPath);
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

    const demoLrc = '''
[00:00.00]凌晨两点的月亮 - 白噪森林
[00:15.00](Intro)
[00:42.10]整座城市慢慢熄灭了灯火
[00:46.35]只剩月光悄悄穿过百叶窗
[00:51.20]耳机里循环着不眠的旋律
[00:55.80]把那些没说出口的话慢慢写完
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

    const posterConfig = MobilePosterConfig(
      tagText: 'Hi-Fi 级 10段 / 31段 EQ',
      tagColor: Color(0xFF38BDF8),
      title: '专业均衡器',
      subtitle: '低延迟原生音频引擎 · 动态增益补偿与预设',
      backgroundGradient: [
        Color(0xFF0C192E),
        Color(0xFF08101E),
        Color(0xFF060913),
      ],
      glowColor: Color(0xFF38BDF8),
      outputPosterFileName: 'ios_store_04_equalizer.png',
      outputScreenFileName: 'ios_screen_04_equalizer.png',
    );

    await runTwoStageMobilePosterTest(
      tester: tester,
      posterConfig: posterConfig,
      initialFftFrame: fftFrame,
      visualizerStreamController: visualizerStreamController,
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
}
