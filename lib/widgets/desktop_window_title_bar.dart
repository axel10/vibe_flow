import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'app_tooltip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../player/audio/audio_riverpod.dart';
import '../player/pro/pro_license_service.dart';
import '../player/settings/settings_service.dart';
import '../pages/settings_page.dart';
import '../l10n/app_localizations.dart';

class DesktopWindowTitleBar extends ConsumerStatefulWidget {
  const DesktopWindowTitleBar({
    super.key,
    required this.brightness,
    this.height = 32,
    this.showSmallWindowButton = false,
    this.showButtonGroupBackground = false,
    this.hideButtonsWhenInactive = false,
  });

  final Brightness brightness;
  final double height;
  final bool showSmallWindowButton;
  final bool showButtonGroupBackground;
  final bool hideButtonsWhenInactive;

  @override
  ConsumerState<DesktopWindowTitleBar> createState() =>
      _DesktopWindowTitleBarState();
}

class _DesktopWindowTitleBarState extends ConsumerState<DesktopWindowTitleBar>
    with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncWindowState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _syncWindowState() async {
    if (!mounted) return;

    final isFull = await windowManager.isFullScreen();
    final isMax = await windowManager.isMaximized();
    if (!mounted) return;

    setState(() {
      _isMaximized = isMax;
    });
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(isWindowFullScreenProvider.notifier).state = isFull;
        }
      });
    } else {
      ref.read(isWindowFullScreenProvider.notifier).state = isFull;
    }
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
  void onWindowMinimize() {
    _syncWindowState();
  }

  @override
  void onWindowRestore() {
    _syncWindowState();
  }

  @override
  void onWindowMaximize() {
    _syncWindowState();
  }

  @override
  void onWindowUnmaximize() {
    _syncWindowState();
  }

  Future<void> _setFullScreen(bool enable) async {
    if (enable) {
      await windowManager.setFullScreen(true);
    } else {
      await windowManager.setFullScreen(false);
    }
    ref.read(isWindowFullScreenProvider.notifier).state = enable;
    await _syncWindowState();
  }

  @override
  Widget build(BuildContext context) {
    final isFullScreen = ref.watch(isWindowFullScreenProvider);
    final isMacOS = Platform.isMacOS;
    final isWindowsOrLinux = Platform.isWindows || Platform.isLinux;
    final settings = ref.watch(settingsServiceProvider);
    final isSmallWindowMode = settings.isSmallWindowMode;
    final showMiniButton = widget.showSmallWindowButton || isSmallWindowMode;
    final hideButtons =
        (widget.hideButtonsWhenInactive || isSmallWindowMode) &&
        settings.isUserInactive;

    final Widget dragGestureArea = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      onDoubleTap: () async {
        if (isFullScreen) return;
        if (isSmallWindowMode) return;
        if (_isMaximized) {
          await windowManager.unmaximize();
        } else {
          await windowManager.maximize();
        }
      },
      child: const SizedBox.expand(),
    );

    final Widget titleBarContent = SizedBox(
      height: widget.height,
      child: Row(
        children: [
          if (isMacOS && showMiniButton)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: hideButtons ? 0.0 : 1.0,
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: hideButtons,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MacosSmallWindowButton(
                      icon: isSmallWindowMode
                          ? Icons.open_in_full
                          : Icons.picture_in_picture_alt,
                      iconSize: isSmallWindowMode ? 16 : 18,
                      onPressed: () {
                        settings.isSmallWindowMode = !settings.isSmallWindowMode;
                      },
                    ),
                    if (isSmallWindowMode)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppTooltip(
                            message: AppLocalizations.of(context)?.alwaysOnTop ??
                                'Always on Top',
                            child: _MacosSmallWindowButton(
                              icon: settings.isSmallWindowAlwaysOnTop
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              iconSize: 16,
                              color: settings.isSmallWindowAlwaysOnTop
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              onPressed: () async {
                                final nextVal = !settings.isSmallWindowAlwaysOnTop;
                                settings.isSmallWindowAlwaysOnTop = nextVal;
                                await windowManager.setAlwaysOnTop(nextVal);
                              },
                            ),
                          ),
                          _MacosSmallWindowButton(
                            icon: Icons.queue_music,
                            iconSize: 16,
                            color: settings.isSmallWindowQueueExpanded
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            onPressed: () {
                              settings.toggleSmallWindowBottomPanelMode(
                                SmallWindowBottomPanelMode.queue,
                              );
                            },
                          ),
                          _MacosSmallWindowButton(
                            icon: Icons.text_snippet_outlined,
                            iconSize: 16,
                            color: settings.isSmallWindowLyricsExpanded
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            onPressed: () {
                              settings.toggleSmallWindowBottomPanelMode(
                                SmallWindowBottomPanelMode.lyrics,
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: dragGestureArea,
          ),
          if (ref.watch(isEffectiveWasapiExclusiveProvider))
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: hideButtons ? 0.0 : 1.0,
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: hideButtons,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _WasapiExclusiveBadge(
                    brightness: widget.brightness,
                    height: widget.height,
                  ),
                ),
              ),
            ),
          if (isWindowsOrLinux)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: hideButtons ? 0.0 : 1.0,
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: hideButtons,
                child: _WindowsCapsuleButtons(
                  buttons: [
                    if (showMiniButton) ...[
                      _CapsuleButtonData(
                        icon: isSmallWindowMode
                            ? Icons.open_in_full
                            : Icons.picture_in_picture_alt,
                        iconSize: isSmallWindowMode ? 14 : 16,
                        onPressed: () {
                          settings.isSmallWindowMode =
                              !settings.isSmallWindowMode;
                        },
                      ),
                      if (isSmallWindowMode)
                        _CapsuleButtonData(
                          icon: settings.isSmallWindowAlwaysOnTop
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                          iconSize: 14,
                          tooltip:
                              AppLocalizations.of(
                                context,
                              )?.alwaysOnTop ??
                              'Always on Top',
                          color: settings.isSmallWindowAlwaysOnTop
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          onPressed: () async {
                            final nextVal =
                                !settings.isSmallWindowAlwaysOnTop;
                            settings.isSmallWindowAlwaysOnTop = nextVal;
                            await windowManager.setAlwaysOnTop(nextVal);
                          },
                        ),
                      if (isSmallWindowMode)
                        _CapsuleButtonData(
                          icon: Icons.queue_music,
                          iconSize: 14,
                          color: settings.isSmallWindowQueueExpanded
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          onPressed: () {
                            settings.toggleSmallWindowBottomPanelMode(
                              SmallWindowBottomPanelMode.queue,
                            );
                          },
                        ),
                      if (isSmallWindowMode)
                        _CapsuleButtonData(
                          icon: Icons.text_snippet_outlined,
                          iconSize: 14,
                          color: settings.isSmallWindowLyricsExpanded
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          onPressed: () {
                            settings.toggleSmallWindowBottomPanelMode(
                              SmallWindowBottomPanelMode.lyrics,
                            );
                          },
                        ),
                    ],
                    if (!isSmallWindowMode) ...[
                      _CapsuleButtonData(
                        icon: isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        iconSize: 16,
                        onPressed: () async {
                          await _setFullScreen(!isFullScreen);
                        },
                      ),
                      _CapsuleButtonData(
                        icon: Icons.remove,
                        iconSize: 16,
                        onPressed: () async {
                          if (isFullScreen) {
                            await _setFullScreen(false);
                          }
                          await windowManager.minimize();
                        },
                      ),
                      _CapsuleButtonData(
                        icon: _isMaximized
                            ? Icons.filter_none
                            : Icons.crop_square,
                        iconSize: 12,
                        onPressed: () async {
                          if (isFullScreen) {
                            await _setFullScreen(false);
                          } else if (_isMaximized) {
                            await windowManager.unmaximize();
                          } else {
                            await windowManager.maximize();
                          }
                        },
                      ),
                    ],
                    _CapsuleButtonData(
                      icon: Icons.close,
                      iconSize: 16,
                      isClose: true,
                      onPressed: windowManager.close,
                    ),
                  ],
                  brightness: widget.brightness,
                  height: widget.height,
                  showBackground: widget.showButtonGroupBackground && isSmallWindowMode,
                ),
              ),
            ),
        ],
      ),
    );

    if (isMacOS) {
      return Padding(
        padding: const EdgeInsets.only(left: 80.0),
        child: titleBarContent,
      );
    }

    return titleBarContent;
  }
}

class _MacosSmallWindowButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;
  final Color? color;

  const _MacosSmallWindowButton({
    required this.icon,
    required this.iconSize,
    required this.onPressed,
    this.color,
  });

  @override
  State<_MacosSmallWindowButton> createState() =>
      _MacosSmallWindowButtonState();
}

class _MacosSmallWindowButtonState extends State<_MacosSmallWindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          width: 42,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 0.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.black.withValues(alpha: 0.05),
                    highlightColor: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: widget.color ?? Colors.black,
                        size: widget.iconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CapsuleButtonData {
  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;
  final Color? color;
  final bool isClose;
  final String? tooltip;

  _CapsuleButtonData({
    required this.icon,
    required this.onPressed,
    this.iconSize = 16,
    this.color,
    this.isClose = false,
    this.tooltip,
  });
}

class _WindowsCapsuleButtons extends StatelessWidget {
  final List<_CapsuleButtonData> buttons;
  final Brightness brightness;
  final double height;
  final bool showBackground;

  const _WindowsCapsuleButtons({
    required this.buttons,
    required this.brightness,
    required this.height,
    required this.showBackground,
  });

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty) return const SizedBox.shrink();

    final isDark = brightness == Brightness.dark;

    final Color capsuleBg = Colors.black.withValues(alpha: 0.12);

    final Color capsuleBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.16);

    if (!showBackground) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(buttons.length, (index) {
              return _WindowsCapsuleButton(
                data: buttons[index],
                brightness: brightness,
                height: height,
              );
            }),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(6),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: height,
              padding: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(
                color: capsuleBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                ),
                border: Border.all(color: capsuleBorderColor, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(buttons.length, (index) {
                  return _WindowsCapsuleButton(
                    data: buttons[index],
                    brightness: brightness,
                    height: height,
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WindowsCapsuleButton extends StatefulWidget {
  final _CapsuleButtonData data;
  final Brightness brightness;
  final double height;

  const _WindowsCapsuleButton({
    required this.data,
    required this.brightness,
    required this.height,
  });

  @override
  State<_WindowsCapsuleButton> createState() => _WindowsCapsuleButtonState();
}

class _WindowsCapsuleButtonState extends State<_WindowsCapsuleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.brightness == Brightness.dark;
    final isLinux = Platform.isLinux;
    final buttonRadius = isLinux ? null : BorderRadius.all(const Radius.circular(6));

    Color iconColor =
        widget.data.color ?? (isDark ? Colors.white70 : Colors.black87);

    if (_isHovered) {
      if (widget.data.isClose) {
        iconColor = Colors.white;
      } else if (widget.data.color == null) {
        iconColor = isDark ? Colors.white : Colors.black;
      }
    }

    Color hoverBg;
    if (widget.data.isClose) {
      hoverBg = Colors.redAccent.withValues(alpha: 0.85);
    } else {
      hoverBg = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.10);
    }

    Widget buttonWidget = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.data.onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36,
          height: widget.height,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: isLinux ? 24 : 32,
            height: isLinux ? 24 : widget.height - 10,
            decoration: BoxDecoration(
              color: _isHovered ? hoverBg : Colors.transparent,
              shape: isLinux ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isLinux ? null : buttonRadius,
            ),
            child: Icon(
              widget.data.icon,
              size: widget.data.iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );

    if (widget.data.tooltip != null) {
      buttonWidget = AppTooltip(
        message: widget.data.tooltip!,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}

class _WasapiExclusiveBadge extends StatefulWidget {
  final Brightness brightness;
  final double height;

  const _WasapiExclusiveBadge({
    required this.brightness,
    required this.height,
  });

  @override
  State<_WasapiExclusiveBadge> createState() => _WasapiExclusiveBadgeState();
}

class _WasapiExclusiveBadgeState extends State<_WasapiExclusiveBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final badgeText = l10n?.exclusiveModeTitle ?? '独占模式';
    final tooltipText = l10n?.exclusiveModeTooltip ??
        'WASAPI 独占模式已启用（已独占音频输出设备）';

    // Hi-Fi Amber/Gold specialized palette for maximum recognition
    final Color badgeBg;
    final Color badgeBorder;
    final Color badgeFg;
    final Color shadowColor;

    if (isDark) {
      badgeBg = _isHovered
          ? const Color(0xFF3D2D10)
          : const Color(0xFF261C0A);
      badgeBorder = _isHovered
          ? const Color(0xFFFBBF24)
          : const Color(0xFFD97706).withValues(alpha: 0.75);
      badgeFg = _isHovered ? const Color(0xFFFDE68A) : const Color(0xFFFCD34D);
      shadowColor = const Color(0xFFF59E0B).withValues(alpha: _isHovered ? 0.25 : 0.12);
    } else {
      badgeBg = _isHovered
          ? const Color(0xFFFDE68A)
          : const Color(0xFFFEF3C7);
      badgeBorder = _isHovered
          ? const Color(0xFFD97706)
          : const Color(0xFFF59E0B).withValues(alpha: 0.85);
      badgeFg = _isHovered ? const Color(0xFF78350F) : const Color(0xFF92400E);
      shadowColor = const Color(0xFFD97706).withValues(alpha: _isHovered ? 0.18 : 0.08);
    }

    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AppTooltip(
          message: tooltipText,
          child: GestureDetector(
            onTap: () {
              final settingsState =
                  context.findAncestorStateOfType<SettingsPageState>();
              if (settingsState != null) {
                settingsState.openSection(SettingsSection.audio);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsPage(
                      initialSection: SettingsSection.audio,
                    ),
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: badgeBorder,
                  width: 0.9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.graphic_eq_rounded,
                    size: 13,
                    color: badgeFg,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeFg,
                      height: 1.1,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
