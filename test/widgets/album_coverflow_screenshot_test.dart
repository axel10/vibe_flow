import 'dart:async';
import 'dart:io';
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
import 'package:vynody/models/album_summary.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/pages/albums_tab.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/audio/audio_snapshot.dart';
import 'package:vynody/player/library/album_library.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/scanner/scanner_service.dart';
import 'package:vynody/player/settings/settings_service.dart';

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

class DemoItem {
  final String filename;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String coverPath;

  const DemoItem({
    required this.filename,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.coverPath,
  });
}

final demoList = const [
  DemoItem(
    filename: '01 - Neon After Rain.mp3',
    title: '雨后霓虹',
    artist: '林舟',
    album: '城市微光',
    durationMs: 192026,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/01 - Neon After Rain.jpg',
  ),
  DemoItem(
    filename: '02 - Sea Breeze Passing.mp3',
    title: '海风掠过',
    artist: '森茉',
    album: '潮汐备忘录',
    durationMs: 208013,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/02 - Sea Breeze Passing.jpg',
  ),
  DemoItem(
    filename: '03 - Moon at 2AM.mp3',
    title: '凌晨两点的月亮',
    artist: '白噪森林',
    album: '不眠电台',
    durationMs: 225018,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/03 - Moon at 2AM.jpg',
  ),
  DemoItem(
    filename: '04 - Walking Home at Sunset.mp3',
    title: '把这一天留给你',
    artist: '晚风邮局',
    album: '约定的红色夏天',
    durationMs: 252003,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/04 - Walking Home at Sunset.jpg',
  ),
  DemoItem(
    filename: '05 - Floating Practice.mp3',
    title: '漂浮练习',
    artist: '清野',
    album: '轻质之物',
    durationMs: 200019,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/05 - Floating Practice.jpg',
  ),
  DemoItem(
    filename: '06 - Blue Room.mp3',
    title: '蓝色房间',
    artist: '正午公园',
    album: '204号房间',
    durationMs: 275017,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/06 - Blue Room.jpg',
  ),
  DemoItem(
    filename: '07 - Letter from Afar.mp3',
    title: '远方来信',
    artist: '春野',
    album: '未完旅程',
    durationMs: 216006,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/07 - Letter from Afar.jpg',
  ),
  DemoItem(
    filename: '08 - Glass Sea.mp3',
    title: '玻璃海',
    artist: '星宿乐团',
    album: '海岸线之外',
    durationMs: 262008,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/08 - Glass Sea.jpg',
  ),
  DemoItem(
    filename: '09 - Wind Through Old Vinyl.mp3',
    title: '穿过旧黑胶的风',
    artist: '周五俱乐部',
    album: '慢速回放',
    durationMs: 238001,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/09 - Wind Through Old Vinyl.jpg',
  ),
  DemoItem(
    filename: '10 - Leave a Light On.mp3',
    title: '留一盏灯',
    artist: '夜言',
    album: '枕边故事',
    durationMs: 290011,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/10 - Leave a Light On.jpg',
  ),
  DemoItem(
    filename: 'demo1.mp3',
    title: '午夜天际线',
    artist: '新星乐团',
    album: '都市遐想',
    durationMs: 185051,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/demo1.jpg',
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Finished Store Poster 03 - 3D Cover Flow', (tester) async {
    await _loadFonts();

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);

    final basePath = '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music';
    final metadataMap = <String, SongMetadata>{};
    final musicFiles = <MusicFile>[];
    final albumSummaries = <AlbumSummary>[];

    for (int i = 0; i < demoList.length; i++) {
      final item = demoList[i];
      final songPath = '$basePath/${item.filename}';

      final meta = SongMetadata(
        id: i + 1,
        path: songPath,
        title: item.title,
        artist: item.artist,
        album: item.album,
        duration: item.durationMs,
        thumbnailPath: item.coverPath,
        artworkPath: item.coverPath,
        artworkWidth: 800,
        artworkHeight: 800,
      );
      metadataMap[songPath] = meta;

      final song = MusicFile(
        id: i + 1,
        path: songPath,
        name: item.filename,
        title: item.title,
        artist: item.artist,
        album: item.album,
        durationMillis: item.durationMs,
        thumbnailPath: item.coverPath,
        artworkPath: item.coverPath,
      );
      musicFiles.add(song);

      albumSummaries.add(
        AlbumSummary(
          id: '${item.album.toLowerCase()}::${item.artist.toLowerCase()}',
          title: item.album,
          artist: item.artist,
          songs: [song],
          representativeSong: song,
          totalDurationMillis: item.durationMs,
        ),
      );
    }

    final activeSong = musicFiles[3]; // '约定的红色夏天' - 晚风邮局

    Uint8List? activeArtworkBytes;
    final activeCoverFile = File(activeSong.thumbnailPath!);
    if (activeCoverFile.existsSync()) {
      activeArtworkBytes = Uint8List.fromList(activeCoverFile.readAsBytesSync());
    }

    final snapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: activeSong,
      position: const Duration(seconds: 45),
      duration: Duration(milliseconds: activeSong.durationMillis ?? 252000),
      volume: 0.85,
      isMuted: false,
      playbackQueue: musicFiles,
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
      currentVisualizerOptions: VisualizerOptimizationOptions(
        frequencyGroups: 100,
      ),
      randomHistory: const [],
      randomQueue: const [],
      historyCursor: null,
      deckCursor: null,
      isVisualizerEnabled: true,
      dynamicStartColor: const Color(0xFF9333EA),
      dynamicEndColor: const Color(0xFF1E1B4B),
      isLyricsActive: false,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    final audioService = _MockAudioService(
      snapshot: snapshot,
      artworkBytes: activeArtworkBytes,
    );

    final scannerService = _MockScannerService(
      rootFolders: [
        MusicFolder(path: basePath, name: 'Demo Music', files: musicFiles),
      ],
      metadataMap: metadataMap,
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
          albumLibraryProvider.overrideWith((ref) => Stream.value(albumSummaries)),
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
                primary: Color(0xFFA78BFA),
                primaryContainer: Color(0xFF4C1D95),
                surface: Color(0xFF0D0F18),
                surfaceContainerHighest: Color(0xFF1F2437),
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
                        Color(0xFF160E2A),
                        Color(0xFF0F101E),
                        Color(0xFF07080F),
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
                          width: 340,
                          height: 340,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF8B5CF6).withValues(alpha: 0.26),
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
                            // Tag badge: 经典唱片美学
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
                                '经典唱片美学',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFC084FC),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Main Title: 唱片美学
                            const Text(
                              '唱片美学',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Subtitle: 3D Cover Flow · 极速分类与智能检索
                            Text(
                              '3D Cover Flow · 极速分类与智能检索',
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
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 36,
                                spreadRadius: 4,
                                offset: const Offset(0, 18),
                              ),
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.14),
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
                                child: RepaintBoundary(
                                  key: deviceScreenRepaintKey,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Builder(
                                          builder: (ctx) => MediaQuery(
                                            data: MediaQuery.of(ctx).copyWith(
                                              padding: const EdgeInsets.only(top: 50, bottom: 34),
                                              viewPadding: const EdgeInsets.only(top: 50, bottom: 34),
                                            ),
                                            child: Scaffold(
                                              backgroundColor: const Color(0xFF0B0D14),
                                              body: SafeArea(
                                                bottom: false,
                                                child: const AlbumsTab(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Status Bar Elements: Time on Left
                                      Positioned(
                                        top: 14,
                                        left: 28,
                                        child: const Text(
                                          '9:41',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                      // Status Bar Elements: Icons on Right
                                      Positioned(
                                        top: 14,
                                        right: 26,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.signal_cellular_4_bar_rounded, size: 14, color: Colors.white),
                                            const SizedBox(width: 5),
                                            const Icon(Icons.wifi_rounded, size: 14, color: Colors.white),
                                            const SizedBox(width: 5),
                                            const Icon(Icons.battery_full_rounded, size: 18, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                      // Dynamic Island (Centered)
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

    // Precache and resolve all cover images inside tester.runAsync
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      for (final item in demoList) {
        final file = File(item.coverPath);
        if (!file.existsSync()) {
          print('FILE_NOT_FOUND: ${item.coverPath}');
          continue;
        }

        final fileImage = FileImage(file);
        final providers = <ImageProvider>[
          fileImage,
          ResizeImage(fileImage, height: 750),
          ResizeImage(fileImage, width: 750),
          ResizeImage(fileImage, height: 750, width: 750),
          ResizeImage(fileImage, height: 600),
          ResizeImage(fileImage, width: 600),
          ResizeImage(fileImage, height: 400),
          ResizeImage(fileImage, width: 400),
          ResizeImage(fileImage, height: 250),
          ResizeImage(fileImage, width: 250),
        ];

        for (final provider in providers) {
          try {
            await precacheImage(provider, element);
          } catch (e) {
            print('PRECACHE_ERROR for ${item.coverPath}: $e');
          }
        }
      }
    });

    await tester.pumpAndSettle();

    // Toggle 3D Cover Flow mode
    final toggle3dBtn = find.byIcon(Icons.view_carousel_rounded);
    if (toggle3dBtn.evaluate().isNotEmpty) {
      await tester.tap(toggle3dBtn);
      await tester.pumpAndSettle();
    }

    // Let all images and 3D animations completely settle
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 600));
    });
    await tester.pumpAndSettle();

    // Scroll to album 3 ("约定的红色夏天" / 晚风邮局)
    for (int step = 0; step < 3; step++) {
      final rightChevron = find.byIcon(Icons.chevron_right_rounded);
      if (rightChevron.evaluate().isNotEmpty) {
        await tester.tap(rightChevron);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();
      }
    }

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    // 1. Capture Full Finished Promotional Poster
    final posterBoundary = posterRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (posterBoundary != null) {
      final image = await posterBoundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        
        final outPoster1 = '/Users/axel10/.gemini/antigravity-ide/brain/d606780a-dd6e-4f51-9b35-c09ae9b9a7ca/store_finished_mockup_03.png';
        final outPoster2 = '/Volumes/Untitled/projects/vibe_flow/screenshots/store_mockup_03_coverflow.png';
        
        File(outPoster1).writeAsBytesSync(pngBytes);
        File(outPoster2).writeAsBytesSync(pngBytes);
        print('SUCCESS_POSTER_SAVED: $outPoster1 (${pngBytes.length} bytes)');
      }
    }

    // 2. Capture Pure Device Screen (Clean iOS Screen)
    final screenBoundary = deviceScreenRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (screenBoundary != null) {
      final image = await screenBoundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final outScreen1 = '/Users/axel10/.gemini/antigravity-ide/brain/d606780a-dd6e-4f51-9b35-c09ae9b9a7ca/album_3d_coverflow_ios_raw.png';
        final outScreen2 = '/Volumes/Untitled/projects/vibe_flow/screenshots/album_3d_coverflow_ios_raw.png';
        
        File(outScreen1).writeAsBytesSync(pngBytes);
        File(outScreen2).writeAsBytesSync(pngBytes);
        print('SUCCESS_RAW_SCREEN_SAVED: $outScreen1 (${pngBytes.length} bytes)');
      }
    }

    print('ALL_DONE_EXITING');
    exit(0);
  });
}

class _MockAudioService extends AudioService {
  _MockAudioService({
    required this.snapshot,
    this.artworkBytes,
  });

  final AudioSnapshot snapshot;
  final Uint8List? artworkBytes;

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
  _MockScannerService({
    required List<MusicFolder> rootFolders,
    required this.metadataMap,
  })  : _rootFolders = List<MusicFolder>.from(rootFolders),
        super(autoInitialize: false);

  final List<MusicFolder> _rootFolders;

  @override
  final Map<String, SongMetadata> metadataMap;

  @override
  List<MusicFolder> get rootFolders => List<MusicFolder>.unmodifiable(_rootFolders);

  @override
  bool get hasPermission => true;

  @override
  bool get isScanning => false;
}
