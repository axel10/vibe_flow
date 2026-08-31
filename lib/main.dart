import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:worker_manager/worker_manager.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';
import 'dialogs/close_window_action_dialog.dart';
import 'l10n/app_localizations.dart';
import 'pages/main_layout.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/lyrics/lyrics_ai_temp_files.dart';
import 'package:vynody/player/library/music_file_utils.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:smtc_windows/smtc_windows.dart';
import 'utils/app_log.dart';
import 'utils/memory_trace.dart';
import 'package:vynody/player/sharing/security/tls_certificate_service.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/pro/iap_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final List<String> _pendingFileOpenArgs = <String>[];
Timer? _pendingFileOpenRetryTimer;

/// 处理从外部（如双击、命令行）打开的文件列表
/// [args] 是外部传入的路径参数列表
void queueFileOpen(List<String> args) {
  if (args.isEmpty) return;
  AppLog.log(
    '[external-open] queueFileOpen args=$args pendingBefore=${_pendingFileOpenArgs.length}',
    mirrorToConsole: true,
  );
  _pendingFileOpenArgs.addAll(args);
  _tryDrainPendingFileOpenArgs();
}

void _tryDrainPendingFileOpenArgs() {
  if (_pendingFileOpenArgs.isEmpty) return;

  final context = navigatorKey.currentContext; // 获取全局导航上下文以访问 Provider
  if (context == null) {
    AppLog.log(
      '[external-open] navigator context not ready, will retry; pending=${_pendingFileOpenArgs.length}',
      mirrorToConsole: true,
    );
    _pendingFileOpenRetryTimer ??= Timer(const Duration(milliseconds: 100), () {
      _pendingFileOpenRetryTimer = null;
      _tryDrainPendingFileOpenArgs();
    });
    return;
  }

  final args = List<String>.from(_pendingFileOpenArgs);
  _pendingFileOpenArgs.clear();
  _pendingFileOpenRetryTimer?.cancel();
  _pendingFileOpenRetryTimer = null;

  AppLog.log('[external-open] draining args=$args', mirrorToConsole: true);

  unawaited(_handleFileOpenArgs(context, args));
}

Future<void> _handleFileOpenArgs(
  BuildContext context,
  List<String> args,
) async {
  final container = ProviderScope.containerOf(context);
  final audio = container.read(audioServiceProvider);

  AppLog.log(
    '[external-open] handleFileOpenArgs start args=$args',
    mirrorToConsole: true,
  );

  for (var arg in args) {
    // 处理路径中可能的双引号和两端空格
    final path = arg.replaceAll('"', '').trim();
    if (path.isEmpty) {
      AppLog.log(
        '[external-open] skip empty arg: "$arg"',
        mirrorToConsole: true,
      );
      continue;
    }

    // 检查文件是否存在
    final exists = path.startsWith('content://') || File(path).existsSync();
    final isMusic = path.startsWith('content://') || MusicFileUtils.isMusicFilePath(path);
    AppLog.log(
      '[external-open] inspect path=$path exists=$exists isMusic=$isMusic',
      mirrorToConsole: true,
    );
    if (!exists) {
      continue;
    }

    // 如果是支持的音频文件
    if (isMusic) {
      AppLog.log(
        '[external-open] playFile begin path=$path',
        mirrorToConsole: true,
      );
      // 将文件添加到播放队列并开始播放
      // append: false 表示清空队列并将此歌曲设为唯一歌曲播放
      await audio.playFile(path, p.basename(path), append: false);
      AppLog.log(
        '[external-open] playFile done path=$path',
        mirrorToConsole: true,
      );

      // 自动跳转到播放详情界面（索引为1的 Tab）
      AppLog.log(
        '[external-open] navigateToMainTab(1) begin path=$path',
        mirrorToConsole: true,
      );
      if (!context.mounted) {
        return;
      }
      await navigateToMainTab(context, index: 1);
      AppLog.log(
        '[external-open] navigateToMainTab(1) done path=$path',
        mirrorToConsole: true,
      );

      // 逻辑：匹配到第一个支持的文件即处理并跳出，避免一次打开大量文件导致界面混乱
      break;
    }
  }

  AppLog.log('[external-open] handleFileOpenArgs end', mirrorToConsole: true);
}

void main(List<String> args) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await AppLog.init();
      AppLog.install();
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details); // 强制在控制台显示
        AppLog.log(
          'Caught FlutterError: ${details.exceptionAsString()}',
          mirrorToConsole: true,
          stackTrace: details.stack,
        );
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        AppLog.log(
          'Caught PlatformDispatcher error: $error',
          mirrorToConsole: true,
          stackTrace: stack,
        );
        return false;
      };

      HttpOverrides.global = LanHttpOverrides();

      if (Platform.isAndroid) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
      AppLog.log('main start args=$args', mirrorToConsole: true);
      final traceMemory =
          args.any(
            (arg) => arg == '--trace-memory' || arg == '--memory-trace',
          ) ||
          Platform.environment['VYNODY_TRACE_MEMORY'] == '1';
      MemoryTrace.configure(enabled: traceMemory);
      MemoryTrace.snapshot(
        'main:start',
        details: <String, Object?>{'args': args.length},
      );

      if (Platform.isWindows) {
        AppLog.log(
          'registering single instance handler',
          mirrorToConsole: true,
        );
        const singleInstanceChannel = MethodChannel('vynody/single_instance');
        singleInstanceChannel.setMethodCallHandler((call) async {
          if (call.method == 'onSecondInstance') {
            try {
              if (await windowManager.isMinimized()) {
                await windowManager.restore();
              }
              await windowManager.show();
              await windowManager.focus();
            } catch (e) {
              AppLog.log('Failed to restore window on second instance: $e', mirrorToConsole: true);
            }

            final List<dynamic> rawArgs = call.arguments;
            final argsList = rawArgs.cast<String>();
            AppLog.log(
              'second window args=$argsList count=${argsList.length}',
              mirrorToConsole: true,
            );
            queueFileOpen(argsList);
          }
        });
      }

      if (Platform.isMacOS || Platform.isAndroid) {
        AppLog.log(
          '[file-opener] registering file opener channel for ${Platform.operatingSystem}',
          mirrorToConsole: true,
        );
        const fileOpenerChannel = MethodChannel('vynody/file_opener');
        fileOpenerChannel.setMethodCallHandler((call) async {
          AppLog.log(
            '[file-opener] received method call: method=${call.method} args=${call.arguments}',
            mirrorToConsole: true,
          );
          if (call.method == 'onOpenFiles') {
            final List<dynamic> rawArgs = call.arguments;
            final argsList = rawArgs.cast<String>();
            AppLog.log(
              '[file-opener] onOpenFiles processing args=$argsList count=${argsList.length}',
              mirrorToConsole: true,
            );
            queueFileOpen(argsList);
          }
        });

        try {
          AppLog.log(
            '[file-opener] invoking getPendingFiles...',
            mirrorToConsole: true,
          );
          final List<dynamic>? pending = await fileOpenerChannel.invokeMethod(
            'getPendingFiles',
          );
          AppLog.log(
            '[file-opener] getPendingFiles returned: $pending',
            mirrorToConsole: true,
          );
          if (pending != null && pending.isNotEmpty) {
            final argsList = pending.cast<String>();
            AppLog.log(
              '[file-opener] queueing pending files=$argsList',
              mirrorToConsole: true,
            );
            queueFileOpen(argsList);
          }
        } catch (e) {
          AppLog.log(
            '[file-opener] failed to get pending files: $e',
            mirrorToConsole: true,
          );
        }
      }

      AppLog.log('initializing settings service', mirrorToConsole: true);
      final settingsService = await SettingsService.init();
      MemoryTrace.snapshot('main:settings-ready');

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        AppLog.log('initializing window manager', mirrorToConsole: true);
        await windowManager.ensureInitialized();
        WindowOptions windowOptions = WindowOptions(
          size: settingsService.savedRegularWindowSize,
          minimumSize: const Size(400, 650),
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.hidden,
          title: 'Vynody',
        );
        windowManager.waitUntilReadyToShow(windowOptions, () async {
          AppLog.log('window ready to show', mirrorToConsole: true);
          MemoryTrace.snapshot('main:window-ready');
          await windowManager.show();
          await windowManager.focus();
        });
      }

      if (Platform.isWindows) {
        AppLog.log('initializing SMTCWindows', mirrorToConsole: true);
        await SMTCWindows.initialize();
      }

      if (Platform.isWindows) {
        try {
          if (settingsService.windowsAutoRepairShortcut) {
            const MethodChannel(
              'vynody/single_instance',
            ).invokeMethod('registerShortcut');
          }
        } catch (e) {
          AppLog.log(
            'failed to trigger registerShortcut: $e',
            mirrorToConsole: true,
          );
        }
      }
      AppLog.log(
        'cleaning lyrics AI temporary transcode files',
        mirrorToConsole: true,
      );
      await cleanupLyricsAiTempArtifacts();
      AppLog.log('initializing worker manager', mirrorToConsole: true);
      unawaited(workerManager.init(isolatesCount: 8));

      AppLog.log('calling runApp', mirrorToConsole: true);
      MemoryTrace.snapshot('main:runApp');
      runApp(
        ProviderScope(
          overrides: [
            settingsServiceProvider.overrideWith((ref) => settingsService),
          ],
          child: MyApp(args: args),
        ),
      );
    },
    (error, stack) {
      AppLog.log(
        'Caught zone error: $error',
        mirrorToConsole: true,
        stackTrace: stack,
      );
    },
  );
}

class MyApp extends ConsumerStatefulWidget {
  final List<String> args;
  const MyApp({super.key, required this.args});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

bool isExplicitAppExit = false;

Future<void> performCleanExit() async {
  if (isExplicitAppExit) {
    exit(0);
  }
  isExplicitAppExit = true;
  AppLog.log(
    'Explicit exit requested, closing database cleanly...',
    mirrorToConsole: true,
  );
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    try {
      await windowManager.hide();
    } catch (_) {}
  }
  try {
    await MetadataDatabase().close().timeout(
      const Duration(milliseconds: 300),
      onTimeout: () {
        AppLog.log(
          'Database close timed out during exit, forcing exit.',
          mirrorToConsole: true,
        );
      },
    );
    AppLog.log('Database closed cleanly.', mirrorToConsole: true);
  } catch (e, s) {
    AppLog.log(
      'Error closing database during exit: $e',
      mirrorToConsole: true,
      stackTrace: s,
    );
  }
  exit(0);
}

class _MyAppState extends ConsumerState<MyApp>
    with WindowListener, WidgetsBindingObserver {
  bool _isMaximized = false;
  bool _isFullScreen = false;

  static const double _linuxWindowCornerRadius = 18.0;

  @override
  void initState() {
    super.initState();
    ref.read(audioServiceWiringProvider);
    ref.read(iapServiceProvider);
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
      windowManager.setPreventClose(true);
      if (Platform.isLinux) {
        _syncWindowState();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowClose() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final settings = ref.read(settingsServiceProvider);

      // If system tray is disabled, exit directly without prompt or hide
      if (!settings.enableSystemTray) {
        await performCleanExit();
        return;
      }

      var action = settings.closeWindowAction;
      if (action == CloseWindowAction.ask) {
        await windowManager.show();
        await windowManager.focus();

        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          final result = await showDialog<CloseWindowActionResult>(
            context: context,
            barrierDismissible: false,
            builder: (dialogCtx) => const CloseWindowActionDialog(),
          );

          if (result == null) {
            // User cancelled the dialog, do not hide or exit.
            return;
          }

          if (result.remember) {
            settings.closeWindowAction = result.action;
          }
          action = result.action;
        } else {
          await performCleanExit();
          return;
        }
      }

      if (action == CloseWindowAction.minimize) {
        await windowManager.hide();
      } else if (action == CloseWindowAction.exit) {
        await performCleanExit();
      }
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    AppLog.log(
      'AppExit request received, closing database cleanly...',
      mirrorToConsole: true,
    );
    await performCleanExit();
    return AppExitResponse.exit;
  }

  Future<void> _syncWindowState() async {
    if (!mounted) return;
    final isMax = await windowManager.isMaximized();
    final isFull = await windowManager.isFullScreen();
    if (!mounted) return;
    setState(() {
      _isMaximized = isMax;
      _isFullScreen = isFull;
    });
  }

  @override
  void onWindowMaximize() {
    _syncWindowState();
  }

  @override
  void onWindowUnmaximize() {
    _syncWindowState();
  }

  @override
  void onWindowEnterFullScreen() {
    _syncWindowState();
  }

  @override
  void onWindowLeaveFullScreen() {
    _syncWindowState();
  }

  @override
  void onWindowRestore() {
    _syncWindowState();
  }

  ThemeData _buildTheme(Brightness brightness, Color primaryColor) {
    final isDark = brightness == Brightness.dark;
    final isPrimaryDark =
        ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark;
    final onPrimary = isPrimaryDark ? Colors.white : Colors.black;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    ).copyWith(
      primary: primaryColor,
      onPrimary: onPrimary,
      surface: isDark ? Colors.black : null,
    );
    final snackBarBackground = isDark ? const Color(0xFF1F1F1F) : Colors.white;
    final snackBarForeground = isDark ? Colors.white : Colors.black;

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? Colors.black : null,
      useMaterial3: true,
      fontFamily: 'Segoe UI',
      fontFamilyFallback: const [
        'Microsoft YaHei UI',
        'Microsoft YaHei',
        'PingFang SC',
        'Heiti SC',
        'Noto Sans CJK SC',
        'Noto Sans SC',
        'Source Han Sans SC',
        'sans-serif',
      ],
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: snackBarBackground,
        contentTextStyle: TextStyle(
          color: snackBarForeground,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: snackBarForeground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      listTileTheme: const ListTileThemeData(
        enableFeedback: false,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          enableFeedback: false,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        enableFeedback: false,
        color: isDark ? null : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        surfaceTintColor: Colors.transparent,
      ),

      // 将焦点颜色设为透明
      // focusColor: Colors.transparent,
      // 将悬停颜色设为透明
      // hoverColor: Colors.transparent,
      // 顺便可以处理掉点击时的水波纹按下颜色
      // highlightColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsServiceProvider);
    final themeColor = settings.themeColor;
    Widget app = OKToast(
      child: MaterialApp(
        title: 'Vynody',
        locale: settings.effectiveLocale,
        theme: _buildTheme(Brightness.light, themeColor),
        darkTheme: _buildTheme(Brightness.dark, themeColor),
        themeMode: settings.themeMode,
        builder: (context, child) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final scale = settings.uiScale;
          Widget content = child ?? const SizedBox.shrink();

          if (scale != 1.0) {
            final mediaQuery = MediaQuery.of(context);
            final scaledSize = mediaQuery.size / scale;
            content = MediaQuery(
              data: mediaQuery.copyWith(
                size: scaledSize,
                devicePixelRatio: mediaQuery.devicePixelRatio * scale,
                textScaler: TextScaler.linear(scale),
              ),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: 0.0,
                  maxWidth: double.infinity,
                  minHeight: 0.0,
                  maxHeight: double.infinity,
                  child: SizedBox(
                    width: scaledSize.width,
                    height: scaledSize.height,
                    child: content,
                  ),
                ),
              ),
            );
          }

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
            child: ColoredBox(
              color: theme.colorScheme.surface,
              child: content,
            ),
          );
        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainLayout(args: widget.args),
        navigatorKey: navigatorKey,
      ),
    );

    if (Platform.isLinux) {
      final double radius = (_isMaximized || _isFullScreen)
          ? 0.0
          : _linuxWindowCornerRadius;
      app = ClipRRect(borderRadius: BorderRadius.circular(radius), child: app);
    }

    return app;
  }
}
