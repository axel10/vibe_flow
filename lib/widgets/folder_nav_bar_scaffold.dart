import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vynody/utils/folder_helpers.dart';

/// Contextual style properties computed by [FolderNavBarScaffold] during scroll animation.
class FolderNavBarStyle {
  final Color navBackgroundColor;
  final Color iconColor;
  final Color chevronColor;
  final Color folderTextColor;
  final List<Shadow>? shadows;
  final double progress;
  final bool isDark;
  final bool isPortrait;

  const FolderNavBarStyle({
    required this.navBackgroundColor,
    required this.iconColor,
    required this.chevronColor,
    required this.folderTextColor,
    required this.shadows,
    required this.progress,
    required this.isDark,
    required this.isPortrait,
  });
}

/// A reusable navigation bar shell that handles scroll transitions, background interpolation,
/// status bar / desktop title padding, and a horizontally scrollable breadcrumb container.
class FolderNavBarScaffold extends StatefulWidget {
  const FolderNavBarScaffold({
    super.key,
    required this.isOverlay,
    required this.scrollProgress,
    this.onGoBack,
    this.scrollController,
    required this.breadcrumbItemsBuilder,
    required this.actionsBuilder,
  });

  final bool isOverlay;
  final ValueListenable<double> scrollProgress;
  final VoidCallback? onGoBack;
  final ScrollController? scrollController;
  final List<Widget> Function(BuildContext context, FolderNavBarStyle style)
      breadcrumbItemsBuilder;
  final Widget Function(BuildContext context, FolderNavBarStyle style)
      actionsBuilder;

  @override
  State<FolderNavBarScaffold> createState() => _FolderNavBarScaffoldState();
}

class _FolderNavBarScaffoldState extends State<FolderNavBarScaffold>
    with SingleTickerProviderStateMixin {
  ScrollController? _internalScrollController;
  late final AnimationController _animController;
  late final Animation<double> _animation;

  ScrollController get _activeScrollController =>
      widget.scrollController ??
      (_internalScrollController ??= ScrollController());

  @override
  void initState() {
    super.initState();
    final isScrolled = widget.scrollProgress.value > 0.03;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: isScrolled ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
    widget.scrollProgress.addListener(_onScrollProgressChanged);
  }

  void _onScrollProgressChanged() {
    final isScrolled = widget.scrollProgress.value > 0.03;
    if (isScrolled) {
      if (_animController.status != AnimationStatus.forward &&
          _animController.value < 1.0) {
        _animController.forward();
      }
    } else {
      if (_animController.status != AnimationStatus.reverse &&
          _animController.value > 0.0) {
        _animController.reverse();
      }
    }
  }

  @override
  void didUpdateWidget(FolderNavBarScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollProgress != widget.scrollProgress) {
      oldWidget.scrollProgress.removeListener(_onScrollProgressChanged);
      widget.scrollProgress.addListener(_onScrollProgressChanged);
      final isScrolled = widget.scrollProgress.value > 0.03;
      if (isScrolled) {
        if (_animController.status != AnimationStatus.forward &&
            _animController.value < 1.0) {
          _animController.forward();
        }
      } else {
        if (_animController.status != AnimationStatus.reverse &&
            _animController.value > 0.0) {
          _animController.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    widget.scrollProgress.removeListener(_onScrollProgressChanged);
    _animController.dispose();
    _internalScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;
        final progress = _animation.value;

        final targetSurface = theme.colorScheme.surface;
        final navBackgroundColor = widget.isOverlay
            ? Color.lerp(
                targetSurface.withValues(alpha: 0.0),
                targetSurface,
                progress,
              )!
            : theme.scaffoldBackgroundColor;

        final overlayIconColor = isDark
            ? Colors.white
            : theme.colorScheme.onSurface.withValues(alpha: 0.85);
        final solidIconColor =
            theme.colorScheme.onSurface.withValues(alpha: 0.85);
        final iconColor = widget.isOverlay
            ? (Color.lerp(overlayIconColor, solidIconColor, progress) ??
                solidIconColor)
            : solidIconColor;

        final overlayChevronColor = isDark
            ? Colors.white.withValues(alpha: 0.6)
            : theme.colorScheme.onSurface.withValues(alpha: 0.4);
        final solidChevronColor =
            theme.colorScheme.onSurface.withValues(alpha: 0.4);
        final chevronColor = widget.isOverlay
            ? (Color.lerp(overlayChevronColor, solidChevronColor, progress) ??
                solidChevronColor)
            : solidChevronColor;

        final overlayFolderTextColor = isDark
            ? Colors.white.withValues(alpha: 0.9)
            : theme.colorScheme.onSurface.withValues(alpha: 0.85);
        final solidFolderTextColor =
            theme.colorScheme.onSurface.withValues(alpha: 0.85);
        final folderTextColor = widget.isOverlay
            ? (Color.lerp(
                    overlayFolderTextColor,
                    solidFolderTextColor,
                    progress,
                  ) ??
                solidFolderTextColor)
            : solidFolderTextColor;

        final shadowAlpha = 1.0 - progress;
        final shadows = (widget.isOverlay && isDark && shadowAlpha > 0.05)
            ? [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.87 * shadowAlpha),
                ),
              ]
            : null;

        final style = FolderNavBarStyle(
          navBackgroundColor: navBackgroundColor,
          iconColor: iconColor,
          chevronColor: chevronColor,
          folderTextColor: folderTextColor,
          shadows: shadows,
          progress: progress,
          isDark: isDark,
          isPortrait: isPortrait,
        );

        final backButton = Material(
          color: Colors.transparent,
          child: InkResponse(
            radius: 18,
            highlightShape: BoxShape.circle,
            onTap: widget.onGoBack,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: iconColor,
                shadows: shadows,
              ),
            ),
          ),
        );

        final backChevron = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: chevronColor,
            shadows: shadows,
          ),
        );

        final breadcrumbItems = widget.breadcrumbItemsBuilder(context, style);
        final actions = widget.actionsBuilder(context, style);

        final statusBarHeight = MediaQuery.of(context).padding.top;
        final isDesktop =
            Platform.isMacOS || Platform.isWindows || Platform.isLinux;
        final topPadding = statusBarHeight > 0
            ? statusBarHeight + 8
            : (isDesktop ? 44.0 : 8.0);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: navBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: widget.isOverlay
                    ? theme.dividerColor.withValues(alpha: 0.12 * progress)
                    : theme.dividerColor.withValues(alpha: 0.05),
              ),
            ),
            boxShadow: widget.isOverlay && progress > 0.05
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.black : theme.colorScheme.shadow)
                          .withValues(alpha: 0.1 * progress),
                      blurRadius: 8 * progress,
                      offset: Offset(0, 2 * progress),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: folderPageMaxWidth),
              child: Padding(
                padding: EdgeInsets.only(
                  top: topPadding,
                  bottom: 8,
                  left: isPortrait ? 8 : 16,
                  right: isPortrait ? 16 : 24,
                ),
                child: Row(
                  children: [
                    if (widget.onGoBack != null) ...[
                      backButton,
                      backChevron,
                    ],
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            controller: _activeScrollController,
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(children: breadcrumbItems),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    actions,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
