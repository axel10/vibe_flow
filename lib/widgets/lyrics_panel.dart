import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rpod;
import 'package:oktoast/oktoast.dart';

import 'package:vynody/models/lyric_line.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_lyric.dart';
import '../l10n/app_localizations.dart';
import '../dialogs/ai_guide_dialog.dart';
import '../dialogs/manual_lyrics_dialog.dart';
import '../dialogs/online_lyrics_search_dialog.dart';
import '../dialogs/timeline_adjustment_dialog.dart';
import '../dialogs/lyrics_font_scale_dialog.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/lyrics/lyrics_controller.dart';
import 'package:vynody/player/lyrics/lyrics_controller_state.dart';
import 'package:vynody/player/lyrics/lyrics_riverpod.dart';
import 'package:vynody/player/lyrics/lyrics_song_task_state.dart';
import 'lyrics_panel_toasts.dart';
import 'lyrics_panel_views.dart';
import 'playback_ui_tuning.dart';
import 'app_context_menu.dart';
import '../utils/song_context_menu_utils.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/pro/pro_models.dart';
import 'package:vynody/player/settings/settings_service.dart';

bool shouldShowGenerateLyricsButton({required bool hasCurrentSong}) {
  return hasCurrentSong;
}

double? calculateLyricTopOffsetFromPanelTop({
  required List<double> lineHeights,
  required List<double> lineCenters,
  required int lineIndex,
  required double scrollOffset,
  double scale = 1.0,
}) {
  if (lineIndex < 0 ||
      lineIndex >= lineHeights.length ||
      lineIndex >= lineCenters.length) {
    return null;
  }

  final lineHeight = lineHeights[lineIndex];
  final contentTop = lineCenters[lineIndex] - lineHeight / 2;
  final scaledTopAdjustment = (lineHeight * scale - lineHeight) / 2;
  return contentTop - scrollOffset - scaledTopAdjustment;
}

class LyricsPanel extends rpod.ConsumerStatefulWidget {
  const LyricsPanel({
    super.key,
    required this.lyrics,
    required this.position,
    this.accentColor,
    this.textColor,
    this.secondaryTextColor,
    this.bottomSpacerHeight = 0.0,
    this.bottomTabBarHeight = 0.0,
    this.onActiveLyricTopChanged,
    this.isTransitioning = false,
  });

  final MusicLyric? lyrics;
  final Duration position;
  final Color? accentColor;
  final Color? textColor;
  final Color? secondaryTextColor;
  final double bottomSpacerHeight;
  final double bottomTabBarHeight;
  final ValueChanged<double?>? onActiveLyricTopChanged;
  final bool isTransitioning;

  @override
  rpod.ConsumerState<LyricsPanel> createState() => _LyricsPanelState();
}

class _LyricsPanelState extends rpod.ConsumerState<LyricsPanel> {
  static const double _lyricsDragSeekThreshold = 24.0;
  static const int _lyricsActiveLineSeekEpsilonMilliseconds = 120;
  static const double _timelineOffsetMinSeconds = -10.0;
  static const double _timelineOffsetMaxSeconds = 10.0;
  static const double _seekToastTopOffset = 88.0;
  static const Duration _seekToastAutoDismissDelay = Duration(
    milliseconds: 1200,
  );
  static const Duration _seekToastAnimationDuration = Duration(
    milliseconds: 160,
  );
  final ScrollController _scrollController = ScrollController();
  int _lastActiveIndex = -1;
  bool _isAutoScrollPaused = false;
  bool _isDraggingLyrics = false;
  double _timelineOffsetSeconds = 0.0;
  double _dragDistancePixels = 0.0;
  double _dragTravelPixels = 0.0;
  int? _dragStartLine;
  int? _dragCurrentLine;
  int _lastDebugActiveIndex = -1;
  int _lastDebugPositionMs = -1;
  DateTime _lastDebugLogAt = DateTime.fromMillisecondsSinceEpoch(0);
  ToastFuture? _seekToast;
  ValueNotifier<({Duration target, String timeLabel})>? _seekToastStateNotifier;
  String? _seekToastSignature;
  Timer? _seekToastAutoDismissTimer;
  double? _lastReportedActiveLyricTopOffset;
  ScrollPosition? _attachedScrollPosition;
  int _lastLayoutRevision = 0;
  List<double>? _oldItemCenters;
  List<double>? _oldLineHeights;
  bool _isFocusMode = true;
  int _activePointers = 0;
  int? _overrideActiveIndex;
  Duration? _seekTargetTimestamp;
  DateTime _seekSetTime = DateTime.fromMillisecondsSinceEpoch(0);
  List<double> _currentItemCenters = const [];
  List<double> _currentLineHeights = const [];
  LyricsStyle? _lastBuiltLyricsStyle;
  bool? _lastBuiltIsFocusMode;
  double _lastScrollDelta = 0.0;
  int _scrollTriggerTime = 0;
  int? _lastBuiltScrollTriggerTime;
  bool _enteringFocusModeTriggered = false;
  bool _isEnteringFocusMode = false;
  int _firstVisibleIndex = 0;
  int? _lastBuiltFirstVisibleIndex;
  bool? _lastBuiltIsEnteringFocusMode;
  bool? _lastBuiltIsSmallWin;
  bool? _lastBuiltIsGenerating;
  bool? _lastBuiltIsTransitioning;
  bool? _lastBuiltIsLowMidEnd;

  List<LyricLine>? _lastMeasuredLines;
  MusicLyric? _lastMeasuredLyrics;
  double? _lastMeasuredMaxWidth;
  double? _lastMeasuredFontScale;
  bool? _lastMeasuredHasTimedLyrics;
  LyricsStyle? _lastMeasuredLyricsStyle;
  String? _lastMeasuredLang;
  ({List<double> heights, List<double> itemCenters, List<double> anchorCenters})? _cachedLineMetrics;

  Widget? _cachedLyricsView;
  int? _lastBuiltActiveIndex;
  List<LyricLine>? _lastBuiltDisplayLines;
  double? _lastBuiltMaxWidth;
  double? _lastBuiltMaxHeight;
  double? _lastBuiltFontScale;
  bool? _lastBuiltAutoScrollPaused;
  Color? _lastBuiltTextColor;
  Color? _lastBuiltSecondaryTextColor;
  LyricsControllerState? _lastBuiltLyricsState;
  MusicFile? _lastBuiltCurrentSong;

  LyricsController get _lyricsControllerActions =>
      ref.read(lyricsControllerProvider.notifier);

  MusicLyric? _lyricsForDisplay() {
    return _lyricsControllerActions.currentLyricsForCurrentSong() ??
        widget.lyrics;
  }

  List<LyricLine> _displayLinesForLyrics(
    LyricsControllerState lyricsState,
    MusicLyric? baseLyrics,
  ) {
    if (lyricsState.currentLyricsLines.isNotEmpty) {
      return lyricsState.currentLyricsLines;
    }
    return baseLyrics?.syncedLines ?? const [];
  }

  MusicLyric? _displayLyrics(
    LyricsControllerState lyricsState,
    MusicLyric? baseLyrics,
  ) {
    final normalizedLiveText = lyricsState.currentLyricsText.trim();
    if (normalizedLiveText.isEmpty) {
      return baseLyrics;
    }

    return baseLyrics?.copyWith(
      syncedLines: _displayLinesForLyrics(lyricsState, baseLyrics),
      plainText: normalizedLiveText,
    );
  }

  LyricsSongTaskState _taskStateForSongPath(String? songPath) {
    if (songPath == null || songPath.isEmpty) {
      return const LyricsSongTaskState();
    }
    return _lyricsControllerActions.taskStateForSong(songPath);
  }

  List<LyricLine> _plainLyricsLines(String plainLyrics) {
    final normalized = plainLyrics.trim();
    if (normalized.isEmpty) {
      return const [];
    }

    final lines = normalized.split(RegExp(r'\r?\n'));
    return lines
        .map(
          (line) =>
              LyricLine(timestamp: Duration.zero, text: line, isTimed: false),
        )
        .toList(growable: false);
  }

  ({List<double> heights, List<double> itemCenters, List<double> anchorCenters})
  _measureLineMetrics({
    required List<LyricLine> lines,
    required MusicLyric? lyrics,
    required double maxWidth,
    required double lyricsFontScale,
    required bool hasTimedLyrics,
    required BuildContext context,
    required LyricsStyle lyricsStyle,
  }) {
    final targetLang = ref.read(lyricsControllerProvider).lyricsTranslationLanguageCode;
    final effectiveLang = lyrics?.getEffectiveTranslationLanguage(targetLang) ?? targetLang;

    if (listEquals(_lastMeasuredLines, lines) &&
        _lastMeasuredLyrics == lyrics &&
        _lastMeasuredMaxWidth == maxWidth &&
        _lastMeasuredFontScale == lyricsFontScale &&
        _lastMeasuredHasTimedLyrics == hasTimedLyrics &&
        _lastMeasuredLyricsStyle == lyricsStyle &&
        _lastMeasuredLang == effectiveLang &&
        _cachedLineMetrics != null) {
      return _cachedLineMetrics!;
    }

    final isSmallWin = ref.read(settingsServiceProvider).isSmallWindowMode;
    final isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait) || isSmallWin;
    final timedLyricFontSize = 16 * lyricsFontScale;
    final plainLyricFontSize = 18 * lyricsFontScale;
    final translationFontSize = (lyricsStyle == LyricsStyle.apple
            ? (isPortrait
                ? PlaybackPageUiTuning.appleLyricsTranslationFontSizePortrait
                : PlaybackPageUiTuning.appleLyricsTranslationFontSizeLandscape)
            : 13.0) *
        lyricsFontScale;
    final basePadding = lyricsStyle == LyricsStyle.apple
        ? PlaybackPageUiTuning.appleLyricsVerticalPadding
        : PlaybackPageUiTuning.traditionalLyricsVerticalPadding;
    final verticalItemPadding = basePadding * lyricsFontScale;
    final translatedSpacing = 3 * lyricsFontScale;

    final lineStyle = hasTimedLyrics
        ? Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: timedLyricFontSize,
            fontWeight: lyricsStyle == LyricsStyle.apple ? FontWeight.w700 : FontWeight.w400,
            height: 1.4,
            leadingDistribution: TextLeadingDistribution.even,
          )
        : TextStyle(
            fontSize: plainLyricFontSize,
            fontWeight: lyricsStyle == LyricsStyle.apple ? FontWeight.w700 : FontWeight.w400,
            height: 1.6,
            leadingDistribution: TextLeadingDistribution.even,
          );

    final translationStyle = TextStyle(
      fontSize: translationFontSize,
      fontWeight: lyricsStyle == LyricsStyle.apple ? FontWeight.w700 : FontWeight.w400,
      height: 1.3,
      leadingDistribution: TextLeadingDistribution.even,
    );

    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    final heights = <double>[];
    final itemCenters = <double>[];
    final anchorCenters = <double>[];
    double currentTop = 0.0;

    final isApplePortrait = isPortrait && lyricsStyle == LyricsStyle.apple;
    final double layoutMaxWidth;
    final double translationLayoutMaxWidth;
    if (isApplePortrait) {
      final double effectiveLeftPadding = isSmallWin ? 16.0 : 0.0;
      layoutMaxWidth = maxWidth - (effectiveLeftPadding + 24.0);
      translationLayoutMaxWidth = layoutMaxWidth - 12.0;
    } else {
      if (lyricsStyle == LyricsStyle.apple) {
        layoutMaxWidth = maxWidth - 48.0;
        translationLayoutMaxWidth = layoutMaxWidth - 12.0;
      } else {
        layoutMaxWidth = maxWidth - 48.0;
        translationLayoutMaxWidth = maxWidth - 72.0;
      }
    }

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final translated =
          lyrics
              ?.translatedLineAt(
                i,
                effectiveLang,
              )
              .trim() ??
          '';

      // 1. Calculate main text height
      final textPainter = TextPainter(
        text: TextSpan(text: line.text, style: lineStyle),
        textDirection: textDirection,
        textScaler: textScaler,
      )..layout(maxWidth: math.max(0.0, layoutMaxWidth));
      double itemHeight = textPainter.height;

      // 2. Calculate translation height if present
      if (hasTimedLyrics && translated.isNotEmpty) {
        final transPainter = TextPainter(
          text: TextSpan(text: translated, style: translationStyle),
          textDirection: textDirection,
          textScaler: textScaler,
        )..layout(maxWidth: math.max(0.0, translationLayoutMaxWidth));
        itemHeight += translatedSpacing + transPainter.height;
      }

      // 3. Add vertical padding
      itemHeight += verticalItemPadding * 2;

      heights.add(itemHeight);
      itemCenters.add(currentTop + itemHeight / 2);
      anchorCenters.add(
        currentTop + verticalItemPadding + textPainter.height / 2,
      );
      currentTop += itemHeight;
    }

    final result = (
      heights: heights,
      itemCenters: itemCenters,
      anchorCenters: anchorCenters,
    );

    _lastMeasuredLines = lines;
    _lastMeasuredLyrics = lyrics;
    _lastMeasuredMaxWidth = maxWidth;
    _lastMeasuredFontScale = lyricsFontScale;
    _lastMeasuredHasTimedLyrics = hasTimedLyrics;
    _lastMeasuredLyricsStyle = lyricsStyle;
    _lastMeasuredLang = effectiveLang;
    _cachedLineMetrics = result;

    return result;
  }

  int _findClosestLineIndex(double targetCenter, List<double> centers) {
    if (centers.isEmpty) return 0;
    if (targetCenter <= centers.first) return 0;
    if (targetCenter >= centers.last) return centers.length - 1;

    int low = 0;
    int high = centers.length - 1;
    while (low < high) {
      int mid = (low + high) >> 1;
      if (centers[mid] < targetCenter) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    if (low > 0) {
      final diffCurrent = (centers[low] - targetCenter).abs();
      final diffPrev = (centers[low - 1] - targetCenter).abs();
      if (diffPrev < diffCurrent) {
        return low - 1;
      }
    }
    return low;
  }

  ScrollBehavior _lyricsScrollBehavior(BuildContext context) {
    return ScrollConfiguration.of(context).copyWith(
      scrollbars: false,
      dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      },
    );
  }

  void _writeLog(String message) {
    // debugPrint('[LYRICS_DEBUG] $message');
  }

  @override
  void initState() {
    super.initState();
    try {
      final file = File('/Volumes/Untitled/projects/vynody/lyrics_debug.log');
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
    _timelineOffsetSeconds = _timelineOffsetToSeconds(
      widget.lyrics?.timelineOffset,
    );
  }

  @override
  void dispose() {
    _detachScrollActivityListener();
    _dismissSeekToast(showAnim: false);
    _scrollController.dispose();
    super.dispose();
  }

  void _dismissSeekToast({bool showAnim = false}) {
    _seekToastAutoDismissTimer?.cancel();
    _seekToastAutoDismissTimer = null;
    _seekToast?.dismiss(showAnim: showAnim);
    _seekToast = null;
    _seekToastSignature = null;
    _seekToastStateNotifier?.dispose();
    _seekToastStateNotifier = null;
  }

  String _formatDuration(Duration duration) {
    final safe = duration < Duration.zero ? Duration.zero : duration;
    final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _syncSeekToast(Duration target) {
    final signature = target.inMilliseconds.toString();
    final l10n = AppLocalizations.of(context);
    final timeText = _formatDuration(target);
    final timeLabelText =
        l10n?.targetTimeLabel(timeText) ?? 'Target time $timeText';

    if (_seekToast?.mounted == true && _seekToastStateNotifier != null) {
      _seekToastSignature = signature;
      _seekToastStateNotifier!.value = (
        target: target,
        timeLabel: timeLabelText,
      );
      _seekToastAutoDismissTimer?.cancel();
      _seekToastAutoDismissTimer = Timer(_seekToastAutoDismissDelay, () {
        if (!mounted) return;
        if (_seekToastSignature != signature) return;
        _dismissSeekToast(showAnim: true);
      });
      return;
    }

    _dismissSeekToast();
    _seekToastSignature = signature;
    _seekToastStateNotifier = ValueNotifier((
      target: target,
      timeLabel: timeLabelText,
    ));
    _seekToast = showToastWidget(
      LyricsSeekToast(
        stateListenable: _seekToastStateNotifier!,
        accentColor:
            widget.accentColor ?? Theme.of(context).colorScheme.primary,
      ),
      context: context,
      duration: Duration.zero,
      position: ToastPosition.top.copyWith(
        align: Alignment.topCenter,
        offset: _seekToastTopOffset,
      ),
      dismissOtherToast: false,
      handleTouch: false,
      animationDuration: _seekToastAnimationDuration,
      animationCurve: Curves.easeOutCubic,
    );

    _seekToastAutoDismissTimer?.cancel();
    _seekToastAutoDismissTimer = Timer(_seekToastAutoDismissDelay, () {
      if (!mounted) return;
      if (_seekToastSignature != signature) return;
      _dismissSeekToast(showAnim: true);
    });
  }

  Duration _audioSeekPositionForLyricTimestamp(Duration timestamp) {
    final targetMs = timestamp.inMilliseconds + _timelineOffsetMilliseconds;
    return Duration(milliseconds: math.max(0, targetMs));
  }

  Future<bool> _ensureLyricsApiKey() async {
    return ensureLyricsGenerationApiKey(context, ref);
  }

  Future<bool> _ensureGeminiApiKey() async {
    return ensureGeminiApiKey(context, ref);
  }

  void _showGenerationErrorSnack(String message) {
    if (!mounted || message.trim().isEmpty) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message.trim())));
  }

  @override
  void didUpdateWidget(covariant LyricsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lyrics != widget.lyrics) {
      final oldLyrics = oldWidget.lyrics;
      final newLyrics = widget.lyrics;
      final bool lyricsContentChanged = oldLyrics?.id != newLyrics?.id ||
          oldLyrics?.plainText != newLyrics?.plainText ||
          !listEquals(oldLyrics?.syncedLines, newLyrics?.syncedLines);
      if (lyricsContentChanged) {
        _overrideActiveIndex = null;
        _seekTargetTimestamp = null;
        _isFocusMode = true;
        _lastActiveIndex = -1;
        _lastScrollDelta = 0.0;
        _scrollTriggerTime = 0;
      }
    }
    final oldOffset = _timelineOffsetToSeconds(
      oldWidget.lyrics?.timelineOffset,
    );
    final newOffset = _timelineOffsetToSeconds(widget.lyrics?.timelineOffset);
    if (oldOffset != newOffset) {
      _timelineOffsetSeconds = newOffset;
    }
  }

  Future<void> _showContextMenu(
    BuildContext context,
    Offset globalPosition, {
    required LyricsControllerState lyricsState,
    required LyricsSongTaskState taskState,
    required List<LyricLine> displayLines,
    required String displayPlainLyrics,
    required bool hasCurrentSong,
    required double lyricsFontScale,
    bool requeryOnly = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final currentSong = ref.read(audioCurrentMusicProvider);
    final availableSources = currentSong != null
        ? await _lyricsControllerActions.getAvailableLyricRecords(currentSong)
        : const <LyricsCacheRecord>[];

    final displayLyrics = _lyricsForDisplay();
    final targetLang = lyricsState.lyricsTranslationLanguageCode;
    final effectiveLang = displayLyrics?.getEffectiveTranslationLanguage(targetLang) ?? targetLang;
    final translation = displayLyrics?.translationFor(effectiveLang);
    final hasTranslation = translation != null && translation.hasContent;

    final settings = ref.read(settingsServiceProvider);
    final saveToLrc = settings.lyricsSaveMethod == LyricsSaveMethod.lrcFile ||
        (settings.lyricsSaveMethod == LyricsSaveMethod.original &&
            displayLyrics?.source == 'external');

    final items = <PopupMenuEntry<String>>[
      buildContextMenuItem<String>(
        value: 'fill_lyrics',
        enabled: hasCurrentSong,
        label: l10n.enterLyricsTitle,
        icon: Icons.edit_note_rounded,
        context: context,
      ),
      if (lyricsState.hasLyrics)
        buildContextMenuItem<String>(
          value: 'generate',
          enabled: hasCurrentSong && !taskState.isGenerationBusy,
          label: l10n.generateLyrics,
          icon: Icons.auto_awesome_rounded,
          context: context,
        ),
      if (lyricsState.hasLyrics)
        buildContextMenuItem<String>(
          value: 'generate_timeline',
          enabled: hasCurrentSong && !taskState.isGenerationBusy,
          label: l10n.generateTimeline,
          icon: Icons.timer_rounded,
          context: context,
        ),
      if (!requeryOnly &&
          _hasTimedLyrics(displayLines) &&
          lyricsState.hasLyrics)
        const PopupMenuDivider(),
      if (!requeryOnly &&
          _hasTimedLyrics(displayLines) &&
          lyricsState.hasLyrics)
        buildContextMenuItem<String>(
          value: 'adjust_timeline',
          enabled: hasCurrentSong,
          label: l10n.timelineAdjustmentTitle,
          icon: Icons.more_time_rounded,
          context: context,
        ),
      if (!requeryOnly &&
          _hasTimedLyrics(displayLines) &&
          settings.lyricsStyle != LyricsStyle.apple)
        buildContextMenuItem<String>(
          value: 'toggle_auto_scroll',
          enabled: hasCurrentSong,
          label: _isAutoScrollPaused
              ? l10n.resumeAutoScroll
              : l10n.pauseAutoScroll,
          icon: _isAutoScrollPaused
              ? Icons.play_arrow_rounded
              : Icons.pause_rounded,
          context: context,
        ),
      if (!requeryOnly)
        buildContextMenuItem<String>(
          value: 'translate',
          enabled: hasCurrentSong && !taskState.isTranslationBusy,
          label: l10n.translateLyrics,
          icon: Icons.translate_rounded,
          context: context,
        ),
      if (!requeryOnly && hasTranslation)
        buildContextMenuItem<String>(
          value: 'copy_translation',
          enabled: true,
          label: l10n.copyTranslationResults,
          icon: Icons.copy_rounded,
          context: context,
        ),
      buildContextMenuItem<String>(
        value: 'search_online_lyrics',
        enabled: hasCurrentSong,
        label: l10n.selectOnlineLyrics,
        icon: Icons.cloud_download_rounded,
        context: context,
      ),
      if (!requeryOnly)
        buildContextMenuItem<String>(
          value: 'clear_lyrics_cache',
          enabled: hasCurrentSong && lyricsState.hasLyrics,
          label: l10n.clearLyricsCache,
          icon: Icons.delete_sweep_rounded,
          context: context,
        ),
      if (!requeryOnly)
        buildContextMenuItem<String>(
          value: 'clear_translation_cache',
          enabled: hasCurrentSong && lyricsState.hasLyrics,
          label: l10n.clearTranslationCache,
          icon: Icons.delete_outline_rounded,
          context: context,
        ),
      if (!requeryOnly)
        buildContextMenuItem<String>(
          value: 'save_lyrics_to_file',
          enabled: hasCurrentSong &&
              (lyricsState.hasLyrics ||
                  (lyricsState.currentLyricsText.isEmpty &&
                      lyricsState.lyricsSearchAttempted)) &&
              ref.read(audioCurrentMusicProvider) != null &&
              (saveToLrc || isMetadataWritable(ref.read(audioCurrentMusicProvider)!.path)),
          label: l10n.writeLyricsToFile,
          icon: Icons.save_alt_rounded,
          context: context,
        ),
      if (!requeryOnly && availableSources.length > 1)
        buildContextMenuItem<String>(
          value: 'select_lyrics_source',
          enabled: hasCurrentSong,
          label: l10n.selectLyricSource,
          icon: Icons.source_rounded,
          context: context,
        ),
      if (requeryOnly)
        buildContextMenuItem<String>(
          value: 'requery',
          enabled:
              hasCurrentSong &&
              !lyricsState.isLyricsLoading &&
              !taskState.isGenerationBusy,
          label: l10n.requery,
          icon: Icons.refresh_rounded,
          context: context,
        ),
      const PopupMenuDivider(),
      buildContextMenuItem<String>(
        value: 'adjust_lyrics_font',
        enabled: true,
        label: l10n.adjustLyricsFont,
        icon: Icons.format_size_rounded,
        context: context,
      ),
    ];

    final selected = await AppContextMenu.show<String>(
      context: context,
      position: globalPosition,
      items: items,
    );

    if (!mounted) return;

    if (selected == 'toggle_auto_scroll') {
      setState(() {
        _isAutoScrollPaused = !_isAutoScrollPaused;
        if (!_isAutoScrollPaused) {
          _lastActiveIndex = -1;
        }
      });
      if (_isAutoScrollPaused) {
        _dismissSeekToast();
      }
    } else if (selected == 'generate') {
      if (!await checkProGate(context, ref, feature: ProFeature.aiLyrics)) return;
      if (!context.mounted || !mounted) return;
      if (await _ensureLyricsApiKey()) {
        if (!context.mounted) return;
        if (lyricsState.hasLyrics) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.regenerateLyrics),
              content: Text(l10n.regenerateLyricsConfirmation),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.confirm),
                ),
              ],
            ),
          );
          if (confirm != true) return;
        }

        if (!context.mounted || !mounted) return;
        final errorMessage = await _lyricsControllerActions
            .regenerateLyricsForCurrentSong();
        if (errorMessage != null) {
          _showGenerationErrorSnack(errorMessage);
        }
      }
    } else if (selected == 'generate_timeline') {
      if (!await checkProGate(context, ref, feature: ProFeature.aiLyrics)) return;
      if (!context.mounted || !mounted) return;
      if (await _ensureLyricsApiKey()) {
        if (!context.mounted) return;
        if (lyricsState.hasLyrics) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.regenerateTimeline),
              content: Text(l10n.regenerateTimelineConfirmation),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.confirm),
                ),
              ],
            ),
          );
          if (confirm != true) return;
        }

        if (!context.mounted || !mounted) return;
        final errorMessage = await _lyricsControllerActions
            .generateTimelineForCurrentSong();
        if (errorMessage != null) {
          _showGenerationErrorSnack(errorMessage);
        }
      }
    } else if (selected == 'translate') {
      if (!await checkProGate(context, ref, feature: ProFeature.aiTranslation)) return;
      if (!context.mounted || !mounted) return;
      if (await _ensureGeminiApiKey()) {
        if (!context.mounted) return;
        if (hasTranslation) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.retranslateLyrics),
              content: Text(l10n.retranslateLyricsConfirmation),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.confirm),
                ),
              ],
            ),
          );
          if (confirm != true) return;

          await _lyricsControllerActions.clearTranslationCacheForCurrentSong();
        }

        if (!context.mounted || !mounted) return;
        final errorMessage = await _lyricsControllerActions
            .translateLyricsForCurrentSong();
        if (errorMessage != null) {
          _showGenerationErrorSnack(errorMessage);
        }
      }
    } else if (selected == 'copy_translation') {
      if (hasTranslation) {
        final copyText = translation.translatedLines.isNotEmpty
            ? translation.translatedLines.join('\n').trim()
            : translation.translatedText.trim();
        await Clipboard.setData(ClipboardData(text: copyText));
        showToast(l10n.translationCopiedToClipboard);
      }
    } else if (selected == 'search_online_lyrics') {
      await _searchOnlineLyrics();
    } else if (selected == 'clear_lyrics_cache') {
      await _lyricsControllerActions.clearLyricsCacheForCurrentSong();
    } else if (selected == 'clear_translation_cache') {
      await _lyricsControllerActions.clearTranslationCacheForCurrentSong();
    } else if (selected == 'save_lyrics_to_file') {
      final currentSong = ref.read(audioCurrentMusicProvider);
      if (currentSong != null) {
        final lyricsToSave = _hasTimedLyrics(displayLines)
            ? displayLines.map((line) {
                if (!line.isTimed) return line.text;
                final totalMs = line.timestamp.inMilliseconds;
                final minutes = totalMs ~/ 60000;
                final seconds = (totalMs % 60000) ~/ 1000;
                final centiseconds = (totalMs % 1000) ~/ 10;
                final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
                return '[$timeStr]${line.text}';
              }).join('\n')
            : displayPlainLyrics;

        showToast(l10n.writingLyrics);

        final settings = ref.read(settingsServiceProvider);
        final displayLyrics = _lyricsForDisplay();
        final saveToLrc = settings.lyricsSaveMethod == LyricsSaveMethod.lrcFile ||
            (settings.lyricsSaveMethod == LyricsSaveMethod.original &&
                displayLyrics?.source == 'external');

        final bool success;
        final LyricsCacheSource newSource;
        if (saveToLrc) {
          success = await MetadataHelper.saveLyricsToExternalLrc(currentSong.path, lyricsToSave);
          newSource = LyricsCacheSource.external;
        } else {
          success = await MetadataHelper.saveLyricsToFile(currentSong.path, lyricsToSave);
          newSource = LyricsCacheSource.embedded;
        }

        if (success) {
          await _lyricsControllerActions.fillLyricsForCurrentSong(
            lyricsToSave,
            source: newSource,
          );
          showToast(l10n.lyricsWrittenToFile);
        } else {
          final errorMsg = MetadataHelper.lastWriteError ?? '';
          showToast(
            errorMsg.isNotEmpty
                ? '${l10n.writeLyricsFailed}: $errorMsg'
                : l10n.writeLyricsFailed,
          );
        }
      }
    } else if (selected == 'select_lyrics_source') {
      if (currentSong != null) {
        await _showSelectLyricsSourceDialog(currentSong, availableSources);
      }
    } else if (selected == 'requery') {
      await _lyricsControllerActions.requeryLyricsForCurrentSong();
    } else if (selected == 'adjust_timeline') {
      await _showTimelineAdjustmentPanel(displayLines);
    } else if (selected == 'fill_lyrics') {
      await _showManualLyricsDialog(displayPlainLyrics);
    } else if (selected == 'adjust_lyrics_font') {
      if (context.mounted) {
        final style = settings.lyricsStyle;
        await showLyricsFontScaleDialog(context, ref, lyricsStyle: style);
      }
    }
  }

  Future<void> _showManualLyricsDialog(String initialLyrics) async {
    final submittedLyrics = await showManualLyricsDialog(
      context,
      initialLyrics: initialLyrics,
    );

    if (!mounted || submittedLyrics == null) return;

    await _lyricsControllerActions.fillLyricsForCurrentSong(submittedLyrics);
  }

  Future<void> _searchOnlineLyrics() async {
    final currentSong = ref.read(audioCurrentMusicProvider);
    final songTitle = currentSong?.displayName.trim() ?? '';
    if (currentSong == null || songTitle.isEmpty) {
      return;
    }
    final songArtist = currentSong.artist?.trim();
    final songAlbum = currentSong.album?.trim();

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(lyricsServiceProvider);

    final selectedTrack = await showOnlineLyricsSearchDialog(
      context: context,
      queryTitle: songTitle,
      lyricsService: service,
      queryArtist: songArtist?.isNotEmpty == true ? songArtist : null,
      queryAlbum: songAlbum?.isNotEmpty == true ? songAlbum : null,
      queryDuration: currentSong.durationMillis != null
          ? Duration(milliseconds: currentSong.durationMillis!)
          : null,
      searchTracks: ({
        required String title,
        String? artist,
        String? album,
        String? q,
        CancelToken? cancelToken,
      }) {
        return service.searchTracksByQuery(
          title: title,
          artist: artist,
          album: album,
          q: q,
          cancelToken: cancelToken,
        );
      },
    );

    if (!mounted || selectedTrack == null) return;

    final lyricsText = selectedTrack.syncedLyrics?.trim().isNotEmpty == true
        ? selectedTrack.syncedLyrics!.trim()
        : selectedTrack.plainLyrics?.trim() ?? '';
    if (lyricsText.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.noMatchingResults)));
      return;
    }

    await _lyricsControllerActions.fillLyricsForCurrentSong(
      lyricsText,
      source: LyricsCacheSource.lrclib,
    );
  }

  String _buildGenerateButtonLabel(
    AppLocalizations l10n,
    LyricsSongTaskState taskState,
  ) {
    final activeLabel = taskState.activeStatusLabel.trim();
    if (activeLabel.isNotEmpty) {
      return activeLabel;
    }

    return taskState.isGenerationBusy
        ? l10n.queueGenerateLyrics
        : l10n.generateLyrics;
  }

  void _scheduleScrollIfNeeded({
    bool force = false,
    bool animate = true,
    List<LyricLine>? displayLines,
    required List<double> itemCenters,
  }) {
    final lyricsState = ref.read(lyricsControllerProvider);
    final lines =
        displayLines ??
        _displayLinesForLyrics(lyricsState, _lyricsForDisplay());
    if (lines.isEmpty ||
        !_hasTimedLyrics(lines) ||
        _isAutoScrollPaused ||
        _isDraggingLyrics ||
        (widget.isTransitioning && !force)) {
      return;
    }

    final activeIndex = _activeLineIndex(lines);
    _writeLog('_scheduleScrollIfNeeded: activeIndex=$activeIndex _lastActiveIndex=$_lastActiveIndex force=$force');
    if (!force && activeIndex == _lastActiveIndex) return;

    bool shouldScroll = true;

    final isInitialScroll = _lastActiveIndex == -1 || activeIndex == 0;
    final lyricsStyle = ref.read(settingsServiceProvider).lyricsStyle;
    if (lyricsStyle == LyricsStyle.apple) {
      if (!force) {
        if (_isFocusMode) {
          _lastActiveIndex = activeIndex;
        } else {
          if (_scrollController.hasClients) {
            final offset = _scrollController.offset;
            final viewportHeight = _scrollController.position.viewportDimension;
            if (activeIndex >= 0 && activeIndex < _currentItemCenters.length && activeIndex < _currentLineHeights.length) {
              final lineTop = _currentItemCenters[activeIndex] - _currentLineHeights[activeIndex] / 2;
              final lineBottom = _currentItemCenters[activeIndex] + _currentLineHeights[activeIndex] / 2;
              final isVisible = lineBottom >= offset - 20.0 && lineTop <= offset + viewportHeight + 20.0;
              final isPlaying = ref.read(audioIsPlayingProvider);
              if (isVisible && isPlaying) {
                if (_activePointers > 0) {
                  shouldScroll = false;
                } else {
                  _lastActiveIndex = activeIndex;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isFocusMode = true;
                        _enteringFocusModeTriggered = true;
                      });
                    }
                  });
                }
              } else {
                if (_activePointers == 0) {
                  _lastActiveIndex = activeIndex;
                }
                shouldScroll = false;
              }
            } else {
              if (_activePointers == 0) {
                _lastActiveIndex = activeIndex;
              }
              shouldScroll = false;
            }
          } else {
            if (_activePointers == 0) {
              _lastActiveIndex = activeIndex;
            }
            shouldScroll = false;
          }
        }
      } else {
        if (!_isFocusMode) {
          shouldScroll = false;
        } else {
          _lastActiveIndex = activeIndex;
        }
      }
    } else {
      _lastActiveIndex = activeIndex;
    }

    if (!shouldScroll) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _writeLog('PostFrameCallback: activeIndex=$activeIndex, scheduling to...');
      if (kDebugMode) {
        final currentOffset = _scrollController.offset;
        final viewportHeight = _scrollController.position.viewportDimension;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final bottomSpacers =
            widget.bottomSpacerHeight + widget.bottomTabBarHeight + bottomPadding;
        final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
        final fadeAsymmetryShift = isPortrait ? 15.0 : 0.0;
        final visibleCenter = (viewportHeight - bottomSpacers) / 2 - fadeAsymmetryShift;
        final targetCenter =
            activeIndex >= 0 && activeIndex < itemCenters.length
            ? itemCenters[activeIndex]
            : double.nan;
        debugPrint(
          '[LyricsPanel] scheduleScroll '
          'force=$force animate=$animate '
          'activeIndex=$activeIndex '
          'currentOffset=${currentOffset.toStringAsFixed(1)} '
          'viewport=${viewportHeight.toStringAsFixed(1)} '
          'visibleCenter=${visibleCenter.toStringAsFixed(1)} '
          'targetCenter=${targetCenter.toStringAsFixed(1)}',
        );
      }
      _scrollToLineIndex(
        activeIndex,
        animate: animate && !isInitialScroll,
        itemCenters: itemCenters,
        isInitialScroll: isInitialScroll,
      );
    });
  }

  void _attachScrollActivityListener() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (identical(_attachedScrollPosition, position)) {
      return;
    }

    _detachScrollActivityListener();
    _attachedScrollPosition = position;
    position.isScrollingNotifier.addListener(_handleScrollActivityChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(_attachedScrollPosition, position)) return;
      _syncScrollAnimatingProvider(position.isScrollingNotifier.value);
      if (!position.isScrollingNotifier.value) {
        unawaited(
          _lyricsControllerActions.flushPendingLyricsTranslationUpdates(),
        );
      }
    });
  }

  void _detachScrollActivityListener() {
    final position = _attachedScrollPosition;
    if (position == null) return;
    position.isScrollingNotifier.removeListener(_handleScrollActivityChanged);
    _attachedScrollPosition = null;
    _syncScrollAnimatingProvider(false);
  }

  void _handleScrollActivityChanged() {
    final position = _attachedScrollPosition;
    if (position == null) return;

    final isScrolling = position.isScrollingNotifier.value;
    _syncScrollAnimatingProvider(isScrolling);
    if (!isScrolling) {
      unawaited(
        _lyricsControllerActions.flushPendingLyricsTranslationUpdates(),
      );
    }
  }

  void _syncScrollAnimatingProvider(bool isScrolling) {
    if (!mounted) return;
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(lyricsPanelScrollAnimatingProvider.notifier)
          .setScrolling(isScrolling);
    });
  }

  void _beginLyricsDrag(List<LyricLine> displayLines) {
    if (displayLines.isEmpty || !_hasTimedLyrics(displayLines)) return;

    final initialLine = _activeLineIndex(
      displayLines,
    ).clamp(0, displayLines.length - 1).toInt();

    if (mounted) {
      setState(() {
        _isDraggingLyrics = false;
        _dragDistancePixels = 0.0;
        _dragTravelPixels = 0.0;
        _dragStartLine = initialLine;
        _dragCurrentLine = initialLine;
      });
    } else {
      _isDraggingLyrics = false;
      _dragDistancePixels = 0.0;
      _dragTravelPixels = 0.0;
      _dragStartLine = initialLine;
      _dragCurrentLine = initialLine;
    }
  }

  void _reportActiveLyricTopOffset({
    required int activeIndex,
    required bool hasTimedLyrics,
    required bool isDraggingLyrics,
    required int? dragCurrentLine,
    required List<double> lineHeights,
    required List<double> itemCenters,
  }) {
    final callback = widget.onActiveLyricTopChanged;
    if (callback == null) return;
    if (!hasTimedLyrics || !_scrollController.hasClients) {
      if (_lastReportedActiveLyricTopOffset != null) {
        _lastReportedActiveLyricTopOffset = null;
        callback(null);
      }
      return;
    }

    final focusedIndex = isDraggingLyrics && dragCurrentLine != null
        ? dragCurrentLine
        : activeIndex;
    final lyricsStyle = ref.read(settingsServiceProvider).lyricsStyle;
    final topOffset = calculateLyricTopOffsetFromPanelTop(
      lineHeights: lineHeights,
      lineCenters: itemCenters,
      lineIndex: focusedIndex,
      scrollOffset: _scrollController.offset,
      scale: lyricsStyle == LyricsStyle.apple ? 1.0 : 1.12,
    );

    if (_lastReportedActiveLyricTopOffset == topOffset) {
      return;
    }

    _lastReportedActiveLyricTopOffset = topOffset;
    callback(topOffset);
  }

  void _updateLyricsDrag(
    DragUpdateDetails details,
    List<LyricLine> displayLines,
    List<double> itemCenters,
  ) {
    if (displayLines.isEmpty || !_hasTimedLyrics(displayLines)) {
      return;
    }

    final startLine = _dragStartLine;
    if (startLine == null) return;

    final delta = details.primaryDelta ?? 0.0;
    if (delta == 0.0) return;

    _dragDistancePixels += delta;
    _dragTravelPixels += delta.abs();

    if (!_isDraggingLyrics) {
      if (_dragTravelPixels < _lyricsDragSeekThreshold) {
        return;
      }

      if (mounted) {
        setState(() {
          _isDraggingLyrics = true;
        });
      } else {
        _isDraggingLyrics = true;
      }

      _dismissSeekToast();
    }

    if (startLine < itemCenters.length) {
      final startCenter = itemCenters[startLine];
      final targetCenter = startCenter - _dragDistancePixels;
      final targetIndex = _findClosestLineIndex(
        targetCenter,
        itemCenters,
      ).clamp(0, displayLines.length - 1).toInt();

      if (_dragCurrentLine != targetIndex) {
        if (mounted) {
          setState(() {
            _dragCurrentLine = targetIndex;
          });
        } else {
          _dragCurrentLine = targetIndex;
        }
      }

      _scrollToLineIndex(targetIndex, animate: false, itemCenters: itemCenters);
      _syncSeekToast(
        _audioSeekPositionForLyricTimestamp(
          displayLines[targetIndex].timestamp,
        ),
      );
    }
  }

  void _handleLyricsLayoutRevisionChanged({
    required int layoutRevision,
    required bool hasTimedLyrics,
    required List<LyricLine> displayLines,
    required List<double> itemCenters,
  }) {
    if (layoutRevision == _lastLayoutRevision) {
      return;
    }

    _lastLayoutRevision = layoutRevision;
    if (!hasTimedLyrics) return;

    _scheduleScrollIfNeeded(
      force: true,
      animate: false,
      displayLines: displayLines,
      itemCenters: itemCenters,
    );
  }

  Future<void> _endLyricsDrag(List<LyricLine> displayLines) async {
    final wasDraggingLyrics = _isDraggingLyrics;
    final targetLine = _dragCurrentLine;
    try {
      if (targetLine == null || !_hasTimedLyrics(displayLines)) {
        _dismissSeekToast(showAnim: true);
        return;
      }

      if (!wasDraggingLyrics) {
        _dismissSeekToast(showAnim: true);
        return;
      }

      // 用户抬手后先立刻收掉进度提示，再等待播放器完成 seek。
      // 这样可以避免松手瞬间还在用旧 position 触发一次回跳。
      _dismissSeekToast(showAnim: true);

      if (targetLine >= 0 && targetLine < displayLines.length) {
        final targetPosition = _audioSeekPositionForLyricTimestamp(
          displayLines[targetLine].timestamp,
        );
        unawaited(ref.read(audioServiceProvider).seek(targetPosition));
        setState(() {
          _overrideActiveIndex = targetLine;
          _seekTargetTimestamp = targetPosition;
          _seekSetTime = DateTime.now();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDraggingLyrics = false;
          _dragDistancePixels = 0.0;
          _dragTravelPixels = 0.0;
          _dragStartLine = null;
          _dragCurrentLine = null;
        });
      } else {
        _isDraggingLyrics = false;
        _dragDistancePixels = 0.0;
        _dragTravelPixels = 0.0;
        _dragStartLine = null;
        _dragCurrentLine = null;
      }
    }
  }

  void _scrollToLineIndex(
    int index, {
    required bool animate,
    required List<double> itemCenters,
    bool isInitialScroll = false,
  }) {
    if (!_scrollController.hasClients) return;
    if (index < 0 || index >= itemCenters.length) return;

    final viewportHeight = _scrollController.position.viewportDimension;
    if (!viewportHeight.isFinite || viewportHeight <= 0) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomSpacers = widget.bottomSpacerHeight + widget.bottomTabBarHeight + bottomPadding;
    final isSmallWin = ref.read(settingsServiceProvider).isSmallWindowMode;
    final isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait) || isSmallWin;
    // 考虑上下渐变区域不对称带来的视觉中心偏移 (15.0) 以及安全区域遮挡
    final fadeAsymmetryShift = isPortrait ? 15.0 : 0.0;
    // 计算可见区域的中心（避开底部遮挡/渐变区/安全区）
    final visibleCenter = (viewportHeight - bottomSpacers) / 2 - fadeAsymmetryShift;

    final lyricsStyle = ref.read(settingsServiceProvider).lyricsStyle;
    final double target;
    if (lyricsStyle == LyricsStyle.apple && index < _currentLineHeights.length) {
      final topOfLine = itemCenters[index] - _currentLineHeights[index] / 2;
      final fontScale = _lastMeasuredFontScale ?? _lastBuiltFontScale ?? 1.0;
      final offset = PlaybackPageUiTuning.appleLyricsScrollOffset(
        fontScale,
        isSmallWin: isSmallWin,
      );
      target = math.max(0.0, math.min(topOfLine - offset, maxExtent));
    } else {
      final targetCenter = itemCenters[index];
      target = math.max(
        0.0,
        math.min(targetCenter - visibleCenter, maxExtent),
      );
    }

    final currentOffset = _scrollController.offset;
    _writeLog('_scrollToLineIndex: index=$index target=$target currentOffset=$currentOffset difference=${(target - currentOffset).abs()} animate=$animate');
    if ((target - currentOffset).abs() < 1.0) {
      _writeLog('_scrollToLineIndex: difference is less than 1.0, early exit');
      return;
    }
    if (kDebugMode) {
      // debugPrint(
      //   '[LyricsPanel] scrollToLine '
      //   'index=$index '
      //   'targetCenter=${targetCenter.toStringAsFixed(1)} '
      //   'visibleCenter=${visibleCenter.toStringAsFixed(1)} '
      //   'currentOffset=${_scrollController.offset.toStringAsFixed(1)} '
      //   'targetOffset=${target.toStringAsFixed(1)} '
      //   'delta=${(target - _scrollController.offset).toStringAsFixed(1)}',
      // );
    }

    if (animate) {
      final currentSong = ref.read(audioCurrentMusicProvider);
      final isGenerating = _taskStateForSongPath(currentSong?.path).isGenerationBusy;
      if (lyricsStyle == LyricsStyle.apple && _isFocusMode && !isGenerating) {
        final delta = target - currentOffset;
        final isEntering = _enteringFocusModeTriggered;
        final maxDelta = isEntering ? math.max(1200.0, viewportHeight * 1.5) : 300.0;
        final bool isBigJump = delta.abs() > maxDelta || index == 0 || isInitialScroll;
        _scrollController.jumpTo(target);
        _enteringFocusModeTriggered = false;
        final firstVisible = _findClosestLineIndex(target, itemCenters);
        if (mounted) {
          setState(() {
            if (widget.isTransitioning || isInitialScroll || isBigJump) {
              _lastScrollDelta = 0.0;
              _scrollTriggerTime = 0;
            } else {
              _lastScrollDelta = delta;
              _scrollTriggerTime = DateTime.now().millisecondsSinceEpoch;
            }
            _isEnteringFocusMode = isEntering;
            _firstVisibleIndex = firstVisible;
          });
        }
      } else {
        unawaited(
          _scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          ),
        );
      }
    } else {
      if (lyricsStyle == LyricsStyle.apple && mounted) {
        setState(() {
          _lastScrollDelta = 0.0;
          _scrollTriggerTime = 0;
        });
      }
      _scrollController.jumpTo(target);
    }
  }

  void _handleLineTapped(int index, List<LyricLine> displayLines) {
    if (index < 0 || index >= displayLines.length) return;
    final line = displayLines[index];
    if (line.isTimed) {
      final targetPosition = _audioSeekPositionForLyricTimestamp(line.timestamp);
      unawaited(ref.read(audioServiceProvider).seek(targetPosition));
      setState(() {
        _isFocusMode = true;
        _enteringFocusModeTriggered = true;
        _overrideActiveIndex = index;
        _seekTargetTimestamp = targetPosition;
        _seekSetTime = DateTime.now();
      });
      _scheduleScrollIfNeeded(force: true, itemCenters: _currentItemCenters);
    }
  }

  int _activeLineIndex(List<LyricLine> displayLines) {
    if (displayLines.isEmpty || !_hasTimedLyrics(displayLines)) return -1;

    int calculateNormal() {
      final current = math.max(
        0,
        _adjustedPositionMilliseconds + _lyricsActiveLineSeekEpsilonMilliseconds,
      );
      int low = 0;
      int high = displayLines.length - 1;
      int answer = 0;

      while (low <= high) {
        final mid = (low + high) >> 1;
        final midMs = displayLines[mid].timestamp.inMilliseconds;
        if (midMs <= current) {
          answer = mid;
          low = mid + 1;
        } else {
          high = mid - 1;
        }
      }
      return answer;
    }

    final normalIndex = calculateNormal();
    final overrideIdx = _overrideActiveIndex;
    final targetTs = _seekTargetTimestamp;

    if (overrideIdx != null && targetTs != null) {
      final timeSinceSeek = DateTime.now().difference(_seekSetTime);
      final positionDiff = (widget.position - targetTs).abs();
      if (positionDiff < const Duration(milliseconds: 800) ||
          timeSinceSeek > const Duration(seconds: 2)) {
        _overrideActiveIndex = null;
        _seekTargetTimestamp = null;
        return normalIndex;
      } else {
        return overrideIdx;
      }
    }

    return normalIndex;
  }

  bool _hasTimedLyrics(List<LyricLine> displayLines) {
    return displayLines.any((line) => line.isTimed);
  }

  int get _adjustedPositionMilliseconds {
    return widget.position.inMilliseconds - _timelineOffsetMilliseconds;
  }

  int get _timelineOffsetMilliseconds {
    return (_timelineOffsetSeconds * 1000).round();
  }

  double _timelineOffsetToSeconds(Duration? offset) {
    final seconds = (offset?.inMilliseconds ?? 0) / 1000.0;
    return _normalizeTimelineOffsetSeconds(seconds);
  }

  double _normalizeTimelineOffsetSeconds(double value) {
    final clamped = value.clamp(
      _timelineOffsetMinSeconds,
      _timelineOffsetMaxSeconds,
    );
    return (clamped * 10).roundToDouble() / 10.0;
  }

  Future<void> _showTimelineAdjustmentPanel(
    List<LyricLine> displayLines,
  ) async {
    if (!_hasTimedLyrics(displayLines)) return;

    Future<void> commitOffset(double value) async {
      final normalized = _normalizeTimelineOffsetSeconds(value);
      if (!mounted) return;
      if (_timelineOffsetSeconds != normalized) {
        setState(() {
          _timelineOffsetSeconds = normalized;
        });
      }
      await _lyricsControllerActions.updateLyricsTimelineOffsetForCurrentSong(
        Duration(milliseconds: (normalized * 1000).round()),
      );
    }

    await showTimelineAdjustmentDialog(
      context,
      initialTimelineOffsetSeconds: _timelineOffsetSeconds,
      onPreviewChanged: (timelineOffsetSeconds) {
        if (!mounted) return;
        if (_timelineOffsetSeconds == timelineOffsetSeconds) {
          return;
        }
        setState(() {
          _timelineOffsetSeconds = timelineOffsetSeconds;
        });
      },
      onCommit: (timelineOffset) async {
        await commitOffset(timelineOffset.inMilliseconds / 1000.0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _writeLog('build: position=${widget.position.inMilliseconds}ms');
    final l10n = AppLocalizations.of(context)!;
    final lyricsState = ref.watch(lyricsControllerProvider);
    final currentSong = ref.watch(audioCurrentMusicProvider);
    final currentSongTaskState = _taskStateForSongPath(currentSong?.path);
    final lyricsStyle = ref.watch(
      settingsServiceProvider.select((settings) => settings.lyricsStyle),
    );
    final isSmallWin = ref.watch(
      settingsServiceProvider.select((settings) => settings.isSmallWindowMode),
    );
    final lyricsForDisplay = _lyricsForDisplay();
    final displayLyrics = _displayLyrics(lyricsState, lyricsForDisplay);
    final displayLines = displayLyrics?.syncedLines ?? const [];
    final displayPlainLyrics = displayLyrics?.plainText ?? '';
    final layoutRevision = ref.watch(lyricsLayoutRevisionProvider);
    final bool isLowMidEnd = ref.watch(isLowMidEndDeviceProvider);
    final hasRenderableLyrics =
        lyricsState.hasLyrics &&
        displayLyrics != null &&
        (displayLyrics.syncedLines.isNotEmpty ||
            displayLyrics.plainText.trim().isNotEmpty);
    final hasCurrentSong = currentSong != null;
    final accent = widget.accentColor ?? Theme.of(context).colorScheme.primary;
    final lyrics = displayLyrics;
    final hasTimedLyrics = _hasTimedLyrics(displayLines);
    final isGenerating = currentSongTaskState.isGenerationBusy;
    final effectiveLyricsStyle = lyricsStyle;
    final userFontScale = ref.watch(
      settingsServiceProvider.select((settings) =>
          effectiveLyricsStyle == LyricsStyle.apple
              ? settings.lyricsFontScaleApple
              : settings.lyricsFontScaleTraditional),
    );
    final textColor = widget.textColor ?? Colors.white;
    final secondaryTextColor =
        widget.secondaryTextColor ?? textColor.withValues(alpha: PlaybackPageUiTuning.appleLyricsInactiveOpacity);

    if (!hasRenderableLyrics) {
      final canGenerateLyrics = shouldShowGenerateLyricsButton(
        hasCurrentSong: hasCurrentSong,
      );
      return LyricsPanelEmptyState(
        accentColor: accent,
        textColor: textColor,
        isLoading: lyricsState.isLyricsLoading,
        isGenerating: currentSongTaskState.isGenerationBusy,
        canGenerateLyrics: canGenerateLyrics,
        generateButtonLabel: _buildGenerateButtonLabel(
          l10n,
          currentSongTaskState,
        ),
        bottomSpacerHeight: widget.bottomSpacerHeight,
        bottomTabBarHeight: widget.bottomTabBarHeight,
        onGeneratePressed: () async {
          if (!await checkProGate(context, ref, feature: ProFeature.aiLyrics)) {
            return;
          }
          if (!context.mounted || !mounted) return;
          if (await _ensureLyricsApiKey()) {
            if (!mounted) return;
            final errorMessage = await _lyricsControllerActions
                .generateLyricsForCurrentSong();
            if (errorMessage != null) {
              _showGenerationErrorSnack(errorMessage);
            }
          }
        },
        onContextMenu: (position) {
          _showContextMenu(
            context,
            position,
            lyricsState: lyricsState,
            taskState: currentSongTaskState,
            displayLines: displayLines,
            displayPlainLyrics: displayPlainLyrics,
            hasCurrentSong: hasCurrentSong,
            lyricsFontScale: userFontScale,
            requeryOnly: true,
          );
        },
      );
    }

    final renderedLines = hasTimedLyrics
        ? displayLines
        : _plainLyricsLines(displayPlainLyrics);

    return LayoutBuilder(
      builder: (context, constraints) {
        _writeLog('LayoutBuilder: maxWidth=${constraints.maxWidth} maxHeight=${constraints.maxHeight}');
        final double screenWidth = MediaQuery.sizeOf(context).width;
        final isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait) || isSmallWin;
        final double panelWidth = constraints.maxWidth;

        // Base scale based on screen width/resolution
        double baseScale;
        if (screenWidth <= PlaybackPageUiTuning.lyricsBaseScaleSmallScreenWidth) {
          baseScale = PlaybackPageUiTuning.lyricsMaxBaseScale;
        } else if (screenWidth >= PlaybackPageUiTuning.lyricsBaseScaleLargeScreenWidth) {
          baseScale = PlaybackPageUiTuning.lyricsMinBaseScale;
        } else {
          baseScale = PlaybackPageUiTuning.lyricsMaxBaseScale -
              (screenWidth - PlaybackPageUiTuning.lyricsBaseScaleSmallScreenWidth) *
                  (PlaybackPageUiTuning.lyricsMaxBaseScale - PlaybackPageUiTuning.lyricsMinBaseScale) /
                  (PlaybackPageUiTuning.lyricsBaseScaleLargeScreenWidth - PlaybackPageUiTuning.lyricsBaseScaleSmallScreenWidth);
        }

        // Panel width factor: larger width -> larger font
        // For both traditional and Apple scrolling lyrics, we clamp the panel width used for font scaling
        // to prevent the text from becoming too large on wide screens and restricting user font scale adjustments.
        final double appleClamp = isPortrait
            ? PlaybackPageUiTuning.appleLyricsMaxWidthClamp
            : PlaybackPageUiTuning.appleLyricsLandscapeMaxWidthClamp;
        final double effectivePanelWidth = effectiveLyricsStyle == LyricsStyle.traditional
            ? panelWidth.clamp(0.0, PlaybackPageUiTuning.traditionalLyricsMaxWidthClamp)
            : panelWidth.clamp(0.0, appleClamp);

        double panelWidthFactor;
        if (effectivePanelWidth >= PlaybackPageUiTuning.lyricsPanelWidthReference) {
          if (effectiveLyricsStyle == LyricsStyle.traditional) {
            // Traditional scrolling lyrics should not increase in font size as width increases
            panelWidthFactor = 1.0;
          } else {
            panelWidthFactor = 1.0 + (effectivePanelWidth - PlaybackPageUiTuning.lyricsPanelWidthReference) *
                    PlaybackPageUiTuning.lyricsPanelWidthGrowFactor;
          }
        } else {
          panelWidthFactor = 1.0 - (PlaybackPageUiTuning.lyricsPanelWidthReference - effectivePanelWidth) *
                  PlaybackPageUiTuning.lyricsPanelWidthShrinkFactor;
        }

        // Clamp the base adaptive scale (baseScale * panelWidthFactor) before multiplying by userFontScale,
        // so that userFontScale can scale the font size up and down linearly without being prematurely clamped.
        final double minScaleLimit = effectiveLyricsStyle == LyricsStyle.traditional
            ? 1.0
            : ((isPortrait || isSmallWin) ? PlaybackPageUiTuning.lyricsMinFontScale : SettingsService.minLyricsFontScale);
        double baseAdaptiveScale = (baseScale * panelWidthFactor).clamp(
          minScaleLimit,
          PlaybackPageUiTuning.lyricsMaxFontScale,
        );

        // Adapt for high resolution screens in Apple lyrics mode, scaling up smoothly
        double effectiveMaxFontScale = PlaybackPageUiTuning.lyricsMaxFontScale;
        double effectiveMinFontScale = SettingsService.minLyricsFontScale;
        if (effectiveLyricsStyle == LyricsStyle.apple &&
            screenWidth > PlaybackPageUiTuning.appleLyricsBaseScreenWidth) {
          final double highResFactor = 1.0 +
              (screenWidth - PlaybackPageUiTuning.appleLyricsBaseScreenWidth) *
                  PlaybackPageUiTuning.appleLyricsHighResSlope;
          baseAdaptiveScale *= highResFactor;
          effectiveMaxFontScale *= highResFactor;
        }

        // Apply portrait / tablet adjustments
        if (isPortrait) {
          if (effectiveLyricsStyle == LyricsStyle.apple) {
            if (screenWidth >= 600) {
              // Apple-style lyrics on iPad (tablet) portrait mode scaled by 1.5x
              baseAdaptiveScale *= 1.5;
              effectiveMaxFontScale *= 1.5;
            } else {
              // Apple-style lyrics on mobile (phone) portrait mode scaled by 1.2x
              baseAdaptiveScale *= 1.2;
              effectiveMaxFontScale *= 1.2;
            }
          } else {
            // Traditional lyrics in portrait mode scaled by 1.2x
            baseAdaptiveScale *= 1.2;
            effectiveMaxFontScale *= 1.2;
          }
        }

        // Apply a 1.5x scale factor for Apple-style lyrics in landscape orientation (not in small window mode)
        if (effectiveLyricsStyle == LyricsStyle.apple && !isPortrait && !isSmallWin) {
          baseAdaptiveScale *= 1.5;
          effectiveMaxFontScale *= 1.5;
          // Keep effectiveMinFontScale at SettingsService.minLyricsFontScale in landscape so manual adjustment can scale down properly.
        }

        // Scale Apple lyrics base font sizes up by 1.1x in landscape orientation as requested (making original 110% the new 100%)
        if (effectiveLyricsStyle == LyricsStyle.apple && !isPortrait) {
          baseAdaptiveScale *= 1.1;
          effectiveMaxFontScale *= 1.1;
          effectiveMinFontScale *= 1.1;
        }

        final double calculatedFontScale = (baseAdaptiveScale * userFontScale).clamp(
          effectiveMinFontScale,
          effectiveMaxFontScale,
        );

        final lineMetrics = _measureLineMetrics(
          lines: renderedLines,
          lyrics: lyrics,
          maxWidth: constraints.maxWidth,
          lyricsFontScale: calculatedFontScale,
          hasTimedLyrics: hasTimedLyrics,
          context: context,
          lyricsStyle: effectiveLyricsStyle,
        );
        final lineHeights = lineMetrics.heights;
        final itemCenters = lineMetrics.itemCenters;
        final anchorCenters = lineMetrics.anchorCenters;
        _currentLineHeights = lineHeights;
        _currentItemCenters = itemCenters;

        // --- SCROLL JITTER MITIGATION ---
        if (_scrollController.hasClients &&
            _oldItemCenters != null &&
            _oldLineHeights != null &&
            _oldItemCenters!.length == itemCenters.length) {
          final currentOffset = _scrollController.offset;
          final k = _findClosestLineIndex(currentOffset, _oldItemCenters!);
          if (k >= 0 && k < itemCenters.length) {
            final oldTop = _oldItemCenters![k] - _oldLineHeights![k] / 2;
            final newTop = itemCenters[k] - lineHeights[k] / 2;
            final delta = newTop - oldTop;
            _writeLog('JitterMitigation: k=$k, oldTop=$oldTop, newTop=$newTop, delta=$delta');
            if (delta.abs() > 0.01) {
              final newOffset = currentOffset + delta;
              _scrollController.position.correctPixels(newOffset);
              _writeLog('JitterMitigation: corrected scroll pixels to $newOffset');
              if (kDebugMode) {
                debugPrint(
                  '[LyricsPanel] Anti-jitter scroll correction: '
                  'anchor line=$k, delta=${delta.toStringAsFixed(1)}, '
                  'offset: ${currentOffset.toStringAsFixed(1)} -> ${newOffset.toStringAsFixed(1)}',
                );
              }
            }
          }
        }
        _oldItemCenters = itemCenters;
        _oldLineHeights = lineHeights;
        // ---------------------------------

        _attachScrollActivityListener();

        final layoutRevisionChanged = layoutRevision != _lastLayoutRevision;
        final activeIndex = hasTimedLyrics
            ? _activeLineIndex(displayLines)
            : -1;
        final focusedIndex = _isDraggingLyrics && _dragCurrentLine != null
            ? _dragCurrentLine!
            : activeIndex;
        _logLyricsDebug(
          displayLines: displayLines,
          activeIndex: focusedIndex,
          hasTimedLyrics: hasTimedLyrics,
        );
        if (hasTimedLyrics) {
          if (layoutRevisionChanged) {
            if (kDebugMode) {
              _logLayoutMetrics(
                displayLines: displayLines,
                lyrics: lyrics,
                lineHeights: lineHeights,
                itemCenters: itemCenters,
                anchorCenters: anchorCenters,
                activeIndex: activeIndex,
                viewportHeight: constraints.maxHeight,
              );
            }
            _handleLyricsLayoutRevisionChanged(
              layoutRevision: layoutRevision,
              hasTimedLyrics: hasTimedLyrics,
              displayLines: displayLines,
              itemCenters: itemCenters,
            );
          } else {
            final bool transitionEnded =
                _lastBuiltIsTransitioning == true && widget.isTransitioning == false;
            final bool generationJustFinished =
                _lastBuiltIsGenerating == true && !isGenerating;
            final bool displayLinesChanged =
                _lastBuiltDisplayLines != null && !listEquals(_lastBuiltDisplayLines, displayLines);
            final bool songChanged = _lastBuiltCurrentSong != null &&
                _lastBuiltCurrentSong?.path != currentSong?.path;

            final bool forceScroll = transitionEnded ||
                generationJustFinished ||
                (displayLinesChanged && !isGenerating) ||
                songChanged;
            if (generationJustFinished ||
                (displayLinesChanged && !isGenerating) ||
                songChanged) {
              _lastActiveIndex = -1;
              _lastScrollDelta = 0.0;
              _scrollTriggerTime = 0;
            }

            _scheduleScrollIfNeeded(
              force: forceScroll,
              animate: !transitionEnded && !songChanged && !displayLinesChanged,
              displayLines: displayLines,
              itemCenters: itemCenters,
            );
          }
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _reportActiveLyricTopOffset(
            activeIndex: activeIndex,
            hasTimedLyrics: hasTimedLyrics,
            isDraggingLyrics: _isDraggingLyrics,
            dragCurrentLine: _dragCurrentLine,
            lineHeights: lineHeights,
            itemCenters: itemCenters,
          );
        });

        final bool needsRebuild = _cachedLyricsView == null ||
            focusedIndex != _lastBuiltActiveIndex ||
            displayLines != _lastBuiltDisplayLines ||
            constraints.maxWidth != _lastBuiltMaxWidth ||
            constraints.maxHeight != _lastBuiltMaxHeight ||
            calculatedFontScale != _lastBuiltFontScale ||
            _isAutoScrollPaused != _lastBuiltAutoScrollPaused ||
            textColor != _lastBuiltTextColor ||
            secondaryTextColor != _lastBuiltSecondaryTextColor ||
            lyricsState != _lastBuiltLyricsState ||
            currentSong != _lastBuiltCurrentSong ||
            effectiveLyricsStyle != _lastBuiltLyricsStyle ||
            _isFocusMode != _lastBuiltIsFocusMode ||
            _scrollTriggerTime != _lastBuiltScrollTriggerTime ||
            _isEnteringFocusMode != _lastBuiltIsEnteringFocusMode ||
            _firstVisibleIndex != _lastBuiltFirstVisibleIndex ||
            isSmallWin != _lastBuiltIsSmallWin ||
            isGenerating != _lastBuiltIsGenerating ||
            widget.isTransitioning != _lastBuiltIsTransitioning ||
            isLowMidEnd != _lastBuiltIsLowMidEnd;

        if (needsRebuild) {
          _lastBuiltActiveIndex = focusedIndex;
          _lastBuiltDisplayLines = displayLines;
          _lastBuiltMaxWidth = constraints.maxWidth;
          _lastBuiltMaxHeight = constraints.maxHeight;
          _lastBuiltFontScale = calculatedFontScale;
          _lastBuiltAutoScrollPaused = _isAutoScrollPaused;
          _lastBuiltTextColor = textColor;
          _lastBuiltSecondaryTextColor = secondaryTextColor;
          _lastBuiltLyricsState = lyricsState;
          _lastBuiltCurrentSong = currentSong;
          _lastBuiltLyricsStyle = effectiveLyricsStyle;
          _lastBuiltIsFocusMode = _isFocusMode;
          _lastBuiltScrollTriggerTime = _scrollTriggerTime;
          _lastBuiltIsEnteringFocusMode = _isEnteringFocusMode;
          _lastBuiltFirstVisibleIndex = _firstVisibleIndex;
          _lastBuiltIsSmallWin = isSmallWin;
          _lastBuiltIsGenerating = isGenerating;
          _lastBuiltIsTransitioning = widget.isTransitioning;
          _lastBuiltIsLowMidEnd = isLowMidEnd;

          _cachedLyricsView = LyricsPanelTimedLyricsView(
            lyrics: lyrics,
            lyricsState: lyricsState,
            displayLines: renderedLines,
            lineHeights: lineHeights,
            hasTimedLyrics: hasTimedLyrics,
            activeIndex: focusedIndex,
            isAutoScrollPaused: _isAutoScrollPaused,
            lyricsFontScale: calculatedFontScale,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            scrollController: _scrollController,
            scrollBehavior: _lyricsScrollBehavior(context),
            onVerticalDragStart: hasTimedLyrics && effectiveLyricsStyle == LyricsStyle.traditional
                ? (_) => _beginLyricsDrag(displayLines)
                : null,
            onVerticalDragUpdate: hasTimedLyrics && effectiveLyricsStyle == LyricsStyle.traditional
                ? (details) =>
                      _updateLyricsDrag(details, displayLines, itemCenters)
                : null,
            onVerticalDragEnd: hasTimedLyrics && effectiveLyricsStyle == LyricsStyle.traditional
                ? (_) {
                    unawaited(_endLyricsDrag(displayLines));
                  }
                : null,
            onVerticalDragCancel: hasTimedLyrics && effectiveLyricsStyle == LyricsStyle.traditional
                ? () {
                    unawaited(_endLyricsDrag(displayLines));
                  }
                : null,
            onContextMenu: (position) {
              _showContextMenu(
                context,
                position,
                lyricsState: lyricsState,
                taskState: currentSongTaskState,
                displayLines: displayLines,
                displayPlainLyrics: displayPlainLyrics,
                hasCurrentSong: hasCurrentSong,
                lyricsFontScale: userFontScale,
              );
            },
            bottomSpacerHeight: widget.bottomSpacerHeight,
            bottomTabBarHeight: widget.bottomTabBarHeight,
            lyricsStyle: effectiveLyricsStyle,
            isFocusMode: _isFocusMode,
            onLineTapped: (index) {
              _handleLineTapped(index, renderedLines);
            },
            scrollDelta: _lastScrollDelta,
            scrollTriggerTime: _scrollTriggerTime,
            isEnteringFocusMode: _isEnteringFocusMode,
            firstVisibleIndex: _firstVisibleIndex,
            isSmallWin: isSmallWin,
            maxWidth: constraints.maxWidth,
            isGenerating: isGenerating,
            isTransitioning: widget.isTransitioning,
            isLowMidEnd: isLowMidEnd,
          );
        }

        final mainView = _cachedLyricsView!;
        if (effectiveLyricsStyle == LyricsStyle.apple && hasTimedLyrics) {
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              _activePointers++;
            },
            onPointerUp: (event) {
              _activePointers = math.max(0, _activePointers - 1);
              if (_activePointers == 0) {
                _scheduleScrollIfNeeded(itemCenters: itemCenters);
              }
            },
            onPointerCancel: (event) {
              _activePointers = 0;
              _scheduleScrollIfNeeded(itemCenters: itemCenters);
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) {
                  if (notification.direction != ScrollDirection.idle) {
                    if (_isFocusMode) {
                      setState(() {
                        _isFocusMode = false;
                      });
                    }
                  }
                }
                return false;
              },
              child: mainView,
            ),
          );
        }

        return mainView;
      },
    );
  }

  void _logLyricsDebug({
    required List<LyricLine> displayLines,
    required int activeIndex,
    required bool hasTimedLyrics,
  }) {
    if (!kDebugMode) return;

    final adjustedMs = _adjustedPositionMilliseconds;
    final now = DateTime.now();
    final activeChanged = activeIndex != _lastDebugActiveIndex;
    final positionChanged = (adjustedMs - _lastDebugPositionMs).abs() >= 250;
    final timeElapsed = now.difference(_lastDebugLogAt);
    if (!activeChanged &&
        !positionChanged &&
        timeElapsed < const Duration(seconds: 1)) {
      return;
    }

    _lastDebugActiveIndex = activeIndex;
    _lastDebugPositionMs = adjustedMs;
    _lastDebugLogAt = now;

    // final activeTimestamp =
    //     (hasTimedLyrics &&
    //         activeIndex >= 0 &&
    //         activeIndex < displayLines.length)
    //     ? displayLines[activeIndex].timestamp.inMilliseconds
    //     : -1;
    // final offsetMs = _timelineOffsetMilliseconds;
    // final deltaMs = activeTimestamp >= 0 ? adjustedMs - activeTimestamp : 0;

    // debugPrint(
    //   '[LyricsPanel] pos=${_formatMs(adjustedMs)}ms '
    //   'raw=${_formatMs(widget.position.inMilliseconds)}ms '
    //   'offset=${_formatMs(offsetMs)}ms '
    //   'activeIndex=$activeIndex '
    //   'activeTs=${_formatMs(activeTimestamp)}ms '
    //   'delta=${_formatSignedMs(deltaMs)}ms '
    //   'lines=${displayLines.length}',
    // );
  }

  void _logLayoutMetrics({
    required List<LyricLine> displayLines,
    required MusicLyric? lyrics,
    required List<double> lineHeights,
    required List<double> itemCenters,
    required List<double> anchorCenters,
    required int activeIndex,
    required double viewportHeight,
  }) {
    if (!kDebugMode) return;
    if (activeIndex < 0 || activeIndex >= displayLines.length) return;

    final start = math.max(0, activeIndex - 3);
    final end = math.min(displayLines.length - 1, activeIndex + 3);
    final buffer = StringBuffer();
    // final scrollOffsetStr = _scrollController.hasClients
    //     ? _scrollController.offset.toStringAsFixed(1)
    //     : 'not_attached';
    // buffer.writeln(
    //   '[LyricsPanel] metrics activeIndex=$activeIndex '
    //   'viewport=${viewportHeight.toStringAsFixed(1)} '
    //   'scrollOffset=$scrollOffsetStr',
    // );
    for (var i = start; i <= end; i++) {
      final translated =
          lyrics
              ?.translatedLineAt(
                i,
                ref
                    .read(lyricsControllerProvider)
                    .lyricsTranslationLanguageCode,
              )
              .trim() ??
          '';
      buffer.writeln(
        '  idx=$i '
        'h=${lineHeights[i].toStringAsFixed(1)} '
        'itemC=${itemCenters[i].toStringAsFixed(1)} '
        'anchorC=${anchorCenters[i].toStringAsFixed(1)} '
        'transLen=${translated.length} '
        'textLen=${displayLines[i].text.length}',
      );
    }
    debugPrint(buffer.toString().trimRight());
  }

  // String _formatMs(int value) {
  //   return value.toString();
  // }
  //
  // String _formatSignedMs(int value) {
  //   if (value >= 0) return value.toString();
  //   return '-${value.abs()}';
  // }

  Future<void> _showSelectLyricsSourceDialog(
    MusicFile song,
    List<LyricsCacheRecord> sources,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final query = await _lyricsControllerActions.buildLyricsQueryForSong(song);
    final cacheKey = query?.cacheKey.trim() ?? '';
    if (cacheKey.isEmpty) return;

    final activePreference = await _lyricsControllerActions.getSelectedLyricSource(cacheKey);

    LyricsCacheSource activeSource = LyricsCacheSource.none;
    String activeLang = '';
    
    if (activePreference != null) {
      activeSource = activePreference.source;
      activeLang = activePreference.languageCode;
    } else {
      final fallbackOrder = [
        LyricsCacheSource.external,
        LyricsCacheSource.embedded,
        LyricsCacheSource.manualAdjust,
        LyricsCacheSource.aiTimeline,
        LyricsCacheSource.aiGenerate,
        LyricsCacheSource.ai,
        LyricsCacheSource.lrclib,
      ];
      for (final src in fallbackOrder) {
        if (sources.any((r) => r.source == src)) {
          activeSource = src;
          if (src.isAiSource) {
            activeLang = sources.firstWhere((r) => r.source == src).languageCode;
          }
          break;
        }
      }
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(l10n.selectLyricSource),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sources.map((record) {
                final isSelected = record.source == activeSource && record.languageCode == activeLang;
                String title = '';
                IconData icon;
                switch (record.source) {
                  case LyricsCacheSource.external:
                    title = l10n.externalLrcFile;
                    icon = Icons.file_present_rounded;
                    break;
                  case LyricsCacheSource.embedded:
                    title = l10n.embeddedLyrics;
                    icon = Icons.music_note_rounded;
                    break;
                  case LyricsCacheSource.manualAdjust:
                    title = l10n.manuallyAdjustedLyrics;
                    icon = Icons.edit_note_rounded;
                    break;
                  case LyricsCacheSource.lrclib:
                    title = l10n.lrclibOnlineLyrics;
                    icon = Icons.cloud_done_rounded;
                    break;
                  default:
                    if (record.source.isAiSource) {
                      final langSuffix = record.languageCode.isNotEmpty
                          ? ' (${getLanguageDisplayName(record.languageCode)})'
                          : '';
                      title = '${l10n.aiGeneratedLyrics}$langSuffix';
                      icon = Icons.auto_awesome_rounded;
                    } else {
                      title = record.source.dbValue;
                      icon = Icons.lyrics_rounded;
                    }
                }

                return ListTile(
                  leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : null),
                  title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
                  trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null,
                  onTap: () async {
                    Navigator.pop(context);
                    await _lyricsControllerActions.setSelectedLyricSource(
                      cacheKey,
                      record.source,
                      languageCode: record.languageCode,
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  String getLanguageDisplayName(String code) {
    if (code.isEmpty) return '';
    final l10n = AppLocalizations.of(context)!;
    final lower = code.toLowerCase();
    switch (lower) {
      case 'zh': return l10n.chineseLanguage;
      case 'en': return l10n.englishLanguage;
      case 'ja': return l10n.japaneseLanguage;
      case 'ko': return l10n.koreanLanguage;
      default: return code.toUpperCase();
    }
  }
}
