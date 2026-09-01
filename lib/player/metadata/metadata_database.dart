import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' hide JsonKey;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vynody/models/lyric_line.dart';
import 'package:vynody/player/lyrics/lyrics_cache_models.dart';
import 'package:vynody/player/scanner/scanner_sorting.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
export 'package:vynody/player/lyrics/lyrics_cache_models.dart';

part 'metadata_database.freezed.dart';
part 'metadata_database.g.dart';
part 'metadata_drift_database.dart';

class SongSourceFlags {
  static const int rootScan = 1 << 0;
  static const int systemMedia = 1 << 1;
  static const int external = 1 << 2;

  const SongSourceFlags._();
}

@freezed
abstract class SongMetadata with _$SongMetadata {
  const SongMetadata._();

  const factory SongMetadata({
    int? id,
    int? mediaId,
    required String path,
    required String title,
    required String album,
    required String artist,
    String? albumArtist,
    int? duration,
    String? artworkPath,
    String? thumbnailPath,
    int? artworkWidth,
    int? artworkHeight,
    int? trackNumber,
    int? sourceFlags,
    Uint8List? themeColorsBlob,
    Uint8List? waveformBlob,
    int? lastModifiedTime,
    int? metadataTextScanned,
    int? metadataImgScanned,
    int? createdAt,
    int? deletedAt,
    List<String>? genres,
    @Default(false) bool isAppModified,
  }) = _SongMetadata;

  bool get isModified => isAppModified;

  Map<String, dynamic> toMap() {
    return {
      'mediaId': mediaId,
      'path': path,
      'title': title,
      'album': album,
      'artist': artist,
      'albumArtist': albumArtist,
      'duration': duration,
      'artworkPath': artworkPath,
      'thumbnailPath': thumbnailPath,
      'artworkWidth': artworkWidth,
      'artworkHeight': artworkHeight,
      'trackNumber': trackNumber,
      'sourceFlags': sourceFlags,
      'themeColorsBlob': themeColorsBlob,
      'waveformBlob': waveformBlob,
      'lastModifiedTime': lastModifiedTime,
      'metadataTextScanned': metadataTextScanned,
      'metadataImgScanned': metadataImgScanned,
      'createdAt': createdAt,
      'deletedAt': deletedAt,
      'genres': genres != null ? jsonEncode(genres) : null,
      'isAppModified': isAppModified ? 1 : 0,
    };
  }

  factory SongMetadata.fromMap(Map<String, dynamic> map) {
    List<String>? genres;
    if (map['genres'] != null) {
      final decoded = jsonDecode(map['genres'] as String);
      if (decoded is List) {
        genres = decoded.cast<String>();
      }
    }
    return SongMetadata(
      id: map['id'],
      path: map['path'],
      title: map['title'] ?? 'Unknown',
      album: map['album'] ?? 'Unknown',
      artist: map['artist'] ?? 'Unknown',
      albumArtist: map['albumArtist'],
      duration: map['duration'],
      artworkPath: map['artworkPath'],
      thumbnailPath: map['thumbnailPath'],
      artworkWidth: map['artworkWidth'],
      artworkHeight: map['artworkHeight'],
      trackNumber: map['trackNumber'],
      sourceFlags: map['sourceFlags'],
      themeColorsBlob: map['themeColorsBlob'] as Uint8List?,
      waveformBlob: map['waveformBlob'] as Uint8List?,
      lastModifiedTime: map['lastModifiedTime'],
      metadataTextScanned: map['metadataTextScanned'],
      metadataImgScanned: map['metadataImgScanned'],
      createdAt: map['createdAt'],
      deletedAt: map['deletedAt'],
      genres: genres,
      isAppModified: map['isAppModified'] == 1 || map['isAppModified'] == true,
    );
  }
}

class LibraryInsightSongRecord {
  const LibraryInsightSongRecord({
    required this.song,
    required this.playCount,
    this.lastPlayedAt,
  });

  final SongMetadata song;
  final int playCount;
  final int? lastPlayedAt;
}

class RootScanSweepResult {
  const RootScanSweepResult({
    required this.deletedPaths,
    required this.softDeletedPaths,
  });

  final List<String> deletedPaths;
  final List<String> softDeletedPaths;
}

class AcoustIDCacheRecord {
  final int? id;
  final String fingerprint;
  final int durationSeconds;
  final String resultsJson;
  final int updatedAtMillis;

  const AcoustIDCacheRecord({
    this.id,
    required this.fingerprint,
    required this.durationSeconds,
    required this.resultsJson,
    required this.updatedAtMillis,
  });

  Map<String, dynamic> toMap() {
    return {
      'fingerprint': fingerprint,
      'durationSeconds': durationSeconds,
      'resultsJson': resultsJson,
      'updatedAtMillis': updatedAtMillis,
    };
  }

  factory AcoustIDCacheRecord.fromMap(Map<String, dynamic> map) {
    return AcoustIDCacheRecord(
      id: map['id'] as int?,
      fingerprint: map['fingerprint'] as String? ?? '',
      durationSeconds: (map['durationSeconds'] as int?) ?? 0,
      resultsJson: map['resultsJson'] as String? ?? '[]',
      updatedAtMillis:
          (map['updatedAtMillis'] as int?) ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class ArtworkCacheRecord {
  final int? id;
  final String md5;
  final String? artworkPath;
  final String? thumbnailPath;
  final int? artworkWidth;
  final int? artworkHeight;
  final Uint8List? themeColorsBlob;
  final int updatedAtMillis;

  const ArtworkCacheRecord({
    this.id,
    required this.md5,
    this.artworkPath,
    this.thumbnailPath,
    this.artworkWidth,
    this.artworkHeight,
    this.themeColorsBlob,
    required this.updatedAtMillis,
  });

  Map<String, dynamic> toMap() {
    return {
      'md5': md5,
      'artworkPath': artworkPath,
      'thumbnailPath': thumbnailPath,
      'artworkWidth': artworkWidth,
      'artworkHeight': artworkHeight,
      'themeColorsBlob': themeColorsBlob,
      'updatedAtMillis': updatedAtMillis,
    };
  }

  factory ArtworkCacheRecord.fromMap(Map<String, dynamic> map) {
    return ArtworkCacheRecord(
      id: map['id'] as int?,
      md5: map['md5'] as String? ?? '',
      artworkPath: map['artworkPath'] as String?,
      thumbnailPath: map['thumbnailPath'] as String?,
      artworkWidth: map['artworkWidth'] as int?,
      artworkHeight: map['artworkHeight'] as int?,
      themeColorsBlob: map['themeColorsBlob'] as Uint8List?,
      updatedAtMillis:
          (map['updatedAtMillis'] as int?) ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class ReleaseCoverCacheRecord {
  final int? id;
  final String releaseId;
  final String? largeUrl;
  final String? thumbnailUrl;
  final int updatedAtMillis;

  const ReleaseCoverCacheRecord({
    this.id,
    required this.releaseId,
    this.largeUrl,
    this.thumbnailUrl,
    required this.updatedAtMillis,
  });

  Map<String, dynamic> toMap() {
    return {
      'releaseId': releaseId,
      'largeUrl': largeUrl,
      'thumbnailUrl': thumbnailUrl,
      'updatedAtMillis': updatedAtMillis,
    };
  }

  factory ReleaseCoverCacheRecord.fromMap(Map<String, dynamic> map) {
    return ReleaseCoverCacheRecord(
      id: map['id'] as int?,
      releaseId: map['releaseId'] as String? ?? '',
      largeUrl: map['largeUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      updatedAtMillis:
          (map['updatedAtMillis'] as int?) ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class ArtistCacheRecord {
  final int? id;
  final String queryKey;
  final String? artistId;
  final String? artistName;
  final String? sortName;
  final String? disambiguation;
  final String? country;
  final String? imageFileTitle;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? areaName;
  final String? beginDate;
  final String? endDate;
  final String? tagsJson;
  final String? rawSearchJson;
  final String? rawDetailJson;
  final bool noData;
  final bool imageFetchCompleted;
  final int updatedAtMillis;

  const ArtistCacheRecord({
    this.id,
    required this.queryKey,
    this.artistId,
    this.artistName,
    this.sortName,
    this.disambiguation,
    this.country,
    this.imageFileTitle,
    this.imageUrl,
    this.thumbnailUrl,
    this.areaName,
    this.beginDate,
    this.endDate,
    this.tagsJson,
    this.rawSearchJson,
    this.rawDetailJson,
    required this.noData,
    this.imageFetchCompleted = false,
    required this.updatedAtMillis,
  });

  Map<String, dynamic> toMap() {
    return {
      'queryKey': queryKey,
      'artistId': artistId,
      'artistName': artistName,
      'sortName': sortName,
      'disambiguation': disambiguation,
      'country': country,
      'imageFileTitle': imageFileTitle,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'areaName': areaName,
      'beginDate': beginDate,
      'endDate': endDate,
      'tagsJson': tagsJson,
      'rawSearchJson': rawSearchJson,
      'rawDetailJson': rawDetailJson,
      'noData': noData,
      'imageFetchCompleted': imageFetchCompleted,
      'updatedAtMillis': updatedAtMillis,
    };
  }

  factory ArtistCacheRecord.fromMap(Map<String, dynamic> map) {
    return ArtistCacheRecord(
      id: map['id'] as int?,
      queryKey: map['queryKey'] as String? ?? '',
      artistId: map['artistId'] as String?,
      artistName: map['artistName'] as String?,
      sortName: map['sortName'] as String?,
      disambiguation: map['disambiguation'] as String?,
      country: map['country'] as String?,
      imageFileTitle: map['imageFileTitle'] as String?,
      imageUrl: map['imageUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      areaName: map['areaName'] as String?,
      beginDate: map['beginDate'] as String?,
      endDate: map['endDate'] as String?,
      tagsJson: map['tagsJson'] as String?,
      rawSearchJson: map['rawSearchJson'] as String?,
      rawDetailJson: map['rawDetailJson'] as String?,
      noData: (map['noData'] as int? ?? 0) != 0,
      imageFetchCompleted: (map['imageFetchCompleted'] as int? ?? 0) != 0,
      updatedAtMillis:
          (map['updatedAtMillis'] as int?) ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  ArtistCacheRecord copyWith({
    int? id,
    String? queryKey,
    String? artistId,
    String? artistName,
    String? sortName,
    String? disambiguation,
    String? country,
    String? imageFileTitle,
    String? imageUrl,
    String? thumbnailUrl,
    String? areaName,
    String? beginDate,
    String? endDate,
    String? tagsJson,
    String? rawSearchJson,
    String? rawDetailJson,
    bool? noData,
    bool? imageFetchCompleted,
    int? updatedAtMillis,
  }) {
    return ArtistCacheRecord(
      id: id ?? this.id,
      queryKey: queryKey ?? this.queryKey,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      sortName: sortName ?? this.sortName,
      disambiguation: disambiguation ?? this.disambiguation,
      country: country ?? this.country,
      imageFileTitle: imageFileTitle ?? this.imageFileTitle,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      areaName: areaName ?? this.areaName,
      beginDate: beginDate ?? this.beginDate,
      endDate: endDate ?? this.endDate,
      tagsJson: tagsJson ?? this.tagsJson,
      rawSearchJson: rawSearchJson ?? this.rawSearchJson,
      rawDetailJson: rawDetailJson ?? this.rawDetailJson,
      noData: noData ?? this.noData,
      imageFetchCompleted: imageFetchCompleted ?? this.imageFetchCompleted,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    );
  }
}

class ArtistImageCacheRecord {
  final int? id;
  final String artistId;
  final String imagePath;
  final String? sourceUrl;
  final int? width;
  final int? height;
  final int updatedAtMillis;

  const ArtistImageCacheRecord({
    this.id,
    required this.artistId,
    required this.imagePath,
    this.sourceUrl,
    this.width,
    this.height,
    required this.updatedAtMillis,
  });

  Map<String, dynamic> toMap() {
    return {
      'artistId': artistId,
      'imagePath': imagePath,
      'sourceUrl': sourceUrl,
      'width': width,
      'height': height,
      'updatedAtMillis': updatedAtMillis,
    };
  }

  factory ArtistImageCacheRecord.fromMap(Map<String, dynamic> map) {
    return ArtistImageCacheRecord(
      id: map['id'] as int?,
      artistId: map['artistId'] as String? ?? '',
      imagePath: map['imagePath'] as String? ?? '',
      sourceUrl: map['sourceUrl'] as String?,
      width: map['width'] as int?,
      height: map['height'] as int?,
      updatedAtMillis:
          (map['updatedAtMillis'] as int?) ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class MetadataDatabase {
  static final MetadataDatabase _instance = MetadataDatabase._internal();
  static final MetadataDriftDatabase _db = MetadataDriftDatabase.instance;

  factory MetadataDatabase() => _instance;

  MetadataDatabase._internal();

  Future<void> ensureOpen() => _db.customSelect('SELECT 1').get();

  Future<void> close() => _db.close();

  Stream<List<SongMetadata>> watchAllSongMetadata() =>
      _db.watchAllSongMetadata();

  Stream<SongMetadata?> watchSongMetadata(String path) =>
      _db.watchSongMetadata(path);

  Future<void> insertOrUpdateSong(
    SongMetadata song, {
    int? rootScanSessionId,
  }) => _db.insertOrUpdateSong(song, rootScanSessionId: rootScanSessionId);

  Future<void> insertOrUpdateSongsMerged(
    Iterable<SongMetadata> songs, {
    int? rootScanSessionId,
  }) => _db.insertOrUpdateSongsMerged(
    songs,
    rootScanSessionId: rootScanSessionId,
  );

  Future<void> insertOrUpdateLyricsCache(LyricsCacheRecord record) =>
      _db.insertOrUpdateLyricsCache(record);

  Future<LyricsCacheRecord?> getLyricsCache(String cacheKey) =>
      _db.getLyricsCache(cacheKey);

  Stream<LyricsCacheRecord?> watchLyricsCache(String cacheKey) =>
      _db.watchLyricsCache(cacheKey);

  Future<List<LyricsCacheRecord>> getLyricsCaches(String cacheKey) =>
      _db.getLyricsCaches(cacheKey);

  Stream<List<LyricsCacheRecord>> watchLyricsCaches(String cacheKey) =>
      _db.watchLyricsCaches(cacheKey);

  Future<void> insertOrUpdateLyricsTranslationCache(
    LyricsTranslationCacheRecord record,
  ) => _db.insertOrUpdateLyricsTranslationCache(record);

  Future<List<LyricsTranslationCacheRecord>> getLyricsTranslationCaches(
    String cacheKey,
  ) => _db.getLyricsTranslationCaches(cacheKey);

  Stream<List<LyricsTranslationCacheRecord>> watchLyricsTranslationCaches(
    String cacheKey,
  ) => _db.watchLyricsTranslationCaches(cacheKey);

  Future<void> insertOrUpdateAcoustIDCache(AcoustIDCacheRecord record) =>
      _db.insertOrUpdateAcoustIDCache(record);

  Future<AcoustIDCacheRecord?> getAcoustIDCache(String fingerprint) =>
      _db.getAcoustIDCache(fingerprint);

  Future<void> insertOrUpdateReleaseCoverCache(
    ReleaseCoverCacheRecord record,
  ) => _db.insertOrUpdateReleaseCoverCache(record);

  Future<ReleaseCoverCacheRecord?> getReleaseCoverCache(String releaseId) =>
      _db.getReleaseCoverCache(releaseId);

  Future<void> insertOrUpdateArtworkCache(ArtworkCacheRecord record) =>
      _db.insertOrUpdateArtworkCache(record);

  Future<ArtworkCacheRecord?> getArtworkCache(String md5) =>
      _db.getArtworkCache(md5);

  Future<void> insertOrUpdateArtistCache(ArtistCacheRecord record) =>
      _db.insertOrUpdateArtistCache(record);

  Future<ArtistCacheRecord?> getArtistCache(String queryKey) =>
      _db.getArtistCache(queryKey);

  Future<Map<String, ArtistCacheRecord>> getArtistCachesByKeys(
    Iterable<String> queryKeys,
  ) => _db.getArtistCachesByKeys(queryKeys);

  Future<List<ArtistCacheRecord>> getAllArtistCaches() =>
      _db.getAllArtistCaches();

  Future<void> insertOrUpdateArtistImageCache(ArtistImageCacheRecord record) =>
      _db.insertOrUpdateArtistImageCache(record);

  Future<ArtistImageCacheRecord?> getArtistImageCache(String artistId) =>
      _db.getArtistImageCache(artistId);

  Future<Map<String, ArtistImageCacheRecord>> getArtistImageCachesByIds(
    Iterable<String> artistIds,
  ) => _db.getArtistImageCachesByIds(artistIds);

  Future<SongMetadata?> getSongMetadata(String path) =>
      _db.getSongMetadata(path);

  Future<SongMetadata?> getRemoteSongMetadata(String virtualUri) =>
      _db.getRemoteSongMetadata(virtualUri);

  Future<void> insertOrUpdateRemoteSong(
    SongMetadata song, {
    String? coverArtId,
    String? suffix,
    int? bitRate,
    String? cachedFilePath,
  }) => _db.insertOrUpdateRemoteSong(
    song,
    coverArtId: coverArtId,
    suffix: suffix,
    bitRate: bitRate,
    cachedFilePath: cachedFilePath,
  );

  Future<void> deleteRemoteSongsByServerId(String serverId) =>
      _db.deleteRemoteSongsByServerId(serverId);

  Future<List<SongMetadata>> getRemoteSongsByServerId(String serverId) =>
      _db.getRemoteSongsByServerId(serverId);

  Future<List<SongMetadata>> getAllSongMetadata() => _db.getAllSongMetadata();

  Future<List<SongMetadata>> getSongsUnderPath(String rootPath) =>
      _db.getSongsUnderPath(rootPath);

  Future<int> getSongCountUnderPath(String rootPath) =>
      _db.getSongCountUnderPath(rootPath);

  Future<int> getSongDurationUnderPath(String rootPath) =>
      _db.getSongDurationUnderPath(rootPath);

  Future<SongMetadata?> getRepresentativeSongUnderPath(
    String rootPath, {
    SortCriteria criteria = SortCriteria.filename,
    SortOrder order = SortOrder.ascending,
  }) =>
      _db.getRepresentativeSongUnderPath(
        rootPath,
        criteria: criteria,
        order: order,
      );

  Future<List<SongMetadata>> getSystemMediaSongs() =>
      _db.getSystemMediaSongs();

  Future<List<SongMetadata>> searchSongs(String query, {String? folderPath}) =>
      _db.searchSongs(query, folderPath: folderPath);

  Future<List<String>> searchFolderPaths(String query) =>
      _db.searchFolderPaths(query);

  Future<Map<String, SongMetadata>> getSongMetadataByPaths(
    Iterable<String> paths,
  ) => _db.getSongMetadataByPaths(paths);

  Future<List<SongMetadata>> findSongsByPathSuffix(String suffix) =>
      _db.findSongsByPathSuffix(suffix);

  Future<List<SongMetadata>> findRemoteSongsByRemoteId(String remoteId) =>
      _db.findRemoteSongsByRemoteId(remoteId);

  Future<List<SongMetadata>> findSongsByTitleAndArtist({
    required String title,
    String? artist,
  }) =>
      _db.findSongsByTitleAndArtist(title: title, artist: artist);

  Future<void> recordSongPlayback({
    required String songPath,
    required int playedAt,
    int? playedDurationMillis,
    int? songDurationMillis,
    String? source,
  }) => _db.recordSongPlayback(
    songPath: songPath,
    playedAt: playedAt,
    playedDurationMillis: playedDurationMillis,
    songDurationMillis: songDurationMillis,
    source: source,
  );

  Stream<List<LibraryInsightSongRecord>> watchRecentlyAddedSongs({
    int? startAtMillis,
    int? limit = 500,
  }) => _db.watchRecentlyAddedSongs(
        startAtMillis: startAtMillis,
        limit: limit,
      );

  Stream<List<LibraryInsightSongRecord>> watchMostPlayedSongs({
    int? startAtMillis,
    int? limit = 500,
  }) => _db.watchMostPlayedSongs(
        startAtMillis: startAtMillis,
        limit: limit,
      );

  Stream<List<LibraryInsightSongRecord>> watchRecentlyPlayedSongs({
    int? startAtMillis,
    int? limit = 500,
  }) => _db.watchRecentlyPlayedSongs(
        startAtMillis: startAtMillis,
        limit: limit,
      );

  Future<int> syncSongSourcePresence({
    required int sourceMask,
    required Iterable<String> presentPaths,
    Iterable<String>? scopeRoots,
  }) => _db.syncSongSourcePresence(
    sourceMask: sourceMask,
    presentPaths: presentPaths,
        scopeRoots: scopeRoots,
      );

  Future<void> markRootScanSeenWithToken(
    Iterable<String> paths, {
    required int scanToken,
    required int sourceMask,
  }) => _db.markRootScanSeenWithToken(
    paths,
    scanToken: scanToken,
    sourceMask: sourceMask,
  );

  Future<RootScanSweepResult> sweepRootScanState({
    required int scanToken,
    required int sourceMask,
    required Iterable<String> activeRoots,
  }) => _db.sweepRootScanState(
    scanToken: scanToken,
    sourceMask: sourceMask,
    activeRoots: activeRoots,
  );

  Future<void> bindSongToRoot(String songPath, String rootPath) =>
      _db.bindSongToRoot(songPath, rootPath);

  Future<void> bindSongsToRootBatch(
    Iterable<String> songPaths,
    String rootPath,
  ) => _db.bindSongsToRootBatch(songPaths, rootPath);

  Future<void> unbindRootPaths(Iterable<String> rootPaths) =>
      _db.unbindRootPaths(rootPaths);

  Future<RootScanSweepResult> sweepOrphanSongs({int chunkSize = 2000}) =>
      _db.sweepOrphanSongs(chunkSize: chunkSize);

  Future<void> deleteSongByPath(String path) => _db.deleteSongByPath(path);

  Future<void> clearAll() => _db.clearAllSongs();

  Future<void> clearSongsExceptExternal() => _db.clearSongsExceptExternal();

  Future<void> clearWaveformCache() => _db.clearWaveformCache();

  Future<void> clearLyricsCache() => _db.clearLyricsCache();

  Future<void> clearLyricsCacheByKey(String cacheKey) =>
      _db.clearLyricsCacheByKey(cacheKey);

  Future<void> clearLyricsTranslationCache() =>
      _db.clearLyricsTranslationCache();

  Future<void> clearLyricsTranslationCacheByKey(String cacheKey) =>
      _db.clearLyricsTranslationCacheByKey(cacheKey);

  Future<List<LyricsCacheRecord>> getAllLyricsCaches() =>
      _db.getAllLyricsCaches();

  Future<List<LyricsTranslationCacheRecord>> getAllLyricsTranslationCaches() =>
      _db.getAllLyricsTranslationCaches();

  Future<void> migrateLinuxRootPath(String oldRoot, String newRoot) async {
    if (oldRoot == newRoot) return;
    debugPrint('[PathMigration] Linux root path change detected.');
    debugPrint('[PathMigration] Old root: $oldRoot');
    debugPrint('[PathMigration] New root: $newRoot');

    // 1. Update songs table
    await _db.customStatement(
      'UPDATE songs SET path = REPLACE(path, ?, ?), '
      'artworkPath = REPLACE(artworkPath, ?, ?), '
      'thumbnailPath = REPLACE(thumbnailPath, ?, ?) '
      'WHERE path LIKE ? OR artworkPath LIKE ? OR thumbnailPath LIKE ?',
      <Object>[
        oldRoot,
        newRoot,
        oldRoot,
        newRoot,
        oldRoot,
        newRoot,
        '$oldRoot%',
        '$oldRoot%',
        '$oldRoot%',
      ],
    );

    // 2. Update song_play_history table
    await _db.customStatement(
      'UPDATE song_play_history SET songPath = REPLACE(songPath, ?, ?) '
      'WHERE songPath LIKE ?',
      <Object>[oldRoot, newRoot, '$oldRoot%'],
    );

    // 3. Update lyrics_cache table (cacheKey contains the filePath as prefix, e.g. filePath|title|...)
    await _db.customStatement(
      'UPDATE lyrics_cache SET cacheKey = REPLACE(cacheKey, ?, ?) '
      'WHERE cacheKey LIKE ?',
      <Object>[oldRoot, newRoot, '$oldRoot%'],
    );

    // 4. Update lyrics_translation_cache table
    await _db.customStatement(
      'UPDATE lyrics_translation_cache SET cacheKey = REPLACE(cacheKey, ?, ?) '
      'WHERE cacheKey LIKE ?',
      <Object>[oldRoot, newRoot, '$oldRoot%'],
    );

    // 5. Update artist_image_cache table
    await _db.customStatement(
      'UPDATE artist_image_cache SET imagePath = REPLACE(imagePath, ?, ?) '
      'WHERE imagePath LIKE ?',
      <Object>[oldRoot, newRoot, '$oldRoot%'],
    );

    // 6. Migrate playlists in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getString('playlists');
    if (playlistsJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(playlistsJson);
        bool changed = false;
        for (final playlist in jsonList) {
          if (playlist is Map<String, dynamic>) {
            final songs = playlist['songs'];
            if (songs is List) {
              for (final song in songs) {
                if (song is Map<String, dynamic>) {
                  final path = song['path'];
                  if (path is String && path.startsWith(oldRoot)) {
                    song['path'] = path.replaceFirst(oldRoot, newRoot);
                    changed = true;
                  }
                  final thumbnailPath = song['thumbnailPath'];
                  if (thumbnailPath is String &&
                      thumbnailPath.startsWith(oldRoot)) {
                    song['thumbnailPath'] = thumbnailPath.replaceFirst(
                      oldRoot,
                      newRoot,
                    );
                    changed = true;
                  }
                }
              }
            }
          }
        }
        if (changed) {
          await prefs.setString('playlists', jsonEncode(jsonList));
          debugPrint('[PathMigration] Migrated playlists in SharedPreferences.');
        }
      } catch (e) {
        debugPrint('[PathMigration] Failed to migrate playlists in SharedPreferences: $e');
      }
    }

    // 7. Migrate playback_session_v1 in SharedPreferences
    final rawSession = prefs.getString('playback_session_v1');
    if (rawSession != null && rawSession.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawSession);
        if (decoded is Map<String, dynamic>) {
          bool changed = false;
          final queue = decoded['queue'];
          if (queue is List) {
            for (final song in queue) {
              if (song is Map<String, dynamic>) {
                final path = song['path'];
                if (path is String && path.startsWith(oldRoot)) {
                  song['path'] = path.replaceFirst(oldRoot, newRoot);
                  changed = true;
                }
                final thumbnailPath = song['thumbnailPath'];
                if (thumbnailPath is String &&
                    thumbnailPath.startsWith(oldRoot)) {
                  song['thumbnailPath'] = thumbnailPath.replaceFirst(
                    oldRoot,
                    newRoot,
                  );
                  changed = true;
                }
              }
            }
          }
          if (changed) {
            await prefs.setString(
              'playback_session_v1',
              jsonEncode(decoded),
            );
            debugPrint('[PathMigration] Migrated playback_session_v1 in SharedPreferences.');
          }
        }
      } catch (e) {
        debugPrint('[PathMigration] Failed to migrate playback_session_v1 in SharedPreferences: $e');
      }
    }
  }
}


String _normalizePath(String path) {
  final trimmed = path.trim();
  if (RemoteMediaResolver.isRemoteUri(trimmed)) {
    return trimmed;
  }
  var normalized = p.normalize(trimmed);
  if (Platform.isWindows) {
    normalized = normalized.replaceAll('/', r'\');
    if (normalized.length > 3 && normalized.endsWith(r'\')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
  } else if (normalized.length > 1 && normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}

String _pathLookupKey(String path) {
  final normalized = _normalizePath(path);
  return Platform.isWindows ? normalized.toLowerCase() : normalized;
}

bool _pathsEqual(String left, String right) {
  final normalizedLeft = _normalizePath(left);
  final normalizedRight = _normalizePath(right);
  if (Platform.isWindows) {
    return normalizedLeft.toLowerCase() == normalizedRight.toLowerCase();
  }
  return normalizedLeft == normalizedRight;
}

bool _isWithinAnyRoot(String path, List<String> roots) {
  for (final root in roots) {
    if (_pathsEqual(path, root)) return true;
    if (Platform.isWindows) {
      if (p.isWithin(root.toLowerCase(), path.toLowerCase())) return true;
    } else if (p.isWithin(root, path)) {
      return true;
    }
  }
  return false;
}

int? _mergeSourceFlags(int? existing, int? incoming) {
  if (incoming == null) {
    if (existing == null) return null;
    var flags = existing;
    if ((flags & (SongSourceFlags.rootScan | SongSourceFlags.systemMedia)) != 0) {
      flags &= ~SongSourceFlags.external;
    }
    return flags;
  }
  if (existing == null) {
    var flags = incoming;
    if ((flags & (SongSourceFlags.rootScan | SongSourceFlags.systemMedia)) != 0) {
      flags &= ~SongSourceFlags.external;
    }
    return flags;
  }
  var merged = existing | incoming;
  if ((merged & (SongSourceFlags.rootScan | SongSourceFlags.systemMedia)) != 0) {
    merged &= ~SongSourceFlags.external;
  }
  return merged;
}

