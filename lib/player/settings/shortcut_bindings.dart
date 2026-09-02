import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:vynody/utils/localized_text.dart';

enum AppShortcutAction {
  playPause,
  next,
  previous,
  volumeUp,
  volumeDown,
  mute,
  seekForward,
  seekBackward,
  toggleFullScreen,
  toggleWasapiExclusive,
}

extension AppShortcutActionX on AppShortcutAction {
  AppLocalizations get _l10n => currentAppL10n;

  String get storageKey => switch (this) {
    AppShortcutAction.playPause => 'play_pause',
    AppShortcutAction.next => 'next',
    AppShortcutAction.previous => 'previous',
    AppShortcutAction.volumeUp => 'volume_up',
    AppShortcutAction.volumeDown => 'volume_down',
    AppShortcutAction.mute => 'mute',
    AppShortcutAction.seekForward => 'seek_forward',
    AppShortcutAction.seekBackward => 'seek_backward',
    AppShortcutAction.toggleFullScreen => 'toggle_full_screen',
    AppShortcutAction.toggleWasapiExclusive => 'toggle_wasapi_exclusive',
  };

  String get label => switch (this) {
    AppShortcutAction.playPause => _l10n.playPause,
    AppShortcutAction.next => _l10n.nextTrack,
    AppShortcutAction.previous => _l10n.previousTrack,
    AppShortcutAction.volumeUp => _l10n.volumeUp,
    AppShortcutAction.volumeDown => _l10n.volumeDown,
    AppShortcutAction.mute => _l10n.toggleMute,
    AppShortcutAction.seekForward => _l10n.seekForward5s,
    AppShortcutAction.seekBackward => _l10n.seekBackward5s,
    AppShortcutAction.toggleFullScreen => _l10n.toggleFullScreen,
    AppShortcutAction.toggleWasapiExclusive => _l10n.toggleWasapiExclusive,
  };

  String get description => switch (this) {
    AppShortcutAction.playPause => _l10n.playPauseDescription,
    AppShortcutAction.next => _l10n.nextDescription,
    AppShortcutAction.previous => _l10n.previousDescription,
    AppShortcutAction.volumeUp => _l10n.volumeUpDescription,
    AppShortcutAction.volumeDown => _l10n.volumeDownDescription,
    AppShortcutAction.mute => _l10n.toggleMuteDescription,
    AppShortcutAction.seekForward => _l10n.seekForward5sDescription,
    AppShortcutAction.seekBackward => _l10n.seekBackward5sDescription,
    AppShortcutAction.toggleFullScreen => _l10n.toggleFullScreenDescription,
    AppShortcutAction.toggleWasapiExclusive => _l10n.toggleWasapiExclusiveDescription,
  };

  ShortcutBinding get defaultBinding {
    final isMac = Platform.isMacOS;
    return switch (this) {
      AppShortcutAction.playPause => ShortcutBinding(
          keyId: LogicalKeyboardKey.space.keyId,
        ),
      AppShortcutAction.next => ShortcutBinding(
          keyId: LogicalKeyboardKey.arrowRight.keyId,
          control: !isMac,
          meta: isMac,
        ),
      AppShortcutAction.previous => ShortcutBinding(
          keyId: LogicalKeyboardKey.arrowLeft.keyId,
          control: !isMac,
          meta: isMac,
        ),
      AppShortcutAction.volumeUp => ShortcutBinding(
          keyId: LogicalKeyboardKey.arrowUp.keyId,
          control: !isMac,
          meta: isMac,
        ),
      AppShortcutAction.volumeDown => ShortcutBinding(
          keyId: LogicalKeyboardKey.arrowDown.keyId,
          control: !isMac,
          meta: isMac,
        ),
      AppShortcutAction.mute => ShortcutBinding(
          keyId: LogicalKeyboardKey.audioVolumeMute.keyId,
        ),
      AppShortcutAction.seekForward => ShortcutBinding(
          keyId: LogicalKeyboardKey.arrowRight.keyId,
          alt: true,
        ),
      AppShortcutAction.seekBackward => ShortcutBinding(
          keyId: LogicalKeyboardKey.arrowLeft.keyId,
          alt: true,
        ),
      AppShortcutAction.toggleFullScreen => ShortcutBinding(
          keyId: isMac ? LogicalKeyboardKey.keyF.keyId : LogicalKeyboardKey.f11.keyId,
          control: isMac,
          meta: isMac,
        ),
      AppShortcutAction.toggleWasapiExclusive => ShortcutBinding(
          keyId: LogicalKeyboardKey.keyW.keyId,
          control: !isMac,
          shift: true,
          meta: isMac,
        ),
    };
  }

  static AppShortcutAction fromStorageKey(String key) {
    final normalized = key.trim().toLowerCase();
    for (final action in AppShortcutAction.values) {
      if (action.storageKey == normalized) {
        return action;
      }
    }
    return AppShortcutAction.playPause;
  }
}

class ShortcutBinding {
  final int keyId;
  final bool control;
  final bool shift;
  final bool alt;
  final bool meta;

  const ShortcutBinding({
    required this.keyId,
    this.control = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });

  LogicalKeyboardKey? get logicalKey =>
      LogicalKeyboardKey.findKeyByKeyId(keyId);

  ShortcutActivator? toActivator() {
    final key = logicalKey;
    if (key == null) {
      return null;
    }
    return SingleActivator(
      key,
      control: control,
      shift: shift,
      alt: alt,
      meta: meta,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'keyId': keyId,
    'control': control,
    'shift': shift,
    'alt': alt,
    'meta': meta,
  };

  static ShortcutBinding? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }

    final keyId = json['keyId'];
    if (keyId is! int) {
      return null;
    }

    return ShortcutBinding(
      keyId: keyId,
      control: json['control'] as bool? ?? false,
      shift: json['shift'] as bool? ?? false,
      alt: json['alt'] as bool? ?? false,
      meta: json['meta'] as bool? ?? false,
    );
  }

  static ShortcutBinding fromActivator(ShortcutActivator activator) {
    if (activator is! SingleActivator) {
      throw ArgumentError(
        'Only SingleActivator is supported for shortcut bindings.',
      );
    }

    return ShortcutBinding(
      keyId: activator.trigger.keyId,
      control: activator.control,
      shift: activator.shift,
      alt: activator.alt,
      meta: activator.meta,
    );
  }

  static ShortcutBinding? fromKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return null;
    }

    final logicalKey = event.logicalKey;
    if (_isModifierKey(logicalKey)) {
      return null;
    }

    return ShortcutBinding(
      keyId: logicalKey.keyId,
      control: HardwareKeyboard.instance.isControlPressed,
      shift: HardwareKeyboard.instance.isShiftPressed,
      alt: HardwareKeyboard.instance.isAltPressed,
      meta: HardwareKeyboard.instance.isMetaPressed,
    );
  }

  static bool _isModifierKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.alt ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.meta ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight;
  }

  String get displayLabel {
    final key = logicalKey;
    final isMac = Platform.isMacOS;
    final parts = <String>[
      if (control) 'Ctrl',
      if (shift) 'Shift',
      if (alt) (isMac ? 'Opt' : 'Alt'),
      if (meta) (isMac ? 'Cmd' : 'Meta'),
      _formatKeyLabel(key),
    ];
    return parts.join(' + ');
  }

  static String _formatKeyLabel(LogicalKeyboardKey? key) {
    if (key == null) {
      return currentAppL10n.unknownKey;
    }

    final label = key.keyLabel.trim();
    if (label.isNotEmpty) {
      return label.length == 1 ? label.toUpperCase() : label;
    }

    final debugName = key.debugName?.trim();
    if (debugName != null && debugName.isNotEmpty) {
      return debugName;
    }

    return '0x${key.keyId.toRadixString(16)}';
  }
}
