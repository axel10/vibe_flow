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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mobile_storage_listener/mobile_storage_event.dart';
import 'package:mobile_storage_listener/mobile_storage_listener_platform_interface.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/models/album_summary.dart';
import 'package:vynody/models/lyric_line.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/models/music_lyric.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/audio/audio_snapshot.dart';
import 'package:vynody/player/audio/equalizer_presets.dart';
import 'package:vynody/player/lyrics/lyrics_controller.dart';
import 'package:vynody/player/lyrics/lyrics_controller_state.dart';
import 'package:vynody/player/lyrics/lyrics_generation_display_state.dart';
import 'package:vynody/player/lyrics/lyrics_song_task_state.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/scanner/scanner_service.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/player/sharing/lan_device.dart';
import 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
import 'package:vynody/player/sharing/remote_control/remote_playback_model.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/player/sharing/sharing_service.dart';

// Re-export common types for test ergonomics
export 'dart:typed_data';
export 'package:audio_core/audio_core.dart' hide RepeatMode;
export 'package:flutter/material.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:vynody/models/album_summary.dart';
export 'package:vynody/models/lyric_line.dart';
export 'package:vynody/models/music_file.dart';
export 'package:vynody/models/music_folder.dart';
export 'package:vynody/models/music_lyric.dart';
export 'package:vynody/player/audio/app_playback_mode.dart';
export 'package:vynody/player/audio/audio_snapshot.dart';
export 'package:vynody/player/audio/equalizer_presets.dart';
export 'package:vynody/player/lyrics/lyrics_controller_state.dart';
export 'package:vynody/player/settings/settings_service.dart';
export 'package:vynody/player/sharing/lan_device.dart';

/// Default screenshot output directory in the project workspace
const String defaultMobileScreenshotOutputDir = '/Volumes/Untitled/projects/vibe_flow/screenshots';

/// Helper function to resolve full output path
File resolveScreenshotOutputFile(String pathOrFilename) {
  if (pathOrFilename.startsWith('/') || pathOrFilename.contains(':\\')) {
    return File(pathOrFilename);
  }
  return File('$defaultMobileScreenshotOutputDir/$pathOrFilename');
}

class _MockMobileStorageListenerPlatform extends MobileStorageListenerPlatform
    with MockPlatformInterfaceMixin {
  @override
  Stream<MobileStorageEvent> storageEvents({bool detectInternalVolumes = true}) {
    return const Stream.empty();
  }
}

/// Loads system/fallback fonts for screenshot rendering.
Future<void> loadMobileTestFonts() async {
  MobileStorageListenerPlatform.instance = _MockMobileStorageListenerPlatform();

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

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('window_manager'),
    (MethodCall methodCall) async => null,
  );
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
List<double> generateFftBandsDefault({int count = 100, double energy = 0.88}) {
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

/// Mobile device specifications for App Store mockups.
class MobileDeviceSpec {
  const MobileDeviceSpec({
    required this.name,
    required this.physicalSize,
    required this.pixelRatio,
    required this.logicalWidth,
    required this.logicalHeight,
    required this.cornerRadius,
    required this.borderWidth,
    this.hasDynamicIsland = true,
    this.islandWidth = 96,
    this.islandHeight = 26,
  });

  final String name;
  final Size physicalSize;
  final double pixelRatio;
  final double logicalWidth;
  final double logicalHeight;
  final double cornerRadius;
  final double borderWidth;
  final bool hasDynamicIsland;
  final double islandWidth;
  final double islandHeight;

  /// Standard iPhone 6.7" / 6.9" Pro Max (430 x 932 logical, 1290 x 2796 physical)
  static const MobileDeviceSpec iphoneProMax = MobileDeviceSpec(
    name: 'iPhone Pro Max',
    physicalSize: Size(1290, 2796),
    pixelRatio: 3.0,
    logicalWidth: 430,
    logicalHeight: 932,
    cornerRadius: 44,
    borderWidth: 3.5,
    hasDynamicIsland: true,
    islandWidth: 96,
    islandHeight: 26,
  );
}

/// Marketing Poster Layout Configuration
class MobilePosterConfig {
  const MobilePosterConfig({
    required this.tagText,
    required this.tagColor,
    required this.title,
    required this.subtitle,
    required this.backgroundGradient,
    required this.glowColor,
    this.screenBackgroundColor,
    this.screenColorScheme,
    this.outputPosterFileName,
    this.outputScreenFileName,
  });

  final String tagText;
  final Color tagColor;
  final String title;
  final String subtitle;
  final List<Color> backgroundGradient;
  final Color glowColor;
  final Color? screenBackgroundColor;
  final ColorScheme? screenColorScheme;
  final String? outputPosterFileName;
  final String? outputScreenFileName;
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
  static bool _ensurePlatformMocked() {
    MobileStorageListenerPlatform.instance = _MockMobileStorageListenerPlatform();
    return true;
  }

  MockScannerService({
    required List<MusicFolder> rootFolders,
    Map<String, SongMetadata> metadataMap = const {},
  })  : _rootFolders = (_ensurePlatformMocked(), List<MusicFolder>.from(rootFolders)).$2,
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

/// Standard Sharing Service Mocks
final defaultMockDiscoveredDevices = [
  LanDevice(
    id: 'mac-01',
    name: 'MacBook Pro 16"',
    deviceType: 'macos',
    httpPort: 52000,
    ip: '192.168.1.102',
    lastSeen: DateTime.now(),
    isOnline: true,
  ),
  LanDevice(
    id: 'win-01',
    name: 'Studio PC (Windows)',
    deviceType: 'windows',
    httpPort: 52000,
    ip: '192.168.1.108',
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
          name: 'MacBook Pro 16"',
          deviceType: 'macos',
          isTrusted: true,
        ),
      ];
}

class MockTrustedDevicesNotifier extends TrustedDevicesNotifier {
  @override
  List<TrustedRemoteDevice> build() => [
        TrustedRemoteDevice(
          id: 'mac-01',
          name: 'MacBook Pro 16"',
          deviceType: 'macos',
          token: 'token-mac',
          pairedAt: DateTime.now(),
        ),
        TrustedRemoteDevice(
          id: 'win-01',
          name: 'Studio PC (Windows)',
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
  }) : _devices = devices ?? defaultMockDiscoveredDevices;

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

/// Test Settings Service
class TestSettingsService extends SettingsService {
  TestSettingsService(super.prefs);

  @override
  void startInactivityTimer() {}

  @override
  void resetInactivity() {}

  @override
  void dispose() {}
}

/// Demo Music Item definition for multi-song test scenarios
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

/// Default 22-album demo set for CoverFlow / Library tests (Chinese)
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

/// Default 22-album demo set for CoverFlow / Library tests (English)
const defaultDemoListEn = [
  DemoItem(
    filename: '01 - Neon After Rain.mp3',
    title: 'Neon After Rain',
    artist: 'Lin Zhou',
    album: 'City Glimmer',
    durationMs: 192000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_01.jpg',
  ),
  DemoItem(
    filename: '02 - Sea Breeze Passing.mp3',
    title: 'Sea Breeze Passing',
    artist: 'Sen Mo',
    album: 'Tide Memoir',
    durationMs: 207974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_02.jpg',
  ),
  DemoItem(
    filename: '03 - Moon at 2AM.mp3',
    title: 'Moon at 2AM',
    artist: 'White Noise Forest',
    album: 'Sleepless Radio',
    durationMs: 224974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_03.jpg',
  ),
  DemoItem(
    filename: '04 - Walking Home at Sunset.mp3',
    title: 'Walking Home at Sunset',
    artist: 'Soda Pop',
    album: 'Summer Slow Motion',
    durationMs: 251974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_04.jpg',
  ),
  DemoItem(
    filename: '05 - Floating Practice.mp3',
    title: 'Floating Practice',
    artist: 'Qing Ye',
    album: 'Weightless Things',
    durationMs: 199974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_05.jpg',
  ),
  DemoItem(
    filename: '06 - Blue Room.mp3',
    title: 'Blue Room',
    artist: 'Noon Park',
    album: 'Room 204',
    durationMs: 274974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_06.jpg',
  ),
  DemoItem(
    filename: '07 - Letter from Afar.mp3',
    title: 'Letter from Afar',
    artist: 'Haruno',
    album: 'Unfinished Journey',
    durationMs: 215974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_07.jpg',
  ),
  DemoItem(
    filename: '08 - Glass Sea.mp3',
    title: 'Glass Sea',
    artist: 'Constellation Band',
    album: 'Beyond Coastlines',
    durationMs: 261974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_08.jpg',
  ),
  DemoItem(
    filename: '09 - Wind Through Old Vinyl.mp3',
    title: 'Wind Through Old Vinyl',
    artist: 'Friday Club',
    album: 'Slow Replay',
    durationMs: 237974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_09.jpg',
  ),
  DemoItem(
    filename: '10 - Leave a Light On.mp3',
    title: 'Leave a Light On',
    artist: 'Night Whisper',
    album: 'Bedtime Stories',
    durationMs: 289974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_10.jpg',
  ),
  DemoItem(
    filename: '11 - Velvet Midnight.mp3',
    title: 'Velvet Midnight',
    artist: 'Lunar Waves',
    album: 'Nightfall Symphony',
    durationMs: 213975,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_11.jpg',
  ),
  DemoItem(
    filename: '12 - Golden Hour Echoes.mp3',
    title: 'Golden Hour Echoes',
    artist: 'Solar Drift',
    album: 'Warm Horizon',
    durationMs: 247974,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_12.jpg',
  ),
  DemoItem(
    filename: '13 - Chasing Fireflies.mp3',
    title: 'Chasing Fireflies',
    artist: 'Amber Glow',
    album: 'Childhood Echoes',
    durationMs: 195000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_13.jpg',
  ),
  DemoItem(
    filename: '14 - Summer Afternoon Nostalgia.mp3',
    title: 'Summer Afternoon Nostalgia',
    artist: 'Sunset Club',
    album: 'July Postcard',
    durationMs: 271973,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_14.jpg',
  ),
  DemoItem(
    filename: '15 - Gentle Awakening.mp3',
    title: 'Gentle Awakening',
    artist: 'Serene Trail',
    album: 'Morning Dew',
    durationMs: 227975,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_15.jpg',
  ),
  DemoItem(
    filename: '16 - Vintage Polaroid.mp3',
    title: 'Vintage Polaroid',
    artist: 'Tape Dreams',
    album: 'Analog Era',
    durationMs: 260000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_16.jpg',
  ),
  DemoItem(
    filename: '17 - Prism Spectrum.mp3',
    title: 'Prism Spectrum',
    artist: 'Neon Mirage',
    album: 'Geometric Moods',
    durationMs: 188000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_17.jpg',
  ),
  DemoItem(
    filename: '18 - Playground Symphony.mp3',
    title: 'Playground Symphony',
    artist: 'Sketchbook',
    album: 'Doodle Wonderland',
    durationMs: 236000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_18.jpg',
  ),
  DemoItem(
    filename: '19 - Desert Wind Whisper.mp3',
    title: 'Desert Wind Whisper',
    artist: 'Oasis Mirage',
    album: 'Silent Dunes',
    durationMs: 283973,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_19.jpg',
  ),
  DemoItem(
    filename: '20 - Cosmic Particles.mp3',
    title: 'Cosmic Particles',
    artist: 'Starlight Theory',
    album: 'Circular Infinity',
    durationMs: 242000,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_20.jpg',
  ),
  DemoItem(
    filename: '21 - Crystal Ballroom.mp3',
    title: 'Crystal Ballroom',
    artist: 'Gilded Age',
    album: 'Art Deco Reverie',
    durationMs: 217975,
    coverPath: '/Volumes/Untitled/projects/vibe_flow/test_covers/cover_21.jpg',
  ),
  DemoItem(
    filename: 'demo1.mp3',
    title: 'Midnight Skyline',
    artist: 'Nova Ensemble',
    album: 'Metropolitan Daydreams',
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
  List<DemoItem> demoItems = defaultDemoList,
}) {
  final metadataMap = <String, SongMetadata>{};
  final musicFiles = <MusicFile>[];
  final albumSummaries = <AlbumSummary>[];

  for (int i = 0; i < demoItems.length; i++) {
    final item = demoItems[i];
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

/// Stage 1: Capture a 1:1 Full-Resolution Mobile App Screen
Future<Uint8List> captureMobileScreen({
  required WidgetTester tester,
  required Widget screenChild,
  required List<dynamic> overrides,
  MobileDeviceSpec deviceSpec = MobileDeviceSpec.iphoneProMax,
  FftFrame? initialFftFrame,
  StreamController<FftFrame>? visualizerStreamController,
  Locale locale = const Locale('zh'),
  Color? scaffoldBackgroundColor,
  ColorScheme? colorScheme,
  String? saveScreenFileName,
}) async {
  await loadMobileTestFonts();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('window_manager'),
    (MethodCall methodCall) async => null,
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockStreamHandler(
    const EventChannel('mobile_storage_listener/events'),
    MockStreamHandler.inline(
      onListen: (args, sink) {},
      onCancel: (args) {},
    ),
  );

  final screenRepaintKey = GlobalKey();

  tester.view.physicalSize = deviceSpec.physicalSize;
  tester.view.devicePixelRatio = deviceSpec.pixelRatio;
  tester.view.padding = FakeViewPadding(
    top: 54.0 * deviceSpec.pixelRatio,
    bottom: 34.0 * deviceSpec.pixelRatio,
    left: 0,
    right: 0,
  );
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);

  final effectiveBgColor = scaffoldBackgroundColor ?? const Color(0xFF07090E);
  final effectiveColorScheme = colorScheme ?? const ColorScheme.dark(
    primary: Color(0xFF38BDF8),
    primaryContainer: Color(0xFF0369A1),
    surface: Color(0xFF0D0F18),
    surfaceContainerLow: Color(0xFF131A26),
    surfaceContainerHighest: Color(0xFF1E293B),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        for (final o in overrides) o,
      ],
      child: OKToast(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            platform: TargetPlatform.iOS,
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
            scaffoldBackgroundColor: effectiveBgColor,
            colorScheme: effectiveColorScheme,
          ),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(deviceSpec.logicalWidth, deviceSpec.logicalHeight),
              devicePixelRatio: deviceSpec.pixelRatio,
              padding: const EdgeInsets.only(
                top: 54.0,
                bottom: 34.0,
              ),
              viewPadding: const EdgeInsets.only(
                top: 54.0,
                bottom: 34.0,
              ),
              platformBrightness: Brightness.dark,
            ),
            child: RepaintBoundary(
              key: screenRepaintKey,
              child: SizedBox(
                width: deviceSpec.logicalWidth,
                height: deviceSpec.logicalHeight,
                child: Material(
                  color: effectiveBgColor,
                  child: screenChild,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  if (initialFftFrame != null && visualizerStreamController != null) {
    visualizerStreamController.add(initialFftFrame);
  }

  await tester.pump();

  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final widget = element.widget as Image;
      await precacheImage(widget.image, element);
    }
    await Future.delayed(const Duration(milliseconds: 350));
  });

  if (initialFftFrame != null && visualizerStreamController != null) {
    visualizerStreamController.add(initialFftFrame);
  }

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));

  Uint8List? screenPngBytes;
  await tester.runAsync(() async {
    final boundary = screenRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: deviceSpec.pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        screenPngBytes = byteData.buffer.asUint8List();
        if (saveScreenFileName != null && saveScreenFileName.isNotEmpty) {
          final file = resolveScreenshotOutputFile(saveScreenFileName);
          file.parent.createSync(recursive: true);
          file.writeAsBytesSync(screenPngBytes!);
          print('SUCCESS_SCREEN_SAVED: ${file.path} (${screenPngBytes!.length} bytes)');
        }
      }
    }
  });

  if (visualizerStreamController != null && !visualizerStreamController.isClosed) {
    await visualizerStreamController.close();
  }

  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);

  return screenPngBytes!;
}

/// Stage 2: Render 1290x2796 Store Marketing Poster embedding the captured screen
Future<Uint8List> renderMobileStorePoster({
  required WidgetTester tester,
  required Uint8List screenBytes,
  required MobilePosterConfig posterConfig,
  MobileDeviceSpec deviceSpec = MobileDeviceSpec.iphoneProMax,
  Locale locale = const Locale('zh'),
}) async {
  await loadMobileTestFonts();

  ui.Image? screenDecodedImage;
  await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(screenBytes);
    final frameInfo = await codec.getNextFrame();
    screenDecodedImage = frameInfo.image;
  });

  if (screenDecodedImage == null) {
    fail('Failed to decode mobile screen image');
  }

  final posterRepaintKey = GlobalKey();

  tester.view.physicalSize = deviceSpec.physicalSize;
  tester.view.devicePixelRatio = deviceSpec.pixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

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
          'Heiti SC',
          'Roboto',
          'sans-serif',
        ],
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF08090D),
        body: RepaintBoundary(
          key: posterRepaintKey,
          child: Container(
            width: deviceSpec.logicalWidth,
            height: deviceSpec.logicalHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: posterConfig.backgroundGradient,
                stops: const [0.0, 0.45, 1.0],
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
                          posterConfig.glowColor.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Top Marketing Typography
                Positioned(
                  top: 54,
                  left: 24,
                  right: 24,
                  child: Column(
                    children: [
                      // Tag badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          posterConfig.tagText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: posterConfig.tagColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Main Title
                      Text(
                        posterConfig.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Subtitle
                      Text(
                        posterConfig.subtitle,
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

                // Framed Phone Device with Drop Shadow embedding high-res screen with exact aspect ratio
                Builder(
                  builder: (context) {
                    const phoneWidth = 376.0;
                    final innerScreenWidth = phoneWidth - deviceSpec.borderWidth * 2;
                    final innerScreenHeight = innerScreenWidth * (deviceSpec.logicalHeight / deviceSpec.logicalWidth);
                    final phoneHeight = innerScreenHeight + deviceSpec.borderWidth * 2;

                    return Positioned(
                      top: 178,
                      width: phoneWidth,
                      height: phoneHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(deviceSpec.cornerRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.65),
                              blurRadius: 36,
                              spreadRadius: 4,
                              offset: const Offset(0, 18),
                            ),
                            BoxShadow(
                              color: posterConfig.glowColor.withValues(alpha: 0.16),
                              blurRadius: 40,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(deviceSpec.cornerRadius),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF4A4E5A),
                                width: deviceSpec.borderWidth,
                              ),
                              borderRadius: BorderRadius.circular(deviceSpec.cornerRadius),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(deviceSpec.cornerRadius - deviceSpec.borderWidth),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  RawImage(
                                    image: screenDecodedImage,
                                    fit: BoxFit.fill,
                                    alignment: Alignment.topCenter,
                                  ),
                                  // Dynamic Island
                                  if (deviceSpec.hasDynamicIsland)
                                    Positioned(
                                      top: 10,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          width: deviceSpec.islandWidth * (innerScreenWidth / deviceSpec.logicalWidth),
                                          height: deviceSpec.islandHeight * (innerScreenWidth / deviceSpec.logicalWidth),
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
                    );
                  },
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
    final boundary = posterRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: deviceSpec.pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        posterPngBytes = byteData.buffer.asUint8List();
        if (posterConfig.outputPosterFileName != null && posterConfig.outputPosterFileName!.isNotEmpty) {
          final file = resolveScreenshotOutputFile(posterConfig.outputPosterFileName!);
          file.parent.createSync(recursive: true);
          file.writeAsBytesSync(posterPngBytes!);
          print('SUCCESS_POSTER_SAVED: ${file.path} (${posterPngBytes!.length} bytes)');
        }
      }
    }
  });

  return posterPngBytes!;
}

/// Unified Two-Stage Mobile Screenshot Pipeline
Future<void> runTwoStageMobilePosterTest({
  required WidgetTester tester,
  required MobilePosterConfig posterConfig,
  required Widget screenChild,
  required List<dynamic> overrides,
  MobileDeviceSpec deviceSpec = MobileDeviceSpec.iphoneProMax,
  FftFrame? initialFftFrame,
  StreamController<FftFrame>? visualizerStreamController,
  Locale locale = const Locale('zh'),
}) async {
  // Stage 1: Render and capture full-bleed native screen
  final screenBytes = await captureMobileScreen(
    tester: tester,
    screenChild: screenChild,
    overrides: overrides,
    deviceSpec: deviceSpec,
    initialFftFrame: initialFftFrame,
    visualizerStreamController: visualizerStreamController,
    locale: locale,
    scaffoldBackgroundColor: posterConfig.screenBackgroundColor,
    colorScheme: posterConfig.screenColorScheme,
    saveScreenFileName: posterConfig.outputScreenFileName,
  );

  // Stage 2: Embed captured screen into stylized store marketing poster
  await renderMobileStorePoster(
    tester: tester,
    screenBytes: screenBytes,
    posterConfig: posterConfig,
    deviceSpec: deviceSpec,
    locale: locale,
  );
}
