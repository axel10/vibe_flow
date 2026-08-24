// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_database.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
    'mediaId',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkPathMeta = const VerificationMeta(
    'artworkPath',
  );
  @override
  late final GeneratedColumn<String> artworkPath = GeneratedColumn<String>(
    'artworkPath',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnailPath',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkWidthMeta = const VerificationMeta(
    'artworkWidth',
  );
  @override
  late final GeneratedColumn<int> artworkWidth = GeneratedColumn<int>(
    'artworkWidth',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkHeightMeta = const VerificationMeta(
    'artworkHeight',
  );
  @override
  late final GeneratedColumn<int> artworkHeight = GeneratedColumn<int>(
    'artworkHeight',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'trackNumber',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceFlagsMeta = const VerificationMeta(
    'sourceFlags',
  );
  @override
  late final GeneratedColumn<int> sourceFlags = GeneratedColumn<int>(
    'sourceFlags',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeColorsBlobMeta = const VerificationMeta(
    'themeColorsBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> themeColorsBlob =
      GeneratedColumn<Uint8List>(
        'themeColorsBlob',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _waveformBlobMeta = const VerificationMeta(
    'waveformBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> waveformBlob =
      GeneratedColumn<Uint8List>(
        'waveformBlob',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastModifiedTimeMeta = const VerificationMeta(
    'lastModifiedTime',
  );
  @override
  late final GeneratedColumn<int> lastModifiedTime = GeneratedColumn<int>(
    'lastModifiedTime',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataTextScannedMeta =
      const VerificationMeta('metadataTextScanned');
  @override
  late final GeneratedColumn<int> metadataTextScanned = GeneratedColumn<int>(
    'metadataTextScanned',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataImgScannedMeta =
      const VerificationMeta('metadataImgScanned');
  @override
  late final GeneratedColumn<int> metadataImgScanned = GeneratedColumn<int>(
    'metadataImgScanned',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'createdAt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deletedAt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAppModifiedMeta = const VerificationMeta(
    'isAppModified',
  );
  @override
  late final GeneratedColumn<bool> isAppModified = GeneratedColumn<bool>(
    'isAppModified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isAppModified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSeenRootScanSessionIdMeta =
      const VerificationMeta('lastSeenRootScanSessionId');
  @override
  late final GeneratedColumn<int> lastSeenRootScanSessionId =
      GeneratedColumn<int>(
        'lastSeenRootScanSessionId',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaId,
    path,
    title,
    album,
    artist,
    duration,
    artworkPath,
    thumbnailPath,
    artworkWidth,
    artworkHeight,
    trackNumber,
    sourceFlags,
    themeColorsBlob,
    waveformBlob,
    lastModifiedTime,
    metadataTextScanned,
    metadataImgScanned,
    createdAt,
    deletedAt,
    genres,
    isAppModified,
    lastSeenRootScanSessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Song> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mediaId')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['mediaId']!, _mediaIdMeta),
      );
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('artworkPath')) {
      context.handle(
        _artworkPathMeta,
        artworkPath.isAcceptableOrUnknown(
          data['artworkPath']!,
          _artworkPathMeta,
        ),
      );
    }
    if (data.containsKey('thumbnailPath')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnailPath']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('artworkWidth')) {
      context.handle(
        _artworkWidthMeta,
        artworkWidth.isAcceptableOrUnknown(
          data['artworkWidth']!,
          _artworkWidthMeta,
        ),
      );
    }
    if (data.containsKey('artworkHeight')) {
      context.handle(
        _artworkHeightMeta,
        artworkHeight.isAcceptableOrUnknown(
          data['artworkHeight']!,
          _artworkHeightMeta,
        ),
      );
    }
    if (data.containsKey('trackNumber')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['trackNumber']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('sourceFlags')) {
      context.handle(
        _sourceFlagsMeta,
        sourceFlags.isAcceptableOrUnknown(
          data['sourceFlags']!,
          _sourceFlagsMeta,
        ),
      );
    }
    if (data.containsKey('themeColorsBlob')) {
      context.handle(
        _themeColorsBlobMeta,
        themeColorsBlob.isAcceptableOrUnknown(
          data['themeColorsBlob']!,
          _themeColorsBlobMeta,
        ),
      );
    }
    if (data.containsKey('waveformBlob')) {
      context.handle(
        _waveformBlobMeta,
        waveformBlob.isAcceptableOrUnknown(
          data['waveformBlob']!,
          _waveformBlobMeta,
        ),
      );
    }
    if (data.containsKey('lastModifiedTime')) {
      context.handle(
        _lastModifiedTimeMeta,
        lastModifiedTime.isAcceptableOrUnknown(
          data['lastModifiedTime']!,
          _lastModifiedTimeMeta,
        ),
      );
    }
    if (data.containsKey('metadataTextScanned')) {
      context.handle(
        _metadataTextScannedMeta,
        metadataTextScanned.isAcceptableOrUnknown(
          data['metadataTextScanned']!,
          _metadataTextScannedMeta,
        ),
      );
    }
    if (data.containsKey('metadataImgScanned')) {
      context.handle(
        _metadataImgScannedMeta,
        metadataImgScanned.isAcceptableOrUnknown(
          data['metadataImgScanned']!,
          _metadataImgScannedMeta,
        ),
      );
    }
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    }
    if (data.containsKey('deletedAt')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deletedAt']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('isAppModified')) {
      context.handle(
        _isAppModifiedMeta,
        isAppModified.isAcceptableOrUnknown(
          data['isAppModified']!,
          _isAppModifiedMeta,
        ),
      );
    }
    if (data.containsKey('lastSeenRootScanSessionId')) {
      context.handle(
        _lastSeenRootScanSessionIdMeta,
        lastSeenRootScanSessionId.isAcceptableOrUnknown(
          data['lastSeenRootScanSessionId']!,
          _lastSeenRootScanSessionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mediaId'],
      ),
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      artworkPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artworkPath'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnailPath'],
      ),
      artworkWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artworkWidth'],
      ),
      artworkHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artworkHeight'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trackNumber'],
      ),
      sourceFlags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sourceFlags'],
      ),
      themeColorsBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}themeColorsBlob'],
      ),
      waveformBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}waveformBlob'],
      ),
      lastModifiedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lastModifiedTime'],
      ),
      metadataTextScanned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metadataTextScanned'],
      ),
      metadataImgScanned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metadataImgScanned'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}createdAt'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deletedAt'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      isAppModified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isAppModified'],
      )!,
      lastSeenRootScanSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lastSeenRootScanSessionId'],
      ),
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  final int id;
  final int? mediaId;
  final String path;
  final String? title;
  final String? album;
  final String? artist;
  final int? duration;
  final String? artworkPath;
  final String? thumbnailPath;
  final int? artworkWidth;
  final int? artworkHeight;
  final int? trackNumber;
  final int? sourceFlags;
  final Uint8List? themeColorsBlob;
  final Uint8List? waveformBlob;
  final int? lastModifiedTime;
  final int? metadataTextScanned;
  final int? metadataImgScanned;
  final int? createdAt;
  final int? deletedAt;
  final String? genres;
  final bool isAppModified;
  final int? lastSeenRootScanSessionId;
  const Song({
    required this.id,
    this.mediaId,
    required this.path,
    this.title,
    this.album,
    this.artist,
    this.duration,
    this.artworkPath,
    this.thumbnailPath,
    this.artworkWidth,
    this.artworkHeight,
    this.trackNumber,
    this.sourceFlags,
    this.themeColorsBlob,
    this.waveformBlob,
    this.lastModifiedTime,
    this.metadataTextScanned,
    this.metadataImgScanned,
    this.createdAt,
    this.deletedAt,
    this.genres,
    required this.isAppModified,
    this.lastSeenRootScanSessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || mediaId != null) {
      map['mediaId'] = Variable<int>(mediaId);
    }
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    if (!nullToAbsent || artworkPath != null) {
      map['artworkPath'] = Variable<String>(artworkPath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnailPath'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || artworkWidth != null) {
      map['artworkWidth'] = Variable<int>(artworkWidth);
    }
    if (!nullToAbsent || artworkHeight != null) {
      map['artworkHeight'] = Variable<int>(artworkHeight);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['trackNumber'] = Variable<int>(trackNumber);
    }
    if (!nullToAbsent || sourceFlags != null) {
      map['sourceFlags'] = Variable<int>(sourceFlags);
    }
    if (!nullToAbsent || themeColorsBlob != null) {
      map['themeColorsBlob'] = Variable<Uint8List>(themeColorsBlob);
    }
    if (!nullToAbsent || waveformBlob != null) {
      map['waveformBlob'] = Variable<Uint8List>(waveformBlob);
    }
    if (!nullToAbsent || lastModifiedTime != null) {
      map['lastModifiedTime'] = Variable<int>(lastModifiedTime);
    }
    if (!nullToAbsent || metadataTextScanned != null) {
      map['metadataTextScanned'] = Variable<int>(metadataTextScanned);
    }
    if (!nullToAbsent || metadataImgScanned != null) {
      map['metadataImgScanned'] = Variable<int>(metadataImgScanned);
    }
    if (!nullToAbsent || createdAt != null) {
      map['createdAt'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deletedAt'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    map['isAppModified'] = Variable<bool>(isAppModified);
    if (!nullToAbsent || lastSeenRootScanSessionId != null) {
      map['lastSeenRootScanSessionId'] = Variable<int>(
        lastSeenRootScanSessionId,
      );
    }
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
      path: Value(path),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      artworkPath: artworkPath == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      artworkWidth: artworkWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkWidth),
      artworkHeight: artworkHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkHeight),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      sourceFlags: sourceFlags == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFlags),
      themeColorsBlob: themeColorsBlob == null && nullToAbsent
          ? const Value.absent()
          : Value(themeColorsBlob),
      waveformBlob: waveformBlob == null && nullToAbsent
          ? const Value.absent()
          : Value(waveformBlob),
      lastModifiedTime: lastModifiedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedTime),
      metadataTextScanned: metadataTextScanned == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataTextScanned),
      metadataImgScanned: metadataImgScanned == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataImgScanned),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      genres: genres == null && nullToAbsent
          ? const Value.absent()
          : Value(genres),
      isAppModified: Value(isAppModified),
      lastSeenRootScanSessionId:
          lastSeenRootScanSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenRootScanSessionId),
    );
  }

  factory Song.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<int>(json['id']),
      mediaId: serializer.fromJson<int?>(json['mediaId']),
      path: serializer.fromJson<String>(json['path']),
      title: serializer.fromJson<String?>(json['title']),
      album: serializer.fromJson<String?>(json['album']),
      artist: serializer.fromJson<String?>(json['artist']),
      duration: serializer.fromJson<int?>(json['duration']),
      artworkPath: serializer.fromJson<String?>(json['artworkPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      artworkWidth: serializer.fromJson<int?>(json['artworkWidth']),
      artworkHeight: serializer.fromJson<int?>(json['artworkHeight']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      sourceFlags: serializer.fromJson<int?>(json['sourceFlags']),
      themeColorsBlob: serializer.fromJson<Uint8List?>(json['themeColorsBlob']),
      waveformBlob: serializer.fromJson<Uint8List?>(json['waveformBlob']),
      lastModifiedTime: serializer.fromJson<int?>(json['lastModifiedTime']),
      metadataTextScanned: serializer.fromJson<int?>(
        json['metadataTextScanned'],
      ),
      metadataImgScanned: serializer.fromJson<int?>(json['metadataImgScanned']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      genres: serializer.fromJson<String?>(json['genres']),
      isAppModified: serializer.fromJson<bool>(json['isAppModified']),
      lastSeenRootScanSessionId: serializer.fromJson<int?>(
        json['lastSeenRootScanSessionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mediaId': serializer.toJson<int?>(mediaId),
      'path': serializer.toJson<String>(path),
      'title': serializer.toJson<String?>(title),
      'album': serializer.toJson<String?>(album),
      'artist': serializer.toJson<String?>(artist),
      'duration': serializer.toJson<int?>(duration),
      'artworkPath': serializer.toJson<String?>(artworkPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'artworkWidth': serializer.toJson<int?>(artworkWidth),
      'artworkHeight': serializer.toJson<int?>(artworkHeight),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'sourceFlags': serializer.toJson<int?>(sourceFlags),
      'themeColorsBlob': serializer.toJson<Uint8List?>(themeColorsBlob),
      'waveformBlob': serializer.toJson<Uint8List?>(waveformBlob),
      'lastModifiedTime': serializer.toJson<int?>(lastModifiedTime),
      'metadataTextScanned': serializer.toJson<int?>(metadataTextScanned),
      'metadataImgScanned': serializer.toJson<int?>(metadataImgScanned),
      'createdAt': serializer.toJson<int?>(createdAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'genres': serializer.toJson<String?>(genres),
      'isAppModified': serializer.toJson<bool>(isAppModified),
      'lastSeenRootScanSessionId': serializer.toJson<int?>(
        lastSeenRootScanSessionId,
      ),
    };
  }

  Song copyWith({
    int? id,
    Value<int?> mediaId = const Value.absent(),
    String? path,
    Value<String?> title = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> artist = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    Value<String?> artworkPath = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    Value<int?> artworkWidth = const Value.absent(),
    Value<int?> artworkHeight = const Value.absent(),
    Value<int?> trackNumber = const Value.absent(),
    Value<int?> sourceFlags = const Value.absent(),
    Value<Uint8List?> themeColorsBlob = const Value.absent(),
    Value<Uint8List?> waveformBlob = const Value.absent(),
    Value<int?> lastModifiedTime = const Value.absent(),
    Value<int?> metadataTextScanned = const Value.absent(),
    Value<int?> metadataImgScanned = const Value.absent(),
    Value<int?> createdAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> genres = const Value.absent(),
    bool? isAppModified,
    Value<int?> lastSeenRootScanSessionId = const Value.absent(),
  }) => Song(
    id: id ?? this.id,
    mediaId: mediaId.present ? mediaId.value : this.mediaId,
    path: path ?? this.path,
    title: title.present ? title.value : this.title,
    album: album.present ? album.value : this.album,
    artist: artist.present ? artist.value : this.artist,
    duration: duration.present ? duration.value : this.duration,
    artworkPath: artworkPath.present ? artworkPath.value : this.artworkPath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    artworkWidth: artworkWidth.present ? artworkWidth.value : this.artworkWidth,
    artworkHeight: artworkHeight.present
        ? artworkHeight.value
        : this.artworkHeight,
    trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
    sourceFlags: sourceFlags.present ? sourceFlags.value : this.sourceFlags,
    themeColorsBlob: themeColorsBlob.present
        ? themeColorsBlob.value
        : this.themeColorsBlob,
    waveformBlob: waveformBlob.present ? waveformBlob.value : this.waveformBlob,
    lastModifiedTime: lastModifiedTime.present
        ? lastModifiedTime.value
        : this.lastModifiedTime,
    metadataTextScanned: metadataTextScanned.present
        ? metadataTextScanned.value
        : this.metadataTextScanned,
    metadataImgScanned: metadataImgScanned.present
        ? metadataImgScanned.value
        : this.metadataImgScanned,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    genres: genres.present ? genres.value : this.genres,
    isAppModified: isAppModified ?? this.isAppModified,
    lastSeenRootScanSessionId: lastSeenRootScanSessionId.present
        ? lastSeenRootScanSessionId.value
        : this.lastSeenRootScanSessionId,
  );
  Song copyWithCompanion(SongsCompanion data) {
    return Song(
      id: data.id.present ? data.id.value : this.id,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      path: data.path.present ? data.path.value : this.path,
      title: data.title.present ? data.title.value : this.title,
      album: data.album.present ? data.album.value : this.album,
      artist: data.artist.present ? data.artist.value : this.artist,
      duration: data.duration.present ? data.duration.value : this.duration,
      artworkPath: data.artworkPath.present
          ? data.artworkPath.value
          : this.artworkPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      artworkWidth: data.artworkWidth.present
          ? data.artworkWidth.value
          : this.artworkWidth,
      artworkHeight: data.artworkHeight.present
          ? data.artworkHeight.value
          : this.artworkHeight,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      sourceFlags: data.sourceFlags.present
          ? data.sourceFlags.value
          : this.sourceFlags,
      themeColorsBlob: data.themeColorsBlob.present
          ? data.themeColorsBlob.value
          : this.themeColorsBlob,
      waveformBlob: data.waveformBlob.present
          ? data.waveformBlob.value
          : this.waveformBlob,
      lastModifiedTime: data.lastModifiedTime.present
          ? data.lastModifiedTime.value
          : this.lastModifiedTime,
      metadataTextScanned: data.metadataTextScanned.present
          ? data.metadataTextScanned.value
          : this.metadataTextScanned,
      metadataImgScanned: data.metadataImgScanned.present
          ? data.metadataImgScanned.value
          : this.metadataImgScanned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      genres: data.genres.present ? data.genres.value : this.genres,
      isAppModified: data.isAppModified.present
          ? data.isAppModified.value
          : this.isAppModified,
      lastSeenRootScanSessionId: data.lastSeenRootScanSessionId.present
          ? data.lastSeenRootScanSessionId.value
          : this.lastSeenRootScanSessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('path: $path, ')
          ..write('title: $title, ')
          ..write('album: $album, ')
          ..write('artist: $artist, ')
          ..write('duration: $duration, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('artworkWidth: $artworkWidth, ')
          ..write('artworkHeight: $artworkHeight, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('sourceFlags: $sourceFlags, ')
          ..write('themeColorsBlob: $themeColorsBlob, ')
          ..write('waveformBlob: $waveformBlob, ')
          ..write('lastModifiedTime: $lastModifiedTime, ')
          ..write('metadataTextScanned: $metadataTextScanned, ')
          ..write('metadataImgScanned: $metadataImgScanned, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('genres: $genres, ')
          ..write('isAppModified: $isAppModified, ')
          ..write('lastSeenRootScanSessionId: $lastSeenRootScanSessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    mediaId,
    path,
    title,
    album,
    artist,
    duration,
    artworkPath,
    thumbnailPath,
    artworkWidth,
    artworkHeight,
    trackNumber,
    sourceFlags,
    $driftBlobEquality.hash(themeColorsBlob),
    $driftBlobEquality.hash(waveformBlob),
    lastModifiedTime,
    metadataTextScanned,
    metadataImgScanned,
    createdAt,
    deletedAt,
    genres,
    isAppModified,
    lastSeenRootScanSessionId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.mediaId == this.mediaId &&
          other.path == this.path &&
          other.title == this.title &&
          other.album == this.album &&
          other.artist == this.artist &&
          other.duration == this.duration &&
          other.artworkPath == this.artworkPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.artworkWidth == this.artworkWidth &&
          other.artworkHeight == this.artworkHeight &&
          other.trackNumber == this.trackNumber &&
          other.sourceFlags == this.sourceFlags &&
          $driftBlobEquality.equals(
            other.themeColorsBlob,
            this.themeColorsBlob,
          ) &&
          $driftBlobEquality.equals(other.waveformBlob, this.waveformBlob) &&
          other.lastModifiedTime == this.lastModifiedTime &&
          other.metadataTextScanned == this.metadataTextScanned &&
          other.metadataImgScanned == this.metadataImgScanned &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt &&
          other.genres == this.genres &&
          other.isAppModified == this.isAppModified &&
          other.lastSeenRootScanSessionId == this.lastSeenRootScanSessionId);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<int> id;
  final Value<int?> mediaId;
  final Value<String> path;
  final Value<String?> title;
  final Value<String?> album;
  final Value<String?> artist;
  final Value<int?> duration;
  final Value<String?> artworkPath;
  final Value<String?> thumbnailPath;
  final Value<int?> artworkWidth;
  final Value<int?> artworkHeight;
  final Value<int?> trackNumber;
  final Value<int?> sourceFlags;
  final Value<Uint8List?> themeColorsBlob;
  final Value<Uint8List?> waveformBlob;
  final Value<int?> lastModifiedTime;
  final Value<int?> metadataTextScanned;
  final Value<int?> metadataImgScanned;
  final Value<int?> createdAt;
  final Value<int?> deletedAt;
  final Value<String?> genres;
  final Value<bool> isAppModified;
  final Value<int?> lastSeenRootScanSessionId;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.path = const Value.absent(),
    this.title = const Value.absent(),
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
    this.duration = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.artworkWidth = const Value.absent(),
    this.artworkHeight = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.sourceFlags = const Value.absent(),
    this.themeColorsBlob = const Value.absent(),
    this.waveformBlob = const Value.absent(),
    this.lastModifiedTime = const Value.absent(),
    this.metadataTextScanned = const Value.absent(),
    this.metadataImgScanned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.genres = const Value.absent(),
    this.isAppModified = const Value.absent(),
    this.lastSeenRootScanSessionId = const Value.absent(),
  });
  SongsCompanion.insert({
    this.id = const Value.absent(),
    this.mediaId = const Value.absent(),
    required String path,
    this.title = const Value.absent(),
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
    this.duration = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.artworkWidth = const Value.absent(),
    this.artworkHeight = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.sourceFlags = const Value.absent(),
    this.themeColorsBlob = const Value.absent(),
    this.waveformBlob = const Value.absent(),
    this.lastModifiedTime = const Value.absent(),
    this.metadataTextScanned = const Value.absent(),
    this.metadataImgScanned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.genres = const Value.absent(),
    this.isAppModified = const Value.absent(),
    this.lastSeenRootScanSessionId = const Value.absent(),
  }) : path = Value(path);
  static Insertable<Song> custom({
    Expression<int>? id,
    Expression<int>? mediaId,
    Expression<String>? path,
    Expression<String>? title,
    Expression<String>? album,
    Expression<String>? artist,
    Expression<int>? duration,
    Expression<String>? artworkPath,
    Expression<String>? thumbnailPath,
    Expression<int>? artworkWidth,
    Expression<int>? artworkHeight,
    Expression<int>? trackNumber,
    Expression<int>? sourceFlags,
    Expression<Uint8List>? themeColorsBlob,
    Expression<Uint8List>? waveformBlob,
    Expression<int>? lastModifiedTime,
    Expression<int>? metadataTextScanned,
    Expression<int>? metadataImgScanned,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<String>? genres,
    Expression<bool>? isAppModified,
    Expression<int>? lastSeenRootScanSessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaId != null) 'mediaId': mediaId,
      if (path != null) 'path': path,
      if (title != null) 'title': title,
      if (album != null) 'album': album,
      if (artist != null) 'artist': artist,
      if (duration != null) 'duration': duration,
      if (artworkPath != null) 'artworkPath': artworkPath,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      if (artworkWidth != null) 'artworkWidth': artworkWidth,
      if (artworkHeight != null) 'artworkHeight': artworkHeight,
      if (trackNumber != null) 'trackNumber': trackNumber,
      if (sourceFlags != null) 'sourceFlags': sourceFlags,
      if (themeColorsBlob != null) 'themeColorsBlob': themeColorsBlob,
      if (waveformBlob != null) 'waveformBlob': waveformBlob,
      if (lastModifiedTime != null) 'lastModifiedTime': lastModifiedTime,
      if (metadataTextScanned != null)
        'metadataTextScanned': metadataTextScanned,
      if (metadataImgScanned != null) 'metadataImgScanned': metadataImgScanned,
      if (createdAt != null) 'createdAt': createdAt,
      if (deletedAt != null) 'deletedAt': deletedAt,
      if (genres != null) 'genres': genres,
      if (isAppModified != null) 'isAppModified': isAppModified,
      if (lastSeenRootScanSessionId != null)
        'lastSeenRootScanSessionId': lastSeenRootScanSessionId,
    });
  }

  SongsCompanion copyWith({
    Value<int>? id,
    Value<int?>? mediaId,
    Value<String>? path,
    Value<String?>? title,
    Value<String?>? album,
    Value<String?>? artist,
    Value<int?>? duration,
    Value<String?>? artworkPath,
    Value<String?>? thumbnailPath,
    Value<int?>? artworkWidth,
    Value<int?>? artworkHeight,
    Value<int?>? trackNumber,
    Value<int?>? sourceFlags,
    Value<Uint8List?>? themeColorsBlob,
    Value<Uint8List?>? waveformBlob,
    Value<int?>? lastModifiedTime,
    Value<int?>? metadataTextScanned,
    Value<int?>? metadataImgScanned,
    Value<int?>? createdAt,
    Value<int?>? deletedAt,
    Value<String?>? genres,
    Value<bool>? isAppModified,
    Value<int?>? lastSeenRootScanSessionId,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      path: path ?? this.path,
      title: title ?? this.title,
      album: album ?? this.album,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      artworkPath: artworkPath ?? this.artworkPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      artworkWidth: artworkWidth ?? this.artworkWidth,
      artworkHeight: artworkHeight ?? this.artworkHeight,
      trackNumber: trackNumber ?? this.trackNumber,
      sourceFlags: sourceFlags ?? this.sourceFlags,
      themeColorsBlob: themeColorsBlob ?? this.themeColorsBlob,
      waveformBlob: waveformBlob ?? this.waveformBlob,
      lastModifiedTime: lastModifiedTime ?? this.lastModifiedTime,
      metadataTextScanned: metadataTextScanned ?? this.metadataTextScanned,
      metadataImgScanned: metadataImgScanned ?? this.metadataImgScanned,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      genres: genres ?? this.genres,
      isAppModified: isAppModified ?? this.isAppModified,
      lastSeenRootScanSessionId:
          lastSeenRootScanSessionId ?? this.lastSeenRootScanSessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mediaId.present) {
      map['mediaId'] = Variable<int>(mediaId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (artworkPath.present) {
      map['artworkPath'] = Variable<String>(artworkPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnailPath'] = Variable<String>(thumbnailPath.value);
    }
    if (artworkWidth.present) {
      map['artworkWidth'] = Variable<int>(artworkWidth.value);
    }
    if (artworkHeight.present) {
      map['artworkHeight'] = Variable<int>(artworkHeight.value);
    }
    if (trackNumber.present) {
      map['trackNumber'] = Variable<int>(trackNumber.value);
    }
    if (sourceFlags.present) {
      map['sourceFlags'] = Variable<int>(sourceFlags.value);
    }
    if (themeColorsBlob.present) {
      map['themeColorsBlob'] = Variable<Uint8List>(themeColorsBlob.value);
    }
    if (waveformBlob.present) {
      map['waveformBlob'] = Variable<Uint8List>(waveformBlob.value);
    }
    if (lastModifiedTime.present) {
      map['lastModifiedTime'] = Variable<int>(lastModifiedTime.value);
    }
    if (metadataTextScanned.present) {
      map['metadataTextScanned'] = Variable<int>(metadataTextScanned.value);
    }
    if (metadataImgScanned.present) {
      map['metadataImgScanned'] = Variable<int>(metadataImgScanned.value);
    }
    if (createdAt.present) {
      map['createdAt'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deletedAt'] = Variable<int>(deletedAt.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (isAppModified.present) {
      map['isAppModified'] = Variable<bool>(isAppModified.value);
    }
    if (lastSeenRootScanSessionId.present) {
      map['lastSeenRootScanSessionId'] = Variable<int>(
        lastSeenRootScanSessionId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('path: $path, ')
          ..write('title: $title, ')
          ..write('album: $album, ')
          ..write('artist: $artist, ')
          ..write('duration: $duration, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('artworkWidth: $artworkWidth, ')
          ..write('artworkHeight: $artworkHeight, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('sourceFlags: $sourceFlags, ')
          ..write('themeColorsBlob: $themeColorsBlob, ')
          ..write('waveformBlob: $waveformBlob, ')
          ..write('lastModifiedTime: $lastModifiedTime, ')
          ..write('metadataTextScanned: $metadataTextScanned, ')
          ..write('metadataImgScanned: $metadataImgScanned, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('genres: $genres, ')
          ..write('isAppModified: $isAppModified, ')
          ..write('lastSeenRootScanSessionId: $lastSeenRootScanSessionId')
          ..write(')'))
        .toString();
  }
}

class $SongRootsTable extends SongRoots
    with TableInfo<$SongRootsTable, SongRoot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongRootsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songPathMeta = const VerificationMeta(
    'songPath',
  );
  @override
  late final GeneratedColumn<String> songPath = GeneratedColumn<String>(
    'song_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootPathMeta = const VerificationMeta(
    'rootPath',
  );
  @override
  late final GeneratedColumn<String> rootPath = GeneratedColumn<String>(
    'root_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [songPath, rootPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_roots';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongRoot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_path')) {
      context.handle(
        _songPathMeta,
        songPath.isAcceptableOrUnknown(data['song_path']!, _songPathMeta),
      );
    } else if (isInserting) {
      context.missing(_songPathMeta);
    }
    if (data.containsKey('root_path')) {
      context.handle(
        _rootPathMeta,
        rootPath.isAcceptableOrUnknown(data['root_path']!, _rootPathMeta),
      );
    } else if (isInserting) {
      context.missing(_rootPathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songPath, rootPath};
  @override
  SongRoot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongRoot(
      songPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_path'],
      )!,
      rootPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_path'],
      )!,
    );
  }

  @override
  $SongRootsTable createAlias(String alias) {
    return $SongRootsTable(attachedDatabase, alias);
  }
}

class SongRoot extends DataClass implements Insertable<SongRoot> {
  final String songPath;
  final String rootPath;
  const SongRoot({required this.songPath, required this.rootPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_path'] = Variable<String>(songPath);
    map['root_path'] = Variable<String>(rootPath);
    return map;
  }

  SongRootsCompanion toCompanion(bool nullToAbsent) {
    return SongRootsCompanion(
      songPath: Value(songPath),
      rootPath: Value(rootPath),
    );
  }

  factory SongRoot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongRoot(
      songPath: serializer.fromJson<String>(json['songPath']),
      rootPath: serializer.fromJson<String>(json['rootPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songPath': serializer.toJson<String>(songPath),
      'rootPath': serializer.toJson<String>(rootPath),
    };
  }

  SongRoot copyWith({String? songPath, String? rootPath}) => SongRoot(
    songPath: songPath ?? this.songPath,
    rootPath: rootPath ?? this.rootPath,
  );
  SongRoot copyWithCompanion(SongRootsCompanion data) {
    return SongRoot(
      songPath: data.songPath.present ? data.songPath.value : this.songPath,
      rootPath: data.rootPath.present ? data.rootPath.value : this.rootPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongRoot(')
          ..write('songPath: $songPath, ')
          ..write('rootPath: $rootPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songPath, rootPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongRoot &&
          other.songPath == this.songPath &&
          other.rootPath == this.rootPath);
}

class SongRootsCompanion extends UpdateCompanion<SongRoot> {
  final Value<String> songPath;
  final Value<String> rootPath;
  final Value<int> rowid;
  const SongRootsCompanion({
    this.songPath = const Value.absent(),
    this.rootPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongRootsCompanion.insert({
    required String songPath,
    required String rootPath,
    this.rowid = const Value.absent(),
  }) : songPath = Value(songPath),
       rootPath = Value(rootPath);
  static Insertable<SongRoot> custom({
    Expression<String>? songPath,
    Expression<String>? rootPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songPath != null) 'song_path': songPath,
      if (rootPath != null) 'root_path': rootPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongRootsCompanion copyWith({
    Value<String>? songPath,
    Value<String>? rootPath,
    Value<int>? rowid,
  }) {
    return SongRootsCompanion(
      songPath: songPath ?? this.songPath,
      rootPath: rootPath ?? this.rootPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songPath.present) {
      map['song_path'] = Variable<String>(songPath.value);
    }
    if (rootPath.present) {
      map['root_path'] = Variable<String>(rootPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongRootsCompanion(')
          ..write('songPath: $songPath, ')
          ..write('rootPath: $rootPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongPlayHistoriesTable extends SongPlayHistories
    with TableInfo<$SongPlayHistoriesTable, SongPlayHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongPlayHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _songPathMeta = const VerificationMeta(
    'songPath',
  );
  @override
  late final GeneratedColumn<String> songPath = GeneratedColumn<String>(
    'songPath',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<int> playedAt = GeneratedColumn<int>(
    'playedAt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedDurationMillisMeta =
      const VerificationMeta('playedDurationMillis');
  @override
  late final GeneratedColumn<int> playedDurationMillis = GeneratedColumn<int>(
    'playedDurationMillis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songDurationMillisMeta =
      const VerificationMeta('songDurationMillis');
  @override
  late final GeneratedColumn<int> songDurationMillis = GeneratedColumn<int>(
    'songDurationMillis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songPath,
    playedAt,
    playedDurationMillis,
    songDurationMillis,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_play_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongPlayHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('songPath')) {
      context.handle(
        _songPathMeta,
        songPath.isAcceptableOrUnknown(data['songPath']!, _songPathMeta),
      );
    } else if (isInserting) {
      context.missing(_songPathMeta);
    }
    if (data.containsKey('playedAt')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['playedAt']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    if (data.containsKey('playedDurationMillis')) {
      context.handle(
        _playedDurationMillisMeta,
        playedDurationMillis.isAcceptableOrUnknown(
          data['playedDurationMillis']!,
          _playedDurationMillisMeta,
        ),
      );
    }
    if (data.containsKey('songDurationMillis')) {
      context.handle(
        _songDurationMillisMeta,
        songDurationMillis.isAcceptableOrUnknown(
          data['songDurationMillis']!,
          _songDurationMillisMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongPlayHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongPlayHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      songPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}songPath'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playedAt'],
      )!,
      playedDurationMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playedDurationMillis'],
      ),
      songDurationMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}songDurationMillis'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
    );
  }

  @override
  $SongPlayHistoriesTable createAlias(String alias) {
    return $SongPlayHistoriesTable(attachedDatabase, alias);
  }
}

class SongPlayHistory extends DataClass implements Insertable<SongPlayHistory> {
  final int id;
  final String songPath;
  final int playedAt;
  final int? playedDurationMillis;
  final int? songDurationMillis;
  final String? source;
  const SongPlayHistory({
    required this.id,
    required this.songPath,
    required this.playedAt,
    this.playedDurationMillis,
    this.songDurationMillis,
    this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['songPath'] = Variable<String>(songPath);
    map['playedAt'] = Variable<int>(playedAt);
    if (!nullToAbsent || playedDurationMillis != null) {
      map['playedDurationMillis'] = Variable<int>(playedDurationMillis);
    }
    if (!nullToAbsent || songDurationMillis != null) {
      map['songDurationMillis'] = Variable<int>(songDurationMillis);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    return map;
  }

  SongPlayHistoriesCompanion toCompanion(bool nullToAbsent) {
    return SongPlayHistoriesCompanion(
      id: Value(id),
      songPath: Value(songPath),
      playedAt: Value(playedAt),
      playedDurationMillis: playedDurationMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(playedDurationMillis),
      songDurationMillis: songDurationMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(songDurationMillis),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
    );
  }

  factory SongPlayHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongPlayHistory(
      id: serializer.fromJson<int>(json['id']),
      songPath: serializer.fromJson<String>(json['songPath']),
      playedAt: serializer.fromJson<int>(json['playedAt']),
      playedDurationMillis: serializer.fromJson<int?>(
        json['playedDurationMillis'],
      ),
      songDurationMillis: serializer.fromJson<int?>(json['songDurationMillis']),
      source: serializer.fromJson<String?>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songPath': serializer.toJson<String>(songPath),
      'playedAt': serializer.toJson<int>(playedAt),
      'playedDurationMillis': serializer.toJson<int?>(playedDurationMillis),
      'songDurationMillis': serializer.toJson<int?>(songDurationMillis),
      'source': serializer.toJson<String?>(source),
    };
  }

  SongPlayHistory copyWith({
    int? id,
    String? songPath,
    int? playedAt,
    Value<int?> playedDurationMillis = const Value.absent(),
    Value<int?> songDurationMillis = const Value.absent(),
    Value<String?> source = const Value.absent(),
  }) => SongPlayHistory(
    id: id ?? this.id,
    songPath: songPath ?? this.songPath,
    playedAt: playedAt ?? this.playedAt,
    playedDurationMillis: playedDurationMillis.present
        ? playedDurationMillis.value
        : this.playedDurationMillis,
    songDurationMillis: songDurationMillis.present
        ? songDurationMillis.value
        : this.songDurationMillis,
    source: source.present ? source.value : this.source,
  );
  SongPlayHistory copyWithCompanion(SongPlayHistoriesCompanion data) {
    return SongPlayHistory(
      id: data.id.present ? data.id.value : this.id,
      songPath: data.songPath.present ? data.songPath.value : this.songPath,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      playedDurationMillis: data.playedDurationMillis.present
          ? data.playedDurationMillis.value
          : this.playedDurationMillis,
      songDurationMillis: data.songDurationMillis.present
          ? data.songDurationMillis.value
          : this.songDurationMillis,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongPlayHistory(')
          ..write('id: $id, ')
          ..write('songPath: $songPath, ')
          ..write('playedAt: $playedAt, ')
          ..write('playedDurationMillis: $playedDurationMillis, ')
          ..write('songDurationMillis: $songDurationMillis, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    songPath,
    playedAt,
    playedDurationMillis,
    songDurationMillis,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongPlayHistory &&
          other.id == this.id &&
          other.songPath == this.songPath &&
          other.playedAt == this.playedAt &&
          other.playedDurationMillis == this.playedDurationMillis &&
          other.songDurationMillis == this.songDurationMillis &&
          other.source == this.source);
}

class SongPlayHistoriesCompanion extends UpdateCompanion<SongPlayHistory> {
  final Value<int> id;
  final Value<String> songPath;
  final Value<int> playedAt;
  final Value<int?> playedDurationMillis;
  final Value<int?> songDurationMillis;
  final Value<String?> source;
  const SongPlayHistoriesCompanion({
    this.id = const Value.absent(),
    this.songPath = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.playedDurationMillis = const Value.absent(),
    this.songDurationMillis = const Value.absent(),
    this.source = const Value.absent(),
  });
  SongPlayHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required String songPath,
    required int playedAt,
    this.playedDurationMillis = const Value.absent(),
    this.songDurationMillis = const Value.absent(),
    this.source = const Value.absent(),
  }) : songPath = Value(songPath),
       playedAt = Value(playedAt);
  static Insertable<SongPlayHistory> custom({
    Expression<int>? id,
    Expression<String>? songPath,
    Expression<int>? playedAt,
    Expression<int>? playedDurationMillis,
    Expression<int>? songDurationMillis,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songPath != null) 'songPath': songPath,
      if (playedAt != null) 'playedAt': playedAt,
      if (playedDurationMillis != null)
        'playedDurationMillis': playedDurationMillis,
      if (songDurationMillis != null) 'songDurationMillis': songDurationMillis,
      if (source != null) 'source': source,
    });
  }

  SongPlayHistoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? songPath,
    Value<int>? playedAt,
    Value<int?>? playedDurationMillis,
    Value<int?>? songDurationMillis,
    Value<String?>? source,
  }) {
    return SongPlayHistoriesCompanion(
      id: id ?? this.id,
      songPath: songPath ?? this.songPath,
      playedAt: playedAt ?? this.playedAt,
      playedDurationMillis: playedDurationMillis ?? this.playedDurationMillis,
      songDurationMillis: songDurationMillis ?? this.songDurationMillis,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songPath.present) {
      map['songPath'] = Variable<String>(songPath.value);
    }
    if (playedAt.present) {
      map['playedAt'] = Variable<int>(playedAt.value);
    }
    if (playedDurationMillis.present) {
      map['playedDurationMillis'] = Variable<int>(playedDurationMillis.value);
    }
    if (songDurationMillis.present) {
      map['songDurationMillis'] = Variable<int>(songDurationMillis.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongPlayHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('songPath: $songPath, ')
          ..write('playedAt: $playedAt, ')
          ..write('playedDurationMillis: $playedDurationMillis, ')
          ..write('songDurationMillis: $songDurationMillis, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $LyricsCachesTable extends LyricsCaches
    with TableInfo<$LyricsCachesTable, LyricsCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricsCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cacheKey',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'languageCode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'isSynced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isSynced" IN (0, 1))',
    ),
  );
  static const VerificationMeta _syncedLyricsMeta = const VerificationMeta(
    'syncedLyrics',
  );
  @override
  late final GeneratedColumn<String> syncedLyrics = GeneratedColumn<String>(
    'syncedLyrics',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedLinesJsonMeta = const VerificationMeta(
    'syncedLinesJson',
  );
  @override
  late final GeneratedColumn<String> syncedLinesJson = GeneratedColumn<String>(
    'syncedLinesJson',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timelineOffsetMillisMeta =
      const VerificationMeta('timelineOffsetMillis');
  @override
  late final GeneratedColumn<int> timelineOffsetMillis = GeneratedColumn<int>(
    'timelineOffsetMillis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updatedAtMillis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cacheKey,
    source,
    languageCode,
    isSynced,
    syncedLyrics,
    syncedLinesJson,
    timelineOffsetMillis,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyrics_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LyricsCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cacheKey')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cacheKey']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('languageCode')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['languageCode']!,
          _languageCodeMeta,
        ),
      );
    }
    if (data.containsKey('isSynced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['isSynced']!, _isSyncedMeta),
      );
    } else if (isInserting) {
      context.missing(_isSyncedMeta);
    }
    if (data.containsKey('syncedLyrics')) {
      context.handle(
        _syncedLyricsMeta,
        syncedLyrics.isAcceptableOrUnknown(
          data['syncedLyrics']!,
          _syncedLyricsMeta,
        ),
      );
    }
    if (data.containsKey('syncedLinesJson')) {
      context.handle(
        _syncedLinesJsonMeta,
        syncedLinesJson.isAcceptableOrUnknown(
          data['syncedLinesJson']!,
          _syncedLinesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncedLinesJsonMeta);
    }
    if (data.containsKey('timelineOffsetMillis')) {
      context.handle(
        _timelineOffsetMillisMeta,
        timelineOffsetMillis.isAcceptableOrUnknown(
          data['timelineOffsetMillis']!,
          _timelineOffsetMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timelineOffsetMillisMeta);
    }
    if (data.containsKey('updatedAtMillis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updatedAtMillis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LyricsCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LyricsCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cacheKey'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}languageCode'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isSynced'],
      )!,
      syncedLyrics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}syncedLyrics'],
      ),
      syncedLinesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}syncedLinesJson'],
      )!,
      timelineOffsetMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timelineOffsetMillis'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updatedAtMillis'],
      )!,
    );
  }

  @override
  $LyricsCachesTable createAlias(String alias) {
    return $LyricsCachesTable(attachedDatabase, alias);
  }
}

class LyricsCache extends DataClass implements Insertable<LyricsCache> {
  final int id;
  final String cacheKey;
  final String source;
  final String languageCode;
  final bool isSynced;
  final String? syncedLyrics;
  final String syncedLinesJson;
  final int timelineOffsetMillis;
  final int updatedAtMillis;
  const LyricsCache({
    required this.id,
    required this.cacheKey,
    required this.source,
    required this.languageCode,
    required this.isSynced,
    this.syncedLyrics,
    required this.syncedLinesJson,
    required this.timelineOffsetMillis,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cacheKey'] = Variable<String>(cacheKey);
    map['source'] = Variable<String>(source);
    map['languageCode'] = Variable<String>(languageCode);
    map['isSynced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || syncedLyrics != null) {
      map['syncedLyrics'] = Variable<String>(syncedLyrics);
    }
    map['syncedLinesJson'] = Variable<String>(syncedLinesJson);
    map['timelineOffsetMillis'] = Variable<int>(timelineOffsetMillis);
    map['updatedAtMillis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  LyricsCachesCompanion toCompanion(bool nullToAbsent) {
    return LyricsCachesCompanion(
      id: Value(id),
      cacheKey: Value(cacheKey),
      source: Value(source),
      languageCode: Value(languageCode),
      isSynced: Value(isSynced),
      syncedLyrics: syncedLyrics == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedLyrics),
      syncedLinesJson: Value(syncedLinesJson),
      timelineOffsetMillis: Value(timelineOffsetMillis),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory LyricsCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LyricsCache(
      id: serializer.fromJson<int>(json['id']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      source: serializer.fromJson<String>(json['source']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncedLyrics: serializer.fromJson<String?>(json['syncedLyrics']),
      syncedLinesJson: serializer.fromJson<String>(json['syncedLinesJson']),
      timelineOffsetMillis: serializer.fromJson<int>(
        json['timelineOffsetMillis'],
      ),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'source': serializer.toJson<String>(source),
      'languageCode': serializer.toJson<String>(languageCode),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncedLyrics': serializer.toJson<String?>(syncedLyrics),
      'syncedLinesJson': serializer.toJson<String>(syncedLinesJson),
      'timelineOffsetMillis': serializer.toJson<int>(timelineOffsetMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  LyricsCache copyWith({
    int? id,
    String? cacheKey,
    String? source,
    String? languageCode,
    bool? isSynced,
    Value<String?> syncedLyrics = const Value.absent(),
    String? syncedLinesJson,
    int? timelineOffsetMillis,
    int? updatedAtMillis,
  }) => LyricsCache(
    id: id ?? this.id,
    cacheKey: cacheKey ?? this.cacheKey,
    source: source ?? this.source,
    languageCode: languageCode ?? this.languageCode,
    isSynced: isSynced ?? this.isSynced,
    syncedLyrics: syncedLyrics.present ? syncedLyrics.value : this.syncedLyrics,
    syncedLinesJson: syncedLinesJson ?? this.syncedLinesJson,
    timelineOffsetMillis: timelineOffsetMillis ?? this.timelineOffsetMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  LyricsCache copyWithCompanion(LyricsCachesCompanion data) {
    return LyricsCache(
      id: data.id.present ? data.id.value : this.id,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      source: data.source.present ? data.source.value : this.source,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncedLyrics: data.syncedLyrics.present
          ? data.syncedLyrics.value
          : this.syncedLyrics,
      syncedLinesJson: data.syncedLinesJson.present
          ? data.syncedLinesJson.value
          : this.syncedLinesJson,
      timelineOffsetMillis: data.timelineOffsetMillis.present
          ? data.timelineOffsetMillis.value
          : this.timelineOffsetMillis,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LyricsCache(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('source: $source, ')
          ..write('languageCode: $languageCode, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncedLyrics: $syncedLyrics, ')
          ..write('syncedLinesJson: $syncedLinesJson, ')
          ..write('timelineOffsetMillis: $timelineOffsetMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cacheKey,
    source,
    languageCode,
    isSynced,
    syncedLyrics,
    syncedLinesJson,
    timelineOffsetMillis,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LyricsCache &&
          other.id == this.id &&
          other.cacheKey == this.cacheKey &&
          other.source == this.source &&
          other.languageCode == this.languageCode &&
          other.isSynced == this.isSynced &&
          other.syncedLyrics == this.syncedLyrics &&
          other.syncedLinesJson == this.syncedLinesJson &&
          other.timelineOffsetMillis == this.timelineOffsetMillis &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class LyricsCachesCompanion extends UpdateCompanion<LyricsCache> {
  final Value<int> id;
  final Value<String> cacheKey;
  final Value<String> source;
  final Value<String> languageCode;
  final Value<bool> isSynced;
  final Value<String?> syncedLyrics;
  final Value<String> syncedLinesJson;
  final Value<int> timelineOffsetMillis;
  final Value<int> updatedAtMillis;
  const LyricsCachesCompanion({
    this.id = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.source = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncedLyrics = const Value.absent(),
    this.syncedLinesJson = const Value.absent(),
    this.timelineOffsetMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
  });
  LyricsCachesCompanion.insert({
    this.id = const Value.absent(),
    required String cacheKey,
    required String source,
    this.languageCode = const Value.absent(),
    required bool isSynced,
    this.syncedLyrics = const Value.absent(),
    required String syncedLinesJson,
    required int timelineOffsetMillis,
    required int updatedAtMillis,
  }) : cacheKey = Value(cacheKey),
       source = Value(source),
       isSynced = Value(isSynced),
       syncedLinesJson = Value(syncedLinesJson),
       timelineOffsetMillis = Value(timelineOffsetMillis),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<LyricsCache> custom({
    Expression<int>? id,
    Expression<String>? cacheKey,
    Expression<String>? source,
    Expression<String>? languageCode,
    Expression<bool>? isSynced,
    Expression<String>? syncedLyrics,
    Expression<String>? syncedLinesJson,
    Expression<int>? timelineOffsetMillis,
    Expression<int>? updatedAtMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cacheKey != null) 'cacheKey': cacheKey,
      if (source != null) 'source': source,
      if (languageCode != null) 'languageCode': languageCode,
      if (isSynced != null) 'isSynced': isSynced,
      if (syncedLyrics != null) 'syncedLyrics': syncedLyrics,
      if (syncedLinesJson != null) 'syncedLinesJson': syncedLinesJson,
      if (timelineOffsetMillis != null)
        'timelineOffsetMillis': timelineOffsetMillis,
      if (updatedAtMillis != null) 'updatedAtMillis': updatedAtMillis,
    });
  }

  LyricsCachesCompanion copyWith({
    Value<int>? id,
    Value<String>? cacheKey,
    Value<String>? source,
    Value<String>? languageCode,
    Value<bool>? isSynced,
    Value<String?>? syncedLyrics,
    Value<String>? syncedLinesJson,
    Value<int>? timelineOffsetMillis,
    Value<int>? updatedAtMillis,
  }) {
    return LyricsCachesCompanion(
      id: id ?? this.id,
      cacheKey: cacheKey ?? this.cacheKey,
      source: source ?? this.source,
      languageCode: languageCode ?? this.languageCode,
      isSynced: isSynced ?? this.isSynced,
      syncedLyrics: syncedLyrics ?? this.syncedLyrics,
      syncedLinesJson: syncedLinesJson ?? this.syncedLinesJson,
      timelineOffsetMillis: timelineOffsetMillis ?? this.timelineOffsetMillis,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cacheKey.present) {
      map['cacheKey'] = Variable<String>(cacheKey.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (languageCode.present) {
      map['languageCode'] = Variable<String>(languageCode.value);
    }
    if (isSynced.present) {
      map['isSynced'] = Variable<bool>(isSynced.value);
    }
    if (syncedLyrics.present) {
      map['syncedLyrics'] = Variable<String>(syncedLyrics.value);
    }
    if (syncedLinesJson.present) {
      map['syncedLinesJson'] = Variable<String>(syncedLinesJson.value);
    }
    if (timelineOffsetMillis.present) {
      map['timelineOffsetMillis'] = Variable<int>(timelineOffsetMillis.value);
    }
    if (updatedAtMillis.present) {
      map['updatedAtMillis'] = Variable<int>(updatedAtMillis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LyricsCachesCompanion(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('source: $source, ')
          ..write('languageCode: $languageCode, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncedLyrics: $syncedLyrics, ')
          ..write('syncedLinesJson: $syncedLinesJson, ')
          ..write('timelineOffsetMillis: $timelineOffsetMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }
}

class $AcoustidCachesTable extends AcoustidCaches
    with TableInfo<$AcoustidCachesTable, AcoustidCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AcoustidCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'durationSeconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultsJsonMeta = const VerificationMeta(
    'resultsJson',
  );
  @override
  late final GeneratedColumn<String> resultsJson = GeneratedColumn<String>(
    'resultsJson',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updatedAtMillis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fingerprint,
    durationSeconds,
    resultsJson,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'acoustid_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<AcoustidCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('durationSeconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['durationSeconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('resultsJson')) {
      context.handle(
        _resultsJsonMeta,
        resultsJson.isAcceptableOrUnknown(
          data['resultsJson']!,
          _resultsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resultsJsonMeta);
    }
    if (data.containsKey('updatedAtMillis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updatedAtMillis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AcoustidCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AcoustidCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}durationSeconds'],
      )!,
      resultsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resultsJson'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updatedAtMillis'],
      )!,
    );
  }

  @override
  $AcoustidCachesTable createAlias(String alias) {
    return $AcoustidCachesTable(attachedDatabase, alias);
  }
}

class AcoustidCache extends DataClass implements Insertable<AcoustidCache> {
  final int id;
  final String fingerprint;
  final int durationSeconds;
  final String resultsJson;
  final int updatedAtMillis;
  const AcoustidCache({
    required this.id,
    required this.fingerprint,
    required this.durationSeconds,
    required this.resultsJson,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['durationSeconds'] = Variable<int>(durationSeconds);
    map['resultsJson'] = Variable<String>(resultsJson);
    map['updatedAtMillis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  AcoustidCachesCompanion toCompanion(bool nullToAbsent) {
    return AcoustidCachesCompanion(
      id: Value(id),
      fingerprint: Value(fingerprint),
      durationSeconds: Value(durationSeconds),
      resultsJson: Value(resultsJson),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory AcoustidCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AcoustidCache(
      id: serializer.fromJson<int>(json['id']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      resultsJson: serializer.fromJson<String>(json['resultsJson']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'resultsJson': serializer.toJson<String>(resultsJson),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  AcoustidCache copyWith({
    int? id,
    String? fingerprint,
    int? durationSeconds,
    String? resultsJson,
    int? updatedAtMillis,
  }) => AcoustidCache(
    id: id ?? this.id,
    fingerprint: fingerprint ?? this.fingerprint,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    resultsJson: resultsJson ?? this.resultsJson,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  AcoustidCache copyWithCompanion(AcoustidCachesCompanion data) {
    return AcoustidCache(
      id: data.id.present ? data.id.value : this.id,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      resultsJson: data.resultsJson.present
          ? data.resultsJson.value
          : this.resultsJson,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AcoustidCache(')
          ..write('id: $id, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('resultsJson: $resultsJson, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fingerprint,
    durationSeconds,
    resultsJson,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AcoustidCache &&
          other.id == this.id &&
          other.fingerprint == this.fingerprint &&
          other.durationSeconds == this.durationSeconds &&
          other.resultsJson == this.resultsJson &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class AcoustidCachesCompanion extends UpdateCompanion<AcoustidCache> {
  final Value<int> id;
  final Value<String> fingerprint;
  final Value<int> durationSeconds;
  final Value<String> resultsJson;
  final Value<int> updatedAtMillis;
  const AcoustidCachesCompanion({
    this.id = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.resultsJson = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
  });
  AcoustidCachesCompanion.insert({
    this.id = const Value.absent(),
    required String fingerprint,
    required int durationSeconds,
    required String resultsJson,
    required int updatedAtMillis,
  }) : fingerprint = Value(fingerprint),
       durationSeconds = Value(durationSeconds),
       resultsJson = Value(resultsJson),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<AcoustidCache> custom({
    Expression<int>? id,
    Expression<String>? fingerprint,
    Expression<int>? durationSeconds,
    Expression<String>? resultsJson,
    Expression<int>? updatedAtMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      if (resultsJson != null) 'resultsJson': resultsJson,
      if (updatedAtMillis != null) 'updatedAtMillis': updatedAtMillis,
    });
  }

  AcoustidCachesCompanion copyWith({
    Value<int>? id,
    Value<String>? fingerprint,
    Value<int>? durationSeconds,
    Value<String>? resultsJson,
    Value<int>? updatedAtMillis,
  }) {
    return AcoustidCachesCompanion(
      id: id ?? this.id,
      fingerprint: fingerprint ?? this.fingerprint,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      resultsJson: resultsJson ?? this.resultsJson,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (durationSeconds.present) {
      map['durationSeconds'] = Variable<int>(durationSeconds.value);
    }
    if (resultsJson.present) {
      map['resultsJson'] = Variable<String>(resultsJson.value);
    }
    if (updatedAtMillis.present) {
      map['updatedAtMillis'] = Variable<int>(updatedAtMillis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AcoustidCachesCompanion(')
          ..write('id: $id, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('resultsJson: $resultsJson, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }
}

class $ReleaseCoverCachesTable extends ReleaseCoverCaches
    with TableInfo<$ReleaseCoverCachesTable, ReleaseCoverCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReleaseCoverCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _releaseIdMeta = const VerificationMeta(
    'releaseId',
  );
  @override
  late final GeneratedColumn<String> releaseId = GeneratedColumn<String>(
    'releaseId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _largeUrlMeta = const VerificationMeta(
    'largeUrl',
  );
  @override
  late final GeneratedColumn<String> largeUrl = GeneratedColumn<String>(
    'largeUrl',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnailUrl',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updatedAtMillis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    releaseId,
    largeUrl,
    thumbnailUrl,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'release_cover_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReleaseCoverCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('releaseId')) {
      context.handle(
        _releaseIdMeta,
        releaseId.isAcceptableOrUnknown(data['releaseId']!, _releaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    if (data.containsKey('largeUrl')) {
      context.handle(
        _largeUrlMeta,
        largeUrl.isAcceptableOrUnknown(data['largeUrl']!, _largeUrlMeta),
      );
    }
    if (data.containsKey('thumbnailUrl')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnailUrl']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('updatedAtMillis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updatedAtMillis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReleaseCoverCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReleaseCoverCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      releaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}releaseId'],
      )!,
      largeUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}largeUrl'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnailUrl'],
      ),
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updatedAtMillis'],
      )!,
    );
  }

  @override
  $ReleaseCoverCachesTable createAlias(String alias) {
    return $ReleaseCoverCachesTable(attachedDatabase, alias);
  }
}

class ReleaseCoverCache extends DataClass
    implements Insertable<ReleaseCoverCache> {
  final int id;
  final String releaseId;
  final String? largeUrl;
  final String? thumbnailUrl;
  final int updatedAtMillis;
  const ReleaseCoverCache({
    required this.id,
    required this.releaseId,
    this.largeUrl,
    this.thumbnailUrl,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['releaseId'] = Variable<String>(releaseId);
    if (!nullToAbsent || largeUrl != null) {
      map['largeUrl'] = Variable<String>(largeUrl);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnailUrl'] = Variable<String>(thumbnailUrl);
    }
    map['updatedAtMillis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  ReleaseCoverCachesCompanion toCompanion(bool nullToAbsent) {
    return ReleaseCoverCachesCompanion(
      id: Value(id),
      releaseId: Value(releaseId),
      largeUrl: largeUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(largeUrl),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory ReleaseCoverCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReleaseCoverCache(
      id: serializer.fromJson<int>(json['id']),
      releaseId: serializer.fromJson<String>(json['releaseId']),
      largeUrl: serializer.fromJson<String?>(json['largeUrl']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'releaseId': serializer.toJson<String>(releaseId),
      'largeUrl': serializer.toJson<String?>(largeUrl),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  ReleaseCoverCache copyWith({
    int? id,
    String? releaseId,
    Value<String?> largeUrl = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    int? updatedAtMillis,
  }) => ReleaseCoverCache(
    id: id ?? this.id,
    releaseId: releaseId ?? this.releaseId,
    largeUrl: largeUrl.present ? largeUrl.value : this.largeUrl,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  ReleaseCoverCache copyWithCompanion(ReleaseCoverCachesCompanion data) {
    return ReleaseCoverCache(
      id: data.id.present ? data.id.value : this.id,
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
      largeUrl: data.largeUrl.present ? data.largeUrl.value : this.largeUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReleaseCoverCache(')
          ..write('id: $id, ')
          ..write('releaseId: $releaseId, ')
          ..write('largeUrl: $largeUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, releaseId, largeUrl, thumbnailUrl, updatedAtMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReleaseCoverCache &&
          other.id == this.id &&
          other.releaseId == this.releaseId &&
          other.largeUrl == this.largeUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class ReleaseCoverCachesCompanion extends UpdateCompanion<ReleaseCoverCache> {
  final Value<int> id;
  final Value<String> releaseId;
  final Value<String?> largeUrl;
  final Value<String?> thumbnailUrl;
  final Value<int> updatedAtMillis;
  const ReleaseCoverCachesCompanion({
    this.id = const Value.absent(),
    this.releaseId = const Value.absent(),
    this.largeUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
  });
  ReleaseCoverCachesCompanion.insert({
    this.id = const Value.absent(),
    required String releaseId,
    this.largeUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    required int updatedAtMillis,
  }) : releaseId = Value(releaseId),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<ReleaseCoverCache> custom({
    Expression<int>? id,
    Expression<String>? releaseId,
    Expression<String>? largeUrl,
    Expression<String>? thumbnailUrl,
    Expression<int>? updatedAtMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (releaseId != null) 'releaseId': releaseId,
      if (largeUrl != null) 'largeUrl': largeUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (updatedAtMillis != null) 'updatedAtMillis': updatedAtMillis,
    });
  }

  ReleaseCoverCachesCompanion copyWith({
    Value<int>? id,
    Value<String>? releaseId,
    Value<String?>? largeUrl,
    Value<String?>? thumbnailUrl,
    Value<int>? updatedAtMillis,
  }) {
    return ReleaseCoverCachesCompanion(
      id: id ?? this.id,
      releaseId: releaseId ?? this.releaseId,
      largeUrl: largeUrl ?? this.largeUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (releaseId.present) {
      map['releaseId'] = Variable<String>(releaseId.value);
    }
    if (largeUrl.present) {
      map['largeUrl'] = Variable<String>(largeUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnailUrl'] = Variable<String>(thumbnailUrl.value);
    }
    if (updatedAtMillis.present) {
      map['updatedAtMillis'] = Variable<int>(updatedAtMillis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReleaseCoverCachesCompanion(')
          ..write('id: $id, ')
          ..write('releaseId: $releaseId, ')
          ..write('largeUrl: $largeUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }
}

class $LyricsTranslationCachesTable extends LyricsTranslationCaches
    with TableInfo<$LyricsTranslationCachesTable, LyricsTranslationCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricsTranslationCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cacheKey',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'languageCode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translatedTextMeta = const VerificationMeta(
    'translatedText',
  );
  @override
  late final GeneratedColumn<String> translatedText = GeneratedColumn<String>(
    'translatedText',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translatedLinesJsonMeta =
      const VerificationMeta('translatedLinesJson');
  @override
  late final GeneratedColumn<String> translatedLinesJson =
      GeneratedColumn<String>(
        'translatedLinesJson',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updatedAtMillis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cacheKey,
    languageCode,
    translatedText,
    translatedLinesJson,
    provider,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyrics_translation_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LyricsTranslationCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cacheKey')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cacheKey']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('languageCode')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['languageCode']!,
          _languageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('translatedText')) {
      context.handle(
        _translatedTextMeta,
        translatedText.isAcceptableOrUnknown(
          data['translatedText']!,
          _translatedTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translatedTextMeta);
    }
    if (data.containsKey('translatedLinesJson')) {
      context.handle(
        _translatedLinesJsonMeta,
        translatedLinesJson.isAcceptableOrUnknown(
          data['translatedLinesJson']!,
          _translatedLinesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translatedLinesJsonMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('updatedAtMillis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updatedAtMillis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LyricsTranslationCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LyricsTranslationCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cacheKey'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}languageCode'],
      )!,
      translatedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translatedText'],
      )!,
      translatedLinesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translatedLinesJson'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updatedAtMillis'],
      )!,
    );
  }

  @override
  $LyricsTranslationCachesTable createAlias(String alias) {
    return $LyricsTranslationCachesTable(attachedDatabase, alias);
  }
}

class LyricsTranslationCache extends DataClass
    implements Insertable<LyricsTranslationCache> {
  final int id;
  final String cacheKey;
  final String languageCode;
  final String translatedText;
  final String translatedLinesJson;
  final String? provider;
  final int updatedAtMillis;
  const LyricsTranslationCache({
    required this.id,
    required this.cacheKey,
    required this.languageCode,
    required this.translatedText,
    required this.translatedLinesJson,
    this.provider,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cacheKey'] = Variable<String>(cacheKey);
    map['languageCode'] = Variable<String>(languageCode);
    map['translatedText'] = Variable<String>(translatedText);
    map['translatedLinesJson'] = Variable<String>(translatedLinesJson);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    map['updatedAtMillis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  LyricsTranslationCachesCompanion toCompanion(bool nullToAbsent) {
    return LyricsTranslationCachesCompanion(
      id: Value(id),
      cacheKey: Value(cacheKey),
      languageCode: Value(languageCode),
      translatedText: Value(translatedText),
      translatedLinesJson: Value(translatedLinesJson),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory LyricsTranslationCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LyricsTranslationCache(
      id: serializer.fromJson<int>(json['id']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      translatedText: serializer.fromJson<String>(json['translatedText']),
      translatedLinesJson: serializer.fromJson<String>(
        json['translatedLinesJson'],
      ),
      provider: serializer.fromJson<String?>(json['provider']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'languageCode': serializer.toJson<String>(languageCode),
      'translatedText': serializer.toJson<String>(translatedText),
      'translatedLinesJson': serializer.toJson<String>(translatedLinesJson),
      'provider': serializer.toJson<String?>(provider),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  LyricsTranslationCache copyWith({
    int? id,
    String? cacheKey,
    String? languageCode,
    String? translatedText,
    String? translatedLinesJson,
    Value<String?> provider = const Value.absent(),
    int? updatedAtMillis,
  }) => LyricsTranslationCache(
    id: id ?? this.id,
    cacheKey: cacheKey ?? this.cacheKey,
    languageCode: languageCode ?? this.languageCode,
    translatedText: translatedText ?? this.translatedText,
    translatedLinesJson: translatedLinesJson ?? this.translatedLinesJson,
    provider: provider.present ? provider.value : this.provider,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  LyricsTranslationCache copyWithCompanion(
    LyricsTranslationCachesCompanion data,
  ) {
    return LyricsTranslationCache(
      id: data.id.present ? data.id.value : this.id,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      translatedText: data.translatedText.present
          ? data.translatedText.value
          : this.translatedText,
      translatedLinesJson: data.translatedLinesJson.present
          ? data.translatedLinesJson.value
          : this.translatedLinesJson,
      provider: data.provider.present ? data.provider.value : this.provider,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LyricsTranslationCache(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('languageCode: $languageCode, ')
          ..write('translatedText: $translatedText, ')
          ..write('translatedLinesJson: $translatedLinesJson, ')
          ..write('provider: $provider, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cacheKey,
    languageCode,
    translatedText,
    translatedLinesJson,
    provider,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LyricsTranslationCache &&
          other.id == this.id &&
          other.cacheKey == this.cacheKey &&
          other.languageCode == this.languageCode &&
          other.translatedText == this.translatedText &&
          other.translatedLinesJson == this.translatedLinesJson &&
          other.provider == this.provider &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class LyricsTranslationCachesCompanion
    extends UpdateCompanion<LyricsTranslationCache> {
  final Value<int> id;
  final Value<String> cacheKey;
  final Value<String> languageCode;
  final Value<String> translatedText;
  final Value<String> translatedLinesJson;
  final Value<String?> provider;
  final Value<int> updatedAtMillis;
  const LyricsTranslationCachesCompanion({
    this.id = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.translatedText = const Value.absent(),
    this.translatedLinesJson = const Value.absent(),
    this.provider = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
  });
  LyricsTranslationCachesCompanion.insert({
    this.id = const Value.absent(),
    required String cacheKey,
    required String languageCode,
    required String translatedText,
    required String translatedLinesJson,
    this.provider = const Value.absent(),
    required int updatedAtMillis,
  }) : cacheKey = Value(cacheKey),
       languageCode = Value(languageCode),
       translatedText = Value(translatedText),
       translatedLinesJson = Value(translatedLinesJson),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<LyricsTranslationCache> custom({
    Expression<int>? id,
    Expression<String>? cacheKey,
    Expression<String>? languageCode,
    Expression<String>? translatedText,
    Expression<String>? translatedLinesJson,
    Expression<String>? provider,
    Expression<int>? updatedAtMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cacheKey != null) 'cacheKey': cacheKey,
      if (languageCode != null) 'languageCode': languageCode,
      if (translatedText != null) 'translatedText': translatedText,
      if (translatedLinesJson != null)
        'translatedLinesJson': translatedLinesJson,
      if (provider != null) 'provider': provider,
      if (updatedAtMillis != null) 'updatedAtMillis': updatedAtMillis,
    });
  }

  LyricsTranslationCachesCompanion copyWith({
    Value<int>? id,
    Value<String>? cacheKey,
    Value<String>? languageCode,
    Value<String>? translatedText,
    Value<String>? translatedLinesJson,
    Value<String?>? provider,
    Value<int>? updatedAtMillis,
  }) {
    return LyricsTranslationCachesCompanion(
      id: id ?? this.id,
      cacheKey: cacheKey ?? this.cacheKey,
      languageCode: languageCode ?? this.languageCode,
      translatedText: translatedText ?? this.translatedText,
      translatedLinesJson: translatedLinesJson ?? this.translatedLinesJson,
      provider: provider ?? this.provider,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cacheKey.present) {
      map['cacheKey'] = Variable<String>(cacheKey.value);
    }
    if (languageCode.present) {
      map['languageCode'] = Variable<String>(languageCode.value);
    }
    if (translatedText.present) {
      map['translatedText'] = Variable<String>(translatedText.value);
    }
    if (translatedLinesJson.present) {
      map['translatedLinesJson'] = Variable<String>(translatedLinesJson.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (updatedAtMillis.present) {
      map['updatedAtMillis'] = Variable<int>(updatedAtMillis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LyricsTranslationCachesCompanion(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('languageCode: $languageCode, ')
          ..write('translatedText: $translatedText, ')
          ..write('translatedLinesJson: $translatedLinesJson, ')
          ..write('provider: $provider, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }
}

class $ArtistCachesTable extends ArtistCaches
    with TableInfo<$ArtistCachesTable, ArtistCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _queryKeyMeta = const VerificationMeta(
    'queryKey',
  );
  @override
  late final GeneratedColumn<String> queryKey = GeneratedColumn<String>(
    'queryKey',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artistId',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistNameMeta = const VerificationMeta(
    'artistName',
  );
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
    'artistName',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortNameMeta = const VerificationMeta(
    'sortName',
  );
  @override
  late final GeneratedColumn<String> sortName = GeneratedColumn<String>(
    'sortName',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _disambiguationMeta = const VerificationMeta(
    'disambiguation',
  );
  @override
  late final GeneratedColumn<String> disambiguation = GeneratedColumn<String>(
    'disambiguation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageFileTitleMeta = const VerificationMeta(
    'imageFileTitle',
  );
  @override
  late final GeneratedColumn<String> imageFileTitle = GeneratedColumn<String>(
    'imageFileTitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'imageUrl',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnailUrl',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaNameMeta = const VerificationMeta(
    'areaName',
  );
  @override
  late final GeneratedColumn<String> areaName = GeneratedColumn<String>(
    'areaName',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beginDateMeta = const VerificationMeta(
    'beginDate',
  );
  @override
  late final GeneratedColumn<String> beginDate = GeneratedColumn<String>(
    'beginDate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'endDate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tagsJson',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawSearchJsonMeta = const VerificationMeta(
    'rawSearchJson',
  );
  @override
  late final GeneratedColumn<String> rawSearchJson = GeneratedColumn<String>(
    'rawSearchJson',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawDetailJsonMeta = const VerificationMeta(
    'rawDetailJson',
  );
  @override
  late final GeneratedColumn<String> rawDetailJson = GeneratedColumn<String>(
    'rawDetailJson',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noDataMeta = const VerificationMeta('noData');
  @override
  late final GeneratedColumn<bool> noData = GeneratedColumn<bool>(
    'noData',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("noData" IN (0, 1))',
    ),
  );
  static const VerificationMeta _imageFetchCompletedMeta =
      const VerificationMeta('imageFetchCompleted');
  @override
  late final GeneratedColumn<bool> imageFetchCompleted = GeneratedColumn<bool>(
    'imageFetchCompleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("imageFetchCompleted" IN (0, 1))',
    ),
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updatedAtMillis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    queryKey,
    artistId,
    artistName,
    sortName,
    disambiguation,
    country,
    imageFileTitle,
    imageUrl,
    thumbnailUrl,
    areaName,
    beginDate,
    endDate,
    tagsJson,
    rawSearchJson,
    rawDetailJson,
    noData,
    imageFetchCompleted,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artist_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtistCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('queryKey')) {
      context.handle(
        _queryKeyMeta,
        queryKey.isAcceptableOrUnknown(data['queryKey']!, _queryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_queryKeyMeta);
    }
    if (data.containsKey('artistId')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artistId']!, _artistIdMeta),
      );
    }
    if (data.containsKey('artistName')) {
      context.handle(
        _artistNameMeta,
        artistName.isAcceptableOrUnknown(data['artistName']!, _artistNameMeta),
      );
    }
    if (data.containsKey('sortName')) {
      context.handle(
        _sortNameMeta,
        sortName.isAcceptableOrUnknown(data['sortName']!, _sortNameMeta),
      );
    }
    if (data.containsKey('disambiguation')) {
      context.handle(
        _disambiguationMeta,
        disambiguation.isAcceptableOrUnknown(
          data['disambiguation']!,
          _disambiguationMeta,
        ),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('imageFileTitle')) {
      context.handle(
        _imageFileTitleMeta,
        imageFileTitle.isAcceptableOrUnknown(
          data['imageFileTitle']!,
          _imageFileTitleMeta,
        ),
      );
    }
    if (data.containsKey('imageUrl')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['imageUrl']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('thumbnailUrl')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnailUrl']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('areaName')) {
      context.handle(
        _areaNameMeta,
        areaName.isAcceptableOrUnknown(data['areaName']!, _areaNameMeta),
      );
    }
    if (data.containsKey('beginDate')) {
      context.handle(
        _beginDateMeta,
        beginDate.isAcceptableOrUnknown(data['beginDate']!, _beginDateMeta),
      );
    }
    if (data.containsKey('endDate')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['endDate']!, _endDateMeta),
      );
    }
    if (data.containsKey('tagsJson')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tagsJson']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('rawSearchJson')) {
      context.handle(
        _rawSearchJsonMeta,
        rawSearchJson.isAcceptableOrUnknown(
          data['rawSearchJson']!,
          _rawSearchJsonMeta,
        ),
      );
    }
    if (data.containsKey('rawDetailJson')) {
      context.handle(
        _rawDetailJsonMeta,
        rawDetailJson.isAcceptableOrUnknown(
          data['rawDetailJson']!,
          _rawDetailJsonMeta,
        ),
      );
    }
    if (data.containsKey('noData')) {
      context.handle(
        _noDataMeta,
        noData.isAcceptableOrUnknown(data['noData']!, _noDataMeta),
      );
    } else if (isInserting) {
      context.missing(_noDataMeta);
    }
    if (data.containsKey('imageFetchCompleted')) {
      context.handle(
        _imageFetchCompletedMeta,
        imageFetchCompleted.isAcceptableOrUnknown(
          data['imageFetchCompleted']!,
          _imageFetchCompletedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_imageFetchCompletedMeta);
    }
    if (data.containsKey('updatedAtMillis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updatedAtMillis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtistCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtistCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      queryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}queryKey'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artistId'],
      ),
      artistName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artistName'],
      ),
      sortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sortName'],
      ),
      disambiguation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}disambiguation'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      imageFileTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imageFileTitle'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imageUrl'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnailUrl'],
      ),
      areaName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}areaName'],
      ),
      beginDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beginDate'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endDate'],
      ),
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tagsJson'],
      ),
      rawSearchJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rawSearchJson'],
      ),
      rawDetailJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rawDetailJson'],
      ),
      noData: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}noData'],
      )!,
      imageFetchCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}imageFetchCompleted'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updatedAtMillis'],
      )!,
    );
  }

  @override
  $ArtistCachesTable createAlias(String alias) {
    return $ArtistCachesTable(attachedDatabase, alias);
  }
}

class ArtistCache extends DataClass implements Insertable<ArtistCache> {
  final int id;
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
  const ArtistCache({
    required this.id,
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
    required this.imageFetchCompleted,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['queryKey'] = Variable<String>(queryKey);
    if (!nullToAbsent || artistId != null) {
      map['artistId'] = Variable<String>(artistId);
    }
    if (!nullToAbsent || artistName != null) {
      map['artistName'] = Variable<String>(artistName);
    }
    if (!nullToAbsent || sortName != null) {
      map['sortName'] = Variable<String>(sortName);
    }
    if (!nullToAbsent || disambiguation != null) {
      map['disambiguation'] = Variable<String>(disambiguation);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || imageFileTitle != null) {
      map['imageFileTitle'] = Variable<String>(imageFileTitle);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['imageUrl'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnailUrl'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || areaName != null) {
      map['areaName'] = Variable<String>(areaName);
    }
    if (!nullToAbsent || beginDate != null) {
      map['beginDate'] = Variable<String>(beginDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['endDate'] = Variable<String>(endDate);
    }
    if (!nullToAbsent || tagsJson != null) {
      map['tagsJson'] = Variable<String>(tagsJson);
    }
    if (!nullToAbsent || rawSearchJson != null) {
      map['rawSearchJson'] = Variable<String>(rawSearchJson);
    }
    if (!nullToAbsent || rawDetailJson != null) {
      map['rawDetailJson'] = Variable<String>(rawDetailJson);
    }
    map['noData'] = Variable<bool>(noData);
    map['imageFetchCompleted'] = Variable<bool>(imageFetchCompleted);
    map['updatedAtMillis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  ArtistCachesCompanion toCompanion(bool nullToAbsent) {
    return ArtistCachesCompanion(
      id: Value(id),
      queryKey: Value(queryKey),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      artistName: artistName == null && nullToAbsent
          ? const Value.absent()
          : Value(artistName),
      sortName: sortName == null && nullToAbsent
          ? const Value.absent()
          : Value(sortName),
      disambiguation: disambiguation == null && nullToAbsent
          ? const Value.absent()
          : Value(disambiguation),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      imageFileTitle: imageFileTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(imageFileTitle),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      areaName: areaName == null && nullToAbsent
          ? const Value.absent()
          : Value(areaName),
      beginDate: beginDate == null && nullToAbsent
          ? const Value.absent()
          : Value(beginDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      tagsJson: tagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tagsJson),
      rawSearchJson: rawSearchJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawSearchJson),
      rawDetailJson: rawDetailJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawDetailJson),
      noData: Value(noData),
      imageFetchCompleted: Value(imageFetchCompleted),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory ArtistCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtistCache(
      id: serializer.fromJson<int>(json['id']),
      queryKey: serializer.fromJson<String>(json['queryKey']),
      artistId: serializer.fromJson<String?>(json['artistId']),
      artistName: serializer.fromJson<String?>(json['artistName']),
      sortName: serializer.fromJson<String?>(json['sortName']),
      disambiguation: serializer.fromJson<String?>(json['disambiguation']),
      country: serializer.fromJson<String?>(json['country']),
      imageFileTitle: serializer.fromJson<String?>(json['imageFileTitle']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      areaName: serializer.fromJson<String?>(json['areaName']),
      beginDate: serializer.fromJson<String?>(json['beginDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      tagsJson: serializer.fromJson<String?>(json['tagsJson']),
      rawSearchJson: serializer.fromJson<String?>(json['rawSearchJson']),
      rawDetailJson: serializer.fromJson<String?>(json['rawDetailJson']),
      noData: serializer.fromJson<bool>(json['noData']),
      imageFetchCompleted: serializer.fromJson<bool>(
        json['imageFetchCompleted'],
      ),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'queryKey': serializer.toJson<String>(queryKey),
      'artistId': serializer.toJson<String?>(artistId),
      'artistName': serializer.toJson<String?>(artistName),
      'sortName': serializer.toJson<String?>(sortName),
      'disambiguation': serializer.toJson<String?>(disambiguation),
      'country': serializer.toJson<String?>(country),
      'imageFileTitle': serializer.toJson<String?>(imageFileTitle),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'areaName': serializer.toJson<String?>(areaName),
      'beginDate': serializer.toJson<String?>(beginDate),
      'endDate': serializer.toJson<String?>(endDate),
      'tagsJson': serializer.toJson<String?>(tagsJson),
      'rawSearchJson': serializer.toJson<String?>(rawSearchJson),
      'rawDetailJson': serializer.toJson<String?>(rawDetailJson),
      'noData': serializer.toJson<bool>(noData),
      'imageFetchCompleted': serializer.toJson<bool>(imageFetchCompleted),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  ArtistCache copyWith({
    int? id,
    String? queryKey,
    Value<String?> artistId = const Value.absent(),
    Value<String?> artistName = const Value.absent(),
    Value<String?> sortName = const Value.absent(),
    Value<String?> disambiguation = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> imageFileTitle = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> areaName = const Value.absent(),
    Value<String?> beginDate = const Value.absent(),
    Value<String?> endDate = const Value.absent(),
    Value<String?> tagsJson = const Value.absent(),
    Value<String?> rawSearchJson = const Value.absent(),
    Value<String?> rawDetailJson = const Value.absent(),
    bool? noData,
    bool? imageFetchCompleted,
    int? updatedAtMillis,
  }) => ArtistCache(
    id: id ?? this.id,
    queryKey: queryKey ?? this.queryKey,
    artistId: artistId.present ? artistId.value : this.artistId,
    artistName: artistName.present ? artistName.value : this.artistName,
    sortName: sortName.present ? sortName.value : this.sortName,
    disambiguation: disambiguation.present
        ? disambiguation.value
        : this.disambiguation,
    country: country.present ? country.value : this.country,
    imageFileTitle: imageFileTitle.present
        ? imageFileTitle.value
        : this.imageFileTitle,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    areaName: areaName.present ? areaName.value : this.areaName,
    beginDate: beginDate.present ? beginDate.value : this.beginDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    tagsJson: tagsJson.present ? tagsJson.value : this.tagsJson,
    rawSearchJson: rawSearchJson.present
        ? rawSearchJson.value
        : this.rawSearchJson,
    rawDetailJson: rawDetailJson.present
        ? rawDetailJson.value
        : this.rawDetailJson,
    noData: noData ?? this.noData,
    imageFetchCompleted: imageFetchCompleted ?? this.imageFetchCompleted,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  ArtistCache copyWithCompanion(ArtistCachesCompanion data) {
    return ArtistCache(
      id: data.id.present ? data.id.value : this.id,
      queryKey: data.queryKey.present ? data.queryKey.value : this.queryKey,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      artistName: data.artistName.present
          ? data.artistName.value
          : this.artistName,
      sortName: data.sortName.present ? data.sortName.value : this.sortName,
      disambiguation: data.disambiguation.present
          ? data.disambiguation.value
          : this.disambiguation,
      country: data.country.present ? data.country.value : this.country,
      imageFileTitle: data.imageFileTitle.present
          ? data.imageFileTitle.value
          : this.imageFileTitle,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      areaName: data.areaName.present ? data.areaName.value : this.areaName,
      beginDate: data.beginDate.present ? data.beginDate.value : this.beginDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      rawSearchJson: data.rawSearchJson.present
          ? data.rawSearchJson.value
          : this.rawSearchJson,
      rawDetailJson: data.rawDetailJson.present
          ? data.rawDetailJson.value
          : this.rawDetailJson,
      noData: data.noData.present ? data.noData.value : this.noData,
      imageFetchCompleted: data.imageFetchCompleted.present
          ? data.imageFetchCompleted.value
          : this.imageFetchCompleted,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtistCache(')
          ..write('id: $id, ')
          ..write('queryKey: $queryKey, ')
          ..write('artistId: $artistId, ')
          ..write('artistName: $artistName, ')
          ..write('sortName: $sortName, ')
          ..write('disambiguation: $disambiguation, ')
          ..write('country: $country, ')
          ..write('imageFileTitle: $imageFileTitle, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('areaName: $areaName, ')
          ..write('beginDate: $beginDate, ')
          ..write('endDate: $endDate, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('rawSearchJson: $rawSearchJson, ')
          ..write('rawDetailJson: $rawDetailJson, ')
          ..write('noData: $noData, ')
          ..write('imageFetchCompleted: $imageFetchCompleted, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    queryKey,
    artistId,
    artistName,
    sortName,
    disambiguation,
    country,
    imageFileTitle,
    imageUrl,
    thumbnailUrl,
    areaName,
    beginDate,
    endDate,
    tagsJson,
    rawSearchJson,
    rawDetailJson,
    noData,
    imageFetchCompleted,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtistCache &&
          other.id == this.id &&
          other.queryKey == this.queryKey &&
          other.artistId == this.artistId &&
          other.artistName == this.artistName &&
          other.sortName == this.sortName &&
          other.disambiguation == this.disambiguation &&
          other.country == this.country &&
          other.imageFileTitle == this.imageFileTitle &&
          other.imageUrl == this.imageUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.areaName == this.areaName &&
          other.beginDate == this.beginDate &&
          other.endDate == this.endDate &&
          other.tagsJson == this.tagsJson &&
          other.rawSearchJson == this.rawSearchJson &&
          other.rawDetailJson == this.rawDetailJson &&
          other.noData == this.noData &&
          other.imageFetchCompleted == this.imageFetchCompleted &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class ArtistCachesCompanion extends UpdateCompanion<ArtistCache> {
  final Value<int> id;
  final Value<String> queryKey;
  final Value<String?> artistId;
  final Value<String?> artistName;
  final Value<String?> sortName;
  final Value<String?> disambiguation;
  final Value<String?> country;
  final Value<String?> imageFileTitle;
  final Value<String?> imageUrl;
  final Value<String?> thumbnailUrl;
  final Value<String?> areaName;
  final Value<String?> beginDate;
  final Value<String?> endDate;
  final Value<String?> tagsJson;
  final Value<String?> rawSearchJson;
  final Value<String?> rawDetailJson;
  final Value<bool> noData;
  final Value<bool> imageFetchCompleted;
  final Value<int> updatedAtMillis;
  const ArtistCachesCompanion({
    this.id = const Value.absent(),
    this.queryKey = const Value.absent(),
    this.artistId = const Value.absent(),
    this.artistName = const Value.absent(),
    this.sortName = const Value.absent(),
    this.disambiguation = const Value.absent(),
    this.country = const Value.absent(),
    this.imageFileTitle = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.areaName = const Value.absent(),
    this.beginDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.rawSearchJson = const Value.absent(),
    this.rawDetailJson = const Value.absent(),
    this.noData = const Value.absent(),
    this.imageFetchCompleted = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
  });
  ArtistCachesCompanion.insert({
    this.id = const Value.absent(),
    required String queryKey,
    this.artistId = const Value.absent(),
    this.artistName = const Value.absent(),
    this.sortName = const Value.absent(),
    this.disambiguation = const Value.absent(),
    this.country = const Value.absent(),
    this.imageFileTitle = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.areaName = const Value.absent(),
    this.beginDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.rawSearchJson = const Value.absent(),
    this.rawDetailJson = const Value.absent(),
    required bool noData,
    required bool imageFetchCompleted,
    required int updatedAtMillis,
  }) : queryKey = Value(queryKey),
       noData = Value(noData),
       imageFetchCompleted = Value(imageFetchCompleted),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<ArtistCache> custom({
    Expression<int>? id,
    Expression<String>? queryKey,
    Expression<String>? artistId,
    Expression<String>? artistName,
    Expression<String>? sortName,
    Expression<String>? disambiguation,
    Expression<String>? country,
    Expression<String>? imageFileTitle,
    Expression<String>? imageUrl,
    Expression<String>? thumbnailUrl,
    Expression<String>? areaName,
    Expression<String>? beginDate,
    Expression<String>? endDate,
    Expression<String>? tagsJson,
    Expression<String>? rawSearchJson,
    Expression<String>? rawDetailJson,
    Expression<bool>? noData,
    Expression<bool>? imageFetchCompleted,
    Expression<int>? updatedAtMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (queryKey != null) 'queryKey': queryKey,
      if (artistId != null) 'artistId': artistId,
      if (artistName != null) 'artistName': artistName,
      if (sortName != null) 'sortName': sortName,
      if (disambiguation != null) 'disambiguation': disambiguation,
      if (country != null) 'country': country,
      if (imageFileTitle != null) 'imageFileTitle': imageFileTitle,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (areaName != null) 'areaName': areaName,
      if (beginDate != null) 'beginDate': beginDate,
      if (endDate != null) 'endDate': endDate,
      if (tagsJson != null) 'tagsJson': tagsJson,
      if (rawSearchJson != null) 'rawSearchJson': rawSearchJson,
      if (rawDetailJson != null) 'rawDetailJson': rawDetailJson,
      if (noData != null) 'noData': noData,
      if (imageFetchCompleted != null)
        'imageFetchCompleted': imageFetchCompleted,
      if (updatedAtMillis != null) 'updatedAtMillis': updatedAtMillis,
    });
  }

  ArtistCachesCompanion copyWith({
    Value<int>? id,
    Value<String>? queryKey,
    Value<String?>? artistId,
    Value<String?>? artistName,
    Value<String?>? sortName,
    Value<String?>? disambiguation,
    Value<String?>? country,
    Value<String?>? imageFileTitle,
    Value<String?>? imageUrl,
    Value<String?>? thumbnailUrl,
    Value<String?>? areaName,
    Value<String?>? beginDate,
    Value<String?>? endDate,
    Value<String?>? tagsJson,
    Value<String?>? rawSearchJson,
    Value<String?>? rawDetailJson,
    Value<bool>? noData,
    Value<bool>? imageFetchCompleted,
    Value<int>? updatedAtMillis,
  }) {
    return ArtistCachesCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (queryKey.present) {
      map['queryKey'] = Variable<String>(queryKey.value);
    }
    if (artistId.present) {
      map['artistId'] = Variable<String>(artistId.value);
    }
    if (artistName.present) {
      map['artistName'] = Variable<String>(artistName.value);
    }
    if (sortName.present) {
      map['sortName'] = Variable<String>(sortName.value);
    }
    if (disambiguation.present) {
      map['disambiguation'] = Variable<String>(disambiguation.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (imageFileTitle.present) {
      map['imageFileTitle'] = Variable<String>(imageFileTitle.value);
    }
    if (imageUrl.present) {
      map['imageUrl'] = Variable<String>(imageUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnailUrl'] = Variable<String>(thumbnailUrl.value);
    }
    if (areaName.present) {
      map['areaName'] = Variable<String>(areaName.value);
    }
    if (beginDate.present) {
      map['beginDate'] = Variable<String>(beginDate.value);
    }
    if (endDate.present) {
      map['endDate'] = Variable<String>(endDate.value);
    }
    if (tagsJson.present) {
      map['tagsJson'] = Variable<String>(tagsJson.value);
    }
    if (rawSearchJson.present) {
      map['rawSearchJson'] = Variable<String>(rawSearchJson.value);
    }
    if (rawDetailJson.present) {
      map['rawDetailJson'] = Variable<String>(rawDetailJson.value);
    }
    if (noData.present) {
      map['noData'] = Variable<bool>(noData.value);
    }
    if (imageFetchCompleted.present) {
      map['imageFetchCompleted'] = Variable<bool>(imageFetchCompleted.value);
    }
    if (updatedAtMillis.present) {
      map['updatedAtMillis'] = Variable<int>(updatedAtMillis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistCachesCompanion(')
          ..write('id: $id, ')
          ..write('queryKey: $queryKey, ')
          ..write('artistId: $artistId, ')
          ..write('artistName: $artistName, ')
          ..write('sortName: $sortName, ')
          ..write('disambiguation: $disambiguation, ')
          ..write('country: $country, ')
          ..write('imageFileTitle: $imageFileTitle, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('areaName: $areaName, ')
          ..write('beginDate: $beginDate, ')
          ..write('endDate: $endDate, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('rawSearchJson: $rawSearchJson, ')
          ..write('rawDetailJson: $rawDetailJson, ')
          ..write('noData: $noData, ')
          ..write('imageFetchCompleted: $imageFetchCompleted, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }
}

class $ArtistImageCachesTable extends ArtistImageCaches
    with TableInfo<$ArtistImageCachesTable, ArtistImageCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistImageCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artistId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'imagePath',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'sourceUrl',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updatedAtMillis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    artistId,
    imagePath,
    sourceUrl,
    width,
    height,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artist_image_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtistImageCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('artistId')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artistId']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('imagePath')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['imagePath']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('sourceUrl')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['sourceUrl']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('updatedAtMillis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updatedAtMillis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtistImageCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtistImageCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artistId'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imagePath'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sourceUrl'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updatedAtMillis'],
      )!,
    );
  }

  @override
  $ArtistImageCachesTable createAlias(String alias) {
    return $ArtistImageCachesTable(attachedDatabase, alias);
  }
}

class ArtistImageCache extends DataClass
    implements Insertable<ArtistImageCache> {
  final int id;
  final String artistId;
  final String imagePath;
  final String? sourceUrl;
  final int? width;
  final int? height;
  final int updatedAtMillis;
  const ArtistImageCache({
    required this.id,
    required this.artistId,
    required this.imagePath,
    this.sourceUrl,
    this.width,
    this.height,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['artistId'] = Variable<String>(artistId);
    map['imagePath'] = Variable<String>(imagePath);
    if (!nullToAbsent || sourceUrl != null) {
      map['sourceUrl'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['updatedAtMillis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  ArtistImageCachesCompanion toCompanion(bool nullToAbsent) {
    return ArtistImageCachesCompanion(
      id: Value(id),
      artistId: Value(artistId),
      imagePath: Value(imagePath),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory ArtistImageCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtistImageCache(
      id: serializer.fromJson<int>(json['id']),
      artistId: serializer.fromJson<String>(json['artistId']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'artistId': serializer.toJson<String>(artistId),
      'imagePath': serializer.toJson<String>(imagePath),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  ArtistImageCache copyWith({
    int? id,
    String? artistId,
    String? imagePath,
    Value<String?> sourceUrl = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    int? updatedAtMillis,
  }) => ArtistImageCache(
    id: id ?? this.id,
    artistId: artistId ?? this.artistId,
    imagePath: imagePath ?? this.imagePath,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  ArtistImageCache copyWithCompanion(ArtistImageCachesCompanion data) {
    return ArtistImageCache(
      id: data.id.present ? data.id.value : this.id,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtistImageCache(')
          ..write('id: $id, ')
          ..write('artistId: $artistId, ')
          ..write('imagePath: $imagePath, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    artistId,
    imagePath,
    sourceUrl,
    width,
    height,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtistImageCache &&
          other.id == this.id &&
          other.artistId == this.artistId &&
          other.imagePath == this.imagePath &&
          other.sourceUrl == this.sourceUrl &&
          other.width == this.width &&
          other.height == this.height &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class ArtistImageCachesCompanion extends UpdateCompanion<ArtistImageCache> {
  final Value<int> id;
  final Value<String> artistId;
  final Value<String> imagePath;
  final Value<String?> sourceUrl;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int> updatedAtMillis;
  const ArtistImageCachesCompanion({
    this.id = const Value.absent(),
    this.artistId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
  });
  ArtistImageCachesCompanion.insert({
    this.id = const Value.absent(),
    required String artistId,
    required String imagePath,
    this.sourceUrl = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required int updatedAtMillis,
  }) : artistId = Value(artistId),
       imagePath = Value(imagePath),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<ArtistImageCache> custom({
    Expression<int>? id,
    Expression<String>? artistId,
    Expression<String>? imagePath,
    Expression<String>? sourceUrl,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? updatedAtMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (artistId != null) 'artistId': artistId,
      if (imagePath != null) 'imagePath': imagePath,
      if (sourceUrl != null) 'sourceUrl': sourceUrl,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (updatedAtMillis != null) 'updatedAtMillis': updatedAtMillis,
    });
  }

  ArtistImageCachesCompanion copyWith({
    Value<int>? id,
    Value<String>? artistId,
    Value<String>? imagePath,
    Value<String?>? sourceUrl,
    Value<int?>? width,
    Value<int?>? height,
    Value<int>? updatedAtMillis,
  }) {
    return ArtistImageCachesCompanion(
      id: id ?? this.id,
      artistId: artistId ?? this.artistId,
      imagePath: imagePath ?? this.imagePath,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (artistId.present) {
      map['artistId'] = Variable<String>(artistId.value);
    }
    if (imagePath.present) {
      map['imagePath'] = Variable<String>(imagePath.value);
    }
    if (sourceUrl.present) {
      map['sourceUrl'] = Variable<String>(sourceUrl.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (updatedAtMillis.present) {
      map['updatedAtMillis'] = Variable<int>(updatedAtMillis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistImageCachesCompanion(')
          ..write('id: $id, ')
          ..write('artistId: $artistId, ')
          ..write('imagePath: $imagePath, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }
}

class $ArtworkCachesTable extends ArtworkCaches
    with TableInfo<$ArtworkCachesTable, ArtworkCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtworkCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _md5Meta = const VerificationMeta('md5');
  @override
  late final GeneratedColumn<String> md5 = GeneratedColumn<String>(
    'md5',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artworkPathMeta = const VerificationMeta(
    'artworkPath',
  );
  @override
  late final GeneratedColumn<String> artworkPath = GeneratedColumn<String>(
    'artworkPath',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnailPath',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkWidthMeta = const VerificationMeta(
    'artworkWidth',
  );
  @override
  late final GeneratedColumn<int> artworkWidth = GeneratedColumn<int>(
    'artworkWidth',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkHeightMeta = const VerificationMeta(
    'artworkHeight',
  );
  @override
  late final GeneratedColumn<int> artworkHeight = GeneratedColumn<int>(
    'artworkHeight',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeColorsBlobMeta = const VerificationMeta(
    'themeColorsBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> themeColorsBlob =
      GeneratedColumn<Uint8List>(
        'themeColorsBlob',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updatedAtMillis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    md5,
    artworkPath,
    thumbnailPath,
    artworkWidth,
    artworkHeight,
    themeColorsBlob,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artwork_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtworkCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('md5')) {
      context.handle(
        _md5Meta,
        md5.isAcceptableOrUnknown(data['md5']!, _md5Meta),
      );
    } else if (isInserting) {
      context.missing(_md5Meta);
    }
    if (data.containsKey('artworkPath')) {
      context.handle(
        _artworkPathMeta,
        artworkPath.isAcceptableOrUnknown(
          data['artworkPath']!,
          _artworkPathMeta,
        ),
      );
    }
    if (data.containsKey('thumbnailPath')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnailPath']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('artworkWidth')) {
      context.handle(
        _artworkWidthMeta,
        artworkWidth.isAcceptableOrUnknown(
          data['artworkWidth']!,
          _artworkWidthMeta,
        ),
      );
    }
    if (data.containsKey('artworkHeight')) {
      context.handle(
        _artworkHeightMeta,
        artworkHeight.isAcceptableOrUnknown(
          data['artworkHeight']!,
          _artworkHeightMeta,
        ),
      );
    }
    if (data.containsKey('themeColorsBlob')) {
      context.handle(
        _themeColorsBlobMeta,
        themeColorsBlob.isAcceptableOrUnknown(
          data['themeColorsBlob']!,
          _themeColorsBlobMeta,
        ),
      );
    }
    if (data.containsKey('updatedAtMillis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updatedAtMillis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtworkCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtworkCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      md5: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}md5'],
      )!,
      artworkPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artworkPath'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnailPath'],
      ),
      artworkWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artworkWidth'],
      ),
      artworkHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artworkHeight'],
      ),
      themeColorsBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}themeColorsBlob'],
      ),
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updatedAtMillis'],
      )!,
    );
  }

  @override
  $ArtworkCachesTable createAlias(String alias) {
    return $ArtworkCachesTable(attachedDatabase, alias);
  }
}

class ArtworkCache extends DataClass implements Insertable<ArtworkCache> {
  final int id;
  final String md5;
  final String? artworkPath;
  final String? thumbnailPath;
  final int? artworkWidth;
  final int? artworkHeight;
  final Uint8List? themeColorsBlob;
  final int updatedAtMillis;
  const ArtworkCache({
    required this.id,
    required this.md5,
    this.artworkPath,
    this.thumbnailPath,
    this.artworkWidth,
    this.artworkHeight,
    this.themeColorsBlob,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['md5'] = Variable<String>(md5);
    if (!nullToAbsent || artworkPath != null) {
      map['artworkPath'] = Variable<String>(artworkPath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnailPath'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || artworkWidth != null) {
      map['artworkWidth'] = Variable<int>(artworkWidth);
    }
    if (!nullToAbsent || artworkHeight != null) {
      map['artworkHeight'] = Variable<int>(artworkHeight);
    }
    if (!nullToAbsent || themeColorsBlob != null) {
      map['themeColorsBlob'] = Variable<Uint8List>(themeColorsBlob);
    }
    map['updatedAtMillis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  ArtworkCachesCompanion toCompanion(bool nullToAbsent) {
    return ArtworkCachesCompanion(
      id: Value(id),
      md5: Value(md5),
      artworkPath: artworkPath == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      artworkWidth: artworkWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkWidth),
      artworkHeight: artworkHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkHeight),
      themeColorsBlob: themeColorsBlob == null && nullToAbsent
          ? const Value.absent()
          : Value(themeColorsBlob),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory ArtworkCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtworkCache(
      id: serializer.fromJson<int>(json['id']),
      md5: serializer.fromJson<String>(json['md5']),
      artworkPath: serializer.fromJson<String?>(json['artworkPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      artworkWidth: serializer.fromJson<int?>(json['artworkWidth']),
      artworkHeight: serializer.fromJson<int?>(json['artworkHeight']),
      themeColorsBlob: serializer.fromJson<Uint8List?>(json['themeColorsBlob']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'md5': serializer.toJson<String>(md5),
      'artworkPath': serializer.toJson<String?>(artworkPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'artworkWidth': serializer.toJson<int?>(artworkWidth),
      'artworkHeight': serializer.toJson<int?>(artworkHeight),
      'themeColorsBlob': serializer.toJson<Uint8List?>(themeColorsBlob),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  ArtworkCache copyWith({
    int? id,
    String? md5,
    Value<String?> artworkPath = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    Value<int?> artworkWidth = const Value.absent(),
    Value<int?> artworkHeight = const Value.absent(),
    Value<Uint8List?> themeColorsBlob = const Value.absent(),
    int? updatedAtMillis,
  }) => ArtworkCache(
    id: id ?? this.id,
    md5: md5 ?? this.md5,
    artworkPath: artworkPath.present ? artworkPath.value : this.artworkPath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    artworkWidth: artworkWidth.present ? artworkWidth.value : this.artworkWidth,
    artworkHeight: artworkHeight.present
        ? artworkHeight.value
        : this.artworkHeight,
    themeColorsBlob: themeColorsBlob.present
        ? themeColorsBlob.value
        : this.themeColorsBlob,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  ArtworkCache copyWithCompanion(ArtworkCachesCompanion data) {
    return ArtworkCache(
      id: data.id.present ? data.id.value : this.id,
      md5: data.md5.present ? data.md5.value : this.md5,
      artworkPath: data.artworkPath.present
          ? data.artworkPath.value
          : this.artworkPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      artworkWidth: data.artworkWidth.present
          ? data.artworkWidth.value
          : this.artworkWidth,
      artworkHeight: data.artworkHeight.present
          ? data.artworkHeight.value
          : this.artworkHeight,
      themeColorsBlob: data.themeColorsBlob.present
          ? data.themeColorsBlob.value
          : this.themeColorsBlob,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtworkCache(')
          ..write('id: $id, ')
          ..write('md5: $md5, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('artworkWidth: $artworkWidth, ')
          ..write('artworkHeight: $artworkHeight, ')
          ..write('themeColorsBlob: $themeColorsBlob, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    md5,
    artworkPath,
    thumbnailPath,
    artworkWidth,
    artworkHeight,
    $driftBlobEquality.hash(themeColorsBlob),
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtworkCache &&
          other.id == this.id &&
          other.md5 == this.md5 &&
          other.artworkPath == this.artworkPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.artworkWidth == this.artworkWidth &&
          other.artworkHeight == this.artworkHeight &&
          $driftBlobEquality.equals(
            other.themeColorsBlob,
            this.themeColorsBlob,
          ) &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class ArtworkCachesCompanion extends UpdateCompanion<ArtworkCache> {
  final Value<int> id;
  final Value<String> md5;
  final Value<String?> artworkPath;
  final Value<String?> thumbnailPath;
  final Value<int?> artworkWidth;
  final Value<int?> artworkHeight;
  final Value<Uint8List?> themeColorsBlob;
  final Value<int> updatedAtMillis;
  const ArtworkCachesCompanion({
    this.id = const Value.absent(),
    this.md5 = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.artworkWidth = const Value.absent(),
    this.artworkHeight = const Value.absent(),
    this.themeColorsBlob = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
  });
  ArtworkCachesCompanion.insert({
    this.id = const Value.absent(),
    required String md5,
    this.artworkPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.artworkWidth = const Value.absent(),
    this.artworkHeight = const Value.absent(),
    this.themeColorsBlob = const Value.absent(),
    required int updatedAtMillis,
  }) : md5 = Value(md5),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<ArtworkCache> custom({
    Expression<int>? id,
    Expression<String>? md5,
    Expression<String>? artworkPath,
    Expression<String>? thumbnailPath,
    Expression<int>? artworkWidth,
    Expression<int>? artworkHeight,
    Expression<Uint8List>? themeColorsBlob,
    Expression<int>? updatedAtMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (md5 != null) 'md5': md5,
      if (artworkPath != null) 'artworkPath': artworkPath,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      if (artworkWidth != null) 'artworkWidth': artworkWidth,
      if (artworkHeight != null) 'artworkHeight': artworkHeight,
      if (themeColorsBlob != null) 'themeColorsBlob': themeColorsBlob,
      if (updatedAtMillis != null) 'updatedAtMillis': updatedAtMillis,
    });
  }

  ArtworkCachesCompanion copyWith({
    Value<int>? id,
    Value<String>? md5,
    Value<String?>? artworkPath,
    Value<String?>? thumbnailPath,
    Value<int?>? artworkWidth,
    Value<int?>? artworkHeight,
    Value<Uint8List?>? themeColorsBlob,
    Value<int>? updatedAtMillis,
  }) {
    return ArtworkCachesCompanion(
      id: id ?? this.id,
      md5: md5 ?? this.md5,
      artworkPath: artworkPath ?? this.artworkPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      artworkWidth: artworkWidth ?? this.artworkWidth,
      artworkHeight: artworkHeight ?? this.artworkHeight,
      themeColorsBlob: themeColorsBlob ?? this.themeColorsBlob,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (md5.present) {
      map['md5'] = Variable<String>(md5.value);
    }
    if (artworkPath.present) {
      map['artworkPath'] = Variable<String>(artworkPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnailPath'] = Variable<String>(thumbnailPath.value);
    }
    if (artworkWidth.present) {
      map['artworkWidth'] = Variable<int>(artworkWidth.value);
    }
    if (artworkHeight.present) {
      map['artworkHeight'] = Variable<int>(artworkHeight.value);
    }
    if (themeColorsBlob.present) {
      map['themeColorsBlob'] = Variable<Uint8List>(themeColorsBlob.value);
    }
    if (updatedAtMillis.present) {
      map['updatedAtMillis'] = Variable<int>(updatedAtMillis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtworkCachesCompanion(')
          ..write('id: $id, ')
          ..write('md5: $md5, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('artworkWidth: $artworkWidth, ')
          ..write('artworkHeight: $artworkHeight, ')
          ..write('themeColorsBlob: $themeColorsBlob, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }
}

class $RemoteSongsTable extends RemoteSongs
    with TableInfo<$RemoteSongsTable, RemoteSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'serverId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remoteId',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _virtualUriMeta = const VerificationMeta(
    'virtualUri',
  );
  @override
  late final GeneratedColumn<String> virtualUri = GeneratedColumn<String>(
    'virtualUri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkPathMeta = const VerificationMeta(
    'artworkPath',
  );
  @override
  late final GeneratedColumn<String> artworkPath = GeneratedColumn<String>(
    'artworkPath',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnailPath',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkWidthMeta = const VerificationMeta(
    'artworkWidth',
  );
  @override
  late final GeneratedColumn<int> artworkWidth = GeneratedColumn<int>(
    'artworkWidth',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkHeightMeta = const VerificationMeta(
    'artworkHeight',
  );
  @override
  late final GeneratedColumn<int> artworkHeight = GeneratedColumn<int>(
    'artworkHeight',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'trackNumber',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeColorsBlobMeta = const VerificationMeta(
    'themeColorsBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> themeColorsBlob =
      GeneratedColumn<Uint8List>(
        'themeColorsBlob',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _waveformBlobMeta = const VerificationMeta(
    'waveformBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> waveformBlob =
      GeneratedColumn<Uint8List>(
        'waveformBlob',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _coverArtIdMeta = const VerificationMeta(
    'coverArtId',
  );
  @override
  late final GeneratedColumn<String> coverArtId = GeneratedColumn<String>(
    'coverArtId',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suffixMeta = const VerificationMeta('suffix');
  @override
  late final GeneratedColumn<String> suffix = GeneratedColumn<String>(
    'suffix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bitRateMeta = const VerificationMeta(
    'bitRate',
  );
  @override
  late final GeneratedColumn<int> bitRate = GeneratedColumn<int>(
    'bitRate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedFilePathMeta = const VerificationMeta(
    'cachedFilePath',
  );
  @override
  late final GeneratedColumn<String> cachedFilePath = GeneratedColumn<String>(
    'cachedFilePath',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'createdAt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updatedAt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deletedAt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    remoteId,
    virtualUri,
    title,
    album,
    artist,
    duration,
    artworkPath,
    thumbnailPath,
    artworkWidth,
    artworkHeight,
    trackNumber,
    themeColorsBlob,
    waveformBlob,
    coverArtId,
    suffix,
    bitRate,
    cachedFilePath,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RemoteSong> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('serverId')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['serverId']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('remoteId')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remoteId']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('virtualUri')) {
      context.handle(
        _virtualUriMeta,
        virtualUri.isAcceptableOrUnknown(data['virtualUri']!, _virtualUriMeta),
      );
    } else if (isInserting) {
      context.missing(_virtualUriMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('artworkPath')) {
      context.handle(
        _artworkPathMeta,
        artworkPath.isAcceptableOrUnknown(
          data['artworkPath']!,
          _artworkPathMeta,
        ),
      );
    }
    if (data.containsKey('thumbnailPath')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnailPath']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('artworkWidth')) {
      context.handle(
        _artworkWidthMeta,
        artworkWidth.isAcceptableOrUnknown(
          data['artworkWidth']!,
          _artworkWidthMeta,
        ),
      );
    }
    if (data.containsKey('artworkHeight')) {
      context.handle(
        _artworkHeightMeta,
        artworkHeight.isAcceptableOrUnknown(
          data['artworkHeight']!,
          _artworkHeightMeta,
        ),
      );
    }
    if (data.containsKey('trackNumber')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['trackNumber']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('themeColorsBlob')) {
      context.handle(
        _themeColorsBlobMeta,
        themeColorsBlob.isAcceptableOrUnknown(
          data['themeColorsBlob']!,
          _themeColorsBlobMeta,
        ),
      );
    }
    if (data.containsKey('waveformBlob')) {
      context.handle(
        _waveformBlobMeta,
        waveformBlob.isAcceptableOrUnknown(
          data['waveformBlob']!,
          _waveformBlobMeta,
        ),
      );
    }
    if (data.containsKey('coverArtId')) {
      context.handle(
        _coverArtIdMeta,
        coverArtId.isAcceptableOrUnknown(data['coverArtId']!, _coverArtIdMeta),
      );
    }
    if (data.containsKey('suffix')) {
      context.handle(
        _suffixMeta,
        suffix.isAcceptableOrUnknown(data['suffix']!, _suffixMeta),
      );
    }
    if (data.containsKey('bitRate')) {
      context.handle(
        _bitRateMeta,
        bitRate.isAcceptableOrUnknown(data['bitRate']!, _bitRateMeta),
      );
    }
    if (data.containsKey('cachedFilePath')) {
      context.handle(
        _cachedFilePathMeta,
        cachedFilePath.isAcceptableOrUnknown(
          data['cachedFilePath']!,
          _cachedFilePathMeta,
        ),
      );
    }
    if (data.containsKey('createdAt')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['createdAt']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updatedAt')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updatedAt']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deletedAt')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deletedAt']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemoteSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteSong(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serverId'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remoteId'],
      )!,
      virtualUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}virtualUri'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      artworkPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artworkPath'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnailPath'],
      ),
      artworkWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artworkWidth'],
      ),
      artworkHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artworkHeight'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trackNumber'],
      ),
      themeColorsBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}themeColorsBlob'],
      ),
      waveformBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}waveformBlob'],
      ),
      coverArtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coverArtId'],
      ),
      suffix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suffix'],
      ),
      bitRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bitRate'],
      ),
      cachedFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cachedFilePath'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}createdAt'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updatedAt'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deletedAt'],
      ),
    );
  }

  @override
  $RemoteSongsTable createAlias(String alias) {
    return $RemoteSongsTable(attachedDatabase, alias);
  }
}

class RemoteSong extends DataClass implements Insertable<RemoteSong> {
  final int id;
  final String serverId;
  final String remoteId;
  final String virtualUri;
  final String? title;
  final String? album;
  final String? artist;
  final int? duration;
  final String? artworkPath;
  final String? thumbnailPath;
  final int? artworkWidth;
  final int? artworkHeight;
  final int? trackNumber;
  final Uint8List? themeColorsBlob;
  final Uint8List? waveformBlob;
  final String? coverArtId;
  final String? suffix;
  final int? bitRate;
  final String? cachedFilePath;
  final int? createdAt;
  final int? updatedAt;
  final int? deletedAt;
  const RemoteSong({
    required this.id,
    required this.serverId,
    required this.remoteId,
    required this.virtualUri,
    this.title,
    this.album,
    this.artist,
    this.duration,
    this.artworkPath,
    this.thumbnailPath,
    this.artworkWidth,
    this.artworkHeight,
    this.trackNumber,
    this.themeColorsBlob,
    this.waveformBlob,
    this.coverArtId,
    this.suffix,
    this.bitRate,
    this.cachedFilePath,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['serverId'] = Variable<String>(serverId);
    map['remoteId'] = Variable<String>(remoteId);
    map['virtualUri'] = Variable<String>(virtualUri);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    if (!nullToAbsent || artworkPath != null) {
      map['artworkPath'] = Variable<String>(artworkPath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnailPath'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || artworkWidth != null) {
      map['artworkWidth'] = Variable<int>(artworkWidth);
    }
    if (!nullToAbsent || artworkHeight != null) {
      map['artworkHeight'] = Variable<int>(artworkHeight);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['trackNumber'] = Variable<int>(trackNumber);
    }
    if (!nullToAbsent || themeColorsBlob != null) {
      map['themeColorsBlob'] = Variable<Uint8List>(themeColorsBlob);
    }
    if (!nullToAbsent || waveformBlob != null) {
      map['waveformBlob'] = Variable<Uint8List>(waveformBlob);
    }
    if (!nullToAbsent || coverArtId != null) {
      map['coverArtId'] = Variable<String>(coverArtId);
    }
    if (!nullToAbsent || suffix != null) {
      map['suffix'] = Variable<String>(suffix);
    }
    if (!nullToAbsent || bitRate != null) {
      map['bitRate'] = Variable<int>(bitRate);
    }
    if (!nullToAbsent || cachedFilePath != null) {
      map['cachedFilePath'] = Variable<String>(cachedFilePath);
    }
    if (!nullToAbsent || createdAt != null) {
      map['createdAt'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updatedAt'] = Variable<int>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deletedAt'] = Variable<int>(deletedAt);
    }
    return map;
  }

  RemoteSongsCompanion toCompanion(bool nullToAbsent) {
    return RemoteSongsCompanion(
      id: Value(id),
      serverId: Value(serverId),
      remoteId: Value(remoteId),
      virtualUri: Value(virtualUri),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      artworkPath: artworkPath == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      artworkWidth: artworkWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkWidth),
      artworkHeight: artworkHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkHeight),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      themeColorsBlob: themeColorsBlob == null && nullToAbsent
          ? const Value.absent()
          : Value(themeColorsBlob),
      waveformBlob: waveformBlob == null && nullToAbsent
          ? const Value.absent()
          : Value(waveformBlob),
      coverArtId: coverArtId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArtId),
      suffix: suffix == null && nullToAbsent
          ? const Value.absent()
          : Value(suffix),
      bitRate: bitRate == null && nullToAbsent
          ? const Value.absent()
          : Value(bitRate),
      cachedFilePath: cachedFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(cachedFilePath),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory RemoteSong.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteSong(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String>(json['serverId']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
      virtualUri: serializer.fromJson<String>(json['virtualUri']),
      title: serializer.fromJson<String?>(json['title']),
      album: serializer.fromJson<String?>(json['album']),
      artist: serializer.fromJson<String?>(json['artist']),
      duration: serializer.fromJson<int?>(json['duration']),
      artworkPath: serializer.fromJson<String?>(json['artworkPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      artworkWidth: serializer.fromJson<int?>(json['artworkWidth']),
      artworkHeight: serializer.fromJson<int?>(json['artworkHeight']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      themeColorsBlob: serializer.fromJson<Uint8List?>(json['themeColorsBlob']),
      waveformBlob: serializer.fromJson<Uint8List?>(json['waveformBlob']),
      coverArtId: serializer.fromJson<String?>(json['coverArtId']),
      suffix: serializer.fromJson<String?>(json['suffix']),
      bitRate: serializer.fromJson<int?>(json['bitRate']),
      cachedFilePath: serializer.fromJson<String?>(json['cachedFilePath']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String>(serverId),
      'remoteId': serializer.toJson<String>(remoteId),
      'virtualUri': serializer.toJson<String>(virtualUri),
      'title': serializer.toJson<String?>(title),
      'album': serializer.toJson<String?>(album),
      'artist': serializer.toJson<String?>(artist),
      'duration': serializer.toJson<int?>(duration),
      'artworkPath': serializer.toJson<String?>(artworkPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'artworkWidth': serializer.toJson<int?>(artworkWidth),
      'artworkHeight': serializer.toJson<int?>(artworkHeight),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'themeColorsBlob': serializer.toJson<Uint8List?>(themeColorsBlob),
      'waveformBlob': serializer.toJson<Uint8List?>(waveformBlob),
      'coverArtId': serializer.toJson<String?>(coverArtId),
      'suffix': serializer.toJson<String?>(suffix),
      'bitRate': serializer.toJson<int?>(bitRate),
      'cachedFilePath': serializer.toJson<String?>(cachedFilePath),
      'createdAt': serializer.toJson<int?>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  RemoteSong copyWith({
    int? id,
    String? serverId,
    String? remoteId,
    String? virtualUri,
    Value<String?> title = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> artist = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    Value<String?> artworkPath = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    Value<int?> artworkWidth = const Value.absent(),
    Value<int?> artworkHeight = const Value.absent(),
    Value<int?> trackNumber = const Value.absent(),
    Value<Uint8List?> themeColorsBlob = const Value.absent(),
    Value<Uint8List?> waveformBlob = const Value.absent(),
    Value<String?> coverArtId = const Value.absent(),
    Value<String?> suffix = const Value.absent(),
    Value<int?> bitRate = const Value.absent(),
    Value<String?> cachedFilePath = const Value.absent(),
    Value<int?> createdAt = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
  }) => RemoteSong(
    id: id ?? this.id,
    serverId: serverId ?? this.serverId,
    remoteId: remoteId ?? this.remoteId,
    virtualUri: virtualUri ?? this.virtualUri,
    title: title.present ? title.value : this.title,
    album: album.present ? album.value : this.album,
    artist: artist.present ? artist.value : this.artist,
    duration: duration.present ? duration.value : this.duration,
    artworkPath: artworkPath.present ? artworkPath.value : this.artworkPath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    artworkWidth: artworkWidth.present ? artworkWidth.value : this.artworkWidth,
    artworkHeight: artworkHeight.present
        ? artworkHeight.value
        : this.artworkHeight,
    trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
    themeColorsBlob: themeColorsBlob.present
        ? themeColorsBlob.value
        : this.themeColorsBlob,
    waveformBlob: waveformBlob.present ? waveformBlob.value : this.waveformBlob,
    coverArtId: coverArtId.present ? coverArtId.value : this.coverArtId,
    suffix: suffix.present ? suffix.value : this.suffix,
    bitRate: bitRate.present ? bitRate.value : this.bitRate,
    cachedFilePath: cachedFilePath.present
        ? cachedFilePath.value
        : this.cachedFilePath,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  RemoteSong copyWithCompanion(RemoteSongsCompanion data) {
    return RemoteSong(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      virtualUri: data.virtualUri.present
          ? data.virtualUri.value
          : this.virtualUri,
      title: data.title.present ? data.title.value : this.title,
      album: data.album.present ? data.album.value : this.album,
      artist: data.artist.present ? data.artist.value : this.artist,
      duration: data.duration.present ? data.duration.value : this.duration,
      artworkPath: data.artworkPath.present
          ? data.artworkPath.value
          : this.artworkPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      artworkWidth: data.artworkWidth.present
          ? data.artworkWidth.value
          : this.artworkWidth,
      artworkHeight: data.artworkHeight.present
          ? data.artworkHeight.value
          : this.artworkHeight,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      themeColorsBlob: data.themeColorsBlob.present
          ? data.themeColorsBlob.value
          : this.themeColorsBlob,
      waveformBlob: data.waveformBlob.present
          ? data.waveformBlob.value
          : this.waveformBlob,
      coverArtId: data.coverArtId.present
          ? data.coverArtId.value
          : this.coverArtId,
      suffix: data.suffix.present ? data.suffix.value : this.suffix,
      bitRate: data.bitRate.present ? data.bitRate.value : this.bitRate,
      cachedFilePath: data.cachedFilePath.present
          ? data.cachedFilePath.value
          : this.cachedFilePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteSong(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('remoteId: $remoteId, ')
          ..write('virtualUri: $virtualUri, ')
          ..write('title: $title, ')
          ..write('album: $album, ')
          ..write('artist: $artist, ')
          ..write('duration: $duration, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('artworkWidth: $artworkWidth, ')
          ..write('artworkHeight: $artworkHeight, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('themeColorsBlob: $themeColorsBlob, ')
          ..write('waveformBlob: $waveformBlob, ')
          ..write('coverArtId: $coverArtId, ')
          ..write('suffix: $suffix, ')
          ..write('bitRate: $bitRate, ')
          ..write('cachedFilePath: $cachedFilePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    serverId,
    remoteId,
    virtualUri,
    title,
    album,
    artist,
    duration,
    artworkPath,
    thumbnailPath,
    artworkWidth,
    artworkHeight,
    trackNumber,
    $driftBlobEquality.hash(themeColorsBlob),
    $driftBlobEquality.hash(waveformBlob),
    coverArtId,
    suffix,
    bitRate,
    cachedFilePath,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteSong &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.remoteId == this.remoteId &&
          other.virtualUri == this.virtualUri &&
          other.title == this.title &&
          other.album == this.album &&
          other.artist == this.artist &&
          other.duration == this.duration &&
          other.artworkPath == this.artworkPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.artworkWidth == this.artworkWidth &&
          other.artworkHeight == this.artworkHeight &&
          other.trackNumber == this.trackNumber &&
          $driftBlobEquality.equals(
            other.themeColorsBlob,
            this.themeColorsBlob,
          ) &&
          $driftBlobEquality.equals(other.waveformBlob, this.waveformBlob) &&
          other.coverArtId == this.coverArtId &&
          other.suffix == this.suffix &&
          other.bitRate == this.bitRate &&
          other.cachedFilePath == this.cachedFilePath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RemoteSongsCompanion extends UpdateCompanion<RemoteSong> {
  final Value<int> id;
  final Value<String> serverId;
  final Value<String> remoteId;
  final Value<String> virtualUri;
  final Value<String?> title;
  final Value<String?> album;
  final Value<String?> artist;
  final Value<int?> duration;
  final Value<String?> artworkPath;
  final Value<String?> thumbnailPath;
  final Value<int?> artworkWidth;
  final Value<int?> artworkHeight;
  final Value<int?> trackNumber;
  final Value<Uint8List?> themeColorsBlob;
  final Value<Uint8List?> waveformBlob;
  final Value<String?> coverArtId;
  final Value<String?> suffix;
  final Value<int?> bitRate;
  final Value<String?> cachedFilePath;
  final Value<int?> createdAt;
  final Value<int?> updatedAt;
  final Value<int?> deletedAt;
  const RemoteSongsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.virtualUri = const Value.absent(),
    this.title = const Value.absent(),
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
    this.duration = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.artworkWidth = const Value.absent(),
    this.artworkHeight = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.themeColorsBlob = const Value.absent(),
    this.waveformBlob = const Value.absent(),
    this.coverArtId = const Value.absent(),
    this.suffix = const Value.absent(),
    this.bitRate = const Value.absent(),
    this.cachedFilePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  RemoteSongsCompanion.insert({
    this.id = const Value.absent(),
    required String serverId,
    required String remoteId,
    required String virtualUri,
    this.title = const Value.absent(),
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
    this.duration = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.artworkWidth = const Value.absent(),
    this.artworkHeight = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.themeColorsBlob = const Value.absent(),
    this.waveformBlob = const Value.absent(),
    this.coverArtId = const Value.absent(),
    this.suffix = const Value.absent(),
    this.bitRate = const Value.absent(),
    this.cachedFilePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : serverId = Value(serverId),
       remoteId = Value(remoteId),
       virtualUri = Value(virtualUri);
  static Insertable<RemoteSong> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? remoteId,
    Expression<String>? virtualUri,
    Expression<String>? title,
    Expression<String>? album,
    Expression<String>? artist,
    Expression<int>? duration,
    Expression<String>? artworkPath,
    Expression<String>? thumbnailPath,
    Expression<int>? artworkWidth,
    Expression<int>? artworkHeight,
    Expression<int>? trackNumber,
    Expression<Uint8List>? themeColorsBlob,
    Expression<Uint8List>? waveformBlob,
    Expression<String>? coverArtId,
    Expression<String>? suffix,
    Expression<int>? bitRate,
    Expression<String>? cachedFilePath,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'serverId': serverId,
      if (remoteId != null) 'remoteId': remoteId,
      if (virtualUri != null) 'virtualUri': virtualUri,
      if (title != null) 'title': title,
      if (album != null) 'album': album,
      if (artist != null) 'artist': artist,
      if (duration != null) 'duration': duration,
      if (artworkPath != null) 'artworkPath': artworkPath,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      if (artworkWidth != null) 'artworkWidth': artworkWidth,
      if (artworkHeight != null) 'artworkHeight': artworkHeight,
      if (trackNumber != null) 'trackNumber': trackNumber,
      if (themeColorsBlob != null) 'themeColorsBlob': themeColorsBlob,
      if (waveformBlob != null) 'waveformBlob': waveformBlob,
      if (coverArtId != null) 'coverArtId': coverArtId,
      if (suffix != null) 'suffix': suffix,
      if (bitRate != null) 'bitRate': bitRate,
      if (cachedFilePath != null) 'cachedFilePath': cachedFilePath,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (deletedAt != null) 'deletedAt': deletedAt,
    });
  }

  RemoteSongsCompanion copyWith({
    Value<int>? id,
    Value<String>? serverId,
    Value<String>? remoteId,
    Value<String>? virtualUri,
    Value<String?>? title,
    Value<String?>? album,
    Value<String?>? artist,
    Value<int?>? duration,
    Value<String?>? artworkPath,
    Value<String?>? thumbnailPath,
    Value<int?>? artworkWidth,
    Value<int?>? artworkHeight,
    Value<int?>? trackNumber,
    Value<Uint8List?>? themeColorsBlob,
    Value<Uint8List?>? waveformBlob,
    Value<String?>? coverArtId,
    Value<String?>? suffix,
    Value<int?>? bitRate,
    Value<String?>? cachedFilePath,
    Value<int?>? createdAt,
    Value<int?>? updatedAt,
    Value<int?>? deletedAt,
  }) {
    return RemoteSongsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      remoteId: remoteId ?? this.remoteId,
      virtualUri: virtualUri ?? this.virtualUri,
      title: title ?? this.title,
      album: album ?? this.album,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      artworkPath: artworkPath ?? this.artworkPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      artworkWidth: artworkWidth ?? this.artworkWidth,
      artworkHeight: artworkHeight ?? this.artworkHeight,
      trackNumber: trackNumber ?? this.trackNumber,
      themeColorsBlob: themeColorsBlob ?? this.themeColorsBlob,
      waveformBlob: waveformBlob ?? this.waveformBlob,
      coverArtId: coverArtId ?? this.coverArtId,
      suffix: suffix ?? this.suffix,
      bitRate: bitRate ?? this.bitRate,
      cachedFilePath: cachedFilePath ?? this.cachedFilePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['serverId'] = Variable<String>(serverId.value);
    }
    if (remoteId.present) {
      map['remoteId'] = Variable<String>(remoteId.value);
    }
    if (virtualUri.present) {
      map['virtualUri'] = Variable<String>(virtualUri.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (artworkPath.present) {
      map['artworkPath'] = Variable<String>(artworkPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnailPath'] = Variable<String>(thumbnailPath.value);
    }
    if (artworkWidth.present) {
      map['artworkWidth'] = Variable<int>(artworkWidth.value);
    }
    if (artworkHeight.present) {
      map['artworkHeight'] = Variable<int>(artworkHeight.value);
    }
    if (trackNumber.present) {
      map['trackNumber'] = Variable<int>(trackNumber.value);
    }
    if (themeColorsBlob.present) {
      map['themeColorsBlob'] = Variable<Uint8List>(themeColorsBlob.value);
    }
    if (waveformBlob.present) {
      map['waveformBlob'] = Variable<Uint8List>(waveformBlob.value);
    }
    if (coverArtId.present) {
      map['coverArtId'] = Variable<String>(coverArtId.value);
    }
    if (suffix.present) {
      map['suffix'] = Variable<String>(suffix.value);
    }
    if (bitRate.present) {
      map['bitRate'] = Variable<int>(bitRate.value);
    }
    if (cachedFilePath.present) {
      map['cachedFilePath'] = Variable<String>(cachedFilePath.value);
    }
    if (createdAt.present) {
      map['createdAt'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updatedAt'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deletedAt'] = Variable<int>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteSongsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('remoteId: $remoteId, ')
          ..write('virtualUri: $virtualUri, ')
          ..write('title: $title, ')
          ..write('album: $album, ')
          ..write('artist: $artist, ')
          ..write('duration: $duration, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('artworkWidth: $artworkWidth, ')
          ..write('artworkHeight: $artworkHeight, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('themeColorsBlob: $themeColorsBlob, ')
          ..write('waveformBlob: $waveformBlob, ')
          ..write('coverArtId: $coverArtId, ')
          ..write('suffix: $suffix, ')
          ..write('bitRate: $bitRate, ')
          ..write('cachedFilePath: $cachedFilePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$MetadataDriftDatabase extends GeneratedDatabase {
  _$MetadataDriftDatabase(QueryExecutor e) : super(e);
  $MetadataDriftDatabaseManager get managers =>
      $MetadataDriftDatabaseManager(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $SongRootsTable songRoots = $SongRootsTable(this);
  late final $SongPlayHistoriesTable songPlayHistories =
      $SongPlayHistoriesTable(this);
  late final $LyricsCachesTable lyricsCaches = $LyricsCachesTable(this);
  late final $AcoustidCachesTable acoustidCaches = $AcoustidCachesTable(this);
  late final $ReleaseCoverCachesTable releaseCoverCaches =
      $ReleaseCoverCachesTable(this);
  late final $LyricsTranslationCachesTable lyricsTranslationCaches =
      $LyricsTranslationCachesTable(this);
  late final $ArtistCachesTable artistCaches = $ArtistCachesTable(this);
  late final $ArtistImageCachesTable artistImageCaches =
      $ArtistImageCachesTable(this);
  late final $ArtworkCachesTable artworkCaches = $ArtworkCachesTable(this);
  late final $RemoteSongsTable remoteSongs = $RemoteSongsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    songs,
    songRoots,
    songPlayHistories,
    lyricsCaches,
    acoustidCaches,
    releaseCoverCaches,
    lyricsTranslationCaches,
    artistCaches,
    artistImageCaches,
    artworkCaches,
    remoteSongs,
  ];
}

typedef $$SongsTableCreateCompanionBuilder =
    SongsCompanion Function({
      Value<int> id,
      Value<int?> mediaId,
      required String path,
      Value<String?> title,
      Value<String?> album,
      Value<String?> artist,
      Value<int?> duration,
      Value<String?> artworkPath,
      Value<String?> thumbnailPath,
      Value<int?> artworkWidth,
      Value<int?> artworkHeight,
      Value<int?> trackNumber,
      Value<int?> sourceFlags,
      Value<Uint8List?> themeColorsBlob,
      Value<Uint8List?> waveformBlob,
      Value<int?> lastModifiedTime,
      Value<int?> metadataTextScanned,
      Value<int?> metadataImgScanned,
      Value<int?> createdAt,
      Value<int?> deletedAt,
      Value<String?> genres,
      Value<bool> isAppModified,
      Value<int?> lastSeenRootScanSessionId,
    });
typedef $$SongsTableUpdateCompanionBuilder =
    SongsCompanion Function({
      Value<int> id,
      Value<int?> mediaId,
      Value<String> path,
      Value<String?> title,
      Value<String?> album,
      Value<String?> artist,
      Value<int?> duration,
      Value<String?> artworkPath,
      Value<String?> thumbnailPath,
      Value<int?> artworkWidth,
      Value<int?> artworkHeight,
      Value<int?> trackNumber,
      Value<int?> sourceFlags,
      Value<Uint8List?> themeColorsBlob,
      Value<Uint8List?> waveformBlob,
      Value<int?> lastModifiedTime,
      Value<int?> metadataTextScanned,
      Value<int?> metadataImgScanned,
      Value<int?> createdAt,
      Value<int?> deletedAt,
      Value<String?> genres,
      Value<bool> isAppModified,
      Value<int?> lastSeenRootScanSessionId,
    });

class $$SongsTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get artworkWidth => $composableBuilder(
    column: $table.artworkWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get artworkHeight => $composableBuilder(
    column: $table.artworkHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceFlags => $composableBuilder(
    column: $table.sourceFlags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get themeColorsBlob => $composableBuilder(
    column: $table.themeColorsBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get waveformBlob => $composableBuilder(
    column: $table.waveformBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastModifiedTime => $composableBuilder(
    column: $table.lastModifiedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metadataTextScanned => $composableBuilder(
    column: $table.metadataTextScanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metadataImgScanned => $composableBuilder(
    column: $table.metadataImgScanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAppModified => $composableBuilder(
    column: $table.isAppModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenRootScanSessionId => $composableBuilder(
    column: $table.lastSeenRootScanSessionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongsTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get artworkWidth => $composableBuilder(
    column: $table.artworkWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get artworkHeight => $composableBuilder(
    column: $table.artworkHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceFlags => $composableBuilder(
    column: $table.sourceFlags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get themeColorsBlob => $composableBuilder(
    column: $table.themeColorsBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get waveformBlob => $composableBuilder(
    column: $table.waveformBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastModifiedTime => $composableBuilder(
    column: $table.lastModifiedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metadataTextScanned => $composableBuilder(
    column: $table.metadataTextScanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metadataImgScanned => $composableBuilder(
    column: $table.metadataImgScanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAppModified => $composableBuilder(
    column: $table.isAppModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenRootScanSessionId => $composableBuilder(
    column: $table.lastSeenRootScanSessionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get artworkWidth => $composableBuilder(
    column: $table.artworkWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get artworkHeight => $composableBuilder(
    column: $table.artworkHeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceFlags => $composableBuilder(
    column: $table.sourceFlags,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get themeColorsBlob => $composableBuilder(
    column: $table.themeColorsBlob,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get waveformBlob => $composableBuilder(
    column: $table.waveformBlob,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastModifiedTime => $composableBuilder(
    column: $table.lastModifiedTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get metadataTextScanned => $composableBuilder(
    column: $table.metadataTextScanned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get metadataImgScanned => $composableBuilder(
    column: $table.metadataImgScanned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<bool> get isAppModified => $composableBuilder(
    column: $table.isAppModified,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenRootScanSessionId => $composableBuilder(
    column: $table.lastSeenRootScanSessionId,
    builder: (column) => column,
  );
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $SongsTable,
          Song,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (Song, BaseReferences<_$MetadataDriftDatabase, $SongsTable, Song>),
          Song,
          PrefetchHooks Function()
        > {
  $$SongsTableTableManager(_$MetadataDriftDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> mediaId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<String?> artworkPath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> artworkWidth = const Value.absent(),
                Value<int?> artworkHeight = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> sourceFlags = const Value.absent(),
                Value<Uint8List?> themeColorsBlob = const Value.absent(),
                Value<Uint8List?> waveformBlob = const Value.absent(),
                Value<int?> lastModifiedTime = const Value.absent(),
                Value<int?> metadataTextScanned = const Value.absent(),
                Value<int?> metadataImgScanned = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<bool> isAppModified = const Value.absent(),
                Value<int?> lastSeenRootScanSessionId = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                mediaId: mediaId,
                path: path,
                title: title,
                album: album,
                artist: artist,
                duration: duration,
                artworkPath: artworkPath,
                thumbnailPath: thumbnailPath,
                artworkWidth: artworkWidth,
                artworkHeight: artworkHeight,
                trackNumber: trackNumber,
                sourceFlags: sourceFlags,
                themeColorsBlob: themeColorsBlob,
                waveformBlob: waveformBlob,
                lastModifiedTime: lastModifiedTime,
                metadataTextScanned: metadataTextScanned,
                metadataImgScanned: metadataImgScanned,
                createdAt: createdAt,
                deletedAt: deletedAt,
                genres: genres,
                isAppModified: isAppModified,
                lastSeenRootScanSessionId: lastSeenRootScanSessionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> mediaId = const Value.absent(),
                required String path,
                Value<String?> title = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<String?> artworkPath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> artworkWidth = const Value.absent(),
                Value<int?> artworkHeight = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> sourceFlags = const Value.absent(),
                Value<Uint8List?> themeColorsBlob = const Value.absent(),
                Value<Uint8List?> waveformBlob = const Value.absent(),
                Value<int?> lastModifiedTime = const Value.absent(),
                Value<int?> metadataTextScanned = const Value.absent(),
                Value<int?> metadataImgScanned = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<bool> isAppModified = const Value.absent(),
                Value<int?> lastSeenRootScanSessionId = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                mediaId: mediaId,
                path: path,
                title: title,
                album: album,
                artist: artist,
                duration: duration,
                artworkPath: artworkPath,
                thumbnailPath: thumbnailPath,
                artworkWidth: artworkWidth,
                artworkHeight: artworkHeight,
                trackNumber: trackNumber,
                sourceFlags: sourceFlags,
                themeColorsBlob: themeColorsBlob,
                waveformBlob: waveformBlob,
                lastModifiedTime: lastModifiedTime,
                metadataTextScanned: metadataTextScanned,
                metadataImgScanned: metadataImgScanned,
                createdAt: createdAt,
                deletedAt: deletedAt,
                genres: genres,
                isAppModified: isAppModified,
                lastSeenRootScanSessionId: lastSeenRootScanSessionId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $SongsTable,
      Song,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (Song, BaseReferences<_$MetadataDriftDatabase, $SongsTable, Song>),
      Song,
      PrefetchHooks Function()
    >;
typedef $$SongRootsTableCreateCompanionBuilder =
    SongRootsCompanion Function({
      required String songPath,
      required String rootPath,
      Value<int> rowid,
    });
typedef $$SongRootsTableUpdateCompanionBuilder =
    SongRootsCompanion Function({
      Value<String> songPath,
      Value<String> rootPath,
      Value<int> rowid,
    });

class $$SongRootsTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $SongRootsTable> {
  $$SongRootsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get songPath => $composableBuilder(
    column: $table.songPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootPath => $composableBuilder(
    column: $table.rootPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongRootsTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $SongRootsTable> {
  $$SongRootsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get songPath => $composableBuilder(
    column: $table.songPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootPath => $composableBuilder(
    column: $table.rootPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongRootsTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $SongRootsTable> {
  $$SongRootsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get songPath =>
      $composableBuilder(column: $table.songPath, builder: (column) => column);

  GeneratedColumn<String> get rootPath =>
      $composableBuilder(column: $table.rootPath, builder: (column) => column);
}

class $$SongRootsTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $SongRootsTable,
          SongRoot,
          $$SongRootsTableFilterComposer,
          $$SongRootsTableOrderingComposer,
          $$SongRootsTableAnnotationComposer,
          $$SongRootsTableCreateCompanionBuilder,
          $$SongRootsTableUpdateCompanionBuilder,
          (
            SongRoot,
            BaseReferences<_$MetadataDriftDatabase, $SongRootsTable, SongRoot>,
          ),
          SongRoot,
          PrefetchHooks Function()
        > {
  $$SongRootsTableTableManager(
    _$MetadataDriftDatabase db,
    $SongRootsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongRootsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongRootsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongRootsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songPath = const Value.absent(),
                Value<String> rootPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongRootsCompanion(
                songPath: songPath,
                rootPath: rootPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songPath,
                required String rootPath,
                Value<int> rowid = const Value.absent(),
              }) => SongRootsCompanion.insert(
                songPath: songPath,
                rootPath: rootPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongRootsTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $SongRootsTable,
      SongRoot,
      $$SongRootsTableFilterComposer,
      $$SongRootsTableOrderingComposer,
      $$SongRootsTableAnnotationComposer,
      $$SongRootsTableCreateCompanionBuilder,
      $$SongRootsTableUpdateCompanionBuilder,
      (
        SongRoot,
        BaseReferences<_$MetadataDriftDatabase, $SongRootsTable, SongRoot>,
      ),
      SongRoot,
      PrefetchHooks Function()
    >;
typedef $$SongPlayHistoriesTableCreateCompanionBuilder =
    SongPlayHistoriesCompanion Function({
      Value<int> id,
      required String songPath,
      required int playedAt,
      Value<int?> playedDurationMillis,
      Value<int?> songDurationMillis,
      Value<String?> source,
    });
typedef $$SongPlayHistoriesTableUpdateCompanionBuilder =
    SongPlayHistoriesCompanion Function({
      Value<int> id,
      Value<String> songPath,
      Value<int> playedAt,
      Value<int?> playedDurationMillis,
      Value<int?> songDurationMillis,
      Value<String?> source,
    });

class $$SongPlayHistoriesTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $SongPlayHistoriesTable> {
  $$SongPlayHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songPath => $composableBuilder(
    column: $table.songPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playedDurationMillis => $composableBuilder(
    column: $table.playedDurationMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songDurationMillis => $composableBuilder(
    column: $table.songDurationMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongPlayHistoriesTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $SongPlayHistoriesTable> {
  $$SongPlayHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songPath => $composableBuilder(
    column: $table.songPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playedDurationMillis => $composableBuilder(
    column: $table.playedDurationMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songDurationMillis => $composableBuilder(
    column: $table.songDurationMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongPlayHistoriesTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $SongPlayHistoriesTable> {
  $$SongPlayHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get songPath =>
      $composableBuilder(column: $table.songPath, builder: (column) => column);

  GeneratedColumn<int> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get playedDurationMillis => $composableBuilder(
    column: $table.playedDurationMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get songDurationMillis => $composableBuilder(
    column: $table.songDurationMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$SongPlayHistoriesTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $SongPlayHistoriesTable,
          SongPlayHistory,
          $$SongPlayHistoriesTableFilterComposer,
          $$SongPlayHistoriesTableOrderingComposer,
          $$SongPlayHistoriesTableAnnotationComposer,
          $$SongPlayHistoriesTableCreateCompanionBuilder,
          $$SongPlayHistoriesTableUpdateCompanionBuilder,
          (
            SongPlayHistory,
            BaseReferences<
              _$MetadataDriftDatabase,
              $SongPlayHistoriesTable,
              SongPlayHistory
            >,
          ),
          SongPlayHistory,
          PrefetchHooks Function()
        > {
  $$SongPlayHistoriesTableTableManager(
    _$MetadataDriftDatabase db,
    $SongPlayHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongPlayHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongPlayHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongPlayHistoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> songPath = const Value.absent(),
                Value<int> playedAt = const Value.absent(),
                Value<int?> playedDurationMillis = const Value.absent(),
                Value<int?> songDurationMillis = const Value.absent(),
                Value<String?> source = const Value.absent(),
              }) => SongPlayHistoriesCompanion(
                id: id,
                songPath: songPath,
                playedAt: playedAt,
                playedDurationMillis: playedDurationMillis,
                songDurationMillis: songDurationMillis,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String songPath,
                required int playedAt,
                Value<int?> playedDurationMillis = const Value.absent(),
                Value<int?> songDurationMillis = const Value.absent(),
                Value<String?> source = const Value.absent(),
              }) => SongPlayHistoriesCompanion.insert(
                id: id,
                songPath: songPath,
                playedAt: playedAt,
                playedDurationMillis: playedDurationMillis,
                songDurationMillis: songDurationMillis,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongPlayHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $SongPlayHistoriesTable,
      SongPlayHistory,
      $$SongPlayHistoriesTableFilterComposer,
      $$SongPlayHistoriesTableOrderingComposer,
      $$SongPlayHistoriesTableAnnotationComposer,
      $$SongPlayHistoriesTableCreateCompanionBuilder,
      $$SongPlayHistoriesTableUpdateCompanionBuilder,
      (
        SongPlayHistory,
        BaseReferences<
          _$MetadataDriftDatabase,
          $SongPlayHistoriesTable,
          SongPlayHistory
        >,
      ),
      SongPlayHistory,
      PrefetchHooks Function()
    >;
typedef $$LyricsCachesTableCreateCompanionBuilder =
    LyricsCachesCompanion Function({
      Value<int> id,
      required String cacheKey,
      required String source,
      Value<String> languageCode,
      required bool isSynced,
      Value<String?> syncedLyrics,
      required String syncedLinesJson,
      required int timelineOffsetMillis,
      required int updatedAtMillis,
    });
typedef $$LyricsCachesTableUpdateCompanionBuilder =
    LyricsCachesCompanion Function({
      Value<int> id,
      Value<String> cacheKey,
      Value<String> source,
      Value<String> languageCode,
      Value<bool> isSynced,
      Value<String?> syncedLyrics,
      Value<String> syncedLinesJson,
      Value<int> timelineOffsetMillis,
      Value<int> updatedAtMillis,
    });

class $$LyricsCachesTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $LyricsCachesTable> {
  $$LyricsCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedLyrics => $composableBuilder(
    column: $table.syncedLyrics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedLinesJson => $composableBuilder(
    column: $table.syncedLinesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timelineOffsetMillis => $composableBuilder(
    column: $table.timelineOffsetMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LyricsCachesTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $LyricsCachesTable> {
  $$LyricsCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedLyrics => $composableBuilder(
    column: $table.syncedLyrics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedLinesJson => $composableBuilder(
    column: $table.syncedLinesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timelineOffsetMillis => $composableBuilder(
    column: $table.timelineOffsetMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LyricsCachesTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $LyricsCachesTable> {
  $$LyricsCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncedLyrics => $composableBuilder(
    column: $table.syncedLyrics,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncedLinesJson => $composableBuilder(
    column: $table.syncedLinesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timelineOffsetMillis => $composableBuilder(
    column: $table.timelineOffsetMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$LyricsCachesTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $LyricsCachesTable,
          LyricsCache,
          $$LyricsCachesTableFilterComposer,
          $$LyricsCachesTableOrderingComposer,
          $$LyricsCachesTableAnnotationComposer,
          $$LyricsCachesTableCreateCompanionBuilder,
          $$LyricsCachesTableUpdateCompanionBuilder,
          (
            LyricsCache,
            BaseReferences<
              _$MetadataDriftDatabase,
              $LyricsCachesTable,
              LyricsCache
            >,
          ),
          LyricsCache,
          PrefetchHooks Function()
        > {
  $$LyricsCachesTableTableManager(
    _$MetadataDriftDatabase db,
    $LyricsCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricsCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LyricsCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LyricsCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> syncedLyrics = const Value.absent(),
                Value<String> syncedLinesJson = const Value.absent(),
                Value<int> timelineOffsetMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
              }) => LyricsCachesCompanion(
                id: id,
                cacheKey: cacheKey,
                source: source,
                languageCode: languageCode,
                isSynced: isSynced,
                syncedLyrics: syncedLyrics,
                syncedLinesJson: syncedLinesJson,
                timelineOffsetMillis: timelineOffsetMillis,
                updatedAtMillis: updatedAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cacheKey,
                required String source,
                Value<String> languageCode = const Value.absent(),
                required bool isSynced,
                Value<String?> syncedLyrics = const Value.absent(),
                required String syncedLinesJson,
                required int timelineOffsetMillis,
                required int updatedAtMillis,
              }) => LyricsCachesCompanion.insert(
                id: id,
                cacheKey: cacheKey,
                source: source,
                languageCode: languageCode,
                isSynced: isSynced,
                syncedLyrics: syncedLyrics,
                syncedLinesJson: syncedLinesJson,
                timelineOffsetMillis: timelineOffsetMillis,
                updatedAtMillis: updatedAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LyricsCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $LyricsCachesTable,
      LyricsCache,
      $$LyricsCachesTableFilterComposer,
      $$LyricsCachesTableOrderingComposer,
      $$LyricsCachesTableAnnotationComposer,
      $$LyricsCachesTableCreateCompanionBuilder,
      $$LyricsCachesTableUpdateCompanionBuilder,
      (
        LyricsCache,
        BaseReferences<
          _$MetadataDriftDatabase,
          $LyricsCachesTable,
          LyricsCache
        >,
      ),
      LyricsCache,
      PrefetchHooks Function()
    >;
typedef $$AcoustidCachesTableCreateCompanionBuilder =
    AcoustidCachesCompanion Function({
      Value<int> id,
      required String fingerprint,
      required int durationSeconds,
      required String resultsJson,
      required int updatedAtMillis,
    });
typedef $$AcoustidCachesTableUpdateCompanionBuilder =
    AcoustidCachesCompanion Function({
      Value<int> id,
      Value<String> fingerprint,
      Value<int> durationSeconds,
      Value<String> resultsJson,
      Value<int> updatedAtMillis,
    });

class $$AcoustidCachesTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $AcoustidCachesTable> {
  $$AcoustidCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultsJson => $composableBuilder(
    column: $table.resultsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AcoustidCachesTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $AcoustidCachesTable> {
  $$AcoustidCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultsJson => $composableBuilder(
    column: $table.resultsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AcoustidCachesTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $AcoustidCachesTable> {
  $$AcoustidCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultsJson => $composableBuilder(
    column: $table.resultsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$AcoustidCachesTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $AcoustidCachesTable,
          AcoustidCache,
          $$AcoustidCachesTableFilterComposer,
          $$AcoustidCachesTableOrderingComposer,
          $$AcoustidCachesTableAnnotationComposer,
          $$AcoustidCachesTableCreateCompanionBuilder,
          $$AcoustidCachesTableUpdateCompanionBuilder,
          (
            AcoustidCache,
            BaseReferences<
              _$MetadataDriftDatabase,
              $AcoustidCachesTable,
              AcoustidCache
            >,
          ),
          AcoustidCache,
          PrefetchHooks Function()
        > {
  $$AcoustidCachesTableTableManager(
    _$MetadataDriftDatabase db,
    $AcoustidCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AcoustidCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AcoustidCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AcoustidCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> resultsJson = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
              }) => AcoustidCachesCompanion(
                id: id,
                fingerprint: fingerprint,
                durationSeconds: durationSeconds,
                resultsJson: resultsJson,
                updatedAtMillis: updatedAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fingerprint,
                required int durationSeconds,
                required String resultsJson,
                required int updatedAtMillis,
              }) => AcoustidCachesCompanion.insert(
                id: id,
                fingerprint: fingerprint,
                durationSeconds: durationSeconds,
                resultsJson: resultsJson,
                updatedAtMillis: updatedAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AcoustidCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $AcoustidCachesTable,
      AcoustidCache,
      $$AcoustidCachesTableFilterComposer,
      $$AcoustidCachesTableOrderingComposer,
      $$AcoustidCachesTableAnnotationComposer,
      $$AcoustidCachesTableCreateCompanionBuilder,
      $$AcoustidCachesTableUpdateCompanionBuilder,
      (
        AcoustidCache,
        BaseReferences<
          _$MetadataDriftDatabase,
          $AcoustidCachesTable,
          AcoustidCache
        >,
      ),
      AcoustidCache,
      PrefetchHooks Function()
    >;
typedef $$ReleaseCoverCachesTableCreateCompanionBuilder =
    ReleaseCoverCachesCompanion Function({
      Value<int> id,
      required String releaseId,
      Value<String?> largeUrl,
      Value<String?> thumbnailUrl,
      required int updatedAtMillis,
    });
typedef $$ReleaseCoverCachesTableUpdateCompanionBuilder =
    ReleaseCoverCachesCompanion Function({
      Value<int> id,
      Value<String> releaseId,
      Value<String?> largeUrl,
      Value<String?> thumbnailUrl,
      Value<int> updatedAtMillis,
    });

class $$ReleaseCoverCachesTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $ReleaseCoverCachesTable> {
  $$ReleaseCoverCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get largeUrl => $composableBuilder(
    column: $table.largeUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReleaseCoverCachesTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $ReleaseCoverCachesTable> {
  $$ReleaseCoverCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get largeUrl => $composableBuilder(
    column: $table.largeUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReleaseCoverCachesTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $ReleaseCoverCachesTable> {
  $$ReleaseCoverCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get releaseId =>
      $composableBuilder(column: $table.releaseId, builder: (column) => column);

  GeneratedColumn<String> get largeUrl =>
      $composableBuilder(column: $table.largeUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$ReleaseCoverCachesTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $ReleaseCoverCachesTable,
          ReleaseCoverCache,
          $$ReleaseCoverCachesTableFilterComposer,
          $$ReleaseCoverCachesTableOrderingComposer,
          $$ReleaseCoverCachesTableAnnotationComposer,
          $$ReleaseCoverCachesTableCreateCompanionBuilder,
          $$ReleaseCoverCachesTableUpdateCompanionBuilder,
          (
            ReleaseCoverCache,
            BaseReferences<
              _$MetadataDriftDatabase,
              $ReleaseCoverCachesTable,
              ReleaseCoverCache
            >,
          ),
          ReleaseCoverCache,
          PrefetchHooks Function()
        > {
  $$ReleaseCoverCachesTableTableManager(
    _$MetadataDriftDatabase db,
    $ReleaseCoverCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReleaseCoverCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReleaseCoverCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReleaseCoverCachesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> releaseId = const Value.absent(),
                Value<String?> largeUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
              }) => ReleaseCoverCachesCompanion(
                id: id,
                releaseId: releaseId,
                largeUrl: largeUrl,
                thumbnailUrl: thumbnailUrl,
                updatedAtMillis: updatedAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String releaseId,
                Value<String?> largeUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                required int updatedAtMillis,
              }) => ReleaseCoverCachesCompanion.insert(
                id: id,
                releaseId: releaseId,
                largeUrl: largeUrl,
                thumbnailUrl: thumbnailUrl,
                updatedAtMillis: updatedAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReleaseCoverCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $ReleaseCoverCachesTable,
      ReleaseCoverCache,
      $$ReleaseCoverCachesTableFilterComposer,
      $$ReleaseCoverCachesTableOrderingComposer,
      $$ReleaseCoverCachesTableAnnotationComposer,
      $$ReleaseCoverCachesTableCreateCompanionBuilder,
      $$ReleaseCoverCachesTableUpdateCompanionBuilder,
      (
        ReleaseCoverCache,
        BaseReferences<
          _$MetadataDriftDatabase,
          $ReleaseCoverCachesTable,
          ReleaseCoverCache
        >,
      ),
      ReleaseCoverCache,
      PrefetchHooks Function()
    >;
typedef $$LyricsTranslationCachesTableCreateCompanionBuilder =
    LyricsTranslationCachesCompanion Function({
      Value<int> id,
      required String cacheKey,
      required String languageCode,
      required String translatedText,
      required String translatedLinesJson,
      Value<String?> provider,
      required int updatedAtMillis,
    });
typedef $$LyricsTranslationCachesTableUpdateCompanionBuilder =
    LyricsTranslationCachesCompanion Function({
      Value<int> id,
      Value<String> cacheKey,
      Value<String> languageCode,
      Value<String> translatedText,
      Value<String> translatedLinesJson,
      Value<String?> provider,
      Value<int> updatedAtMillis,
    });

class $$LyricsTranslationCachesTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $LyricsTranslationCachesTable> {
  $$LyricsTranslationCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedLinesJson => $composableBuilder(
    column: $table.translatedLinesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LyricsTranslationCachesTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $LyricsTranslationCachesTable> {
  $$LyricsTranslationCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedLinesJson => $composableBuilder(
    column: $table.translatedLinesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LyricsTranslationCachesTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $LyricsTranslationCachesTable> {
  $$LyricsTranslationCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translatedLinesJson => $composableBuilder(
    column: $table.translatedLinesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$LyricsTranslationCachesTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $LyricsTranslationCachesTable,
          LyricsTranslationCache,
          $$LyricsTranslationCachesTableFilterComposer,
          $$LyricsTranslationCachesTableOrderingComposer,
          $$LyricsTranslationCachesTableAnnotationComposer,
          $$LyricsTranslationCachesTableCreateCompanionBuilder,
          $$LyricsTranslationCachesTableUpdateCompanionBuilder,
          (
            LyricsTranslationCache,
            BaseReferences<
              _$MetadataDriftDatabase,
              $LyricsTranslationCachesTable,
              LyricsTranslationCache
            >,
          ),
          LyricsTranslationCache,
          PrefetchHooks Function()
        > {
  $$LyricsTranslationCachesTableTableManager(
    _$MetadataDriftDatabase db,
    $LyricsTranslationCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricsTranslationCachesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LyricsTranslationCachesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LyricsTranslationCachesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> translatedText = const Value.absent(),
                Value<String> translatedLinesJson = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
              }) => LyricsTranslationCachesCompanion(
                id: id,
                cacheKey: cacheKey,
                languageCode: languageCode,
                translatedText: translatedText,
                translatedLinesJson: translatedLinesJson,
                provider: provider,
                updatedAtMillis: updatedAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cacheKey,
                required String languageCode,
                required String translatedText,
                required String translatedLinesJson,
                Value<String?> provider = const Value.absent(),
                required int updatedAtMillis,
              }) => LyricsTranslationCachesCompanion.insert(
                id: id,
                cacheKey: cacheKey,
                languageCode: languageCode,
                translatedText: translatedText,
                translatedLinesJson: translatedLinesJson,
                provider: provider,
                updatedAtMillis: updatedAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LyricsTranslationCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $LyricsTranslationCachesTable,
      LyricsTranslationCache,
      $$LyricsTranslationCachesTableFilterComposer,
      $$LyricsTranslationCachesTableOrderingComposer,
      $$LyricsTranslationCachesTableAnnotationComposer,
      $$LyricsTranslationCachesTableCreateCompanionBuilder,
      $$LyricsTranslationCachesTableUpdateCompanionBuilder,
      (
        LyricsTranslationCache,
        BaseReferences<
          _$MetadataDriftDatabase,
          $LyricsTranslationCachesTable,
          LyricsTranslationCache
        >,
      ),
      LyricsTranslationCache,
      PrefetchHooks Function()
    >;
typedef $$ArtistCachesTableCreateCompanionBuilder =
    ArtistCachesCompanion Function({
      Value<int> id,
      required String queryKey,
      Value<String?> artistId,
      Value<String?> artistName,
      Value<String?> sortName,
      Value<String?> disambiguation,
      Value<String?> country,
      Value<String?> imageFileTitle,
      Value<String?> imageUrl,
      Value<String?> thumbnailUrl,
      Value<String?> areaName,
      Value<String?> beginDate,
      Value<String?> endDate,
      Value<String?> tagsJson,
      Value<String?> rawSearchJson,
      Value<String?> rawDetailJson,
      required bool noData,
      required bool imageFetchCompleted,
      required int updatedAtMillis,
    });
typedef $$ArtistCachesTableUpdateCompanionBuilder =
    ArtistCachesCompanion Function({
      Value<int> id,
      Value<String> queryKey,
      Value<String?> artistId,
      Value<String?> artistName,
      Value<String?> sortName,
      Value<String?> disambiguation,
      Value<String?> country,
      Value<String?> imageFileTitle,
      Value<String?> imageUrl,
      Value<String?> thumbnailUrl,
      Value<String?> areaName,
      Value<String?> beginDate,
      Value<String?> endDate,
      Value<String?> tagsJson,
      Value<String?> rawSearchJson,
      Value<String?> rawDetailJson,
      Value<bool> noData,
      Value<bool> imageFetchCompleted,
      Value<int> updatedAtMillis,
    });

class $$ArtistCachesTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $ArtistCachesTable> {
  $$ArtistCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get queryKey => $composableBuilder(
    column: $table.queryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortName => $composableBuilder(
    column: $table.sortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get disambiguation => $composableBuilder(
    column: $table.disambiguation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageFileTitle => $composableBuilder(
    column: $table.imageFileTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaName => $composableBuilder(
    column: $table.areaName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beginDate => $composableBuilder(
    column: $table.beginDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawSearchJson => $composableBuilder(
    column: $table.rawSearchJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawDetailJson => $composableBuilder(
    column: $table.rawDetailJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get noData => $composableBuilder(
    column: $table.noData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get imageFetchCompleted => $composableBuilder(
    column: $table.imageFetchCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtistCachesTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $ArtistCachesTable> {
  $$ArtistCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get queryKey => $composableBuilder(
    column: $table.queryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortName => $composableBuilder(
    column: $table.sortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get disambiguation => $composableBuilder(
    column: $table.disambiguation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageFileTitle => $composableBuilder(
    column: $table.imageFileTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaName => $composableBuilder(
    column: $table.areaName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beginDate => $composableBuilder(
    column: $table.beginDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawSearchJson => $composableBuilder(
    column: $table.rawSearchJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawDetailJson => $composableBuilder(
    column: $table.rawDetailJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get noData => $composableBuilder(
    column: $table.noData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get imageFetchCompleted => $composableBuilder(
    column: $table.imageFetchCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtistCachesTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $ArtistCachesTable> {
  $$ArtistCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get queryKey =>
      $composableBuilder(column: $table.queryKey, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sortName =>
      $composableBuilder(column: $table.sortName, builder: (column) => column);

  GeneratedColumn<String> get disambiguation => $composableBuilder(
    column: $table.disambiguation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get imageFileTitle => $composableBuilder(
    column: $table.imageFileTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get areaName =>
      $composableBuilder(column: $table.areaName, builder: (column) => column);

  GeneratedColumn<String> get beginDate =>
      $composableBuilder(column: $table.beginDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get rawSearchJson => $composableBuilder(
    column: $table.rawSearchJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawDetailJson => $composableBuilder(
    column: $table.rawDetailJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get noData =>
      $composableBuilder(column: $table.noData, builder: (column) => column);

  GeneratedColumn<bool> get imageFetchCompleted => $composableBuilder(
    column: $table.imageFetchCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$ArtistCachesTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $ArtistCachesTable,
          ArtistCache,
          $$ArtistCachesTableFilterComposer,
          $$ArtistCachesTableOrderingComposer,
          $$ArtistCachesTableAnnotationComposer,
          $$ArtistCachesTableCreateCompanionBuilder,
          $$ArtistCachesTableUpdateCompanionBuilder,
          (
            ArtistCache,
            BaseReferences<
              _$MetadataDriftDatabase,
              $ArtistCachesTable,
              ArtistCache
            >,
          ),
          ArtistCache,
          PrefetchHooks Function()
        > {
  $$ArtistCachesTableTableManager(
    _$MetadataDriftDatabase db,
    $ArtistCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> queryKey = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String?> artistName = const Value.absent(),
                Value<String?> sortName = const Value.absent(),
                Value<String?> disambiguation = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> imageFileTitle = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> areaName = const Value.absent(),
                Value<String?> beginDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<String?> tagsJson = const Value.absent(),
                Value<String?> rawSearchJson = const Value.absent(),
                Value<String?> rawDetailJson = const Value.absent(),
                Value<bool> noData = const Value.absent(),
                Value<bool> imageFetchCompleted = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
              }) => ArtistCachesCompanion(
                id: id,
                queryKey: queryKey,
                artistId: artistId,
                artistName: artistName,
                sortName: sortName,
                disambiguation: disambiguation,
                country: country,
                imageFileTitle: imageFileTitle,
                imageUrl: imageUrl,
                thumbnailUrl: thumbnailUrl,
                areaName: areaName,
                beginDate: beginDate,
                endDate: endDate,
                tagsJson: tagsJson,
                rawSearchJson: rawSearchJson,
                rawDetailJson: rawDetailJson,
                noData: noData,
                imageFetchCompleted: imageFetchCompleted,
                updatedAtMillis: updatedAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String queryKey,
                Value<String?> artistId = const Value.absent(),
                Value<String?> artistName = const Value.absent(),
                Value<String?> sortName = const Value.absent(),
                Value<String?> disambiguation = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> imageFileTitle = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> areaName = const Value.absent(),
                Value<String?> beginDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<String?> tagsJson = const Value.absent(),
                Value<String?> rawSearchJson = const Value.absent(),
                Value<String?> rawDetailJson = const Value.absent(),
                required bool noData,
                required bool imageFetchCompleted,
                required int updatedAtMillis,
              }) => ArtistCachesCompanion.insert(
                id: id,
                queryKey: queryKey,
                artistId: artistId,
                artistName: artistName,
                sortName: sortName,
                disambiguation: disambiguation,
                country: country,
                imageFileTitle: imageFileTitle,
                imageUrl: imageUrl,
                thumbnailUrl: thumbnailUrl,
                areaName: areaName,
                beginDate: beginDate,
                endDate: endDate,
                tagsJson: tagsJson,
                rawSearchJson: rawSearchJson,
                rawDetailJson: rawDetailJson,
                noData: noData,
                imageFetchCompleted: imageFetchCompleted,
                updatedAtMillis: updatedAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtistCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $ArtistCachesTable,
      ArtistCache,
      $$ArtistCachesTableFilterComposer,
      $$ArtistCachesTableOrderingComposer,
      $$ArtistCachesTableAnnotationComposer,
      $$ArtistCachesTableCreateCompanionBuilder,
      $$ArtistCachesTableUpdateCompanionBuilder,
      (
        ArtistCache,
        BaseReferences<
          _$MetadataDriftDatabase,
          $ArtistCachesTable,
          ArtistCache
        >,
      ),
      ArtistCache,
      PrefetchHooks Function()
    >;
typedef $$ArtistImageCachesTableCreateCompanionBuilder =
    ArtistImageCachesCompanion Function({
      Value<int> id,
      required String artistId,
      required String imagePath,
      Value<String?> sourceUrl,
      Value<int?> width,
      Value<int?> height,
      required int updatedAtMillis,
    });
typedef $$ArtistImageCachesTableUpdateCompanionBuilder =
    ArtistImageCachesCompanion Function({
      Value<int> id,
      Value<String> artistId,
      Value<String> imagePath,
      Value<String?> sourceUrl,
      Value<int?> width,
      Value<int?> height,
      Value<int> updatedAtMillis,
    });

class $$ArtistImageCachesTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $ArtistImageCachesTable> {
  $$ArtistImageCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtistImageCachesTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $ArtistImageCachesTable> {
  $$ArtistImageCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtistImageCachesTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $ArtistImageCachesTable> {
  $$ArtistImageCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$ArtistImageCachesTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $ArtistImageCachesTable,
          ArtistImageCache,
          $$ArtistImageCachesTableFilterComposer,
          $$ArtistImageCachesTableOrderingComposer,
          $$ArtistImageCachesTableAnnotationComposer,
          $$ArtistImageCachesTableCreateCompanionBuilder,
          $$ArtistImageCachesTableUpdateCompanionBuilder,
          (
            ArtistImageCache,
            BaseReferences<
              _$MetadataDriftDatabase,
              $ArtistImageCachesTable,
              ArtistImageCache
            >,
          ),
          ArtistImageCache,
          PrefetchHooks Function()
        > {
  $$ArtistImageCachesTableTableManager(
    _$MetadataDriftDatabase db,
    $ArtistImageCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistImageCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistImageCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistImageCachesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> artistId = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
              }) => ArtistImageCachesCompanion(
                id: id,
                artistId: artistId,
                imagePath: imagePath,
                sourceUrl: sourceUrl,
                width: width,
                height: height,
                updatedAtMillis: updatedAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String artistId,
                required String imagePath,
                Value<String?> sourceUrl = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required int updatedAtMillis,
              }) => ArtistImageCachesCompanion.insert(
                id: id,
                artistId: artistId,
                imagePath: imagePath,
                sourceUrl: sourceUrl,
                width: width,
                height: height,
                updatedAtMillis: updatedAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtistImageCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $ArtistImageCachesTable,
      ArtistImageCache,
      $$ArtistImageCachesTableFilterComposer,
      $$ArtistImageCachesTableOrderingComposer,
      $$ArtistImageCachesTableAnnotationComposer,
      $$ArtistImageCachesTableCreateCompanionBuilder,
      $$ArtistImageCachesTableUpdateCompanionBuilder,
      (
        ArtistImageCache,
        BaseReferences<
          _$MetadataDriftDatabase,
          $ArtistImageCachesTable,
          ArtistImageCache
        >,
      ),
      ArtistImageCache,
      PrefetchHooks Function()
    >;
typedef $$ArtworkCachesTableCreateCompanionBuilder =
    ArtworkCachesCompanion Function({
      Value<int> id,
      required String md5,
      Value<String?> artworkPath,
      Value<String?> thumbnailPath,
      Value<int?> artworkWidth,
      Value<int?> artworkHeight,
      Value<Uint8List?> themeColorsBlob,
      required int updatedAtMillis,
    });
typedef $$ArtworkCachesTableUpdateCompanionBuilder =
    ArtworkCachesCompanion Function({
      Value<int> id,
      Value<String> md5,
      Value<String?> artworkPath,
      Value<String?> thumbnailPath,
      Value<int?> artworkWidth,
      Value<int?> artworkHeight,
      Value<Uint8List?> themeColorsBlob,
      Value<int> updatedAtMillis,
    });

class $$ArtworkCachesTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $ArtworkCachesTable> {
  $$ArtworkCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get md5 => $composableBuilder(
    column: $table.md5,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get artworkWidth => $composableBuilder(
    column: $table.artworkWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get artworkHeight => $composableBuilder(
    column: $table.artworkHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get themeColorsBlob => $composableBuilder(
    column: $table.themeColorsBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtworkCachesTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $ArtworkCachesTable> {
  $$ArtworkCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get md5 => $composableBuilder(
    column: $table.md5,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get artworkWidth => $composableBuilder(
    column: $table.artworkWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get artworkHeight => $composableBuilder(
    column: $table.artworkHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get themeColorsBlob => $composableBuilder(
    column: $table.themeColorsBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtworkCachesTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $ArtworkCachesTable> {
  $$ArtworkCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get md5 =>
      $composableBuilder(column: $table.md5, builder: (column) => column);

  GeneratedColumn<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get artworkWidth => $composableBuilder(
    column: $table.artworkWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get artworkHeight => $composableBuilder(
    column: $table.artworkHeight,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get themeColorsBlob => $composableBuilder(
    column: $table.themeColorsBlob,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$ArtworkCachesTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $ArtworkCachesTable,
          ArtworkCache,
          $$ArtworkCachesTableFilterComposer,
          $$ArtworkCachesTableOrderingComposer,
          $$ArtworkCachesTableAnnotationComposer,
          $$ArtworkCachesTableCreateCompanionBuilder,
          $$ArtworkCachesTableUpdateCompanionBuilder,
          (
            ArtworkCache,
            BaseReferences<
              _$MetadataDriftDatabase,
              $ArtworkCachesTable,
              ArtworkCache
            >,
          ),
          ArtworkCache,
          PrefetchHooks Function()
        > {
  $$ArtworkCachesTableTableManager(
    _$MetadataDriftDatabase db,
    $ArtworkCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtworkCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtworkCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtworkCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> md5 = const Value.absent(),
                Value<String?> artworkPath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> artworkWidth = const Value.absent(),
                Value<int?> artworkHeight = const Value.absent(),
                Value<Uint8List?> themeColorsBlob = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
              }) => ArtworkCachesCompanion(
                id: id,
                md5: md5,
                artworkPath: artworkPath,
                thumbnailPath: thumbnailPath,
                artworkWidth: artworkWidth,
                artworkHeight: artworkHeight,
                themeColorsBlob: themeColorsBlob,
                updatedAtMillis: updatedAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String md5,
                Value<String?> artworkPath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> artworkWidth = const Value.absent(),
                Value<int?> artworkHeight = const Value.absent(),
                Value<Uint8List?> themeColorsBlob = const Value.absent(),
                required int updatedAtMillis,
              }) => ArtworkCachesCompanion.insert(
                id: id,
                md5: md5,
                artworkPath: artworkPath,
                thumbnailPath: thumbnailPath,
                artworkWidth: artworkWidth,
                artworkHeight: artworkHeight,
                themeColorsBlob: themeColorsBlob,
                updatedAtMillis: updatedAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtworkCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $ArtworkCachesTable,
      ArtworkCache,
      $$ArtworkCachesTableFilterComposer,
      $$ArtworkCachesTableOrderingComposer,
      $$ArtworkCachesTableAnnotationComposer,
      $$ArtworkCachesTableCreateCompanionBuilder,
      $$ArtworkCachesTableUpdateCompanionBuilder,
      (
        ArtworkCache,
        BaseReferences<
          _$MetadataDriftDatabase,
          $ArtworkCachesTable,
          ArtworkCache
        >,
      ),
      ArtworkCache,
      PrefetchHooks Function()
    >;
typedef $$RemoteSongsTableCreateCompanionBuilder =
    RemoteSongsCompanion Function({
      Value<int> id,
      required String serverId,
      required String remoteId,
      required String virtualUri,
      Value<String?> title,
      Value<String?> album,
      Value<String?> artist,
      Value<int?> duration,
      Value<String?> artworkPath,
      Value<String?> thumbnailPath,
      Value<int?> artworkWidth,
      Value<int?> artworkHeight,
      Value<int?> trackNumber,
      Value<Uint8List?> themeColorsBlob,
      Value<Uint8List?> waveformBlob,
      Value<String?> coverArtId,
      Value<String?> suffix,
      Value<int?> bitRate,
      Value<String?> cachedFilePath,
      Value<int?> createdAt,
      Value<int?> updatedAt,
      Value<int?> deletedAt,
    });
typedef $$RemoteSongsTableUpdateCompanionBuilder =
    RemoteSongsCompanion Function({
      Value<int> id,
      Value<String> serverId,
      Value<String> remoteId,
      Value<String> virtualUri,
      Value<String?> title,
      Value<String?> album,
      Value<String?> artist,
      Value<int?> duration,
      Value<String?> artworkPath,
      Value<String?> thumbnailPath,
      Value<int?> artworkWidth,
      Value<int?> artworkHeight,
      Value<int?> trackNumber,
      Value<Uint8List?> themeColorsBlob,
      Value<Uint8List?> waveformBlob,
      Value<String?> coverArtId,
      Value<String?> suffix,
      Value<int?> bitRate,
      Value<String?> cachedFilePath,
      Value<int?> createdAt,
      Value<int?> updatedAt,
      Value<int?> deletedAt,
    });

class $$RemoteSongsTableFilterComposer
    extends Composer<_$MetadataDriftDatabase, $RemoteSongsTable> {
  $$RemoteSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get virtualUri => $composableBuilder(
    column: $table.virtualUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get artworkWidth => $composableBuilder(
    column: $table.artworkWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get artworkHeight => $composableBuilder(
    column: $table.artworkHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get themeColorsBlob => $composableBuilder(
    column: $table.themeColorsBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get waveformBlob => $composableBuilder(
    column: $table.waveformBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suffix => $composableBuilder(
    column: $table.suffix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitRate => $composableBuilder(
    column: $table.bitRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachedFilePath => $composableBuilder(
    column: $table.cachedFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemoteSongsTableOrderingComposer
    extends Composer<_$MetadataDriftDatabase, $RemoteSongsTable> {
  $$RemoteSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get virtualUri => $composableBuilder(
    column: $table.virtualUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get artworkWidth => $composableBuilder(
    column: $table.artworkWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get artworkHeight => $composableBuilder(
    column: $table.artworkHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get themeColorsBlob => $composableBuilder(
    column: $table.themeColorsBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get waveformBlob => $composableBuilder(
    column: $table.waveformBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suffix => $composableBuilder(
    column: $table.suffix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitRate => $composableBuilder(
    column: $table.bitRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachedFilePath => $composableBuilder(
    column: $table.cachedFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemoteSongsTableAnnotationComposer
    extends Composer<_$MetadataDriftDatabase, $RemoteSongsTable> {
  $$RemoteSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get virtualUri => $composableBuilder(
    column: $table.virtualUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get artworkWidth => $composableBuilder(
    column: $table.artworkWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get artworkHeight => $composableBuilder(
    column: $table.artworkHeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get themeColorsBlob => $composableBuilder(
    column: $table.themeColorsBlob,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get waveformBlob => $composableBuilder(
    column: $table.waveformBlob,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverArtId => $composableBuilder(
    column: $table.coverArtId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suffix =>
      $composableBuilder(column: $table.suffix, builder: (column) => column);

  GeneratedColumn<int> get bitRate =>
      $composableBuilder(column: $table.bitRate, builder: (column) => column);

  GeneratedColumn<String> get cachedFilePath => $composableBuilder(
    column: $table.cachedFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$RemoteSongsTableTableManager
    extends
        RootTableManager<
          _$MetadataDriftDatabase,
          $RemoteSongsTable,
          RemoteSong,
          $$RemoteSongsTableFilterComposer,
          $$RemoteSongsTableOrderingComposer,
          $$RemoteSongsTableAnnotationComposer,
          $$RemoteSongsTableCreateCompanionBuilder,
          $$RemoteSongsTableUpdateCompanionBuilder,
          (
            RemoteSong,
            BaseReferences<
              _$MetadataDriftDatabase,
              $RemoteSongsTable,
              RemoteSong
            >,
          ),
          RemoteSong,
          PrefetchHooks Function()
        > {
  $$RemoteSongsTableTableManager(
    _$MetadataDriftDatabase db,
    $RemoteSongsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<String> remoteId = const Value.absent(),
                Value<String> virtualUri = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<String?> artworkPath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> artworkWidth = const Value.absent(),
                Value<int?> artworkHeight = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<Uint8List?> themeColorsBlob = const Value.absent(),
                Value<Uint8List?> waveformBlob = const Value.absent(),
                Value<String?> coverArtId = const Value.absent(),
                Value<String?> suffix = const Value.absent(),
                Value<int?> bitRate = const Value.absent(),
                Value<String?> cachedFilePath = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
              }) => RemoteSongsCompanion(
                id: id,
                serverId: serverId,
                remoteId: remoteId,
                virtualUri: virtualUri,
                title: title,
                album: album,
                artist: artist,
                duration: duration,
                artworkPath: artworkPath,
                thumbnailPath: thumbnailPath,
                artworkWidth: artworkWidth,
                artworkHeight: artworkHeight,
                trackNumber: trackNumber,
                themeColorsBlob: themeColorsBlob,
                waveformBlob: waveformBlob,
                coverArtId: coverArtId,
                suffix: suffix,
                bitRate: bitRate,
                cachedFilePath: cachedFilePath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String serverId,
                required String remoteId,
                required String virtualUri,
                Value<String?> title = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<String?> artworkPath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> artworkWidth = const Value.absent(),
                Value<int?> artworkHeight = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<Uint8List?> themeColorsBlob = const Value.absent(),
                Value<Uint8List?> waveformBlob = const Value.absent(),
                Value<String?> coverArtId = const Value.absent(),
                Value<String?> suffix = const Value.absent(),
                Value<int?> bitRate = const Value.absent(),
                Value<String?> cachedFilePath = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
              }) => RemoteSongsCompanion.insert(
                id: id,
                serverId: serverId,
                remoteId: remoteId,
                virtualUri: virtualUri,
                title: title,
                album: album,
                artist: artist,
                duration: duration,
                artworkPath: artworkPath,
                thumbnailPath: thumbnailPath,
                artworkWidth: artworkWidth,
                artworkHeight: artworkHeight,
                trackNumber: trackNumber,
                themeColorsBlob: themeColorsBlob,
                waveformBlob: waveformBlob,
                coverArtId: coverArtId,
                suffix: suffix,
                bitRate: bitRate,
                cachedFilePath: cachedFilePath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemoteSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$MetadataDriftDatabase,
      $RemoteSongsTable,
      RemoteSong,
      $$RemoteSongsTableFilterComposer,
      $$RemoteSongsTableOrderingComposer,
      $$RemoteSongsTableAnnotationComposer,
      $$RemoteSongsTableCreateCompanionBuilder,
      $$RemoteSongsTableUpdateCompanionBuilder,
      (
        RemoteSong,
        BaseReferences<_$MetadataDriftDatabase, $RemoteSongsTable, RemoteSong>,
      ),
      RemoteSong,
      PrefetchHooks Function()
    >;

class $MetadataDriftDatabaseManager {
  final _$MetadataDriftDatabase _db;
  $MetadataDriftDatabaseManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$SongRootsTableTableManager get songRoots =>
      $$SongRootsTableTableManager(_db, _db.songRoots);
  $$SongPlayHistoriesTableTableManager get songPlayHistories =>
      $$SongPlayHistoriesTableTableManager(_db, _db.songPlayHistories);
  $$LyricsCachesTableTableManager get lyricsCaches =>
      $$LyricsCachesTableTableManager(_db, _db.lyricsCaches);
  $$AcoustidCachesTableTableManager get acoustidCaches =>
      $$AcoustidCachesTableTableManager(_db, _db.acoustidCaches);
  $$ReleaseCoverCachesTableTableManager get releaseCoverCaches =>
      $$ReleaseCoverCachesTableTableManager(_db, _db.releaseCoverCaches);
  $$LyricsTranslationCachesTableTableManager get lyricsTranslationCaches =>
      $$LyricsTranslationCachesTableTableManager(
        _db,
        _db.lyricsTranslationCaches,
      );
  $$ArtistCachesTableTableManager get artistCaches =>
      $$ArtistCachesTableTableManager(_db, _db.artistCaches);
  $$ArtistImageCachesTableTableManager get artistImageCaches =>
      $$ArtistImageCachesTableTableManager(_db, _db.artistImageCaches);
  $$ArtworkCachesTableTableManager get artworkCaches =>
      $$ArtworkCachesTableTableManager(_db, _db.artworkCaches);
  $$RemoteSongsTableTableManager get remoteSongs =>
      $$RemoteSongsTableTableManager(_db, _db.remoteSongs);
}
