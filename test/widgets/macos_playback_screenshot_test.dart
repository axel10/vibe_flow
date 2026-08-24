// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/macos_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('macOS Store 01 - 沉浸播放 (Render Window & 2880x1800 Poster)', (tester) async {
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

    const demoLrc = '''[00:00.00]雨后霓虹 - 林舟
[00:15.00](Intro)
[00:42.10]Raindrops blurring out the traffic lights
[00:46.35]We’re just shadows chasing compromised nights
[00:51.20]You said forever was a guaranteed thing
[00:55.80]But forever’s getting shorter, or so it seems
''';

    final lyrics = parseLrc(demoLrc);
    final waveformBlob = generateRealisticWaveform(128, seed: 1.8);
    const songPath =
        '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music/01 - Neon After Rain.mp3';

    final demoSong = MusicFile(
      id: 1,
      path: songPath,
      name: '01 - Neon After Rain.mp3',
      title: '雨后霓虹',
      artist: '林舟',
      album: '城市微光',
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
      saveWindowFileName: ScreenshotPaths.raw('macos_window_01_playback.png'),
      configureSettings: (s) {
        s.visualizerColor = const Color(0xFFFFA066);
      },
    );

    // 3. Render 2880x1800 macOS Store Poster
    await renderMacosStorePoster(
      tester: tester,
      windowBytes: windowBytes,
      config: MacosPosterConfig(
        tagText: '全格式无损播放',
        tagColor: const Color(0xFF69F0AE),
        title: '沉浸播放',
        subtitle: '全格式无损解码 · 灵动频谱与实时声学波形',
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
        outputFileName: ScreenshotPaths.store('macos_store_01_playback.png'),
      ),
    );
  });
}
