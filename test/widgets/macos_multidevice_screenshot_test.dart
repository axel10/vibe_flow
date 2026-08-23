// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/macos_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('macOS Store 05 - 多端互联 (Render Window & 2880x1800 Poster)', (tester) async {
    await loadMacosTestFonts();

    // 1. Prepare artwork and song data for bottom mini player
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
      saveWindowFileName: 'macos_window_05_multidevice.png',
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
      config: const MacosPosterConfig(
        tagText: '全平台安全互联',
        tagColor: Color(0xFF38BDF8),
        title: '多端互联',
        subtitle: 'TLS 端到端加密 · 局域网无损秒传与跨端遥控',
        backgroundGradient: [
          Color(0xFF0D1B2A),
          Color(0xFF08111D),
          Color(0xFF04060A),
        ],
        glowColors: [
          Color(0x3D38BDF8),
          Color(0x1C0284C7),
          Colors.transparent,
        ],
        outputFileName: 'macos_store_05_multidevice.png',
      ),
    );
  });
}
