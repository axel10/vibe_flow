import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_taglib/flutter_taglib.dart' as taglib;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vynody/models/lyric_line.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_lyric.dart';
import 'package:vynody/utils/language_code_utils.dart';
import 'package:vynody/utils/lrc_utils.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/lyrics/lyrics_ai_service.dart';
import 'package:vynody/player/lyrics/lyrics_cache_repository.dart';
import 'package:vynody/player/lyrics/lyrics_controller_context.dart';
import 'package:vynody/player/lyrics/lyrics_generation_display_state.dart';
import 'package:vynody/player/lyrics/lyrics_controller_fetch.dart';
import 'package:vynody/player/lyrics/lyrics_controller_generation.dart';
import 'package:vynody/player/lyrics/lyrics_controller_state.dart';
import 'package:vynody/player/lyrics/lyrics_controller_translation.dart';
import 'package:vynody/player/lyrics/lyrics_controller_utils.dart';
import 'package:vynody/player/lyrics/lyrics_riverpod.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/lyrics/lyrics_service.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/lyrics/lyrics_generation_phase.dart';
import 'package:vynody/player/lyrics/lyrics_song_task_state.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/settings/settings_service.dart';

class LyricsController extends Notifier<LyricsControllerState> {
  late MetadataDatabase _db;
  late MusicFile? Function() _currentMusic;
  late List<MusicFile> Function() _queue;
  late int Function() _currentIndex;
  late Duration Function() _playerDuration;
  late bool Function() _isLyricsActive;
  late void Function(String path, int durationMillis) _cacheSongDuration;
  late LyricsCacheRepository _lyricsCacheRepository;
  late LyricsService _lyricsService;
  late LyricsAiService _lyricsAiService;
  late SettingsService _settingsService;
  late LyricsControllerContext _context;
  late LyricsControllerSupport _support;
  late LyricsFetchCoordinator _fetchCoordinator;
  late LyricsGenerationCoordinator _generationCoordinator;
  late LyricsTranslationCoordinator _translationCoordinator;
  StreamSubscription<List<LyricsCacheRecord>>? _lyricsCacheSubscription;
  StreamSubscription<List<LyricsTranslationCacheRecord>>?
  _lyricsTranslationCacheSubscription;
  String? _watchedLyricsCacheKey;
  String? _watchedLyricsSongPath;
  bool _lyricsCacheWatchPrimed = false;

  @override
  LyricsControllerState build() {
    final dependencies = ref.watch(lyricsControllerDependenciesProvider);
    ref.onDispose(clearLyricsCacheWatch);
    _db = dependencies.db;
    _currentMusic = dependencies.currentMusic;
    _queue = dependencies.queue;
    _currentIndex = dependencies.currentIndex;
    _playerDuration = dependencies.playerDuration;
    _isLyricsActive = dependencies.isLyricsActive;
    _cacheSongDuration = dependencies.cacheSongDuration;
    _lyricsCacheRepository = LyricsCacheRepository(db: _db);
    _lyricsService = LyricsService(
      db: _db,
      cacheRepository: _lyricsCacheRepository,
    );
    _settingsService = ref.read(settingsServiceProvider);
    final effectiveLanguageCode = ref.read(
      lyricsTranslationLanguageCodeProvider,
    );
    ref.listen<String>(lyricsTranslationLanguageCodeProvider, (
      previous,
      next,
    ) {
      if (state.lyricsTranslationLanguageCode == next) {
        return;
      }
      Future.microtask(() {
        if (state.lyricsTranslationLanguageCode == next) {
          return;
        }
        state = state.copyWith(
          lyricsTranslationLanguageCode: next,
        );
      });
    });
    _lyricsAiService = ref.read(lyricsAiServiceProvider);
    _context = LyricsControllerContext(
      db: _db,
      currentMusic: _currentMusic,
      queue: _queue,
      currentIndex: _currentIndex,
      playerDuration: _playerDuration,
      isLyricsActive: _isLyricsActive,
      cacheSongDuration: _cacheSongDuration,
      lyricsCacheRepository: _lyricsCacheRepository,
      lyricsService: _lyricsService,
      settingsService: _settingsService,
      lyricsAiService: _lyricsAiService,
      getState: () => state,
      setState: (newState) => state = newState,
      clearState: ({bool notify = false, bool preserveTaskState = true}) =>
          clearState(notify: notify, preserveTaskState: preserveTaskState),
      setIsLyricsLoading: (value) => _isLyricsLoading = value,
      setIsLyricsTranslating: (value) => _isLyricsTranslating = value,
      setLyricsTranslationStatus: (value) => _lyricsTranslationStatus = value,
      setLyricsGenerationStatus: (value) => _lyricsGenerationStatus = value,
      setLyricsGenerationDisplayState: (value) =>
          _setLyricsGenerationDisplayState(value),
      setHasLyrics: (value) => _hasLyrics = value,
      setLyricsSearchAttempted: (value) => _lyricsSearchAttempted = value,
      setCurrentLyricsLines: (value) => _currentLyricsLines = value,
      setCurrentLyricsText: (value) => _currentLyricsText = value,
      setLyricsGenerating: _setLyricsGenerating,
      startLyricsGenerationStatus: _startLyricsGenerationStatus,
      clearLyricsGenerationStatus: _clearLyricsGenerationStatus,
      watchLyricsCacheForSong: watchLyricsCacheForSong,
      bumpRevision: _bumpRevision,
      bumpLyricsLayoutRevision: _bumpLyricsLayoutRevision,
      isLyricsPanelScrolling: () =>
          ref.read(lyricsPanelScrollAnimatingProvider),
      isProUnlocked: () => ref.read(isProUnlockedProvider),
      logDebug: _logDebug,
    );
    _support = LyricsControllerSupport(_context);
    _fetchCoordinator = LyricsFetchCoordinator(_context, _support);
    _generationCoordinator = LyricsGenerationCoordinator(_context, _support);
    _translationCoordinator = LyricsTranslationCoordinator(_context, _support);
    return LyricsControllerState(
      lyricsTranslationLanguageCode: effectiveLanguageCode,
    );
  }

  set _isLyricsLoading(bool value) {
    state = state.copyWith(isLyricsLoading: value);
  }

  set _isLyricsTranslating(bool value) {
    state = state.copyWith(isLyricsTranslating: value);
  }

  set _lyricsTranslationStatus(String value) {
    state = state.copyWith(lyricsTranslationStatus: value);
  }

  set _lyricsGenerationStatus(String value) {
    state = state.copyWith(lyricsGenerationStatus: value);
  }

  set _hasLyrics(bool value) {
    state = state.copyWith(hasLyrics: value);
  }

  set _lyricsSearchAttempted(bool value) {
    state = state.copyWith(lyricsSearchAttempted: value);
  }

  set _currentLyricsLines(List<LyricLine> value) {
    state = state.copyWith(currentLyricsLines: value);
  }

  set _currentLyricsText(String value) {
    state = state.copyWith(currentLyricsText: value);
  }

  void _setLyricsGenerating(
    bool value, {
    LyricsGenerationPhase? phase,
    double? progress,
  }) {
    state = state.copyWith(
      isLyricsGenerating: value,
      lyricsGenerationPhase: phase ?? state.lyricsGenerationPhase,
      lyricsGenerationProgress: progress ?? state.lyricsGenerationProgress,
    );
  }

  void _startLyricsGenerationStatus(String status) {
    _lyricsGenerationStatus = status;
  }

  void _clearLyricsGenerationStatus() {
    _lyricsGenerationStatus = '';
  }

  void _setLyricsGenerationDisplayState(LyricsGenerationDisplayState value) {
    if (_context.updateLyricsGenerationDisplayState(value)) {
      _bumpRevision();
    }
  }

  void _bumpRevision() {
    state = state.copyWith(revision: state.revision + 1);
  }

  void _bumpLyricsLayoutRevision() {
    ref.read(lyricsLayoutRevisionProvider.notifier).state++;
  }

  void setTranslationLanguageCode(String languageCode) {
    final normalized = LanguageCodeUtils.normalizeLanguageCode(languageCode);
    final effective = normalized.isEmpty
        ? LanguageCodeUtils.currentAppLanguageCode()
        : normalized;

    if (_settingsService.lyricsTranslationTargetLanguageCode != normalized) {
      _settingsService.lyricsTranslationTargetLanguageCode = normalized;
    }
    if (state.lyricsTranslationLanguageCode == effective) {
      return;
    }
    state = state.copyWith(lyricsTranslationLanguageCode: effective);
  }

  void clearState({bool notify = false, bool preserveTaskState = true}) {
    final current = state;
    state = LyricsControllerState(
      isLyricsLoading: false,
      isLyricsTranslating: preserveTaskState
          ? current.isLyricsTranslating
          : false,
      lyricsTranslationStatus: preserveTaskState
          ? current.lyricsTranslationStatus
          : '',
      lyricsGenerationStatus: preserveTaskState
          ? current.lyricsGenerationStatus
          : '',
      hasLyrics: false,
      lyricsSearchAttempted: false,
      currentLyricsLines: const <LyricLine>[],
      currentLyricsText: '',
      isLyricsGenerating: preserveTaskState
          ? current.isLyricsGenerating
          : false,
      lyricsGenerationPhase: preserveTaskState
          ? current.lyricsGenerationPhase
          : LyricsGenerationPhase.idle,
      lyricsGenerationProgress: preserveTaskState
          ? current.lyricsGenerationProgress
          : 0.0,
      lyricsTranslationLanguageCode: current.lyricsTranslationLanguageCode,
      revision: notify ? current.revision + 1 : current.revision,
    );
    clearLyricsCacheWatch();
  }

  void restoreFromSongLyrics(MusicFile song) {
    final songLyrics = song.lyrics;
    if (songLyrics == null) {
      clearState();
      return;
    }

    _hasLyrics = true;
    _isLyricsLoading = false;
    _currentLyricsLines = songLyrics.syncedLines;
    _currentLyricsText = songLyrics.plainText;
    _lyricsSearchAttempted = true;
    unawaited(_support.restoreCachedTranslations(song));
    unawaited(watchLyricsCacheForSong(song));
    _logDebug(
      'lyrics restored from cache -> title="${song.displayName}" '
      'lines=${songLyrics.syncedLines.length} synced=${songLyrics.isSynced}',
    );
    _bumpRevision();
  }

  void scheduleFetch(MusicFile song) {
    _fetchCoordinator.scheduleFetch(song);
  }

  Future<void> fetchAndLog(MusicFile song) {
    return _fetchCoordinator.fetchAndLog(song);
  }

  Future<void> watchLyricsCacheForSong(MusicFile song) async {
    final query = await _support.buildLyricsQueryForSong(song);
    final cacheKey = query?.cacheKey.trim() ?? '';
    if (cacheKey.isEmpty) {
      clearLyricsCacheWatch();
      return;
    }

    final currentPath = _context.currentMusic()?.path;
    if (currentPath != song.path) {
      return;
    }

    if (_watchedLyricsCacheKey == cacheKey &&
        _watchedLyricsSongPath == song.path) {
      return;
    }

    clearLyricsCacheWatch();
    _watchedLyricsCacheKey = cacheKey;
    _watchedLyricsSongPath = song.path;

    _lyricsCacheSubscription = _context.lyricsCacheRepository
        .watchLyricsCaches(cacheKey)
        .listen(
          (_) => unawaited(_syncLyricsCacheWatch(song.path, cacheKey)),
          onError: (error, stackTrace) {
            debugPrint('[LyricsController] lyrics cache watch error: $error');
          },
        );
    _lyricsTranslationCacheSubscription = _context.lyricsCacheRepository
        .watchLyricsTranslationCaches(cacheKey)
        .listen(
          (_) => unawaited(_syncLyricsCacheWatch(song.path, cacheKey)),
          onError: (error, stackTrace) {
            debugPrint(
              '[LyricsController] lyrics translation cache watch error: $error',
            );
          },
        );

    unawaited(_syncLyricsCacheWatch(song.path, cacheKey));
  }

  static const String _activeLyricSourcePrefix = 'selected_lyric_source_';

  Future<({LyricsCacheSource source, String languageCode})?> getSelectedLyricSource(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString('$_activeLyricSourcePrefix$cacheKey');
      if (val != null && val.contains('|')) {
        final parts = val.split('|');
        return (
          source: LyricsCacheSource.fromDbValue(parts[0]),
          languageCode: parts.length > 1 ? parts[1] : '',
        );
      }
    } catch (e) {
      debugPrint('[LyricsController] Error getting selected lyric source: $e');
    }
    return null;
  }

  Future<void> setSelectedLyricSource(String cacheKey, LyricsCacheSource source, {String languageCode = ''}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_activeLyricSourcePrefix$cacheKey';
      await prefs.setString(key, '${source.dbValue}|$languageCode');
      
      final currentSong = _context.currentMusic();
      if (currentSong != null) {
        final currentQuery = await _support.buildLyricsQueryForSong(currentSong);
        if (currentQuery?.cacheKey == cacheKey) {
          unawaited(_syncLyricsCacheWatch(currentSong.path, cacheKey));
        }
      }
    } catch (e) {
      debugPrint('[LyricsController] Error setting selected lyric source: $e');
    }
  }

  Future<LyricsCacheRecord?> _tryLoadExternalLrcRecord(String songPath, String cacheKey) async {
    if (RemoteMediaResolver.isRemoteUri(songPath)) {
      return null;
    }
    try {
      final directory = p.dirname(songPath);
      final baseName = p.basenameWithoutExtension(songPath);
      final lrcPath = p.join(directory, '$baseName.lrc');
      var lrcFile = File(lrcPath);
      if (!await lrcFile.exists()) {
        final lrcPathUpper = p.join(directory, '$baseName.LRC');
        final lrcFileUpper = File(lrcPathUpper);
        if (!await lrcFileUpper.exists()) {
          return null;
        }
        lrcFile = lrcFileUpper;
      }

      final rawLyrics = await lrcFile.readAsString();
      if (rawLyrics.trim().isNotEmpty) {
        final parsed = LrcUtils.parseTimedLyrics(rawLyrics);
        return LyricsCacheRecord(
          cacheKey: cacheKey,
          source: LyricsCacheSource.external,
          isSynced: parsed.isNotEmpty,
          syncedLyrics: rawLyrics,
          syncedLines: parsed.isNotEmpty
              ? parsed
              : rawLyrics.split('\n').map((l) => LyricLine(timestamp: Duration.zero, text: l, isTimed: false)).toList(),
          timelineOffsetMillis: 0,
          updatedAtMillis: lrcFile.lastModifiedSync().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      debugPrint('[LyricsController] Failed to check external LRC: $e');
    }
    return null;
  }

  Future<LyricsCacheRecord?> _tryLoadEmbeddedRecord(String songPath, String cacheKey) async {
    if (RemoteMediaResolver.isRemoteUri(songPath)) {
      return null;
    }
    try {
      if (!taglib.TagLibFile.isSupported) {
        return null;
      }
      final file = File(songPath);
      if (!await file.exists()) {
        return null;
      }

      final tagFile = await taglib.TagLibFile.openAsync(songPath);
      if (tagFile == null) {
        return null;
      }

      try {
        final lyricsList = tagFile.properties[taglib.TagProperties.lyrics];
        if (lyricsList == null || lyricsList.isEmpty) {
          return null;
        }

        final rawLyrics = lyricsList.first.trim();
        if (rawLyrics.isEmpty) {
          return null;
        }

        final parsed = LrcUtils.parseTimedLyrics(rawLyrics);
        return LyricsCacheRecord(
          cacheKey: cacheKey,
          source: LyricsCacheSource.embedded,
          isSynced: parsed.isNotEmpty,
          syncedLyrics: rawLyrics,
          syncedLines: parsed.isNotEmpty
              ? parsed
              : rawLyrics.split('\n').map((l) => LyricLine(timestamp: Duration.zero, text: l, isTimed: false)).toList(),
          timelineOffsetMillis: 0,
          updatedAtMillis: file.lastModifiedSync().millisecondsSinceEpoch,
        );
      } finally {
        tagFile.close();
      }
    } catch (e) {
      debugPrint('[LyricsController] Failed to read embedded record: $e');
    }
    return null;
  }

  Future<LyricsQuery?> buildLyricsQueryForSong(MusicFile song) {
    return _support.buildLyricsQueryForSong(song);
  }

  Future<List<LyricsCacheRecord>> getAvailableLyricRecords(MusicFile song) async {
    final query = await _support.buildLyricsQueryForSong(song);
    final cacheKey = query?.cacheKey.trim() ?? '';
    if (cacheKey.isEmpty) return const [];

    final records = <LyricsCacheRecord>[];

    final externalRecord = await _tryLoadExternalLrcRecord(song.path, cacheKey);
    if (externalRecord != null) {
      records.add(externalRecord);
    }

    final embeddedRecord = await _tryLoadEmbeddedRecord(song.path, cacheKey);
    if (embeddedRecord != null) {
      records.add(embeddedRecord);
    }

    final dbCaches = await _context.lyricsCacheRepository.getLyricsCaches(cacheKey);

    for (final cache in dbCaches) {
      if (cache.source == LyricsCacheSource.external && externalRecord != null) {
        continue;
      }
      if (cache.source == LyricsCacheSource.embedded && embeddedRecord != null) {
        continue;
      }
      if (cache.source == LyricsCacheSource.none) {
        continue;
      }
      records.add(cache);
    }

    return records;
  }

  void clearLyricsCacheWatch() {
    _lyricsCacheSubscription?.cancel();
    _lyricsCacheSubscription = null;
    _lyricsTranslationCacheSubscription?.cancel();
    _lyricsTranslationCacheSubscription = null;
    _watchedLyricsCacheKey = null;
    _watchedLyricsSongPath = null;
    _lyricsCacheWatchPrimed = false;
  }

  Future<void> retryFetchUntilReady(MusicFile song) {
    return _fetchCoordinator.retryFetchUntilReady(song);
  }

  Future<void> clearAllLyricsCache() {
    return _fetchCoordinator.clearAllLyricsCache();
  }

  Future<void> clearLyricsCacheForCurrentSong() {
    return _fetchCoordinator.clearLyricsCacheForCurrentSong();
  }

  Future<void> clearTranslationCacheForCurrentSong() {
    return _fetchCoordinator.clearTranslationCacheForCurrentSong();
  }

  Future<void> requeryLyricsForCurrentSong() {
    return _fetchCoordinator.requeryLyricsForCurrentSong();
  }

  Future<void> clearTranslationCache() {
    return _fetchCoordinator.clearTranslationCache();
  }

  Future<void> restoreCachedTranslations(MusicFile song) {
    return _fetchCoordinator.restoreCachedTranslations(song);
  }

  MusicLyric? currentLyricsForCurrentSong() {
    final currentSong = _currentMusic();
    if (currentSong == null) return null;

    return _support.songForPath(currentSong.path)?.lyrics;
  }

  Future<String?> generateLyricsForCurrentSong() {
    return _generationCoordinator.generateLyricsForCurrentSong();
  }

  Future<String?> generateTimelineForCurrentSong() {
    return _generationCoordinator.generateTimelineForCurrentSong();
  }

  Future<String?> regenerateLyricsForCurrentSong() {
    return _generationCoordinator.regenerateLyricsForCurrentSong();
  }

  Future<String?> translateLyricsForCurrentSong({String? targetLanguageCode}) {
    return _translationCoordinator.translateLyricsForCurrentSong(
      targetLanguageCode: targetLanguageCode,
    );
  }

  void cancelActiveAiTask() {
    _logDebug('cancelActiveAiTask called');
    if (_context.lyricsAiCancelToken != null) {
      _context.lyricsAiCancelToken!.cancel('User cancelled AI lyrics task');
      _context.lyricsAiCancelToken = null;
    }
  }

  Future<void> flushPendingLyricsTranslationUpdates() {
    return _translationCoordinator.flushPendingLyricsTranslationUpdates();
  }

  Future<void> updateLyricsTimelineOffsetForCurrentSong(
    Duration timelineOffset,
  ) {
    return _support.updateLyricsTimelineOffsetForCurrentSong(timelineOffset);
  }

  Future<void> fillLyricsForCurrentSong(
    String lyricsText, {
    LyricsCacheSource source = LyricsCacheSource.manualAdjust,
  }) {
    return _support.fillLyricsForCurrentSong(lyricsText, source: source);
  }

  LyricsSongTaskState taskStateForSong(String path) {
    return _context.taskStateForSong(path);
  }

  bool isLyricsGenerationForSong(String path) {
    return _context.isLyricsGenerationBusyForSong(path);
  }

  bool isLyricsTranslationForSong(String path) {
    return _context.isLyricsTranslationBusyForSong(path);
  }

  String? get activeLyricsGenerationSongPath {
    return _context.lyricsGeneration.songPath;
  }

  LyricsGenerationDisplayState get activeLyricsGenerationDisplayState {
    return _context.lyricsGenerationDisplayState;
  }

  void _logDebug(String message) {
    if (!kDebugMode) return;
    // debugPrint('[AudioService][Lyrics] $message');
  }

  Future<void> _syncLyricsCacheWatch(String songPath, String cacheKey) async {
    final currentSong = _support.songForPath(songPath);
    if (currentSong == null) {
      return;
    }

    final availableCaches = await getAvailableLyricRecords(currentSong);
    if (availableCaches.isEmpty) {
      if (!_lyricsCacheWatchPrimed) {
        _logDebug(
          'lyrics cache watch initial null ignored -> path="$songPath" '
          'cacheKey="$cacheKey"',
        );
        return;
      }
      if (currentSong.lyrics != null) {
        _logDebug(
          'lyrics cache watch cleared -> path="$songPath" cacheKey="$cacheKey"',
        );
        _support.clearLyricsStateForPath(songPath);
        _context.setLyricsTranslationStatus('');
        _context.bumpRevision();
      }
      return;
    }

    _lyricsCacheWatchPrimed = true;

    final preference = await getSelectedLyricSource(cacheKey);
    LyricsCacheRecord? selectedRecord;

    if (preference != null) {
      for (final record in availableCaches) {
        if (record.source == preference.source && record.languageCode == preference.languageCode) {
          selectedRecord = record;
          break;
        }
      }
    }

    if (selectedRecord == null) {
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
        for (final record in availableCaches) {
          if (record.source == src) {
            selectedRecord = record;
            break;
          }
        }
        if (selectedRecord != null) break;
      }
      selectedRecord ??= availableCaches.first;
    }

    final translationRecords = await _context.lyricsCacheRepository
        .getLyricsTranslationCaches(cacheKey);
    final translations = _support.translationsFromCacheRecords(
      translationRecords,
    );
    final nextLyrics = _support.lyricsFromCacheRecord(
      selectedRecord,
      translations: translations,
    );

    if (currentSong.lyrics == nextLyrics) {
      return;
    }

    final updatedSong = _support.replaceSongIfPath(
      songPath,
      (queueSong) => queueSong.copyWith(lyrics: nextLyrics),
    );
    if (updatedSong == null) {
      return;
    }

    if (_context.currentMusic()?.path == songPath) {
      _context.setHasLyrics(
        nextLyrics.plainText.trim().isNotEmpty ||
            nextLyrics.syncedLines.isNotEmpty ||
            nextLyrics.translations.isNotEmpty,
      );
      _context.setIsLyricsLoading(false);
      _context.setLyricsSearchAttempted(true);
      _context.setCurrentLyricsLines(nextLyrics.syncedLines);
      _context.setCurrentLyricsText(nextLyrics.plainText);
      _context.setLyricsTranslationStatus('');
    }

    _logDebug(
      'lyrics cache watch applied -> path="$songPath" cacheKey="$cacheKey" '
      'source=${selectedRecord.source.dbValue} lang=${selectedRecord.languageCode} '
      'hasLyrics=${nextLyrics.plainText.trim().isNotEmpty || nextLyrics.syncedLines.isNotEmpty || nextLyrics.translations.isNotEmpty} '
      'lines=${nextLyrics.syncedLines.length} textLen=${nextLyrics.plainText.trim().length}',
    );

    _context.bumpRevision();
    if (nextLyrics.translations.isNotEmpty) {
      _context.bumpLyricsLayoutRevision();
    }
  }
}
