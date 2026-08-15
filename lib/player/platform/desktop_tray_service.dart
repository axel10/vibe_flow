import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/utils/localized_text.dart';
import 'package:path/path.dart' as path;
import 'package:vynody/main.dart';
import 'package:vynody/utils/app_log.dart';
import 'package:flutter_desktop_tray/flutter_desktop_tray.dart' as ft;

class DesktopTrayService with WindowListener {
  final AudioService audioService;
  final SettingsService settingsService;
  bool _initialized = false;
  bool? _lastIsPlaying;
  bool? _lastIsMuted;
  bool? _lastIsWindowVisible;
  final ft.FlutterTray _tray = ft.FlutterTray();
  StreamSubscription<ft.TrayEvent>? _eventSubscription;

  static const int _idPrevious = 1;
  static const int _idTogglePlay = 2;
  static const int _idNext = 3;
  static const int _idToggleMute = 4;
  static const int _idSeparator = 5;
  static const int _idToggleWindow = 6;
  static const int _idDisableTray = 7;
  static const int _idExit = 8;

  DesktopTrayService({
    required this.audioService,
    required this.settingsService,
  }) {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      settingsService.addListener(_handleSettingsChange);
      windowManager.addListener(this);
      _syncTrayState();
    }
  }

  void _handleSettingsChange() {
    _syncTrayState();
  }

  Future<void> _syncTrayState() async {
    final enabled = settingsService.enableSystemTray;
    if (enabled && !_initialized) {
      await _initTray();
    } else if (!enabled && _initialized) {
      await _destroyTray();
    }
  }

  String _getIconAbsolutePath(String assetPath) {
    if (Platform.isMacOS) {
      final baseDir = path.dirname(Platform.resolvedExecutable);
      final frameworkPath = path.normalize(path.joinAll([
        baseDir,
        '../Frameworks/App.framework/Resources/flutter_assets',
        assetPath,
      ]));
      if (File(frameworkPath).existsSync()) {
        return frameworkPath;
      }
      return path.normalize(path.joinAll([
        baseDir,
        '../Resources/flutter_assets',
        assetPath,
      ]));
    } else {
      return path.normalize(path.joinAll([
        path.dirname(Platform.resolvedExecutable),
        'data/flutter_assets',
        assetPath,
      ]));
    }
  }

  Future<void> _initTray() async {
    try {
      debugPrint('[Tray] Initializing system tray...');
      final iconRelativePath = Platform.isWindows ? 'assets/icons/tray_shadow.ico' : 'assets/icons/tray.png';
      final iconAbsolutePath = _getIconAbsolutePath(iconRelativePath);
      debugPrint('[Tray] Absolute icon path: $iconAbsolutePath');

      final success = await _tray.initTray(
        iconPath: iconAbsolutePath,
        tooltip: 'Vynody',
      );

      if (success) {
        _eventSubscription?.cancel();
        _eventSubscription = _tray.eventStream.listen((event) {
          switch (event.type) {
            case ft.TrayEventType.leftClick:
              debugPrint('[Tray] Left click');
              _showAndFocusWindow();
              break;
            case ft.TrayEventType.rightClick:
              debugPrint('[Tray] Right click');
              break;
            case ft.TrayEventType.menuClick:
              debugPrint('[Tray] Menu click: id=${event.menuId}');
              _handleMenuItemClick(event.menuId);
              break;
          }
        });

        _initialized = true;
        debugPrint('[Tray] System tray initialized. Setting up menu...');
        await updateMenu(force: true);
      } else {
        debugPrint('[Tray] Failed to initialize tray: initTray returned false');
      }
    } catch (e) {
      debugPrint('[Tray] Failed to initialize tray: $e');
    }
  }

  Future<void> _destroyTray() async {
    try {
      _eventSubscription?.cancel();
      _eventSubscription = null;
      await _tray.destroy();
      _initialized = false;
      _lastIsPlaying = null;
      _lastIsMuted = null;
      _lastIsWindowVisible = null;
      debugPrint('[Tray] System tray destroyed.');
    } catch (e) {
      debugPrint('Failed to destroy tray: $e');
    }
  }

  Future<bool> _isWindowActiveOnScreen() async {
    try {
      final isVisible = await windowManager.isVisible();
      final isMinimized = await windowManager.isMinimized();
      return isVisible && !isMinimized;
    } catch (e) {
      return true;
    }
  }

  @override
  void onWindowMinimize() {
    updateMenu(force: true);
  }

  @override
  void onWindowRestore() {
    updateMenu(force: true);
  }

  @override
  void onWindowFocus() {
    updateMenu(force: true);
  }

  Future<void> updateMenu({bool force = false}) async {
    if (!_initialized) {
      return;
    }

    final isPlaying = audioService.isPlaying;
    final isMuted = audioService.isMuted;
    final isWindowVisible = await _isWindowActiveOnScreen();

    if (!force &&
        isPlaying == _lastIsPlaying &&
        isMuted == _lastIsMuted &&
        isWindowVisible == _lastIsWindowVisible) {
      return;
    }

    _lastIsPlaying = isPlaying;
    _lastIsMuted = isMuted;
    _lastIsWindowVisible = isWindowVisible;

    try {
      final l10n = currentAppL10n;
      await _tray.setMenu([
        ft.MenuItem(
          id: _idPrevious,
          label: l10n.previous,
        ),
        ft.MenuItem(
          id: _idTogglePlay,
          label: isPlaying ? l10n.pause : l10n.play,
        ),
        ft.MenuItem(
          id: _idNext,
          label: l10n.next,
        ),
        ft.MenuItem(
          id: _idToggleMute,
          label: isMuted ? l10n.unmute : l10n.mute,
        ),
        ft.MenuItem.separator(_idSeparator),
        ft.MenuItem(
          id: _idToggleWindow,
          label: isWindowVisible ? l10n.hideWindow : l10n.restoreWindow,
        ),
        ft.MenuItem(
          id: _idDisableTray,
          label: l10n.disableSystemTray,
        ),
        ft.MenuItem(
          id: _idExit,
          label: l10n.exitApp,
        ),
      ]);
    } catch (e) {
      debugPrint('[Tray] Failed to set tray context menu: $e');
    }
  }

  void _handleMenuItemClick(int? id) {
    if (id == null) return;
    switch (id) {
      case _idPrevious:
        audioService.previous();
        break;
      case _idTogglePlay:
        audioService.togglePlay();
        break;
      case _idNext:
        audioService.next();
        break;
      case _idToggleMute:
        audioService.toggleMute();
        break;
      case _idToggleWindow:
        _toggleWindowVisibility();
        break;
      case _idDisableTray:
        _showAndFocusWindow();
        settingsService.enableSystemTray = false;
        break;
      case _idExit:
        performCleanExit();
        break;
    }
  }

  Future<void> _toggleWindowVisibility() async {
    try {
      final isVisible = await _isWindowActiveOnScreen();
      if (isVisible) {
        AppLog.log('[Tray] Hiding window...', mirrorToConsole: true);
        await windowManager.hide();
      } else {
        AppLog.log('[Tray] Restoring window...', mirrorToConsole: true);
        await _showAndFocusWindow();
      }
      await updateMenu(force: true);
    } catch (e) {
      AppLog.log('[Tray] Failed to toggle window visibility: $e', mirrorToConsole: true);
    }
  }

  Future<void> _showAndFocusWindow() async {
    try {
      AppLog.log('[Tray] _showAndFocusWindow called', mirrorToConsole: true);
      final isMinimized = await windowManager.isMinimized();
      AppLog.log('[Tray] window isMinimized=$isMinimized', mirrorToConsole: true);
      if (isMinimized) {
        await windowManager.restore();
      }
      await windowManager.show();
      await windowManager.focus();
      AppLog.log('[Tray] window reshown & focused, reapplying taskbar buttons...', mirrorToConsole: true);
      audioService.windowsIntegration?.reapplyTaskbarButtons();
      await updateMenu(force: true);
    } catch (e) {
      AppLog.log('[Tray] Failed to show and focus window: $e', mirrorToConsole: true);
    }
  }

  void dispose() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      settingsService.removeListener(_handleSettingsChange);
      windowManager.removeListener(this);
      _destroyTray();
    }
  }
}

