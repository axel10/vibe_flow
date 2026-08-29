import 'package:audio_core/audio_core.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';

part 'audio_snapshot.freezed.dart';

@freezed
abstract class AudioSnapshot with _$AudioSnapshot {
  const AudioSnapshot._();

  const factory AudioSnapshot({
    required bool isPlaying,
    @Default(false) bool isBuffering,
    required bool isTransitioning,
    required bool? isLastActionNext,
    required MusicFile? currentMusic,
    required Duration position,
    required Duration duration,
    required double volume,
    required bool isMuted,
    @Default(<MusicFile>[]) List<MusicFile> playbackQueue,
    required int currentIndex,
    required bool isRandomMode,
    required bool isShuffleRandomMode,
    required AppPlaybackMode playbackMode,
    required EqualizerConfig equalizerConfig,
    required VisualizerOptimizationOptions currentVisualizerOptions,
    @Default(<MusicFile>[]) List<MusicFile> randomHistory,
    @Default(<MusicFile>[]) List<MusicFile> randomQueue,
    required int? historyCursor,
    required int? deckCursor,
    required bool isVisualizerEnabled,
    required Color? dynamicStartColor,
    required Color? dynamicEndColor,
    @Default(<String, Color>{}) Map<String, Color> currentThemeColorsMap,
    required bool isLyricsActive,
    required Duration? sleepTimerRemaining,
    required Duration? sleepTimerDuration,
    @Default(1.0) double playbackSpeed,
  }) = _AudioSnapshot;

  double get progress =>
      duration.inMilliseconds > 0
          ? position.inMilliseconds / duration.inMilliseconds
          : 0.0;
}
