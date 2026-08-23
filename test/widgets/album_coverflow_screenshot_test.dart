import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/pages/albums_tab.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/library/album_library.dart';
import 'package:vynody/player/pro/pro_license_service.dart';

import 'helpers/mobile_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Finished Store Poster 03 - 3D Cover Flow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = TestSettingsService(prefs);

    const basePath = '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music';
    final demoData = createDemoLibraryData(basePath: basePath);

    final activeSong = demoData.songs[3]; // '约定的红色夏天' - 晚风邮局

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
      tagText: '经典唱片美学',
      tagColor: Color(0xFFFBBF24),
      title: '唱片美学',
      subtitle: '3D Cover Flow · 极速分类与智能检索',
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
      outputPosterFileName: ScreenshotPaths.store('ios_store_03_coverflow.png'),
      outputScreenFileName: ScreenshotPaths.raw('ios_screen_03_coverflow.png'),
    );

    await runTwoStageMobilePosterTest(
      tester: tester,
      posterConfig: posterConfig,
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
}
