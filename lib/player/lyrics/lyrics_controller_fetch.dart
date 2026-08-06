import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_lyric.dart';
import 'package:vynody/models/music_lyric_translation.dart';
import 'package:vynody/utils/language_code_utils.dart';
import 'package:vynody/utils/lrc_utils.dart';
import 'package:vynody/utils/lyrics_id_utils.dart';
import 'package:vynody/player/lyrics/lyrics_controller_context.dart';
import 'package:vynody/player/lyrics/lyrics_controller_utils.dart';
import 'package:vynody/player/lyrics/lyrics_generation_phase.dart';
import 'package:vynody/player/lyrics/lyrics_service.dart';

class LyricsFetchCoordinator {
  LyricsFetchCoordinator(this._context, this._support);

  final LyricsControllerContext _context;
  final LyricsControllerSupport _support;

  void scheduleFetch(MusicFile song) {
    unawaited(fetchAndLog(song));
    unawaited(retryFetchUntilReady(song));
  }

  Future<void> fetchAndLog(MusicFile song) async {
    if (_context.lyricsGeneration.isGenerating &&
        _context.lyricsGeneration.songPath == song.path) {
      _support.logDebug(
        'fetch skipped because lyrics generation is in progress for same song -> '
        'title="${song.displayName}" path="${song.path}"',
      );
      return;
    }

    _context.lyricsFetchCancelToken?.cancel(
      'replaced by a newer lyrics request',
    );
    final cancelToken = CancelToken();
    _context.lyricsFetchCancelToken = cancelToken;
    _context.setIsLyricsLoading(true);

    _support.logDebug(
      'fetch request created -> title="${song.displayName}" '
      'path="${song.path}" cancelToken=${identityHashCode(cancelToken)}',
    );

    final queryDuration = await _support.resolveLyricsDuration(song);
    if (queryDuration == null) {
      _support.logDebug(
        'fetch skipped, duration not ready -> title="${song.displayName}" '
        'path="${song.path}" playerDuration=${_context.playerDuration()} '
        'songDuration=${song.durationMillis}',
      );
      if (_context.lyricsFetchCancelToken == cancelToken) {
        _context.lyricsFetchCancelToken = null;
      }
      _context.setIsLyricsLoading(false);
      return;
    }

    final requestId = ++_context.lyricsRequestSerial;
    final query = LyricsQuery(
      filePath: song.path,
      fileName: song.name,
      title: _support.lyricsTitleForQuery(song),
      artist: _support.lyricsArtistForQuery(song),
      album: _support.lyricsAlbumForQuery(song),
      duration: queryDuration,
    );

    _context.setIsLyricsLoading(true);
    _support.logDebug(
      'fetch start -> title="${song.displayName}" path="${song.path}" '
      'queryDuration=$queryDuration playerDuration=${_context.playerDuration()} '
      'requestId=$requestId cancelToken=${identityHashCode(cancelToken)}',
    );

    try {
      _support.logDebug(
        'fetch dispatching to lyrics service -> requestId=$requestId '
        'path="${song.path}"',
      );
      final result = await _context.lyricsService.fetchBestLyrics(
        query: query,
        cancelToken: cancelToken,
      );
      if (requestId != _context.lyricsRequestSerial ||
          _context.currentMusic()?.path != song.path) {
        _support.logDebug(
          'fetch ignored due to stale request -> title="${song.displayName}" '
          'requestId=$requestId latest=${_context.lyricsRequestSerial} '
          'currentPath="${_context.currentMusic()?.path}"',
        );
        return;
      }

      final rawLyricsText = result?.lyricsText ?? '';
      final parsedResult = LrcUtils.parseLyricsWithTranslation(rawLyricsText);
      final effectiveSyncedLines = _support.buildLyricsLines(
        parsedResult.syncedLines.isNotEmpty
            ? parsedResult.syncedLines
            : (result?.syncedLines ?? const []),
        rawLyricsText,
      );

      _context.setIsLyricsLoading(false);
      _context.setLyricsSearchAttempted(true);
      _context.setHasLyrics(result != null && result.track.hasLyrics);
      _context.setCurrentLyricsLines(effectiveSyncedLines);
      _context.setCurrentLyricsText(rawLyricsText);

      final translationsMap = <String, MusicLyricTranslation>{};
      if (song.lyrics?.translations != null) {
        translationsMap.addAll(song.lyrics!.translations);
      }
      if (parsedResult.hasTranslation) {
        final langCode = LanguageCodeUtils.currentAppLanguageCode().isNotEmpty
            ? LanguageCodeUtils.currentAppLanguageCode()
            : 'zh';
        translationsMap[langCode] = MusicLyricTranslation(
          languageCode: langCode,
          translatedLines: parsedResult.translatedLines!,
          translatedText: parsedResult.translatedLines!.join('\n'),
          provider: 'embedded_lrc',
          updatedAt: DateTime.now(),
        );
      }

      final updated = _support.replaceCurrentSongIfPath(
        song.path,
        (currentSong) => currentSong.copyWith(
          lyrics: MusicLyric(
            id:
                result?.track.lyricsId ??
                LyricsIdUtils.fromLyricsText(_context.state.currentLyricsText),
            syncedLines: _context.state.currentLyricsLines,
            plainText: _context.state.currentLyricsText,
            source: result?.source ?? 'lrclib',
            timelineOffset:
                result?.timelineOffset ??
                song.lyrics?.timelineOffset ??
                Duration.zero,
            translations: translationsMap,
          ),
        ),
      );
      if (updated != null) {
        unawaited(_context.watchLyricsCacheForSong(updated));
        unawaited(_support.restoreCachedTranslations(updated));
      }

      _support.logDebug(
        'fetch state committed -> title="${song.displayName}" '
        'requestId=$requestId hasLyrics=${_context.state.hasLyrics} '
        'searched=${_context.state.lyricsSearchAttempted} '
        'lines=${_context.state.currentLyricsLines.length} '
        'textLen=${_context.state.currentLyricsText.trim().length}',
      );
      _context.bumpRevision();
      _support.logDebug(
        'fetch completed -> title="${song.displayName}" requestId=$requestId '
        'hasLyrics=${result != null && result.track.hasLyrics} '
        'source=${result?.source ?? 'none'}',
      );
      _context.lyricsService.debugPrintSelection(query, result);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _support.logDebug(
          'fetch canceled -> title="${song.displayName}" '
          'path="${song.path}" requestId=$requestId '
          'cancelToken=${identityHashCode(cancelToken)}',
        );
        return;
      }
      debugPrint('[LyricsController] Failed to fetch lyrics: $e');
      if (requestId == _context.lyricsRequestSerial &&
          _context.currentMusic()?.path == song.path) {
        _context.setIsLyricsLoading(false);
        _context.setLyricsSearchAttempted(true);
      }
    } catch (e) {
      debugPrint('[LyricsController] Failed to fetch lyrics: $e');
      if (requestId == _context.lyricsRequestSerial &&
          _context.currentMusic()?.path == song.path) {
        _context.setIsLyricsLoading(false);
        _context.setLyricsSearchAttempted(true);
      }
    } finally {
      if (_context.lyricsFetchCancelToken == cancelToken) {
        _support.logDebug(
          'fetch cleanup -> title="${song.displayName}" requestId=$requestId '
          'cancelToken=${identityHashCode(cancelToken)}',
        );
        _context.lyricsFetchCancelToken = null;
      }
    }
  }

  Future<void> retryFetchUntilReady(MusicFile song) async {
    if (_context.lyricsGeneration.isGenerating &&
        _context.lyricsGeneration.songPath == song.path) {
      return;
    }
    if (_context.state.isLyricsLoading ||
        _context.lyricsFetchCancelToken != null) {
      return;
    }

    final retryId = ++_context.lyricsRetrySerial;
    for (var attempt = 0; attempt < 12; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 150));

      if (retryId != _context.lyricsRetrySerial) return;
      if (!_context.isLyricsActive() ||
          _context.currentMusic()?.path != song.path) {
        return;
      }
      if (_context.state.hasLyrics ||
          _context.state.isLyricsLoading ||
          _context.state.lyricsSearchAttempted) {
        _support.logDebug(
          'retry aborted because state changed -> title="${song.displayName}" '
          'attempt=${attempt + 1} retryId=$retryId loading=${_context.state.isLyricsLoading} '
          'searched=${_context.state.lyricsSearchAttempted} hasLyrics=${_context.state.hasLyrics}',
        );
        return;
      }

      if (await _support.resolveLyricsDuration(song) != null) {
        _support.logDebug(
          'retry triggering fetch -> title="${song.displayName}" '
          'attempt=${attempt + 1} retryId=$retryId',
        );
        unawaited(fetchAndLog(song));
        return;
      }
    }
  }

  Future<void> clearAllLyricsCache() async {
    _support.cancelOngoingLyricsFetch(reason: 'lyrics cache cleared');
    await _context.lyricsCacheRepository.clearAllLyricsCaches();

    final queue = _context.queue();
    for (var i = 0; i < queue.length; i++) {
      final song = queue[i];
      if (song.lyrics == null) continue;
      queue[i] = _support.copySongWithLyrics(song, null);
    }

    _context.translatedLyricsKeys.clear();
    _context.translationInFlightKeys.clear();
    _context.setLyricsTranslationStatus('');
    _context.setHasLyrics(false);
    _context.setIsLyricsLoading(false);
    _context.setIsLyricsTranslating(false);
    _context.setLyricsGenerating(
      false,
      phase: LyricsGenerationPhase.idle,
      progress: 0.0,
    );
    _context.setLyricsSearchAttempted(false);
    _context.setCurrentLyricsLines(const []);
    _context.setCurrentLyricsText('');
    _context.bumpRevision();

    final current = _context.currentMusic();
    if (_context.isLyricsActive() && current != null) {
      scheduleFetch(current);
    }
  }

  Future<void> clearLyricsCacheForCurrentSong() async {
    final song = _context.currentMusic();
    if (song == null) return;

    final cacheKey = await _support.lyricsCacheKeyForSong(song);
    if (cacheKey.isNotEmpty) {
      await _context.lyricsCacheRepository.clearAllLyricsCachesByKey(cacheKey);
      _context.translatedLyricsKeys.removeWhere(
        (key) => key.startsWith('$cacheKey|'),
      );
      _context.translationInFlightKeys.removeWhere(
        (key) => key.startsWith('$cacheKey|'),
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('selected_lyric_source_$cacheKey');
      } catch (e) {
        debugPrint('[LyricsController] Failed to remove selection preference: $e');
      }
    }

    if (_context.currentMusic()?.path != song.path) return;

    _support.cancelOngoingLyricsFetch(
      reason: 'lyrics cache cleared for current song',
    );
    _support.clearLyricsStateForPath(song.path);
    _context.setLyricsTranslationStatus('');
    _context.bumpRevision();
  }

  Future<void> clearTranslationCacheForCurrentSong() async {
    final song = _context.currentMusic();
    if (song == null) return;

    final cacheKey = await _support.lyricsCacheKeyForSong(song);
    if (cacheKey.isNotEmpty) {
      await _context.lyricsCacheRepository.clearLyricsTranslationCacheByKey(
        cacheKey,
      );
      _context.translatedLyricsKeys.removeWhere(
        (key) => key.startsWith('$cacheKey|'),
      );
      _context.translationInFlightKeys.removeWhere(
        (key) => key.startsWith('$cacheKey|'),
      );
    }

    if (_context.currentMusic()?.path != song.path) return;

    _context.clearPendingLyricsTranslationUpdatesForSong(song.path);
    _support.clearTranslationStateForPath(song.path);
    _context.setLyricsTranslationStatus('');
    _context.bumpRevision();
    _context.bumpLyricsLayoutRevision();
  }

  Future<void> requeryLyricsForCurrentSong() async {
    final song = _context.currentMusic();
    if (song == null) return;

    await clearLyricsCacheForCurrentSong();
    if (_context.currentMusic()?.path != song.path) return;
    scheduleFetch(song);
  }

  Future<void> clearTranslationCache() async {
    await _context.lyricsCacheRepository.clearLyricsTranslationCache();

    _context.translatedLyricsKeys.clear();
    _context.translationInFlightKeys.clear();
    _context.setLyricsTranslationStatus('');

    final queue = _context.queue();
    for (var i = 0; i < queue.length; i++) {
      final song = queue[i];
      final lyrics = song.lyrics;
      if (lyrics == null || lyrics.translations.isEmpty) continue;

      queue[i] = song.copyWith(
        lyrics: lyrics.copyWith(
          translations: const <String, MusicLyricTranslation>{},
        ),
      );
    }

    _context.bumpRevision();
  }

  Future<void> restoreCachedTranslations(MusicFile song) async {
    await _support.restoreCachedTranslations(song);
  }
}
