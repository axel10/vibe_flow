import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:audio_core/audio_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/models/lyric_line.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/models/music_lyric.dart';
import 'package:vynody/pages/playback_page.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/audio/audio_snapshot.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/lyrics/lyrics_riverpod.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/scanner/scanner_service.dart';
import 'package:vynody/player/settings/settings_service.dart';

Future<void> _loadFonts() async {
  final iconFontFile = File('/Users/axel10/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (iconFontFile.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons');
    iconLoader.addFont(Future.value(ByteData.sublistView(iconFontFile.readAsBytesSync())));
    await iconLoader.load();
  }

  final unicodeFontFile = File('/System/Library/Fonts/Supplemental/Arial Unicode.ttf');
  if (unicodeFontFile.existsSync()) {
    final bytes = unicodeFontFile.readAsBytesSync();
    for (final family in ['Roboto', 'Arial Unicode MS', '.SF UI Text', '.SF UI Display', 'PingFang SC']) {
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
    final noise = ((math.Random(i * 19 + (seed * 100).toInt()).nextDouble()) * 0.2);
    final value = ((envelope * (0.35 + beat + detail) + noise) * 0.95).clamp(0.08, 1.0);
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
        lines.add(LyricLine(timestamp: Duration(milliseconds: totalMs), text: text));
      }
    }
  }
  return MusicLyric(syncedLines: lines);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Finished Store Poster 01 - Immersive Playback', (tester) async {
    await _loadFonts();

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);
    
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

    final lyrics = _parseLrc(demoLrc);
    final waveformBlob = _generateRealisticWaveform(128, seed: 1.8);

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

    final fftValues = _generateFftBandsDefault(count: 100, energy: 0.88);
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
      currentVisualizerOptions: VisualizerOptimizationOptions(
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
    final audioService = _MockAudioService(
      snapshot: snapshot,
      artworkBytes: artworkBytes,
      visualizerStream: visualizerStreamController.stream,
    );

    final scannerService = _MockScannerService(
      rootFolders: [
        MusicFolder(path: '/demo', name: 'Demo Music', files: [demoSong])
      ],
    );

    final posterRepaintKey = GlobalKey();

    // Standard Store Poster: 1290 x 2796 (iPhone 6.7" Super Retina XDR @ 3x)
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
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
              fontFamilyFallback: const ['Arial Unicode MS', 'Roboto'],
              scaffoldBackgroundColor: const Color(0xFF07090E),
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
                        Color(0xFF181124),
                        Color(0xFF0D0F18),
                        Color(0xFF06070B),
                      ],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Ambient Glow behind device
                      Positioned(
                        top: 220,
                        child: Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFE2824A).withValues(alpha: 0.22),
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
                            // Tag badge: 沉浸式音频体验
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: const Text(
                                '沉浸式音频体验',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFDBA74),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Main Title: 沉浸播放
                            const Text(
                              '沉浸播放',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Subtitle: 纯净声学 · 灵动频谱与多款定制背景
                            Text(
                              '纯净声学 · 灵动频谱与多款定制背景',
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
                        bottom: -120, // Overflow naturally offscreen at bottom
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(44),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 36,
                                spreadRadius: 4,
                                offset: const Offset(0, 18),
                              ),
                              BoxShadow(
                                color: const Color(0xFFE2824A).withValues(alpha: 0.12),
                                blurRadius: 40,
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
                                  color: const Color(0xFF4A4E5A),
                                  width: 3.5,
                                ),
                                borderRadius: BorderRadius.circular(44),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Stack(
                                  children: [
                                    const Positioned.fill(
                                      child: PlaybackPage(),
                                    ),
                                    // Dynamic Island
                                    Positioned(
                                      top: 10,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          width: 96,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(20),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    visualizerStreamController.add(fftFrame);

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 350));
    });
    visualizerStreamController.add(fftFrame);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Capture Full Finished Promotional Poster
    final boundary = posterRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final outputPath = '/Users/axel10/.gemini/antigravity-ide/brain/50a333f4-8920-4e32-aa9b-ddecce8faeaf/store_finished_mockup_01.png';
        File(outputPath).writeAsBytesSync(pngBytes);
        print('SUCCESS_POSTER_SAVED: $outputPath (${pngBytes.length} bytes)');
      }
    }

    await visualizerStreamController.close();
    print('ALL_DONE_EXITING');
    exit(0);
  });
}

class _MockAudioService extends AudioService {
  _MockAudioService({
    required this.snapshot,
    this.artworkBytes,
    required this.visualizerStream,
  });

  final AudioSnapshot snapshot;
  final Uint8List? artworkBytes;

  @override
  final Stream<FftFrame> visualizerStream;

  @override
  AudioSnapshot build() => snapshot;

  @override
  MusicFile? get currentMusic => snapshot.currentMusic;

  @override
  bool get isPlaying => true;

  @override
  double get volume => snapshot.volume;

  @override
  Duration get position => snapshot.position;

  @override
  Duration get duration => snapshot.duration;

  @override
  AppPlaybackMode get playbackMode => snapshot.playbackMode;

  @override
  Uint8List? getCachedArtwork(String? path) => artworkBytes;

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
}

class _MockScannerService extends ScannerService {
  _MockScannerService({required List<MusicFolder> rootFolders})
      : _rootFolders = List<MusicFolder>.from(rootFolders),
        super(autoInitialize: false);

  final List<MusicFolder> _rootFolders;

  @override
  List<MusicFolder> get rootFolders => List<MusicFolder>.unmodifiable(_rootFolders);

  @override
  bool get hasPermission => true;

  @override
  bool get isScanning => false;

  @override
  Map<String, SongMetadata> get metadataMap => const {};
}
