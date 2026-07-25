import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MethodChannel, RootIsolateToken, BackgroundIsolateBinaryMessenger;
import 'package:audio_core/audio_core.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/scanner/scanner_path_utils.dart';
import 'package:vynody/player/metadata/artwork_constants.dart';
import 'package:flutter_taglib/flutter_taglib.dart' as taglib;
import 'package:on_audio_query/on_audio_query.dart';

Future<Map<String, dynamic>?> _buildArtworkFiles({
  required String songPath,
  required Uint8List data,
  required String supportDirPath,
  required bool saveLarge,
  int thumbnailSize = vynodyArtworkThumbnailSize,
}) async {
  try {
    final result = await generateTrackArtwork(
      path: songPath,
      artworkBytes: data,
      cacheRootPath: supportDirPath,
      saveLargeArtwork: saveLarge,
      thumbnailSize: thumbnailSize,
      meshStylePreset: MeshStylePreset.stable.index,
      hueCohesion: 0.0,
      paletteBlurRadius: 5.0,
      meshMuddyPenaltyMultiplier: 1.0,
      meshPopulationStrength: 1.0,
      meshContrastStrength: 1.0,
      meshHarmonyStrength: 1.0,
      meshVibrancyStrength: 1.0,
    );
    return {
      'artworkPath': result.artworkPath,
      'thumbnailPath': result.thumbnailPath,
      'width': result.artworkWidth,
      'height': result.artworkHeight,
      'themeColorsBlob': result.themeColorsBlob,
    };
  } catch (e) {
    debugPrint('Error building artwork files via Rust: $e');
    return null;
  }
}

/// Supported file extensions for writing metadata
const Set<String> writableMetadataExtensions = {
  '.mp3',
  '.m4a',
  '.mp4',
  '.flac',
  '.wav',
};

/// Unsupported file extensions (OGG, Opus, etc.)
const Set<String> unsupportedMetadataExtensions = {'.ogg', '.opus'};

/// Checks if a file extension supports writing metadata
bool isMetadataWritable(String filePath) {
  final ext = p.extension(filePath).toLowerCase();
  return writableMetadataExtensions.contains(ext);
}

/// Result of saving metadata to file
class SaveMetadataResult {
  final bool success;
  final String? error;
  final int unsupportedCount;
  final int savedCount;
  final List<String> unsupportedFiles;

  SaveMetadataResult({
    required this.success,
    this.error,
    this.unsupportedCount = 0,
    this.savedCount = 0,
    this.unsupportedFiles = const [],
  });
}

class MetadataHelper {
  /// Stores the last error message during metadata saving.
  static String? lastWriteError;

  static String _resolveText(String? value, String fallback) {
    if (value == null) return fallback;
    return value.trim();
  }

  static Future<bool> _writeSelectionMetadataToFile({
    required String filePath,
    required SongMetadata metadata,
    Uint8List? artworkBytes,
    String? lyrics,
    List<TrackMetadataPicture>? pictures,
    String? fallbackMediaUri,
    bool clearTrackNumber = false,
  }) async {
    lastWriteError = null;
    if (!isMetadataWritable(filePath)) {
      lastWriteError = 'File format is not supported for writing metadata';
      debugPrint('[MetadataHelper] $lastWriteError');
      return false;
    }

    final controller = AudioCoreController();
    if (!controller.isInitialized) {
      try {
        await controller.initialize();
      } catch (e) {
        debugPrint('Failed to initialize audio core for metadata write: $e');
        lastWriteError = 'Failed to initialize audio core: $e';
      }
    }

    final isArtworkCleared = artworkBytes != null && artworkBytes.isEmpty;
    final update = TrackMetadataUpdate(
      title: metadata.title,
      artist: metadata.artist,
      album: metadata.album,
      trackNumber: metadata.trackNumber,
      genres: metadata.genres ?? const <String>[],
      lyrics: lyrics,
      clearArtwork: isArtworkCleared,
      clearTrackNumber: clearTrackNumber,
      pictures:
          pictures ??
          (artworkBytes == null || artworkBytes.isEmpty
              ? const <TrackMetadataPicture>[]
              : <TrackMetadataPicture>[
                   TrackMetadataPicture(
                     bytes: artworkBytes,
                     mimeType: 'image/jpeg',
                     pictureType: 'Front Cover',
                   ),
                 ]),
    );

    try {
      final results = await controller.updateMetadataBatch([
        TrackMetadataWriteRequest(
          path: filePath,
          metadata: update,
          fallbackMediaUri: fallbackMediaUri,
        ),
      ]);
      final success = results.isNotEmpty && results.first;
      if (!success) {
        lastWriteError = taglib.TagLibFile.lastError ?? 'Native updateMetadataBatch operation returned false';
        debugPrint('[MetadataHelper] Save failed: $lastWriteError');
      }
      return success;
    } catch (e) {
      debugPrint('Failed to write selection metadata to file $filePath: $e');
      lastWriteError = e.toString();
      return false;
    }
  }

  static Future<(SongMetadata, Uint8List?)?> saveSelectedSongMetadata({
    required String filePath,
    required String title,
    required String artist,
    required String album,
    int? duration,
    int? trackNumber,
    bool clearTrackNumber = false,
    List<String>? genres,
    Uint8List? artworkBytes,
    String? artworkPath,
    String? thumbnailPath,
    int? artworkWidth,
    int? artworkHeight,
    SongMetadata? existingMetadata,
    bool writeToFile = true,
    String? fallbackMediaUri,
  }) async {
    try {
      final db = MetadataDatabase();
      final dbRecord = await db.getSongMetadata(filePath);
      final existing = dbRecord ?? existingMetadata;
      final now = DateTime.now().millisecondsSinceEpoch;

      var resolvedArtworkPath = artworkPath ?? existing?.artworkPath;
      var resolvedThumbnailPath = thumbnailPath ?? existing?.thumbnailPath;
      var resolvedArtworkWidth = artworkWidth ?? existing?.artworkWidth;
      var resolvedArtworkHeight = artworkHeight ?? existing?.artworkHeight;
      Uint8List? themeColorsBlob = existing?.themeColorsBlob;

      final isArtworkCleared = artworkBytes != null && artworkBytes.isEmpty;

      if (isArtworkCleared) {
        if (existing?.artworkPath != null && existing!.artworkPath!.isNotEmpty) {
          final oldArtworkFile = File(existing.artworkPath!);
          if (oldArtworkFile.existsSync()) {
            try {
              oldArtworkFile.deleteSync();
            } catch (e) {
              debugPrint('Error deleting old artwork file: $e');
            }
          }
        }
        if (existing?.thumbnailPath != null && existing!.thumbnailPath!.isNotEmpty) {
          final oldThumbnailFile = File(existing.thumbnailPath!);
          if (oldThumbnailFile.existsSync()) {
            try {
              oldThumbnailFile.deleteSync();
            } catch (e) {
              debugPrint('Error deleting old thumbnail file: $e');
            }
          }
        }
        resolvedArtworkPath = null;
        resolvedThumbnailPath = null;
        resolvedArtworkWidth = null;
        resolvedArtworkHeight = null;
        themeColorsBlob = null;
      }

      final needsArtworkSave =
          artworkBytes != null &&
          artworkBytes.isNotEmpty &&
          artworkPath == null &&
          thumbnailPath == null &&
          artworkWidth == null &&
          artworkHeight == null;

       if (needsArtworkSave) {
        if (existing?.artworkPath != null && existing!.artworkPath!.isNotEmpty) {
          final oldArtworkFile = File(existing.artworkPath!);
          if (oldArtworkFile.existsSync()) {
            try {
              oldArtworkFile.deleteSync();
            } catch (e) {
              debugPrint('Error deleting old artwork file: $e');
            }
          }
        }

        final supportDir = await getApplicationSupportDirectory();
        final artworkInfo = await _buildArtworkFiles(
          songPath: filePath,
          data: artworkBytes,
          supportDirPath: supportDir.path,
          saveLarge: !writeToFile,
        );

        if (artworkInfo != null) {
          resolvedArtworkPath = artworkInfo['artworkPath'] as String?;
          resolvedThumbnailPath = artworkInfo['thumbnailPath'] as String?;
          resolvedArtworkWidth = artworkInfo['width'] as int?;
          resolvedArtworkHeight = artworkInfo['height'] as int?;
          themeColorsBlob = artworkInfo['themeColorsBlob'] as Uint8List?;
        } else {
          debugPrint('Failed to save artwork for selected metadata $filePath');
        }
      }


      int? resolvedSourceFlags = existing?.sourceFlags;
      try {
        final prefs = await SharedPreferences.getInstance();
        final roots = prefs.getStringList('root_paths') ?? [];
        bool isInsideRoot = false;
        for (final root in roots) {
          if (ScannerPathUtils.pathContains(root, filePath)) {
            isInsideRoot = true;
            break;
          }
        }
        if (isInsideRoot) {
          if (resolvedSourceFlags == null) {
            resolvedSourceFlags = SongSourceFlags.rootScan;
          } else {
            resolvedSourceFlags = (resolvedSourceFlags & ~SongSourceFlags.external) | SongSourceFlags.rootScan;
          }
        } else if (resolvedSourceFlags == null) {
          resolvedSourceFlags = SongSourceFlags.external;
        }
      } catch (_) {
        resolvedSourceFlags ??= SongSourceFlags.external;
      }

      final base =
          existing ??
          SongMetadata(
            path: filePath,
            title: p.basenameWithoutExtension(filePath),
            album: 'Unknown Album',
            artist: 'Unknown Artist',
            sourceFlags: resolvedSourceFlags,
          );

      var updated = base.copyWith(
        title: _resolveText(title, base.title),
        artist: _resolveText(artist, base.artist),
        album: _resolveText(album, base.album),
        duration: duration ?? base.duration,
        trackNumber: clearTrackNumber ? null : (trackNumber ?? base.trackNumber),
        artworkPath: resolvedArtworkPath,
        thumbnailPath: resolvedThumbnailPath,
        artworkWidth: resolvedArtworkWidth,
        artworkHeight: resolvedArtworkHeight,
        themeColorsBlob: themeColorsBlob,
        lastModifiedTime: now,
        metadataTextScanned: now,
        metadataImgScanned: artworkBytes != null
            ? now
            : base.metadataImgScanned,
        createdAt: base.createdAt ??
            (File(filePath).existsSync()
                ? File(filePath).lastModifiedSync().millisecondsSinceEpoch
                : now),
        genres: genres ?? base.genres,
        isAppModified: true,
        sourceFlags: resolvedSourceFlags,
      );

      if (writeToFile) {
        final fileUpdated = await _writeSelectionMetadataToFile(
          filePath: filePath,
          metadata: updated,
          artworkBytes: artworkBytes,
          fallbackMediaUri: fallbackMediaUri,
          clearTrackNumber: clearTrackNumber,
        );

        if (!fileUpdated) {
          return null;
        }

        final mtime = File(filePath).lastModifiedSync().millisecondsSinceEpoch;
        updated = updated.copyWith(
          lastModifiedTime: mtime,
          createdAt: mtime,
          isAppModified: false,
        );
      }

      await db.insertOrUpdateSong(updated);
      return (updated, artworkBytes);
    } catch (e) {
      debugPrint('Error saving selected metadata for $filePath: $e');
      return null;
    }
  }

  /// Writes current database metadata and cached artwork of the song back to the physical audio file,
  /// and resets the `isModified` flag in the database.
  static Future<bool> saveDatabaseMetadataToFile(String filePath, {String? fallbackMediaUri}) async {
    try {
      final db = MetadataDatabase();
      final metadata = await db.getSongMetadata(filePath);
      if (metadata == null) {
        debugPrint('[MetadataHelper] Cannot save to file: No database metadata found for $filePath');
        return false;
      }

      Uint8List? artworkBytes;
      if (metadata.artworkPath != null && metadata.artworkPath!.isNotEmpty) {
        final artworkFile = File(metadata.artworkPath!);
        if (await artworkFile.exists()) {
          artworkBytes = await artworkFile.readAsBytes();
        }
      }

      // If we don't have artworkBytes locally but we have a thumbnail, we can fall back to the thumbnail
      if (artworkBytes == null && metadata.thumbnailPath != null && metadata.thumbnailPath!.isNotEmpty) {
        final thumbnailFile = File(metadata.thumbnailPath!);
        if (await thumbnailFile.exists()) {
          artworkBytes = await thumbnailFile.readAsBytes();
        }
      }

      final success = await _writeSelectionMetadataToFile(
        filePath: filePath,
        metadata: metadata,
        artworkBytes: artworkBytes,
        fallbackMediaUri: fallbackMediaUri,
      );

      if (success) {
        final mtime = File(filePath).lastModifiedSync().millisecondsSinceEpoch;
        var updated = metadata.copyWith(
          lastModifiedTime: mtime,
          createdAt: mtime,
          isAppModified: false,
        );

        if (metadata.artworkPath != null && metadata.artworkPath!.isNotEmpty) {
          final artworkFile = File(metadata.artworkPath!);
          if (await artworkFile.exists()) {
            try {
              await artworkFile.delete();
              updated = updated.copyWith(artworkPath: null);
            } catch (e) {
              debugPrint('[MetadataHelper] Error deleting old artwork file: $e');
            }
          }
        }

        await db.insertOrUpdateSong(updated);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[MetadataHelper] Error saving database metadata to file for $filePath: $e');
      return false;
    }
  }

  static const Set<String> validCoverExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.bmp',
    '.gif',
  };

  static final Map<String, String?> _globalDirCoverCache = {};

  /// Searches for cover.xxx (case-insensitive) in the same directory as songPath
  static String? findDirectoryCover(
    String songPath, {
    Map<String, String?>? dirCache,
  }) {
    final dirPath = p.dirname(songPath);
    if (dirCache != null && dirCache.containsKey(dirPath)) {
      return dirCache[dirPath];
    }
    if (_globalDirCoverCache.containsKey(dirPath)) {
      final cachedResult = _globalDirCoverCache[dirPath];
      if (dirCache != null) {
        dirCache[dirPath] = cachedResult;
      }
      return cachedResult;
    }

    String? result;
    try {
      // 1. Fast path: test common candidate file names directly to avoid expensive directory listing
      const candidateNames = [
        'cover.jpg',
        'cover.png',
        'cover.jpeg',
        'cover.webp',
        'folder.jpg',
        'folder.png',
      ];
      bool candidateFound = false;
      for (final name in candidateNames) {
        if (File(p.join(dirPath, name)).existsSync()) {
          candidateFound = true;
          break;
        }
      }

      // 2. Only list directory if candidate check found a potential cover file or as a fallback
      if (candidateFound) {
        final dir = Directory(dirPath);
        if (dir.existsSync()) {
          final entries = dir.listSync(followLinks: false);
          for (final entry in entries) {
            if (entry is File) {
              final baseName =
                  p.basenameWithoutExtension(entry.path).toLowerCase();
              final ext = p.extension(entry.path).toLowerCase();
              if ((baseName == 'cover' || baseName == 'folder') &&
                  validCoverExtensions.contains(ext)) {
                result = entry.path;
                break;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('findDirectoryCover error for $dirPath: $e');
    }

    _globalDirCoverCache[dirPath] = result;
    if (dirCache != null) {
      dirCache[dirPath] = result;
    }
    return result;
  }

  /// 深度解析音频文件的元数据和封面信息
  ///
  /// 该方法耗时较长，通常在后台线程（Isolate）中执行，结果会存入数据库以便下次秒开。
  static Future<(SongMetadata, Uint8List?)?> processMetadata(
    String filePath, {
    int? songId,
    bool generateThumbnail = true,
    bool forceRefresh = false,
    int? sourceFlags,
    Map<String, String?>? dirCache,
  }) async {
    final db = MetadataDatabase();
    final file = File(filePath);
    if (!await file.exists()) {
      debugPrint('processMetadata skipped, file missing: $filePath');
      return null;
    }
    final lastModified = (await file.lastModified()).millisecondsSinceEpoch;

    // 1. 如果数据库已有记录且已被修改尚未保存，或者修改时间相同，直接返回
    final existing = await db.getSongMetadata(filePath);
    if (!forceRefresh && existing != null && existing.isModified) {
      return (existing, null);
    }
    if (!forceRefresh &&
        existing != null &&
        existing.lastModifiedTime == lastModified) {
      final hasArtwork =
          (existing.artworkPath?.isNotEmpty ?? false) ||
          (existing.thumbnailPath?.isNotEmpty ?? false);
      final hasImageScanned = existing.metadataImgScanned == lastModified;
      final dirCover = findDirectoryCover(filePath, dirCache: dirCache);
      final hasDirCover = dirCover != null;
      if (!generateThumbnail || hasArtwork || (hasImageScanned && !hasDirCover)) {
        return (existing, null);
      }
    }

    try {
      final existingArtworkPath = existing?.artworkPath;
      final existingThumbnailPath = existing?.thumbnailPath;
      final existingArtworkWidth = existing?.artworkWidth;
      final existingArtworkHeight = existing?.artworkHeight;
      final existingThemeColorsBlob = existing?.themeColorsBlob;
      Uint8List? artworkData;
      String? title;
      String? album;
      String? artist;
      int? duration;
      int? trackNumber;

      try {
        // 2. 在 Isolate 中读取文件标签；只有需要缩略图时才取封面字节
        final metadata = await compute(
          generateThumbnail
              ? _readMetadataWithImageIsolateEntryPoint
              : _readMetadataIsolateEntryPoint,
          <String, dynamic>{
            'path': filePath,
            'token': RootIsolateToken.instance,
          },
        );
        title = metadata.title;
        album = metadata.album;
        artist = metadata.artist;
        duration = metadata.duration?.inMilliseconds;
        trackNumber = metadata.trackNumber;
        artworkData = metadata.pictures.isNotEmpty
            ? metadata.pictures.first.bytes
            : null;
      } catch (e) {
        debugPrint('TagLib read error for $filePath: $e');
      }

      String? artworkPath;
      String? thumbnailPath;
      int? artworkWidth;
      int? artworkHeight;
      Uint8List? themeColorsBlob;

      if (artworkData != null && generateThumbnail) {
        // 3. 处理封面图：保存原始大图并生成缩略图
        // Windows 下仅生成缩略图，不存大图
        final artworkInfo = await saveArtworkAndThumbnail(
          filePath,
          artworkData,
          saveLarge: false,
        );

        artworkPath = artworkInfo?['artworkPath'] as String?;
        thumbnailPath = artworkInfo?['thumbnailPath'] as String?;
        artworkWidth = artworkInfo?['width'] as int?;
        artworkHeight = artworkInfo?['height'] as int?;
        themeColorsBlob = artworkInfo?['themeColorsBlob'] as Uint8List?;
      } else if (generateThumbnail) {
        final coverPath = findDirectoryCover(filePath, dirCache: dirCache);
        if (coverPath != null) {
          try {
            final coverBytes = await File(coverPath).readAsBytes();
            if (coverBytes.isNotEmpty) {
              final artworkInfo = await saveArtworkAndThumbnail(
                filePath,
                coverBytes,
                saveLarge: false,
              );

              artworkPath = artworkInfo?['artworkPath'] as String?;
              thumbnailPath = artworkInfo?['thumbnailPath'] as String?;
              artworkWidth = artworkInfo?['width'] as int?;
              artworkHeight = artworkInfo?['height'] as int?;
              themeColorsBlob = artworkInfo?['themeColorsBlob'] as Uint8List?;
            }
          } catch (e) {
            debugPrint('Failed to process directory cover $coverPath: $e');
          }
        } else if (Platform.isAndroid && songId != null) {
          try {
            final queryBytes = await OnAudioQuery().queryArtwork(
              songId,
              ArtworkType.AUDIO,
              size: 800,
            );
            if (queryBytes != null && queryBytes.isNotEmpty) {
              final artworkInfo = await saveArtworkAndThumbnail(
                filePath,
                queryBytes,
                saveLarge: false,
              );

              artworkPath = artworkInfo?['artworkPath'] as String?;
              thumbnailPath = artworkInfo?['thumbnailPath'] as String?;
              artworkWidth = artworkInfo?['width'] as int?;
              artworkHeight = artworkInfo?['height'] as int?;
              themeColorsBlob = artworkInfo?['themeColorsBlob'] as Uint8List?;
            }
          } catch (e) {
            debugPrint('Failed to fetch system artwork via OnAudioQuery for $songId: $e');
          }
        }
      } else if (!generateThumbnail && existing != null) {
        artworkPath = existingArtworkPath;
        thumbnailPath = existingThumbnailPath;
        artworkWidth = existingArtworkWidth;
        artworkHeight = existingArtworkHeight;
        themeColorsBlob = existingThemeColorsBlob;
      }

      // 如果是更新现有记录，保留原有的 createdAt；否则使用当前时间
      final createdAt =
          existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch;

      int? resolvedSourceFlags = sourceFlags ?? existing?.sourceFlags;
      try {
        final prefs = await SharedPreferences.getInstance();
        final roots = prefs.getStringList('root_paths') ?? [];
        bool isInsideRoot = false;
        for (final root in roots) {
          if (ScannerPathUtils.pathContains(root, filePath)) {
            isInsideRoot = true;
            break;
          }
        }
        if (isInsideRoot) {
          if (resolvedSourceFlags == null) {
            resolvedSourceFlags = SongSourceFlags.rootScan;
          } else {
            resolvedSourceFlags = (resolvedSourceFlags & ~SongSourceFlags.external) | SongSourceFlags.rootScan;
          }
        } else if (resolvedSourceFlags == null) {
          resolvedSourceFlags = SongSourceFlags.external;
        }
      } catch (_) {
        resolvedSourceFlags ??= SongSourceFlags.external;
      }

      final song = SongMetadata(
        path: filePath,
        title: title ?? p.basenameWithoutExtension(filePath),
        album: album ?? 'Unknown Album',
        artist: artist ?? 'Unknown Artist',
        duration: duration,
        artworkPath: artworkPath,
        thumbnailPath: thumbnailPath,
        artworkWidth: artworkWidth,
        artworkHeight: artworkHeight,
        trackNumber: trackNumber,
        themeColorsBlob: themeColorsBlob,
        lastModifiedTime: lastModified,
        metadataTextScanned: lastModified,
        metadataImgScanned: generateThumbnail
            ? lastModified
            : existing?.metadataImgScanned,
        createdAt: createdAt,
        sourceFlags: resolvedSourceFlags,
        isAppModified: existing?.isAppModified ?? false,
      );

      // 5. 将解析结果存入数据库
      await db.insertOrUpdateSong(song);
      return (song, artworkData);
    } catch (e) {
      debugPrint('Error processing metadata for $filePath: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> saveArtworkAndThumbnail(
    String songPath,
    Uint8List data, {
    bool saveLarge = false,
    int thumbnailSize = vynodyArtworkThumbnailSize,
  }) async {
    try {
      final md5Hex = await calculateMd5(bytes: data);
      final db = MetadataDatabase();
      final cached = await db.getArtworkCache(md5Hex);
      if (cached != null) {
        final hasThumb = cached.thumbnailPath != null && File(cached.thumbnailPath!).existsSync();
        final hasArt = cached.artworkPath != null && File(cached.artworkPath!).existsSync();
        if (hasThumb && (!saveLarge || hasArt)) {
          return {
            'artworkPath': cached.artworkPath,
            'thumbnailPath': cached.thumbnailPath,
            'width': cached.artworkWidth,
            'height': cached.artworkHeight,
            'themeColorsBlob': cached.themeColorsBlob,
          };
        }
      }

      final supportDir = await getApplicationSupportDirectory();
      final artworkInfo = await _buildArtworkFiles(
        songPath: songPath,
        data: data,
        supportDirPath: supportDir.path,
        saveLarge: saveLarge,
        thumbnailSize: thumbnailSize,
      );

      if (artworkInfo != null) {
        final record = ArtworkCacheRecord(
          md5: md5Hex,
          artworkPath: artworkInfo['artworkPath'] as String?,
          thumbnailPath: artworkInfo['thumbnailPath'] as String?,
          artworkWidth: artworkInfo['width'] as int?,
          artworkHeight: artworkInfo['height'] as int?,
          themeColorsBlob: artworkInfo['themeColorsBlob'] as Uint8List?,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await db.insertOrUpdateArtworkCache(record);
      }

      return artworkInfo;
    } catch (e) {
      debugPrint('Error saving artwork: $e');
      return null;
    }
  }

  static Future<void> clearThumbnails() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final thumbnailsDir = Directory(p.join(supportDir.path, 'thumbnails'));
      if (await thumbnailsDir.exists()) {
        await thumbnailsDir.delete(recursive: true);
        await thumbnailsDir.create(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing thumbnails: $e');
    }
  }

  /// 从文件直接读取原始标签，不请求网络，不存入数据库
  static Future<SongMetadata?> readMetadataFromFile(String filePath) async {
    try {
      final metadata = await compute(_readMetadataIsolateEntryPoint, <String, dynamic>{
        'path': filePath,
        'token': RootIsolateToken.instance,
      });
      return SongMetadata(
        path: filePath,
        title: metadata.title ?? p.basenameWithoutExtension(filePath),
        album: metadata.album ?? 'Unknown Album',
        artist: metadata.artist ?? 'Unknown Artist',
        duration: metadata.duration?.inMilliseconds,
        trackNumber: metadata.trackNumber,
      );
    } catch (e) {
      debugPrint('Error reading metadata from file $filePath: $e');
      return null;
    }
  }

  /// Loads metadata for playback use.
  ///
  /// This first tries the database cache. If no record exists, it falls back to
  /// reading the audio file itself, then persists the parsed metadata back into
  /// the database through [processMetadata].
  ///
  /// The returned artwork bytes are only populated when the fallback file parse
  /// was needed and the file contained embedded artwork.
  static Future<(SongMetadata, Uint8List?)?> loadMetadataForPlayback(
    String filePath, {
    bool generateThumbnail = false,
  }) async {
    final db = MetadataDatabase();
    final cached = await db.getSongMetadata(filePath);
    if (cached != null) {
      return (cached, null);
    }

    return processMetadata(
      filePath,
      generateThumbnail: generateThumbnail,
      sourceFlags: SongSourceFlags.external,
    );
  }

  /// 解码文件内嵌封面，分辨率限制在 [maxWidth] * [maxHeight]
  static Future<Uint8List?> decodeEmbeddedArtwork(String filePath) async {
    try {
      final metadata = await compute(_readMetadataWithImageIsolateEntryPoint, <String, dynamic>{
        'path': filePath,
        'token': RootIsolateToken.instance,
      });
      if (metadata.pictures.isEmpty) return null;

      return metadata.pictures.first.bytes;
    } catch (e) {
      debugPrint('Error decoding embedded artwork for $filePath: $e');
      return null;
    }
  }

  /// 探测文件内是否存在内嵌封面，不生成任何缓存文件。
  static Future<bool> hasEmbeddedArtwork(String filePath) async {
    try {
      final metadata = await compute(_readMetadataIsolateEntryPoint, <String, dynamic>{
        'path': filePath,
        'token': RootIsolateToken.instance,
      });
      return metadata.hasArtwork;
    } catch (_) {
      // Probe-only API: tagless or slightly malformed files should behave like
      // "no artwork" here instead of polluting logs.
      return false;
    }
  }

  static TagLibMetadata readMetadataIsolate(String path) {
    if (!taglib.TagLibFile.isSupported) {
      throw UnsupportedError('TagLib is not supported.');
    }
    final tagFile = taglib.TagLibFile.open(path);
    if (tagFile == null) {
      throw Exception('Failed to open file via TagLib.');
    }
    try {
      final title = tagFile.title;
      final artist = tagFile.artist;
      final album = tagFile.album;
      final duration = tagFile.duration;
      final trackNumber = tagFile.track;
      final hasArtwork = tagFile.hasCover;

      return TagLibMetadata(
        title: title.isNotEmpty ? title : null,
        album: album.isNotEmpty ? album : null,
        artist: artist.isNotEmpty ? artist : null,
        duration: duration.inMilliseconds > 0 ? duration : null,
        trackNumber: trackNumber > 0 ? trackNumber : null,
        hasArtwork: hasArtwork,
        pictures: const [],
      );
    } finally {
      tagFile.close();
    }
  }

  static TagLibMetadata readMetadataWithImageIsolate(String path) {
    if (!taglib.TagLibFile.isSupported) {
      throw UnsupportedError('TagLib is not supported.');
    }
    final tagFile = taglib.TagLibFile.open(path);
    if (tagFile == null) {
      throw Exception('Failed to open file via TagLib.');
    }
    try {
      final title = tagFile.title;
      final artist = tagFile.artist;
      final album = tagFile.album;
      final duration = tagFile.duration;
      final trackNumber = tagFile.track;
      final hasArtwork = tagFile.hasCover;
      final pictures = tagFile.pictures;

      return TagLibMetadata(
        title: title.isNotEmpty ? title : null,
        album: album.isNotEmpty ? album : null,
        artist: artist.isNotEmpty ? artist : null,
        duration: duration.inMilliseconds > 0 ? duration : null,
        trackNumber: trackNumber > 0 ? trackNumber : null,
        hasArtwork: hasArtwork,
        pictures: pictures,
      );
    } finally {
      tagFile.close();
    }
  }

  static Future<TagLibMetadata> _readMetadataIsolateEntryPoint(
    Map<String, dynamic> args,
  ) async {
    final path = args['path'] as String;
    final token = args['token'] as RootIsolateToken?;

    if (Platform.isAndroid && token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    if (!taglib.TagLibFile.isSupported) {
      throw UnsupportedError('TagLib is not supported.');
    }
    final tagFile = await taglib.TagLibFile.openAsync(path);
    if (tagFile == null) {
      throw Exception('Failed to open file via TagLib.');
    }
    try {
      final title = tagFile.title;
      final artist = tagFile.artist;
      final album = tagFile.album;
      final duration = tagFile.duration;
      final trackNumber = tagFile.track;
      final hasArtwork = tagFile.hasCover;

      return TagLibMetadata(
        title: title.isNotEmpty ? title : null,
        album: album.isNotEmpty ? album : null,
        artist: artist.isNotEmpty ? artist : null,
        duration: duration.inMilliseconds > 0 ? duration : null,
        trackNumber: trackNumber > 0 ? trackNumber : null,
        hasArtwork: hasArtwork,
        pictures: const [],
      );
    } finally {
      tagFile.close();
    }
  }

  static Future<TagLibMetadata> _readMetadataWithImageIsolateEntryPoint(
    Map<String, dynamic> args,
  ) async {
    final path = args['path'] as String;
    final token = args['token'] as RootIsolateToken?;

    if (Platform.isAndroid && token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    if (!taglib.TagLibFile.isSupported) {
      throw UnsupportedError('TagLib is not supported.');
    }
    final tagFile = await taglib.TagLibFile.openAsync(path);
    if (tagFile == null) {
      throw Exception('Failed to open file via TagLib.');
    }
    try {
      final title = tagFile.title;
      final artist = tagFile.artist;
      final album = tagFile.album;
      final duration = tagFile.duration;
      final trackNumber = tagFile.track;
      final hasArtwork = tagFile.hasCover;
      final pictures = tagFile.pictures;

      return TagLibMetadata(
        title: title.isNotEmpty ? title : null,
        album: album.isNotEmpty ? album : null,
        artist: artist.isNotEmpty ? artist : null,
        duration: duration.inMilliseconds > 0 ? duration : null,
        trackNumber: trackNumber > 0 ? trackNumber : null,
        hasArtwork: hasArtwork,
        pictures: pictures,
      );
    } finally {
      tagFile.close();
    }
  }

  static Future<List<Map<String, dynamic>>> readMetadataBatch(
    List<String> filePaths, {
    bool getImage = false,
    int? isolateCount,
  }) async {
    if (filePaths.isEmpty) {
      return const [];
    }

    final effectiveIsolates =
        (isolateCount ?? Platform.numberOfProcessors).clamp(1, filePaths.length);

    try {
      if (taglib.TagLibFile.isSupported) {
        final batchResults = await taglib.TagLibFile.readBatchAsync(
          filePaths,
          isolateCount: effectiveIsolates,
        );

        final results = <Map<String, dynamic>>[];
        for (final item in batchResults) {
          final file = File(item.path);
          final lastModified = _safeLastModifiedMillis(file);

          Uint8List? artworkBytes;
          if (getImage && item.hasCover) {
            try {
              final tagFile = await taglib.TagLibFile.openAsync(item.path);
              if (tagFile != null) {
                try {
                  artworkBytes = tagFile.coverData;
                } finally {
                  tagFile.close();
                }
              }
            } catch (_) {}
          }

          results.add(<String, dynamic>{
            'path': item.path,
            'title': item.title.trim().isNotEmpty ? item.title.trim() : null,
            'album': item.album.trim().isNotEmpty ? item.album.trim() : null,
            'artist': item.artist.trim().isNotEmpty ? item.artist.trim() : null,
            'duration':
                item.duration.inMilliseconds > 0
                    ? item.duration.inMilliseconds
                    : null,
            'trackNumber': item.track > 0 ? item.track : null,
            'lastModifiedTime': lastModified,
            'hasArtwork': item.hasCover,
            'artworkBytes': artworkBytes,
            'error':
                item.success ? null : (item.error ?? 'Failed to read metadata'),
          });
        }
        return results;
      }
    } catch (e, stackTrace) {
      debugPrint('[MetadataHelper] TagLib readBatchAsync failed: $e\n$stackTrace');
    }

    return compute(_readMetadataBatchIsolate, <String, dynamic>{
      'paths': filePaths,
      'getImage': getImage,
      'token': RootIsolateToken.instance,
    });
  }

  static Future<List<Map<String, dynamic>>> _readMetadataBatchIsolate(
    Map<String, dynamic> args,
  ) async {
    final paths = (args['paths'] as List).cast<String>();
    final getImage = args['getImage'] as bool? ?? false;
    final token = args['token'] as RootIsolateToken?;

    if (Platform.isAndroid && token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    final results = <Map<String, dynamic>>[];
    for (final path in paths) {
      final file = File(path);
      try {
        if (!taglib.TagLibFile.isSupported) {
          throw UnsupportedError('TagLib is not supported.');
        }
        final tagFile = await taglib.TagLibFile.openAsync(path);
        if (tagFile == null) {
          throw Exception('Failed to open file via TagLib.');
        }
        try {
          final title = tagFile.title;
          final artist = tagFile.artist;
          final album = tagFile.album;
          final duration = tagFile.duration.inMilliseconds;
          final trackNumber = tagFile.track;
          final hasArtwork = tagFile.hasCover;
          final artworkBytes = getImage && hasArtwork ? tagFile.coverData : null;
          final lastModified = _safeLastModifiedMillis(file);

          results.add(<String, dynamic>{
            'path': path,
            'title': title.isNotEmpty ? title : null,
            'album': album.isNotEmpty ? album : null,
            'artist': artist.isNotEmpty ? artist : null,
            'duration': duration > 0 ? duration : null,
            'trackNumber': trackNumber > 0 ? trackNumber : null,
            'lastModifiedTime': lastModified,
            'hasArtwork': hasArtwork,
            'artworkBytes': artworkBytes,
            'error': null,
          });
        } finally {
          tagFile.close();
        }
      } catch (e) {
        final lastModified = _safeLastModifiedMillis(file);
        results.add(<String, dynamic>{
          'path': path,
          'title': null,
          'album': null,
          'artist': null,
          'duration': null,
          'trackNumber': null,
          'lastModifiedTime': lastModified,
          'hasArtwork': false,
          'artworkBytes': null,
          'error': e.toString(),
        });
      }
    }
    return results;
  }

  static int? _safeLastModifiedMillis(File file) {
    try {
      return file.lastModifiedSync().millisecondsSinceEpoch;
    } catch (_) {
      return null;
    }
  }

  /// Saves metadata to a single audio file.
  /// Returns true if successful, false if the format is not supported or an error occurred.
  static Future<bool> saveMetadataToFile(
    String filePath, {
    String? title,
    String? artist,
    String? album,
    int? trackNumber,
    List<String>? genres,
    String? o3ics,
    List<taglib.Picture>? pictures,
  }) async {
    if (!isMetadataWritable(filePath)) {
      return false;
    }

    try {
      final firstPictureBytes = (pictures?.isNotEmpty ?? false)
          ? pictures!.first.bytes
          : null;
      final success = await _writeSelectionMetadataToFile(
        filePath: filePath,
        metadata: SongMetadata(
          path: filePath,
          title: title ?? p.basenameWithoutExtension(filePath),
          album: album ?? 'Unknown Album',
          artist: artist ?? 'Unknown Artist',
          trackNumber: trackNumber,
          genres: genres,
        ),
        artworkBytes: firstPictureBytes,
        lyrics: o3ics,
        pictures: pictures
            ?.map(
              (picture) => TrackMetadataPicture(
                bytes: picture.bytes,
                mimeType: picture.mimeType,
                pictureType: picture.pictureType,
              ),
            )
            .toList(),
      );
      return success;
    } catch (e) {
      debugPrint('Error saving metadata to $filePath: $e');
      return false;
    }
  }

  /// Saves metadata for multiple songs.
  /// Returns a result indicating success count, unsupported count, and errors.
  static Future<SaveMetadataResult> saveMetadataToMultipleFiles(
    List<SongMetadata> songs, {
    List<String>? o3icsList,
    List<Uint8List?>? artworkBytesList,
  }) async {
    int savedCount = 0;
    int unsupportedCount = 0;
    final unsupportedFiles = <String>[];

    for (int i = 0; i < songs.length; i++) {
      final song = songs[i];
      final o3ics = o3icsList != null && i < o3icsList.length
          ? o3icsList[i]
          : null;
      final artworkBytes =
          artworkBytesList != null && i < artworkBytesList.length
          ? artworkBytesList[i]
          : null;

      List<taglib.Picture>? pictures;
      if (artworkBytes != null) {
        pictures = [
          taglib.Picture(
            bytes: artworkBytes,
            mimeType: 'image/jpeg',
            pictureType: 'Front Cover',
          ),
        ];
      }

      final success = await saveMetadataToFile(
        song.path,
        title: song.title,
        artist: song.artist,
        album: song.album,
        trackNumber: song.trackNumber,
        genres: song.genres,
        o3ics: o3ics,
        pictures: pictures,
      );

      if (success) {
        savedCount++;
      } else {
        if (isMetadataWritable(song.path)) {
          debugPrint('Failed to save metadata to ${song.path}');
        } else {
          unsupportedCount++;
          unsupportedFiles.add(song.path);
        }
      }
    }

    return SaveMetadataResult(
      success: unsupportedCount == 0,
      unsupportedCount: unsupportedCount,
      savedCount: savedCount,
      unsupportedFiles: unsupportedFiles,
    );
  }

  /// Writes lyrics to a single audio file, preserving existing metadata and artwork.
  static Future<bool> saveLyricsToFile(String filePath, String lyricsText) async {
    lastWriteError = null;
    if (!isMetadataWritable(filePath)) {
      lastWriteError = 'File format is not supported for writing metadata';
      debugPrint('[MetadataHelper] $lastWriteError');
      return false;
    }

    try {
      final db = MetadataDatabase();
      var metadata = await db.getSongMetadata(filePath);
      if (metadata == null) {
        metadata = await readMetadataFromFile(filePath);
      }

      if (metadata == null) {
        metadata = SongMetadata(
          path: filePath,
          title: p.basenameWithoutExtension(filePath),
          album: 'Unknown Album',
          artist: 'Unknown Artist',
        );
      }

      Uint8List? artworkBytes;
      if (metadata.artworkPath != null && metadata.artworkPath!.isNotEmpty) {
        final artworkFile = File(metadata.artworkPath!);
        if (await artworkFile.exists()) {
          artworkBytes = await artworkFile.readAsBytes();
        }
      }

      if (artworkBytes == null) {
        artworkBytes = await decodeEmbeddedArtwork(filePath);
      }

      final success = await _writeSelectionMetadataToFile(
        filePath: filePath,
        metadata: metadata,
        artworkBytes: artworkBytes,
        lyrics: lyricsText,
      );

      if (success) {
        final mtime = File(filePath).lastModifiedSync().millisecondsSinceEpoch;
        var updated = metadata.copyWith(
          lastModifiedTime: mtime,
          createdAt: mtime,
          isAppModified: false,
        );
        await db.insertOrUpdateSong(updated);
      }

      return success;
    } catch (e) {
      debugPrint('Error saving lyrics to file $filePath: $e');
      lastWriteError = e.toString();
      return false;
    }
  }

  /// Writes lyrics to an external .lrc file in the same directory as the song.
  /// On Android, resolves SAF tree URIs and uses the native saveFileToDirectory method if needed.
  static Future<bool> saveLyricsToExternalLrc(String songPath, String lyricsText) async {
    lastWriteError = null;

    final directory = p.dirname(songPath);
    final baseName = p.basenameWithoutExtension(songPath);
    final lrcFileName = '$baseName.lrc';
    final lrcFilePath = p.join(directory, lrcFileName);

    if (Platform.isAndroid) {
      // Check if we can write normally (e.g. if it's on local storage that supports regular File writing)
      try {
        final dir = Directory(directory);
        if (await dir.exists()) {
          final testFile = File(p.join(directory, '.vynody_write_test'));
          await testFile.writeAsString('test');
          await testFile.delete();
          // Regular write works!
          final file = File(lrcFilePath);
          await file.writeAsString(lyricsText);
          return true;
        }
      } catch (_) {
        // Fallback to SAF below
      }

      // Resolve SAF mapping
      final mapping = await AndroidSafStorageHelper.findBestMapping(songPath);
      if (mapping == null) {
        lastWriteError = 'No write permission for this folder. Please re-add the folder to grant permission.';
        debugPrint('[MetadataHelper] $lastWriteError');
        return false;
      }

      final rootDisplayPath = mapping.key;
      final treeUri = mapping.value;

      // Calculate relative path from SAF root to the lrc file
      String relativeLrcPath = '';
      try {
        relativeLrcPath = p.relative(lrcFilePath, from: rootDisplayPath);
      } catch (e) {
        relativeLrcPath = lrcFileName;
      }

      // Write lyric text to a temporary scratch file first
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, 'temp_lyrics_${DateTime.now().millisecondsSinceEpoch}.lrc'));
      await tempFile.writeAsString(lyricsText);

      try {
        final controller = AudioCoreController();
        if (!controller.isInitialized) {
          await controller.initialize();
        }

        // Call native channel via audio_converter channel
        final methodChannel = const MethodChannel('com.example.audio_converter/saf');
        final result = await methodChannel.invokeMapMethod<String, Object?>(
          'saveFileToDirectory',
          <String, Object?>{
            'treeUri': treeUri,
            'sourcePath': tempFile.path,
            'fileName': relativeLrcPath.replaceAll('\\', '/'),
            'overwrite': true,
          },
        );
        final savedUri = result?['savedUri']?.toString();
        if (savedUri != null && savedUri.isNotEmpty) {
          return true;
        } else {
          lastWriteError = 'Failed to write via SAF';
          return false;
        }
      } catch (e) {
        debugPrint('[MetadataHelper] Native save file via SAF failed: $e');
        lastWriteError = e.toString();
        return false;
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    } else {
      // Desktop / iOS: standard file write
      try {
        final file = File(lrcFilePath);
        await file.writeAsString(lyricsText);
        return true;
      } catch (e) {
        debugPrint('[MetadataHelper] Failed to save external LRC: $e');
        lastWriteError = e.toString();
        return false;
      }
    }
  }
}

class TagLibMetadata {
  final String? title;
  final String? album;
  final String? artist;
  final Duration? duration;
  final int? trackNumber;
  final bool hasArtwork;
  final List<taglib.Picture> pictures;

  TagLibMetadata({
    this.title,
    this.album,
    this.artist,
    this.duration,
    this.trackNumber,
    required this.hasArtwork,
    required this.pictures,
  });
}

class AndroidSafStorageHelper {
  static const String _prefKey = 'saf_tree_mappings_v1';

  static Future<Map<String, String>> getMappings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefKey);
      if (jsonStr == null || jsonStr.isEmpty) return {};
      final map = jsonDecode(jsonStr);
      if (map is Map) {
        return map.map((key, value) => MapEntry(key.toString(), value.toString()));
      }
    } catch (e) {
      debugPrint('[AndroidSafStorageHelper] Error reading mappings: $e');
    }
    return {};
  }

  static Future<void> saveMapping(String displayPath, String treeUri) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await getMappings();
      current[displayPath] = treeUri;
      await prefs.setString(_prefKey, jsonEncode(current));
      debugPrint('[AndroidSafStorageHelper] Saved mapping: $displayPath -> $treeUri');
    } catch (e) {
      debugPrint('[AndroidSafStorageHelper] Error saving mapping: $e');
    }
  }

  static Future<MapEntry<String, String>?> findBestMapping(String filePath) async {
    final mappings = await getMappings();
    if (mappings.isEmpty) return null;

    final normalizedFile = p.normalize(filePath).toLowerCase();
    MapEntry<String, String>? bestMatch;
    int longestMatchLength = 0;

    for (final entry in mappings.entries) {
      final normalizedRoot = p.normalize(entry.key).toLowerCase();
      if (normalizedFile.startsWith(normalizedRoot)) {
        if (entry.key.length > longestMatchLength) {
          longestMatchLength = entry.key.length;
          bestMatch = entry;
        }
      }
    }
    return bestMatch;
  }

  static Future<bool> fileExists(String treeUri, String relativePath) async {
    try {
      final methodChannel = const MethodChannel('com.example.audio_converter/saf');
      final result = await methodChannel.invokeMethod<bool>(
        'fileExistsInDirectory',
        <String, Object?>{
          'treeUri': treeUri,
          'fileName': relativePath.replaceAll('\\', '/'),
        },
      );
      return result ?? false;
    } catch (e) {
      debugPrint('[AndroidSafStorageHelper] fileExists error: $e');
      return false;
    }
  }

  static Future<bool> directoryExists(String treeUri) async {
    try {
      final methodChannel = const MethodChannel('com.example.audio_converter/saf');
      final result = await methodChannel.invokeMethod<bool>(
        'directoryExists',
        <String, Object?>{
          'treeUri': treeUri,
        },
      );
      return result ?? false;
    } catch (e) {
      debugPrint('[AndroidSafStorageHelper] directoryExists error: $e');
      return false;
    }
  }

  static Future<List<String>> listMusicFilesRecursively(
    String treeUri, {
    String relativeSubPath = '',
  }) async {
    try {
      final methodChannel = const MethodChannel('com.example.audio_converter/saf');
      final result = await methodChannel.invokeListMethod<String>(
        'listMusicFilesInDirectory',
        <String, Object?>{
          'treeUri': treeUri,
          'relativeSubPath': relativeSubPath,
        },
      );
      return result ?? const <String>[];
    } catch (e) {
      debugPrint('[AndroidSafStorageHelper] listMusicFilesRecursively error: $e');
      return const <String>[];
    }
  }
}

