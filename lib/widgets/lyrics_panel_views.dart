import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vynody/models/lyric_line.dart';
import 'package:vynody/models/music_lyric.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'package:vynody/player/lyrics/lyrics_controller_state.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'playback_ui_tuning.dart';

class LyricsPanelEmptyState extends StatelessWidget {
  const LyricsPanelEmptyState({
    super.key,
    required this.accentColor,
    required this.textColor,
    required this.isLoading,
    required this.isGenerating,
    required this.canGenerateLyrics,
    required this.onGeneratePressed,
    required this.generateButtonLabel,
    required this.onContextMenu,
    required this.bottomSpacerHeight,
    required this.bottomTabBarHeight,
  });

  final Color accentColor;
  final Color textColor;
  final bool isLoading;
  final bool isGenerating;
  final bool canGenerateLyrics;
  final Future<void> Function() onGeneratePressed;
  final String generateButtonLabel;
  final void Function(Offset globalPosition) onContextMenu;
  final double bottomSpacerHeight;
  final double bottomTabBarHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final buttonForegroundColor =
        ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: (details) => onContextMenu(details.globalPosition),
      onLongPressStart: (details) {
        onContextMenu(details.globalPosition);
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading && !isGenerating) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                isLoading ? l10n.searchingLyrics : l10n.noLyrics,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              if (canGenerateLyrics) ...[
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: FilledButton.icon(
                    onPressed: isGenerating ? null : () => onGeneratePressed(),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor.withValues(alpha: 0.95),
                      foregroundColor: buttonForegroundColor,
                      disabledBackgroundColor: accentColor.withValues(alpha: 0.95),
                      disabledForegroundColor: buttonForegroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    icon: isGenerating
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: buttonForegroundColor.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(generateButtonLabel),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LyricsPanelTimedLyricsView extends StatefulWidget {
  const LyricsPanelTimedLyricsView({
    super.key,
    required this.lyrics,
    required this.lyricsState,
    required this.displayLines,
    required this.lineHeights,
    required this.hasTimedLyrics,
    required this.activeIndex,
    required this.isAutoScrollPaused,
    required this.lyricsFontScale,
    required this.scrollController,
    required this.scrollBehavior,
    required this.textColor,
    required this.secondaryTextColor,
    required this.onVerticalDragStart,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
    required this.onVerticalDragCancel,
    required this.onContextMenu,
    required this.bottomSpacerHeight,
    this.bottomTabBarHeight = 0.0,
    required this.lyricsStyle,
    required this.isFocusMode,
    this.onLineTapped,
    required this.scrollDelta,
    required this.scrollTriggerTime,
    required this.isEnteringFocusMode,
    required this.firstVisibleIndex,
    required this.isSmallWin,
    required this.maxWidth,
    required this.isGenerating,
    required this.isTransitioning,
    required this.isLowMidEnd,
  });

  final MusicLyric? lyrics;
  final LyricsControllerState lyricsState;
  final List<LyricLine> displayLines;
  final List<double> lineHeights;
  final bool hasTimedLyrics;
  final int activeIndex;
  final bool isAutoScrollPaused;
  final double lyricsFontScale;
  final ScrollController scrollController;
  final ScrollBehavior scrollBehavior;
  final Color textColor;
  final Color secondaryTextColor;
  final GestureDragStartCallback? onVerticalDragStart;
  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureDragEndCallback? onVerticalDragEnd;
  final VoidCallback? onVerticalDragCancel;
  final void Function(Offset globalPosition) onContextMenu;
  final double bottomSpacerHeight;
  final double bottomTabBarHeight;
  final LyricsStyle lyricsStyle;
  final bool isFocusMode;
  final ValueChanged<int>? onLineTapped;
  final double scrollDelta;
  final int scrollTriggerTime;
  final bool isEnteringFocusMode;
  final int firstVisibleIndex;
  final bool isSmallWin;
  final double maxWidth;
  final bool isGenerating;
  final bool isTransitioning;
  final bool isLowMidEnd;

  @override
  State<LyricsPanelTimedLyricsView> createState() => _LyricsPanelTimedLyricsViewState();
}

class _LyricsPanelTimedLyricsViewState extends State<LyricsPanelTimedLyricsView> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final targetLang = widget.lyricsState.lyricsTranslationLanguageCode;
    final effectiveLang = widget.lyrics?.getEffectiveTranslationLanguage(targetLang) ?? targetLang;
    final isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait) || widget.isSmallWin;
    final isLeftAligned = widget.lyricsStyle == LyricsStyle.apple;
    final isApplePortrait = isPortrait && widget.lyricsStyle == LyricsStyle.apple;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: widget.isAutoScrollPaused || widget.lyricsStyle == LyricsStyle.apple ? null : widget.onVerticalDragStart,
      onVerticalDragUpdate: widget.isAutoScrollPaused || widget.lyricsStyle == LyricsStyle.apple ? null : widget.onVerticalDragUpdate,
      onVerticalDragEnd: widget.isAutoScrollPaused || widget.lyricsStyle == LyricsStyle.apple ? null : widget.onVerticalDragEnd,
      onVerticalDragCancel: widget.isAutoScrollPaused || widget.lyricsStyle == LyricsStyle.apple ? null : widget.onVerticalDragCancel,
      onSecondaryTapDown: (details) => widget.onContextMenu(details.globalPosition),
      onLongPressStart: (details) {
        widget.onContextMenu(details.globalPosition);
      },
      child: Column(
        children: [
          Expanded(
            child: _LyricsFadeShaderMask(
              bottomSpacerHeight: widget.bottomSpacerHeight + widget.bottomTabBarHeight,
              isSmallWin: widget.isSmallWin,
              lyricsFontScale: widget.lyricsFontScale,
              lyricsStyle: widget.lyricsStyle,
              child: ClipRect(
                clipper: const _VerticalOnlyClipper(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewportHeight = constraints.maxHeight;
                    final double extraBottomPadding;
                    if (widget.lyricsStyle == LyricsStyle.apple && widget.lineHeights.isNotEmpty) {
                      final topPadding = PlaybackPageUiTuning.appleLyricsTopPadding(
                        widget.lyricsFontScale,
                        isSmallWin: widget.isSmallWin,
                      );
                      final offset = PlaybackPageUiTuning.appleLyricsScrollOffset(
                        widget.lyricsFontScale,
                        isSmallWin: widget.isSmallWin,
                      );
                      final lastLineHeight = widget.lineHeights.last;
                      extraBottomPadding = math.max(
                        0.0,
                        viewportHeight -
                            topPadding -
                            offset -
                            lastLineHeight -
                            widget.bottomSpacerHeight -
                            widget.bottomTabBarHeight,
                      );
                    } else {
                      extraBottomPadding = widget.lyricsStyle == LyricsStyle.apple
                          ? math.max(500.0, viewportHeight - (isPortrait ? 25.0 : 100.0))
                          : 500.0;
                    }
                    return ScrollConfiguration(
                      behavior: widget.scrollBehavior,
                      child: SingleChildScrollView(
                        controller: widget.scrollController,
                        clipBehavior: Clip.none,
                        physics: widget.hasTimedLyrics
                            ? (widget.isAutoScrollPaused || widget.lyricsStyle == LyricsStyle.apple
                                  ? const BouncingScrollPhysics()
                                  : const NeverScrollableScrollPhysics())
                            : const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                        padding: EdgeInsets.only(
                          top: widget.lyricsStyle == LyricsStyle.apple
                              ? PlaybackPageUiTuning.appleLyricsTopPadding(
                                  widget.lyricsFontScale,
                                  isSmallWin: widget.isSmallWin,
                                )
                              : 0.0,
                          bottom: widget.bottomSpacerHeight + widget.bottomTabBarHeight + extraBottomPadding,
                        ),
                    child: Column(
                      children: List.generate(widget.displayLines.length, (index) {
                        final bool isFar = widget.isTransitioning &&
                            (widget.hasTimedLyrics
                                ? (index - widget.activeIndex).abs() > 8
                                : index > 15);

                        if (isFar) {
                          double itemHeight = 40.0;
                          if (index < widget.lineHeights.length) {
                            itemHeight = widget.lineHeights[index];
                          }
                          return SizedBox(
                            key: ValueKey('lyric_placeholder_$index'),
                            height: itemHeight,
                          );
                        }

                        final line = widget.displayLines[index];
                        final translated =
                            widget.lyrics
                                ?.translatedLineAt(
                                  index,
                                  effectiveLang,
                                )
                                .trim() ??
                            '';
                        final distance = (index - widget.activeIndex).abs();
                        final isActive = widget.hasTimedLyrics && index == widget.activeIndex;
                        final isHovered = _hoveredIndex == index;
                        final isNear =
                            widget.hasTimedLyrics && distance <= 1 && !isActive;
                        final targetScale = isActive && widget.lyricsStyle != LyricsStyle.apple ? 1.12 : 1.0;
                        final timedLyricFontSize = 16 * widget.lyricsFontScale;
                        final plainLyricFontSize = 18 * widget.lyricsFontScale;
                        final translationFontSize = (widget.lyricsStyle == LyricsStyle.apple
                                ? (isPortrait
                                    ? PlaybackPageUiTuning.appleLyricsTranslationFontSizePortrait
                                    : PlaybackPageUiTuning.appleLyricsTranslationFontSizeLandscape)
                                : 13.0) *
                            widget.lyricsFontScale;
                        final basePadding = widget.lyricsStyle == LyricsStyle.apple
                            ? PlaybackPageUiTuning.appleLyricsVerticalPadding
                            : PlaybackPageUiTuning.traditionalLyricsVerticalPadding;
                        final verticalItemPadding = basePadding * widget.lyricsFontScale;
                        final translatedSpacing = 3 * widget.lyricsFontScale;
                        final lineStyle = widget.hasTimedLyrics
                            ? Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: isActive
                                            ? widget.textColor
                                            : (isHovered
                                                ? widget.textColor.withValues(alpha: 1.0)
                                                : widget.textColor.withValues(
                                                    alpha: (isNear && widget.lyricsStyle != LyricsStyle.apple) ? 0.72 : PlaybackPageUiTuning.appleLyricsInactiveOpacity,
                                                  )),
                                fontSize: timedLyricFontSize,
                                fontWeight: (isActive || widget.lyricsStyle == LyricsStyle.apple)
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                height: 1.4,
                                leadingDistribution: TextLeadingDistribution.even,
                              )
                            : TextStyle(
                                color: widget.textColor,
                                fontSize: plainLyricFontSize,
                                fontWeight: widget.lyricsStyle == LyricsStyle.apple
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                height: 1.6,
                                leadingDistribution: TextLeadingDistribution.even,
                              );

                        final double effectiveLeftPadding = isApplePortrait
                            ? (widget.isSmallWin ? 16.0 : 0.0)
                            : 24.0;
                        final double effectiveRightPadding = 24.0;
                        final double layoutMaxWidth = widget.maxWidth - (effectiveLeftPadding + effectiveRightPadding);

                        final animatedScaleChild = AnimatedScale(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          scale: targetScale,
                          alignment: isLeftAligned ? Alignment.centerLeft : Alignment.center,
                          child: SizedBox(
                            width: layoutMaxWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: isLeftAligned ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: isLeftAligned ? MainAxisAlignment.start : MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOutCubic,
                                        style: lineStyle,
                                        textAlign: isLeftAligned ? TextAlign.left : TextAlign.center,
                                        child: (line.words != null && line.words!.isNotEmpty && isActive && widget.lyricsStyle == LyricsStyle.apple)
                                            ? WordWordLyricsWidget(
                                                words: line.words!,
                                                lineStyle: lineStyle,
                                                activeColor: widget.textColor,
                                                inactiveColor: widget.textColor.withValues(alpha: PlaybackPageUiTuning.appleLyricsInactiveOpacity),
                                                isLeftAligned: isLeftAligned,
                                              )
                                            : Text(line.text),
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.hasTimedLyrics &&
                                    translated.isNotEmpty) ...[
                                  SizedBox(height: translatedSpacing),
                                  Padding(
                                    padding: isLeftAligned
                                        ? const EdgeInsets.only(right: 12)
                                        : const EdgeInsets.symmetric(horizontal: 12),
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                      style: TextStyle(
                                        color: (isActive &&
                                                !(widget.lyricsStyle == LyricsStyle.apple &&
                                                    line.words != null &&
                                                    line.words!.isNotEmpty))
                                            ? widget.secondaryTextColor.withValues(alpha: 1.0)
                                            : (isHovered
                                                ? widget.secondaryTextColor.withValues(alpha: 1.0)
                                                : widget.secondaryTextColor),
                                        fontSize: translationFontSize,
                                        fontWeight: (isActive || widget.lyricsStyle == LyricsStyle.apple)
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        height: 1.3,
                                        leadingDistribution:
                                            TextLeadingDistribution.even,
                                      ),
                                      textAlign: isLeftAligned ? TextAlign.left : TextAlign.center,
                                      child: Text(translated),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );

                        final bool shouldBlur = widget.hasTimedLyrics &&
                            widget.lyricsStyle == LyricsStyle.apple &&
                            widget.isFocusMode &&
                            !isActive &&
                            !isHovered &&
                            distance <= 10 &&
                            !widget.isTransitioning;
                        final Widget blurredChild;
                        if (widget.hasTimedLyrics &&
                            widget.lyricsStyle == LyricsStyle.apple &&
                            widget.isFocusMode &&
                            distance <= 12 &&
                            !widget.isTransitioning) {
                          final int diff = index - widget.activeIndex;
                          final double targetBlur = shouldBlur
                              ? (PlaybackPageUiTuning.appleLyricsBaseBlurSigma +
                                      diff * PlaybackPageUiTuning.appleLyricsBlurGradientFactor)
                                  .clamp(
                                  PlaybackPageUiTuning.appleLyricsMinBlurSigma,
                                  PlaybackPageUiTuning.appleLyricsMaxBlurSigma,
                                )
                              : 0.0;
                          blurredChild = TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: targetBlur, end: targetBlur),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            builder: (context, blurSigma, child) {
                              if (blurSigma == 0.0) {
                                return child!;
                              }
                              return ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                                child: child,
                              );
                            },
                            child: animatedScaleChild,
                          );
                        } else {
                          blurredChild = animatedScaleChild;
                        }

                        final lineContent = Padding(
                          padding: EdgeInsets.only(
                            top: verticalItemPadding,
                            bottom: verticalItemPadding,
                            left: effectiveLeftPadding,
                            right: effectiveRightPadding,
                          ),
                          child: Align(
                            alignment: isLeftAligned ? Alignment.centerLeft : Alignment.center,
                            child: blurredChild,
                          ),
                        );

                        final Widget itemWidget;
                        if (widget.onLineTapped != null) {
                          itemWidget = RepaintBoundary(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => widget.onLineTapped!(index),
                              child: lineContent,
                            ),
                          );
                        } else {
                          itemWidget = RepaintBoundary(
                            child: lineContent,
                          );
                        }

                        final wrappedItemWidget = MouseRegion(
                          hitTestBehavior: HitTestBehavior.opaque,
                          cursor: widget.hasTimedLyrics ? SystemMouseCursors.click : MouseCursor.defer,
                          onEnter: (_) {
                            setState(() {
                              _hoveredIndex = index;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              if (_hoveredIndex == index) {
                                _hoveredIndex = null;
                              }
                            });
                          },
                          child: itemWidget,
                        );

                        final Widget resultWidget;
                        final bool isInStaggerRange = widget.lyricsStyle == LyricsStyle.apple &&
                            widget.isFocusMode &&
                            !widget.isGenerating &&
                            index >= widget.firstVisibleIndex - 5 &&
                            index <= widget.firstVisibleIndex + 25;

                        if (isInStaggerRange) {
                          resultWidget = StaggeredAppleLyricsScrollWrapper(
                            index: index,
                            activeIndex: widget.activeIndex,
                            scrollDelta: widget.scrollDelta,
                            scrollTriggerTime: widget.scrollTriggerTime,
                            isEnteringFocusMode: widget.isEnteringFocusMode,
                            firstVisibleIndex: widget.firstVisibleIndex,
                            isTransitioning: widget.isTransitioning,
                            child: wrappedItemWidget,
                          );
                        } else {
                          resultWidget = wrappedItemWidget;
                        }

                        return KeyedSubtree(
                          key: ValueKey('lyric_active_$index'),
                          child: resultWidget,
                        );
                      }),
                    ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalOnlyClipper extends CustomClipper<Rect> {
  const _VerticalOnlyClipper();

  @override
  Rect getClip(Size size) {
    const horizontalInset = 100000.0;
    return Rect.fromLTRB(
      -horizontalInset,
      0,
      size.width + horizontalInset,
      size.height,
    );
  }

  @override
  bool shouldReclip(covariant _VerticalOnlyClipper oldClipper) => false;
}

class _LyricsFadeShaderMask extends StatelessWidget {
  const _LyricsFadeShaderMask({
    required this.bottomSpacerHeight,
    required this.isSmallWin,
    required this.lyricsFontScale,
    required this.lyricsStyle,
    required this.child,
  });

  final double bottomSpacerHeight;
  final bool isSmallWin;
  final double lyricsFontScale;
  final LyricsStyle lyricsStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          final height = bounds.height > 0 ? bounds.height : 1.0;
          if (height <= 1.0) {
            return const LinearGradient(
              colors: [Colors.white, Colors.white],
            ).createShader(bounds);
          }

          final topFadeHeight = lyricsStyle == LyricsStyle.apple
              ? PlaybackPageUiTuning.appleLyricsTopFadeHeight(lyricsFontScale)
              : 30.0;
          final topFadeEnd = (topFadeHeight / height).clamp(0.0, 1.0);

          final isPortrait =
              (MediaQuery.of(context).orientation == Orientation.portrait) || isSmallWin;

          final double bottomFadeEndHeight;
          final double bottomFadeStartHeight;

          if (isPortrait) {
            bottomFadeEndHeight =  20.0;
            bottomFadeStartHeight = 60.0;
          } else {
            bottomFadeEndHeight = 0.0;
            bottomFadeStartHeight = math.max(30.0, bottomSpacerHeight);
          }

          final bottomFadeStart =
              ((bounds.height - bottomFadeStartHeight) / bounds.height)
                  .clamp(0.0, 1.0);
          final bottomFadeEnd =
              ((bounds.height - bottomFadeEndHeight) / bounds.height)
                  .clamp(0.0, 1.0);

          final tEnd = topFadeEnd;
          final bStart = bottomFadeStart.clamp(tEnd, 1.0);
          final bEnd = bottomFadeEnd.clamp(bStart, 1.0);

          // Ensure stops are in increasing order
          final stops = [
            0.0,
            tEnd,
            bStart,
            bEnd,
            1.0,
          ];

          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
              Colors.transparent,
            ],
            stops: stops,
          ).createShader(bounds);
        },
        child: child,
      ),
    );
  }
}

class StaggeredAppleLyricsScrollWrapper extends StatefulWidget {
  final Widget child;
  final int index;
  final int activeIndex;
  final double scrollDelta;
  final int scrollTriggerTime;
  final bool isEnteringFocusMode;
  final int firstVisibleIndex;
  final bool isTransitioning;

  const StaggeredAppleLyricsScrollWrapper({
    super.key,
    required this.child,
    required this.index,
    required this.activeIndex,
    required this.scrollDelta,
    required this.scrollTriggerTime,
    required this.isEnteringFocusMode,
    required this.firstVisibleIndex,
    required this.isTransitioning,
  });

  @override
  State<StaggeredAppleLyricsScrollWrapper> createState() =>
      _StaggeredAppleLyricsScrollWrapperState();
}

class _StaggeredAppleLyricsScrollWrapperState
    extends State<StaggeredAppleLyricsScrollWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _startOffset = 0.0;
  double _currentOffset = 0.0;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    final double maxDelta = widget.isEnteringFocusMode ? 1200.0 : 300.0;
    final timePassed = DateTime.now().millisecondsSinceEpoch - widget.scrollTriggerTime;
    if (widget.scrollTriggerTime > 0 &&
        !widget.isTransitioning &&
        timePassed < 700 &&
        widget.scrollDelta.abs() <= maxDelta) {
      _startOffset = widget.scrollDelta;
      _currentOffset = widget.scrollDelta;

      final int delayMs;
      if (widget.isEnteringFocusMode) {
        delayMs = math.min(350, math.max(0, widget.index - widget.firstVisibleIndex) * 15);
      } else {
        if (widget.index > widget.activeIndex) {
          delayMs = math.min(300, (widget.index - widget.activeIndex) * 24);
        } else if (widget.index < widget.activeIndex) {
          delayMs = math.min(120, (widget.activeIndex - widget.index) * 12);
        } else {
          delayMs = 0;
        }
      }

      if (delayMs == 0) {
        _controller.forward(from: 0.0);
      } else {
        _delayTimer = Timer(Duration(milliseconds: delayMs), () {
          if (mounted) {
            _controller.forward(from: 0.0);
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(StaggeredAppleLyricsScrollWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    final double maxDelta = widget.isEnteringFocusMode ? 1200.0 : 300.0;
    if (widget.isTransitioning ||
        widget.scrollTriggerTime <= 0 ||
        widget.scrollDelta.abs() > maxDelta) {
      _delayTimer?.cancel();
      _controller.stop();
      _currentOffset = 0.0;
      _startOffset = 0.0;
      return;
    }

    if (widget.scrollTriggerTime != oldWidget.scrollTriggerTime &&
        widget.scrollTriggerTime > 0) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _delayTimer?.cancel();
    _controller.stop();

    final double maxDelta = widget.isEnteringFocusMode ? 1200.0 : 300.0;
    if (widget.scrollDelta.abs() > maxDelta || widget.scrollTriggerTime <= 0) {
      _currentOffset = 0.0;
      _startOffset = 0.0;
      return;
    }

    final int delayMs;
    if (widget.isEnteringFocusMode) {
      delayMs = math.min(350, math.max(0, widget.index - widget.firstVisibleIndex) * 15);
    } else {
      if (widget.index > widget.activeIndex) {
        delayMs = math.min(300, (widget.index - widget.activeIndex) * 24);
      } else if (widget.index < widget.activeIndex) {
        delayMs = math.min(120, (widget.activeIndex - widget.index) * 12);
      } else {
        delayMs = 0;
      }
    }
    
    _startOffset = widget.scrollDelta + _currentOffset;

    if (delayMs == 0) {
      _controller.forward(from: 0.0);
    } else {
      _delayTimer = Timer(Duration(milliseconds: delayMs), () {
        if (mounted) {
          _controller.forward(from: 0.0);
        }
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        if (widget.isTransitioning) {
          return child!;
        }

        if (_controller.isAnimating) {
          _currentOffset = _startOffset * (1.0 - _animation.value);
        } else if (_delayTimer?.isActive ?? false) {
          _currentOffset = _startOffset;
        } else {
          _currentOffset = 0.0;
        }

        return Transform.translate(
          offset: Offset(0.0, _currentOffset),
          child: child,
        );
      },
    );
  }
}

class WordWordLyricsWidget extends ConsumerStatefulWidget {
  const WordWordLyricsWidget({
    super.key,
    required this.words,
    required this.lineStyle,
    required this.activeColor,
    required this.inactiveColor,
    required this.isLeftAligned,
  });

  final List<LyricWord> words;
  final TextStyle lineStyle;
  final Color activeColor;
  final Color inactiveColor;
  final bool isLeftAligned;

  @override
  ConsumerState<WordWordLyricsWidget> createState() => _WordWordLyricsWidgetState();
}

class _WordWordLyricsWidgetState extends ConsumerState<WordWordLyricsWidget> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastObservedPosition = Duration.zero;
  DateTime _lastObservedAt = DateTime.now();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted && _isPlaying) {
        setState(() {});
      }
    });
  }

  void _updateTickerState() {
    if (_isPlaying) {
      if (!_ticker.isActive) {
        _ticker.start();
      }
    } else {
      if (_ticker.isActive) {
        _ticker.stop();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(audioPositionProvider);
    final isPlaying = ref.watch(audioIsPlayingProvider);

    if (position != _lastObservedPosition || isPlaying != _isPlaying) {
      _lastObservedPosition = position;
      _lastObservedAt = DateTime.now();
      _isPlaying = isPlaying;
      _updateTickerState();
    }

    final Duration currentPosition;
    if (_isPlaying) {
      final elapsed = DateTime.now().difference(_lastObservedAt);
      currentPosition = _lastObservedPosition + elapsed;
    } else {
      currentPosition = _lastObservedPosition;
    }

    return Wrap(
      alignment: widget.isLeftAligned ? WrapAlignment.start : WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: widget.words.map((word) {
        final startMs = word.timestamp.inMilliseconds;
        final durationMs = word.durationMs;
        final currentMs = currentPosition.inMilliseconds;

        double progress = 0.0;
        if (currentMs >= startMs + durationMs) {
          progress = 1.0;
        } else if (currentMs >= startMs && durationMs > 0) {
          progress = (currentMs - startMs) / durationMs;
        }

        return WordHighlightText(
          text: word.text,
          progress: progress,
          style: widget.lineStyle,
          activeColor: widget.activeColor,
          inactiveColor: widget.inactiveColor,
        );
      }).toList(),
    );
  }
}

class WordHighlightText extends StatelessWidget {
  const WordHighlightText({
    super.key,
    required this.text,
    required this.progress,
    required this.style,
    required this.activeColor,
    required this.inactiveColor,
  });

  final String text;
  final double progress;
  final TextStyle style;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0.0) {
      return Text(
        text,
        style: style.copyWith(color: inactiveColor),
      );
    }
    if (progress >= 1.0) {
      return Text(
        text,
        style: style.copyWith(color: activeColor),
      );
    }

    // Smooth transition from left to right with a soft edge
    final double softEdge = 0.15;
    final double start = (progress - softEdge).clamp(0.0, 1.0);
    final double end = (progress + softEdge).clamp(0.0, 1.0);

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [activeColor, activeColor, inactiveColor, inactiveColor],
          stops: [0.0, start, end, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
