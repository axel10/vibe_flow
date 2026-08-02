import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/utils/localized_text.dart';
import 'package:path/path.dart' as path;
import 'package:vynody/main.dart';
import 'package:flutter_tray/flutter_tray.dart' as ft;

class DesktopTrayService {
  final AudioService audioService;
  final SettingsService settingsService;
  bool _initialized = false;
  bool? _lastIsPlaying;
  bool? _lastIsMuted;
  final ft.FlutterTray _tray = ft.FlutterTray();
  StreamSubscription<ft.TrayEvent>? _eventSubscription;

  static const int _idPrevious = 1;
  static const int _idTogglePlay = 2;
  static const int _idNext = 3;
  static const int _idToggleMute = 4;
  static const int _idSeparator = 5;
  static const int _idDisableTray = 6;
  static const int _idExit = 7;

  DesktopTrayService({
    required this.audioService,
    required this.settingsService,
  }) {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      settingsService.addListener(_handleSettingsChange);
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
      final iconRelativePath = Platform.isWindows ? 'assets/images/app_icon.ico' : 'assets/images/icon.png';
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
      debugPrint('[Tray] System tray destroyed.');
    } catch (e) {
      debugPrint('Failed to destroy tray: $e');
    }
  }

  Future<void> updateMenu({bool force = false}) async {
    if (!_initialized) {
      return;
    }

    final isPlaying = audioService.isPlaying;
    final isMuted = audioService.isMuted;

    if (!force && isPlaying == _lastIsPlaying && isMuted == _lastIsMuted) {
      return;
    }

    _lastIsPlaying = isPlaying;
    _lastIsMuted = isMuted;

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
      case _idDisableTray:
        settingsService.enableSystemTray = false;
        break;
      case _idExit:
        _destroyTray().then((_) {
          performCleanExit();
        });
        break;
    }
  }

  Future<void> _showAndFocusWindow() async {
    try {
      final isMinimized = await windowManager.isMinimized();
      if (isMinimized) {
        await windowManager.restore();
      }
      await windowManager.show();
      await windowManager.focus();
    } catch (e) {
      debugPrint('Failed to show and focus window: $e');
    }
  }

  void dispose() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      settingsService.removeListener(_handleSettingsChange);
      _destroyTray();
    }
  }
}

