// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/macos_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('macOS Store 04 - 专业调音 (Render Window & 2880x1800 Poster)', (tester) async {
    await loadMacosTestFonts();

    // 1. Prepare artwork and song data
    Uint8List? artworkBytes;
    final coverFile = File('/Volumes/Untitled/projects/vibe_flow/test_covers/03 - Moon at 2AM.jpg');
    if (coverFile.existsSync()) {
      artworkBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

    const demoLrc = '''[00:00.00]凌晨两点的月亮 - 白噪森林
[00:15.00](Intro)
[00:42.10]整座城市慢慢熄灭了灯火
[00:46.35]只剩月光悄悄穿过百叶窗
[00:51.20]耳机里循环着不眠的旋律
[00:55.80]把那些没说出口的话慢慢写完
''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 2.1);
    const songPath =
        '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music/03 - Moon at 2AM.mp3';

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
      lyricsTranslationLanguageCode: 'zh',
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

    // 2. Capture 1080p native macOS App Window with Equalizer Panel floating over Playback view
    final windowBytes = await captureMacosWindow(
      tester: tester,
      song: demoSong,
      snapshot: snapshot,
      lyricsState: lyricsState,
      lyrics: lyrics,
      initialIndex: 1,
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
      saveWindowFileName: 'macos_window_04_equalizer.png',
      configureSettings: (s) {
        s.equalizerBandCount = 10;
        s.visualizerColor = const Color(0xFF38BDF8);
      },
    );

    // 3. Render 2880x1800 macOS Store Poster
    await renderMacosStorePoster(
      tester: tester,
      windowBytes: windowBytes,
      config: const MacosPosterConfig(
        tagText: '专业声学引擎',
        tagColor: Color(0xFF38BDF8),
        title: '专业调音',
        subtitle: '5~20 段高精度 EQ · 丰富声学预设与低音增强',
        backgroundGradient: [
          Color(0xFF0E1A30),
          Color(0xFF08101D),
          Color(0xFF04060A),
        ],
        glowColors: [
          Color(0x3D38BDF8),
          Color(0x1C6366F1),
          Colors.transparent,
        ],
        outputFileName: 'macos_store_04_equalizer.png',
      ),
    );
  });
}
