// ignore_for_file: avoid_print, override_on_non_overriding_member
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:audio_core/audio_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/models/lyric_line.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/models/music_lyric.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/audio/audio_snapshot.dart';
import 'package:vynody/player/audio/equalizer_presets.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/scanner/scanner_service.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/widgets/equalizer_panel.dart';

Future<void> _loadFonts() async {
  final iconFontFile = File(
    '/Users/axel10/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (iconFontFile.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons');
    iconLoader.addFont(
      Future.value(ByteData.sublistView(iconFontFile.readAsBytesSync())),
    );
    await iconLoader.load();
  }

  final unicodeFontFile = File(
    '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
  );
  if (unicodeFontFile.existsSync()) {
    final bytes = unicodeFontFile.readAsBytesSync();
    for (final family in [
      'Roboto',
      'Arial Unicode MS',
      '.SF UI Text',
      '.SF UI Display',
      'PingFang SC',
      'Segoe UI',
      'Microsoft YaHei UI',
      'Microsoft YaHei',
      'Heiti SC',
      'sans-serif',
      '',
    ]) {
      final loader = FontLoader(family);
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
  }
}

Uint8List _generateRealisticWaveform(int length, {double seed = 1.0}) {
  final floats = Float32List(length);
  for (int i = 0; i < length; i++) {
    final x = i / length;
    final envelope = (math.sin(x * math.pi) * 0.7 + 0.3);
    final beat = (math.sin(x * 28.0 * math.pi * seed).abs() * 0.45);
    final detail = (math.sin(x * 96.0 * math.pi * (seed + 0.4)).abs() * 0.25);
    final noise =
        ((math.Random(i * 19 + (seed * 100).toInt()).nextDouble()) * 0.2);
    final value =
        ((envelope * (0.35 + beat + detail) + noise) * 0.95).clamp(0.08, 1.0);
    floats[i] = value;
  }
  return floats.buffer.asUint8List();
}

List<double> _generateFftBandsDefault({int count = 100, double energy = 0.88}) {
  final bands = <double>[];
  for (int i = 0; i < count; i++) {
    final freqFactor = math.pow(1.0 - (i / count), 0.65).toDouble();
    final bounce = math.sin((i * 0.25) + 1.1).abs() * 0.4 + 0.45;
    final value = (freqFactor * bounce * energy).clamp(0.04, 0.96);
    bands.add(value);
  }
  return bands;
}

MusicLyric _parseLrc(String lrcContent) {
  final lines = <LyricLine>[];
  final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
  for (final rawLine in lrcContent.split('\n')) {
    final match = regex.firstMatch(rawLine.trim());
    if (match != null) {
      final min = int.parse(match.group(1)!);
      final sec = int.parse(match.group(2)!);
      final msStr = match.group(3)!;
      final ms = int.parse(msStr.padRight(3, '0').substring(0, 3));
      final totalMs = min * 60000 + sec * 1000 + ms;
      final text = match.group(4)!.trim();
      if (text.isNotEmpty) {
        lines.add(
          LyricLine(timestamp: Duration(milliseconds: totalMs), text: text),
        );
      }
    }
  }
  return MusicLyric(syncedLines: lines);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Finished Store Poster 04 - Equalizer Pro Tuning', (
    tester,
  ) async {
    await _loadFonts();

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);

    settingsService.hasShownCoverTapLyricTip = true;
    settingsService.isWaveformProgressBarEnabled = true;
    settingsService.portraitFrequencyGroups = 100;
    settingsService.visualizerStyle = VisualizerStyle.bars;
    settingsService.visualizerOpacity = VisualizerStyle.bars.defaultOpacity;
    settingsService.isVisualizerDynamicColor = true;
    settingsService.equalizerBandCount = 10;

    final songPath =
        '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music/03 - Moon at 2AM.mp3';
    final coverPath =
        '/Volumes/Untitled/projects/vibe_flow/test_covers/03 - Moon at 2AM.jpg';

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

    final lyrics = _parseLrc(demoLrc);
    final waveformBlob = _generateRealisticWaveform(128, seed: 2.1);

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
      thumbnailPath: coverPath,
      artworkPath: coverPath,
    );

    final fftValues = _generateFftBandsDefault(count: 100, energy: 0.85);
    final fftFrame = FftFrame(
      position: const Duration(seconds: 48, milliseconds: 200),
      values: fftValues,
      isPlaying: true,
    );

    // Hi-Fi Gains: [5.0, 3.0, 0.0, -1.0, 0.0, 0.0, 0.0, -1.0, 2.0, 5.0]
    final eqGains = Float32List.fromList(
      EqualizerPresets.hifi.referenceGains,
    );

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
      currentVisualizerOptions: VisualizerOptimizationOptions(
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
    final audioService = _MockAudioService(
      mockSnapshot: snapshot,
      artworkBytes: artworkBytes,
      mockVisualizerStream: visualizerStreamController.stream,
    );

    final scannerService = _MockScannerService(
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
          thumbnailPath: coverPath,
          artworkPath: coverPath,
        ),
      },
    );

    final posterRepaintKey = GlobalKey();
    final deviceScreenRepaintKey = GlobalKey();

    // Standard Store Poster: 1290 x 2796 (iPhone 6.7" Super Retina XDR @ 3x)
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      rpod.ProviderScope(
        overrides: [
          settingsServiceProvider.overrideWith((ref) => settingsService),
          audioServiceProvider.overrideWith((ref) => audioService),
          audioSnapshotProvider.overrideWith((ref) => snapshot),
          isEffectiveWaveformEnabledProvider.overrideWith((ref) => true),
          isProUnlockedProvider.overrideWith((ref) => true),
          scannerServiceProvider.overrideWith((ref) => scannerService),
        ],
        child: OKToast(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Arial Unicode MS',
              fontFamilyFallback: const [
                'Arial Unicode MS',
                'PingFang SC',
                'Segoe UI',
                'Microsoft YaHei',
                'Heiti SC',
                'Roboto',
                'sans-serif',
              ],
              scaffoldBackgroundColor: const Color(0xFF07090E),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF38BDF8),
                primaryContainer: Color(0xFF0369A1),
                surface: Color(0xFF0D0F18),
                surfaceContainerHighest: Color(0xFF1E293B),
                onSurfaceVariant: Color(0xFF94A3B8),
              ),
            ),
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              backgroundColor: const Color(0xFF08090D),
              body: RepaintBoundary(
                key: posterRepaintKey,
                child: Container(
                  width: 430,
                  height: 932,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF081C38),
                        Color(0xFF091224),
                        Color(0xFF04060B),
                      ],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Ambient Glow behind device
                      Positioned(
                        top: 210,
                        child: Container(
                          width: 360,
                          height: 360,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF0284C7).withValues(alpha: 0.32),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Top Marketing Typography from 宣传图文案.md
                      Positioned(
                        top: 54,
                        left: 24,
                        right: 24,
                        child: Column(
                          children: [
                            // Tag badge: 专业声学引擎
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: const Text(
                                '专业声学引擎',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF38BDF8),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Main Title: 专业调音
                            const Text(
                              '专业调音',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Subtitle: 5~20 段高精度 EQ · 定制专属声学曲线
                            Text(
                              '5~20 段高精度 EQ · 定制专属声学曲线',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.68),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Framed Phone Device with Drop Shadow
                      Positioned(
                        top: 185,
                        left: 28,
                        right: 28,
                        bottom: -80,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(44),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.68),
                                blurRadius: 38,
                                spreadRadius: 4,
                                offset: const Offset(0, 18),
                              ),
                              BoxShadow(
                                color: const Color(
                                  0xFF0284C7,
                                ).withValues(alpha: 0.22),
                                blurRadius: 44,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(44),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF424E60),
                                  width: 3.5,
                                ),
                                borderRadius: BorderRadius.circular(44),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: RepaintBoundary(
                                  key: deviceScreenRepaintKey,
                                  child: Stack(
                                    children: [
                                      // 1. Full Gaussian blurred album cover of 03 - Moon at 2AM
                                      if (artworkBytes != null)
                                        Positioned.fill(
                                          child: Image.memory(
                                            artworkBytes,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      Positioned.fill(
                                        child: BackdropFilter(
                                          filter: ui.ImageFilter.blur(
                                            sigmaX: 55,
                                            sigmaY: 55,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.38),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 2. Pure Equalizer Panel
                                      Positioned.fill(
                                        child: Builder(
                                          builder:
                                              (ctx) => MediaQuery(
                                                data: MediaQuery.of(
                                                  ctx,
                                                ).copyWith(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 44,
                                                        bottom: 34,
                                                      ),
                                                  viewPadding:
                                                      const EdgeInsets.only(
                                                        top: 44,
                                                        bottom: 34,
                                                      ),
                                                ),
                                                child: const EqualizerPanel(),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.runAsync(() async {
      visualizerStreamController.add(fftFrame);
      await Future.delayed(const Duration(milliseconds: 300));
    });

    visualizerStreamController.add(fftFrame);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Capture outputs
    final posterBoundary =
        posterRepaintKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (posterBoundary != null) {
      final image = await posterBoundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final outPoster1 =
            '/Users/axel10/.gemini/antigravity-ide/brain/ee82e312-9346-4477-b534-f2f7b352b68f/store_finished_mockup_04.png';
        final outPoster2 =
            '/Volumes/Untitled/projects/vibe_flow/screenshots/store_mockup_04_equalizer.png';

        File(outPoster1).parent.createSync(recursive: true);
        File(outPoster2).parent.createSync(recursive: true);
        File(outPoster1).writeAsBytesSync(pngBytes);
        File(outPoster2).writeAsBytesSync(pngBytes);
        print('SUCCESS_POSTER_SAVED: $outPoster2 (${pngBytes.length} bytes)');
      }
    }

    final screenBoundary =
        deviceScreenRepaintKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (screenBoundary != null) {
      final image = await screenBoundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final outScreen1 =
            '/Users/axel10/.gemini/antigravity-ide/brain/ee82e312-9346-4477-b534-f2f7b352b68f/equalizer_ios_raw.png';
        final outScreen2 =
            '/Volumes/Untitled/projects/vibe_flow/screenshots/equalizer_ios_raw.png';

        File(outScreen1).writeAsBytesSync(pngBytes);
        File(outScreen2).writeAsBytesSync(pngBytes);
        print('SUCCESS_RAW_SCREEN_SAVED: $outScreen2 (${pngBytes.length} bytes)');
      }
    }

    print('ALL_DONE_EXITING');
    exit(0);
  });
}

class _MockAudioService extends AudioService {
  _MockAudioService({
    required this.mockSnapshot,
    this.artworkBytes,
    required this.mockVisualizerStream,
  });

  final AudioSnapshot mockSnapshot;
  final Uint8List? artworkBytes;
  final Stream<FftFrame> mockVisualizerStream;

  @override
  AudioSnapshot build() => mockSnapshot;

  @override
  MusicFile? get currentMusic => mockSnapshot.currentMusic;

  @override
  bool get isPlaying => true;

  @override
  double get volume => mockSnapshot.volume;

  @override
  Duration get position => mockSnapshot.position;

  @override
  Duration get duration => mockSnapshot.duration;

  @override
  AppPlaybackMode get playbackMode => mockSnapshot.playbackMode;

  @override
  bool get isLyricsActive => mockSnapshot.isLyricsActive;

  @override
  Uint8List? getCachedArtwork(String? path) => artworkBytes;

  @override
  List<double> getEqualizerBandCenters({required int bandCount}) {
    if (bandCount == 10) {
      return EqualizerPresets.standard10Frequencies;
    }
    return List.generate(
      bandCount,
      (i) => 31.25 * math.pow(2, i * 9.0 / (bandCount - 1)),
    );
  }

  @override
  Stream<FftFrame> get visualizerStream => mockVisualizerStream;

  @override
  Future<void> completeHeroTransition({String? priorityPath}) async {}

  @override
  void applyVisualizerSettings({required Orientation orientation}) {}

  @override
  void setLyricsActive(bool active) {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> next() async {}

  @override
  Future<void> previous() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setVolume(double volume, {bool showVolumeHud = true}) async {}

  @override
  Future<void> ensureEqualizerBandCount(int count) async {}

  @override
  Future<void> setEqualizerEnabled(bool enabled) async {}

  @override
  Future<void> setEqualizerBandGain(int bandIndex, double gainDb) async {}

  @override
  Future<void> setEqualizerPreamp(double preampDb) async {}

  @override
  Future<void> setBassBoost(double amount) async {}

  @override
  Future<void> setPlaybackSpeed(double speed) async {}
}

class _MockScannerService extends ScannerService {
  _MockScannerService({
    required List<MusicFolder> rootFolders,
    required this.metadataMap,
  }) : _rootFolders = List<MusicFolder>.from(rootFolders),
       super(autoInitialize: false);

  final List<MusicFolder> _rootFolders;

  @override
  final Map<String, SongMetadata> metadataMap;

  @override
  List<MusicFolder> get rootFolders =>
      List<MusicFolder>.unmodifiable(_rootFolders);

  @override
  bool get hasPermission => true;

  @override
  bool get isScanning => false;
}
