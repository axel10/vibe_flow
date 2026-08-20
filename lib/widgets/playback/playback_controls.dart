import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/utils/playback_utils.dart';
import 'package:vynody/widgets/animated_play_pause_button.dart';
import 'package:vynody/widgets/app_tooltip.dart';
import 'package:vynody/widgets/playback_ui_tuning.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'playback_progress_section.dart';
import '../../l10n/app_localizations.dart';

class PlaybackControls extends ConsumerWidget {
  final double width;
  final double layoutWidth;
  final double controlsScale;
  final double tLyrics;
  final bool isLandscape;
  final bool isTransitioning;
  final bool showVisualizerToggle;
  final double? overrideProgress;
  final Duration? overridePosition;
  final List<double>? overrideWaveform;
  final VoidCallback? onShowMoreMenu;
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
  final ValueChanged<double>? onVolumeDrag;
  final ValueChanged<double>? onVolumeScroll;

  const PlaybackControls({
    super.key,
    required this.width,
    required this.layoutWidth,
    this.controlsScale = 1.0,
    this.tLyrics = 0.0,
    required this.isLandscape,
    this.isTransitioning = false,
    this.showVisualizerToggle = true,
    this.overrideProgress,
    this.overridePosition,
    this.overrideWaveform,
    this.onShowMoreMenu,
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
    this.onVolumeDrag,
    this.onVolumeScroll,
  });

  static String _formatSleepTimer(Duration duration) {
    final safe = duration < Duration.zero ? Duration.zero : duration;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final isWaveformEnabled = ref.watch(isEffectiveWaveformEnabledProvider);

    final size = MediaQuery.of(context).size;
    final settings = ref.read(settingsServiceProvider);
    final bool isSmallWindow = PlaybackPageUiTuning.isSmallWindow(
      size,
      isWaveformEnabled: isWaveformEnabled,
      isSmallWindowMode: settings.isSmallWindowMode,
    );
    final bool effectiveIsLandscape = isLandscape && !isSmallWindow;

    const topButtonsCount = 7;
    const topButtonsGaps = topButtonsCount - 1;
    final singleButtonWidth =
        PlaybackHeroCardUiTuning.controlsTopButtonsHeight * controlsScale;
    final gapWidth =
        PlaybackHeroCardUiTuning.topButtonsInnerGap * controlsScale;
    final buttonsRowWidth =
        topButtonsCount * singleButtonWidth + topButtonsGaps * gapWidth;

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

    final topButtonsOrder = ref.watch(
      settingsServiceProvider.select((s) => s.topButtonsOrder),
    );
    final mainControlsLeftKey = ref.watch(
      settingsServiceProvider.select((s) => s.mainControlsLeftButton),
    );
    final mainControlsRightKey = ref.watch(
      settingsServiceProvider.select((s) => s.mainControlsRightButton),
    );

    Widget buildTopRowButtonByKey(String key) {
      switch (key) {
        case 'more':
          return AppTooltip(
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
                size: PlaybackHeroCardUiTuning.topButtonsIconSize * controlsScale,
                color: Colors.white70,
              ),
              onPressed: onShowMoreMenu,
            ),
          );
        case 'favorite':
          return AppTooltip(
            message: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
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
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: PlaybackHeroCardUiTuning.topButtonsIconSize * controlsScale,
                color: isFavorite ? Colors.redAccent : Colors.white70,
              ),
              onPressed: currentMusic == null
                  ? null
                  : () async {
                      final playlistService = ref.read(playlistServiceProvider);
                      await playlistService.toggleFavoriteSong(currentMusic);
                    },
            ),
          );
        case 'playlist_mode':
          return AppTooltip(
            message: getPlaylistModeName(playbackMode, l10n),
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
                getPlaylistModeIcon(playbackMode),
                size: PlaybackHeroCardUiTuning.topButtonsIconSize * controlsScale,
                color: Colors.white70,
              ),
              onPressed: onCyclePlaylistMode,
              onLongPress: onShowPlaylistModeSelector,
            ),
          );
        case 'shuffle':
          return AppTooltip(
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
                size: PlaybackHeroCardUiTuning.topButtonsIconSize * controlsScale,
                color: isRandomMode ? Theme.of(context).colorScheme.primary : Colors.white70,
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
          );
        case 'tag_completion':
          return AppTooltip(
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
                size: PlaybackHeroCardUiTuning.topButtonsIconSize * controlsScale,
                color: Colors.white70,
              ),
              onPressed: onTagCompletionTap,
              onLongPress: onTagCompletionLongPress,
            ),
          );
        case 'sleep_timer':
          return AppTooltip(
            message: sleepTimerRemaining != null
                ? l10n.sleepTimerRemaining(_formatSleepTimer(sleepTimerRemaining))
                : l10n.sleepTimer,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSleepTimerTap,
              child: Container(
                width: PlaybackHeroCardUiTuning.controlsTopButtonsHeight * controlsScale,
                height: PlaybackHeroCardUiTuning.controlsTopButtonsHeight * controlsScale,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(
                  top: (sleepTimerRemaining != null
                          ? (PlaybackHeroCardUiTuning.controlsTopButtonsHeight -
                              PlaybackHeroCardUiTuning.topButtonsIconSize - 12)
                          : (PlaybackHeroCardUiTuning.controlsTopButtonsHeight -
                              PlaybackHeroCardUiTuning.topButtonsIconSize)) /
                      2 *
                      controlsScale,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.bedtime_rounded,
                      size: PlaybackHeroCardUiTuning.topButtonsIconSize * controlsScale,
                      color: sleepTimerRemaining != null
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white70,
                    ),
                    if (sleepTimerRemaining != null) ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.0 * controlsScale,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatSleepTimer(sleepTimerRemaining),
                            maxLines: 1,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 10 * controlsScale,
                              height: 1.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        case 'equalizer':
          return AppTooltip(
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
                size: PlaybackHeroCardUiTuning.topButtonsIconSize * controlsScale,
                color: Colors.white70,
              ),
              onPressed: onEqualizerTap,
            ),
          );
        case 'visualizer':
          return AppTooltip(
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
                showVisualizerToggle ? Icons.analytics : Icons.analytics_outlined,
                size: PlaybackHeroCardUiTuning.topButtonsIconSize * controlsScale,
                color: showVisualizerToggle ? Theme.of(context).colorScheme.primary : Colors.white70,
              ),
              onPressed: onToggleVisualizer,
            ),
          );
        case 'volume':
          final volume = ref.watch(audioVolumeProvider);
          return AppTooltip(
            message: l10n.volume,
            child: GestureDetector(
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
                    getVolumeIcon(volume, isMuted: ref.watch(audioIsMutedProvider)),
                    size: PlaybackHeroCardUiTuning.topButtonsIconSize * controlsScale,
                    color: Colors.white70,
                  ),
                  onPressed: onVolumeTap,
                ),
              ),
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    }

    final Widget topButtonsRowInner = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: topButtonsOrder.map((key) => buildTopRowButtonByKey(key)).toList(),
    );

    final topButtonsRow = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PlaybackHeroCardUiTuning.topButtonsHorizontalPadding,
      ),
      child: SizedBox(
        width: unifiedWidth,
        height: topRowHeight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: math.max(unifiedWidth, buttonsRowWidth),
            height: topRowHeight,
            child: OverflowBox(
              minWidth: math.max(unifiedWidth, buttonsRowWidth) + topButtonsOverflowOffset * 2,
              maxWidth: math.max(unifiedWidth, buttonsRowWidth) + topButtonsOverflowOffset * 2,
              minHeight: topRowHeight,
              maxHeight: topRowHeight,
              child: topButtonsRowInner,
            ),
          ),
        ),
      ),
    );

    final controlIconColor =
        currentThemeColorsMap['darkVibrant'] ??
        currentThemeColorsMap['darkMuted'] ??
        Colors.black;

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

    Widget buildSecondaryControlByKey(String key) {
      switch (key) {
        case 'visualizer':
          return buildSecondaryControl(
            circleSize: (useOverlayStyle ? 42 : 40),
            iconBuilder: (color, isWhiteBg) => Icon(
              showVisualizerToggle
                  ? Icons.analytics
                  : Icons.analytics_outlined,
              size: (isWhiteBg ? 22 : 24) * controlsScale,
              color: showVisualizerToggle
                  ? color
                  : color.withValues(alpha: 0.6),
            ),
            onPressed: onToggleVisualizer,
            tooltip: l10n.visualizer,
          );
        case 'volume':
          final volumeButton = buildSecondaryControl(
            circleSize: (useOverlayStyle ? 42 : 40),
            iconBuilder: (color, isWhiteBg) => Icon(
              getVolumeIcon(
                ref.watch(audioVolumeProvider),
                isMuted: ref.watch(audioIsMutedProvider),
              ),
              size: (isWhiteBg ? 22 : 24) * controlsScale,
              color: color,
            ),
            onPressed: onVolumeTap,
            tooltip: l10n.volume,
          );
          return GestureDetector(
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
              child: volumeButton,
            ),
          );
        case 'more':
          return buildSecondaryControl(
            circleSize: (useOverlayStyle ? 42 : 40),
            iconBuilder: (color, isWhiteBg) => Icon(
              Icons.more_horiz,
              size: (isWhiteBg ? 22 : 24) * controlsScale,
              color: color,
            ),
            onPressed: onShowMoreMenu,
            tooltip: l10n.more,
          );
        case 'favorite':
          return buildSecondaryControl(
            circleSize: (useOverlayStyle ? 42 : 40),
            iconBuilder: (color, isWhiteBg) => Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: (isWhiteBg ? 22 : 24) * controlsScale,
              color: isFavorite ? Colors.redAccent : color,
            ),
            onPressed: currentMusic == null
                ? null
                : () async {
                    final playlistService = ref.read(playlistServiceProvider);
                    await playlistService.toggleFavoriteSong(currentMusic);
                  },
            tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
          );
        case 'playlist_mode':
          return buildSecondaryControl(
            circleSize: (useOverlayStyle ? 42 : 40),
            iconBuilder: (color, isWhiteBg) => Icon(
              getPlaylistModeIcon(playbackMode),
              size: (isWhiteBg ? 22 : 24) * controlsScale,
              color: color,
            ),
            onPressed: onCyclePlaylistMode,
            onLongPress: onShowPlaylistModeSelector,
            tooltip: getPlaylistModeName(playbackMode, l10n),
          );
        case 'shuffle':
          return buildSecondaryControl(
            circleSize: (useOverlayStyle ? 42 : 40),
            iconBuilder: (color, isWhiteBg) => Icon(
              Icons.shuffle_rounded,
              size: (isWhiteBg ? 22 : 24) * controlsScale,
              color: isRandomMode
                  ? (isWhiteBg ? color : Theme.of(context).colorScheme.primary)
                  : color,
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
            tooltip: l10n.randomMode,
          );
        case 'tag_completion':
          return buildSecondaryControl(
            circleSize: (useOverlayStyle ? 42 : 40),
            iconBuilder: (color, isWhiteBg) => Icon(
              Icons.auto_fix_high_rounded,
              size: (isWhiteBg ? 22 : 24) * controlsScale,
              color: color,
            ),
            onPressed: onTagCompletionTap,
            onLongPress: onTagCompletionLongPress,
            tooltip: l10n.tagCompletion,
          );
        case 'sleep_timer':
          return buildSecondaryControl(
            circleSize: (useOverlayStyle ? 42 : 40),
            iconBuilder: (color, isWhiteBg) => Icon(
              Icons.bedtime_rounded,
              size: (isWhiteBg ? 22 : 24) * controlsScale,
              color: sleepTimerRemaining != null
                  ? (isWhiteBg ? color : Theme.of(context).colorScheme.primary)
                  : color,
            ),
            onPressed: onSleepTimerTap,
            tooltip: sleepTimerRemaining != null
                ? l10n.sleepTimerRemaining(_formatSleepTimer(sleepTimerRemaining))
                : l10n.sleepTimer,
          );
        case 'equalizer':
          return buildSecondaryControl(
            circleSize: (useOverlayStyle ? 42 : 40),
            iconBuilder: (color, isWhiteBg) => Icon(
              Icons.tune_rounded,
              size: (isWhiteBg ? 22 : 24) * controlsScale,
              color: color,
            ),
            onPressed: onEqualizerTap,
            tooltip: l10n.effects,
          );
        default:
          return buildSecondaryControl(
            circleSize: (useOverlayStyle ? 42 : 40),
            iconBuilder: (color, isWhiteBg) => Icon(
              showVisualizerToggle ? Icons.analytics : Icons.analytics_outlined,
              size: (isWhiteBg ? 22 : 24) * controlsScale,
              color: color,
            ),
            onPressed: onToggleVisualizer,
            tooltip: l10n.visualizer,
          );
      }
    }

    final mainControlsRowInner = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildSecondaryControlByKey(mainControlsLeftKey),
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
        buildSecondaryControlByKey(mainControlsRightKey),
      ],
    );

    final double mainControlsOverflowOffset = useOverlayStyle
        ? 12.0 * controlsScale
        : 10.0 * controlsScale;
    final double mainRowHeight = (useOverlayStyle ? 72.0 : 60.0) * controlsScale;
    final double minMainRowWidth = (useOverlayStyle ? 268.0 : 260.0) * controlsScale;
    final Widget mainControlsRow = SizedBox(
      width: unifiedWidth,
      height: mainRowHeight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: math.max(unifiedWidth, minMainRowWidth),
          height: mainRowHeight,
          child: OverflowBox(
            minWidth: math.max(unifiedWidth, minMainRowWidth) + mainControlsOverflowOffset * 2,
            maxWidth: math.max(unifiedWidth, minMainRowWidth) + mainControlsOverflowOffset * 2,
            minHeight: mainRowHeight,
            maxHeight: mainRowHeight,
            child: mainControlsRowInner,
          ),
        ),
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
                isTransitioning: isTransitioning,
                playButtonRowWidth: unifiedWidth,
              ),
              mainControlsRow,
            ],
          ),
        ],
      );
    }

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
            isTransitioning: isTransitioning,
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
          isTransitioning: isTransitioning,
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
