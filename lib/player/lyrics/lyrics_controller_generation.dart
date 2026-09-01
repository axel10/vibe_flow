import 'dart:async';

import 'package:dio/dio.dart' show CancelToken, DioException;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vynody/models/lyric_line.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_lyric.dart';
import 'package:vynody/models/music_lyric_translation.dart';
import 'package:vynody/utils/localized_text.dart';
import 'package:vynody/utils/lrc_utils.dart';
import 'package:vynody/utils/lyrics_id_utils.dart';
import 'package:vynody/player/lyrics/lyrics_cache_models.dart';
import 'package:vynody/player/lyrics/lyrics_controller_context.dart';
import 'package:vynody/player/lyrics/lyrics_generation_display_state.dart';
import 'package:vynody/player/lyrics/lyrics_controller_utils.dart';
import 'package:vynody/player/lyrics/lyrics_generation_phase.dart';
import 'package:vynody/player/lyrics/lyrics_generation_result.dart';
import 'package:vynody/player/lyrics/lyrics_ai_service.dart';
import 'package:vynody/player/lyrics/lyrics_service.dart';

typedef _LyricsGenerationInvoker =
    Future<LyricsGenerationResult> Function(
      CancelToken cancelToken, {
      required void Function(double progress) onUploadProgress,
      required void Function(String stage) onStageChanged,
      required void Function(String partialText, bool isFinal) onProgress,
    });

class _LyricsGenerationSession {
  _LyricsGenerationSession({
    required this.id,
    required this.songPath,
    required this.baseStatusLabel,
  });

  final int id;
  final String songPath;
  final String baseStatusLabel;
}

class LyricsGenerationCoordinator {
  LyricsGenerationCoordinator(this._context, this._support);

  final LyricsControllerContext _context;
  final LyricsControllerSupport _support;

  _LyricsGenerationSession _beginLyricsGeneration(
    MusicFile song, {
    required String statusLabel,
    required String modelLabel,
  }) {
    _support.cancelOngoingLyricsFetch(reason: 'lyrics generation started');
    _context.lyricsGeneration.beginForSong(song.path);
    _context.setLyricsSearchAttempted(true);
    _context.startLyricsGenerationStatus(statusLabel);
    _context.updateLyricsGenerationDisplayState(
      LyricsGenerationDisplayState(
        songPath: song.path,
        statusLabel: statusLabel,
        modelLabel: modelLabel,
        phase: LyricsGenerationPhase.uploading,
        progress: 0.0,
        retryAttempt: 0,
        maxRetryCount: LyricsAiService.maxGenerationRetries,
      ),
    );
    _context.updateSongTaskState(
      song.path,
      (current) => current.copyWith(
        isGenerationQueued: false,
        isGenerationRunning: true,
        generationPhase: LyricsGenerationPhase.uploading,
        generationProgress: 0.0,
        generationStatus: statusLabel,
      ),
    );

    return _LyricsGenerationSession(
      id: _context.lyricsGeneration.serial,
      songPath: song.path,
      baseStatusLabel: statusLabel,
    );
  }

  void _queueLyricsGeneration(
    MusicFile song, {
    required String statusLabel,
    required String modelLabel,
  }) {
    _context.updateSongTaskState(
      song.path,
      (current) => current.copyWith(
        isGenerationQueued: true,
        generationStatus: statusLabel,
      ),
    );
    _context.updateLyricsGenerationDisplayState(
      LyricsGenerationDisplayState(
        songPath: song.path,
        statusLabel: statusLabel,
        modelLabel: modelLabel,
        retryAttempt: 0,
        maxRetryCount: LyricsAiService.maxGenerationRetries,
      ),
    );
  }

  bool _isActiveLyricsGeneration(_LyricsGenerationSession session) {
    return session.id == _context.lyricsGeneration.serial;
  }

  bool _isCurrentSong(_LyricsGenerationSession session) {
    return _context.currentMusic()?.path == session.songPath;
  }

  void _updateLyricsGenerationStage(
    _LyricsGenerationSession session,
    String stage,
  ) {
    if (!_isActiveLyricsGeneration(session)) return;
    if (!_isCurrentSong(session)) return;
    _support.setGenerationStage(stage);
    final current = _context.lyricsGenerationDisplayState;
    final stageStatus = _generationStageLabel(stage, session.baseStatusLabel);
    _context.setLyricsGenerationStatus(stageStatus);
    _context.updateLyricsGenerationDisplayState(
      current.copyWith(
        songPath: session.songPath,
        phase: switch (stage) {
          'downloading' => LyricsGenerationPhase.uploading,
          'transcoding' => LyricsGenerationPhase.transcoding,
          'uploading' => LyricsGenerationPhase.uploading,
          'processing' => LyricsGenerationPhase.processing,
          'requesting' => LyricsGenerationPhase.requesting,
          'generating' => LyricsGenerationPhase.generating,
          'retrying' => LyricsGenerationPhase.retrying,
          _ => LyricsGenerationPhase.idle,
        },
        progress: switch (stage) {
          'downloading' => 0.0,
          'transcoding' => 0.0,
          'uploading' => 0.0,
          'processing' => 1.0,
          'requesting' => 1.0,
          'generating' => 1.0,
          'retrying' => 1.0,
          _ => 0.0,
        },
        statusLabel: stageStatus,
        retryAttempt: stage == 'retrying'
            ? current.retryAttempt + 1
            : current.retryAttempt,
        maxRetryCount: LyricsAiService.maxGenerationRetries,
      ),
    );
    _context.updateSongTaskState(
      session.songPath,
      (currentState) => currentState.copyWith(generationStatus: stageStatus),
    );
  }

  String _generationStageLabel(String stage, String currentStatus) {
    final taskKind = _generationTaskKind(currentStatus);
    switch (stage) {
      case 'downloading':
        return _l10n().downloadingTab;
      case 'transcoding':
        return currentStatus;
      case 'uploading':
        return _l10n().uploadingSongFile;
      case 'processing':
        return _l10n().fileUploadedWaitingForReadiness;
      case 'requesting':
        return _l10n().requestingModelResponse;
      case 'generating':
        return _l10n().generatingTaskKind(taskKind);
      case 'retrying':
        return _l10n().retryingTaskKindGeneration(taskKind);
      default:
        return currentStatus.isNotEmpty
            ? currentStatus
            : _l10n().processing;
    }
  }

  String _generationTaskKind(String statusLabel) {
    if (statusLabel.contains('时间轴') ||
        statusLabel.toLowerCase().contains('timeline')) {
      return _l10n().timeline;
    }
    return _l10n().lyrics;
  }

  void _updateLyricsGenerationModelLabel(String? modelLabel) {
    final current = _context.lyricsGenerationDisplayState;
    _context.updateLyricsGenerationDisplayState(
      current.copyWith(modelLabel: modelLabel ?? ''),
    );
  }

  MusicLyric _buildGeneratedLyrics({
    required String text,
    required String source,
    Duration timelineOffset = Duration.zero,
    Map<String, MusicLyricTranslation> translations =
        const <String, MusicLyricTranslation>{},
  }) {
    final normalizedText = text.trim();
    final generatedLines = _parseGeneratedLyrics(normalizedText);
    return MusicLyric(
      id: LyricsIdUtils.fromLyricsText(normalizedText),
      syncedLines: generatedLines.isNotEmpty
          ? generatedLines
          : _support.buildLyricsLines(const [], normalizedText),
      plainText: normalizedText,
      source: source,
      timelineOffset: timelineOffset,
      translations: translations,
    );
  }

  void _publishGeneratedLyrics(
    _LyricsGenerationSession session, {
    required MusicFile song,
    required MusicLyric lyrics,
  }) {
    if (!_isActiveLyricsGeneration(session)) return;

    final updated = _support.replaceSongIfPath(
      song.path,
      (currentSong) => currentSong.copyWith(lyrics: lyrics),
    );
    if (updated != null) {
      unawaited(_support.restoreCachedTranslations(updated));
    }

    _context.updateSongTaskState(
      song.path,
      (current) => current.copyWith(
        generationPhase: LyricsGenerationPhase.generating,
        generationProgress: 1.0,
      ),
    );

    if (_isCurrentSong(session)) {
      _context.setHasLyrics(true);
      _context.setIsLyricsLoading(false);
      _context.setLyricsSearchAttempted(true);
      _context.setCurrentLyricsLines(lyrics.syncedLines);
      _context.setCurrentLyricsText(lyrics.plainText);
    }

    _context.bumpRevision();
  }

  void _finalizeLyricsGeneration(_LyricsGenerationSession session) {
    if (session.id != _context.lyricsGeneration.serial) return;

    _context.lyricsGeneration.finish();
    _context.updateSongTaskState(
      session.songPath,
      (current) => current.copyWith(
        isGenerationQueued: false,
        isGenerationRunning: false,
        generationPhase: LyricsGenerationPhase.idle,
        generationProgress: 0.0,
        generationStatus: '',
      ),
    );
    _context.clearLyricsGenerationStatus();
    _context.updateLyricsGenerationDisplayState(
      const LyricsGenerationDisplayState(),
    );
  }

  Future<String?> _runLyricsGeneration({
    required MusicFile song,
    required LyricsCacheSource databaseSource,
    required String statusLabel,
    required String modelLabel,
    required CancelToken cancelToken,
    required _LyricsGenerationInvoker invoke,
    Map<String, MusicLyricTranslation> Function()? translationProvider,
  }) async {
    final session = _beginLyricsGeneration(
      song,
      statusLabel: statusLabel,
      modelLabel: modelLabel,
    );
    String? lastProgressText;
    List<LyricLine> lastSyncedLines = const [];

    try {
      final result = await invoke(
        cancelToken,
        onUploadProgress: (progress) {
          if (!_isActiveLyricsGeneration(session)) {
            return;
          }

          _context.updateSongTaskState(
            session.songPath,
            (current) => current.copyWith(
              generationPhase: LyricsGenerationPhase.uploading,
              generationProgress: progress.clamp(0.0, 1.0),
            ),
          );
          final current = _context.lyricsGenerationDisplayState;
          _context.updateLyricsGenerationDisplayState(
            current.copyWith(
              songPath: session.songPath,
              phase: LyricsGenerationPhase.uploading,
              progress: progress.clamp(0.0, 1.0),
            ),
          );
        },
        onStageChanged: (stage) {
          _updateLyricsGenerationStage(session, stage);
        },
        onProgress: (partialText, isFinal) {
          if (!_isActiveLyricsGeneration(session)) {
            return;
          }

          final progressText = partialText.trim();
          if (progressText.isEmpty) return;
          lastProgressText = progressText;
          final progressLyrics = _buildGeneratedLyrics(
            text: progressText,
            source: _support.lyricsProviderTag(),
            timelineOffset: song.lyrics?.timelineOffset ?? Duration.zero,
            translations:
                translationProvider?.call() ??
                const <String, MusicLyricTranslation>{},
          );
          lastSyncedLines = progressLyrics.syncedLines;
          _publishGeneratedLyrics(session, song: song, lyrics: progressLyrics);
          unawaited(_saveGeneratedLyricsToDatabase(
            song: song,
            generatedLyrics: progressLyrics.plainText,
            syncedLines: progressLyrics.syncedLines,
            source: databaseSource,
          ));
        },
      );

      if (!_isActiveLyricsGeneration(session)) {
        return null;
      }

      if (cancelToken.isCancelled) {
        if (lastProgressText != null && lastProgressText!.isNotEmpty) {
          await _saveGeneratedLyricsToDatabase(
            song: song,
            generatedLyrics: lastProgressText!,
            syncedLines: lastSyncedLines,
            source: databaseSource,
          );
        }
        return null;
      }

      if (!result.isSuccess ||
          result.text == null ||
          result.text!.trim().isEmpty) {
        if (lastProgressText != null && lastProgressText!.isNotEmpty) {
          await _saveGeneratedLyricsToDatabase(
            song: song,
            generatedLyrics: lastProgressText!,
            syncedLines: lastSyncedLines,
            source: databaseSource,
          );
        }
        return result.errorMessage ?? _l10n().generationFailed;
      }

      final lyrics = _buildGeneratedLyrics(
        text: result.text!,
        source: _support.lyricsProviderTag(),
        timelineOffset: song.lyrics?.timelineOffset ?? Duration.zero,
        translations:
            translationProvider?.call() ??
            const <String, MusicLyricTranslation>{},
      );
      _publishGeneratedLyrics(session, song: song, lyrics: lyrics);

      await _saveGeneratedLyricsToDatabase(
        song: song,
        generatedLyrics: lyrics.plainText,
        syncedLines: lyrics.syncedLines,
        source: databaseSource,
      );
      return null;
    } catch (e) {
      if (lastProgressText != null && lastProgressText!.isNotEmpty) {
        try {
          await _saveGeneratedLyricsToDatabase(
            song: song,
            generatedLyrics: lastProgressText!,
            syncedLines: lastSyncedLines,
            source: databaseSource,
          );
        } catch (dbError) {
          debugPrint('[LyricsController] Failed to save partial progress on error: $dbError');
        }
      }
      rethrow;
    } finally {
      _finalizeLyricsGeneration(session);
    }
  }

  Future<String?> _generateLyricsForSong(MusicFile song) async {
    if (!_context.isProUnlocked()) {
      return _l10n().proTrialExpired;
    }
    final cancelToken = CancelToken();
    _context.lyricsAiCancelToken = cancelToken;
    try {
      return await _runLyricsGeneration(
        song: song,
        databaseSource: LyricsCacheSource.aiGenerate,
        statusLabel: _l10n().generatingLyrics,
        modelLabel: _context.lyricsAiService.currentGenerationModelLabel,
        cancelToken: cancelToken,
        invoke:
            (cancelToken, {
              required onUploadProgress,
              required onStageChanged,
              required onProgress,
            }) {
              return _context.lyricsAiService.generateLyricsFromFile(
                filePath: song.path,
                songTitle: song.title,
                onModelLabelChanged: _updateLyricsGenerationModelLabel,
                onUploadProgress: onUploadProgress,
                onStageChanged: onStageChanged,
                onProgress: onProgress,
                cancelToken: cancelToken,
              );
            },
      );
    } catch (e) {
      if (cancelToken.isCancelled || (e is DioException && CancelToken.isCancel(e))) {
        debugPrint('[LyricsController] lyrics generation cancelled by user.');
        return null;
      }
      debugPrint('[LyricsController] Failed to generate lyrics: $e');
      return _l10n().lyricGenerationError('$e');
    } finally {
      if (_context.lyricsAiCancelToken == cancelToken) {
        _context.lyricsAiCancelToken = null;
      }
      _context.updateSongTaskState(
        song.path,
        (current) => current.copyWith(
          isGenerationQueued: false,
          isGenerationRunning: false,
          generationPhase: LyricsGenerationPhase.idle,
          generationProgress: 0.0,
          generationStatus: '',
        ),
      );
    }
  }

  Future<String?> _generateTimelineForSong(MusicFile song) async {
    if (!_context.isProUnlocked()) {
      return _l10n().proTrialExpired;
    }
    final sourceLyrics = _timelineSourceLyricsForSong(song).trim();
    if (sourceLyrics.isEmpty) {
      debugPrint(
        '[LyricsController] generate timeline skipped: no usable lyrics '
        'path=${song.path}',
      );
      return _l10n().noLyricsForTimelineGeneration;
    }

    final cancelToken = CancelToken();
    _context.lyricsAiCancelToken = cancelToken;
    try {
      return await _runLyricsGeneration(
        song: song,
        databaseSource: LyricsCacheSource.aiTimeline,
        statusLabel: _l10n().generatingTimeline,
        modelLabel: _context.lyricsAiService.currentGenerationModelLabel,
        cancelToken: cancelToken,
        translationProvider: () =>
            _support.songForPath(song.path)?.lyrics?.translations ??
            const <String, MusicLyricTranslation>{},
        invoke:
            (cancelToken, {
              required onUploadProgress,
              required onStageChanged,
              required onProgress,
            }) {
              return _context.lyricsAiService.generateTimelineFromLyrics(
                filePath: song.path,
                lyrics: sourceLyrics,
                songTitle: song.title,
                onModelLabelChanged: _updateLyricsGenerationModelLabel,
                onUploadProgress: onUploadProgress,
                onStageChanged: onStageChanged,
                onProgress: onProgress,
                cancelToken: cancelToken,
              );
            },
      );
    } catch (e) {
      if (cancelToken.isCancelled || (e is DioException && CancelToken.isCancel(e))) {
        debugPrint('[LyricsController] timeline generation cancelled by user.');
        return null;
      }
      debugPrint('[LyricsController] Failed to generate timeline: $e');
      return _l10n().timelineGenerationError('$e');
    } finally {
      if (_context.lyricsAiCancelToken == cancelToken) {
        _context.lyricsAiCancelToken = null;
      }
      _context.updateSongTaskState(
        song.path,
        (current) => current.copyWith(
          isGenerationQueued: false,
          isGenerationRunning: false,
          generationPhase: LyricsGenerationPhase.idle,
          generationProgress: 0.0,
          generationStatus: '',
        ),
      );
    }
  }

  Future<String?> generateLyricsForCurrentSong() async {
    if (!_context.isProUnlocked()) {
      return _l10n().proTrialExpired;
    }
    final song = _context.currentMusic();
    if (song == null) {
      debugPrint('[LyricsController] generate lyrics skipped: no current song');
      return _l10n().noCurrentSongAvailable;
    }
    if (_context.isLyricsGenerationBusyForSong(song.path)) {
      return _l10n().songAlreadyQueuedForGeneration;
    }

    _queueLyricsGeneration(
      song,
      statusLabel: _l10n().generatingLyrics,
      modelLabel: _context.lyricsAiService.currentGenerationModelLabel,
    );

    return _context.lyricsAiTaskQueue.enqueue(() {
      return _generateLyricsForSong(song);
    });
  }

  Future<String?> generateTimelineForCurrentSong() async {
    if (!_context.isProUnlocked()) {
      return _l10n().proTrialExpired;
    }
    final song = _context.currentMusic();
    if (song == null) {
      debugPrint(
        '[LyricsController] generate timeline skipped: no current song',
      );
      return _l10n().noCurrentSongAvailable;
    }
    if (_context.isLyricsGenerationBusyForSong(song.path)) {
      return _l10n().songAlreadyQueuedForGeneration;
    }

    _queueLyricsGeneration(
      song,
      statusLabel: _l10n().generatingTimeline,
      modelLabel: _context.lyricsAiService.currentGenerationModelLabel,
    );

    return _context.lyricsAiTaskQueue.enqueue(() {
      final activeSong = _support.songForPath(song.path) ?? song;
      return _generateTimelineForSong(activeSong);
    });
  }

  Future<String?> regenerateLyricsForCurrentSong() async {
    if (!_context.isProUnlocked()) {
      return _l10n().proTrialExpired;
    }
    final song = _context.currentMusic();
    if (song == null) {
      debugPrint(
        '[LyricsController] regenerate lyrics skipped: no current song',
      );
      return _l10n().noCurrentSongAvailable;
    }

    _support.clearLyricsStateForPath(song.path);
    _queueLyricsGeneration(
      song,
      statusLabel: _l10n().regeneratingLyrics,
      modelLabel: _context.lyricsAiService.currentGenerationModelLabel,
    );
    return _context.lyricsAiTaskQueue.enqueue(() {
      return _generateLyricsForSong(_support.songForPath(song.path) ?? song);
    });
  }

  Future<void> _saveGeneratedLyricsToDatabase({
    required MusicFile song,
    required String generatedLyrics,
    required List<LyricLine> syncedLines,
    LyricsCacheSource source = LyricsCacheSource.aiGenerate,
  }) async {
    try {
      final duration = await _support.resolveLyricsDuration(song);
      final query = LyricsQuery(
        filePath: song.path,
        fileName: song.name,
        title: _support.lyricsTitleForQuery(song),
        artist: _support.lyricsArtistForQuery(song),
        album: _support.lyricsAlbumForQuery(song),
        duration: duration,
      );
      final record = LyricsCacheRecord(
        cacheKey: query.cacheKey,
        source: source,
        isSynced: syncedLines.any((line) => line.isTimed),
        syncedLyrics: syncedLines.any((line) => line.isTimed)
            ? generatedLyrics
            : null,
        syncedLines: syncedLines,
        timelineOffsetMillis: song.lyrics?.timelineOffset.inMilliseconds ?? 0,
        updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
      );
      await _context.lyricsCacheRepository.saveLyricsCache(record);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_lyric_source_${record.cacheKey}', '${record.source.dbValue}|${record.languageCode}');
    } catch (e) {
      debugPrint('[LyricsController] Failed to cache generated lyrics: $e');
    }
  }

  List<LyricLine> _parseGeneratedLyrics(String? lyrics) {
    return LrcUtils.parseTimedLyrics(lyrics);
  }

  String _timelineSourceLyricsForSong(MusicFile song) {
    final lyrics = song.lyrics;
    if (lyrics != null && lyrics.plainText.trim().isNotEmpty) {
      return lyrics.plainText.trim();
    }

    return _context.getState().currentLyricsText.trim();
  }
}

AppLocalizations _l10n() => currentAppL10n;
