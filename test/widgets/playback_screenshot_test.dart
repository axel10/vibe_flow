import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/pages/playback_page.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/pro/pro_license_service.dart';

import 'helpers/mobile_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Finished Store Poster 01 - Immersive Playback', (tester) async {
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
    final coverFile = File('/Users/axel10/.gemini/antigravity-ide/brain/50a333f4-8920-4e32-aa9b-ddecce8faeaf/demo_cover_04.jpg');
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
        MusicFolder(path: '/demo', name: 'Demo Music', files: [demoSong])
      ],
    );

    final posterConfig = MobilePosterConfig(
      tagText: '全格式无损播放',
      tagColor: Color(0xFFFDBA74),
      title: '沉浸播放',
      subtitle: '全格式无损解码 · 灵动频谱与实时声学波形',
      backgroundGradient: [
        Color(0xFF181124),
        Color(0xFF0D0F18),
        Color(0xFF06070B),
      ],
      glowColor: Color(0xFFE2824A),
      outputPosterFileName: ScreenshotPaths.store('ios_store_01_playback.png'),
      outputScreenFileName: ScreenshotPaths.raw('ios_screen_01_playback.png'),
    );

    await runTwoStageMobilePosterTest(
      tester: tester,
      posterConfig: posterConfig,
      screenChild: const PlaybackPage(),
      initialFftFrame: fftFrame,
      visualizerStreamController: visualizerStreamController,
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
}
