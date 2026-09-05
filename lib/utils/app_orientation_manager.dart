import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/main_layout_riverpod.dart';

enum AppOrientationMode {
  unrestricted,
  portraitOnly,
  landscapeOnly,
}

/// 移动端屏幕方向自适应管理器
/// - 手机端（Android 手机 / iPhone，shortestSide < 600）：默认全局锁定竖屏；进入 3D 唱片封面墙（Cover Flow）时自动切为横屏，退出恢复竖屏。
/// - 平板与桌面模式（iPad、Android 平板、折叠屏展开态、Android 桌面模式，shortestSide >= 600）：允许所有方向自由旋转。
/// - 桌面平台（Windows / macOS / Linux）：不设限制。
class AppOrientationManager {
  static const double tabletShortestSideBreakpoint = 600.0;

  @visibleForTesting
  static AppOrientationMode? currentMode;

  @visibleForTesting
  static bool? isMobileOverride;

  static bool get isMobile =>
      isMobileOverride ?? (Platform.isAndroid || Platform.isIOS);

  /// 应用启动时尽早初始化默认屏幕方向
  static void init() {
    if (!isMobile) {
      return;
    }

    try {
      final view = PlatformDispatcher.instance.views.firstOrNull;
      if (view != null) {
        final pixelRatio = view.devicePixelRatio > 0 ? view.devicePixelRatio : 1.0;
        final logicalSize = view.physicalSize / pixelRatio;
        if (logicalSize.shortestSide < tabletShortestSideBreakpoint) {
          currentMode = AppOrientationMode.portraitOnly;
          SystemChrome.setPreferredOrientations(const [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          return;
        }
      }
      currentMode = AppOrientationMode.unrestricted;
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    } catch (_) {
      // 避免早期初始化异常影响应用启动
    }
  }

  /// 依据当前屏幕尺寸及 Cover Flow 状态同步设置屏幕方向
  static void syncWithMetrics({
    required double shortestSide,
    required bool isCoverFlowActive,
  }) {
    if (!isMobile) {
      return;
    }

    final bool isTabletOrDesktop = shortestSide >= tabletShortestSideBreakpoint;

    final AppOrientationMode targetMode;
    if (isTabletOrDesktop) {
      targetMode = AppOrientationMode.unrestricted;
    } else if (isCoverFlowActive) {
      targetMode = AppOrientationMode.landscapeOnly;
    } else {
      targetMode = AppOrientationMode.portraitOnly;
    }

    if (currentMode == targetMode) {
      return;
    }

    currentMode = targetMode;

    switch (targetMode) {
      case AppOrientationMode.unrestricted:
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        break;
      case AppOrientationMode.landscapeOnly:
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        break;
      case AppOrientationMode.portraitOnly:
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        break;
    }
  }
}

/// 监听屏幕方向及 Riverpod 状态的 Widget
class AppOrientationWatcher extends ConsumerStatefulWidget {
  final Widget child;

  const AppOrientationWatcher({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppOrientationWatcher> createState() => _AppOrientationWatcherState();
}

class _AppOrientationWatcherState extends ConsumerState<AppOrientationWatcher> {
  @override
  Widget build(BuildContext context) {
    final isCoverFlowActive = ref.watch(isCoverFlowImmersiveActiveProvider);
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppOrientationManager.syncWithMetrics(
        shortestSide: shortestSide,
        isCoverFlowActive: isCoverFlowActive,
      );
    });

    return widget.child;
  }
}
