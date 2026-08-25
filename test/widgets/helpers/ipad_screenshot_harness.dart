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

import 'mobile_screenshot_harness.dart'
    show
        DemoItem,
        defaultDemoList,
        defaultDemoListEn,
        createDemoLibraryData,
        generateRealisticWaveform,
        generateFftBandsDefault,
        parseLrc;
import 'screenshot_paths.dart';

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
export 'mobile_screenshot_harness.dart'
    show
        DemoItem,
        defaultDemoList,
        defaultDemoListEn,
        createDemoLibraryData,
        generateRealisticWaveform,
        generateFftBandsDefault,
        parseLrc,
        MockLyricsController,
        MockAudioService,
        MockScannerService,
        TestSettingsService,
        MockSharingService,
        MockSharingServerStateNotifier,
        MockHostConnectedClientsNotifier,
        MockTrustedDevicesNotifier,
        defaultMockDiscoveredDevices;
export 'screenshot_paths.dart';

/// Helper function to resolve full output path
File resolveScreenshotOutputFile(String pathOrFilename) =>
    ScreenshotPaths.resolve(pathOrFilename);

class _MockMobileStorageListenerPlatform extends MobileStorageListenerPlatform
    with MockPlatformInterfaceMixin {
  @override
  Stream<MobileStorageEvent> storageEvents({bool detectInternalVolumes = true}) {
    return const Stream.empty();
  }
}

/// Loads system/fallback fonts for screenshot rendering.
Future<void> loadIpadTestFonts() async {
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

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('window_manager'),
    (MethodCall methodCall) async => null,
  );
}

/// iPad device specifications for 13-inch iPad Pro (2048 x 2732 physical).
class IpadDeviceSpec {
  const IpadDeviceSpec({
    required this.name,
    required this.physicalSize,
    required this.pixelRatio,
    required this.logicalWidth,
    required this.logicalHeight,
    required this.cornerRadius,
    required this.borderWidth,
  });

  final String name;
  final Size physicalSize;
  final double pixelRatio;
  final double logicalWidth;
  final double logicalHeight;
  final double cornerRadius;
  final double borderWidth;

  /// Standard 13-inch iPad Pro (1024 x 1366 logical, 2048 x 2732 physical @ 2x DPR)
  static const IpadDeviceSpec ipadPro13 = IpadDeviceSpec(
    name: 'iPad Pro 13"',
    physicalSize: Size(2048, 2732),
    pixelRatio: 2.0,
    logicalWidth: 1024,
    logicalHeight: 1366,
    cornerRadius: 32,
    borderWidth: 6.0,
  );
}

/// iPad Marketing Poster Layout Configuration
class IpadPosterConfig {
  const IpadPosterConfig({
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

/// Stage 1: Capture a 1:1 Full-Resolution iPad Screen (2048 x 2732)
Future<Uint8List> captureIpadScreen({
  required WidgetTester tester,
  required Widget screenChild,
  required List<dynamic> overrides,
  IpadDeviceSpec deviceSpec = IpadDeviceSpec.ipadPro13,
  FftFrame? initialFftFrame,
  StreamController<FftFrame>? visualizerStreamController,
  Locale locale = const Locale('zh'),
  Color? scaffoldBackgroundColor,
  ColorScheme? colorScheme,
  String? saveScreenFileName,
}) async {
  await loadIpadTestFonts();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('window_manager'),
    (MethodCall methodCall) async => null,
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockStreamHandler(
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
    top: 24.0 * deviceSpec.pixelRatio,
    bottom: 20.0 * deviceSpec.pixelRatio,
    left: 0,
    right: 0,
  );
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);

  final effectiveBgColor = scaffoldBackgroundColor ?? const Color(0xFF07090E);
  final effectiveColorScheme = colorScheme ??
      const ColorScheme.dark(
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
                top: 24.0,
                bottom: 20.0,
              ),
              viewPadding: const EdgeInsets.only(
                top: 24.0,
                bottom: 20.0,
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
    final boundary =
        screenRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: deviceSpec.pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        screenPngBytes = byteData.buffer.asUint8List();
        if (saveScreenFileName != null && saveScreenFileName.isNotEmpty) {
          final file = resolveScreenshotOutputFile(saveScreenFileName);
          file.parent.createSync(recursive: true);
          file.writeAsBytesSync(screenPngBytes!);
          print(
              'SUCCESS_IPAD_SCREEN_SAVED: ${file.path} (${screenPngBytes!.length} bytes)');
        }
      }
    }
  });

  if (visualizerStreamController != null &&
      !visualizerStreamController.isClosed) {
    await visualizerStreamController.close();
  }

  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);

  return screenPngBytes!;
}

/// Stage 2: Render 2048x2732 iPad App Store Marketing Poster embedding the captured screen
Future<Uint8List> renderIpadStorePoster({
  required WidgetTester tester,
  required Uint8List screenBytes,
  required IpadPosterConfig posterConfig,
  IpadDeviceSpec deviceSpec = IpadDeviceSpec.ipadPro13,
  Locale locale = const Locale('zh'),
}) async {
  await loadIpadTestFonts();

  ui.Image? screenDecodedImage;
  await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(screenBytes);
    final frameInfo = await codec.getNextFrame();
    screenDecodedImage = frameInfo.image;
  });

  if (screenDecodedImage == null) {
    fail('Failed to decode iPad screen image');
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
                // Ambient Glow behind iPad device
                Positioned(
                  top: 260,
                  child: Container(
                    width: 720,
                    height: 720,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          posterConfig.glowColor.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Top Marketing Typography
                Positioned(
                  top: 56,
                  left: 48,
                  right: 48,
                  child: Column(
                    children: [
                      // Tag badge
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          posterConfig.tagText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: posterConfig.tagColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Main Title
                      Text(
                        posterConfig.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        posterConfig.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.72),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Framed iPad Device with Drop Shadow embedding high-res screen with exact aspect ratio
                Builder(
                  builder: (context) {
                    const ipadFrameWidth = 830.0;
                    final innerScreenWidth =
                        ipadFrameWidth - deviceSpec.borderWidth * 2;
                    final innerScreenHeight = innerScreenWidth *
                        (deviceSpec.logicalHeight / deviceSpec.logicalWidth);
                    final ipadFrameHeight =
                        innerScreenHeight + deviceSpec.borderWidth * 2;

                    return Positioned(
                      top: 216,
                      width: ipadFrameWidth,
                      height: ipadFrameHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(deviceSpec.cornerRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.7),
                              blurRadius: 48,
                              spreadRadius: 6,
                              offset: const Offset(0, 24),
                            ),
                            BoxShadow(
                              color:
                                  posterConfig.glowColor.withValues(alpha: 0.20),
                              blurRadius: 52,
                              spreadRadius: 0,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(deviceSpec.cornerRadius),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF424754),
                                width: deviceSpec.borderWidth,
                              ),
                              borderRadius:
                                  BorderRadius.circular(deviceSpec.cornerRadius),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  deviceSpec.cornerRadius -
                                      deviceSpec.borderWidth),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  RawImage(
                                    image: screenDecodedImage,
                                    fit: BoxFit.fill,
                                    alignment: Alignment.topCenter,
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
    final boundary =
        posterRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: deviceSpec.pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        posterPngBytes = byteData.buffer.asUint8List();
        if (posterConfig.outputPosterFileName != null &&
            posterConfig.outputPosterFileName!.isNotEmpty) {
          final file =
              resolveScreenshotOutputFile(posterConfig.outputPosterFileName!);
          file.parent.createSync(recursive: true);
          file.writeAsBytesSync(posterPngBytes!);
          print(
              'SUCCESS_IPAD_POSTER_SAVED: ${file.path} (${posterPngBytes!.length} bytes)');
        }
      }
    }
  });

  return posterPngBytes!;
}

/// Unified Two-Stage iPad Screenshot Pipeline
Future<void> runTwoStageIpadPosterTest({
  required WidgetTester tester,
  required IpadPosterConfig posterConfig,
  required Widget screenChild,
  required List<dynamic> overrides,
  IpadDeviceSpec deviceSpec = IpadDeviceSpec.ipadPro13,
  FftFrame? initialFftFrame,
  StreamController<FftFrame>? visualizerStreamController,
  Locale locale = const Locale('zh'),
}) async {
  // Stage 1: Render and capture full-bleed native iPad screen
  final screenBytes = await captureIpadScreen(
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
  await renderIpadStorePoster(
    tester: tester,
    screenBytes: screenBytes,
    posterConfig: posterConfig,
    deviceSpec: deviceSpec,
    locale: locale,
  );
}
