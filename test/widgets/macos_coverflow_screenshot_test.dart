// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/macos_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('macOS Store 03 - 唱片画廊 (Render Window & 2880x1800 Poster)', (tester) async {
    await loadMacosTestFonts();

    // 1. Prepare demo library data and active song
    const basePath = '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music';
    final demoData = createDemoLibraryData(basePath: basePath);

    // Active featured album song: '把这一天留给你' - 晚风邮局 (约定的红色夏天)
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
      saveWindowFileName: 'macos_window_03_coverflow.png',
      configureSettings: (s) {
        s.visualizerColor = const Color(0xFFF59E0B);
      },
    );

    // 3. Render 2880x1800 macOS Store Poster
    await renderMacosStorePoster(
      tester: tester,
      windowBytes: windowBytes,
      config: const MacosPosterConfig(
        tagText: '经典唱片美学',
        tagColor: Color(0xFFFBBF24),
        title: '唱片画廊',
        subtitle: '经典 3D 唱片墙 · 极速分类与智能曲库管理',
        backgroundGradient: [
          Color(0xFF26180C),
          Color(0xFF140D07),
          Color(0xFF070503),
        ],
        glowColors: [
          Color(0x3DD97706),
          Color(0x1CF59E0B),
          Colors.transparent,
        ],
        outputFileName: 'macos_store_03_coverflow.png',
      ),
    );
  });
}
