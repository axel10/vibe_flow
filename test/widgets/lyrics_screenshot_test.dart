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
import 'package:vynody/pages/playback_page.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/audio/audio_snapshot.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/lyrics/lyrics_controller.dart';
import 'package:vynody/player/lyrics/lyrics_controller_state.dart';
import 'package:vynody/player/lyrics/lyrics_generation_display_state.dart';
import 'package:vynody/player/lyrics/lyrics_generation_phase.dart';
import 'package:vynody/player/lyrics/lyrics_riverpod.dart';
import 'package:vynody/player/lyrics/lyrics_song_task_state.dart';
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
      ''
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

  testWidgets('Generate Finished Store Poster 02 - Fullscreen Lyrics Mode', (tester) async {
    await _loadFonts();

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);

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

    final lyrics = _parseLrc(demoLrc);
    final waveformBlob = _generateRealisticWaveform(128, seed: 1.8);

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

    final fftValues = _generateFftBandsDefault(count: 100, energy: 0.88);
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
      currentVisualizerOptions: VisualizerOptimizationOptions(
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
    final audioService = _MockAudioService(
      snapshot: snapshot,
      artworkBytes: artworkBytes,
      visualizerStream: visualizerStreamController.stream,
    );

    final scannerService = _MockScannerService(
      rootFolders: [
        MusicFolder(path: '/demo_zh', name: 'Demo Music', files: [demoSong])
      ],
    );

    final lyricsState = LyricsControllerState(
      hasLyrics: true,
      currentLyricsLines: lyrics.syncedLines,
      lyricsTranslationLanguageCode: 'zh',
    );

    final posterRepaintKey = GlobalKey();

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
          lyricsControllerProvider.overrideWith(() => _MockLyricsController(initialState: lyricsState, lyrics: lyrics)),
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
                        Color(0xFF22111E),
                        Color(0xFF130E1B),
                        Color(0xFF08070C),
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
                          width: 330,
                          height: 330,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFE11D48).withValues(alpha: 0.22),
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
                            // Tag badge: 全屏沉浸歌词
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: const Text(
                                '全屏沉浸歌词',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFDA4AF),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Main Title: 逐行聚焦歌词
                            const Text(
                              '逐行聚焦歌词',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Subtitle: 逐行聚焦 · 平滑滚动与双语对照
                            Text(
                              '逐行聚焦 · 平滑滚动与双语对照',
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
                                color: const Color(0xFFE11D48).withValues(alpha: 0.12),
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

    // Pump frames to let layout and hero animations settle
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Capture Full Finished Promotional Poster
    final boundary = posterRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        
        final outputDirs = [
          '/Users/axel10/.gemini/antigravity-ide/brain/0e31c3ec-1e9d-43f9-b7d8-3b0c7e447717',
          '/Users/axel10/.gemini/antigravity-ide/brain/50a333f4-8920-4e32-aa9b-ddecce8faeaf',
        ];
        for (final dir in outputDirs) {
          final dirFile = Directory(dir);
          if (dirFile.existsSync()) {
            final filePath = '$dir/store_finished_mockup_02.png';
            File(filePath).writeAsBytesSync(pngBytes);
            print('SUCCESS_POSTER_SAVED: $filePath (${pngBytes.length} bytes)');
          }
        }
      }
    }

    await visualizerStreamController.close();
    print('ALL_DONE_EXITING');
    exit(0);
  });
}

class _MockLyricsController extends LyricsController {
  _MockLyricsController({required this.initialState, required this.lyrics});

  final LyricsControllerState initialState;
  final MusicLyric lyrics;

  @override
  LyricsControllerState build() => initialState;

  @override
  MusicLyric? currentLyricsForCurrentSong() => lyrics;

  @override
  LyricsSongTaskState taskStateForSong(String? songPath) => const LyricsSongTaskState();

  @override
  Future<void> flushPendingLyricsTranslationUpdates() async {}

  @override
  LyricsGenerationDisplayState get activeLyricsGenerationDisplayState {
    return const LyricsGenerationDisplayState();
  }
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
  bool get isLyricsActive => snapshot.isLyricsActive;

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
