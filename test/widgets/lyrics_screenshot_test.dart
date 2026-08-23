import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/pages/playback_page.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/lyrics/lyrics_riverpod.dart';
import 'package:vynody/player/pro/pro_license_service.dart';

import 'helpers/mobile_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Finished Store Poster 02 - Fullscreen Lyrics Mode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = TestSettingsService(prefs);

    settingsService.hasShownCoverTapLyricTip = true;
    settingsService.hasShownLyricsMenuTip = true;
    settingsService.isWaveformProgressBarEnabled = true;
    settingsService.lyricsStyle = LyricsStyle.apple;
    settingsService.lyricsTranslationTargetLanguageCode = 'zh';

    Uint8List? artworkBytes;
    final coverFile = File('/tmp/demo_zh_cover.jpg');
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    } else {
      final fallbackCover = File('/Users/axel10/.gemini/antigravity-ide/brain/50a333f4-8920-4e32-aa9b-ddecce8faeaf/demo_cover_04.jpg');
      if (fallbackCover.existsSync()) {
        artworkBytes = Uint8List.fromList(fallbackCover.readAsBytesSync());
      }
    }

    const demoLrc = '''
[00:00.00]《把这一天留给你》
[00:16.00]街角的风吹过红色的墙
[00:20.50]阳光落在旧信纸上
[00:24.80]你写下一个日期
[00:28.90]却没有告诉我理由是什么
[00:34.80]我把那一天圈了又圈
[00:39.20]像害怕它会突然走远
[00:43.60]窗外云朵慢慢变淡
[00:47.80]心里的期待却越来越明显
[00:53.50]如果你也在等
[00:57.40]那就让我听见
[01:01.60]藏在晚风里面
[01:05.70]没有说完的语言
[01:11.20]我把这一天留给你
[01:15.70]把所有温柔都写进日期
[01:20.20]等钟声响起
[01:23.50]等你出现在我眼里
[01:28.90]我把这一天留给你
[01:33.30]不管晴天还是下着小雨
[01:37.90]只要你愿意
[01:41.20]我们就从这里开始相遇
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

    // Climax position: chorus 01:15.70
    final currentPosition = const Duration(seconds: 75, milliseconds: 700);

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

    const posterConfig = MobilePosterConfig(
      tagText: '双语同步与逐字光效',
      tagColor: Color(0xFFFDA4AF),
      title: '动感歌词',
      subtitle: 'Apple Music 级丝滑滚动 · 本地 AI 实时翻译与精细对齐',
      backgroundGradient: [
        Color(0xFF220F18),
        Color(0xFF130911),
        Color(0xFF07070B),
      ],
      glowColor: Color(0xFFE11D48),
      outputPosterFileName: 'ios_store_02_lyrics.png',
      outputScreenFileName: 'ios_screen_02_lyrics.png',
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
        lyricsControllerProvider.overrideWith(() => lyricsController),
        isEffectiveWaveformEnabledProvider.overrideWith((ref) => true),
        isProUnlockedProvider.overrideWith((ref) => true),
        scannerServiceProvider.overrideWith((ref) => scannerService),
      ],
    );

    await visualizerStreamController.close();
  });
}
