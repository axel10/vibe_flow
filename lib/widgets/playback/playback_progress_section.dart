import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/utils/playback_utils.dart';
import 'package:vynody/widgets/waveform_progress_bar.dart';
import 'package:vynody/widgets/playback_ui_tuning.dart';
import '../../l10n/app_localizations.dart';

class ZeroPaddingTrackShape extends RoundedRectSliderTrackShape {
  const ZeroPaddingTrackShape();

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
  final bool isTransitioning;
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
    this.isTransitioning = false,
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

    const double horizontalPadding = 0.0;

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
            trackShape: isLandscape ? const ZeroPaddingTrackShape() : null,
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
                      padding: const EdgeInsets.symmetric(
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
                        isTransitioning: isTransitioning,
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
  final bool isTransitioning;
  final double? playButtonRowWidth;

  const PlaybackOverlayProgressTimeLayer({
    super.key,
    required this.currentMusic,
    required this.controlsScale,
    required this.totalWidth,
    required this.isLandscape,
    this.isTransitioning = false,
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
                  isTransitioning: isTransitioning,
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

class MiniPlayerProgressInfo extends ConsumerStatefulWidget {
  final MusicFile? currentMusic;
  final double progress;
  final ValueChanged<double>? onScrubbing;
  final ValueChanged<double>? onSeek;

  const MiniPlayerProgressInfo({
    super.key,
    required this.currentMusic,
    required this.progress,
    this.onScrubbing,
    this.onSeek,
  });

  @override
  ConsumerState<MiniPlayerProgressInfo> createState() =>
      _MiniPlayerProgressInfoState();
}

class _MiniPlayerProgressInfoState
    extends ConsumerState<MiniPlayerProgressInfo> {
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
            onTap: () {},
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
