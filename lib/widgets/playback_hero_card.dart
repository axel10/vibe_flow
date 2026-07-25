import 'dart:ui' show lerpDouble, ImageFilter;

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:vynody/utils/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/utils/playback_utils.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import '../widgets/cover_carousel.dart';
import '../widgets/lyrics_panel.dart';

import '../widgets/mini_player_widgets.dart';
import '../widgets/animated_play_pause_button.dart';
import '../widgets/playback_ui_tuning.dart';
import '../widgets/waveform_progress_bar.dart';
import 'marquee_text.dart';
import 'app_tooltip.dart';

const String playbackHeroTag = 'player_capsule';

enum _TrackInfoMenuTarget { title, artistAlbum }

class _PlaybackPaneLayout {
  const _PlaybackPaneLayout({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
    required this.opacity,
  });

  final double top;
  final double left;
  final double width;
  final double height;
  final double opacity;
}

class _PlaybackCardLayout {
  const _PlaybackCardLayout({
    required this.cover,
    required this.info,
    required this.controls,
    required this.lyrics,
    required this.trackInfoAlign,
    required this.controlsScale,
  });

  final _PlaybackPaneLayout cover;
  final _PlaybackPaneLayout info;
  final _PlaybackPaneLayout controls;
  final _PlaybackPaneLayout lyrics;
  final TextAlign trackInfoAlign;
  final double controlsScale;
}

class PlaybackHeroCard extends ConsumerWidget {
  const PlaybackHeroCard({
    super.key,
    required this.isMini,
    this.isLyricsMode = false,
    this.isLandscape = false,
    this.isNext = true,
    this.showVisualizerToggle = true,
    this.showMiniVolumeSlider = false,
    this.onShowMoreMenu,
    this.onMiniTap,
    this.onCyclePlaylistMode,
    this.onShowPlaylistModeSelector,
    this.onScrubbing,
    this.onSeek,
    this.onToggleVisualizer,
    this.onTagCompletionTap,
    this.onTagCompletionLongPress,
    this.onSleepTimerTap,
    this.onEqualizerTap,
    this.onPrevious,
    this.onPlayPause,
    this.onNext,
    this.onVolumeTap,
    this.onVolumeChanged,
    this.onMiniMouseExit,
    this.onVolumeDrag,
    this.onVolumeScroll,
    this.onCoverTap,
    this.onCarouselAnimationComplete,
    this.overrideProgress,
    this.overridePosition,
    this.overrideWaveform,
    this.lyricsBottomSpacerHeight = 0.0,
    this.lyricsBottomTabBarHeight = 0.0,
    this.coverKey,
    this.lyricsKey,
  });

  final bool isMini;
  final bool isLyricsMode;
  final bool isLandscape;
  final bool isNext;
  final bool showMiniVolumeSlider;
  final List<double>? overrideWaveform;
  final double? overrideProgress;
  final Duration? overridePosition;
  final bool showVisualizerToggle;
  final VoidCallback? onShowMoreMenu;
  final VoidCallback? onMiniTap;
  final VoidCallback? onCyclePlaylistMode;
  final VoidCallback? onShowPlaylistModeSelector;
  final ValueChanged<double>? onScrubbing;
  final ValueChanged<double>? onSeek;
  final VoidCallback? onToggleVisualizer;
  final VoidCallback? onTagCompletionTap;
  final VoidCallback? onTagCompletionLongPress;
  final VoidCallback? onSleepTimerTap;
  final VoidCallback? onEqualizerTap;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onVolumeTap;
  final ValueChanged<double>? onVolumeChanged;
  final VoidCallback? onMiniMouseExit;
  final ValueChanged<double>? onVolumeDrag;
  final ValueChanged<double>? onVolumeScroll;
  final VoidCallback? onCoverTap;
  final void Function(Uint8List? artworkBytes, String? sourcePath)?
  onCarouselAnimationComplete;
  final double lyricsBottomSpacerHeight;
  final double lyricsBottomTabBarHeight;
  final GlobalKey? coverKey;
  final GlobalKey? lyricsKey;

  double _lerp2D(
    BuildContext context,
    double pN,
    double pL,
    double lN,
    double lL,
    double tLyrics,
    double tLand,
  ) {
    final p = lerpDouble(pN, pL, tLyrics) ?? pN;
    final l = lerpDouble(lN, lL, tLyrics) ?? lN;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final raw = lerpDouble(p, l, tLand) ?? p;
    return (raw * dpr).round() / dpr;
  }

  double _lerp2DSmooth(
    double pN,
    double pL,
    double lN,
    double lL,
    double tLyrics,
    double tLand,
  ) {
    final p = lerpDouble(pN, pL, tLyrics) ?? pN;
    final l = lerpDouble(lN, lL, tLyrics) ?? lN;
    return lerpDouble(p, l, tLand) ?? p;
  }

  _PlaybackPaneLayout _lerpPaneLayout(
    _PlaybackPaneLayout a,
    _PlaybackPaneLayout b,
    double t,
  ) {
    return _PlaybackPaneLayout(
      top: lerpDouble(a.top, b.top, t) ?? a.top,
      left: lerpDouble(a.left, b.left, t) ?? a.left,
      width: lerpDouble(a.width, b.width, t) ?? a.width,
      height: lerpDouble(a.height, b.height, t) ?? a.height,
      opacity: lerpDouble(a.opacity, b.opacity, t) ?? a.opacity,
    );
  }

  _PlaybackCardLayout _lerpPlaybackCardLayout(
    _PlaybackCardLayout start,
    _PlaybackCardLayout end,
    double t,
  ) {
    if (t <= 0.0) return start;
    if (t >= 1.0) return end;
    return _PlaybackCardLayout(
      cover: _lerpPaneLayout(start.cover, end.cover, t),
      info: _lerpPaneLayout(start.info, end.info, t),
      controls: _lerpPaneLayout(start.controls, end.controls, t),
      lyrics: _lerpPaneLayout(start.lyrics, end.lyrics, t),
      trackInfoAlign: t < 0.5 ? start.trackInfoAlign : end.trackInfoAlign,
      controlsScale: lerpDouble(start.controlsScale, end.controlsScale, t) ??
          start.controlsScale,
    );
  }

  // Removed viewportProfile

  Future<void> _showTrackInfoContextMenu(
    BuildContext context,
    Offset globalPosition, {
    required _TrackInfoMenuTarget target,
    required MusicFile? currentMusic,
  }) async {
    await showSongContextMenu(
      context,
      globalPosition,
      song: currentMusic,
      mode: target == _TrackInfoMenuTarget.title
          ? SongContextMenuMode.title
          : SongContextMenuMode.artistAlbum,
    );
  }

  Future<void> _showCoverContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset globalPosition,
    MusicFile? currentMusic,
  ) async {
    if (currentMusic == null) return;

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final l10n = AppLocalizations.of(context)!;
    final audioService = ref.read(audioServiceProvider);
    final bytes =
        currentMusic.artworkBytes ??
        audioService.getCachedArtwork(currentMusic.path);
    final String? path = currentMusic.artworkPath ?? currentMusic.thumbnailPath;
    final bool hasCover =
        (bytes != null && bytes.isNotEmpty) ||
        (path != null && File(path).existsSync());

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(globalPosition, globalPosition),
        Offset.zero & overlay.size,
      ),
      items: [
        buildContextMenuItem<String>(
          value: 'copy_cover',
          enabled: hasCover,
          label: l10n.copyCover,
          icon: Icons.image_outlined,
          context: context,
        ),
      ],
    );

    if (!context.mounted || selected == null) return;

    if (selected == 'copy_cover') {
      try {
        if (bytes != null && bytes.isNotEmpty) {
          await Pasteboard.writeImage(bytes);
          if (context.mounted) {
            AppSnackBar.show(
              context,
              ref,
              SnackBar(content: Text(l10n.copyCoverSuccess)),
            );
          }
        } else if (path != null) {
          final file = File(path);
          if (file.existsSync()) {
            final fileBytes = await file.readAsBytes();
            await Pasteboard.writeImage(fileBytes);
            if (context.mounted) {
              AppSnackBar.show(
                context,
                ref,
                SnackBar(content: Text(l10n.copyCoverSuccess)),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to copy cover to clipboard: $e');
        if (context.mounted) {
          AppSnackBar.show(
            context,
            ref,
            const SnackBar(content: Text('Failed to copy cover')),
          );
        }
      }
    }
  }

  String _formatSleepTimer(Duration duration) {
    final safe = duration < Duration.zero ? Duration.zero : duration;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60);
    return [
      hours.toString().padLeft(2, '0'),
      minutes.toString().padLeft(2, '0'),
      seconds.toString().padLeft(2, '0'),
    ].join(':');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Hero(
      tag: playbackHeroTag,
      child: Material(
        type: MaterialType.transparency,
        child: isMini
            ? _buildMiniCard(context, ref)
            : _buildFullCard(context, ref),
      ),
    );
  }

  Widget _buildMiniCard(BuildContext context, WidgetRef ref) {
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isPlaying = ref.watch(audioIsPlayingProvider);
    final progress = ref.watch(audioProgressProvider);
    final playlistService = ref.watch(playlistServiceProvider);
    final isFavorite =
        currentMusic != null && playlistService.isFavoriteSong(currentMusic);
    final l10n = AppLocalizations.of(context)!;

    final windowWidth = MediaQuery.of(context).size.width;
    // Volume button expanded needs 568 logical pixels.
    // If the window width is smaller than 568, we collapse the volume and favorite controls.
    final showVolumeAndFavorite = windowWidth >= 568.0;

    final playControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MiniControlButton(
          icon: Icons.skip_previous_rounded,
          onPressed: onPrevious,
          tooltip: l10n.previous,
        ),
        const SizedBox(width: 4),
        AnimatedPlayPauseButton(
          isPlaying: isPlaying,
          onPressed: onPlayPause,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
          size: 24,
          padding: const EdgeInsets.all(6.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          tooltip: isPlaying ? l10n.pause : l10n.play,
        ),
        const SizedBox(width: 4),
        MiniControlButton(
          icon: Icons.skip_next_rounded,
          onPressed: onNext,
          tooltip: l10n.next,
        ),
      ],
    );

    final trackInfo = Flexible(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onMiniTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniArtwork(),
            const SizedBox(width: 14),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: _MiniPlayerProgressInfo(
                  currentMusic: currentMusic,
                  progress: progress,
                  onScrubbing: onScrubbing,
                  onSeek: onSeek,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final rightControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTooltip(
          message: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
          child: IconButton(
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite
                  ? Colors.redAccent
                  : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87),
              size: 18,
            ),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: currentMusic == null
                ? null
                : () async {
                    await playlistService.toggleFavoriteSong(currentMusic);
                  },
          ),
        ),
        const SizedBox(width: 4),
        MiniInlineVolumeControl(
          volume: ref.watch(audioVolumeProvider),
          showSlider: showMiniVolumeSlider,
          onTap: onVolumeTap,
          onChanged: onVolumeChanged,
          onScroll: onVolumeScroll,
          tooltip: l10n.volume,
        ),
      ],
    );

    return MouseRegion(
      onExit: (_) => onMiniMouseExit?.call(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withValues(alpha: 0.82)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color:
                  (Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.grey[400]!)
                      .withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.6,
                  child: MiniSpectrumBackground(
                    audio: ref.read(audioServiceProvider),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: showVolumeAndFavorite
                      ? [
                          playControls,
                          const SizedBox(width: 14),
                          trackInfo,
                          const SizedBox(width: 14),
                          rightControls,
                        ]
                      : [trackInfo, const SizedBox(width: 14), playControls],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context, WidgetRef ref) {
    const animDuration = PlaybackHeroCardUiTuning.transitionDuration;
    const animCurve = Curves.fastOutSlowIn;
    final currentMusic = ref.watch(audioCurrentMusicProvider);

    final size = MediaQuery.of(context).size;
    final settings = ref.watch(settingsServiceProvider);

    final bool isLowMidEnd = ref.watch(isLowMidEndDeviceProvider);

    final bool isSmallWindow = PlaybackPageUiTuning.isSmallWindow(
      size,
      isWaveformEnabled: settings.isWaveformProgressBarEnabled,
      isSmallWindowMode: settings.isSmallWindowMode,
    );
    final bool effectiveIsLandscape = isLandscape && !isSmallWindow;
    final bool effectiveIsLyricsMode = isLyricsMode && !isSmallWindow;

    final isTransitioningNotifier = ValueNotifier<bool>(false);
    final lyricsPanelWidget = _LyricsPanelTransitionWrapper(
      isTransitioning: isTransitioningNotifier,
      lyricsBottomSpacerHeight: lyricsBottomSpacerHeight,
      lyricsBottomTabBarHeight: lyricsBottomTabBarHeight,
    );

    // 核心动画容器：使用 TweenAnimationBuilder 对 2D 平面上的多个布局变量（尺寸、位置、不透明度）进行线性插值处理。
    // 这使得点击封面切换 `isLyricsMode` 后，UI 元素能平滑移动/缩放，例如：
    // - 封面从大变小并挪到角落
    // - 歌词面板从下而上“浮现”
    // - 播放控制按键在手机竖屏时向下滑出屏幕
    return TweenAnimationBuilder<double>(
      duration: animDuration,
      curve: animCurve,
      tween: Tween<double>(end: effectiveIsLandscape ? 1.0 : 0.0),
      child: lyricsPanelWidget,
      builder: (context, tLand, child) {
        return TweenAnimationBuilder<double>(
          duration: animDuration,
          curve: animCurve,
          tween: Tween<double>(end: effectiveIsLyricsMode ? 1.0 : 0.0),
          child: child,
          builder: (context, tLyrics, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth.roundToDouble();
                final height = constraints.maxHeight.roundToDouble();
                final isWaveformEnabled = ref.watch(
                  settingsServiceProvider.select(
                    (s) => s.isWaveformProgressBarEnabled,
                  ),
                );
                final collapseButtonsInLandscapeLyrics = ref.watch(
                  settingsServiceProvider.select(
                    (s) => s.collapseButtonsInLandscapeLyrics,
                  ),
                );

                final bool isTransitioning =
                    (tLyrics > 0.0 && tLyrics < 1.0) ||
                    (tLand > 0.0 && tLand < 1.0);
                final bool optimize = isTransitioning && isLowMidEnd;

                final double targetTLyrics = effectiveIsLyricsMode ? 1.0 : 0.0;

                // Stable normal layout (tLyrics = 0.0)
                final coverNormalLayout = _buildPlaybackCardLayout(
                  context,
                  width: width,
                  height: height,
                  tLyrics: 0.0,
                  tLand: tLand,
                  isWaveformEnabled: isWaveformEnabled,
                  isSmallWindow: isSmallWindow,
                  lyricsStyle: settings.lyricsStyle,
                  collapseButtonsInLandscapeLyrics:
                      collapseButtonsInLandscapeLyrics,
                );

                // Stable target end layout (tLyrics = 1.0)
                final endLayout = _buildPlaybackCardLayout(
                  context,
                  width: width,
                  height: height,
                  tLyrics: 1.0,
                  tLand: tLand,
                  isWaveformEnabled: isWaveformEnabled,
                  isSmallWindow: isSmallWindow,
                  lyricsStyle: settings.lyricsStyle,
                  collapseButtonsInLandscapeLyrics:
                      collapseButtonsInLandscapeLyrics,
                );

                // Interpolated current layout for smooth animation without re-evaluating full layout rules
                final layout = _lerpPlaybackCardLayout(
                  coverNormalLayout,
                  endLayout,
                  tLyrics,
                );

                final targetLayout =
                    targetTLyrics == 1.0 ? endLayout : coverNormalLayout;

                final double translationX =
                    layout.lyrics.left - endLayout.lyrics.left;
                final double translationY =
                    layout.lyrics.top - endLayout.lyrics.top;

                final double infoTranslationX =
                    layout.info.left - targetLayout.info.left;
                final double infoTranslationY =
                    layout.info.top - targetLayout.info.top;

                return SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: endLayout.lyrics.top,
                        left: endLayout.lyrics.left,
                        width: endLayout.lyrics.width,
                        height: endLayout.lyrics.height,
                        child: ExcludeSemantics(
                          excluding: isTransitioning,
                          child: RepaintBoundary(
                            child: Transform.translate(
                              offset: Offset(translationX, translationY),
                              child: IgnorePointer(
                                ignoring: layout.lyrics.opacity < 0.5,
                                child: RepaintBoundary(
                                  child: Consumer(
                                    builder: (context, ref, childWidget) {
                                      if (tLyrics == 0.0 &&
                                          !effectiveIsLyricsMode) {
                                        return const SizedBox.shrink();
                                      }
                                      if (isTransitioningNotifier.value !=
                                          optimize) {
                                        Future.microtask(() {
                                          isTransitioningNotifier.value =
                                              optimize;
                                        });
                                      }
                                      if (lyricsKey != null) {
                                        return KeyedSubtree(
                                          key: lyricsKey,
                                          child: child!,
                                        );
                                      }
                                      return child!;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isSmallWindow)
                        Positioned(
                          top: layout.info.top - 48.0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final containerHeight = constraints.maxHeight;
                              final fadeStop = containerHeight > 0
                                  ? (48.0 / containerHeight).clamp(0.0, 1.0)
                                  : 0.2;
                              return ShaderMask(
                                shaderCallback: (rect) {
                                  return LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: const [
                                      Colors.transparent,
                                      Colors.black,
                                    ],
                                    stops: [0.0, fadeStop],
                                  ).createShader(rect);
                                },
                                blendMode: BlendMode.dstIn,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.35),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      Positioned(
                        // 控件区
                        top: layout.controls.top,
                        left: layout.controls.left,
                        width: layout.controls.width,
                        height: layout.controls.height,
                        child: IgnorePointer(
                          ignoring: layout.controls.opacity < 0.5,
                          child: FittedBox(
                            // 控件区
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Consumer(
                              builder: (context, ref, child) {
                                final double layoutWidth = optimize
                                    ? targetLayout.controls.width
                                    : layout.controls.width;
                                return SizedBox(
                                  key: const ValueKey('controls_sizing_box'),
                                  width: (effectiveIsLandscape
                                      ? layoutWidth
                                      : width *
                                            PlaybackHeroCardUiTuning
                                                .portraitControlsWidthFactor),
                                  child: _buildPlaybackControlsWidget(
                                    context,
                                    ref,
                                    width: width,
                                    layoutWidth: layoutWidth,
                                    controlsScale: optimize
                                        ? targetLayout.controlsScale
                                        : layout.controlsScale,
                                    tLyrics: optimize ? targetTLyrics : tLyrics,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (layout.cover.width > 0 && layout.cover.height > 0)
                        Positioned(
                          top: layout.cover.top,
                          left: layout.cover.left,
                          width: layout.cover.width,
                          height: layout.cover.height,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final double currentSize = optimize
                                  ? coverNormalLayout.cover.width
                                  : layout.cover.width;
                              final Widget coverWidget = _buildAlbumArtCore(
                                context,
                                ref,
                                currentSize,
                                cacheWidthSize: coverNormalLayout.cover.width,
                              );
                              final Widget result = optimize
                                  ? FittedBox(
                                      fit: BoxFit.fill,
                                      child: SizedBox(
                                        width: coverNormalLayout.cover.width,
                                        height: coverNormalLayout.cover.width,
                                        child: coverWidget,
                                      ),
                                    )
                                  : coverWidget;
                              return KeyedSubtree(key: coverKey, child: result);
                            },
                          ),
                        ),
                      Positioned(
                        top: optimize ? targetLayout.info.top : layout.info.top,
                        left: optimize ? targetLayout.info.left : layout.info.left,
                        width: optimize ? targetLayout.info.width : layout.info.width,
                        height: optimize ? targetLayout.info.height : layout.info.height,
                        child: Transform.translate(
                          offset: optimize
                              ? Offset(infoTranslationX, infoTranslationY)
                              : Offset.zero,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: optimize
                                ? Alignment.lerp(
                                    Alignment.center,
                                    Alignment.lerp(
                                      Alignment.center,
                                      Alignment.centerLeft,
                                      targetTLyrics,
                                    )!,
                                    tLand,
                                  )!
                                : Alignment.lerp(
                                    Alignment.center,
                                    Alignment.lerp(
                                      Alignment.center,
                                      Alignment.centerLeft,
                                      tLyrics,
                                    )!,
                                    tLand,
                                  )!,
                            child: SizedBox(
                              width: optimize
                                  ? targetLayout.info.width
                                  : layout.info.width,
                              child: _buildTrackInfo(
                                context,
                                ref,
                                currentMusic,
                                optimize
                                    ? targetLayout.trackInfoAlign
                                    : layout.trackInfoAlign,
                                optimize ? targetTLyrics : tLyrics,
                                tLand,
                                optimize
                                    ? targetLayout.controlsScale
                                    : layout.controlsScale,
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
          },
        );
      },
    );
  }

  _PlaybackCardLayout _buildPlaybackCardLayout(
    BuildContext context, {
    required double width,
    required double height,
    required double tLyrics,
    required double tLand,
    required bool isWaveformEnabled,
    required bool isSmallWindow,
    required LyricsStyle lyricsStyle,
    bool collapseButtonsInLandscapeLyrics = true,
  }) {
    // ---------------- Portrait Normal ----------------
    final double scaleFactor = isSmallWindow ? 0.82 : 1.0;

    final pNormalControlsBaseIdealHeight =
        PlaybackHeroCardUiTuning.controlsTopButtonsHeight +
        (isWaveformEnabled
            ? PlaybackHeroCardUiTuning.waveformStandardTimeRowSpacing
            : PlaybackHeroCardUiTuning.controlsRowPortraitGap) +
        (isWaveformEnabled
            ? PlaybackHeroCardUiTuning.waveformOverlayHeight
            : 48.0) + // Normal slider height is roughly 48
        (isWaveformEnabled
            ? 0.0
            : (8.0 + // Time gap
                  PlaybackHeroCardUiTuning.controlsTimeRowHeight +
                  PlaybackHeroCardUiTuning.controlsRowPortraitGap +
                  PlaybackHeroCardUiTuning.controlsMainButtonsHeight));

    final pNormalControlsWidth =
        width * PlaybackHeroCardUiTuning.portraitControlsWidthFactor;
    final pNormalScale =
        (width / PlaybackHeroCardUiTuning.pControlsScaleBase).clamp(0.9, 1.15) *
        scaleFactor;

    final double maxControlsHeightFactor = isSmallWindow
        ? 0.85
        : PlaybackHeroCardUiTuning.pControlsHeightFactor;

    final pNormalControlsHeight =
        (pNormalControlsBaseIdealHeight * pNormalScale)
            .clamp(0.0, height * maxControlsHeightFactor)
            .ceilToDouble();
    final pNormalInfoHeight =
        PlaybackHeroCardUiTuning.pInfoHeight * pNormalScale;

    // 避让底部 Tab 栏高度 (Avoid bottom tab bar height)
    final pNormalBottomLimit =
        height - PlaybackHeroCardUiTuning.portraitBottomReservedSpace;

    // 封面贴顶 (Cover sticks to top)
    const pNormalCoverTop = 0.0;

    // 内容总高度 (Total content height: Info + Controls)
    final pNormalTotalContentHeight = pNormalInfoHeight + pNormalControlsHeight;

    // 封面尺寸：在满足下方内容展示空间的情况下，尽量占满宽度
    // 留出最小间距以防重叠 (Reserved min gap to prevent overlap)
    final pNormalCoverSide = isSmallWindow
        ? 0.0
        : math
              .min(
                width,
                pNormalBottomLimit -
                    pNormalTotalContentHeight -
                    PlaybackHeroCardUiTuning.pNormalCoverInfoMinGap,
              )
              .clamp(0.0, PlaybackHeroCardUiTuning.pCoverMaxSide)
              .toDouble();

    final double pNormalInfoTop;
    final double pNormalControlsTop;

    if (isSmallWindow) {
      // 紧贴窗口底部 (Position right up against the bottom of the window)
      // 留出 12 像素底边距 (Leave 12px padding at the bottom)
      const double bottomPadding = 12.0;
      pNormalControlsTop =
          pNormalBottomLimit - pNormalControlsHeight - bottomPadding;
      pNormalInfoTop = pNormalControlsTop - pNormalInfoHeight - 4.0;
    } else {
      // 在封面底部到 Tab 栏顶部之间的剩余空间内居中放置标题和控件区
      final pNormalAvailableHeight = pNormalBottomLimit - pNormalCoverSide;
      final pNormalContentTop =
          pNormalCoverSide +
          (pNormalAvailableHeight - pNormalTotalContentHeight) / 2;

      pNormalInfoTop = pNormalContentTop;
      pNormalControlsTop = pNormalInfoTop + pNormalInfoHeight;
    }

    // ---------------- Portrait Lyrics ----------------
    final pLyricsCoverSide = PlaybackHeroCardUiTuning.pLyricsCoverSide;
    final pLyricsCoverTop = PlaybackHeroCardUiTuning.pLyricsCoverTop;
    final pLyricsCoverLeft = PlaybackHeroCardUiTuning.pLyricsCoverLeft;

    final pLyricsInfoHeight = pLyricsCoverSide;
    final pLyricsInfoTop = pLyricsCoverTop;
    final pLyricsInfoLeft = pLyricsCoverLeft + pLyricsCoverSide + 16.0;

    // ---------------- Landscape Normal ----------------
    final lNormalContentWidth = width
        .clamp(0.0, math.max(1600.0, height * 2.5).toDouble())
        .toDouble();
    final lNormalOffsetX = (width - lNormalContentWidth) / 2;

    final lColumnWidth = lNormalContentWidth * 0.5;

    // 横屏普通模式控件区宽度：采用具有较高基底和较低增长率的公式，
    // 使得在窗口化（较小宽度）时控件区比例更大，而在全屏（较大宽度）时保持原样。
    // (Landscape normal controls width: Use a formula with a higher base and lower growth rate,
    // making the controls area relatively larger in windowed mode while maintaining fullscreen size.)
    final lNormalControlsWidth = (lNormalContentWidth * 0.24 + 72).clamp(
      PlaybackHeroCardUiTuning.lControlsMinWidth,
      PlaybackHeroCardUiTuning.lControlsMaxWidth,
    );
    final lNormalCoverSide = math
        .min(
          lColumnWidth * PlaybackHeroCardUiTuning.lNormalCoverSideFactor,
          height * PlaybackHeroCardUiTuning.lNormalCoverSideFactor,
        )
        .clamp(
          PlaybackHeroCardUiTuning.lCoverMinSide,
          PlaybackHeroCardUiTuning.lCoverMaxSide,
        );

    final lNormalLeftCenter = lNormalOffsetX + (lNormalContentWidth * 0.25);
    final lNormalCoverTop = (height - lNormalCoverSide) / 2;
    final lNormalCoverLeft = lNormalLeftCenter - (lNormalCoverSide / 2);

    final lNormalCoverRightEdge = lNormalCoverLeft + lNormalCoverSide;
    final lContentRightEdge = lNormalOffsetX + lNormalContentWidth;
    final lRemainingSpace = lContentRightEdge - lNormalCoverRightEdge;

    final lNormalControlsLeft =
        lNormalCoverRightEdge + (lRemainingSpace - lNormalControlsWidth) / 2;

    final double lNormalControlsScale =
        (lNormalControlsWidth / PlaybackHeroCardUiTuning.lControlsScaleBase)
            .clamp(0.85, 1.8);
    final double lNormalSingleButtonWidth =
        PlaybackHeroCardUiTuning.controlsTopButtonsHeight *
        lNormalControlsScale;
    final double lNormalGapWidth =
        PlaybackHeroCardUiTuning.topButtonsInnerGap * lNormalControlsScale;
    final double lNormalButtonsRowWidth =
        7 * lNormalSingleButtonWidth + 6 * lNormalGapWidth;

    // When the gap between controls and cover is >= 80.0, the title area is at full width (lNormalControlsWidth).
    // As the gap shrinks from 80.0 to 0.0, the title area width gradually shrinks to align with the button area (lNormalButtonsRowWidth).
    const double gapStartShrink = 80.0;
    const double gapEndShrink = 0.0;
    final double gap = lNormalControlsLeft - lNormalCoverRightEdge;
    final double lNormalInfoWidthFactor =
        ((gap - gapEndShrink) / (gapStartShrink - gapEndShrink)).clamp(
          0.0,
          1.0,
        );
    final double lNormalInfoWidthAdjusted =
        lNormalButtonsRowWidth +
        (lNormalControlsWidth - lNormalButtonsRowWidth) *
            lNormalInfoWidthFactor;

    final double lNormalInfoLeftAdjusted =
        lNormalControlsLeft +
        (lNormalControlsWidth - lNormalInfoWidthAdjusted) / 2;

    // Snap the normal landscape panes to whole pixels to avoid 1px overflow
    // when the window is resized and the layout lands on fractional values.
    final lNormalControlsRawScale =
        lNormalControlsWidth / PlaybackHeroCardUiTuning.lControlsScaleBase;

    // 标题区实际高度 (Title actual height)
    final lNormalInfoHeight =
        (PlaybackHeroCardUiTuning.landscapeInfoHeightBase *
                lNormalControlsRawScale.clamp(0.0, 1.8))
            .ceilToDouble();

    // 控件区动态高度计算 (Dynamic controls height)
    final lNormalControlsBaseIdealHeight =
        PlaybackHeroCardUiTuning.controlsTopButtonsHeight +
        PlaybackHeroCardUiTuning.controlsRowLandscapeGap +
        (isWaveformEnabled
            ? PlaybackHeroCardUiTuning.waveformLandscapeHeight
            : 48.0) + // Use smaller height when waveform is disabled
        PlaybackHeroCardUiTuning.controlsTimeGap +
        PlaybackHeroCardUiTuning.controlsTimeRowHeight +
        PlaybackHeroCardUiTuning.controlsRowLandscapeMainGap +
        PlaybackHeroCardUiTuning.controlsMainButtonsHeight;

    final lNormalControlsHeight =
        (lNormalControlsBaseIdealHeight *
                lNormalControlsRawScale.clamp(0.0, 1.8))
            .clamp(
              0.0,
              height * 0.5,
            ) // Remove pControlsMinHeight clamp to allow exact fit
            .ceilToDouble();

    final lNormalGap = PlaybackHeroCardUiTuning.landscapeInfoControlsGap;
    final lNormalInfoTop =
        (height * 0.5 -
                (lNormalInfoHeight + lNormalControlsHeight + lNormalGap) / 2)
            .roundToDouble();
    final lNormalControlsTop = lNormalInfoTop + lNormalInfoHeight + lNormalGap;

    // ---------------- Landscape Lyrics ----------------
    // 高分辨率屏幕适配系数（4K 显示屏且高度充足时适度放大，1080p 显示屏保持 1.0 紧凑基准）
    // High-DPI adaptation factor: scale up smoothly on 4K screens (> 1920 logical width) when height is sufficient
    final double highResControlsScale = (width > 1920.0 && height > 600.0)
        ? (1.0 + (width - 1920.0) * 0.00018).clamp(1.0, 1.35)
        : 1.0;

    // 当窗口宽度与高度均充足时，通过 PlaybackHeroCardUiTuning 中的统一参数按比例放大封面与控件区
    final double widthFactor = ((width - 960.0) / 720.0).clamp(0.0, 1.0);
    final double heightFactor = ((height - 580.0) / 420.0).clamp(0.0, 1.0);
    final double spaceFactor = math.min(widthFactor, heightFactor);

    final double lLyricsPreferredCoverSide =
        (PlaybackHeroCardUiTuning.lLyricsPreferredCoverSide +
                spaceFactor * PlaybackHeroCardUiTuning.lLyricsMaxCoverExpansion) *
        highResControlsScale;
    final double lLyricsSpaceControlsScale =
        highResControlsScale *
        (PlaybackHeroCardUiTuning.lLyricsBaseControlsScale +
            spaceFactor * PlaybackHeroCardUiTuning.lLyricsMaxControlsExpansion);

    const lLyricsTopPadding = 16.0;
    const lLyricsOuterLeftPadding = 48.0;
    const lLyricsInnerLeftPadding = 16.0;
    final lLyricsAvailableHeight = math.max(
      0.0,
      height - (lLyricsTopPadding * 2),
    );

    final double lLyricsColumnWidth;
    final double lLyricsLyricsLeft;
    final double lLyricsLyricsWidth;

    if (lyricsStyle == LyricsStyle.apple) {
      final double rightRatio =
          PlaybackHeroCardUiTuning.appleLyricsRightPanelRatio;
      final double leftRatio = 1.0 - rightRatio;
      lLyricsColumnWidth = width * leftRatio;
      lLyricsLyricsLeft = width * leftRatio + 24.0;
      lLyricsLyricsWidth = math.max(0.0, width * rightRatio - 24.0 - 48.0);
    } else {
      final double lLyricsMaxColumnWidth = math.min(width * 0.45, 800.0);
      lLyricsColumnWidth = (width * 0.20).clamp(
        math.min(380.0, lLyricsMaxColumnWidth),
        lLyricsMaxColumnWidth,
      );
      lLyricsLyricsLeft =
          lLyricsOuterLeftPadding +
          lLyricsColumnWidth +
          lLyricsInnerLeftPadding;
      lLyricsLyricsWidth = math.max(0.0, width - lLyricsLyricsLeft - 32.0);
    }

    final double lLyricsInfoHeight =
        (collapseButtonsInLandscapeLyrics
            ? PlaybackHeroCardUiTuning.landscapeLyricsInfoHeightBase
            : PlaybackHeroCardUiTuning.landscapeInfoHeightBase) *
        lLyricsSpaceControlsScale;

    final double lLyricsControlsBaseIdealHeight =
        collapseButtonsInLandscapeLyrics
            ? ((isWaveformEnabled
                    ? PlaybackHeroCardUiTuning.waveformLandscapeHeight
                    : 48.0) +
                PlaybackHeroCardUiTuning.controlsTimeGap +
                PlaybackHeroCardUiTuning.controlsTimeRowHeight +
                PlaybackHeroCardUiTuning.controlsRowLandscapeGap +
                PlaybackHeroCardUiTuning.controlsMainButtonsHeight)
            : lNormalControlsBaseIdealHeight;
    final lLyricsControlsHeight =
        lLyricsControlsBaseIdealHeight * lLyricsSpaceControlsScale;

    final lLyricsCoverInfoSpacing =
        PlaybackHeroCardUiTuning.landscapeLyricsCoverInfoGapBase *
        lLyricsSpaceControlsScale;
    final lLyricsInfoControlsSpacing =
        PlaybackHeroCardUiTuning.landscapeLyricsInfoControlsGap *
        lLyricsSpaceControlsScale;

    // Apple Music 布局逻辑：控件大小保持舒适设定，高度不足时封面收缩，控件区宽度同步收缩至与封面同宽，控件间距自动紧密
    final double maxHorizontalSpace =
        lyricsStyle == LyricsStyle.apple
            ? math.max(120.0, lLyricsColumnWidth - 64.0)
            : lLyricsColumnWidth;
    final double maxCoverSide = math.min(
      lLyricsPreferredCoverSide,
      maxHorizontalSpace,
    );
    final double availableCoverHeight =
        lLyricsAvailableHeight -
        lLyricsInfoHeight -
        lLyricsControlsHeight -
        lLyricsCoverInfoSpacing -
        lLyricsInfoControlsSpacing;

    final double lLyricsCoverSide = availableCoverHeight.clamp(
      math.min(140.0, maxCoverSide),
      maxCoverSide,
    );

    // 控件区与标题区宽度收缩至与封面保持一致，控件大小不变，按钮间距自动收缩
    final double lLyricsItemWidth = math.min(
      maxHorizontalSpace,
      lLyricsCoverSide,
    );

    final double lLyricsTotalContentHeight =
        lLyricsCoverSide +
        lLyricsCoverInfoSpacing +
        lLyricsInfoHeight +
        lLyricsInfoControlsSpacing +
        lLyricsControlsHeight;

    final double lLyricsCoverTop = math.max(
      16.0,
      (height - lLyricsTotalContentHeight) / 2,
    );

    // 居中对齐逻辑：封面、信息区和控制区在列宽内统一居中对齐
    // Centering logic: cover, info and controls are centered within the column and aligned in width
    // 横屏歌词模式控件尺寸保持舒适，横向间距随控件区宽度（同封面宽）动态调整
    final currentControlsScale =
        _lerp2DSmooth(
          // 竖屏：基于宽度进行缩放，稍微增加基准，让按钮在标准屏幕上保持舒适大小
          (width / PlaybackHeroCardUiTuning.pControlsScaleBase).clamp(
            0.9,
            1.15,
          ),
          1.0,
          // 横屏普通模式：基于列宽进行缩放，放宽最小缩放限制以允许在小窗口下更自然的布局
          (lNormalControlsWidth / PlaybackHeroCardUiTuning.lControlsScaleBase)
              .clamp(0.85, 1.8),
          // 横屏歌词模式：控件大小保持舒适设定
          lLyricsSpaceControlsScale,
          tLyrics,
          tLand,
        ) *
        scaleFactor;

    final double lLyricsCoverLeft;
    final double lLyricsInfoLeft;
    final double lLyricsControlsLeft;

    if (lyricsStyle == LyricsStyle.apple) {
      final double leftAreaCenter = lLyricsColumnWidth / 2;
      lLyricsCoverLeft = (leftAreaCenter - lLyricsCoverSide / 2).clamp(
        32.0,
        math.max(32.0, lLyricsColumnWidth - lLyricsCoverSide - 24.0),
      );
      final double itemLeft = (leftAreaCenter - lLyricsItemWidth / 2).clamp(
        24.0,
        math.max(24.0, lLyricsColumnWidth - lLyricsItemWidth - 24.0),
      );
      lLyricsInfoLeft = itemLeft;
      lLyricsControlsLeft = itemLeft;
    } else {
      lLyricsCoverLeft = lLyricsOuterLeftPadding;
      lLyricsInfoLeft = lLyricsOuterLeftPadding;
      lLyricsControlsLeft = lLyricsOuterLeftPadding;
    }

    final lLyricsInfoTop =
        lLyricsCoverTop + lLyricsCoverSide + lLyricsCoverInfoSpacing;

    final lLyricsControlsTop =
        lLyricsInfoTop + lLyricsInfoHeight + lLyricsInfoControlsSpacing;

    // Build the Panes
    // Cover
    final cover = _lerpPane(
      context,
      pNormal: _PlaybackPaneLayout(
        top: pNormalCoverTop,
        left: (width - pNormalCoverSide) / 2,
        width: pNormalCoverSide,
        height: pNormalCoverSide,
        opacity: 1.0,
      ),
      pLyrics: _PlaybackPaneLayout(
        top: pLyricsCoverTop,
        left: pLyricsCoverLeft,
        width: pLyricsCoverSide,
        height: pLyricsCoverSide,
        opacity: 1.0,
      ),
      lNormal: _PlaybackPaneLayout(
        top: lNormalCoverTop,
        left: lNormalCoverLeft,
        width: lNormalCoverSide,
        height: lNormalCoverSide,
        opacity: 1.0,
      ),
      lLyrics: _PlaybackPaneLayout(
        top: lLyricsCoverTop,
        left: lLyricsCoverLeft,
        width: lLyricsCoverSide,
        height: lLyricsCoverSide,
        opacity: 1.0,
      ),
      tLyrics: tLyrics,
      tLand: tLand,
    );

    // Info
    final info = _lerpPane(
      context,
      pNormal: _PlaybackPaneLayout(
        top: pNormalInfoTop,
        left: 24.0,
        width: math.max(0.0, width - 48.0),
        height: pNormalInfoHeight,
        opacity: 1.0,
      ),
      pLyrics: _PlaybackPaneLayout(
        top: pLyricsInfoTop,
        left: pLyricsInfoLeft,
        width: math.max(0.0, width - pLyricsInfoLeft - 24.0),
        height: pLyricsInfoHeight,
        opacity: 1.0,
      ),
      lNormal: _PlaybackPaneLayout(
        top: lNormalInfoTop,
        left: lNormalInfoLeftAdjusted,
        width: lNormalInfoWidthAdjusted,
        height: lNormalInfoHeight,
        opacity: 1.0,
      ),
      lLyrics: _PlaybackPaneLayout(
        top: lLyricsInfoTop,
        left: lLyricsInfoLeft,
        width: lLyricsItemWidth,
        height: lLyricsInfoHeight,
        opacity: 1.0,
      ),
      tLyrics: tLyrics,
      tLand: tLand,
    );

    // Controls
    final controls = _lerpPane(
      context,
      pNormal: _PlaybackPaneLayout(
        top: pNormalControlsTop,
        left: (width - math.min(width, pNormalControlsWidth)) / 2,
        width: math.min(width, pNormalControlsWidth),
        height: pNormalControlsHeight,
        opacity: 1.0,
      ),
      pLyrics: _PlaybackPaneLayout(
        top: height,
        left: 24.0,
        width: math.max(0.0, width - 48.0),
        height: pNormalControlsHeight,
        opacity: 0.0,
      ),
      lNormal: _PlaybackPaneLayout(
        top: lNormalControlsTop,
        left: lNormalControlsLeft,
        width: lNormalControlsWidth,
        height: lNormalControlsHeight,
        opacity: 1.0,
      ),
      lLyrics: _PlaybackPaneLayout(
        top: lLyricsControlsTop,
        left: lLyricsControlsLeft,
        width: lLyricsItemWidth,
        height: lLyricsControlsHeight,
        opacity: 1.0,
      ),
      tLyrics: tLyrics,
      tLand: tLand,
    );

    // Lyrics
    final lyrics = _lerpPane(
      context,
      pNormal: _PlaybackPaneLayout(
        top: height + 80.0,
        left: 24.0,
        width: math.max(0.0, width - 48.0),
        height: math.max(
          0.0,
          height - (pLyricsCoverTop + pLyricsCoverSide + 16.0),
        ),
        opacity: 0.0,
      ),
      pLyrics: _PlaybackPaneLayout(
        top: pLyricsCoverTop + pLyricsCoverSide + 16.0,
        left: 24.0,
        width: math.max(0.0, width - 48.0),
        height: math.max(
          0.0,
          height - (pLyricsCoverTop + pLyricsCoverSide + 16.0),
        ),
        opacity: 1.0,
      ),
      lNormal: _PlaybackPaneLayout(
        top: 16.0,
        left: width + 80.0,
        width: lLyricsLyricsWidth,
        height: math.max(0.0, height - 32.0),
        opacity: 0.0,
      ),
      lLyrics: _PlaybackPaneLayout(
        top: 16.0,
        left: lLyricsLyricsLeft,
        width: lLyricsLyricsWidth,
        height: math.max(0.0, height - 32.0),
        opacity: 1.0,
      ),
      tLyrics: tLyrics,
      tLand: tLand,
    );

    final trackInfoAlign = isLandscape
        ? TextAlign.center
        : (isLyricsMode ? TextAlign.left : TextAlign.center);

    return _PlaybackCardLayout(
      cover: cover,
      info: info,
      controls: controls,
      lyrics: lyrics,
      trackInfoAlign: trackInfoAlign,
      controlsScale: currentControlsScale,
    );
  }

  _PlaybackPaneLayout _lerpPane(
    BuildContext context, {
    required _PlaybackPaneLayout pNormal,
    required _PlaybackPaneLayout pLyrics,
    required _PlaybackPaneLayout lNormal,
    required _PlaybackPaneLayout lLyrics,
    required double tLyrics,
    required double tLand,
  }) {
    return _PlaybackPaneLayout(
      top: _lerp2D(
        context,
        pNormal.top,
        pLyrics.top,
        lNormal.top,
        lLyrics.top,
        tLyrics,
        tLand,
      ),
      left: _lerp2D(
        context,
        pNormal.left,
        pLyrics.left,
        lNormal.left,
        lLyrics.left,
        tLyrics,
        tLand,
      ),
      width: _lerp2D(
        context,
        pNormal.width,
        pLyrics.width,
        lNormal.width,
        lLyrics.width,
        tLyrics,
        tLand,
      ),
      height: _lerp2D(
        context,
        pNormal.height,
        pLyrics.height,
        lNormal.height,
        lLyrics.height,
        tLyrics,
        tLand,
      ),
      opacity: _lerp2DSmooth(
        pNormal.opacity,
        pLyrics.opacity,
        lNormal.opacity,
        lLyrics.opacity,
        tLyrics,
        tLand,
      ),
    );
  }

  Widget _buildAlbumArtCore(
    BuildContext context,
    WidgetRef ref,
    double currentSize, {
    double? cacheWidthSize,
  }) {
    final playlist = ref.watch(audioPlaybackQueueProvider);
    final currentIndex = ref.watch(audioCurrentIndexProvider);
    if (playlist.isEmpty) {
      return Center(
        child: Container(
          width: currentSize * 0.8,
          height: currentSize * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              math.min(24.0, currentSize * 0.2),
            ),
            color: Colors.black87,
            boxShadow: [
              // Deep soft ambient shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 16),
              ),
              // Crisp contact shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.music_note, size: 80, color: Colors.white54),
        ),
      );
    }

    final cover = ExcludeSemantics(
      child: CoverCarousel(
        playlist: playlist,
        currentIndex: currentIndex,
        audioService: ref.read(audioServiceProvider),
        isNext: isNext,
        displaySize: currentSize,
        cacheWidthSize: cacheWidthSize,
        onPageChanged: (page) {
          final audio = ref.read(audioServiceProvider);
          if (page >= 0 && page < playlist.length && page != currentIndex) {
            audio.playAtIndex(page);
          }
        },
        onAnimationComplete: onCarouselAnimationComplete,
      ),
    );

    final currentMusic = ref.watch(audioCurrentMusicProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onCoverTap,
      onSecondaryTapDown: (details) {
        _showCoverContextMenu(
          context,
          ref,
          details.globalPosition,
          currentMusic,
        );
      },
      onLongPressStart: (details) {
        HapticFeedback.mediumImpact();
        _showCoverContextMenu(
          context,
          ref,
          details.globalPosition,
          currentMusic,
        );
      },
      child: cover,
    );
  }

  Widget _buildTrackInfo(
    BuildContext context,
    WidgetRef ref,
    MusicFile? currentMusic,
    TextAlign align,
    double lyricsModeT,
    double landscapeT,
    double controlsScale,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final title = currentMusic?.displayName ?? l10n.notSelected;
    final showArtistAlbum = currentMusic != null;

    final rawAlbum = currentMusic?.album?.trim() ?? '';
    final rawArtist = currentMusic?.artist?.trim() ?? '';

    bool isUnknown(String val) {
      if (val.isEmpty) return true;
      final lower = val.toLowerCase();
      return lower == 'unknown' ||
          lower == 'unknown artist' ||
          lower == 'unknown album';
    }

    final bool hasArtist = !isUnknown(rawArtist);
    final bool hasAlbum = !isUnknown(rawAlbum);
    final shouldCollapse = ref.watch(
      settingsServiceProvider.select(
        (s) => s.collapseButtonsInLandscapeLyrics,
      ),
    );
    final transition = lyricsModeT.clamp(0.0, 1.0);
    final double simplifiedT = shouldCollapse ? (landscapeT * transition) : 0.0;
    final double portraitLyricsT = (1.0 - landscapeT) * transition;
    final double rightButtonsFactor = math.max(simplifiedT, portraitLyricsT);
    final bool showFavoriteIconButton = simplifiedT > 0.0;

    final double buttonControlsScale = controlsScale;

    final titleAlignment = Alignment.lerp(
      Alignment.center,
      (shouldCollapse || landscapeT == 0.0)
          ? Alignment.centerLeft
          : Alignment.center,
      transition,
    )!;

    final double baseTitleSize = lerpDouble(
      lerpDouble(
        PlaybackHeroCardUiTuning.trackTitleStandardFont,
        PlaybackHeroCardUiTuning.trackTitlePortraitLyricsFont,
        transition,
      )!,
      lerpDouble(
        PlaybackHeroCardUiTuning.trackTitleStandardFont,
        shouldCollapse
            ? PlaybackHeroCardUiTuning.trackTitleLandscapeLyricsFont
            : PlaybackHeroCardUiTuning.trackTitleStandardFont,
        transition,
      )!,
      landscapeT,
    )!;
    final double minTitleFont = lerpDouble(
      PlaybackHeroCardUiTuning.minTrackTitleFontSize,
      PlaybackHeroCardUiTuning.minTrackTitleFontSize * controlsScale,
      simplifiedT,
    )!.clamp(9.0, PlaybackHeroCardUiTuning.minTrackTitleFontSize);
    final titleSize = math.max(
      minTitleFont,
      baseTitleSize * controlsScale,
    );

    final double baseArtistSize = lerpDouble(
      lerpDouble(
        PlaybackHeroCardUiTuning.trackArtistStandardFont,
        PlaybackHeroCardUiTuning.trackArtistPortraitLyricsFont,
        transition,
      )!,
      lerpDouble(
        PlaybackHeroCardUiTuning.trackArtistStandardFont,
        shouldCollapse
            ? PlaybackHeroCardUiTuning.trackArtistLandscapeLyricsFont
            : PlaybackHeroCardUiTuning.trackArtistStandardFont,
        transition,
      )!,
      landscapeT,
    )!;
    final double minArtistFont = lerpDouble(
      PlaybackHeroCardUiTuning.minTrackArtistFontSize,
      PlaybackHeroCardUiTuning.minTrackArtistFontSize * controlsScale,
      simplifiedT,
    )!.clamp(8.0, PlaybackHeroCardUiTuning.minTrackArtistFontSize);
    final artistSize = math.max(
      minArtistFont,
      baseArtistSize * controlsScale,
    );

    final textContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: Align(
            alignment: titleAlignment,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onSecondaryTapDown: (details) {
                _showTrackInfoContextMenu(
                  context,
                  details.globalPosition,
                  target: _TrackInfoMenuTarget.title,
                  currentMusic: currentMusic,
                );
              },
              onLongPressStart: (details) {
                HapticFeedback.mediumImpact();
                _showTrackInfoContextMenu(
                  context,
                  details.globalPosition,
                  target: _TrackInfoMenuTarget.title,
                  currentMusic: currentMusic,
                );
              },
              child: DefaultTextStyle(
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  height: lerpDouble(
                    lerpDouble(1.2, 1.1, transition),
                    lerpDouble(1.2, 1.25, transition),
                    landscapeT,
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    final style = DefaultTextStyle.of(context).style;
                    return MarqueeText(
                      text: title,
                      style: style,
                      alignment: titleAlignment,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (showArtistAlbum)
          Padding(
            padding: EdgeInsets.only(
              top: lerpDouble(
                6.0,
                PlaybackHeroCardUiTuning.trackInfoLandscapeLyricsGap,
                simplifiedT,
              )!,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Align(
                alignment: titleAlignment,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onSecondaryTapDown: (details) {
                    _showTrackInfoContextMenu(
                      context,
                      details.globalPosition,
                      target: _TrackInfoMenuTarget.artistAlbum,
                      currentMusic: currentMusic,
                    );
                  },
                  onLongPressStart: (details) {
                    HapticFeedback.mediumImpact();
                    _showTrackInfoContextMenu(
                      context,
                      details.globalPosition,
                      target: _TrackInfoMenuTarget.artistAlbum,
                      currentMusic: currentMusic,
                    );
                  },
                  child: DefaultTextStyle(
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white70,
                      fontSize: artistSize,
                      height: lerpDouble(
                        lerpDouble(1.3, 1.1, transition),
                        lerpDouble(1.3, 1.25, transition),
                        landscapeT,
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        final style = DefaultTextStyle.of(context).style;
                        return MarqueeText(
                          text: hasArtist && hasAlbum
                              ? '$rawArtist — $rawAlbum'
                              : (hasArtist
                                    ? rawArtist
                                    : (hasAlbum ? rawAlbum : l10n.unknown)),
                          style: style,
                          alignment: titleAlignment,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (rightButtonsFactor > 0.0) {
      final playlistService = ref.watch(playlistServiceProvider);
      final isFavorite =
          currentMusic != null && playlistService.isFavoriteSong(currentMusic);
      final isRandomMode = ref.watch(audioIsRandomModeProvider);
      final sleepTimerRemaining = ref.watch(audioSleepTimerRemainingProvider);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: textContent),
          SizedBox(width: 8 * buttonControlsScale * rightButtonsFactor),
          if (sleepTimerRemaining != null) ...[
            Opacity(
              opacity: rightButtonsFactor,
              child: SizedBox(
                width: PlaybackHeroCardUiTuning.lLyricsSleepTimerButtonWidth *
                    buttonControlsScale *
                    rightButtonsFactor,
                height: PlaybackHeroCardUiTuning.lLyricsSleepTimerButtonHeight *
                    buttonControlsScale,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AppTooltip(
                    message: l10n.sleepTimerRemaining(
                      _formatSleepTimer(sleepTimerRemaining),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onSleepTimerTap,
                      child: SizedBox(
                        width: PlaybackHeroCardUiTuning.lLyricsSleepTimerButtonWidth *
                            buttonControlsScale,
                        height: PlaybackHeroCardUiTuning.lLyricsSleepTimerButtonHeight *
                            buttonControlsScale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bedtime_rounded,
                              size: PlaybackHeroCardUiTuning.lLyricsTitleIconSize *
                                  buttonControlsScale,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatSleepTimer(sleepTimerRemaining),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: PlaybackHeroCardUiTuning.lLyricsSleepTimerFontSize *
                                    buttonControlsScale,
                                height: 1.0,
                                fontWeight: FontWeight.w600,
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
            SizedBox(width: 8 * buttonControlsScale * rightButtonsFactor),
          ],
          if (showFavoriteIconButton) ...[
            Opacity(
              opacity: rightButtonsFactor,
              child: SizedBox(
                width: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                    buttonControlsScale *
                    rightButtonsFactor,
                height: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                    buttonControlsScale,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AppTooltip(
                    message: isFavorite
                        ? l10n.removeFromFavorites
                        : l10n.addToFavorites,
                    child: SizedBox(
                      width: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                          buttonControlsScale,
                      height: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                          buttonControlsScale,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: PlaybackHeroCardUiTuning.lLyricsTitleIconSize *
                              buttonControlsScale,
                          color: isFavorite ? Colors.redAccent : Colors.white70,
                        ),
                        onPressed: currentMusic == null
                            ? null
                            : () async {
                                await playlistService.toggleFavoriteSong(
                                  currentMusic,
                                );
                              },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * buttonControlsScale * rightButtonsFactor),
          ],
          Opacity(
            opacity: rightButtonsFactor,
            child: SizedBox(
              width: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                  buttonControlsScale *
                  rightButtonsFactor,
              height: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                  buttonControlsScale,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: PopupMenuButton<String>(
                  tooltip: l10n.more,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.more_horiz,
                    size: PlaybackHeroCardUiTuning.lLyricsTitleIconSize *
                        buttonControlsScale,
                    color: Colors.white70,
                  ),
                  onSelected: (value) async {
                    final audio = ref.read(audioServiceProvider);
                    switch (value) {
                      case 'favorite':
                        if (currentMusic != null) {
                          await playlistService.toggleFavoriteSong(currentMusic);
                        }
                        break;
                      case 'settings':
                        onShowMoreMenu?.call();
                        break;
                      case 'visualizer':
                        onToggleVisualizer?.call();
                        break;
                      case 'random':
                        if (audio.settingsService.randomRange == 1 &&
                            !isRandomMode) {
                          final playlistService = ref.read(
                            playlistServiceProvider,
                          );
                          final List<MusicFile> allSongs = [];
                          final pathSet = <String>{};
                          for (final p in playlistService.playlists) {
                            for (final s in p.songs) {
                              if (pathSet.add(s.path)) allSongs.add(s);
                            }
                          }
                          audio.toggleRandomMode(globalSongs: allSongs);
                        } else {
                          audio.toggleRandomMode();
                        }
                        break;
                      case 'tag':
                        onTagCompletionTap?.call();
                        break;
                      case 'sleep':
                        onSleepTimerTap?.call();
                        break;
                      case 'effects':
                        onEqualizerTap?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    buildContextMenuItem<String>(
                      value: 'favorite',
                      label: isFavorite
                          ? l10n.removeFromFavorites
                          : l10n.addToFavorites,
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      context: context,
                      iconColor: isFavorite ? Colors.redAccent : null,
                    ),
                    buildContextMenuItem<String>(
                      value: 'settings',
                      label: l10n.visualizerSettings,
                      icon: Icons.settings_outlined,
                      context: context,
                    ),
                    buildContextMenuItem<String>(
                      value: 'visualizer',
                      label: l10n.visualizer,
                      icon: showVisualizerToggle
                          ? Icons.analytics
                          : Icons.analytics_outlined,
                      context: context,
                      iconColor: showVisualizerToggle
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    buildContextMenuItem<String>(
                      value: 'random',
                      label: l10n.randomMode,
                      icon: Icons.shuffle_rounded,
                      context: context,
                      iconColor: isRandomMode
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    buildContextMenuItem<String>(
                      value: 'tag',
                      label: l10n.tagCompletion,
                      icon: Icons.auto_fix_high_rounded,
                      context: context,
                      enabled: currentMusic != null,
                    ),
                    buildContextMenuItem<String>(
                      value: 'sleep',
                      label: sleepTimerRemaining != null
                          ? l10n.sleepTimerRemaining(
                              _formatSleepTimer(sleepTimerRemaining),
                            )
                          : l10n.sleepTimer,
                      icon: Icons.bedtime_rounded,
                      context: context,
                      iconColor: sleepTimerRemaining != null
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    buildContextMenuItem<String>(
                      value: 'effects',
                      label: l10n.effects,
                      icon: Icons.tune_rounded,
                      context: context,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return textContent;
  }

  Widget _buildPlaybackControlsWidget(
    BuildContext context,
    WidgetRef ref, {
    required double width,
    required double layoutWidth,
    double controlsScale = 1.0,
    double tLyrics = 0.0,
  }) {
    final playbackMode = ref.watch(audioPlaybackModeProvider);
    final isRandomMode = ref.watch(audioIsRandomModeProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final playlistService = ref.watch(playlistServiceProvider);
    final isFavorite =
        currentMusic != null && playlistService.isFavoriteSong(currentMusic);
    final currentThemeColorsMap = ref.watch(audioCurrentThemeColorsMapProvider);
    final sleepTimerRemaining = ref.watch(audioSleepTimerRemainingProvider);
    final isPlaying = ref.watch(audioIsPlayingProvider);
    final l10n = AppLocalizations.of(context)!;

    final isWaveformEnabled = ref.watch(
      settingsServiceProvider.select((s) => s.isWaveformProgressBarEnabled),
    );

    final size = MediaQuery.of(context).size;
    final settings = ref.read(settingsServiceProvider);
    final bool isSmallWindow = PlaybackPageUiTuning.isSmallWindow(
      size,
      isWaveformEnabled: settings.isWaveformProgressBarEnabled,
      isSmallWindowMode: settings.isSmallWindowMode,
    );
    final bool effectiveIsLandscape = isLandscape && !isSmallWindow;

    final topButtonsCount = 7;
    final topButtonsGaps = topButtonsCount - 1;
    final singleButtonWidth =
        PlaybackHeroCardUiTuning.controlsTopButtonsHeight * controlsScale;
    final gapWidth =
        PlaybackHeroCardUiTuning.topButtonsInnerGap * controlsScale;
    final buttonsRowWidth =
        topButtonsCount * singleButtonWidth + topButtonsGaps * gapWidth;

    // 竖屏模式下如果启用波形进度条，则使用叠层布局 (Overlay layout in portrait if waveform is enabled)
    final useOverlayStyle = !effectiveIsLandscape && isWaveformEnabled;

    final widthFactor = effectiveIsLandscape
        ? (lerpDouble(
            PlaybackHeroCardUiTuning.progressBarWidthFactor,
            1.0,
            tLyrics,
          )!)
        : PlaybackHeroCardUiTuning.portraitProgressBarWidthFactor;

    final unifiedWidth = effectiveIsLandscape
        ? math.max(0.0, lerpDouble(buttonsRowWidth, layoutWidth, tLyrics)!)
        : math.max(0.0, math.min(width - 32.0, buttonsRowWidth * widthFactor));


    final double topButtonsIconSizeScaled =
        PlaybackHeroCardUiTuning.topButtonsIconSize * controlsScale;
    final double topButtonsOverflowOffset =
        ((singleButtonWidth - topButtonsIconSizeScaled) / 2 + 2.0 * controlsScale);
    final double topRowHeight = singleButtonWidth;

    final Widget topButtonsRowInner = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppTooltip(
          message: l10n.more,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: singleButtonWidth,
              height: singleButtonWidth,
            ),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              Icons.more_horiz,
              size:
                  PlaybackHeroCardUiTuning.topButtonsIconSize *
                  controlsScale,
              color: Colors.white70,
            ),
            onPressed: onShowMoreMenu,
          ),
        ),
        AppTooltip(
          message: isFavorite
              ? l10n.removeFromFavorites
              : l10n.addToFavorites,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: singleButtonWidth,
              height: singleButtonWidth,
            ),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size:
                  PlaybackHeroCardUiTuning.topButtonsIconSize *
                  controlsScale,
              color: isFavorite ? Colors.redAccent : Colors.white70,
            ),
            onPressed: currentMusic == null
                ? null
                : () async {
                    final playlistService = ref.read(
                      playlistServiceProvider,
                    );
                    await playlistService.toggleFavoriteSong(currentMusic);
                  },
          ),
        ),
        AppTooltip(
          message: l10n.visualizer,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: singleButtonWidth,
              height: singleButtonWidth,
            ),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              showVisualizerToggle
                  ? Icons.analytics
                  : Icons.analytics_outlined,
              size:
                  PlaybackHeroCardUiTuning.topButtonsIconSize *
                  controlsScale,
              color: showVisualizerToggle
                  ? Colors.white70
                  : Colors.white70.withValues(alpha: 0.6),
            ),
            onPressed: onToggleVisualizer,
          ),
        ),
        AppTooltip(
          message: l10n.randomMode,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: singleButtonWidth,
              height: singleButtonWidth,
            ),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              Icons.shuffle_rounded,
              size:
                  PlaybackHeroCardUiTuning.topButtonsIconSize *
                  controlsScale,
              color: isRandomMode
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white70,
            ),
            onPressed: () {
              final audio = ref.read(audioServiceProvider);
              if (audio.settingsService.randomRange == 1 && !isRandomMode) {
                final playlistService = ref.read(playlistServiceProvider);
                final List<MusicFile> allSongs = [];
                final pathSet = <String>{};
                for (final p in playlistService.playlists) {
                  for (final s in p.songs) {
                    if (pathSet.add(s.path)) allSongs.add(s);
                  }
                }
                audio.toggleRandomMode(globalSongs: allSongs);
              } else {
                audio.toggleRandomMode();
              }
            },
          ),
        ),
        AppTooltip(
          message: l10n.tagCompletion,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: singleButtonWidth,
              height: singleButtonWidth,
            ),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              Icons.auto_fix_high_rounded,
              size:
                  PlaybackHeroCardUiTuning.topButtonsIconSize *
                  controlsScale,
              color: Colors.white70,
            ),
            onPressed: onTagCompletionTap,
            onLongPress: onTagCompletionLongPress,
          ),
        ),
        AppTooltip(
          message: sleepTimerRemaining != null
              ? l10n.sleepTimerRemaining(
                  _formatSleepTimer(sleepTimerRemaining),
                )
              : l10n.sleepTimer,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSleepTimerTap,
            child: Container(
              width:
                  PlaybackHeroCardUiTuning.controlsTopButtonsHeight *
                  controlsScale,
              height:
                  PlaybackHeroCardUiTuning.controlsTopButtonsHeight *
                  controlsScale,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(
                top:
                    (sleepTimerRemaining != null
                        ? (PlaybackHeroCardUiTuning
                                  .controlsTopButtonsHeight -
                              PlaybackHeroCardUiTuning.topButtonsIconSize -
                              12)
                        : (PlaybackHeroCardUiTuning
                                  .controlsTopButtonsHeight -
                              PlaybackHeroCardUiTuning
                                  .topButtonsIconSize)) /
                    2 *
                    controlsScale,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.bedtime_rounded,
                    size:
                        PlaybackHeroCardUiTuning.topButtonsIconSize *
                        controlsScale,
                    color: sleepTimerRemaining != null
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white70,
                  ),
                  if (sleepTimerRemaining != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatSleepTimer(sleepTimerRemaining),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 10 * controlsScale,
                        height: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        AppTooltip(
          message: l10n.effects,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: singleButtonWidth,
              height: singleButtonWidth,
            ),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              Icons.tune_rounded,
              size:
                  PlaybackHeroCardUiTuning.topButtonsIconSize *
                  controlsScale,
              color: Colors.white70,
            ),
            onPressed: onEqualizerTap,
          ),
        ),
      ],
    );

    final topButtonsRow = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PlaybackHeroCardUiTuning.topButtonsHorizontalPadding,
      ),
      child: SizedBox(
        width: unifiedWidth,
        height: topRowHeight,
        child: OverflowBox(
          minWidth: unifiedWidth + topButtonsOverflowOffset * 2,
          maxWidth: unifiedWidth + topButtonsOverflowOffset * 2,
          minHeight: topRowHeight,
          maxHeight: topRowHeight,
          child: topButtonsRowInner,
        ),
      ),
    );

    final controlIconColor =
        currentThemeColorsMap['darkVibrant'] ??
        currentThemeColorsMap['darkMuted'] ??
        Colors.black;

    // 内部辅助组件：构建带背景和阴影的次级控制按钮 (Internal helper: build secondary control)
    Widget buildSecondaryControl({
      required Widget Function(Color color, bool isWhiteBg) iconBuilder,
      required VoidCallback? onPressed,
      VoidCallback? onLongPress,
      required double circleSize,
      String? tooltip,
    }) {
      Widget buttonWidget;
      if (useOverlayStyle) {
        buttonWidget = Container(
          width: circleSize * controlsScale,
          height: circleSize * controlsScale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10 * controlsScale,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: iconBuilder(controlIconColor, true),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        );
      } else {
        // 其他情况一律都是原来的白色图标 (Original white icon style)
        buttonWidget = IconButton(
          constraints: BoxConstraints.tightFor(
            width: circleSize * controlsScale,
            height: circleSize * controlsScale,
          ),
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: iconBuilder(Colors.white, false),
          onPressed: onPressed,
          onLongPress: onLongPress,
        );
      }

      if (tooltip != null && tooltip.isNotEmpty) {
        return AppTooltip(message: tooltip, child: buttonWidget);
      }

      return buttonWidget;
    }

    final mainControlsRowInner = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildSecondaryControl(
          circleSize: (useOverlayStyle ? 42 : 40),
          iconBuilder: (color, isWhiteBg) => Icon(
            getPlaylistModeIcon(playbackMode),
            size: (isWhiteBg ? 22 : 24) * controlsScale,
            color: color,
          ),
          onPressed: onCyclePlaylistMode,
          onLongPress: onShowPlaylistModeSelector,
          tooltip: getPlaylistModeName(playbackMode, l10n),
        ),
        buildSecondaryControl(
          circleSize: (useOverlayStyle ? 56 : 60),
          iconBuilder: (color, isWhiteBg) => Icon(
            Icons.skip_previous_rounded,
            size: (isWhiteBg ? 34 : 52) * controlsScale,
            color: color,
          ),
          onPressed: onPrevious,
          tooltip: l10n.previous,
        ),
        useOverlayStyle
            ? Container(
                width: 72 * controlsScale,
                height: 72 * controlsScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10 * controlsScale,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AnimatedPlayPauseButton(
                  isPlaying: isPlaying,
                  onPressed: onPlayPause,
                  color: controlIconColor,
                  size: 42 * controlsScale,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  tooltip: isPlaying ? l10n.pause : l10n.play,
                ),
              )
            : SizedBox(
                width: 60 * controlsScale,
                height: 60 * controlsScale,
                child: AnimatedPlayPauseButton(
                  isPlaying: isPlaying,
                  onPressed: onPlayPause,
                  color: Colors.white,
                  size: 52 * controlsScale,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  tooltip: isPlaying ? l10n.pause : l10n.play,
                ),
              ),
        buildSecondaryControl(
          circleSize: (useOverlayStyle ? 56 : 60),
          iconBuilder: (color, isWhiteBg) => Icon(
            Icons.skip_next_rounded,
            size: (isWhiteBg ? 34 : 48) * controlsScale,
            color: color,
          ),
          onPressed: onNext,
          tooltip: l10n.next,
        ),
        buildSecondaryControl(
          circleSize: (useOverlayStyle ? 42 : 40),
          iconBuilder: (color, isWhiteBg) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              onVolumeDrag?.call(details.primaryDelta ?? 0);
            },
            child: Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  onVolumeScroll?.call(pointerSignal.scrollDelta.dy);
                }
              },
              child: Icon(
                getVolumeIcon(ref.watch(audioVolumeProvider)),
                size: (isWhiteBg ? 22 : 24) * controlsScale,
                color: color,
              ),
            ),
          ),
          onPressed: onVolumeTap,
          tooltip: l10n.volume,
        ),
      ],
    );

    final double mainControlsOverflowOffset = useOverlayStyle
        ? 12.0 * controlsScale
        : 10.0 * controlsScale;
    final double mainRowHeight = (useOverlayStyle ? 72.0 : 60.0) * controlsScale;
    final Widget mainControlsRow = SizedBox(
      width: unifiedWidth,
      height: mainRowHeight,
      child: OverflowBox(
        minWidth: unifiedWidth + mainControlsOverflowOffset * 2,
        maxWidth: unifiedWidth + mainControlsOverflowOffset * 2,
        minHeight: mainRowHeight,
        maxHeight: mainRowHeight,
        child: mainControlsRowInner,
      ),
    );

    if (useOverlayStyle) {
      return Column(
        key: const ValueKey('overlay_controls_column'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          topButtonsRow,
          const SizedBox(
            height: PlaybackHeroCardUiTuning.waveformStandardTimeRowSpacing,
          ),
          Stack(
            key: const ValueKey('overlay_controls_stack'),
            alignment: Alignment.center,
            children: [
              PlaybackOverlayProgressTimeLayer(
                key: const ValueKey('playback_overlay_progress_time_layer'),
                currentMusic: currentMusic,
                controlsScale: controlsScale,
                totalWidth: width,
                overrideProgress: overrideProgress,
                overridePosition: overridePosition,
                overrideWaveform: overrideWaveform,
                onScrubbing: onScrubbing,
                onSeek: onSeek,
                isLandscape: effectiveIsLandscape,
                playButtonRowWidth: unifiedWidth,
              ),
              // 3. 播放控制按钮叠在上面，不跟随缩放 (Playback controls on top, no scaling)
              mainControlsRow,
            ],
          ),
        ],
      );
    }

    // 默认布局 (Default layout)
    if (effectiveIsLandscape) {
      final shouldCollapse = ref.watch(
        settingsServiceProvider.select(
          (s) => s.collapseButtonsInLandscapeLyrics,
        ),
      );
      final double buttonCollapseT = shouldCollapse ? tLyrics : 0.0;

      return Column(
        key: const ValueKey('default_controls_column'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRect(
            child: Align(
              heightFactor: 1.0 - buttonCollapseT,
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: (1.0 - buttonCollapseT).clamp(0.0, 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    topButtonsRow,
                    SizedBox(
                      height:
                          PlaybackHeroCardUiTuning.controlsRowLandscapeGap *
                          controlsScale,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PlaybackProgressSection(
            key: const ValueKey('playback_progress_section_landscape'),
            currentMusic: currentMusic,
            controlsScale: controlsScale,
            tLyrics: tLyrics,
            isLandscape: effectiveIsLandscape,
            buttonsRowWidth: unifiedWidth,
            overrideProgress: overrideProgress,
            overridePosition: overridePosition,
            overrideWaveform: overrideWaveform,
            onScrubbing: onScrubbing,
            onSeek: onSeek,
          ),
          SizedBox(
            height:
                lerpDouble(
                  PlaybackHeroCardUiTuning.controlsRowLandscapeMainGap,
                  PlaybackHeroCardUiTuning.controlsRowLandscapeGap,
                  tLyrics,
                )! *
                controlsScale,
          ),
          mainControlsRow,
        ],
      );
    }

    // 竖屏非叠加布局 (Portrait non-overlay)
    return Column(
      key: const ValueKey('default_controls_column_portrait'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        topButtonsRow,
        SizedBox(
          height:
              PlaybackHeroCardUiTuning.controlsRowPortraitGap * controlsScale,
        ),
        PlaybackProgressSection(
          key: const ValueKey('playback_progress_section_portrait'),
          currentMusic: currentMusic,
          controlsScale: controlsScale,
          tLyrics: tLyrics,
          isLandscape: effectiveIsLandscape,
          buttonsRowWidth: unifiedWidth,
          overrideProgress: overrideProgress,
          overridePosition: overridePosition,
          overrideWaveform: overrideWaveform,
          onScrubbing: onScrubbing,
          onSeek: onSeek,
        ),
        SizedBox(
          height:
              PlaybackHeroCardUiTuning.controlsRowPortraitGap * controlsScale,
        ),
        mainControlsRow,
      ],
    );
  }
}

class _ZeroPaddingTrackShape extends RoundedRectSliderTrackShape {
  const _ZeroPaddingTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class PlaybackProgressSection extends ConsumerWidget {
  final MusicFile? currentMusic;
  final double controlsScale;
  final double tLyrics;
  final bool isLandscape;
  final double buttonsRowWidth;
  final double? overrideProgress;
  final Duration? overridePosition;
  final List<double>? overrideWaveform;
  final ValueChanged<double>? onScrubbing;
  final ValueChanged<double>? onSeek;

  const PlaybackProgressSection({
    super.key,
    required this.currentMusic,
    required this.controlsScale,
    required this.tLyrics,
    required this.isLandscape,
    required this.buttonsRowWidth,
    this.overrideProgress,
    this.overridePosition,
    this.overrideWaveform,
    this.onScrubbing,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(audioProgressProvider);
    final position = ref.watch(audioPositionProvider);
    final duration = ref.watch(audioDurationProvider);
    final isPlaying = ref.watch(audioIsPlayingProvider);
    final isWaveformEnabled = ref.watch(
      settingsServiceProvider.select((s) => s.isWaveformProgressBarEnabled),
    );
    final currentThemeColorsMap = ref.watch(audioCurrentThemeColorsMapProvider);
    final controlIconColor =
        currentThemeColorsMap['darkVibrant'] ??
        currentThemeColorsMap['darkMuted'] ??
        Colors.black;

    final waveform = overrideWaveform ?? currentMusic?.waveform ?? const [];
    final displayProgress = overrideProgress ?? progress.clamp(0.0, 1.0);

    // Calculate the horizontal padding to align with the outer visual edges of the outermost icons
    // Top button size: 44 * controlsScale, icon size: 22 * controlsScale (margin is 11 * controlsScale)
    // Bottom button size: 40 * controlsScale, icon size: 24 * controlsScale (margin is 8 * controlsScale)
    // We choose 11.0 * controlsScale to align with the visual boundaries of the outermost icons.
    final double horizontalPadding = 0.0;

    Widget buildStandardSlider(
      BuildContext context,
      double displayProgress,
      double controlsScale, {
      bool noPadding = false,
    }) {
      final double pad = noPadding
          ? horizontalPadding
          : PlaybackHeroCardUiTuning.waveformStandardHorizontalPadding;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4 * controlsScale,
            trackShape: isLandscape ? const _ZeroPaddingTrackShape() : null,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 7 * controlsScale,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: 16 * controlsScale,
            ),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: displayProgress.clamp(0.0, 1.0),
            onChanged: onScrubbing,
            onChangeEnd: (value) {
              onSeek?.call(value);
            },
          ),
        ),
      );
    }

    return SizedBox(
      width: buttonsRowWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Builder(
            builder: (context) {
              if (isWaveformEnabled) {
                return Builder(
                  builder: (context) {
                    final size = MediaQuery.of(context).size;
                    final settings = ref.watch(settingsServiceProvider);
                    final isMinimized = ref.watch(isWindowMinimizedProvider);
                    final bool isSmallWindow =
                        PlaybackPageUiTuning.isSmallWindow(
                          size,
                          isWaveformEnabled:
                              settings.isWaveformProgressBarEnabled,
                          isSmallWindowMode: settings.isSmallWindowMode,
                        );
                    final double overflowScale = isLandscape
                        ? 1.0
                        : (isSmallWindow
                              ? 1.0
                              : PlaybackHeroCardUiTuning
                                    .portraitWaveformOverflowScale);

                    final widget = Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: WaveformProgressBar(
                        waveform: waveform,
                        progress: displayProgress,
                        duration: duration,
                        isPlaying: isPlaying,
                        onScrubbing: onScrubbing ?? (_) {},
                        onSeek: onSeek ?? (_) {},
                        isWindowMinimized: isMinimized,
                        height:
                            (isLandscape
                                ? PlaybackHeroCardUiTuning
                                      .waveformLandscapeHeight
                                : PlaybackHeroCardUiTuning
                                      .waveformPortraitLyricsHeight) *
                            controlsScale,
                        barWidth:
                            (isLandscape
                                ? PlaybackHeroCardUiTuning
                                      .waveformBarWidthLandscape
                                : PlaybackHeroCardUiTuning.waveformBarWidth) /
                            overflowScale,
                        barGap:
                            (isLandscape
                                ? PlaybackHeroCardUiTuning
                                      .waveformBarGapLandscape
                                : PlaybackHeroCardUiTuning.waveformBarGap) /
                            overflowScale,
                      ),
                    );

                    if (!isLandscape) {
                      return Transform.scale(
                        scaleX: overflowScale,
                        child: widget,
                      );
                    }
                    return widget;
                  },
                );
              }
              return buildStandardSlider(
                context,
                displayProgress,
                controlsScale,
                noPadding: true,
              );
            },
          ),
          SizedBox(
            height:
                (isLandscape ? PlaybackHeroCardUiTuning.controlsTimeGap : 8.0) *
                controlsScale,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? horizontalPadding : 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isLandscape || !isWaveformEnabled)
                  Text(
                    formatDuration(overridePosition ?? position),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: math.max(
                        PlaybackHeroCardUiTuning.minProgressTimeFontSize,
                        12 * controlsScale,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      formatDuration(overridePosition ?? position),
                      style: TextStyle(
                        color: controlIconColor,
                        fontSize: math.max(
                          PlaybackHeroCardUiTuning.minProgressTimeFontSize,
                          11 * controlsScale,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isLandscape || !isWaveformEnabled)
                  Text(
                    formatDuration(duration),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: math.max(
                        PlaybackHeroCardUiTuning.minProgressTimeFontSize,
                        12 * controlsScale,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      formatDuration(duration),
                      style: TextStyle(
                        color: controlIconColor,
                        fontSize: math.max(
                          PlaybackHeroCardUiTuning.minProgressTimeFontSize,
                          11 * controlsScale,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlaybackOverlayProgressTimeLayer extends ConsumerWidget {
  final MusicFile? currentMusic;
  final double controlsScale;
  final double totalWidth;
  final double? overrideProgress;
  final Duration? overridePosition;
  final List<double>? overrideWaveform;
  final ValueChanged<double>? onScrubbing;
  final ValueChanged<double>? onSeek;
  final bool isLandscape;
  final double? playButtonRowWidth;

  const PlaybackOverlayProgressTimeLayer({
    super.key,
    required this.currentMusic,
    required this.controlsScale,
    required this.totalWidth,
    required this.isLandscape,
    this.overrideProgress,
    this.overridePosition,
    this.overrideWaveform,
    this.onScrubbing,
    this.onSeek,
    this.playButtonRowWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(audioProgressProvider);
    final position = ref.watch(audioPositionProvider);
    final duration = ref.watch(audioDurationProvider);
    final isPlaying = ref.watch(audioIsPlayingProvider);
    final waveform = overrideWaveform ?? currentMusic?.waveform ?? const [];
    final displayProgress = overrideProgress ?? progress.clamp(0.0, 1.0);
    final currentThemeColorsMap = ref.watch(audioCurrentThemeColorsMapProvider);
    final controlIconColor =
        currentThemeColorsMap['darkVibrant'] ??
        currentThemeColorsMap['darkMuted'] ??
        Colors.black;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. 只有波形进度条进行缩放 (Only waveform is scaled)
        Builder(
          builder: (context) {
            final size = MediaQuery.of(context).size;
            final settings = ref.watch(settingsServiceProvider);
            final isMinimized = ref.watch(isWindowMinimizedProvider);
            final bool isSmallWindow = PlaybackPageUiTuning.isSmallWindow(
              size,
              isWaveformEnabled: settings.isWaveformProgressBarEnabled,
              isSmallWindowMode: settings.isSmallWindowMode,
            );
            final double overflowScale = isSmallWindow
                ? 1.0
                : PlaybackHeroCardUiTuning.portraitWaveformOverflowScale;

            return Transform.scale(
              scaleX: overflowScale,
              child: SizedBox(
                width: totalWidth,
                child: WaveformProgressBar(
                  waveform: waveform,
                  progress: displayProgress,
                  duration: duration,
                  isPlaying: isPlaying,
                  onScrubbing: onScrubbing ?? (_) {},
                  onSeek: onSeek ?? (_) {},
                  isWindowMinimized: isMinimized,
                  height:
                      PlaybackHeroCardUiTuning.waveformOverlayHeight *
                      controlsScale,
                  barWidth:
                      (isLandscape
                          ? PlaybackHeroCardUiTuning.waveformBarWidthLandscape
                          : PlaybackHeroCardUiTuning.waveformBarWidth) /
                      overflowScale,
                  barGap:
                      (isLandscape
                          ? PlaybackHeroCardUiTuning.waveformBarGapLandscape
                          : PlaybackHeroCardUiTuning.waveformBarGap) /
                      overflowScale,
                ),
              ),
            );
          },
        ),
        // 2. 时间文字与5按钮行保持完全一致的宽度和居中对齐，确保完美对齐且同步缩放
        Builder(
          builder: (context) {
            final double mainControlsOverflowOffset = 12.0 * controlsScale;
            final double buttonRowActualWidth =
                (playButtonRowWidth ?? totalWidth) +
                mainControlsOverflowOffset * 2;

            return SizedBox(
              width: buttonRowActualWidth,
              height:
                  PlaybackHeroCardUiTuning.waveformOverlayHeight *
                  controlsScale,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    bottom: PlaybackHeroCardUiTuning.waveformOverlayTimeBottom,
                    child: isLandscape
                        ? Text(
                            formatDuration(overridePosition ?? position),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: math.max(
                                PlaybackHeroCardUiTuning
                                    .minProgressTimeFontSize,
                                12 * controlsScale,
                              ),
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(color: Colors.black45, blurRadius: 4),
                              ],
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              formatDuration(overridePosition ?? position),
                              style: TextStyle(
                                color: controlIconColor,
                                fontSize: math.max(
                                  PlaybackHeroCardUiTuning
                                      .minProgressTimeFontSize,
                                  11 * controlsScale,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: PlaybackHeroCardUiTuning.waveformOverlayTimeBottom,
                    child: isLandscape
                        ? Text(
                            formatDuration(duration),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: math.max(
                                PlaybackHeroCardUiTuning
                                    .minProgressTimeFontSize,
                                12 * controlsScale,
                              ),
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(color: Colors.black45, blurRadius: 4),
                              ],
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              formatDuration(duration),
                              style: TextStyle(
                                color: controlIconColor,
                                fontSize: math.max(
                                  PlaybackHeroCardUiTuning
                                      .minProgressTimeFontSize,
                                  11 * controlsScale,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MiniPlayerProgressInfo extends ConsumerStatefulWidget {
  final MusicFile? currentMusic;
  final double progress;
  final ValueChanged<double>? onScrubbing;
  final ValueChanged<double>? onSeek;

  const _MiniPlayerProgressInfo({
    required this.currentMusic,
    required this.progress,
    this.onScrubbing,
    this.onSeek,
  });

  @override
  ConsumerState<_MiniPlayerProgressInfo> createState() =>
      _MiniPlayerProgressInfoState();
}

class _MiniPlayerProgressInfoState
    extends ConsumerState<_MiniPlayerProgressInfo> {
  bool _isHovering = false;
  bool _isDragging = false;
  double? _dragValue;

  bool get _isActive => _isHovering || _isDragging;

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(audioPositionProvider);
    final duration = ref.watch(audioDurationProvider);
    final currentMusic = widget.currentMusic;

    final displayProgress = _isDragging
        ? (_dragValue ?? widget.progress)
        : widget.progress;
    final displayPosition = _isDragging
        ? Duration(
            milliseconds:
                (duration.inMilliseconds * (_dragValue ?? widget.progress))
                    .toInt(),
          )
        : position;

    final subtitle = [
      if (currentMusic?.artist != null && currentMusic!.artist!.isNotEmpty)
        currentMusic.artist,
      if (currentMusic?.album != null && currentMusic!.album!.isNotEmpty)
        currentMusic.album,
    ].join(' - ');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 32,
          child: Stack(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                tween: Tween<double>(begin: 0, end: _isActive ? 5.0 : 0.0),
                builder: (context, blur, child) {
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isActive ? 0.3 : 1.0,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentMusic?.displayName ??
                          AppLocalizations.of(context)!.notSelected,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black87)
                                  .withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (_isActive)
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '${formatDuration(displayPosition)} / ${formatDuration(duration)}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) {
              setState(() {
                _isDragging = true;
                _dragValue = widget.progress;
              });
            },
            onHorizontalDragUpdate: (details) {
              if (!_isDragging) return;
              final RenderBox box = context.findRenderObject() as RenderBox;
              final double localX = details.localPosition.dx;
              final double newProgress = (localX / box.size.width).clamp(
                0.0,
                1.0,
              );
              setState(() {
                _dragValue = newProgress;
              });
              widget.onScrubbing?.call(newProgress);
            },
            onHorizontalDragEnd: (details) {
              if (!_isDragging) return;
              final finalProgress = _dragValue ?? widget.progress;
              setState(() {
                _isDragging = false;
                _dragValue = null;
              });
              widget.onSeek?.call(finalProgress);
            },
            onTapDown: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final double localX = details.localPosition.dx;
              final double newProgress = (localX / box.size.width).clamp(
                0.0,
                1.0,
              );
              widget.onScrubbing?.call(newProgress);
              widget.onSeek?.call(newProgress);
            },
            onTap:
                () {}, // Consume tap to prevent bubbling to parent mini player tap
            child: Container(
              height: 10,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _isActive ? 6 : 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: _isActive ? 6 : 3,
                    value: displayProgress.clamp(0.0, 1.0),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LyricsPanelTransitionWrapper extends StatefulWidget {
  final ValueNotifier<bool> isTransitioning;
  final double lyricsBottomSpacerHeight;
  final double lyricsBottomTabBarHeight;

  const _LyricsPanelTransitionWrapper({
    required this.isTransitioning,
    required this.lyricsBottomSpacerHeight,
    required this.lyricsBottomTabBarHeight,
  });

  @override
  State<_LyricsPanelTransitionWrapper> createState() =>
      _LyricsPanelTransitionWrapperState();
}

class _LyricsPanelTransitionWrapperState
    extends State<_LyricsPanelTransitionWrapper> {
  late bool _isTransitioning;

  @override
  void initState() {
    super.initState();
    _isTransitioning = widget.isTransitioning.value;
    widget.isTransitioning.addListener(_handleTransitionChange);
  }

  @override
  void didUpdateWidget(_LyricsPanelTransitionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isTransitioning != widget.isTransitioning) {
      oldWidget.isTransitioning.removeListener(_handleTransitionChange);
      widget.isTransitioning.addListener(_handleTransitionChange);
      _isTransitioning = widget.isTransitioning.value;
    }
  }

  @override
  void dispose() {
    widget.isTransitioning.removeListener(_handleTransitionChange);
    super.dispose();
  }

  void _handleTransitionChange() {
    if (mounted && _isTransitioning != widget.isTransitioning.value) {
      setState(() {
        _isTransitioning = widget.isTransitioning.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final currentIndex = ref.watch(audioCurrentIndexProvider);
        final currentMusic = ref.watch(audioCurrentMusicProvider);
        final position = ref.watch(audioPositionProvider);
        final currentThemeColorsMap = ref.watch(
          audioCurrentThemeColorsMapProvider,
        );
        final accent =
            currentThemeColorsMap['darkVibrant'] ??
            currentThemeColorsMap['darkMuted'] ??
            Colors.white;

        return LyricsPanel(
          key: ValueKey('$currentIndex:${currentMusic?.path ?? 'no-track'}'),
          lyrics: currentMusic?.lyrics,
          position: position,
          accentColor: accent,
          bottomSpacerHeight: widget.lyricsBottomSpacerHeight,
          bottomTabBarHeight: widget.lyricsBottomTabBarHeight,
          isTransitioning: _isTransitioning,
        );
      },
    );
  }
}
