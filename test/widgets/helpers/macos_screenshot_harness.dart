// ignore_for_file: avoid_print, override_on_non_overriding_member, annotate_overrides, must_call_super
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
import 'package:vynody/pages/main_layout.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/audio/audio_snapshot.dart';
import 'package:vynody/player/lyrics/lyrics_controller.dart';
import 'package:vynody/player/lyrics/lyrics_controller_state.dart';
import 'package:vynody/player/lyrics/lyrics_generation_display_state.dart';
import 'package:vynody/player/lyrics/lyrics_riverpod.dart';
import 'package:vynody/player/lyrics/lyrics_song_task_state.dart';
import 'package:vynody/player/audio/equalizer_presets.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/scanner/scanner_service.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/player/sharing/lan_device.dart';
import 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
import 'package:vynody/player/sharing/remote_control/remote_playback_model.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/player/sharing/sharing_service.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mobile_storage_listener/mobile_storage_event.dart';
import 'package:mobile_storage_listener/mobile_storage_listener_platform_interface.dart';

import 'package:vynody/models/album_summary.dart';
import 'screenshot_paths.dart';

// Re-export common types for test ergonomics
export 'package:audio_core/audio_core.dart';
export 'package:vynody/models/album_summary.dart';
export 'package:vynody/models/lyric_line.dart';
export 'package:vynody/models/music_file.dart';
export 'package:vynody/models/music_folder.dart';
export 'package:vynody/models/music_lyric.dart';
export 'package:vynody/pages/albums_tab.dart';
export 'package:vynody/pages/library_page.dart';
export 'package:vynody/pages/main_layout.dart';
export 'package:vynody/pages/sharing_page.dart';
export 'package:vynody/player/audio/app_playback_mode.dart';
export 'package:vynody/player/audio/audio_riverpod.dart';
export 'package:vynody/player/audio/audio_snapshot.dart';
export 'package:vynody/player/audio/equalizer_presets.dart';
export 'package:vynody/player/library/album_library.dart';
export 'package:vynody/player/lyrics/lyrics_controller_state.dart';
export 'package:vynody/player/metadata/metadata_database.dart';
export 'package:vynody/player/pro/pro_license_service.dart';
export 'package:vynody/player/scanner/scanner_service.dart';
export 'package:vynody/player/settings/settings_service.dart';
export 'package:vynody/player/sharing/lan_device.dart';
export 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
export 'package:vynody/player/sharing/remote_control/remote_playback_model.dart';
export 'package:vynody/player/sharing/sharing_riverpod.dart';
export 'package:vynody/player/sharing/sharing_service.dart';
export 'package:vynody/widgets/equalizer_panel.dart';
export 'screenshot_paths.dart';

/// Helper function to resolve full output path
File resolveMacosScreenshotOutputFile(String pathOrFilename) => ScreenshotPaths.resolve(pathOrFilename);

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

/// Default 22-album demo set for CoverFlow / Library tests
const defaultDemoList = [
  DemoItem(
    filename: '01 - Neon After Rain.mp3',
    title: '雨后霓虹',
    artist: '林舟',
    album: '城市微光',
    durationMs: 192000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_01.jpg',
  ),
  DemoItem(
    filename: '02 - Sea Breeze Passing.mp3',
    title: '海风掠过',
    artist: '森茉',
    album: '潮汐备忘录',
    durationMs: 207974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_02.jpg',
  ),
  DemoItem(
    filename: '03 - Moon at 2AM.mp3',
    title: '凌晨两点的月亮',
    artist: '白噪森林',
    album: '不眠电台',
    durationMs: 224974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_03.jpg',
  ),
  DemoItem(
    filename: '04 - Walking Home at Sunset.mp3',
    title: '把这一天留给你',
    artist: '晚风邮局',
    album: '约定的红色夏天',
    durationMs: 251974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_04.jpg',
  ),
  DemoItem(
    filename: '05 - Floating Practice.mp3',
    title: '漂浮练习',
    artist: '清野',
    album: '轻质之物',
    durationMs: 199974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_05.jpg',
  ),
  DemoItem(
    filename: '06 - Blue Room.mp3',
    title: '蓝色房间',
    artist: '正午公园',
    album: '204号房间',
    durationMs: 274974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_06.jpg',
  ),
  DemoItem(
    filename: '07 - Letter from Afar.mp3',
    title: '远方来信',
    artist: '春野',
    album: '未完旅程',
    durationMs: 215974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_07.jpg',
  ),
  DemoItem(
    filename: '08 - Glass Sea.mp3',
    title: '玻璃海',
    artist: '星宿乐团',
    album: '海岸线之外',
    durationMs: 261974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_08.jpg',
  ),
  DemoItem(
    filename: '09 - Wind Through Old Vinyl.mp3',
    title: '穿过旧黑胶的风',
    artist: '周五俱乐部',
    album: '慢速回放',
    durationMs: 237974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_09.jpg',
  ),
  DemoItem(
    filename: '10 - Leave a Light On.mp3',
    title: '留一盏灯',
    artist: '夜言',
    album: '枕边故事',
    durationMs: 289974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_10.jpg',
  ),
  DemoItem(
    filename: '11 - Velvet Midnight.mp3',
    title: '丝绒午夜',
    artist: '月相波',
    album: '夜幕交响',
    durationMs: 213975,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_11.jpg',
  ),
  DemoItem(
    filename: '12 - Golden Hour Echoes.mp3',
    title: '黄金时刻回响',
    artist: '太阳漂流',
    album: '暖色地平线',
    durationMs: 247974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_12.jpg',
  ),
  DemoItem(
    filename: '13 - Chasing Fireflies.mp3',
    title: '追萤火虫的人',
    artist: '琥珀微光',
    album: '童年回音',
    durationMs: 195000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_13.jpg',
  ),
  DemoItem(
    filename: '14 - Summer Afternoon Nostalgia.mp3',
    title: '夏日午后漫想',
    artist: '日落俱乐部',
    album: '七月的明信片',
    durationMs: 271973,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_14.jpg',
  ),
  DemoItem(
    filename: '15 - Gentle Awakening.mp3',
    title: '温柔苏醒',
    artist: '宁静小径',
    album: '清晨微露',
    durationMs: 227975,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_15.jpg',
  ),
  DemoItem(
    filename: '16 - Vintage Polaroid.mp3',
    title: '复古拍立得',
    artist: '磁带梦境',
    album: '模拟时代',
    durationMs: 260000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_16.jpg',
  ),
  DemoItem(
    filename: '17 - Prism Spectrum.mp3',
    title: '棱镜光谱',
    artist: '霓虹幻象',
    album: '几何情绪',
    durationMs: 188000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_17.jpg',
  ),
  DemoItem(
    filename: '18 - Playground Symphony.mp3',
    title: '游乐场交响诗',
    artist: '随笔集',
    album: '涂鸦仙境',
    durationMs: 236000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_18.jpg',
  ),
  DemoItem(
    filename: '19 - Desert Wind Whisper.mp3',
    title: '荒漠风语',
    artist: '绿洲海市',
    album: '沉寂沙丘',
    durationMs: 283973,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_19.jpg',
  ),
  DemoItem(
    filename: '20 - Cosmic Particles.mp3',
    title: '宇宙微粒',
    artist: '星芒理论',
    album: '环形无限',
    durationMs: 242000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_20.jpg',
  ),
  DemoItem(
    filename: '21 - Crystal Ballroom.mp3',
    title: '水晶舞厅',
    artist: '镀金世纪',
    album: '装饰风艺术遐想',
    durationMs: 217975,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_21.jpg',
  ),
  DemoItem(
    filename: 'demo1.mp3',
    title: '午夜天际线',
    artist: '新星乐团',
    album: '都市遐想',
    durationMs: 185000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_22.jpg',
  ),
];

/// Helper to create demo songs and album summaries
({
  List<MusicFile> songs,
  List<AlbumSummary> albums,
  Map<String, SongMetadata> metadataMap
}) createDemoLibraryData({
  String basePath = '/Users/axel10/Music/Vynody Music/Demo Music/zh/Demo Music',
}) {
  final metadataMap = <String, SongMetadata>{};
  final musicFiles = <MusicFile>[];
  final albumSummaries = <AlbumSummary>[];

  for (int i = 0; i < defaultDemoList.length; i++) {
    final item = defaultDemoList[i];
    final songPath = '$basePath/${item.filename}';

    Uint8List? coverBytes;
    final coverFile = File(item.coverPath);
    if (coverFile.existsSync()) {
      coverBytes = Uint8List.fromList(coverFile.readAsBytesSync());
    }

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
      artworkBytes: coverBytes,
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

  return (songs: musicFiles, albums: albumSummaries, metadataMap: metadataMap);
}

class _MockMobileStorageListenerPlatform extends MobileStorageListenerPlatform
    with MockPlatformInterfaceMixin {
  @override
  Stream<MobileStorageEvent> storageEvents({bool detectInternalVolumes = true}) {
    return const Stream.empty();
  }
}

/// Loads system/fallback fonts for screenshot rendering.
Future<void> loadMacosTestFonts() async {
  MobileStorageListenerPlatform.instance = _MockMobileStorageListenerPlatform();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('window_manager'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isFullScreen':
          return false;
        case 'isMaximized':
          return false;
        case 'getSize':
          return {'width': 1920.0, 'height': 1080.0};
        default:
          return null;
      }
    },
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('mobile_storage_listener/events'),
    (MethodCall methodCall) async => null,
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('mobile_storage_listener'),
    (MethodCall methodCall) async => null,
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockStreamHandler(
    const EventChannel('mobile_storage_listener/events'),
    MockStreamHandler.inline(
      onListen: (args, sink) {},
      onCancel: (args) {},
    ),
  );

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

/// Generates a realistic audio waveform byte buffer.
Uint8List generateRealisticWaveform(int length, {double seed = 1.0}) {
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

/// Generates mock FFT visualizer frequency band energy values.
List<double> generateFftBandsDesktop({int count = 100, double energy = 0.88}) {
  final bands = <double>[];
  for (int i = 0; i < count; i++) {
    final freqFactor = math.pow(1.0 - (i / count), 0.65).toDouble();
    final bounce = math.sin((i * 0.25) + 1.1).abs() * 0.4 + 0.45;
    final value = (freqFactor * bounce * energy).clamp(0.04, 0.96);
    bands.add(value);
  }
  return bands;
}

/// Parses an LRC text into [MusicLyric].
MusicLyric parseLrc(String lrcContent) {
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

/// Builds native macOS-styled traffic light buttons (Close, Minimize, Zoom).
Widget buildMacosTrafficLights({double size = 13, double spacing = 8}) {
  Widget buildDot(Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      buildDot(const Color(0xFFFF5F56)),
      SizedBox(width: spacing),
      buildDot(const Color(0xFFFFBD2E)),
      SizedBox(width: spacing),
      buildDot(const Color(0xFF27C93F)),
    ],
  );
}

/// Configuration for generating a 2880x1800 macOS App Store Marketing Poster.
class MacosPosterConfig {
  const MacosPosterConfig({
    required this.tagText,
    required this.tagColor,
    required this.title,
    required this.subtitle,
    required this.backgroundGradient,
    required this.glowColors,
    required this.outputFileName,
  });

  final String tagText;
  final Color tagColor;
  final String title;
  final String subtitle;
  final List<Color> backgroundGradient;
  final List<Color> glowColors;
  final String outputFileName;
}

/// Standard Mock Lyrics Controller
class MockLyricsController extends LyricsController {
  MockLyricsController({
    required this.initialState,
    required this.lyrics,
  });

  final LyricsControllerState initialState;
  final MusicLyric lyrics;

  @override
  LyricsControllerState build() => initialState;

  @override
  LyricsControllerState get state => initialState;

  @override
  MusicLyric? currentLyricsForCurrentSong() => lyrics;

  @override
  LyricsSongTaskState taskStateForSong(String? songPath) => const LyricsSongTaskState();

  @override
  Future<void> flushPendingLyricsTranslationUpdates() async {}

  @override
  LyricsGenerationDisplayState get activeLyricsGenerationDisplayState =>
      const LyricsGenerationDisplayState();

  @override
  Future<void> fetchLyrics(MusicFile song, {bool force = false}) async {}
}

/// Standard Mock Audio Service
class MockAudioService extends AudioService {
  MockAudioService({
    required this.snapshot,
    this.artworkBytes,
    required this.visualizerStream,
  });

  @override
  final AudioSnapshot snapshot;
  final Uint8List? artworkBytes;

  @override
  final Stream<FftFrame> visualizerStream;

  @override
  AudioSnapshot build() => snapshot;

  @override
  MusicFile? get currentMusic => snapshot.currentMusic;

  @override
  bool get isPlaying => snapshot.isPlaying;

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

  @override
  Future<void> ensureEqualizerBandCount(int targetBandCount) async {}

  @override
  List<double> getEqualizerBandCenters({required int bandCount}) {
    return EqualizerPresets.standard10Frequencies;
  }
}

/// Standard Mock Scanner Service
class MockScannerService extends ScannerService {
  MockScannerService({
    required List<MusicFolder> rootFolders,
    Map<String, SongMetadata> metadataMap = const {},
  })  : _rootFolders = List<MusicFolder>.from(rootFolders),
        _metadataMap = Map<String, SongMetadata>.from(metadataMap),
        super(autoInitialize: false);

  final List<MusicFolder> _rootFolders;
  final Map<String, SongMetadata> _metadataMap;

  @override
  List<MusicFolder> get rootFolders => List<MusicFolder>.unmodifiable(_rootFolders);

  @override
  bool get hasPermission => true;

  @override
  bool get isScanning => false;

  @override
  Map<String, SongMetadata> get metadataMap => _metadataMap;
}

/// Test Settings Service with bypassed timers
class TestSettingsService extends SettingsService {
  TestSettingsService(super.prefs);

  @override
  void startInactivityTimer() {}

  @override
  void resetInactivity() {}

  @override
  void dispose() {}
}

/// Standard Sharing Service Mocks for macOS
final defaultMacosDiscoveredDevices = [
  LanDevice(
    id: 'ios-01',
    name: 'iPhone 16 Pro Max',
    deviceType: 'ios',
    httpPort: 52000,
    ip: '192.168.1.102',
    lastSeen: DateTime.now(),
    isOnline: true,
  ),
  LanDevice(
    id: 'ipad-01',
    name: 'iPad Pro 13"',
    deviceType: 'ios',
    httpPort: 52000,
    ip: '192.168.1.108',
    lastSeen: DateTime.now(),
    isOnline: true,
  ),
  LanDevice(
    id: 'win-01',
    name: 'Studio PC (Windows 11)',
    deviceType: 'windows',
    httpPort: 52000,
    ip: '192.168.1.112',
    lastSeen: DateTime.now(),
    isOnline: true,
  ),
  LanDevice(
    id: 'and-01',
    name: 'Pixel 9 Pro',
    deviceType: 'android',
    httpPort: 52000,
    ip: '192.168.1.115',
    lastSeen: DateTime.now(),
    isOnline: true,
  ),
  LanDevice(
    id: 'lin-01',
    name: 'Ubuntu Audio Lab',
    deviceType: 'linux',
    httpPort: 52000,
    ip: '192.168.1.120',
    lastSeen: DateTime.now(),
    isOnline: true,
  ),
];

class MockSharingServerStateNotifier extends SharingServerStateNotifier {
  @override
  SharingServerState build() {
    return SharingServerState(
      isRunning: true,
      localIp: '192.168.1.105',
      httpPort: 52000,
    );
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

class MockHostConnectedClientsNotifier extends HostConnectedClientsNotifier {
  @override
  List<ConnectedHostClient> build() => const [
        ConnectedHostClient(
          name: 'iPhone 16 Pro Max',
          deviceType: 'ios',
          isTrusted: true,
        ),
      ];
}

class MockTrustedDevicesNotifier extends TrustedDevicesNotifier {
  @override
  List<TrustedRemoteDevice> build() => [
        TrustedRemoteDevice(
          id: 'ios-01',
          name: 'iPhone 16 Pro Max',
          deviceType: 'ios',
          token: 'token-ios',
          pairedAt: DateTime.now(),
        ),
        TrustedRemoteDevice(
          id: 'win-01',
          name: 'Studio PC (Windows 11)',
          deviceType: 'windows',
          token: 'token-win',
          pairedAt: DateTime.now(),
        ),
      ];
}

class MockSharingService extends SharingService {
  MockSharingService(
    super.ref, {
    List<LanDevice>? devices,
    this.folderPath = '/Users/axel10/Music/Vynody Music',
  }) : _devices = devices ?? defaultMacosDiscoveredDevices;

  final List<LanDevice> _devices;
  final String folderPath;

  @override
  String get sharingFolderPath => folderPath;

  @override
  Future<String> getDefaultSharingFolderPath() async => folderPath;

  @override
  Future<bool> checkSharingFolderWritable([String? pathToCheck]) async => true;

  @override
  Future<bool> checkLocalNetworkPermission() async => true;

  @override
  String? get localIp => '192.168.1.105';

  @override
  int get httpPort => 52000;

  @override
  bool get isRunning => true;

  @override
  List<LanDevice> get discoveredDevices => _devices;

  @override
  Stream<List<LanDevice>> get discoveredDevicesStream => Stream.value(_devices);
}

/// Captures a 1920x1080 native macOS App Window screenshot.
Future<Uint8List> captureMacosWindow({
  required WidgetTester tester,
  required MusicFile song,
  AudioSnapshot? snapshot,
  void Function(TestSettingsService settings)? configureSettings,
  LyricsControllerState? lyricsState,
  MusicLyric? lyrics,
  int initialIndex = 1,
  Widget? customBody,
  List<dynamic> extraOverrides = const [],
  String? saveWindowFileName,
  double fftEnergy = 0.88,
  ScannerService? scannerService,
  AudioService? audioService,
  ColorScheme? colorScheme,
}) async {
  await loadMacosTestFonts();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('window_manager'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isFullScreen':
          return false;
        case 'isMaximized':
          return false;
        case 'getSize':
          return {'width': 1920.0, 'height': 1080.0};
        default:
          return null;
      }
    },
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockStreamHandler(
    const EventChannel('mobile_storage_listener/events'),
    MockStreamHandler.inline(
      onListen: (args, sink) {},
      onCancel: (args) {},
    ),
  );

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final settingsService = TestSettingsService(prefs);

  // Default baseline settings
  settingsService.hasShownOnboarding = true;
  settingsService.hasShownCoverTapLyricTip = true;
  settingsService.hasShownLyricsMenuTip = true;
  settingsService.isWaveformProgressBarEnabled = true;
  settingsService.portraitFrequencyGroups = 100;
  settingsService.visualizerStyle = VisualizerStyle.bars;
  settingsService.visualizerOpacity = VisualizerStyle.bars.defaultOpacity;
  settingsService.isVisualizerDynamicColor = false;
  settingsService.playbackBackgroundType = 0;
  settingsService.uiScale = 1.0;

  configureSettings?.call(settingsService);

  final effectiveSnapshot = snapshot ??
      AudioSnapshot(
        isPlaying: true,
        isTransitioning: false,
        isLastActionNext: null,
        currentMusic: song,
        position: const Duration(seconds: 80),
        duration: Duration(milliseconds: song.durationMillis ?? 0),
        volume: 0.82,
        isMuted: false,
        playbackQueue: [song],
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

  final visualizerStreamController = StreamController<FftFrame>.broadcast();
  final effectiveAudioService = audioService ??
      MockAudioService(
        snapshot: effectiveSnapshot,
        artworkBytes: song.artworkBytes,
        visualizerStream: visualizerStreamController.stream,
      );

  final effectiveScannerService = scannerService ??
      MockScannerService(
        rootFolders: [
          MusicFolder(path: '/demo_zh', name: 'Demo Music', files: [song])
        ],
      );

  final effectiveLyrics = lyrics ?? song.lyrics ?? const MusicLyric();
  final effectiveLyricsState = lyricsState ??
      LyricsControllerState(
        hasLyrics: effectiveLyrics.syncedLines.isNotEmpty,
        currentLyricsLines: effectiveLyrics.syncedLines,
        lyricsTranslationLanguageCode: 'zh',
      );

  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final windowCaptureKey = GlobalKey();

  await tester.pumpWidget(
    rpod.ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWith((ref) => settingsService),
        audioServiceProvider.overrideWith((ref) => effectiveAudioService),
        audioSnapshotProvider.overrideWith((ref) => effectiveSnapshot),
        isEffectiveWaveformEnabledProvider.overrideWith((ref) => true),
        isProUnlockedProvider.overrideWith((ref) => true),
        scannerServiceProvider.overrideWith((ref) => effectiveScannerService),
        lyricsControllerProvider.overrideWith(
          () => MockLyricsController(initialState: effectiveLyricsState, lyrics: effectiveLyrics),
        ),
        ...extraOverrides,
      ],
      child: OKToast(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: colorScheme ??
                ColorScheme.fromSeed(
                  seedColor: const Color(0xFF38BDF8),
                  brightness: Brightness.dark,
                ),
            fontFamily: 'Arial Unicode MS',
            fontFamilyFallback: const [
              'Arial Unicode MS',
              'PingFang SC',
              'Segoe UI',
              'Microsoft YaHei',
              'Roboto',
              'sans-serif',
            ],
            scaffoldBackgroundColor: Colors.transparent,
          ),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            backgroundColor: const Color(0xFF141721),
            body: RepaintBoundary(
              key: windowCaptureKey,
              child: SizedBox(
                width: 1920,
                height: 1080,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: customBody ??
                          MainLayout(
                            args: const [],
                            initialIndex: initialIndex,
                          ),
                    ),
                    Positioned(
                      top: 14,
                      left: 18,
                      child: buildMacosTrafficLights(),
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

  final fftFrame = FftFrame(
    position: effectiveSnapshot.position,
    values: generateFftBandsDesktop(count: 100, energy: fftEnergy),
    isPlaying: true,
  );

  visualizerStreamController.add(fftFrame);
  await tester.pump();

  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final widget = element.widget as Image;
      try {
        await precacheImage(widget.image, element).timeout(
          const Duration(milliseconds: 300),
          onTimeout: () {},
        );
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 600));
  });

  visualizerStreamController.add(fftFrame);
  await tester.pump();

  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final widget = element.widget as Image;
      try {
        await precacheImage(widget.image, element).timeout(
          const Duration(milliseconds: 300),
          onTimeout: () {},
        );
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 400));
  });

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));

  Uint8List? windowPngBytes;
  await tester.runAsync(() async {
    final windowBoundary =
        windowCaptureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (windowBoundary == null) {
      fail('Window boundary render object is null');
    }

    final windowImage = await windowBoundary.toImage(pixelRatio: 2.0);
    final windowByteData = await windowImage.toByteData(format: ui.ImageByteFormat.png);
    if (windowByteData == null) {
      fail('Failed to capture window image');
    }
    windowPngBytes = windowByteData.buffer.asUint8List();

    if (saveWindowFileName != null && saveWindowFileName.isNotEmpty) {
      final file = resolveMacosScreenshotOutputFile(saveWindowFileName);
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(windowPngBytes!);
      print('SUCCESS_SAVED_WINDOW: ${file.path} (${windowPngBytes!.length} bytes)');
    }
  });

  await visualizerStreamController.close();
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);

  return windowPngBytes!;
}

/// Renders and saves a 2880x1800 macOS App Store Marketing Poster.
Future<Uint8List> renderMacosStorePoster({
  required WidgetTester tester,
  required Uint8List windowBytes,
  required MacosPosterConfig config,
}) async {
  await loadMacosTestFonts();

  ui.Image? windowDecodedImage;
  await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(windowBytes);
    final frameInfo = await codec.getNextFrame();
    windowDecodedImage = frameInfo.image;
  });

  if (windowDecodedImage == null) {
    fail('Failed to decode window image');
  }

  // 2880 x 1800 standard macOS App Store retina ratio (16:10)
  tester.view.physicalSize = const Size(2880, 1800);
  tester.view.devicePixelRatio = 3.0; // 960 x 600 logical canvas
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  const canvasWidth = 960.0;
  const canvasHeight = 600.0;
  const double winFrameWidth = 830.0;
  const double winFrameHeight = 830.0 * (1080.0 / 1920.0); // 466.875px

  final posterRepaintKey = GlobalKey();

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Arial Unicode MS',
        fontFamilyFallback: const [
          'Arial Unicode MS',
          'PingFang SC',
          'Segoe UI',
          'Microsoft YaHei',
          'Roboto',
          'sans-serif',
        ],
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF06080E),
        body: RepaintBoundary(
          key: posterRepaintKey,
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: Stack(
              children: [
                // 1. Poster Background Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: config.backgroundGradient,
                        stops: const [0.0, 0.42, 1.0],
                      ),
                    ),
                  ),
                ),

                // 2. Atmospheric Radial Glow behind window
                Positioned(
                  top: 60,
                  left: 70,
                  right: 70,
                  height: 520,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(250),
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.85,
                        colors: config.glowColors,
                      ),
                    ),
                  ),
                ),

                // 3. Top Marketing Header
                Positioned(
                  top: 14,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tag Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          config.tagText,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: config.tagColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      // Main Title
                      Text(
                        config.title,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Subtitle
                      Text(
                        config.subtitle,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.72),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. macOS App Window Card with Drop Shadow
                Positioned(
                  top: 110,
                  left: (canvasWidth - winFrameWidth) / 2,
                  width: winFrameWidth,
                  height: winFrameHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.85),
                          blurRadius: 48,
                          spreadRadius: 4,
                          offset: const Offset(0, 18),
                        ),
                        BoxShadow(
                          color: (config.glowColors.firstOrNull ?? Colors.transparent)
                              .withValues(alpha: 0.20),
                          blurRadius: 56,
                          spreadRadius: -2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF141721),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 1.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(13)),
                          child: RawImage(
                            image: windowDecodedImage,
                            width: winFrameWidth,
                            height: winFrameHeight,
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.high,
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
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));

  Uint8List? posterPngBytes;
  await tester.runAsync(() async {
    final posterBoundary =
        posterRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (posterBoundary != null) {
      final image = await posterBoundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        posterPngBytes = byteData.buffer.asUint8List();

        final file = resolveMacosScreenshotOutputFile(config.outputFileName);
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(posterPngBytes!);

        final outDir = Directory(
            '/Users/axel10/.gemini/antigravity-ide/brain/ac9c6dcc-f11e-4cb7-aaad-460f09c22d96');
        if (outDir.existsSync()) {
          final brainFile = File('${outDir.path}/${config.outputFileName}');
          brainFile.parent.createSync(recursive: true);
          brainFile.writeAsBytesSync(posterPngBytes!);
        }

        print('SUCCESS_MACOS_POSTER_SAVED: ${file.path} (${posterPngBytes!.length} bytes)');
      }
    }
  });

  return posterPngBytes!;
}
