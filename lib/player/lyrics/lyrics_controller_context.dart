import 'dart:async';

import 'package:dio/dio.dart';

import 'package:vynody/models/lyric_line.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/lyrics/lyrics_ai_service.dart';
import 'package:vynody/player/lyrics/lyrics_ai_task_queue.dart';
import 'package:vynody/player/lyrics/lyrics_cache_repository.dart';
import 'package:vynody/player/lyrics/lyrics_generation_display_state.dart';
import 'package:vynody/player/lyrics/lyrics_controller_state.dart';
import 'package:vynody/player/lyrics/lyrics_generation_phase.dart';
import 'package:vynody/player/lyrics/lyrics_song_task_state.dart';
import 'package:vynody/player/lyrics/lyrics_service.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/settings/settings_service.dart';

class LyricsGenerationRuntime {
  int serial = 0;
  Completer<void>? completer;
  String? songPath;

  bool get isGenerating => completer != null;

  void start() {
    serial++;
    completer = Completer<void>();
  }

  void beginForSong(String path) {
    songPath = path;
    start();
  }

  void finish() {
    final currentCompleter = completer;
    if (currentCompleter != null && !currentCompleter.isCompleted) {
      currentCompleter.complete();
    }
    completer = null;
    songPath = null;
  }
}

class LyricsControllerContext {
  LyricsControllerContext({
    required this.db,
    required this.currentMusic,
    required this.queue,
    required this.currentIndex,
    required this.playerDuration,
    required this.isLyricsActive,
    required this.cacheSongDuration,
    required this.lyricsCacheRepository,
    required this.lyricsService,
    required this.settingsService,
    required this.lyricsAiService,
    required this.getState,
    required this.setState,
    required this.clearState,
    required this.setIsLyricsLoading,
    required this.setIsLyricsTranslating,
    required this.setLyricsTranslationStatus,
    required this.setLyricsGenerationStatus,
    required this.setLyricsGenerationDisplayState,
    required this.setHasLyrics,
    required this.setLyricsSearchAttempted,
    required this.setCurrentLyricsLines,
    required this.setCurrentLyricsText,
    required this.setLyricsGenerating,
    required this.startLyricsGenerationStatus,
    required this.clearLyricsGenerationStatus,
    required this.watchLyricsCacheForSong,
    required this.bumpRevision,
    required this.bumpLyricsLayoutRevision,
    required this.isLyricsPanelScrolling,
    required this.isProUnlocked,
    required this.logDebug,
  });

  final MetadataDatabase db;
  final MusicFile? Function() currentMusic;
  final List<MusicFile> Function() queue;
  final int Function() currentIndex;
  final Duration Function() playerDuration;
  final bool Function() isLyricsActive;
  final bool Function() isProUnlocked;
  final void Function(String path, int durationMillis) cacheSongDuration;
  final LyricsCacheRepository lyricsCacheRepository;
  final LyricsService lyricsService;
  final SettingsService settingsService;
  final LyricsAiService lyricsAiService;
  final LyricsControllerState Function() getState;
  final void Function(LyricsControllerState state) setState;
  final void Function({bool notify, bool preserveTaskState}) clearState;
  final void Function(bool value) setIsLyricsLoading;
  final void Function(bool value) setIsLyricsTranslating;
  final void Function(String value) setLyricsTranslationStatus;
  final void Function(String value) setLyricsGenerationStatus;
  final void Function(LyricsGenerationDisplayState value)
  setLyricsGenerationDisplayState;
  final void Function(bool value) setHasLyrics;
  final void Function(bool value) setLyricsSearchAttempted;
  final void Function(List<LyricLine> value) setCurrentLyricsLines;
  final void Function(String value) setCurrentLyricsText;
  final void Function(
    bool value, {
    LyricsGenerationPhase? phase,
    double? progress,
  })
  setLyricsGenerating;
  final void Function(String value) startLyricsGenerationStatus;
  final void Function() clearLyricsGenerationStatus;
  final Future<void> Function(MusicFile song) watchLyricsCacheForSong;
  final void Function() bumpRevision;
  final void Function() bumpLyricsLayoutRevision;
  final bool Function() isLyricsPanelScrolling;
  final void Function(String message) logDebug;

  final LyricsGenerationRuntime lyricsGeneration = LyricsGenerationRuntime();
  final LyricsAiTaskQueue lyricsAiTaskQueue = LyricsAiTaskQueue();
  final Map<String, LyricsSongTaskState> songTaskStates =
      <String, LyricsSongTaskState>{};
  final Set<String> translatedLyricsKeys = <String>{};
  final Set<String> translationInFlightKeys = <String>{};
  final Map<
    String,
    ({
      String songPath,
      String cacheKey,
      String languageCode,
      String lyricsId,
      List<String> translatedLines,
      String translatedText,
      bool completed,
    })
  >
  pendingLyricsTranslationUpdates =
      <
        String,
        ({
          String songPath,
          String cacheKey,
          String languageCode,
          String lyricsId,
          List<String> translatedLines,
          String translatedText,
          bool completed,
        })
      >{};
  int lyricsRequestSerial = 0;
  int lyricsRetrySerial = 0;
  CancelToken? lyricsFetchCancelToken;
  CancelToken? lyricsAiCancelToken;
  LyricsGenerationDisplayState lyricsGenerationDisplayState =
      const LyricsGenerationDisplayState();

  LyricsControllerState get state => getState();

  bool updateLyricsGenerationDisplayState(
    LyricsGenerationDisplayState nextState,
  ) {
    if (lyricsGenerationDisplayState == nextState) {
      return false;
    }
    lyricsGenerationDisplayState = nextState;
    setLyricsGenerationDisplayState(nextState);
    return true;
  }

  LyricsSongTaskState taskStateForSong(String path) {
    return songTaskStates[path] ?? const LyricsSongTaskState();
  }

  void updateSongTaskState(
    String path,
    LyricsSongTaskState Function(LyricsSongTaskState current) update,
  ) {
    final current = taskStateForSong(path);
    final next = update(current);
    if (next == current) {
      return;
    }

    if (next.isAnyBusy) {
      songTaskStates[path] = next;
    } else {
      songTaskStates.remove(path);
    }
    bumpRevision();
  }

  bool isLyricsGenerationBusyForSong(String path) {
    return taskStateForSong(path).isGenerationBusy;
  }

  bool isLyricsTranslationBusyForSong(String path) {
    return taskStateForSong(path).isTranslationBusy;
  }

  bool isLyricsTaskBusyForSong(String path) {
    return taskStateForSong(path).isAnyBusy;
  }

  void stashPendingLyricsTranslationUpdate({
    required String songPath,
    required String cacheKey,
    required String languageCode,
    required String lyricsId,
    required List<String> translatedLines,
    required String translatedText,
    bool completed = false,
  }) {
    final existing = pendingLyricsTranslationUpdates[songPath];
    pendingLyricsTranslationUpdates[songPath] = (
      songPath: songPath,
      cacheKey: cacheKey,
      languageCode: languageCode,
      lyricsId: lyricsId,
      translatedLines: translatedLines,
      translatedText: translatedText,
      completed: completed || existing?.completed == true,
    );
  }

  void clearPendingLyricsTranslationUpdatesForSong(String songPath) {
    pendingLyricsTranslationUpdates.remove(songPath);
  }
}
