// ignore_for_file: avoid_print, override_on_non_overriding_member
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/pages/sharing_page.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/player/sharing/lan_device.dart';
import 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
import 'package:vynody/player/sharing/remote_control/remote_playback_model.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/player/sharing/sharing_service.dart';

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

final _mockDiscoveredDevices = [
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

class _MockSharingServerStateNotifier extends SharingServerStateNotifier {
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

class _MockHostConnectedClientsNotifier extends HostConnectedClientsNotifier {
  @override
  List<ConnectedHostClient> build() => [
        const ConnectedHostClient(
          name: 'MacBook Pro 16"',
          deviceType: 'macos',
          isTrusted: true,
        ),
      ];
}

class _MockTrustedDevicesNotifier extends TrustedDevicesNotifier {
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

class _MockSharingService extends SharingService {
  _MockSharingService(super.ref);

  @override
  String get sharingFolderPath => '/Users/axel10/Music/Vynody Music';

  @override
  Future<String> getDefaultSharingFolderPath() async =>
      '/Users/axel10/Music/Vynody Music';

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
  List<LanDevice> get discoveredDevices => _mockDiscoveredDevices;

  @override
  Stream<List<LanDevice>> get discoveredDevicesStream =>
      Stream.value(_mockDiscoveredDevices);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Finished Store Poster 05 - Multi-Device Connect', (
    tester,
  ) async {
    await _loadFonts();

    SharedPreferences.setMockInitialValues({
      'lan_sharing_enabled': true,
      'allow_remote_control': true,
      'lan_sharing_folder_path': '/Users/axel10/Music/Vynody Music',
    });
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);
    settingsService.lanSharingEnabled = true;
    settingsService.allowRemoteControl = true;
    settingsService.lanSharingFolderPath = '/Users/axel10/Music/Vynody Music';

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
          sharingServiceProvider.overrideWith((ref) => _MockSharingService(ref)),
          sharingServerStateProvider.overrideWith(
            () => _MockSharingServerStateNotifier(),
          ),
          hostConnectedClientsProvider.overrideWith(
            () => _MockHostConnectedClientsNotifier(),
          ),
          trustedDevicesProvider.overrideWith(
            () => _MockTrustedDevicesNotifier(),
          ),
          discoveredDevicesProvider.overrideWith(
            (ref) => Stream.value(_mockDiscoveredDevices),
          ),
          audioCurrentMusicProvider.overrideWith((ref) => null),
          isProUnlockedProvider.overrideWith((ref) => true),
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
                surfaceContainerLow: Color(0xFF131A26),
                surfaceContainerHighest: Color(0xFF1E293B),
                outlineVariant: Color(0xFF334155),
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
                            // Tag badge: 全平台安全互联
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
                                '全平台安全互联',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF38BDF8),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Main Title: 多端互联
                            const Text(
                              '多端互联',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Subtitle: TLS 端到端加密 · 局域网无损秒传与跨端遥控
                            Text(
                              'TLS 端到端加密 · 局域网无损秒传与跨端遥控',
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
                                  child: const MediaQuery(
                                    data: MediaQueryData(
                                      padding: EdgeInsets.only(
                                        top: 44,
                                        bottom: 34,
                                      ),
                                      viewPadding: EdgeInsets.only(
                                        top: 44,
                                        bottom: 34,
                                      ),
                                    ),
                                    child: SharingPage(),
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
        final outPoster =
            '/Volumes/Untitled/projects/vibe_flow/screenshots/store_mockup_05_multidevice.png';
        final outPosterAlt =
            '/Volumes/Untitled/projects/vibe_flow/screenshots/store_mockup_05_sharing.png';
        final outBrain =
            '/Users/axel10/.gemini/antigravity-ide/brain/f87ee87b-a793-4870-9b6c-aa6c53451547/store_finished_mockup_05.png';

        File(outPoster).parent.createSync(recursive: true);
        File(outBrain).parent.createSync(recursive: true);
        File(outPoster).writeAsBytesSync(pngBytes);
        File(outPosterAlt).writeAsBytesSync(pngBytes);
        File(outBrain).writeAsBytesSync(pngBytes);
        print('SUCCESS_POSTER_SAVED: $outPoster (${pngBytes.length} bytes)');
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
        final outScreen =
            '/Volumes/Untitled/projects/vibe_flow/screenshots/multidevice_ios_raw.png';
        File(outScreen).writeAsBytesSync(pngBytes);
        print('SUCCESS_RAW_SCREEN_SAVED: $outScreen (${pngBytes.length} bytes)');
      }
    }

    print('ALL_DONE_EXITING');
    exit(0);
  });
}
