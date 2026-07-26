import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';

class ScannerMetadataStore {
  ScannerMetadataStore({
    required Iterable<MusicFolder> Function() rootFolders,
    required MusicFolder? Function() systemMediaFolder,
    required void Function() notifyListeners,
    required void Function() scheduleMetadataNotify,
    required void Function() onMetadataMutated,
    required void Function() onAlbumMetadataMutated,
    required void Function(String path, bool isMissing) notifySongMissingState,
    required String Function(String path) normalizePath,
    required bool Function(String left, String right) pathsEqual,
  }) : _rootFolders = rootFolders,
       _systemMediaFolder = systemMediaFolder,
       _notifyListeners = notifyListeners,
       _scheduleMetadataNotify = scheduleMetadataNotify,
       _onMetadataMutated = onMetadataMutated,
       _onAlbumMetadataMutated = onAlbumMetadataMutated,
       _notifySongMissingState = notifySongMissingState,
       _normalizePath = normalizePath,
       _pathsEqual = pathsEqual;

  final Iterable<MusicFolder> Function() _rootFolders;
  final MusicFolder? Function() _systemMediaFolder;
  final void Function() _notifyListeners;
  final void Function() _scheduleMetadataNotify;
  final void Function() _onMetadataMutated;
  final void Function() _onAlbumMetadataMutated;
  final void Function(String path, bool isMissing) _notifySongMissingState;
  final String Function(String path) _normalizePath;
  final bool Function(String left, String right) _pathsEqual;

  final Map<String, SongMetadata> _metadataMap = {};

  Map<String, SongMetadata> get metadataMap => _metadataMap;

  SongMetadata? getMetadata(String path) => _metadataMap[path];

  void replaceAllMetadata(Iterable<SongMetadata> metadataList) {
    _metadataMap
      ..clear()
      ..addEntries(
        metadataList.map(
          (metadata) => MapEntry(
            metadata.path,
            metadata.copyWith(
              waveformBlob: null,
              sourceFlags: metadata.sourceFlags,
            ),
          ),
        ),
      );
    _onMetadataMutated();
    _onAlbumMetadataMutated();
  }

  bool _albumRelevantMetadataChanged(
    SongMetadata? previous,
    SongMetadata next,
  ) {
    if (previous == null) {
      return true;
    }

    return previous.title != next.title ||
        previous.album != next.album ||
        previous.artist != next.artist ||
        previous.duration != next.duration ||
        previous.trackNumber != next.trackNumber;
  }

  void _logTiming(String label, Stopwatch stopwatch) {
    if (!kDebugMode) return;
    // debugPrint(
    //   '[ScannerMetadataStore][timing] $label ${stopwatch.elapsedMilliseconds} ms',
    // );
  }

  void cacheMetadata(SongMetadata metadata) {
    final existing = _metadataMap[metadata.path];
    final albumChanged = _albumRelevantMetadataChanged(existing, metadata);
    _metadataMap[metadata.path] = metadata.copyWith(
      waveformBlob: null,
      sourceFlags: _mergeSourceFlags(
        existing?.sourceFlags,
        metadata.sourceFlags,
      ),
    );
    _onMetadataMutated();
    if (albumChanged) {
      _onAlbumMetadataMutated();
    }
  }

  void cacheMetadataBatch(Iterable<SongMetadata> items) {
    if (items.isEmpty) return;
    var anyAlbumChanged = false;
    for (final metadata in items) {
      final existing = _metadataMap[metadata.path];
      if (!anyAlbumChanged && _albumRelevantMetadataChanged(existing, metadata)) {
        anyAlbumChanged = true;
      }
      _metadataMap[metadata.path] = metadata.copyWith(
        waveformBlob: null,
        sourceFlags: _mergeSourceFlags(
          existing?.sourceFlags,
          metadata.sourceFlags,
        ),
      );
    }
    _onMetadataMutated();
    if (anyAlbumChanged) {
      _onAlbumMetadataMutated();
    }
  }

  void clear() {
    _metadataMap.clear();
    _onMetadataMutated();
    _onAlbumMetadataMutated();
  }

  Future<void> loadMetadataForPath(String path) async {
    final stopwatch = Stopwatch()..start();
    if (!await File(path).exists()) {
      await purgeMissingSongPath(path);
      stopwatch.stop();
      _logTiming('loadMetadataForPath missing($path)', stopwatch);
      return;
    }

    final cached = _metadataMap[path];
    if (cached != null) {
      return;
    }

    final db = MetadataDatabase();
    SongMetadata? metadata = await db.getSongMetadata(path);
    final result = metadata == null
        ? await MetadataHelper.processMetadata(path, generateThumbnail: false)
        : null;
    metadata ??= result?.$1;

    if (metadata != null) {
      final mergedMetadata = metadata.copyWith(
        sourceFlags: _mergeSourceFlags(
          _metadataMap[path]?.sourceFlags,
          metadata.sourceFlags,
        ),
      );
      final albumChanged = _albumRelevantMetadataChanged(
        _metadataMap[path],
        mergedMetadata,
      );
      _metadataMap[path] = mergedMetadata;
      _onMetadataMutated();
      if (albumChanged) {
        _onAlbumMetadataMutated();
      }
      _notifyListeners();
    }
    stopwatch.stop();
    _logTiming('loadMetadataForPath($path)', stopwatch);
  }

  Future<void> loadThumbnailForPath(String path) async {
    final cached = _metadataMap[path];
    if (cached != null && (cached.thumbnailPath?.isNotEmpty ?? false)) {
      return;
    }

    final stopwatch = Stopwatch()..start();
    if (!await File(path).exists()) {
      await purgeMissingSongPath(path);
      stopwatch.stop();
      _logTiming('loadThumbnailForPath missing($path)', stopwatch);
      return;
    }

    final db = MetadataDatabase();
    SongMetadata? metadata = await db.getSongMetadata(path);
    if (metadata == null || (metadata.thumbnailPath?.isEmpty ?? true)) {
      final result = await MetadataHelper.processMetadata(
        path,
        generateThumbnail: true,
      );
      metadata = result?.$1 ?? metadata;
    }

    if (metadata != null) {
      final mergedMetadata = metadata.copyWith(
        sourceFlags: _mergeSourceFlags(
          _metadataMap[path]?.sourceFlags,
          metadata.sourceFlags,
        ),
      );
      final albumChanged = _albumRelevantMetadataChanged(
        _metadataMap[path],
        mergedMetadata,
      );
      _metadataMap[path] = mergedMetadata;
      _onMetadataMutated();
      if (albumChanged) {
        _onAlbumMetadataMutated();
      }
      _notifyListeners();
    }
    stopwatch.stop();
    _logTiming('loadThumbnailForPath($path)', stopwatch);
  }

  void updateMetadataForPath(
    SongMetadata metadata, {
    Uint8List? artworkBytes,
    bool notify = true,
    bool syncTree = true,
  }) {
    final existing = _metadataMap[metadata.path];
    final isArtworkCleared = artworkBytes != null && artworkBytes.isEmpty;
    final mergedMetadata = metadata.copyWith(
      thumbnailPath: isArtworkCleared ? null : (metadata.thumbnailPath ?? existing?.thumbnailPath),
      artworkPath: isArtworkCleared ? null : (metadata.artworkPath ?? existing?.artworkPath),
      artworkWidth: isArtworkCleared ? null : (metadata.artworkWidth ?? existing?.artworkWidth),
      artworkHeight: isArtworkCleared ? null : (metadata.artworkHeight ?? existing?.artworkHeight),
      sourceFlags: _mergeSourceFlags(
        existing?.sourceFlags,
        metadata.sourceFlags,
      ),
      themeColorsBlob: isArtworkCleared ? null : (metadata.themeColorsBlob ?? existing?.themeColorsBlob),
      waveformBlob: null,
    );
    final albumChanged = _albumRelevantMetadataChanged(
      existing,
      mergedMetadata,
    );
    _metadataMap[metadata.path] = mergedMetadata;
    _onMetadataMutated();
    if (albumChanged) {
      _onAlbumMetadataMutated();
    }

    if (syncTree) {
      for (final root in _rootFolders()) {
        _updateMusicFileInFolder(
          root,
          mergedMetadata,
          artworkBytes: artworkBytes,
        );
      }
      final systemFolder = _systemMediaFolder();
      if (systemFolder != null) {
        _updateMusicFileInFolder(
          systemFolder,
          mergedMetadata,
          artworkBytes: artworkBytes,
        );
      }
    }

    if (notify) {
      _notifyListeners();
    } else {
      _scheduleMetadataNotify();
    }
  }

  Future<void> purgeMissingSongPath(String path) async {
    final normalizedPath = _normalizePath(path);
    if (normalizedPath.isEmpty) return;

    _notifySongMissingState(normalizedPath, true);

    await MetadataDatabase().deleteSongByPath(normalizedPath);
    _removeMetadataForPaths([normalizedPath]);
    _notifyListeners();
  }

  void deleteMissingFromCache(
    Iterable<String> paths, {
    bool updateVisibleTrees = true,
  }) {
    _removeMetadataForPaths(paths, updateVisibleTrees: updateVisibleTrees);
  }

  void removeMetadataForPath(String path) {
    _removeMetadataForPaths([path]);
  }

  void clearWaveformForPath(String path) {
    final existing = _metadataMap[path];
    if (existing == null) return;
    _metadataMap[path] = existing.copyWith(waveformBlob: null);
    _onMetadataMutated();
  }

  bool containsPath(String path) {
    return _metadataMap.containsKey(path);
  }

  int? _mergeSourceFlags(int? existing, int? incoming) {
    if (incoming == null) return existing;
    if (existing == null) return incoming;
    return existing | incoming;
  }

  void _removeMetadataForPaths(
    Iterable<String> paths, {
    bool updateVisibleTrees = true,
  }) {
    final normalizedTargets = paths
        .map(_normalizePath)
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
    if (normalizedTargets.isEmpty || _metadataMap.isEmpty) {
      return;
    }

    if (updateVisibleTrees) {
      _removePathsFromVisibleTrees(normalizedTargets);
    }

    final targetLookup = normalizedTargets
        .map((path) => Platform.isWindows ? path.toLowerCase() : path)
        .toSet();
    final beforeLength = _metadataMap.length;
    _metadataMap.removeWhere((key, _) {
      final normalizedKey = _normalizePath(key);
      final lookupKey = Platform.isWindows
          ? normalizedKey.toLowerCase()
          : normalizedKey;
      return targetLookup.contains(lookupKey);
    });

    if (_metadataMap.length != beforeLength) {
      _onMetadataMutated();
      _onAlbumMetadataMutated();
    }
  }

  void _removePathsFromVisibleTrees(Iterable<String> paths) {
    for (final root in _rootFolders()) {
      for (final path in paths) {
        _removeSongFromFolder(root, path);
      }
    }
    final systemFolder = _systemMediaFolder();
    if (systemFolder != null) {
      for (final path in paths) {
        _removeSongFromFolder(systemFolder, path);
      }
    }
  }

  void _updateMusicFileInFolder(
    MusicFolder folder,
    SongMetadata metadata, {
    Uint8List? artworkBytes,
  }) {
    final isArtworkCleared = artworkBytes != null && artworkBytes.isEmpty;
    for (var i = 0; i < folder.files.length; i++) {
      final file = folder.files[i];
      if (_pathsEqual(file.path, metadata.path)) {
        folder.files[i] = file.copyWith(
          title: metadata.title,
          artist: metadata.artist,
          album: metadata.album,
          trackNumber: metadata.trackNumber,
          thumbnailPath: isArtworkCleared ? null : (metadata.thumbnailPath ?? file.thumbnailPath),
          artworkPath: isArtworkCleared ? null : (metadata.artworkPath ?? file.artworkPath),
          artworkWidth: isArtworkCleared ? null : (metadata.artworkWidth ?? file.artworkWidth),
          artworkHeight: isArtworkCleared ? null : (metadata.artworkHeight ?? file.artworkHeight),
          themeColorsBlob: isArtworkCleared ? null : (metadata.themeColorsBlob ?? file.themeColorsBlob),
          waveformBlob: null,
          artworkBytes: isArtworkCleared ? null : (artworkBytes ?? file.artworkBytes),
          lastModifiedTime: metadata.lastModifiedTime,
        );
      }
    }
    for (final subFolder in folder.subFolders) {
      _updateMusicFileInFolder(subFolder, metadata, artworkBytes: artworkBytes);
    }
  }

  bool _removeSongFromFolder(MusicFolder folder, String path) {
    folder.files.removeWhere((file) => _pathsEqual(file.path, path));

    folder.subFolders.removeWhere((subFolder) {
      final shouldRemove = _removeSongFromFolder(subFolder, path);
      return shouldRemove;
    });

    return folder.isEmpty;
  }
}
