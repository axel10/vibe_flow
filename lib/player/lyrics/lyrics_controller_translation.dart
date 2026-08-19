import 'dart:async';

import 'package:dio/dio.dart' show CancelToken, DioException;
import 'package:flutter/foundation.dart';

import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_lyric.dart';
import 'package:vynody/models/music_lyric_translation.dart';
import 'package:vynody/utils/localized_text.dart';
import 'package:vynody/utils/language_code_utils.dart';
import 'package:vynody/player/lyrics/lyrics_cache_models.dart';
import 'package:vynody/player/lyrics/lyrics_controller_context.dart';
import 'package:vynody/player/lyrics/lyrics_controller_utils.dart';
import 'package:vynody/player/settings/settings_service.dart';

class _LyricsTranslationRequest {
  _LyricsTranslationRequest({
    required this.songPath,
    required this.cacheKey,
    required this.languageCode,
    required this.sourceLyrics,
    required this.lyricsId,
    required this.translationKey,
  });

  final String songPath;
  final String cacheKey;
  final String languageCode;
  final String sourceLyrics;
  final String lyricsId;
  final String translationKey;
}

class LyricsTranslationCoordinator {
  LyricsTranslationCoordinator(this._context, this._support);

  final LyricsControllerContext _context;
  final LyricsControllerSupport _support;

  Future<String?> translateLyricsForCurrentSong({
    String? targetLanguageCode,
  }) async {
    if (!_context.isProUnlocked()) {
      return _l10n().proTrialExpired;
    }
    final song = _context.currentMusic();
    if (song == null) {
      return _l10n().noCurrentSongAvailable;
    }

    final normalizedLanguageCode = LanguageCodeUtils.normalizeLanguageCode(
      targetLanguageCode ?? _context.state.lyricsTranslationLanguageCode,
    );
    if (normalizedLanguageCode.isEmpty) {
      return _l10n().invalidTargetLanguage;
    }
    if (_context.state.lyricsTranslationLanguageCode !=
        normalizedLanguageCode) {
      _context.setLyricsTranslationStatus('');
      _context.setState(
        _context.state.copyWith(
          lyricsTranslationLanguageCode: normalizedLanguageCode,
        ),
      );
    }

    if (_context.isLyricsTranslationBusyForSong(song.path)) {
      return _l10n().songAlreadyQueuedForTranslation;
    }

    _context.updateSongTaskState(
      song.path,
      (current) => current.copyWith(
        isTranslationQueued: true,
        translationStatus: _l10n().translatingLyrics,
      ),
    );

    return _context.lyricsAiTaskQueue.enqueue(() {
      return _translateLyricsForSong(
        song,
        normalizedLanguageCode: normalizedLanguageCode,
      );
    });
  }

  Future<String?> _translateLyricsForSong(
    MusicFile song, {
    required String normalizedLanguageCode,
  }) async {
    if (!_context.isProUnlocked()) {
      return _l10n().proTrialExpired;
    }
    final currentSong = _support.songForPath(song.path);
    if (currentSong == null) {
      return _l10n().songNoLongerExistsForTranslation;
    }

    final cancelToken = CancelToken();
    _context.lyricsAiCancelToken = cancelToken;

    try {
      final sourceLyrics = _lyricsSourceForTranslation(currentSong);
      if (sourceLyrics.isEmpty) {
        return _l10n().noLyricsAvailableForTranslation;
      }

      final request = await _buildLyricsTranslationRequest(
        currentSong,
        normalizedLanguageCode: normalizedLanguageCode,
        sourceLyrics: sourceLyrics,
      );
      if (request == null) {
        return null;
      }

      return await _runLyricsTranslationRequest(request, cancelToken);
    } catch (e) {
      if (cancelToken.isCancelled || (e is DioException && CancelToken.isCancel(e))) {
        debugPrint('[LyricsController] lyrics translation cancelled by user.');
        return null;
      }
      rethrow;
    } finally {
      if (_context.lyricsAiCancelToken == cancelToken) {
        _context.lyricsAiCancelToken = null;
      }
      _context.updateSongTaskState(
        song.path,
        (current) => current.copyWith(
          isTranslationQueued: false,
          isTranslationRunning: false,
          translationStatus: '',
        ),
      );
    }
  }

  Future<_LyricsTranslationRequest?> _buildLyricsTranslationRequest(
    MusicFile song, {
    required String normalizedLanguageCode,
    required String sourceLyrics,
  }) async {
    final query = await _support.buildLyricsQueryForSong(song);
    if (query == null) return null;

    final lyricsId = _support.lyricsIdForSong(song, sourceLyrics: sourceLyrics);
    if (lyricsId.isEmpty) return null;

    final translationKey = _lyricsTranslationCacheKey(
      query.cacheKey,
      normalizedLanguageCode,
    );

    final currentLyrics = song.lyrics;
    if (currentLyrics != null && !currentLyrics.hasId) {
      _support.replaceSongIfPath(
        song.path,
        (queueSong) =>
            queueSong.copyWith(lyrics: currentLyrics.copyWith(id: lyricsId)),
      );
    }

    if (_context.translationInFlightKeys.contains(translationKey)) return null;
    if (currentLyrics?.translationFor(normalizedLanguageCode)?.hasContent ==
        true) {
      return null;
    }
    if (_context.translatedLyricsKeys.contains(translationKey)) return null;

    return _LyricsTranslationRequest(
      songPath: song.path,
      cacheKey: query.cacheKey,
      languageCode: normalizedLanguageCode,
      sourceLyrics: sourceLyrics,
      lyricsId: lyricsId,
      translationKey: translationKey,
    );
  }

  Future<String?> _runLyricsTranslationRequest(
    _LyricsTranslationRequest request,
    CancelToken cancelToken,
  ) async {
    if (_context.translationInFlightKeys.contains(request.translationKey)) {
      return null;
    }

    _context.translationInFlightKeys.add(request.translationKey);
    _context.updateSongTaskState(
      request.songPath,
      (current) => current.copyWith(
        isTranslationQueued: false,
        isTranslationRunning: true,
        translationStatus: _l10n().translatingLyrics,
      ),
    );

    try {
      final errorMessage = await _context.lyricsAiService.translateLyricsStream(
        lyrics: request.sourceLyrics,
        targetLanguageCode: request.languageCode,
        onModelLabelChanged: _updateTranslationModelLabel,
        cancelToken: cancelToken,
        onProgress: (translatedLines, translatedText) {
          _syncTranslatedLyricsToSong(
            request.songPath,
            request.lyricsId,
            request.languageCode,
            translatedLines,
            translatedText,
            cacheKey: request.cacheKey,
          );
        },
      );
      if (errorMessage == null) {
        if (_context.isLyricsPanelScrolling()) {
          final pending =
              _context.pendingLyricsTranslationUpdates[request.songPath];
          if (pending != null) {
            _context.stashPendingLyricsTranslationUpdate(
              songPath: pending.songPath,
              cacheKey: request.cacheKey,
              languageCode: pending.languageCode,
              lyricsId: pending.lyricsId,
              translatedLines: pending.translatedLines,
              translatedText: pending.translatedText,
              completed: true,
            );
          }
          return null;
        }

        _context.translatedLyricsKeys.add(request.translationKey);
        await _saveTranslatedLyricsToDatabase(
          songPath: request.songPath,
          cacheKey: request.cacheKey,
          languageCode: request.languageCode,
        );
        return null;
      }

      await _saveTranslatedLyricsToDatabase(
        songPath: request.songPath,
        cacheKey: request.cacheKey,
        languageCode: request.languageCode,
      );

      if (cancelToken.isCancelled || errorMessage == 'cancelled') {
        return null;
      }
      return errorMessage;
    } catch (e) {
      try {
        await _saveTranslatedLyricsToDatabase(
          songPath: request.songPath,
          cacheKey: request.cacheKey,
          languageCode: request.languageCode,
        );
      } catch (dbError) {
        debugPrint('[LyricsController] Failed to save partial translation on error: $dbError');
      }
      rethrow;
    } finally {
      _context.translationInFlightKeys.remove(request.translationKey);
      _context.updateSongTaskState(
        request.songPath,
        (current) => current.copyWith(
          isTranslationQueued: false,
          isTranslationRunning: false,
          translationStatus: '',
        ),
      );
    }
  }

  Future<void> flushPendingLyricsTranslationUpdates() async {
    final pendingUpdates = _context.pendingLyricsTranslationUpdates.values
        .toList(growable: false);
    if (pendingUpdates.isEmpty) return;

    for (final pending in pendingUpdates) {
      _context.pendingLyricsTranslationUpdates.remove(pending.songPath);
      _syncTranslatedLyricsToSong(
        pending.songPath,
        pending.lyricsId,
        pending.languageCode,
        pending.translatedLines,
        pending.translatedText,
        cacheKey: pending.cacheKey,
        bumpLayoutRevision: false,
      );
      if (pending.completed) {
        await _saveTranslatedLyricsToDatabase(
          songPath: pending.songPath,
          cacheKey: pending.cacheKey,
          languageCode: pending.languageCode,
        );
        _context.translatedLyricsKeys.add(
          _lyricsTranslationCacheKey(pending.cacheKey, pending.languageCode),
        );
      }
    }

    _context.bumpLyricsLayoutRevision();
  }

  void _updateTranslationModelLabel(String? modelLabel) {
    final current = _context.lyricsGenerationDisplayState;
    _context.updateLyricsGenerationDisplayState(
      current.copyWith(modelLabel: modelLabel ?? ''),
    );
  }

  String _lyricsSourceForTranslation(MusicFile song) {
    final lyrics = song.lyrics;
    if (lyrics?.syncedLines.isNotEmpty == true) {
      return _support.lyricsTextWithTimestamps(lyrics!);
    }
    final plainText = lyrics?.plainText.trim() ?? '';
    if (plainText.isNotEmpty) {
      return plainText;
    }
    return _context.state.currentLyricsText.trim();
  }

  void _syncTranslatedLyricsToSong(
    String songPath,
    String lyricsId,
    String languageCode,
    List<String> translatedLines,
    String translatedText, {
    String? cacheKey,
    bool bumpLayoutRevision = true,
  }) {
    if (_context.isLyricsPanelScrolling()) {
      _context.logDebug(
        'translation sync deferred while panel scrolling -> '
        'path="$songPath" lang="$languageCode" '
        'lines=${translatedLines.length} textLen=${translatedText.trim().length}',
      );
      _context.stashPendingLyricsTranslationUpdate(
        songPath: songPath,
        cacheKey: cacheKey ?? '',
        languageCode: languageCode,
        lyricsId: lyricsId,
        translatedLines: translatedLines,
        translatedText: translatedText,
      );
      return;
    }

    MusicFile? updatedSong;
    _support.replaceSongIfPath(songPath, (currentSong) {
      final existingLyrics = currentSong.lyrics ?? const MusicLyric();
      final existingTranslation = existingLyrics.translationFor(languageCode);
      final updatedTranslation = _buildLyricsTranslation(
        languageCode: languageCode,
        translatedLines: translatedLines,
        translatedText: translatedText,
      );
      if (existingTranslation == updatedTranslation) {
        updatedSong = currentSong;
        return currentSong;
      }

      final updatedTranslations = Map<String, MusicLyricTranslation>.from(
        existingLyrics.translations,
      )..[languageCode] = updatedTranslation;

      updatedSong = currentSong.copyWith(
        lyrics: existingLyrics.copyWith(
          id: lyricsId.isEmpty ? existingLyrics.id : lyricsId,
          translations: updatedTranslations,
        ),
      );
      return updatedSong!;
    });

    if (updatedSong == null) return;
    _context.logDebug(
      'translation sync applied -> path="$songPath" lang="$languageCode" '
      'lines=${translatedLines.length} textLen=${translatedText.trim().length} '
      'bumpLayout=$bumpLayoutRevision',
    );
    _context.bumpRevision();
    if (bumpLayoutRevision) {
      _context.bumpLyricsLayoutRevision();
    }
    if (cacheKey != null) {
      unawaited(_saveTranslatedLyricsToDatabase(
        songPath: songPath,
        cacheKey: cacheKey,
        languageCode: languageCode,
      ));
    }
  }

  Future<void> _saveTranslatedLyricsToDatabase({
    required String songPath,
    required String cacheKey,
    required String languageCode,
  }) async {
    try {
      final current = _support.songForPath(songPath);
      if (current == null) return;

      final lyrics = current.lyrics;
      if (lyrics == null) return;

      final translation = lyrics.translationFor(languageCode);
      if (translation == null || !translation.hasContent) return;

      final record = LyricsTranslationCacheRecord(
        cacheKey: cacheKey,
        languageCode: languageCode,
        translatedText: translation.translatedText,
        translatedLines: translation.translatedLines,
        provider: translation.provider,
        updatedAtMillis:
            translation.updatedAt?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch,
      );
      await _context.lyricsCacheRepository.saveLyricsTranslationCache(record);
    } catch (e) {
      debugPrint('[LyricsController] Failed to cache translated lyrics: $e');
    }
  }

  MusicLyricTranslation _buildLyricsTranslation({
    required String languageCode,
    required List<String> translatedLines,
    required String translatedText,
  }) {
    final normalizedLines = translatedLines
        .map((line) => line.trim())
        .toList(growable: false);
    return MusicLyricTranslation(
      languageCode: languageCode,
      translatedText: translatedText,
      translatedLines: normalizedLines,
      provider: _translationProviderTag(),
      updatedAt: DateTime.now(),
    );
  }

  String _lyricsTranslationCacheKey(String cacheKey, String languageCode) {
    return '$cacheKey|$languageCode';
  }

  String _translationProviderTag() {
    final provider = _context.settingsService.translationPrimaryModel.provider;
    return provider.storageValue;
  }
}

AppLocalizations _l10n() => currentAppL10n;
