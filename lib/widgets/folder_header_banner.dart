import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';

class FolderHeaderBanner extends ConsumerStatefulWidget {
  const FolderHeaderBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.songsCount,
    required this.totalDuration,
    required this.coverWidget,
    this.coverImagePath,
    this.topHeader,
    required this.actionButtons,
    this.actionButtonsScrollable = false,
    required this.isSearching,
    required this.searchController,
    required this.searchQuery,
    required this.searchHintText,
    required this.onSearchQueryChanged,
    required this.onToggleSearch,
    this.heroTag,
    this.isHeroModeEnabled = true,
    this.isLowEndDevice,
  });

  final String title;
  final String subtitle;
  final int songsCount;
  final Duration totalDuration;
  final Widget coverWidget;
  final String? coverImagePath;
  final Widget? topHeader;
  final List<Widget> actionButtons;
  final bool actionButtonsScrollable;
  final bool isSearching;
  final TextEditingController searchController;
  final String searchQuery;
  final String searchHintText;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<bool> onToggleSearch;
  final String? heroTag;
  final bool isHeroModeEnabled;
  final bool? isLowEndDevice;

  @override
  ConsumerState<FolderHeaderBanner> createState() => _FolderHeaderBannerState();
}

class _FolderHeaderBannerState extends ConsumerState<FolderHeaderBanner> {
  double? _aspectRatio;
  String? _resolvedPath;

  @override
  void initState() {
    super.initState();
    _checkImageAspectRatio();
  }

  @override
  void didUpdateWidget(FolderHeaderBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coverImagePath != widget.coverImagePath) {
      _checkImageAspectRatio();
    }
  }

  void _checkImageAspectRatio() {
    final path = widget.coverImagePath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      _resolvedPath = path;
      final fileImage = FileImage(File(path));
      final stream = fileImage.resolve(ImageConfiguration.empty);
      stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
        if (mounted) {
          final w = info.image.width;
          final h = info.image.height;
          if (w > 0 && h > 0) {
            setState(() {
              _aspectRatio = w / h;
            });
          }
        }
      }));
    } else {
      setState(() {
        _resolvedPath = null;
        _aspectRatio = null;
      });
    }
  }

  String _formatDurationText(AppLocalizations l10n) {
    final hours = widget.totalDuration.inHours;
    final minutes = widget.totalDuration.inMinutes.remainder(60);
    final seconds = widget.totalDuration.inSeconds.remainder(60);

    if (l10n.localeName == 'zh') {
      if (hours > 0) {
        return '$hours小时$minutes分钟';
      } else if (minutes > 0) {
        return '$minutes分钟$seconds秒';
      } else {
        return '$seconds秒';
      }
    } else {
      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else if (minutes > 0) {
        return '${minutes}m ${seconds}s';
      } else {
        return '${seconds}s';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final durationText = _formatDurationText(l10n);

    final hasImage = _resolvedPath != null && File(_resolvedPath!).existsSync();
    final coverFile = hasImage ? File(_resolvedPath!) : null;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isWideOrSquare = _aspectRatio == null || _aspectRatio! >= 0.85;
    final bool isLowEndDevice = widget.isLowEndDevice ?? ref.watch(isLowMidEndDeviceProvider);



    if (isLandscape) {
      return RepaintBoundary(
        child: _FolderLandscapeHeaderBanner(
          title: widget.title,
          subtitle: widget.subtitle,
          songsCount: widget.songsCount,
          durationText: durationText,
          coverWidget: widget.coverWidget,
          actionButtons: widget.actionButtons,
          actionButtonsScrollable: widget.actionButtonsScrollable,
          isSearching: widget.isSearching,
          searchController: widget.searchController,
          searchQuery: widget.searchQuery,
          searchHintText: widget.searchHintText,
          onSearchQueryChanged: widget.onSearchQueryChanged,
          onToggleSearch: widget.onToggleSearch,
          heroTag: widget.heroTag,
          isHeroModeEnabled: widget.isHeroModeEnabled,
        ),
      );
    }

    return RepaintBoundary(
      child: _FolderPortraitHeaderBanner(
        title: widget.title,
        subtitle: widget.subtitle,
        songsCount: widget.songsCount,
        durationText: durationText,
        coverWidget: widget.coverWidget,
        coverFile: coverFile,
        hasImage: hasImage,
        isWideOrSquare: isWideOrSquare,
        topHeader: widget.topHeader,
        actionButtons: widget.actionButtons,
        actionButtonsScrollable: widget.actionButtonsScrollable,
        isSearching: widget.isSearching,
        searchController: widget.searchController,
        searchQuery: widget.searchQuery,
        searchHintText: widget.searchHintText,
        onSearchQueryChanged: widget.onSearchQueryChanged,
        onToggleSearch: widget.onToggleSearch,
        heroTag: widget.heroTag,
        isHeroModeEnabled: widget.isHeroModeEnabled,
        resolvedPath: _resolvedPath,
        totalDuration: widget.totalDuration,
        isLowEndDevice: isLowEndDevice,
      ),
    );
  }
}

/// Decoupled Landscape Header Banner Component
class _FolderLandscapeHeaderBanner extends StatelessWidget {
  const _FolderLandscapeHeaderBanner({
    required this.title,
    required this.subtitle,
    required this.songsCount,
    required this.durationText,
    required this.coverWidget,
    required this.actionButtons,
    required this.actionButtonsScrollable,
    required this.isSearching,
    required this.searchController,
    required this.searchQuery,
    required this.searchHintText,
    required this.onSearchQueryChanged,
    required this.onToggleSearch,
    required this.heroTag,
    required this.isHeroModeEnabled,
  });

  final String title;
  final String subtitle;
  final int songsCount;
  final String durationText;
  final Widget coverWidget;
  final List<Widget> actionButtons;
  final bool actionButtonsScrollable;
  final bool isSearching;
  final TextEditingController searchController;
  final String searchQuery;
  final String searchHintText;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<bool> onToggleSearch;
  final String? heroTag;
  final bool isHeroModeEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Widget resolvedCover;
    if (heroTag != null) {
      resolvedCover = HeroMode(
        enabled: isHeroModeEnabled,
        child: Hero(
          tag: heroTag!,
          // Explicit linear rect tween for smooth 1:1 horizontal flight in landscape mode
          createRectTween: (begin, end) => SmoothRectTween(
            begin: begin,
            end: end,
            curve: Curves.linear,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: coverWidget,
          ),
        ),
      );
    } else {
      resolvedCover = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: coverWidget,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 540 && MediaQuery.of(context).size.width >= 900;

        if (isWideScreen) {
          return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                resolvedCover,
                const SizedBox(width: 16),
                Expanded(
                  child: _BannerInfoColumn(
                    title: title,
                    subtitle: subtitle,
                    songsCount: songsCount,
                    durationText: durationText,
                    isOverlay: false,
                  ),
                ),
                const SizedBox(width: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSearching
                      ? Row(
                          key: const ValueKey('wide-search-active'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 260,
                              child: _BannerSearchTextField(
                                controller: searchController,
                                hintText: searchHintText,
                                query: searchQuery,
                                onChanged: onSearchQueryChanged,
                                compact: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () {
                                searchController.clear();
                                onSearchQueryChanged('');
                                onToggleSearch(false);
                              },
                              style: IconButton.styleFrom(
                                minimumSize: const Size(32, 32),
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('wide-actions-normal'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (actionButtonsScrollable)
                              Flexible(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: actionButtons,
                                  ),
                                ),
                              )
                            else
                              ...actionButtons,
                            const SizedBox(width: 8),
                            _BannerSearchIconButton(
                              onPressed: () => onToggleSearch(true),
                              tooltip: l10n.search,
                              isWhite: false,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  resolvedCover,
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BannerInfoColumn(
                      title: title,
                      subtitle: subtitle,
                      songsCount: songsCount,
                      durationText: durationText,
                      isOverlay: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSearching
                    ? Row(
                        key: const ValueKey('search-active-row'),
                        children: [
                          Expanded(
                            child: _BannerSearchTextField(
                              controller: searchController,
                              hintText: searchHintText,
                              query: searchQuery,
                              onChanged: onSearchQueryChanged,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              searchController.clear();
                              onSearchQueryChanged('');
                              onToggleSearch(false);
                            },
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('actions-normal-row'),
                        children: [
                          if (actionButtonsScrollable)
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: actionButtons,
                                ),
                              ),
                            )
                          else ...[
                            ...actionButtons,
                            const Spacer(),
                          ],
                          const SizedBox(width: 8),
                          _BannerSearchIconButton(
                            onPressed: () => onToggleSearch(true),
                            tooltip: l10n.search,
                            isWhite: false,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Decoupled Portrait Header Banner Component
class _FolderPortraitHeaderBanner extends StatelessWidget {
  const _FolderPortraitHeaderBanner({
    required this.title,
    required this.subtitle,
    required this.songsCount,
    required this.durationText,
    required this.coverWidget,
    required this.coverFile,
    required this.hasImage,
    required this.isWideOrSquare,
    required this.topHeader,
    required this.actionButtons,
    required this.actionButtonsScrollable,
    required this.isSearching,
    required this.searchController,
    required this.searchQuery,
    required this.searchHintText,
    required this.onSearchQueryChanged,
    required this.onToggleSearch,
    required this.heroTag,
    required this.isHeroModeEnabled,
    required this.resolvedPath,
    required this.totalDuration,
    required this.isLowEndDevice,
  });

  final String title;
  final String subtitle;
  final int songsCount;
  final String durationText;
  final Widget coverWidget;
  final File? coverFile;
  final bool hasImage;
  final bool isWideOrSquare;
  final Widget? topHeader;
  final List<Widget> actionButtons;
  final bool actionButtonsScrollable;
  final bool isSearching;
  final TextEditingController searchController;
  final String searchQuery;
  final String searchHintText;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<bool> onToggleSearch;
  final String? heroTag;
  final bool isHeroModeEnabled;
  final String? resolvedPath;
  final Duration totalDuration;
  final bool isLowEndDevice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 900;
    final statusBarTop = MediaQuery.of(context).padding.top;
    final isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    final desktopTitleBarHeight = isDesktop ? 28.0 : 0.0;
    final hasTopHeader = topHeader != null;

    final routeAnimation = ModalRoute.of(context)?.animation;
    final darkOverlayAnimation = routeAnimation != null
        ? CurvedAnimation(parent: routeAnimation, curve: Curves.easeOut)
        : null;
    final foregroundAnimation = routeAnimation != null
        ? CurvedAnimation(
            parent: routeAnimation,
            curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: Stack(
          children: [
            // 1. Background cover / backdrop layer
            Positioned.fill(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage) ...[
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: Image.file(
                        coverFile!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      color: Colors.black.withValues(alpha: isWideOrSquare ? 0.25 : 0.45),
                    ),
                  ] else ...[
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            HSLColor.fromAHSL(1.0, (title.hashCode.abs() % 360).toDouble(), 0.60, 0.30).toColor(),
                            HSLColor.fromAHSL(1.0, ((title.hashCode.abs() % 360 + 40) % 360).toDouble(), 0.70, 0.20).toColor(),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // Wide or Square cover extending across full width, or fallback hero gradient
                  if (isWideOrSquare) ...[
                    Positioned.fill(
                      child: heroTag != null
                          ? HeroMode(
                              enabled: isHeroModeEnabled,
                              child: Hero(
                                tag: heroTag!,
                                // Explicit fastOutSlowIn curve for portrait hero backdrop expansion
                                createRectTween: (begin, end) => SmoothRectTween(
                                  begin: begin,
                                  end: end,
                                  curve: Curves.fastOutSlowIn,
                                ),
                                flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                                  return _buildHeroFlightShuttle(
                                    flightContext: flightContext,
                                    animation: animation,
                                    theme: theme,
                                    l10n: l10n,
                                    screenWidth: screenWidth,
                                    durationText: durationText,
                                    hasImage: hasImage,
                                    coverFile: coverFile,
                                    statusBarTop: statusBarTop,
                                    desktopTitleBarHeight: desktopTitleBarHeight,
                                    hasTopHeader: hasTopHeader,
                                    isLowEndDevice: isLowEndDevice,
                                  );
                                },
                                child: hasImage
                                    ? Image.file(
                                        coverFile!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              HSLColor.fromAHSL(1.0, (title.hashCode.abs() % 360).toDouble(), 0.60, 0.30).toColor(),
                                              HSLColor.fromAHSL(1.0, ((title.hashCode.abs() % 360 + 40) % 360).toDouble(), 0.70, 0.20).toColor(),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            )
                          : (hasImage
                              ? Image.file(
                                  coverFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        HSLColor.fromAHSL(1.0, (title.hashCode.abs() % 360).toDouble(), 0.60, 0.30).toColor(),
                                        HSLColor.fromAHSL(1.0, ((title.hashCode.abs() % 360 + 40) % 360).toDouble(), 0.70, 0.20).toColor(),
                                      ],
                                    ),
                                  ),
                                )),
                    ),
                  ],
                  // Dark gradient overlay for text readability
                  AnimatedBuilder(
                    animation: routeAnimation ?? const AlwaysStoppedAnimation(1.0),
                    builder: (context, child) {
                      final opacity = (darkOverlayAnimation?.value ?? 1.0).clamp(0.0, 1.0);
                      return Opacity(
                        opacity: opacity,
                        child: child,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.55),
                            Colors.black.withValues(alpha: 0.85),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Foreground content layer
            AnimatedBuilder(
              animation: routeAnimation ?? const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                if (routeAnimation == null) {
                  return child!;
                }
                final progress = (foregroundAnimation?.value ?? 1.0).clamp(0.0, 1.0);
                final opacity = progress;
                final offsetY = 14.0 * (1.0 - progress);
                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, offsetY),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(
                  top: hasTopHeader
                      ? 0
                      : (statusBarTop > 0
                          ? statusBarTop + desktopTitleBarHeight + 8
                          : desktopTitleBarHeight + 16),
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasTopHeader) topHeader!,
                    if (hasTopHeader) const SizedBox(height: 8),

                    if (isWideScreen) ...[
                      // Wide screen / desktop horizontal layout over cover backdrop
                      Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxHeight: 110, maxWidth: 110),
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: (heroTag != null && !isWideOrSquare)
                                  ? HeroMode(
                                      enabled: isHeroModeEnabled,
                                      child: Hero(
                                        tag: heroTag!,
                                        createRectTween: (begin, end) => SmoothRectTween(
                                          begin: begin,
                                          end: end,
                                          curve: Curves.fastOutSlowIn,
                                        ),
                                        child: hasImage
                                            ? Image.file(coverFile!, fit: BoxFit.cover)
                                            : coverWidget,
                                      ),
                                    )
                                  : (hasImage
                                      ? Image.file(coverFile!, fit: BoxFit.cover)
                                      : coverWidget),
                            ),
                          ),
                          Expanded(
                            child: _BannerInfoColumn(
                              title: title,
                              subtitle: subtitle,
                              songsCount: songsCount,
                              durationText: durationText,
                              isOverlay: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isSearching
                                ? Row(
                                    key: const ValueKey('wide-search-active'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 260,
                                        child: _BannerSearchTextField(
                                          controller: searchController,
                                          hintText: searchHintText,
                                          query: searchQuery,
                                          onChanged: onSearchQueryChanged,
                                          compact: true,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
                                        onPressed: () {
                                          searchController.clear();
                                          onSearchQueryChanged('');
                                          onToggleSearch(false);
                                        },
                                      ),
                                    ],
                                  )
                                : Row(
                                    key: const ValueKey('wide-actions-normal'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (actionButtonsScrollable)
                                        Flexible(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: actionButtons,
                                            ),
                                          ),
                                        )
                                      else
                                        ...actionButtons,
                                      const SizedBox(width: 8),
                                      _BannerSearchIconButton(
                                        onPressed: () => onToggleSearch(true),
                                        tooltip: l10n.search,
                                        isWhite: true,
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Standard portrait column layout
                      if (!isWideOrSquare) ...[
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 180),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: heroTag != null
                                  ? HeroMode(
                                      enabled: isHeroModeEnabled,
                                      child: Hero(
                                        tag: heroTag!,
                                        createRectTween: (begin, end) => SmoothRectTween(
                                          begin: begin,
                                          end: end,
                                          curve: Curves.fastOutSlowIn,
                                        ),
                                        child: hasImage
                                            ? Image.file(
                                                coverFile!,
                                                fit: BoxFit.contain,
                                              )
                                            : coverWidget,
                                      ),
                                    )
                                  : (hasImage
                                      ? Image.file(
                                          coverFile!,
                                          fit: BoxFit.contain,
                                        )
                                      : coverWidget),
                            ),
                          ),
                        ),
                      ],

                      // Title & Subtitle & Metadata
                      _BannerInfoColumn(
                        title: title,
                        subtitle: subtitle,
                        songsCount: songsCount,
                        durationText: durationText,
                        isOverlay: true,
                      ),

                      const SizedBox(height: 14),

                      // Actions / Search Row
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isSearching
                            ? Row(
                                key: const ValueKey('search-active-row'),
                                children: [
                                  Expanded(
                                    child: _BannerSearchTextField(
                                      controller: searchController,
                                      hintText: searchHintText,
                                      query: searchQuery,
                                      onChanged: onSearchQueryChanged,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black87),
                                      ],
                                    ),
                                    onPressed: () {
                                      searchController.clear();
                                      onSearchQueryChanged('');
                                      onToggleSearch(false);
                                    },
                                  ),
                                ],
                              )
                            : Row(
                                key: const ValueKey('actions-normal-row'),
                                children: [
                                  if (actionButtonsScrollable)
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: actionButtons,
                                        ),
                                      ),
                                    )
                                  else ...[
                                    ...actionButtons,
                                    const Spacer(),
                                  ],
                                  const SizedBox(width: 8),
                                  _BannerSearchIconButton(
                                    onPressed: () => onToggleSearch(true),
                                    tooltip: l10n.search,
                                    isWhite: true,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroFlightShuttle({
    required BuildContext flightContext,
    required Animation<double> animation,
    required ThemeData theme,
    required AppLocalizations l10n,
    required double screenWidth,
    required String durationText,
    required bool hasImage,
    required File? coverFile,
    required double statusBarTop,
    required double desktopTitleBarHeight,
    required bool hasTopHeader,
    required bool isLowEndDevice,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double progress = animation.value;
        final double radiusTop = lerpDouble(8.0, 0.0, progress) ?? 0.0;
        final double radiusBottom = lerpDouble(8.0, 20.0, progress) ?? 20.0;

        final double darkOpacity = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ).value;

        // On high-end/desktop devices (isLowEndDevice == false), retain full rich Hero animation with foreground items.
        // On low-end devices, apply smooth fade-in curve (from 20% to 100% progress) so components smoothly fade in without popping up abruptly.
        final double fgOpacity = CurvedAnimation(
          parent: animation,
          curve: isLowEndDevice
              ? const Interval(0.20, 1.0, curve: Curves.easeOutCubic)
              : const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
        ).value;

        final double fgOffsetY = 12.0 * (1.0 - fgOpacity);

        return ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusTop),
            bottom: Radius.circular(radiusBottom),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Cover Image / Gradient Background
              hasImage
                  ? Image.file(
                      coverFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            HSLColor.fromAHSL(1.0, (title.hashCode.abs() % 360).toDouble(), 0.60, 0.30).toColor(),
                            HSLColor.fromAHSL(1.0, ((title.hashCode.abs() % 360 + 40) % 360).toDouble(), 0.70, 0.20).toColor(),
                          ],
                        ),
                      ),
                    ),

              // 2. Dark Gradient Overlay
              Opacity(
                opacity: darkOpacity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Complete Foreground Layer (Rendered with smooth fade-in on both modes)
              if (fgOpacity > 0.01)
                Opacity(
                  opacity: fgOpacity,
                  child: Transform.translate(
                    offset: Offset(0, fgOffsetY),
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: screenWidth,
                      maxWidth: screenWidth,
                      minHeight: 0,
                      maxHeight: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: hasTopHeader
                              ? 0
                              : (statusBarTop > 0
                                  ? statusBarTop + desktopTitleBarHeight + 8
                                  : desktopTitleBarHeight + 16),
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasTopHeader) topHeader!,
                            if (hasTopHeader) const SizedBox(height: 8),

                            _BannerInfoColumn(
                              title: title,
                              subtitle: subtitle,
                              songsCount: songsCount,
                              durationText: durationText,
                              isOverlay: true,
                            ),

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                if (actionButtonsScrollable)
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: actionButtons,
                                      ),
                                    ),
                                  )
                                else ...[
                                  ...actionButtons,
                                  const Spacer(),
                                ],
                                const SizedBox(width: 8),
                                _BannerSearchIconButton(
                                  onPressed: () {},
                                  tooltip: l10n.search,
                                  isWhite: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Information Text Column Sub-widget
class _BannerInfoColumn extends StatelessWidget {
  const _BannerInfoColumn({
    required this.title,
    required this.subtitle,
    required this.songsCount,
    required this.durationText,
    required this.isOverlay,
  });

  final String title;
  final String subtitle;
  final int songsCount;
  final String durationText;
  final bool isOverlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final titleColor = isOverlay ? Colors.white : theme.colorScheme.onSurface;
    final subtitleColor = isOverlay
        ? Colors.white.withValues(alpha: 0.8)
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: titleColor,
            shadows: isOverlay
                ? const [
                    Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black87),
                  ]
                : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtitleColor,
              shadows: isOverlay
                  ? const [
                      Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black87),
                    ]
                  : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.left,
          ),
        ],
        const SizedBox(height: 6),
        Text(
          '${l10n.songCount(songsCount)} | $durationText',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isOverlay
                ? Colors.white.withValues(alpha: 0.85)
                : theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: isOverlay ? 13 : 14,
            shadows: isOverlay
                ? const [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black87,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}

/// Search Text Field Sub-widget
class _BannerSearchTextField extends StatelessWidget {
  const _BannerSearchTextField({
    required this.controller,
    required this.hintText,
    required this.query,
    required this.onChanged,
    this.compact = false,
  });

  final TextEditingController controller;
  final String hintText;
  final String query;
  final ValueChanged<String> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      autofocus: true,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 6 : 8,
        ),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}

/// Search Icon Button Sub-widget
class _BannerSearchIconButton extends StatelessWidget {
  const _BannerSearchIconButton({
    required this.onPressed,
    required this.tooltip,
    this.isWhite = false,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1000;
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.search_rounded,
        size: isLargeScreen ? 18 : 16,
        color: isWhite ? Colors.white : null,
        shadows: isWhite
            ? const [
                Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black87),
              ]
            : null,
      ),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        minimumSize: Size(isLargeScreen ? 38 : 32, isLargeScreen ? 38 : 32),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class FolderPlayActionButtons extends StatelessWidget {
  const FolderPlayActionButtons({
    super.key,
    required this.onPlayAll,
    required this.onShufflePlay,
    required this.totalSongsCount,
  });

  final FutureOr<void> Function()? onPlayAll;
  final FutureOr<void> Function()? onShufflePlay;
  final int totalSongsCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWiderScreen = screenWidth > 480;
    final isLargeScreen = screenWidth >= 1000;
    final isDisabled = totalSongsCount == 0 || (onPlayAll == null && onShufflePlay == null);

    final playAllButton = isWiderScreen
        ? FilledButton.tonalIcon(
            onPressed: isDisabled ? null : () => onPlayAll?.call(),
            icon: Icon(Icons.play_arrow_rounded, size: isLargeScreen ? 18 : 16),
            label: Text(l10n.playAll),
            style: FilledButton.styleFrom(
              minimumSize: Size(0, isLargeScreen ? 38 : 32),
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 16 : 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              textStyle: TextStyle(
                fontSize: isLargeScreen ? 13.0 : 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : Tooltip(
            message: l10n.playAll,
            child: FilledButton.tonal(
              onPressed: isDisabled ? null : () => onPlayAll?.call(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(32, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              child: const Icon(Icons.play_arrow_rounded, size: 16),
            ),
          );

    final shuffleButton = isWiderScreen
        ? FilledButton.tonalIcon(
            onPressed: isDisabled ? null : () => onShufflePlay?.call(),
            icon: Icon(Icons.shuffle_rounded, size: isLargeScreen ? 18 : 16),
            label: Text(l10n.shuffle),
            style: FilledButton.styleFrom(
              minimumSize: Size(0, isLargeScreen ? 38 : 32),
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 16 : 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              textStyle: TextStyle(
                fontSize: isLargeScreen ? 13.0 : 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : Tooltip(
            message: l10n.shuffle,
            child: FilledButton.tonal(
              onPressed: isDisabled ? null : () => onShufflePlay?.call(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(32, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              child: const Icon(Icons.shuffle_rounded, size: 16),
            ),
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        playAllButton,
        const SizedBox(width: 8),
        shuffleButton,
      ],
    );
  }
}

/// Custom RectTween with an explicit curve per hero transition context
class SmoothRectTween extends RectTween {
  SmoothRectTween({
    super.begin,
    super.end,
    required this.curve,
  });

  final Curve curve;

  @override
  Rect? lerp(double t) {
    return super.lerp(curve.transform(t));
  }
}
