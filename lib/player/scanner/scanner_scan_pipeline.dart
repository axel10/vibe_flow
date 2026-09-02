import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:flutter/foundation.dart';

import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/scanner/scanner_metadata_store.dart';
import 'package:vynody/player/scanner/scanner_scan_support.dart';

class ScannerScanPipeline {
  ScannerScanPipeline({
    required String Function(String path) normalizePath,
    required String Function(String path) pathLookupKey,
    required ScannerMetadataStore metadataStore,
  }) : _normalizePath = normalizePath,
       _pathLookupKey = pathLookupKey,
       _metadataStore = metadataStore;

  final String Function(String path) _normalizePath;
  final String Function(String path) _pathLookupKey;
  final ScannerMetadataStore _metadataStore;

  void _logTiming(String label, Stopwatch stopwatch) {
    debugPrint(
      '[ScannerScanPipeline] $label took ${stopwatch.elapsedMilliseconds} ms',
    );
  }

  Future<Map<String, int?>> loadLastModifiedTimes(
    Iterable<String> filePaths, {
    bool Function()? shouldCancel,
  }) async {
    final totalStopwatch = Stopwatch()..start();
    final normalizedPaths = <String>[];
    final seen = <String>{};

    for (final path in filePaths) {
      final normalized = _normalizePath(path);
      if (normalized.isEmpty) continue;

      final lookupKey = _pathLookupKey(normalized);
      if (seen.add(lookupKey)) {
        normalizedPaths.add(normalized);
      }
    }

    final lastModifiedByPath = <String, int?>{};
    if (normalizedPaths.isEmpty) {
      totalStopwatch.stop();
      _logTiming('loadLastModifiedTimes empty', totalStopwatch);
      return lastModifiedByPath;
    }

    const batchSize = 128;
    for (var start = 0; start < normalizedPaths.length; start += batchSize) {
      if (shouldCancel?.call() ?? false) {
        break;
      }
      final end = start + batchSize < normalizedPaths.length
          ? start + batchSize
          : normalizedPaths.length;
      final chunk = normalizedPaths.sublist(start, end);
      final batchStopwatch = Stopwatch()..start();

      final results = await Future.wait(
        chunk.map((path) async {
          try {
            final lastModified = await File(path).lastModified();
            return MapEntry(
              _pathLookupKey(path),
              lastModified.millisecondsSinceEpoch,
            );
          } catch (_) {
            return MapEntry<String, int?>(_pathLookupKey(path), null);
          }
        }),
      );

      for (final entry in results) {
        lastModifiedByPath[entry.key] = entry.value;
      }
      batchStopwatch.stop();
      _logTiming(
        'loadLastModifiedTimes chunk ${start + 1}-$end',
        batchStopwatch,
      );
    }

    totalStopwatch.stop();
    _logTiming('loadLastModifiedTimes total', totalStopwatch);
    return lastModifiedByPath;
  }

  Future<ScanFileClassification> classifyDiscoveredFiles(
    List<ScanDiscoveredFile> discoveredFiles, {
    bool Function()? shouldCancel,
  }) async {
    final totalStopwatch = Stopwatch()..start();
    if (discoveredFiles.isEmpty) {
      totalStopwatch.stop();
      _logTiming('classifyDiscoveredFiles empty', totalStopwatch);
      return ScanFileClassification(
        existingMetadataByPath: const {},
        stageByPath: const {},
      );
    }

    final filePaths =
        discoveredFiles.map((f) => f.path).toList(growable: false);

    final dbStopwatch = Stopwatch()..start();
    final existingMetadataByPath = await MetadataDatabase()
        .getSongMetadataByPaths(filePaths);
    dbStopwatch.stop();
    _logTiming('classifyDiscoveredFiles database lookup', dbStopwatch);

    final statStopwatch = Stopwatch()..start();
    final lastModifiedByPath = <String, int?>{};
    final missingPaths = <String>[];

    for (final file in discoveredFiles) {
      final lookupKey = _pathLookupKey(file.path);
      if (file.lastModifiedTime != null) {
        lastModifiedByPath[lookupKey] = file.lastModifiedTime;
      } else {
        missingPaths.add(file.path);
      }
    }

    if (missingPaths.isNotEmpty) {
      final loadedTimes = await loadLastModifiedTimes(
        missingPaths,
        shouldCancel: shouldCancel,
      );
      lastModifiedByPath.addAll(loadedTimes);
    }
    statStopwatch.stop();
    _logTiming('classifyDiscoveredFiles file stat lookup', statStopwatch);

    final stageByPath = <String, ScanFileStage>{};
    final seen = <String>{};
    final classifyStopwatch = Stopwatch()..start();

    var count = 0;
    for (final path in filePaths) {
      if (count % 1000 == 0) {
        if (shouldCancel?.call() ?? false) {
          break;
        }
        if (count > 0) {
          await Future<void>.delayed(Duration.zero);
        }
      }
      count++;
      final lookupKey = _pathLookupKey(path);
      if (!seen.add(lookupKey)) {
        continue;
      }

      final existing = existingMetadataByPath[lookupKey];
      final currentLastModified = lastModifiedByPath[lookupKey];
      final textScanned = existing?.metadataTextScanned;

      if (existing != null && existing.isModified) {
        stageByPath[path] = ScanFileStage.unchanged;
      } else if (existing != null &&
          currentLastModified != null &&
          textScanned == currentLastModified) {
        stageByPath[path] = ScanFileStage.unchanged;
      } else {
        stageByPath[path] = ScanFileStage.full;
      }
    }
    classifyStopwatch.stop();
    _logTiming('classifyDiscoveredFiles compare decision', classifyStopwatch);

    totalStopwatch.stop();
    _logTiming('classifyDiscoveredFiles total', totalStopwatch);
    return ScanFileClassification(
      existingMetadataByPath: existingMetadataByPath,
      stageByPath: stageByPath,
    );
  }

  SongMetadata buildScannedMetadataFromBatchResult(
    String filePath,
    Map<String, dynamic> result, {
    SongMetadata? existing,
    int? sourceFlags,
    int? mediaId,
    String? fallbackTitle,
    String? fallbackAlbum,
    String? fallbackArtist,
    String? fallbackAlbumArtist,
    int? fallbackDuration,
    int? fallbackTrackNumber,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    int? fileLastModified;
    try {
      fileLastModified = File(filePath).lastModifiedSync().millisecondsSinceEpoch;
    } catch (_) {}

    final lastModified =
        result['lastModifiedTime'] as int? ??
        fileLastModified ??
        existing?.lastModifiedTime ??
        now;
    final resolvedFallbackTitle =
        _cleanText(fallbackTitle) ?? p.basenameWithoutExtension(filePath);

    final hasError = result['error'] != null;

    return SongMetadata(
      path: filePath,
      mediaId: mediaId ?? existing?.mediaId,
      title:
          _cleanText(result['title'] as String?) ??
          (hasError ? _cleanText(existing?.title) : null) ??
          resolvedFallbackTitle,
      album:
          _cleanText(result['album'] as String?) ??
          (hasError ? _cleanText(existing?.album) : null) ??
          _cleanText(fallbackAlbum) ??
          'Unknown Album',
      artist:
          _cleanText(result['artist'] as String?) ??
          (hasError ? _cleanText(existing?.artist) : null) ??
          _cleanText(fallbackArtist) ??
          'Unknown Artist',
      albumArtist:
          _cleanText(result['albumArtist'] as String?) ??
          (hasError ? _cleanText(existing?.albumArtist) : null) ??
          _cleanText(fallbackAlbumArtist),
      duration:
          result['duration'] as int? ?? existing?.duration ?? fallbackDuration,
      trackNumber:
          result['trackNumber'] as int? ??
          (hasError ? existing?.trackNumber : null) ??
          fallbackTrackNumber,
      sourceFlags: sourceFlags ?? existing?.sourceFlags,
      artworkPath: existing?.artworkPath,
      thumbnailPath: existing?.thumbnailPath,
      artworkWidth: existing?.artworkWidth,
      artworkHeight: existing?.artworkHeight,
      themeColorsBlob: existing?.themeColorsBlob,
      waveformBlob: existing?.waveformBlob,
      lastModifiedTime: lastModified,
      metadataTextScanned: lastModified,
      metadataImgScanned: existing?.metadataImgScanned,
      createdAt: existing?.createdAt ?? now,
      genres: existing?.genres,
      isAppModified: existing?.isAppModified ?? false,
    );
  }

  void seedMetadataFromDatabase(
    Map<String, SongMetadata> existingMetadataByPath,
  ) {
    _metadataStore.cacheMetadataBatch(existingMetadataByPath.values);
  }

  String? cleanText(String? value) {
    return _cleanText(value);
  }

  String? _cleanText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
