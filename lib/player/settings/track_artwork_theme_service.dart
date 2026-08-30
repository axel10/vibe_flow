import 'dart:io';
import 'package:audio_core/audio_core.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:vynody/player/metadata/artwork_constants.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/remote/remote_server_storage.dart';

class TrackArtworkThemeResult {
  const TrackArtworkThemeResult({
    required this.path,
    required this.artworkPath,
    required this.thumbnailPath,
    required this.artworkWidth,
    required this.artworkHeight,
    required this.themeColorsBlob,
    required this.artworkFound,
  });

  final String path;
  final String? artworkPath;
  final String? thumbnailPath;
  final int? artworkWidth;
  final int? artworkHeight;
  final Uint8List? themeColorsBlob;
  final bool artworkFound;

  static bool _hasText(String? value) => value?.trim().isNotEmpty ?? false;

  bool get hasThumbnailPath => _hasText(thumbnailPath);

  bool get hasArtworkPath => _hasText(artworkPath) || hasThumbnailPath;

  bool get hasThemeColors =>
      themeColorsBlob != null && themeColorsBlob!.isNotEmpty;

  bool get hasCompleteData => hasThumbnailPath && hasThemeColors;

  TrackArtworkThemeResult copyWith({
    String? artworkPath,
    String? thumbnailPath,
    int? artworkWidth,
    int? artworkHeight,
    Uint8List? themeColorsBlob,
    bool? artworkFound,
  }) {
    return TrackArtworkThemeResult(
      path: path,
      artworkPath: artworkPath ?? this.artworkPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      artworkWidth: artworkWidth ?? this.artworkWidth,
      artworkHeight: artworkHeight ?? this.artworkHeight,
      themeColorsBlob: themeColorsBlob ?? this.themeColorsBlob,
      artworkFound: artworkFound ?? this.artworkFound,
    );
  }

  static TrackArtworkThemeResult? fromMetadata(
    String path,
    SongMetadata? metadata,
  ) {
    if (metadata == null) return null;

    final artworkPath = _hasText(metadata.artworkPath)
        ? metadata.artworkPath
        : null;
    final thumbnailPath = _hasText(metadata.thumbnailPath)
        ? metadata.thumbnailPath
        : null;
    final themeColorsBlob = metadata.themeColorsBlob;
    final artworkFound = artworkPath != null || thumbnailPath != null;

    if (!artworkFound && (themeColorsBlob == null || themeColorsBlob.isEmpty)) {
      return null;
    }

    return TrackArtworkThemeResult(
      path: path,
      artworkPath: artworkPath,
      thumbnailPath: thumbnailPath,
      artworkWidth: metadata.artworkWidth,
      artworkHeight: metadata.artworkHeight,
      themeColorsBlob: themeColorsBlob,
      artworkFound: artworkFound,
    );
  }

  SongMetadata toSongMetadata({SongMetadata? base}) {
    final resolvedBase =
        base ??
        SongMetadata(
          path: path,
          title: p.basenameWithoutExtension(path),
          album: 'Unknown Album',
          artist: 'Unknown Artist',
        );

    return resolvedBase.copyWith(
      artworkPath: artworkPath ?? resolvedBase.artworkPath,
      thumbnailPath: thumbnailPath ?? resolvedBase.thumbnailPath,
      artworkWidth: artworkWidth ?? resolvedBase.artworkWidth,
      artworkHeight: artworkHeight ?? resolvedBase.artworkHeight,
      themeColorsBlob: themeColorsBlob ?? resolvedBase.themeColorsBlob,
    );
  }
}

class TrackArtworkThemeService {
  TrackArtworkThemeService({MetadataDatabase? db})
    : _db = db ?? MetadataDatabase();

  final MetadataDatabase _db;

  static final Map<String, Future<TrackArtworkThemeResult?>> _inFlight = {};

  Future<TrackArtworkThemeResult?> getTrackArtworkTheme(
    String path, {
    AudioCoreController? controller,
    String? cacheRootPath,
    bool saveLargeArtwork = false,
    int thumbnailSize = vynodyArtworkThumbnailSize,
    bool saveToDatabase = true,
    SongMetadata? existingMetadata,
  }) async {
    final normalizedPath = path.trim();
    if (normalizedPath.isEmpty) return null;

    final cached = existingMetadata ?? await _db.getSongMetadata(normalizedPath);
    final cachedResult = TrackArtworkThemeResult.fromMetadata(
      normalizedPath,
      cached,
    );
    if (cachedResult != null && cachedResult.hasCompleteData) {
      return cachedResult;
    }

    if (cached != null) {
      final lastModified = cached.lastModifiedTime;
      final hasArtwork =
          (cached.artworkPath?.isNotEmpty ?? false) ||
          (cached.thumbnailPath?.isNotEmpty ?? false);
      if (!RemoteMediaResolver.isRemoteUri(normalizedPath)) {
        final dirCover = MetadataHelper.findDirectoryCover(normalizedPath);
        final hasDirCover = dirCover != null;
        if (cached.metadataImgScanned != null &&
            cached.metadataImgScanned == lastModified &&
            (hasArtwork || !hasDirCover)) {
          return cachedResult;
        }
      } else if (hasArtwork && (cached.themeColorsBlob?.isNotEmpty ?? false)) {
        return cachedResult;
      }
    }

    final inFlight = _inFlight[normalizedPath];
    if (inFlight != null) {
      return inFlight;
    }

    if (controller == null) {
      return cachedResult;
    }

    final resolvedCacheRootPath = (cacheRootPath?.trim().isNotEmpty ?? false)
        ? cacheRootPath!.trim()
        : (await getApplicationSupportDirectory()).path;

    final future = _resolveTrackArtworkTheme(
      path: normalizedPath,
      controller: controller,
      cacheRootPath: resolvedCacheRootPath,
      saveLargeArtwork: saveLargeArtwork,
      thumbnailSize: thumbnailSize,
      cached: cached,
      saveToDatabase: saveToDatabase,
    );

    _inFlight[normalizedPath] = future;
    try {
      return await future;
    } finally {
      if (_inFlight[normalizedPath] == future) {
        _inFlight.remove(normalizedPath);
      }
    }
  }

  Future<TrackArtworkThemeResult?> _resolveTrackArtworkTheme({
    required String path,
    required AudioCoreController controller,
    required String cacheRootPath,
    required bool saveLargeArtwork,
    required int thumbnailSize,
    required SongMetadata? cached,
    bool saveToDatabase = true,
  }) async {
    final baseMetadata =
        cached ??
        SongMetadata(
          path: path,
          title: p.basenameWithoutExtension(path),
          album: 'Unknown Album',
          artist: 'Unknown Artist',
        );

    final isRemote = RemoteMediaResolver.isRemoteUri(path);
    final lastModified = baseMetadata.lastModifiedTime ??
        (!isRemote && File(path).existsSync()
            ? File(path).lastModifiedSync().millisecondsSinceEpoch
            : DateTime.now().millisecondsSinceEpoch);

    try {
      Uint8List? artworkBytes;
      if (isRemote) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final storage = RemoteServerStorage(prefs: prefs);
          final resolver = RemoteMediaResolver(storage: storage);
          final coverId = baseMetadata.artworkPath ?? cached?.artworkPath;
          artworkBytes = await resolver.getArtworkBytes(path, coverArtId: coverId);
        } catch (e) {
          debugPrint('[TrackArtworkThemeService] Failed to fetch remote artwork for $path: $e');
        }

        if (artworkBytes == null || artworkBytes.isEmpty) {
          try {
            final info = RemoteMediaResolver.parseUri(path);
            if (info != null) {
              final rawKey = '${info.serverId}:${info.trackIdOrPath}';
              final decodedKey = '${info.serverId}:${Uri.decodeFull(info.trackIdOrPath)}';
              final encodedKey = '${info.serverId}:${Uri.encodeFull(info.trackIdOrPath)}';
              for (final key in {rawKey, decodedKey, encodedKey}) {
                final cacheFile = await controller.streamCacheManager.getCacheFile(key);
                if (await cacheFile.exists() && (await cacheFile.length()) > 0) {
                  artworkBytes = await MetadataHelper.decodeEmbeddedArtwork(cacheFile.path);
                  if (artworkBytes != null && artworkBytes.isNotEmpty) break;
                }
              }
            }
          } catch (_) {}
        }
      } else {
        artworkBytes = await MetadataHelper.decodeEmbeddedArtwork(path);
        if (artworkBytes == null || artworkBytes.isEmpty) {
          final dirCoverPath = MetadataHelper.findDirectoryCover(path);
          if (dirCoverPath != null) {
            try {
              artworkBytes = await File(dirCoverPath).readAsBytes();
            } catch (e) {
              debugPrint('Failed to read directory cover $dirCoverPath: $e');
            }
          }
        }
      }
      final resolvedBytes = artworkBytes ?? Uint8List(0);

      final artwork = await controller.generateTrackArtwork(
        path: path,
        artworkBytes: resolvedBytes,
        cacheRootPath: cacheRootPath,
        saveLargeArtwork: saveLargeArtwork,
        options: TrackArtworkOptions(
          thumbnailSize: thumbnailSize,
          meshMuddyPenaltyMultiplier: 1,
          paletteBlurRadius: 0
        ),
      );

      final isWebDavUnparsed = path.startsWith('webdav://') &&
          (baseMetadata.artist == 'Unknown Artist' || baseMetadata.artist.isEmpty);
      final shouldSaveToDb = saveToDatabase && !isWebDavUnparsed;

      if (!artwork.artworkFound &&
          !(artwork.thumbnailPath?.trim().isNotEmpty ?? false) &&
          (artwork.themeColorsBlob == null ||
              artwork.themeColorsBlob!.isEmpty)) {
        final resolvedMetadata = baseMetadata.copyWith(
          metadataImgScanned: lastModified,
        );
        if (shouldSaveToDb) {
          await _db.insertOrUpdateSong(resolvedMetadata);
        }
        return TrackArtworkThemeResult.fromMetadata(path, resolvedMetadata);
      }

      final resolvedMetadata = baseMetadata.copyWith(
        artworkPath: artwork.artworkPath ?? baseMetadata.artworkPath,
        thumbnailPath: artwork.thumbnailPath ?? baseMetadata.thumbnailPath,
        artworkWidth: artwork.artworkWidth ?? baseMetadata.artworkWidth,
        artworkHeight: artwork.artworkHeight ?? baseMetadata.artworkHeight,
        themeColorsBlob:
            artwork.themeColorsBlob ?? baseMetadata.themeColorsBlob,
        metadataImgScanned: lastModified,
      );

      if (shouldSaveToDb) {
        await _db.insertOrUpdateSong(resolvedMetadata);
      }

      return TrackArtworkThemeResult.fromMetadata(path, resolvedMetadata) ??
          TrackArtworkThemeResult(
            path: path,
            artworkPath: resolvedMetadata.artworkPath,
            thumbnailPath: resolvedMetadata.thumbnailPath,
            artworkWidth: resolvedMetadata.artworkWidth,
            artworkHeight: resolvedMetadata.artworkHeight,
            themeColorsBlob: resolvedMetadata.themeColorsBlob,
            artworkFound: artwork.artworkFound,
          );
    } catch (e) {
      debugPrint('TrackArtworkThemeService failed for $path: $e');
      return TrackArtworkThemeResult.fromMetadata(path, cached);
    }
  }
}
