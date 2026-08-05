part of 'metadata_database.dart';

@DriftDatabase(
  tables: [
    Songs,
    SongRoots,
    SongPlayHistories,
    LyricsCaches,
    AcoustidCaches,
    ReleaseCoverCaches,
    LyricsTranslationCaches,
    ArtistCaches,
    ArtistImageCaches,
    ArtworkCaches,
  ],
)
class MetadataDriftDatabase extends _$MetadataDriftDatabase {
  MetadataDriftDatabase._() : super(_openConnection());

  static final MetadataDriftDatabase instance = MetadataDriftDatabase._();

  @override
  int get schemaVersion => 31;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA busy_timeout = 5000');

      if (Platform.isIOS) {
        await _migrateIosSandboxPaths();
      }

      final migrator = createMigrator();
      for (final table in allTables) {
        final exists = await _tableExists(table.actualTableName);
        if (!exists) {
          debugPrint(
            '[Database] Table ${table.actualTableName} is missing, recreating...',
          );
          await migrator.createTable(table as TableInfo<Table, dynamic>);
        }
      }

      await _repairLegacyLyricsCacheRows();
      await _repairLegacyArtistCacheRows();

      // Clean up sourceFlags (remove external flag 4 if combined with rootScan or systemMedia)
      await customStatement('''
        UPDATE songs
        SET sourceFlags = sourceFlags - 4
        WHERE sourceFlags IS NOT NULL
          AND (sourceFlags & 3) != 0
          AND (sourceFlags & 4) != 0
      ''');
    },
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _addColumnIfMissing(m, 'songs', 'artworkWidth', 'INTEGER');
        await _addColumnIfMissing(m, 'songs', 'artworkHeight', 'INTEGER');
      }
      if (from < 3) {
        await _addColumnIfMissing(m, 'songs', 'trackNumber', 'INTEGER');
      }
      if (from < 4) {
        await _addColumnIfMissing(m, 'songs', 'themeColorsBlob', 'BLOB');
      }
      if (from < 5) {
        await _addColumnIfMissing(m, 'songs', 'waveformBlob', 'BLOB');
      }
      if (from < 6) {
        await m.database.customStatement('''
          CREATE TABLE IF NOT EXISTS lyrics_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cacheKey TEXT UNIQUE,
            filePath TEXT,
            title TEXT,
            artist TEXT,
            album TEXT,
            duration INTEGER,
            source TEXT,
            trackId INTEGER,
            score REAL,
            isSynced INTEGER,
            instrumental INTEGER,
            plainLyrics TEXT,
            syncedLyrics TEXT,
            syncedLinesJson TEXT,
            rawJson TEXT,
            updatedAtMillis INTEGER
          )
        ''');
      }
      if (from < 7) {
        await _addColumnIfMissing(m, 'songs', 'thumbnailPath', 'TEXT');
      }
      if (from < 8) {
        await _addColumnIfMissing(m, 'songs', 'lastModifiedTime', 'INTEGER');
      }
      if (from < 9) {
        await m.database.customStatement('''
          CREATE TABLE IF NOT EXISTS acoustid_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fingerprint TEXT UNIQUE,
            durationSeconds INTEGER,
            resultsJson TEXT,
            updatedAtMillis INTEGER
          )
        ''');
      }
      if (from < 10) {
        await m.database.customStatement('''
          CREATE TABLE IF NOT EXISTS release_cover_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            releaseId TEXT UNIQUE,
            largeUrl TEXT,
            thumbnailUrl TEXT,
            updatedAtMillis INTEGER
          )
        ''');
      }
      if (from < 11) {
        await _addColumnIfMissing(m, 'songs', 'genres', 'TEXT');
      }
      if (from < 12) {
        await _addColumnIfMissing(m, 'songs', 'createdAt', 'INTEGER');
      }
      if (from < 13) {
        await m.database.customStatement('''
          CREATE TABLE IF NOT EXISTS lyrics_translation_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cacheKey TEXT,
            languageCode TEXT,
            translatedText TEXT,
            translatedLinesJson TEXT,
            provider TEXT,
            updatedAtMillis INTEGER,
            UNIQUE(cacheKey, languageCode)
          )
        ''');
      }
      if (from < 14) {
        await _addColumnIfMissing(m, 'lyrics_cache', 'cacheKey', 'TEXT');
      }
      if (from < 15) {
        await m.database.customStatement(
          'DROP TABLE IF EXISTS lyrics_translation_cache',
        );
        await m.database.customStatement('''
          CREATE TABLE lyrics_translation_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cacheKey TEXT,
            languageCode TEXT,
            translatedText TEXT,
            translatedLinesJson TEXT,
            provider TEXT,
            updatedAtMillis INTEGER,
            UNIQUE(cacheKey, languageCode)
          )
        ''');
      }
      if (from < 16) {
        await m.database.customStatement('DROP TABLE IF EXISTS acoustid_cache');
        await m.database.customStatement('''
          CREATE TABLE IF NOT EXISTS acoustid_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fingerprint TEXT UNIQUE,
            durationSeconds INTEGER,
            resultsJson TEXT,
            updatedAtMillis INTEGER
          )
        ''');
      }
      if (from < 17) {
        await _addColumnIfMissing(
          m,
          'lyrics_cache',
          'timelineOffsetMillis',
          'INTEGER',
        );
        await _repairLegacyLyricsCacheRows();
      }
      if (from < 18) {
        await _addColumnIfMissing(m, 'songs', 'metadataTextScanned', 'INTEGER');
        await _addColumnIfMissing(m, 'songs', 'metadataImgScanned', 'INTEGER');
      }
      if (from < 19) {
        await _addColumnIfMissing(m, 'songs', 'sourceFlags', 'INTEGER');
      }
      if (from < 20) {
        await m.database.customStatement('''
          CREATE TABLE IF NOT EXISTS artist_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            queryKey TEXT UNIQUE,
            artistId TEXT,
            artistName TEXT,
            sortName TEXT,
            disambiguation TEXT,
            country TEXT,
            imageFileTitle TEXT,
            imageUrl TEXT,
            thumbnailUrl TEXT,
            areaName TEXT,
            beginDate TEXT,
            endDate TEXT,
            tagsJson TEXT,
            rawSearchJson TEXT,
            rawDetailJson TEXT,
            noData INTEGER,
            updatedAtMillis INTEGER
          )
        ''');
      }
      if (from < 21) {
        await m.database.customStatement('''
          CREATE TABLE IF NOT EXISTS artist_image_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            artistId TEXT UNIQUE,
            imagePath TEXT,
            sourceUrl TEXT,
            width INTEGER,
            height INTEGER,
            updatedAtMillis INTEGER
          )
        ''');
      }
      if (from < 22) {
        await _addColumnIfMissing(
          m,
          'artist_cache',
          'imageFetchCompleted',
          'INTEGER',
        );
        await m.database.customStatement('''
          UPDATE artist_cache
          SET imageFetchCompleted = 0
          WHERE imageFetchCompleted IS NULL
        ''');
      }
      if (from < 23) {
        await m.database.customStatement('''
          CREATE TABLE IF NOT EXISTS song_play_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            songPath TEXT NOT NULL,
            playedAt INTEGER NOT NULL,
            playedDurationMillis INTEGER,
            songDurationMillis INTEGER,
            source TEXT
          )
        ''');
        await m.database.customStatement('''
          CREATE INDEX IF NOT EXISTS idx_song_play_history_song_path_played_at
          ON song_play_history(songPath, playedAt DESC)
        ''');
        await m.database.customStatement('''
          CREATE INDEX IF NOT EXISTS idx_song_play_history_played_at
          ON song_play_history(playedAt DESC)
        ''');
      }
      if (from < 24) {
        await _addColumnIfMissing(
          m,
          'songs',
          'lastSeenRootScanSessionId',
          'INTEGER',
        );
      }
      if (from < 25) {
        await _addColumnIfMissing(
          m,
          'songs',
          'lastSeenRootScanToken',
          'INTEGER',
        );
        await _addColumnIfMissing(m, 'songs', 'missingReason', 'TEXT');
        await _addColumnIfMissing(m, 'songs', 'deletedAt', 'INTEGER');
      }
      if (from < 27) {
        if (await _columnExists('songs', 'isSoftDeleted')) {
          final rows = await customSelect(
            '''
            SELECT thumbnailPath
            FROM songs
            WHERE isSoftDeleted = 1
              AND deletedAt IS NULL
            ''',
            readsFrom: {songs},
          ).get();
          final deletedAtMillis = DateTime.now().millisecondsSinceEpoch;
          await customStatement('''
            UPDATE songs
            SET deletedAt = $deletedAtMillis,
                thumbnailPath = NULL
            WHERE isSoftDeleted = 1
              AND deletedAt IS NULL
          ''');
          await _deleteThumbnailFiles(
            rows.map((row) => row.read<String?>('thumbnailPath')),
          );
        }
      }
      if (from < 28) {
        await _addColumnIfMissing(m, 'songs', 'isAppModified', 'INTEGER');
        await m.database.customStatement('''
          UPDATE songs
          SET isAppModified = 0
          WHERE isAppModified IS NULL
        ''');
      }
      if (from < 29) {
        await m.database.customStatement('ALTER TABLE lyrics_cache RENAME TO lyrics_cache_old;');
        await m.database.customStatement('''
          CREATE TABLE lyrics_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cacheKey TEXT NOT NULL,
            source TEXT NOT NULL,
            languageCode TEXT NOT NULL DEFAULT '',
            isSynced INTEGER NOT NULL,
            syncedLyrics TEXT,
            syncedLinesJson TEXT NOT NULL,
            timelineOffsetMillis INTEGER NOT NULL,
            updatedAtMillis INTEGER NOT NULL,
            UNIQUE(cacheKey, source, languageCode)
          )
        ''');
        await m.database.customStatement('''
          INSERT INTO lyrics_cache (
            id, cacheKey, source, languageCode, isSynced, syncedLyrics,
            syncedLinesJson, timelineOffsetMillis, updatedAtMillis
          )
          SELECT 
            id, cacheKey, source, '', isSynced, syncedLyrics,
            syncedLinesJson, timelineOffsetMillis, updatedAtMillis
          FROM lyrics_cache_old;
        ''');
        await m.database.customStatement('DROP TABLE lyrics_cache_old;');
      }
      if (from < 30) {
        await _addColumnIfMissing(m, 'songs', 'mediaId', 'INTEGER');
      }
    },
  );

  Future<void> _addColumnIfMissing(
    Migrator m,
    String table,
    String column,
    String sqlType,
  ) async {
    if (await _columnExists(table, column)) {
      return;
    }
    await m.database.customStatement(
      'ALTER TABLE $table ADD COLUMN $column $sqlType',
    );
  }

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((row) => row.data['name'] == column);
  }

  Future<bool> _tableExists(String table) async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
      variables: [Variable(table)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<void> _repairLegacyLyricsCacheRows() async {
    if (!await _columnExists('lyrics_cache', 'timelineOffsetMillis')) {
      return;
    }

    await customStatement('''
      UPDATE lyrics_cache
      SET timelineOffsetMillis = 0
      WHERE timelineOffsetMillis IS NULL
    ''');
  }

  Future<void> _repairLegacyArtistCacheRows() async {
    if (await _columnExists('artist_cache', 'noData')) {
      await customStatement('''
        UPDATE artist_cache
        SET noData = 0
        WHERE noData IS NULL
      ''');
    }

    if (await _columnExists('artist_cache', 'imageFetchCompleted')) {
      await customStatement('''
        UPDATE artist_cache
        SET imageFetchCompleted = 0
        WHERE imageFetchCompleted IS NULL
      ''');
    }
  }

  Future<void> _deleteThumbnailFiles(Iterable<String?> thumbnailPaths) async {
    for (final thumbnailPath in thumbnailPaths) {
      await _deleteThumbnailFile(thumbnailPath);
    }
  }

  Future<void> _deleteThumbnailFile(String? thumbnailPath) async {
    final normalizedPath = thumbnailPath?.trim();
    if (normalizedPath == null || normalizedPath.isEmpty) {
      return;
    }

    try {
      // 避免当同一首歌曲在多个根目录里有副本时，因其中一个副本被清理而导致共用的缩略图文件被删掉。
      // 仅当没有其他有效（未被彻底删除）的歌曲记录引用该缩略图时，才物理删除文件。
      final query = select(songs)
        ..where((t) => t.thumbnailPath.equals(normalizedPath) & t.deletedAt.isNull());
      final count = await query.get().then((rows) => rows.length);
      if (count > 0) {
        return;
      }
    } catch (e) {
      debugPrint('[Database] Failed to query thumbnail reference count: $e');
    }

    try {
      final file = File(normalizedPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint(
        '[Database] Failed to delete thumbnail file $normalizedPath: $e',
      );
    }
  }

  Stream<List<SongMetadata>> watchAllSongMetadata() {
    return customSelect(
      '''
      SELECT *
      FROM songs
      WHERE deletedAt IS NULL
      ORDER BY LOWER(path) ASC
      ''',
      readsFrom: {songs},
    ).watch().map(
      (rows) => rows.map(_songFromQueryRow).toList(growable: false),
    );
  }

  Future<List<SongMetadata>> getAllSongMetadata() async {
    final rows = await customSelect(
      '''
      SELECT *
      FROM songs
      WHERE deletedAt IS NULL
      ORDER BY LOWER(path) ASC
      ''',
      readsFrom: {songs},
    ).get();
    return rows.map(_songFromQueryRow).toList(growable: false);
  }

  Future<List<SongMetadata>> getSongsUnderPath(String rootPath) async {
    final normalized = _normalizePath(rootPath);
    if (normalized.isEmpty) return const [];
    if (normalized == 'system') {
      return getSystemMediaSongs();
    }
    if (normalized.startsWith('system/')) {
      final relativePath = normalized.substring('system/'.length);
      final separator = Platform.isWindows ? '\\' : '/';
      final prefixPattern = relativePath.endsWith(separator) ? '$relativePath%' : '$relativePath$separator%';
      final rows = await customSelect(
        '''
        SELECT *
        FROM songs
        WHERE (sourceFlags & ?) != 0
          AND (path = ? OR path LIKE ? OR path = ? OR path LIKE ?)
          AND deletedAt IS NULL
        ORDER BY LOWER(path) ASC
        ''',
        variables: [
          Variable(SongSourceFlags.systemMedia),
          Variable(relativePath),
          Variable(prefixPattern),
          Variable(normalized),
          Variable('$normalized%'),
        ],
        readsFrom: {songs},
      ).get();
      return rows.map(_songFromQueryRow).toList(growable: false);
    }

    final separator = Platform.isWindows ? '\\' : '/';
    final prefixPattern = normalized.endsWith(separator) ? '$normalized%' : '$normalized$separator%';
    final rows = await customSelect(
      '''
      SELECT *
      FROM songs
      WHERE (path = ? OR path LIKE ?)
        AND deletedAt IS NULL
      ORDER BY LOWER(path) ASC
      ''',
      variables: [Variable(normalized), Variable(prefixPattern)],
      readsFrom: {songs},
    ).get();
    return rows.map(_songFromQueryRow).toList(growable: false);
  }

  Future<int> getSongCountUnderPath(String rootPath) async {
    final normalized = _normalizePath(rootPath);
    if (normalized.isEmpty) return 0;
    if (normalized.startsWith('system/')) {
      final relativePath = normalized.substring('system/'.length);
      final separator = Platform.isWindows ? '\\' : '/';
      final prefixPattern = relativePath.endsWith(separator) ? '$relativePath%' : '$relativePath$separator%';
      final row = await customSelect(
        '''
        SELECT COUNT(*) AS c
        FROM songs
        WHERE (sourceFlags & ?) != 0
          AND (path = ? OR path LIKE ? OR path = ? OR path LIKE ?)
          AND deletedAt IS NULL
        ''',
        variables: [
          Variable(SongSourceFlags.systemMedia),
          Variable(relativePath),
          Variable(prefixPattern),
          Variable(normalized),
          Variable('$normalized%'),
        ],
        readsFrom: {songs},
      ).getSingle();
      return row.read<int>('c');
    }

    final separator = Platform.isWindows ? '\\' : '/';
    final prefixPattern = normalized.endsWith(separator) ? '$normalized%' : '$normalized$separator%';
    final row = await customSelect(
      '''
      SELECT COUNT(*) AS c
      FROM songs
      WHERE (path = ? OR path LIKE ?)
        AND deletedAt IS NULL
      ''',
      variables: [Variable(normalized), Variable(prefixPattern)],
      readsFrom: {songs},
    ).getSingle();
    return row.read<int>('c');
  }

  Future<int> getSongDurationUnderPath(String rootPath) async {
    final normalized = _normalizePath(rootPath);
    if (normalized.isEmpty) return 0;
    if (normalized.startsWith('system/')) {
      final relativePath = normalized.substring('system/'.length);
      final separator = Platform.isWindows ? '\\' : '/';
      final prefixPattern = relativePath.endsWith(separator) ? '$relativePath%' : '$relativePath$separator%';
      final row = await customSelect(
        '''
        SELECT SUM(duration) AS s
        FROM songs
        WHERE (sourceFlags & ?) != 0
          AND (path = ? OR path LIKE ? OR path = ? OR path LIKE ?)
          AND deletedAt IS NULL
        ''',
        variables: [
          Variable(SongSourceFlags.systemMedia),
          Variable(relativePath),
          Variable(prefixPattern),
          Variable(normalized),
          Variable('$normalized%'),
        ],
        readsFrom: {songs},
      ).getSingle();
      return row.read<int?>('s') ?? 0;
    }

    final separator = Platform.isWindows ? '\\' : '/';
    final prefixPattern = normalized.endsWith(separator) ? '$normalized%' : '$normalized$separator%';
    final row = await customSelect(
      '''
      SELECT SUM(duration) AS s
      FROM songs
      WHERE (path = ? OR path LIKE ?)
        AND deletedAt IS NULL
      ''',
      variables: [Variable(normalized), Variable(prefixPattern)],
      readsFrom: {songs},
    ).getSingle();
    return row.read<int?>('s') ?? 0;
  }

  Future<SongMetadata?> getRepresentativeSongUnderPath(
    String rootPath, {
    SortCriteria criteria = SortCriteria.filename,
    SortOrder order = SortOrder.ascending,
  }) async {
    final normalized = _normalizePath(rootPath);
    if (normalized.isEmpty) return null;

    final isDesc = order == SortOrder.descending;
    final dir = isDesc ? 'DESC' : 'ASC';

    final String orderByClause = switch (criteria) {
      SortCriteria.title =>
        'COALESCE(NULLIF(title, \'\'), path) $dir, path $dir',
      SortCriteria.trackNumber =>
        isDesc
            ? 'CASE WHEN trackNumber IS NOT NULL THEN 0 ELSE 1 END, trackNumber DESC, path DESC'
            : 'CASE WHEN trackNumber IS NOT NULL THEN 0 ELSE 1 END, trackNumber ASC, path ASC',
      SortCriteria.filename =>
        'path $dir',
    };

    if (normalized.startsWith('system/')) {
      final relativePath = normalized.substring('system/'.length);
      final separator = Platform.isWindows ? '\\' : '/';
      final prefixPattern = relativePath.endsWith(separator) ? '$relativePath%' : '$relativePath$separator%';
      final subPrefixPattern = relativePath.endsWith(separator) ? '$relativePath%$separator%' : '$relativePath$separator%$separator%';

      final depthOrder = 'CASE WHEN (path = ? OR path = ? OR (path LIKE ? AND path NOT LIKE ?)) THEN 0 ELSE 1 END, $orderByClause';
      final vars = [
        Variable(relativePath),
        Variable(normalized),
        Variable(prefixPattern),
        Variable(subPrefixPattern),
        Variable(SongSourceFlags.systemMedia),
        Variable(relativePath),
        Variable(prefixPattern),
        Variable(normalized),
        Variable('$normalized%'),
      ];

      var row = await customSelect(
        '''
        SELECT *
        FROM songs
        WHERE (sourceFlags & ?) != 0
          AND (path = ? OR path LIKE ? OR path = ? OR path LIKE ?)
          AND deletedAt IS NULL
          AND (NULLIF(artworkPath, '') IS NOT NULL OR NULLIF(thumbnailPath, '') IS NOT NULL)
        ORDER BY $depthOrder
        LIMIT 1
        ''',
        variables: vars,
        readsFrom: {songs},
      ).getSingleOrNull();

      row ??= await customSelect(
        '''
        SELECT *
        FROM songs
        WHERE (sourceFlags & ?) != 0
          AND (path = ? OR path LIKE ? OR path = ? OR path LIKE ?)
          AND deletedAt IS NULL
        ORDER BY $depthOrder
        LIMIT 1
        ''',
        variables: vars,
        readsFrom: {songs},
      ).getSingleOrNull();

      return row == null ? null : _songFromQueryRow(row);
    }

    final separator = Platform.isWindows ? '\\' : '/';
    final prefixPattern = normalized.endsWith(separator) ? '$normalized%' : '$normalized$separator%';
    final subPrefixPattern = normalized.endsWith(separator) ? '$normalized%$separator%' : '$normalized$separator%$separator%';

    final depthOrder = 'CASE WHEN (path = ? OR (path LIKE ? AND path NOT LIKE ?)) THEN 0 ELSE 1 END, $orderByClause';
    final vars = [
      Variable(normalized),
      Variable(prefixPattern),
      Variable(subPrefixPattern),
      Variable(normalized),
      Variable(prefixPattern),
    ];

    // 1. Try with artwork / thumbnail / mediaId
    var row = await customSelect(
      '''
      SELECT *
      FROM songs
      WHERE (path = ? OR path LIKE ?)
        AND deletedAt IS NULL
        AND (NULLIF(artworkPath, '') IS NOT NULL OR NULLIF(thumbnailPath, '') IS NOT NULL)
      ORDER BY $depthOrder
      LIMIT 1
      ''',
      variables: vars,
      readsFrom: {songs},
    ).getSingleOrNull();

    // 2. Try without artwork
    row ??= await customSelect(
      '''
      SELECT *
      FROM songs
      WHERE (path = ? OR path LIKE ?)
        AND deletedAt IS NULL
      ORDER BY $depthOrder
      LIMIT 1
      ''',
      variables: vars,
      readsFrom: {songs},
    ).getSingleOrNull();

    return row == null ? null : _songFromQueryRow(row);
  }

  Future<List<SongMetadata>> getSystemMediaSongs() async {
    final rows = await customSelect(
      '''
      SELECT *
      FROM songs
      WHERE (sourceFlags & ?) != 0
        AND deletedAt IS NULL
      ORDER BY path ASC
      ''',
      variables: [Variable(SongSourceFlags.systemMedia)],
      readsFrom: {songs},
    ).get();
    return rows.map(_songFromQueryRow).toList();
  }

  Future<List<SongMetadata>> searchSongs(
    String query, {
    String? folderPath,
  }) async {
    final pattern = '%$query%';
    if (folderPath != null && folderPath.isNotEmpty) {
      final normalizedFolder = _normalizePath(folderPath);
      if (normalizedFolder == 'system') {
        final rows = await customSelect(
          '''
          SELECT *
          FROM songs
          WHERE (sourceFlags & ?) != 0
            AND (title LIKE ? OR artist LIKE ? OR album LIKE ? OR path LIKE ?)
            AND deletedAt IS NULL
          ORDER BY LOWER(path) ASC
          ''',
          variables: [
            Variable(SongSourceFlags.systemMedia),
            Variable(pattern),
            Variable(pattern),
            Variable(pattern),
            Variable(pattern),
          ],
          readsFrom: {songs},
        ).get();
        return rows.map(_songFromQueryRow).toList(growable: false);
      } else if (normalizedFolder.startsWith('system/')) {
        final relativePath = normalizedFolder.substring('system/'.length);
        final separator = Platform.isWindows ? '\\' : '/';
        final prefixPattern = relativePath.endsWith(separator)
            ? '$relativePath%'
            : '$relativePath$separator%';
        final rows = await customSelect(
          '''
          SELECT *
          FROM songs
          WHERE (sourceFlags & ?) != 0
            AND (path = ? OR path LIKE ? OR path = ? OR path LIKE ?)
            AND (title LIKE ? OR artist LIKE ? OR album LIKE ? OR path LIKE ?)
            AND deletedAt IS NULL
          ORDER BY LOWER(path) ASC
          ''',
          variables: [
            Variable(SongSourceFlags.systemMedia),
            Variable(relativePath),
            Variable(prefixPattern),
            Variable(normalizedFolder),
            Variable('$normalizedFolder%'),
            Variable(pattern),
            Variable(pattern),
            Variable(pattern),
            Variable(pattern),
          ],
          readsFrom: {songs},
        ).get();
        return rows.map(_songFromQueryRow).toList(growable: false);
      } else {
        final separator = Platform.isWindows ? '\\' : '/';
        final prefixPattern = normalizedFolder.endsWith(separator)
            ? '$normalizedFolder%'
            : '$normalizedFolder$separator%';
        final rows = await customSelect(
          '''
          SELECT *
          FROM songs
          WHERE (path = ? OR path LIKE ?)
            AND (title LIKE ? OR artist LIKE ? OR album LIKE ? OR path LIKE ?)
            AND deletedAt IS NULL
          ORDER BY LOWER(path) ASC
          ''',
          variables: [
            Variable(normalizedFolder),
            Variable(prefixPattern),
            Variable(pattern),
            Variable(pattern),
            Variable(pattern),
            Variable(pattern),
          ],
          readsFrom: {songs},
        ).get();
        return rows.map(_songFromQueryRow).toList(growable: false);
      }
    }

    final rows = await customSelect(
      '''
      SELECT *
      FROM songs
      WHERE (title LIKE ? OR artist LIKE ? OR album LIKE ? OR path LIKE ?)
        AND deletedAt IS NULL
      ORDER BY LOWER(path) ASC
      ''',
      variables: [
        Variable(pattern),
        Variable(pattern),
        Variable(pattern),
        Variable(pattern),
      ],
      readsFrom: {songs},
    ).get();
    return rows.map(_songFromQueryRow).toList(growable: false);
  }

  Future<List<String>> searchFolderPaths(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final pattern = '%$trimmed%';
    final rows = await customSelect(
      '''
      SELECT DISTINCT path
      FROM songs
      WHERE path LIKE ?
        AND deletedAt IS NULL
      ORDER BY LOWER(path) ASC
      ''',
      variables: [Variable(pattern)],
      readsFrom: {songs},
    ).get();

    final distinctDirs = <String>{};
    final lowercaseQuery = trimmed.toLowerCase();

    for (final row in rows) {
      final filePath = row.read<String>('path');
      var dirPath = p.dirname(filePath);
      while (dirPath.isNotEmpty && dirPath != p.rootPrefix(dirPath)) {
        final dirName = p.basename(dirPath);
        if (dirName.toLowerCase().contains(lowercaseQuery)) {
          distinctDirs.add(dirPath);
        }
        final parent = p.dirname(dirPath);
        if (parent == dirPath) break;
        dirPath = parent;
      }
    }
    return distinctDirs.toList(growable: false);
  }

  Stream<SongMetadata?> watchSongMetadata(String path) {
    final normalizedPath = _normalizePath(path);
    if (normalizedPath.isEmpty) {
      return Stream<SongMetadata?>.value(null);
    }
    return customSelect(
      '''
      SELECT *
      FROM songs
      WHERE path = ?
        AND deletedAt IS NULL
      LIMIT 1
      ''',
      variables: [Variable(normalizedPath)],
      readsFrom: {songs},
    ).watchSingleOrNull().map(
      (row) => row == null ? null : _songFromQueryRow(row),
    );
  }

  Future<SongMetadata?> getSongMetadata(String path) async {
    final normalizedPath = _normalizePath(path);
    if (normalizedPath.isEmpty) {
      return null;
    }
    final row = await customSelect(
      '''
      SELECT *
      FROM songs
      WHERE path = ?
        AND deletedAt IS NULL
      LIMIT 1
      ''',
      variables: [Variable(normalizedPath)],
      readsFrom: {songs},
    ).getSingleOrNull();
    return row == null ? null : _songFromQueryRow(row);
  }

  Future<Map<String, SongMetadata>> getSongMetadataByPaths(
    Iterable<String> paths,
  ) async {
    final normalizedPaths = paths
        .map(_normalizePath)
        .where((path) => path.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedPaths.isEmpty) {
      return {};
    }

    final result = <String, SongMetadata>{};
    const batchSize = 500;
    await transaction(() async {
      for (var i = 0; i < normalizedPaths.length; i += batchSize) {
        if (i > 0 && i % 5000 == 0) {
          await Future<void>.delayed(Duration.zero);
        }
        final chunk = normalizedPaths.sublist(
          i,
          i + batchSize > normalizedPaths.length
              ? normalizedPaths.length
              : i + batchSize,
        );
        final rows = await customSelect(
          '''
          SELECT *
          FROM songs
          WHERE path IN (${List.filled(chunk.length, '?').join(', ')})
            AND deletedAt IS NULL
          ''',
          variables: chunk.map(Variable.new).toList(growable: false),
          readsFrom: {songs},
        ).get();

        for (final row in rows) {
          result[_pathLookupKey(row.read<String>('path'))] =
              _songFromQueryRow(row);
        }
      }
    });
    return result;
  }

  Future<void> insertOrUpdateSong(
    SongMetadata song, {
    int? rootScanSessionId,
  }) async {
    final normalizedPath = _normalizePath(song.path);
    if (normalizedPath.isEmpty) return;

    final existing =
        await (select(songs)
              ..where((t) => t.path.equals(normalizedPath))
              ..limit(1))
            .getSingleOrNull();
    final mergedSourceFlags = _mergeSourceFlags(
      existing?.sourceFlags,
      song.sourceFlags,
    );

    final updatedSong = song.copyWith(
      path: normalizedPath,
      sourceFlags: mergedSourceFlags,
    );
    final companion = _songCompanion(
      updatedSong,
      lastSeenRootScanSessionId: rootScanSessionId,
    );

    if (existing != null) {
      await (update(
        songs,
      )..where((t) => t.path.equals(existing.path))).write(companion);
      return;
    }

    await into(songs).insert(companion);
  }

  Future<void> insertOrUpdateSongsMerged(
    Iterable<SongMetadata> songsList, {
    int? rootScanSessionId,
  }) async {
    final dedupedByPath = <String, SongMetadata>{};
    for (final song in songsList) {
      final normalizedPath = _normalizePath(song.path);
      if (normalizedPath.isEmpty) continue;
      dedupedByPath[_pathLookupKey(normalizedPath)] = song.copyWith(
        path: normalizedPath,
      );
    }

    final normalizedSongs = dedupedByPath.values.toList(growable: false);
    if (normalizedSongs.isEmpty) return;
    final existingRows =
        await (select(songs)..where(
              (t) => t.path.isIn(
                normalizedSongs.map((song) => song.path).toList(),
              ),
            ))
            .get();
    final existingByPath = {
      for (final row in existingRows)
        _pathLookupKey(row.path): _songFromTableRow(row),
    };

    await transaction(() async {
      for (final song in normalizedSongs) {
        final existing = existingByPath[_pathLookupKey(song.path)];
        final mergedCompanion = _songCompanion(
          song.copyWith(
            sourceFlags: _mergeSourceFlags(
              existing?.sourceFlags,
              song.sourceFlags,
            ),
          ),
          lastSeenRootScanSessionId: rootScanSessionId,
        );
        await into(songs).insert(
          mergedCompanion,
          onConflict: DoUpdate((old) => mergedCompanion, target: [songs.path]),
        );
      }
    });
  }

  Future<void> recordSongPlayback({
    required String songPath,
    required int playedAt,
    int? playedDurationMillis,
    int? songDurationMillis,
    String? source,
  }) async {
    final normalizedPath = _normalizePath(songPath);
    if (normalizedPath.isEmpty) return;

    await into(songPlayHistories).insert(
      SongPlayHistoriesCompanion.insert(
        songPath: normalizedPath,
        playedAt: playedAt,
        playedDurationMillis: Value(playedDurationMillis),
        songDurationMillis: Value(songDurationMillis),
        source: Value(source?.trim().isEmpty == true ? null : source?.trim()),
      ),
    );
  }

  Stream<List<LibraryInsightSongRecord>> watchRecentlyAddedSongs({
    int? startAtMillis,
    int? limit = 500,
  }) {
    final buffer = StringBuffer()
      ..writeln('SELECT')
      ..writeln('  s.id,')
      ..writeln('  s.path,')
      ..writeln('  s.title,')
      ..writeln('  s.album,')
      ..writeln('  s.artist,')
      ..writeln('  s.duration,')
      ..writeln('  s.artworkPath,')
      ..writeln('  s.thumbnailPath,')
      ..writeln('  s.artworkWidth,')
      ..writeln('  s.artworkHeight,')
      ..writeln('  s.trackNumber,')
      ..writeln('  s.sourceFlags,')
      ..writeln('  s.themeColorsBlob,')
      ..writeln('  s.waveformBlob,')
      ..writeln('  s.lastModifiedTime,')
      ..writeln('  s.metadataTextScanned,')
      ..writeln('  s.metadataImgScanned,')
      ..writeln('  s.createdAt,')
      ..writeln('  s.genres,')
      ..writeln('  s.isAppModified,')
      ..writeln('  0 AS playCount,')
      ..writeln('  NULL AS lastPlayedAt')
      ..writeln('FROM songs s')
      ..writeln('WHERE s.createdAt IS NOT NULL')
      ..writeln('  AND s.deletedAt IS NULL');

    final variables = <Variable<Object>>[];
    if (startAtMillis != null) {
      buffer.writeln('  AND s.createdAt >= ?');
      variables.add(Variable.withInt(startAtMillis));
    }

    buffer
      ..writeln('ORDER BY s.createdAt DESC,')
      ..writeln("LOWER(COALESCE(s.title, '')) ASC,")
      ..writeln('LOWER(s.path) ASC');

    if (limit != null && limit > 0) {
      buffer.writeln('LIMIT ?');
      variables.add(Variable.withInt(limit));
    }

    return customSelect(
      buffer.toString(),
      variables: variables,
      readsFrom: {songs},
    ).watch().map(
      (rows) => rows
          .map((row) => _libraryInsightSongRecordFromRow(row))
          .toList(growable: false),
    );
  }

  Stream<List<LibraryInsightSongRecord>> watchMostPlayedSongs({
    int? startAtMillis,
    int? limit = 500,
  }) {
    final buffer = StringBuffer()
      ..writeln('SELECT')
      ..writeln('  s.id,')
      ..writeln('  s.path,')
      ..writeln('  s.title,')
      ..writeln('  s.album,')
      ..writeln('  s.artist,')
      ..writeln('  s.duration,')
      ..writeln('  s.artworkPath,')
      ..writeln('  s.thumbnailPath,')
      ..writeln('  s.artworkWidth,')
      ..writeln('  s.artworkHeight,')
      ..writeln('  s.trackNumber,')
      ..writeln('  s.sourceFlags,')
      ..writeln('  s.themeColorsBlob,')
      ..writeln('  s.waveformBlob,')
      ..writeln('  s.lastModifiedTime,')
      ..writeln('  s.metadataTextScanned,')
      ..writeln('  s.metadataImgScanned,')
      ..writeln('  s.createdAt,')
      ..writeln('  s.genres,')
      ..writeln('  s.isAppModified,')
      ..writeln('  COUNT(h.id) AS playCount,')
      ..writeln('  MAX(h.playedAt) AS lastPlayedAt')
      ..writeln('FROM songs s')
      ..writeln('JOIN song_play_history h ON h.songPath = s.path')
      ..writeln('WHERE s.deletedAt IS NULL');

    final variables = <Variable<Object>>[];
    if (startAtMillis != null) {
      buffer.writeln('  AND h.playedAt >= ?');
      variables.add(Variable.withInt(startAtMillis));
    }

    buffer
      ..writeln('GROUP BY s.path')
      ..writeln('ORDER BY playCount DESC,')
      ..writeln('lastPlayedAt DESC,')
      ..writeln("LOWER(COALESCE(s.title, '')) ASC,")
      ..writeln('LOWER(s.path) ASC');

    if (limit != null && limit > 0) {
      buffer.writeln('LIMIT ?');
      variables.add(Variable.withInt(limit));
    }

    return customSelect(
      buffer.toString(),
      variables: variables,
      readsFrom: {songs, songPlayHistories},
    ).watch().map(
      (rows) => rows
          .map((row) => _libraryInsightSongRecordFromRow(row))
          .toList(growable: false),
    );
  }

  Stream<List<LibraryInsightSongRecord>> watchRecentlyPlayedSongs({
    int? startAtMillis,
    int? limit = 500,
  }) {
    final buffer = StringBuffer()
      ..writeln('SELECT')
      ..writeln('  s.id,')
      ..writeln('  s.path,')
      ..writeln('  s.title,')
      ..writeln('  s.album,')
      ..writeln('  s.artist,')
      ..writeln('  s.duration,')
      ..writeln('  s.artworkPath,')
      ..writeln('  s.thumbnailPath,')
      ..writeln('  s.artworkWidth,')
      ..writeln('  s.artworkHeight,')
      ..writeln('  s.trackNumber,')
      ..writeln('  s.sourceFlags,')
      ..writeln('  s.themeColorsBlob,')
      ..writeln('  s.waveformBlob,')
      ..writeln('  s.lastModifiedTime,')
      ..writeln('  s.metadataTextScanned,')
      ..writeln('  s.metadataImgScanned,')
      ..writeln('  s.createdAt,')
      ..writeln('  s.genres,')
      ..writeln('  s.isAppModified,')
      ..writeln('  COUNT(h.id) AS playCount,')
      ..writeln('  MAX(h.playedAt) AS lastPlayedAt')
      ..writeln('FROM songs s')
      ..writeln('JOIN song_play_history h ON h.songPath = s.path')
      ..writeln('WHERE s.deletedAt IS NULL');

    final variables = <Variable<Object>>[];
    if (startAtMillis != null) {
      buffer.writeln('  AND h.playedAt >= ?');
      variables.add(Variable.withInt(startAtMillis));
    }

    buffer
      ..writeln('GROUP BY s.path')
      ..writeln('ORDER BY lastPlayedAt DESC,')
      ..writeln("LOWER(COALESCE(s.title, '')) ASC,")
      ..writeln('LOWER(s.path) ASC');

    if (limit != null && limit > 0) {
      buffer.writeln('LIMIT ?');
      variables.add(Variable.withInt(limit));
    }

    return customSelect(
      buffer.toString(),
      variables: variables,
      readsFrom: {songs, songPlayHistories},
    ).watch().map(
      (rows) => rows
          .map((row) => _libraryInsightSongRecordFromRow(row))
          .toList(growable: false),
    );
  }

  Future<void> deleteSongByPath(String path) async {
    final normalizedPath = _normalizePath(path);
    if (normalizedPath.isEmpty) return;

    final row =
        await (select(songs)
              ..where((t) => t.path.equals(normalizedPath))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return;

    await customStatement(
      '''
      UPDATE songs
      SET deletedAt = ?,
          thumbnailPath = NULL
      WHERE path = ?
      ''',
      <Object>[DateTime.now().millisecondsSinceEpoch, normalizedPath],
    );
    await _deleteThumbnailFile(row.thumbnailPath);
  }

  Future<void> clearAllSongs() async {
    final rows = await select(songs).get();
    await delete(songs).go();
    await _deleteThumbnailFiles(rows.map((row) => row.thumbnailPath));
  }

  Future<void> clearSongsExceptExternal() async {
    final rows =
        await (select(songs)..where(
              (t) =>
                  t.sourceFlags.isNull() |
                  t.sourceFlags
                      .bitwiseAnd(Variable(SongSourceFlags.external))
                      .equals(0),
            ))
            .get();
    await (delete(songs)..where(
          (t) =>
              t.sourceFlags.isNull() |
              t.sourceFlags
                  .bitwiseAnd(Variable(SongSourceFlags.external))
                  .equals(0),
        ))
        .go();
    await _deleteThumbnailFiles(rows.map((row) => row.thumbnailPath));
  }

  Future<void> clearWaveformCache() async {
    await customStatement(
      'UPDATE songs SET waveformBlob = NULL WHERE waveformBlob IS NOT NULL',
    );
  }

  Future<void> markRootScanSeenWithToken(
    Iterable<String> paths, {
    required int scanToken,
    required int sourceMask,
  }) async {
    final normalizedPaths = paths
        .map(_normalizePath)
        .where((path) => path.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedPaths.isEmpty) {
      return;
    }

    const batchSize = 200;
    await transaction(() async {
      for (var start = 0; start < normalizedPaths.length; start += batchSize) {
        final end = start + batchSize < normalizedPaths.length
            ? start + batchSize
            : normalizedPaths.length;
        final chunk = normalizedPaths.sublist(start, end);
        await customStatement(
          '''
          UPDATE songs
          SET sourceFlags = CASE
                WHEN sourceFlags IS NULL OR sourceFlags = 0 THEN ?
                ELSE sourceFlags | ?
              END,
              lastSeenRootScanSessionId = ?,
              deletedAt = NULL
          WHERE path IN (${List.filled(chunk.length, '?').join(', ')})
          ''',
          <Object>[sourceMask, sourceMask, scanToken, ...chunk],
        );
      }
    });
  }

  Future<int> syncSongSourcePresence({
    required int sourceMask,
    required Iterable<String> presentPaths,
    Iterable<String>? scopeRoots,
  }) async {
    final normalizedPresentPaths = presentPaths
        .map(_normalizePath)
        .where((path) => path.isNotEmpty)
        .map((path) => Platform.isWindows ? path.toLowerCase() : path)
        .toSet();
    final normalizedScopeRoots = scopeRoots == null
        ? const <String>[]
        : scopeRoots
              .map(_normalizePath)
              .where((path) => path.isNotEmpty)
              .toList(growable: false);

    var changedCount = 0;
    final thumbnailPathsToDelete = <String?>[];
    await transaction(() async {
      final rows = await select(songs).get();
      for (final row in rows) {
        final normalizedPath = _normalizePath(row.path);
        if (normalizedScopeRoots.isNotEmpty &&
            !_isWithinAnyRoot(normalizedPath, normalizedScopeRoots)) {
          continue;
        }

        final normalizedLookup = Platform.isWindows
            ? normalizedPath.toLowerCase()
            : normalizedPath;
        final currentFlags = row.sourceFlags ?? 0;
        final shouldHaveSource = normalizedPresentPaths.contains(
          normalizedLookup,
        );
        final hasSource = currentFlags == 0
            ? true
            : (currentFlags & sourceMask) != 0;

        int? nextFlags;
        if (shouldHaveSource) {
          nextFlags = currentFlags | sourceMask;
        } else if (hasSource) {
          nextFlags = currentFlags & ~sourceMask;
        }

        if (nextFlags == null || nextFlags == currentFlags) {
          continue;
        }

        if (nextFlags == 0) {
          thumbnailPathsToDelete.add(row.thumbnailPath);
          await (delete(songs)..where((t) => t.path.equals(row.path))).go();
        } else {
          await (update(songs)..where((t) => t.path.equals(row.path))).write(
            SongsCompanion(sourceFlags: Value(nextFlags)),
          );
        }
        changedCount++;
      }
    });
    await _deleteThumbnailFiles(thumbnailPathsToDelete);

    return changedCount;
  }

  Future<RootScanSweepResult> sweepRootScanState({
    required int scanToken,
    required int sourceMask,
    required Iterable<String> activeRoots,
  }) async {
    final normalizedActiveRoots = activeRoots
        .map(_normalizePath)
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
    final candidateRows = await customSelect(
      '''
      SELECT path, sourceFlags, lastSeenRootScanSessionId, thumbnailPath
      FROM songs
      WHERE sourceFlags IS NULL
         OR sourceFlags = 0
         OR (sourceFlags & ?) != 0
      ''',
      variables: [Variable(sourceMask)],
      readsFrom: {songs},
    ).get();

    if (candidateRows.isEmpty) {
      return const RootScanSweepResult(
        deletedPaths: <String>[],
        softDeletedPaths: <String>[],
      );
    }

    final deletedPaths = <String>[];
    final softDeletedPaths = <String>[];
    final thumbnailPathsToDelete = <String?>[];
    final deletedAtMillis = DateTime.now().millisecondsSinceEpoch;
    await transaction(() async {
      for (final row in candidateRows) {
        final path = row.read<String>('path');
        final currentFlags = row.read<int?>('sourceFlags') ?? 0;
        final seenToken = row.read<int?>('lastSeenRootScanSessionId');
        final thumbnailPath = row.read<String?>('thumbnailPath');
        if (seenToken == scanToken) {
          continue;
        }

        if (_isWithinAnyRoot(path, normalizedActiveRoots)) {
          await customStatement(
            '''
            UPDATE songs
            SET deletedAt = $deletedAtMillis,
                thumbnailPath = NULL
            WHERE path = ?
            ''',
            <Object>[path],
          );
          softDeletedPaths.add(path);
          thumbnailPathsToDelete.add(thumbnailPath);
          continue;
        }

        final nextFlags = currentFlags == 0 ? 0 : currentFlags & ~sourceMask;
        if (nextFlags == 0) {
          thumbnailPathsToDelete.add(thumbnailPath);
          await (delete(songs)..where((t) => t.path.equals(path))).go();
        } else {
          await customStatement(
            '''
            UPDATE songs
            SET sourceFlags = ?,
                deletedAt = NULL
            WHERE path = ?
            ''',
            <Object>[nextFlags, path],
          );
        }
        deletedPaths.add(path);
      }
    });
    await _deleteThumbnailFiles(thumbnailPathsToDelete);

    return RootScanSweepResult(
      deletedPaths: deletedPaths,
      softDeletedPaths: softDeletedPaths,
    );
  }

  Future<void> bindSongToRoot(String songPath, String rootPath) async {
    final normSong = _normalizePath(songPath);
    final normRoot = _normalizePath(rootPath);
    if (normSong.isEmpty || normRoot.isEmpty) return;
    await into(songRoots).insert(
      SongRootsCompanion.insert(
        songPath: normSong,
        rootPath: normRoot,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> bindSongsToRootBatch(
    Iterable<String> songPaths,
    String rootPath,
  ) async {
    final normRoot = _normalizePath(rootPath);
    if (normRoot.isEmpty) return;
    final normalizedSongPaths = songPaths
        .map(_normalizePath)
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
    if (normalizedSongPaths.isEmpty) return;

    await batch((b) {
      b.insertAll(
        songRoots,
        normalizedSongPaths.map(
          (p) => SongRootsCompanion.insert(songPath: p, rootPath: normRoot),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> unbindRootPaths(Iterable<String> rootPaths) async {
    final normalizedRoots = rootPaths
        .map(_normalizePath)
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
    if (normalizedRoots.isEmpty) return;

    await (delete(songRoots)
          ..where((t) => t.rootPath.isIn(normalizedRoots)))
        .go();
  }

  Future<RootScanSweepResult> sweepOrphanSongs({int chunkSize = 2000}) async {
    final candidateRows = await customSelect(
      '''
      SELECT s.path, s.sourceFlags, s.thumbnailPath
      FROM songs s
      LEFT JOIN song_roots r ON s.path = r.song_path
      WHERE r.song_path IS NULL
        AND (s.sourceFlags IS NULL OR (s.sourceFlags & ?) = 0)
        AND s.deletedAt IS NULL
      ''',
      variables: [Variable(SongSourceFlags.external)],
      readsFrom: {songs, songRoots},
    ).get();

    if (candidateRows.isEmpty) {
      return const RootScanSweepResult(
        deletedPaths: <String>[],
        softDeletedPaths: <String>[],
      );
    }

    final deletedPaths = <String>[];
    final thumbnailPathsToDelete = <String?>[];

    for (var i = 0; i < candidateRows.length; i += chunkSize) {
      final end = (i + chunkSize < candidateRows.length)
          ? i + chunkSize
          : candidateRows.length;
      final chunk = candidateRows.sublist(i, end);

      await transaction(() async {
        for (final row in chunk) {
          final path = row.read<String>('path');
          final thumbnailPath = row.read<String?>('thumbnailPath');

          await (delete(songs)..where((t) => t.path.equals(path))).go();
          deletedPaths.add(path);
          if (thumbnailPath != null) {
            thumbnailPathsToDelete.add(thumbnailPath);
          }
        }
      });

      await Future<void>.delayed(Duration.zero);
    }

    _deleteThumbnailFiles(thumbnailPathsToDelete).ignore();

    return RootScanSweepResult(
      deletedPaths: deletedPaths,
      softDeletedPaths: const <String>[],
    );
  }

  Future<void> insertOrUpdateLyricsCache(LyricsCacheRecord record) async {
    final normalizedCacheKey = record.cacheKey.trim();
    if (normalizedCacheKey.isEmpty) return;

    await transaction(() async {
      await (delete(lyricsCaches)
            ..where((t) =>
                t.cacheKey.equals(normalizedCacheKey) &
                t.source.equals(record.source.dbValue) &
                t.languageCode.equals(record.languageCode)))
          .go();

      await into(lyricsCaches).insert(
        LyricsCachesCompanion(
          cacheKey: Value(normalizedCacheKey),
          source: Value(record.source.dbValue),
          languageCode: Value(record.languageCode),
          isSynced: Value(record.isSynced),
          syncedLyrics: Value(record.syncedLyrics),
          syncedLinesJson: Value(
            jsonEncode(
              record.syncedLines
                  .map((line) => line.toJson())
                  .toList(growable: false),
            ),
          ),
          timelineOffsetMillis: Value(record.timelineOffsetMillis),
          updatedAtMillis: Value(record.updatedAtMillis),
        ),
      );
    });
  }

  Future<LyricsCacheRecord?> getLyricsCache(String cacheKey) async {
    final normalizedCacheKey = cacheKey.trim();
    if (normalizedCacheKey.isEmpty) return null;

    final row =
        await (select(lyricsCaches)
              ..where((t) => t.cacheKey.equals(normalizedCacheKey))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _lyricsCacheFromRow(row);
  }

  Stream<LyricsCacheRecord?> watchLyricsCache(String cacheKey) {
    final normalizedCacheKey = cacheKey.trim();
    if (normalizedCacheKey.isEmpty) {
      return Stream.value(null);
    }

    return (select(lyricsCaches)
          ..where((t) => t.cacheKey.equals(normalizedCacheKey))
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _lyricsCacheFromRow(row));
  }

  Future<List<LyricsCacheRecord>> getLyricsCaches(String cacheKey) async {
    final normalizedCacheKey = cacheKey.trim();
    if (normalizedCacheKey.isEmpty) return const [];

    final rows = await (select(lyricsCaches)
          ..where((t) => t.cacheKey.equals(normalizedCacheKey)))
        .get();
    return rows.map(_lyricsCacheFromRow).toList(growable: false);
  }

  Stream<List<LyricsCacheRecord>> watchLyricsCaches(String cacheKey) {
    final normalizedCacheKey = cacheKey.trim();
    if (normalizedCacheKey.isEmpty) {
      return Stream.value(const []);
    }

    return (select(lyricsCaches)
          ..where((t) => t.cacheKey.equals(normalizedCacheKey)))
        .watch()
        .map((rows) => rows.map(_lyricsCacheFromRow).toList(growable: false));
  }

  Future<void> clearLyricsCache() async {
    await delete(lyricsCaches).go();
  }

  Future<void> clearLyricsCacheByKey(String cacheKey) async {
    final normalizedCacheKey = cacheKey.trim();
    if (normalizedCacheKey.isEmpty) return;

    await (delete(
      lyricsCaches,
    )..where((t) => t.cacheKey.equals(normalizedCacheKey))).go();
  }

  Future<List<LyricsCacheRecord>> getAllLyricsCaches() async {
    final rows = await select(lyricsCaches).get();
    return rows.map(_lyricsCacheFromRow).toList(growable: false);
  }

  Future<void> insertOrUpdateLyricsTranslationCache(
    LyricsTranslationCacheRecord record,
  ) async {
    final normalizedCacheKey = record.cacheKey.trim();
    if (normalizedCacheKey.isNotEmpty) {
      await (delete(lyricsTranslationCaches)..where(
            (t) =>
                t.cacheKey.equals(normalizedCacheKey) &
                t.languageCode.equals(record.languageCode),
          ))
          .go();
    }

    await into(lyricsTranslationCaches).insertOnConflictUpdate(
      LyricsTranslationCachesCompanion(
        cacheKey: Value(normalizedCacheKey),
        languageCode: Value(record.languageCode),
        translatedText: Value(record.translatedText),
        translatedLinesJson: Value(jsonEncode(record.translatedLines)),
        provider: Value(record.provider),
        updatedAtMillis: Value(record.updatedAtMillis),
      ),
    );
  }

  Future<List<LyricsTranslationCacheRecord>> getLyricsTranslationCaches(
    String cacheKey,
  ) async {
    final normalizedCacheKey = cacheKey.trim();
    if (normalizedCacheKey.isEmpty) {
      return const <LyricsTranslationCacheRecord>[];
    }

    final rows =
        await (select(lyricsTranslationCaches)
              ..where((t) => t.cacheKey.equals(normalizedCacheKey))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.updatedAtMillis,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    return rows.map(_lyricsTranslationCacheFromRow).toList(growable: false);
  }

  Stream<List<LyricsTranslationCacheRecord>> watchLyricsTranslationCaches(
    String cacheKey,
  ) {
    final normalizedCacheKey = cacheKey.trim();
    if (normalizedCacheKey.isEmpty) {
      return Stream.value(const <LyricsTranslationCacheRecord>[]);
    }

    return (select(lyricsTranslationCaches)
          ..where((t) => t.cacheKey.equals(normalizedCacheKey))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.updatedAtMillis,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch()
        .map(
          (rows) =>
              rows.map(_lyricsTranslationCacheFromRow).toList(growable: false),
        );
  }

  Future<void> clearLyricsTranslationCache() async {
    await delete(lyricsTranslationCaches).go();
  }

  Future<void> clearLyricsTranslationCacheByKey(String cacheKey) async {
    final normalizedCacheKey = cacheKey.trim();
    if (normalizedCacheKey.isEmpty) return;

    await (delete(
      lyricsTranslationCaches,
    )..where((t) => t.cacheKey.equals(normalizedCacheKey))).go();
  }

  Future<List<LyricsTranslationCacheRecord>>
  getAllLyricsTranslationCaches() async {
    final rows = await select(lyricsTranslationCaches).get();
    return rows.map(_lyricsTranslationCacheFromRow).toList(growable: false);
  }

  Future<void> insertOrUpdateAcoustIDCache(AcoustIDCacheRecord record) async {
    await into(acoustidCaches).insertOnConflictUpdate(
      AcoustidCachesCompanion(
        fingerprint: Value(record.fingerprint),
        durationSeconds: Value(record.durationSeconds),
        resultsJson: Value(record.resultsJson),
        updatedAtMillis: Value(record.updatedAtMillis),
      ),
    );
  }

  Future<AcoustIDCacheRecord?> getAcoustIDCache(String fingerprint) async {
    final row =
        await (select(acoustidCaches)
              ..where((t) => t.fingerprint.equals(fingerprint))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _acoustidCacheFromRow(row);
  }

  Future<void> insertOrUpdateReleaseCoverCache(
    ReleaseCoverCacheRecord record,
  ) async {
    await into(releaseCoverCaches).insertOnConflictUpdate(
      ReleaseCoverCachesCompanion(
        releaseId: Value(record.releaseId),
        largeUrl: Value(record.largeUrl),
        thumbnailUrl: Value(record.thumbnailUrl),
        updatedAtMillis: Value(record.updatedAtMillis),
      ),
    );
  }

  Future<ReleaseCoverCacheRecord?> getReleaseCoverCache(
    String releaseId,
  ) async {
    final row =
        await (select(releaseCoverCaches)
              ..where((t) => t.releaseId.equals(releaseId))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _releaseCoverCacheFromRow(row);
  }

  Future<void> insertOrUpdateArtworkCache(ArtworkCacheRecord record) async {
    await into(artworkCaches).insert(
      ArtworkCachesCompanion(
        md5: Value(record.md5),
        artworkPath: Value(record.artworkPath),
        thumbnailPath: Value(record.thumbnailPath),
        artworkWidth: Value(record.artworkWidth),
        artworkHeight: Value(record.artworkHeight),
        themeColorsBlob: Value(record.themeColorsBlob),
        updatedAtMillis: Value(record.updatedAtMillis),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<ArtworkCacheRecord?> getArtworkCache(String md5) async {
    final row = await (select(artworkCaches)
          ..where((t) => t.md5.equals(md5))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _artworkCacheFromRow(row);
  }

  Future<void> insertOrUpdateArtistCache(ArtistCacheRecord record) async {
    final normalizedKey = _normalizeArtistCacheKey(record.queryKey);
    final companion = ArtistCachesCompanion(
      queryKey: Value(normalizedKey),
      artistId: Value(record.artistId),
      artistName: Value(record.artistName),
      sortName: Value(record.sortName),
      disambiguation: Value(record.disambiguation),
      country: Value(record.country),
      imageFileTitle: Value(record.imageFileTitle),
      imageUrl: Value(record.imageUrl),
      thumbnailUrl: Value(record.thumbnailUrl),
      areaName: Value(record.areaName),
      beginDate: Value(record.beginDate),
      endDate: Value(record.endDate),
      tagsJson: Value(record.tagsJson),
      rawSearchJson: Value(record.rawSearchJson),
      rawDetailJson: Value(record.rawDetailJson),
      noData: Value(record.noData),
      imageFetchCompleted: Value(record.imageFetchCompleted),
      updatedAtMillis: Value(record.updatedAtMillis),
    );

    final existing = await getArtistCache(normalizedKey);
    if (existing != null) {
      await (update(
        artistCaches,
      )..where((t) => t.queryKey.equals(normalizedKey))).write(companion);
      return;
    }

    await into(artistCaches).insert(companion);
  }

  Future<void> insertOrUpdateArtistImageCache(
    ArtistImageCacheRecord record,
  ) async {
    await into(artistImageCaches).insertOnConflictUpdate(
      ArtistImageCachesCompanion(
        artistId: Value(record.artistId),
        imagePath: Value(record.imagePath),
        sourceUrl: Value(record.sourceUrl),
        width: Value(record.width),
        height: Value(record.height),
        updatedAtMillis: Value(record.updatedAtMillis),
      ),
    );
  }

  Future<ArtistCacheRecord?> getArtistCache(String queryKey) async {
    final normalized = _normalizeArtistCacheKey(queryKey);
    if (normalized.isEmpty) return null;
    final row =
        await (select(artistCaches)
              ..where((t) => t.queryKey.equals(normalized))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _artistCacheFromRow(row);
  }

  Future<ArtistImageCacheRecord?> getArtistImageCache(String artistId) async {
    final normalized = artistId.trim();
    if (normalized.isEmpty) return null;
    final row =
        await (select(artistImageCaches)
              ..where((t) => t.artistId.equals(normalized))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _artistImageCacheFromRow(row);
  }

  Future<Map<String, ArtistImageCacheRecord>> getArtistImageCachesByIds(
    Iterable<String> artistIds,
  ) async {
    final normalizedIds = artistIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedIds.isEmpty) return const {};

    final rows = await (select(
      artistImageCaches,
    )..where((t) => t.artistId.isIn(normalizedIds))).get();
    return {
      for (final row in rows) row.artistId: _artistImageCacheFromRow(row),
    };
  }

  Future<Map<String, ArtistCacheRecord>> getArtistCachesByKeys(
    Iterable<String> queryKeys,
  ) async {
    final normalizedKeys = queryKeys
        .map(_normalizeArtistCacheKey)
        .where((key) => key.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedKeys.isEmpty) return const {};

    final rows = await (select(
      artistCaches,
    )..where((t) => t.queryKey.isIn(normalizedKeys))).get();
    return {for (final row in rows) row.queryKey: _artistCacheFromRow(row)};
  }

  Future<List<ArtistCacheRecord>> getAllArtistCaches() async {
    final rows =
        await (select(artistCaches)..orderBy([
              (t) =>
                  OrderingTerm(expression: t.queryKey, mode: OrderingMode.asc),
            ]))
            .get();
    return rows.map(_artistCacheFromRow).toList(growable: false);
  }

  List<String> get songPaths => const [];

  SongMetadata _songFromQueryRow(QueryRow row) {
    return SongMetadata(
      id: row.read<int?>('id'),
      mediaId: row.read<int?>('mediaId'),
      path: row.read<String>('path'),
      title: row.read<String?>('title') ?? 'Unknown',
      album: row.read<String?>('album') ?? 'Unknown',
      artist: row.read<String?>('artist') ?? 'Unknown',
      duration: row.read<int?>('duration'),
      artworkPath: row.read<String?>('artworkPath'),
      thumbnailPath: row.read<String?>('thumbnailPath'),
      artworkWidth: row.read<int?>('artworkWidth'),
      artworkHeight: row.read<int?>('artworkHeight'),
      trackNumber: row.read<int?>('trackNumber'),
      sourceFlags: row.read<int?>('sourceFlags'),
      themeColorsBlob: row.read<Uint8List?>('themeColorsBlob'),
      waveformBlob: row.read<Uint8List?>('waveformBlob'),
      lastModifiedTime: row.read<int?>('lastModifiedTime'),
      metadataTextScanned: row.read<int?>('metadataTextScanned'),
      metadataImgScanned: row.read<int?>('metadataImgScanned'),
      createdAt: row.read<int?>('createdAt'),
      deletedAt: row.read<int?>('deletedAt'),
      genres: _decodeGenres(row.read<String?>('genres')),
      isAppModified: row.read<bool?>('isAppModified') ?? false,
    );
  }

  SongMetadata _songFromTableRow(Song row) {
    return SongMetadata(
      id: row.id,
      mediaId: row.mediaId,
      path: row.path,
      title: row.title ?? 'Unknown',
      album: row.album ?? 'Unknown',
      artist: row.artist ?? 'Unknown',
      duration: row.duration,
      artworkPath: row.artworkPath,
      thumbnailPath: row.thumbnailPath,
      artworkWidth: row.artworkWidth,
      artworkHeight: row.artworkHeight,
      trackNumber: row.trackNumber,
      sourceFlags: row.sourceFlags,
      themeColorsBlob: row.themeColorsBlob,
      waveformBlob: row.waveformBlob,
      lastModifiedTime: row.lastModifiedTime,
      metadataTextScanned: row.metadataTextScanned,
      metadataImgScanned: row.metadataImgScanned,
      createdAt: row.createdAt,
      deletedAt: row.deletedAt,
      genres: _decodeGenres(row.genres),
      isAppModified: row.isAppModified,
    );
  }

  SongsCompanion _songCompanion(
    SongMetadata song, {
    int? lastSeenRootScanSessionId,
  }) {
    return SongsCompanion(
      path: Value(song.path),
      mediaId: Value(song.mediaId),
      title: Value(song.title),
      album: Value(song.album),
      artist: Value(song.artist),
      duration: Value(song.duration),
      artworkPath: Value(song.artworkPath),
      thumbnailPath: Value(song.thumbnailPath),
      artworkWidth: Value(song.artworkWidth),
      artworkHeight: Value(song.artworkHeight),
      trackNumber: Value(song.trackNumber),
      sourceFlags: Value(song.sourceFlags),
      themeColorsBlob: Value(song.themeColorsBlob),
      waveformBlob: Value(song.waveformBlob),
      lastModifiedTime: Value(song.lastModifiedTime),
      metadataTextScanned: Value(song.metadataTextScanned),
      metadataImgScanned: Value(song.metadataImgScanned),
      createdAt: Value(song.createdAt),
      deletedAt: Value(song.deletedAt),
      genres: Value(song.genres == null ? null : jsonEncode(song.genres)),
      isAppModified: Value(song.isAppModified),
      lastSeenRootScanSessionId: lastSeenRootScanSessionId == null
          ? const Value.absent()
          : Value(lastSeenRootScanSessionId),
    );
  }

  LyricsCacheRecord _lyricsCacheFromRow(LyricsCache row) {
    return LyricsCacheRecord(
      id: row.id,
      cacheKey: row.cacheKey,
      source: LyricsCacheSource.fromDbValue(row.source),
      languageCode: row.languageCode,
      isSynced: row.isSynced,
      syncedLyrics: row.syncedLyrics,
      syncedLines: _decodeSyncedLines(row.syncedLinesJson),
      timelineOffsetMillis: row.timelineOffsetMillis,
      updatedAtMillis: row.updatedAtMillis,
    );
  }

  AcoustIDCacheRecord _acoustidCacheFromRow(AcoustidCache row) {
    return AcoustIDCacheRecord(
      id: row.id,
      fingerprint: row.fingerprint,
      durationSeconds: row.durationSeconds,
      resultsJson: row.resultsJson,
      updatedAtMillis: row.updatedAtMillis,
    );
  }

  ReleaseCoverCacheRecord _releaseCoverCacheFromRow(ReleaseCoverCache row) {
    return ReleaseCoverCacheRecord(
      id: row.id,
      releaseId: row.releaseId,
      largeUrl: row.largeUrl,
      thumbnailUrl: row.thumbnailUrl,
      updatedAtMillis: row.updatedAtMillis,
    );
  }

  ArtworkCacheRecord _artworkCacheFromRow(ArtworkCache row) {
    return ArtworkCacheRecord(
      id: row.id,
      md5: row.md5,
      artworkPath: row.artworkPath,
      thumbnailPath: row.thumbnailPath,
      artworkWidth: row.artworkWidth,
      artworkHeight: row.artworkHeight,
      themeColorsBlob: row.themeColorsBlob,
      updatedAtMillis: row.updatedAtMillis,
    );
  }

  ArtistCacheRecord _artistCacheFromRow(ArtistCache row) {
    return ArtistCacheRecord(
      id: row.id,
      queryKey: row.queryKey,
      artistId: row.artistId,
      artistName: row.artistName,
      sortName: row.sortName,
      disambiguation: row.disambiguation,
      country: row.country,
      imageFileTitle: row.imageFileTitle,
      imageUrl: row.imageUrl,
      thumbnailUrl: row.thumbnailUrl,
      areaName: row.areaName,
      beginDate: row.beginDate,
      endDate: row.endDate,
      tagsJson: row.tagsJson,
      rawSearchJson: row.rawSearchJson,
      rawDetailJson: row.rawDetailJson,
      noData: row.noData,
      imageFetchCompleted: row.imageFetchCompleted,
      updatedAtMillis: row.updatedAtMillis,
    );
  }

  ArtistImageCacheRecord _artistImageCacheFromRow(ArtistImageCache row) {
    return ArtistImageCacheRecord(
      id: row.id,
      artistId: row.artistId,
      imagePath: row.imagePath,
      sourceUrl: row.sourceUrl,
      width: row.width,
      height: row.height,
      updatedAtMillis: row.updatedAtMillis,
    );
  }

  LyricsTranslationCacheRecord _lyricsTranslationCacheFromRow(
    LyricsTranslationCache row,
  ) {
    return LyricsTranslationCacheRecord(
      id: row.id,
      cacheKey: row.cacheKey,
      languageCode: row.languageCode,
      translatedText: row.translatedText,
      translatedLines: _decodeTranslatedLines(row.translatedLinesJson),
      provider: row.provider,
      updatedAtMillis: row.updatedAtMillis,
    );
  }

  List<LyricLine> _decodeSyncedLines(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return const <LyricLine>[];
    }
    final decodedValue = jsonDecode(rawValue);
    if (decodedValue is! List) return const <LyricLine>[];
    return decodedValue
        .whereType<Map>()
        .map((item) => LyricLine.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  List<String> _decodeTranslatedLines(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return const <String>[];
    }
    final decodedValue = jsonDecode(rawValue);
    if (decodedValue is! List) return const <String>[];
    return decodedValue
        .map((item) => item?.toString() ?? '')
        .toList(growable: false);
  }

  List<String>? _decodeGenres(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) return null;
    final decoded = jsonDecode(rawValue);
    if (decoded is! List) return null;
    return decoded
        .map((item) => item?.toString() ?? '')
        .toList(growable: false);
  }

  LibraryInsightSongRecord _libraryInsightSongRecordFromRow(QueryRow row) {
    return LibraryInsightSongRecord(
      song: SongMetadata(
        id: row.read<int?>('id'),
        path: row.read<String>('path'),
        title: row.read<String?>('title') ?? 'Unknown',
        album: row.read<String?>('album') ?? 'Unknown',
        artist: row.read<String?>('artist') ?? 'Unknown',
        duration: row.read<int?>('duration'),
        artworkPath: row.read<String?>('artworkPath'),
        thumbnailPath: row.read<String?>('thumbnailPath'),
        artworkWidth: row.read<int?>('artworkWidth'),
        artworkHeight: row.read<int?>('artworkHeight'),
        trackNumber: row.read<int?>('trackNumber'),
        sourceFlags: row.read<int?>('sourceFlags'),
        themeColorsBlob: row.read<Uint8List?>('themeColorsBlob'),
        waveformBlob: row.read<Uint8List?>('waveformBlob'),
        lastModifiedTime: row.read<int?>('lastModifiedTime'),
        metadataTextScanned: row.read<int?>('metadataTextScanned'),
        metadataImgScanned: row.read<int?>('metadataImgScanned'),
        createdAt: row.read<int?>('createdAt'),
        genres: _decodeGenres(row.read<String?>('genres')),
        isAppModified: row.read<bool?>('isAppModified') ?? false,
      ),
      playCount: row.read<int>('playCount'),
      lastPlayedAt: row.read<int?>('lastPlayedAt'),
    );
  }

  Future<void> _migrateIosSandboxPaths() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final currentSandbox = p.dirname(docDir.path);

      // Ensure the sharing directory is created so it's never grayed out in the files app!
      final sharingFolderPath = p.join(docDir.path, 'Vynody Music');
      final dir = Directory(sharingFolderPath);
      if (!dir.existsSync()) {
        try {
          dir.createSync(recursive: true);
          debugPrint(
            '[PathMigration] Created Vynody Music directory at: $sharingFolderPath',
          );
        } catch (e) {
          debugPrint(
            '[PathMigration] Failed to create Vynody Music directory: $e',
          );
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final lastKnownSandbox = prefs.getString('last_known_sandbox_path');

      String? oldSandboxPrefix;
      if (lastKnownSandbox != null) {
        if (lastKnownSandbox != currentSandbox) {
          oldSandboxPrefix = lastKnownSandbox;
        }
      } else {
        // Try to detect old sandbox path from SharedPreferences root_paths
        final rootPaths = prefs.getStringList('root_paths') ?? [];
        final regExp = RegExp(r'^(.*)/Containers/Data/Application/([^/]+)');
        for (final path in rootPaths) {
          final match = regExp.firstMatch(path);
          if (match != null) {
            final oldPrefix = match.group(0);
            if (oldPrefix != null && oldPrefix != currentSandbox) {
              oldSandboxPrefix = oldPrefix;
              break;
            }
          }
        }

        // If not found in SharedPreferences, check the database songs table
        if (oldSandboxPrefix == null) {
          try {
            final row = await customSelect(
              "SELECT path FROM songs WHERE path LIKE '%/Containers/Data/Application/%' LIMIT 1",
            ).getSingleOrNull();
            if (row != null) {
              final path = row.read<String>('path');
              final match = regExp.firstMatch(path);
              if (match != null) {
                final oldPrefix = match.group(0);
                if (oldPrefix != null && oldPrefix != currentSandbox) {
                  oldSandboxPrefix = oldPrefix;
                }
              }
            }
          } catch (e) {
            debugPrint(
              '[PathMigration] Failed to check database for old sandbox prefix: $e',
            );
          }
        }
      }

      if (oldSandboxPrefix != null && oldSandboxPrefix != currentSandbox) {
        final oldPrefix = oldSandboxPrefix;
        debugPrint('[PathMigration] Sandbox UUID change detected on iOS.');
        debugPrint('[PathMigration] Old sandbox: $oldPrefix');
        debugPrint('[PathMigration] Current sandbox: $currentSandbox');

        // 1. Update songs table
        await customStatement(
          'UPDATE songs SET path = REPLACE(path, ?, ?), '
          'artworkPath = REPLACE(artworkPath, ?, ?), '
          'thumbnailPath = REPLACE(thumbnailPath, ?, ?) '
          'WHERE path LIKE ? OR artworkPath LIKE ? OR thumbnailPath LIKE ?',
          <Object>[
            oldPrefix,
            currentSandbox,
            oldPrefix,
            currentSandbox,
            oldPrefix,
            currentSandbox,
            '$oldPrefix%',
            '$oldPrefix%',
            '$oldPrefix%',
          ],
        );

        // 2. Update song_play_history table
        await customStatement(
          'UPDATE song_play_history SET songPath = REPLACE(songPath, ?, ?) '
          'WHERE songPath LIKE ?',
          <Object>[oldPrefix, currentSandbox, '$oldPrefix%'],
        );

        // 3. Update lyrics_cache table (cacheKey contains the filePath)
        await customStatement(
          'UPDATE lyrics_cache SET cacheKey = REPLACE(cacheKey, ?, ?) '
          'WHERE cacheKey LIKE ?',
          <Object>[oldPrefix, currentSandbox, '%$oldPrefix%'],
        );

        // 4. Update lyrics_translation_cache table
        await customStatement(
          'UPDATE lyrics_translation_cache SET cacheKey = REPLACE(cacheKey, ?, ?) '
          'WHERE cacheKey LIKE ?',
          <Object>[oldPrefix, currentSandbox, '%$oldPrefix%'],
        );

        // 5. Update artist_image_cache table
        await customStatement(
          'UPDATE artist_image_cache SET imagePath = REPLACE(imagePath, ?, ?) '
          'WHERE imagePath LIKE ?',
          <Object>[oldPrefix, currentSandbox, '$oldPrefix%'],
        );

        // 6. Migrate root_paths in SharedPreferences
        final rootPaths = prefs.getStringList('root_paths');
        if (rootPaths != null) {
          final updatedRootPaths = rootPaths.map((p) {
            if (p.contains(oldPrefix)) {
              return p.replaceAll(oldPrefix, currentSandbox);
            }
            return p;
          }).toList();
          await prefs.setStringList('root_paths', updatedRootPaths);
          debugPrint(
            '[PathMigration] Migrated root_paths in SharedPreferences.',
          );
        }

        // 7. Migrate playlists in SharedPreferences
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
                      if (path is String && path.contains(oldPrefix)) {
                        song['path'] = path.replaceAll(
                          oldPrefix,
                          currentSandbox,
                        );
                        changed = true;
                      }
                      final thumbnailPath = song['thumbnailPath'];
                      if (thumbnailPath is String &&
                          thumbnailPath.contains(oldPrefix)) {
                        song['thumbnailPath'] = thumbnailPath.replaceAll(
                          oldPrefix,
                          currentSandbox,
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
              debugPrint(
                '[PathMigration] Migrated playlists in SharedPreferences.',
              );
            }
          } catch (e) {
            debugPrint(
              '[PathMigration] Failed to migrate playlists in SharedPreferences: $e',
            );
          }
        }

        // 8. Migrate playback_session_v1 in SharedPreferences
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
                    if (path is String && path.contains(oldPrefix)) {
                      song['path'] = path.replaceAll(oldPrefix, currentSandbox);
                      changed = true;
                    }
                    final thumbnailPath = song['thumbnailPath'];
                    if (thumbnailPath is String &&
                        thumbnailPath.contains(oldPrefix)) {
                      song['thumbnailPath'] = thumbnailPath.replaceAll(
                        oldPrefix,
                        currentSandbox,
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
                debugPrint(
                  '[PathMigration] Migrated playback_session_v1 in SharedPreferences.',
                );
              }
            }
          } catch (e) {
            debugPrint(
              '[PathMigration] Failed to migrate playback_session_v1 in SharedPreferences: $e',
            );
          }
        }
      }

      // Always save the current sandbox path
      await prefs.setString('last_known_sandbox_path', currentSandbox);
    } catch (e, st) {
      debugPrint(
        '[PathMigration] Error running iOS sandbox path migration: $e\n$st',
      );
    }
  }
}

class Songs extends Table {
  @override
  String get tableName => 'songs';

  IntColumn get id => integer().autoIncrement().named('id')();
  IntColumn get mediaId => integer().nullable().named('mediaId')();
  TextColumn get path => text().named('path')();
  TextColumn get title => text().nullable().named('title')();
  TextColumn get album => text().nullable().named('album')();
  TextColumn get artist => text().nullable().named('artist')();
  IntColumn get duration => integer().nullable().named('duration')();
  TextColumn get artworkPath => text().nullable().named('artworkPath')();
  TextColumn get thumbnailPath => text().nullable().named('thumbnailPath')();
  IntColumn get artworkWidth => integer().nullable().named('artworkWidth')();
  IntColumn get artworkHeight => integer().nullable().named('artworkHeight')();
  IntColumn get trackNumber => integer().nullable().named('trackNumber')();
  IntColumn get sourceFlags => integer().nullable().named('sourceFlags')();
  BlobColumn get themeColorsBlob =>
      blob().nullable().named('themeColorsBlob')();
  BlobColumn get waveformBlob => blob().nullable().named('waveformBlob')();
  IntColumn get lastModifiedTime =>
      integer().nullable().named('lastModifiedTime')();
  IntColumn get metadataTextScanned =>
      integer().nullable().named('metadataTextScanned')();
  IntColumn get metadataImgScanned =>
      integer().nullable().named('metadataImgScanned')();
  IntColumn get createdAt => integer().nullable().named('createdAt')();
  IntColumn get deletedAt => integer().nullable().named('deletedAt')();
  TextColumn get genres => text().nullable().named('genres')();
  BoolColumn get isAppModified =>
      boolean().withDefault(const Constant(false)).named('isAppModified')();
  IntColumn get lastSeenRootScanSessionId =>
      integer().nullable().named('lastSeenRootScanSessionId')();

  @override
  List<String> get customConstraints => const ['UNIQUE(path)'];
}

class SongRoots extends Table {
  @override
  String get tableName => 'song_roots';

  TextColumn get songPath => text().named('song_path')();
  TextColumn get rootPath => text().named('root_path')();

  @override
  Set<Column> get primaryKey => {songPath, rootPath};
}

class SongPlayHistories extends Table {
  @override
  String get tableName => 'song_play_history';

  IntColumn get id => integer().autoIncrement().named('id')();
  TextColumn get songPath => text().named('songPath')();
  IntColumn get playedAt => integer().named('playedAt')();
  IntColumn get playedDurationMillis =>
      integer().nullable().named('playedDurationMillis')();
  IntColumn get songDurationMillis =>
      integer().nullable().named('songDurationMillis')();
  TextColumn get source => text().nullable().named('source')();
}

class LyricsCaches extends Table {
  @override
  String get tableName => 'lyrics_cache';

  IntColumn get id => integer().autoIncrement().named('id')();
  TextColumn get cacheKey => text().named('cacheKey')();
  TextColumn get source => text().named('source')();
  TextColumn get languageCode => text().withDefault(const Constant('')).named('languageCode')();
  BoolColumn get isSynced => boolean().named('isSynced')();
  TextColumn get syncedLyrics => text().nullable().named('syncedLyrics')();
  TextColumn get syncedLinesJson => text().named('syncedLinesJson')();
  IntColumn get timelineOffsetMillis =>
      integer().named('timelineOffsetMillis')();
  IntColumn get updatedAtMillis => integer().named('updatedAtMillis')();

  @override
  List<String> get customConstraints => const ['UNIQUE(cacheKey, source, languageCode)'];
}

class AcoustidCaches extends Table {
  @override
  String get tableName => 'acoustid_cache';

  IntColumn get id => integer().autoIncrement().named('id')();
  TextColumn get fingerprint => text().named('fingerprint')();
  IntColumn get durationSeconds => integer().named('durationSeconds')();
  TextColumn get resultsJson => text().named('resultsJson')();
  IntColumn get updatedAtMillis => integer().named('updatedAtMillis')();

  @override
  List<String> get customConstraints => const ['UNIQUE(fingerprint)'];
}

class ReleaseCoverCaches extends Table {
  @override
  String get tableName => 'release_cover_cache';

  IntColumn get id => integer().autoIncrement().named('id')();
  TextColumn get releaseId => text().named('releaseId')();
  TextColumn get largeUrl => text().nullable().named('largeUrl')();
  TextColumn get thumbnailUrl => text().nullable().named('thumbnailUrl')();
  IntColumn get updatedAtMillis => integer().named('updatedAtMillis')();

  @override
  List<String> get customConstraints => const ['UNIQUE(releaseId)'];
}

class ArtistCaches extends Table {
  @override
  String get tableName => 'artist_cache';

  IntColumn get id => integer().autoIncrement().named('id')();
  TextColumn get queryKey => text().named('queryKey')();
  TextColumn get artistId => text().nullable().named('artistId')();
  TextColumn get artistName => text().nullable().named('artistName')();
  TextColumn get sortName => text().nullable().named('sortName')();
  TextColumn get disambiguation => text().nullable().named('disambiguation')();
  TextColumn get country => text().nullable().named('country')();
  TextColumn get imageFileTitle => text().nullable().named('imageFileTitle')();
  TextColumn get imageUrl => text().nullable().named('imageUrl')();
  TextColumn get thumbnailUrl => text().nullable().named('thumbnailUrl')();
  TextColumn get areaName => text().nullable().named('areaName')();
  TextColumn get beginDate => text().nullable().named('beginDate')();
  TextColumn get endDate => text().nullable().named('endDate')();
  TextColumn get tagsJson => text().nullable().named('tagsJson')();
  TextColumn get rawSearchJson => text().nullable().named('rawSearchJson')();
  TextColumn get rawDetailJson => text().nullable().named('rawDetailJson')();
  BoolColumn get noData => boolean().named('noData')();
  BoolColumn get imageFetchCompleted =>
      boolean().named('imageFetchCompleted')();
  IntColumn get updatedAtMillis => integer().named('updatedAtMillis')();

  @override
  List<String> get customConstraints => const ['UNIQUE(queryKey)'];
}

class ArtistImageCaches extends Table {
  @override
  String get tableName => 'artist_image_cache';

  IntColumn get id => integer().autoIncrement().named('id')();
  TextColumn get artistId => text().named('artistId')();
  TextColumn get imagePath => text().named('imagePath')();
  TextColumn get sourceUrl => text().nullable().named('sourceUrl')();
  IntColumn get width => integer().nullable().named('width')();
  IntColumn get height => integer().nullable().named('height')();
  IntColumn get updatedAtMillis => integer().named('updatedAtMillis')();

  @override
  List<String> get customConstraints => const ['UNIQUE(artistId)'];
}

class LyricsTranslationCaches extends Table {
  @override
  String get tableName => 'lyrics_translation_cache';

  IntColumn get id => integer().autoIncrement().named('id')();
  TextColumn get cacheKey => text().named('cacheKey')();
  TextColumn get languageCode => text().named('languageCode')();
  TextColumn get translatedText => text().named('translatedText')();
  TextColumn get translatedLinesJson => text().named('translatedLinesJson')();
  TextColumn get provider => text().nullable().named('provider')();
  IntColumn get updatedAtMillis => integer().named('updatedAtMillis')();

  @override
  List<String> get customConstraints => const [
    'UNIQUE(cacheKey, languageCode)',
  ];
}

class ArtworkCaches extends Table {
  @override
  String get tableName => 'artwork_cache';

  IntColumn get id => integer().autoIncrement().named('id')();
  TextColumn get md5 => text().named('md5')();
  TextColumn get artworkPath => text().nullable().named('artworkPath')();
  TextColumn get thumbnailPath => text().nullable().named('thumbnailPath')();
  IntColumn get artworkWidth => integer().nullable().named('artworkWidth')();
  IntColumn get artworkHeight => integer().nullable().named('artworkHeight')();
  BlobColumn get themeColorsBlob => blob().nullable().named('themeColorsBlob')();
  IntColumn get updatedAtMillis => integer().named('updatedAtMillis')();

  @override
  List<String> get customConstraints => const ['UNIQUE(md5)'];
}

void _setupSqliteInIsolate([Object? db]) {}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    _setupSqliteInIsolate();
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'metadata.db'));
    return NativeDatabase.createInBackground(
      file,
      isolateSetup: _setupSqliteInIsolate,
      setup: _setupSqliteInIsolate,
    );
  });
}

String _normalizeArtistCacheKey(String queryKey) {
  return queryKey.trim().toLowerCase();
}
