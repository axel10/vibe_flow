/// 播放队列后台处理器
///
/// 负责在后台异步处理播放列表中的歌曲。
/// 包括：解析元数据、从封面提取配色方案、生成全曲波形图等耗时操作，不干扰主线程播放。
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audio_core/audio_core.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:vynody/player/metadata/artwork_constants.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/player/settings/theme_color_helper.dart';
import 'package:vynody/player/settings/track_artwork_theme_service.dart';
import 'package:vynody/player/audio/waveform_service.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/utils/memory_trace.dart';

/// Handles background processing of the playback queue (waveforms, colors, etc.)
class PlaybackQueueProcessor {
  final MetadataDatabase db;
  final AudioCoreController player;
  final SettingsService settingsService;
  final WaveformService waveformService;

  int _currentProcessId = 0;
  bool _isProcessing = false;
  bool _isPaused = false;
  bool _disposed = false;
  bool get isProcessing => _isProcessing;
  bool get isPaused => _isPaused;

  PlaybackQueueProcessor({
    required this.db,
    required this.player,
    required this.settingsService,
    required this.waveformService,
  });

  void pause() {
    _isPaused = true;
    debugPrint('PlaybackQueueProcessor: Paused background processing.');
  }

  void resume() {
    _isPaused = false;
    debugPrint('PlaybackQueueProcessor: Resumed background processing.');
  }

  Future<void> _waitUntilResumed() async {
    while (_isPaused && !_disposed) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Checks if a song already has all required background data (waveform, colors).
  Future<bool> isSongReady(String path) async {
    final existing = await db.getSongMetadata(path);
    if (existing == null) return false;

    final bool showWaveform = settingsService.isWaveformProgressBarEnabled;
    final bool needsWaveform =
        showWaveform && !await waveformService.hasCachedWaveform(path);
    final bool needsThemeColor = existing.themeColorsBlob == null;

    return !needsWaveform && !needsThemeColor;
  }

  Future<void> processQueue({
    required List<MusicFile> playlist,
    required String? currentFilePath,
    required Function(String path, Map<String, dynamic> updates) onUpdate,
    Function(String path, String artworkPath)? onHdArtworkLoaded,
  }) async {
    if (_disposed) return;
    final artworkThemeService = TrackArtworkThemeService(db: db);
    // If already processing, we signal to stop the current one and start fresh with new priority
    _currentProcessId++;
    final int myId = _currentProcessId;
    MemoryTrace.snapshot(
      'queueProcessor:start',
      details: <String, Object?>{
        'id': myId,
        'playlist': playlist.length,
        'current': currentFilePath ?? '-',
      },
    );

    if (_isProcessing) {
      debugPrint('Signaling background processor to re-prioritize');
    }

    _isProcessing = true;

    try {
      debugPrint('Starting background queue processing (ID: $myId)');

      // 1. Sort the processing list to prioritize current and upcoming songs
      final List<MusicFile> sortedList = List.from(playlist);
      int currentIndex = -1;
      final Set<String> dbPriorityPaths = <String>{};

      if (currentFilePath != null) {
        if (_disposed) return;
        currentIndex = playlist.indexWhere((s) => s.path == currentFilePath);
        if (currentIndex != -1) {
          final Set<String> processed = <String>{};
          final List<MusicFile> prioritized = <MusicFile>[];

          void addIfUnique(int index) {
            final idx = index % playlist.length;
            final song = playlist[idx < 0 ? idx + playlist.length : idx];
            if (processed.add(song.path)) {
              prioritized.add(song);
            }
          }

          // DB check & calculate range: current, prev 2, next 3
          // This range is what we calculate and store in DB
          for (int i = 0; i <= 3; i++) {
            addIfUnique(currentIndex + i);
          }
          for (int i = 1; i <= 2; i++) {
            addIfUnique(currentIndex - i);
          }

          // Save the priority paths for DB calculations
          for (final song in prioritized) {
            dbPriorityPaths.add(song.path);
          }

          // 4: Everything else
          for (int i = 0; i < playlist.length; i++) {
            addIfUnique(i);
          }

          sortedList.clear();
          sortedList.addAll(prioritized);
        }
      }

      // Priority Phase: Immediately process current song's heavy metadata (waveform, colors)
      // so it is available instantly without waiting for the fast-pass of other songs' covers.
      if (sortedList.isNotEmpty) {
        final currentSong = sortedList.first;
        await _processSongHeavyData(
          song: currentSong,
          artworkThemeService: artworkThemeService,
          onUpdate: onUpdate,
          myId: myId,
        );
      }

      // Phase 1: FAST PASS - Immediately load HD artwork for prioritized songs (prev 1, current, next 1)
      // This ensures that when skipping fast, covers are already in memory.
      final List<MusicFile> artworkPrioritySongs = [];
      if (currentFilePath != null && currentIndex != -1) {
        artworkPrioritySongs.add(playlist[currentIndex]);
        if (playlist.length > 1) {
          final idx = (currentIndex + 1) % playlist.length;
          artworkPrioritySongs.add(playlist[idx]);
        }
        if (playlist.length > 2) {
          final idx = (currentIndex - 1 + playlist.length) % playlist.length;
          if (!artworkPrioritySongs.any((s) => s.path == playlist[idx].path)) {
            artworkPrioritySongs.add(playlist[idx]);
          }
        }
      }

      for (final song in artworkPrioritySongs) {
        if (_disposed || myId != _currentProcessId) return;
        final isRemote = RemoteMediaResolver.isRemoteUri(song.path);
        if (song.isMissing ||
            song.path.isEmpty ||
            (!isRemote && !File(song.path).existsSync())) {
          continue;
        }

        try {
          final existing = await db.getSongMetadata(song.path);
          final path = existing?.artworkPath ?? existing?.thumbnailPath;
          if (path != null && onHdArtworkLoaded != null) {
            onHdArtworkLoaded(song.path, path);
          }
        } catch (e) {
          debugPrint('Error loading HD artwork in fast pass: $e');
        }
      }

      // Phase 2: SLOW PASS - Process thumbnails, colors and waveforms
      // Only process songs within dbPriorityPaths (prev 2 to next 3) to save CPU
      for (final song in sortedList) {
        // Check if we've been superseded by a newer request
        if (_disposed || myId != _currentProcessId) {
          debugPrint(
            'Background process $myId superseded by $_currentProcessId, exiting.',
          );
          return;
        }

        if (dbPriorityPaths.isNotEmpty && !dbPriorityPaths.contains(song.path)) {
          continue;
        }

        await _processSongHeavyData(
          song: song,
          artworkThemeService: artworkThemeService,
          onUpdate: onUpdate,
          myId: myId,
        );
      }
    } finally {
      _isProcessing = false;
      MemoryTrace.snapshot(
        'queueProcessor:end',
        details: <String, Object?>{
          'id': myId,
          'playlist': playlist.length,
        },
      );
      debugPrint('Background queue processing finished');
    }
  }

  Future<void> _processSongHeavyData({
    required MusicFile song,
    required TrackArtworkThemeService artworkThemeService,
    required Function(String path, Map<String, dynamic> updates) onUpdate,
    required int myId,
  }) async {
    if (_disposed || myId != _currentProcessId) return;

    await _waitUntilResumed();

    try {
      final isRemote = RemoteMediaResolver.isRemoteUri(song.path);
      if (song.isMissing ||
          song.path.isEmpty ||
          (!isRemote && !File(song.path).existsSync())) {
        return;
      }

      final existing = await db.getSongMetadata(song.path);
      final bool showWaveform = settingsService.isWaveformProgressBarEnabled;

      // Sync existing database values to memory if missing on the in-memory song object
      if (existing != null) {
        final Map<String, dynamic> updates = {};
        if (song.waveformBlob == null && existing.waveformBlob != null) {
          updates['waveformBlob'] = existing.waveformBlob;
          updates['waveform'] = waveformService.waveformFromBlob(existing.waveformBlob);
        }
        if (song.themeColorsBlob == null && existing.themeColorsBlob != null) {
          updates['themeColorsBlob'] = existing.themeColorsBlob;
          updates['themeColors'] = ThemeColorHelper.blobToColors(
            existing.themeColorsBlob!,
          );
        }
        if (song.thumbnailPath == null && existing.thumbnailPath != null) {
          updates['thumbnailPath'] = existing.thumbnailPath;
        }
        if (song.artworkPath == null && existing.artworkPath != null) {
          updates['artworkPath'] = existing.artworkPath;
        }
        if (song.artworkWidth == null && existing.artworkWidth != null) {
          updates['artworkWidth'] = existing.artworkWidth;
        }
        if (song.artworkHeight == null && existing.artworkHeight != null) {
          updates['artworkHeight'] = existing.artworkHeight;
        }
        if (updates.isNotEmpty) {
          onUpdate(song.path, updates);
        }
      }

      // Decide what needs to be done
      final lastModified = existing?.lastModifiedTime ??
          (!isRemote && File(song.path).existsSync()
              ? (await File(song.path).lastModified()).millisecondsSinceEpoch
              : DateTime.now().millisecondsSinceEpoch);

      final bool hasScannedImg = existing != null &&
          existing.metadataImgScanned != null &&
          existing.metadataImgScanned == existing.lastModifiedTime;

      final bool needsWaveform =
          showWaveform && (existing == null || existing.waveformBlob == null);
      final bool needsThemeColor =
          !hasScannedImg && (existing == null || existing.themeColorsBlob == null);
      final bool needsArtwork =
          !hasScannedImg && (existing == null || existing.thumbnailPath == null);

      // Heavy Processing: Thumbnails, Colors and Waveform
      if (needsWaveform || needsThemeColor || needsArtwork) {
        if (_disposed || myId != _currentProcessId) return;

        debugPrint(
          'Background processing (Thumbnail/Colors/Waveform): ${song.path}',
        );

        // We need a metadata object (either from DB or a quick scan) to get the artwork path
        SongMetadata? m = existing;
        if (m == null) {
          if (!isRemote) {
            final result = await MetadataHelper.processMetadata(
              song.path,
              generateThumbnail: false,
            );
            if (_disposed || myId != _currentProcessId) return;
            m = result?.$1;
          } else {
            m = SongMetadata(
              path: song.path,
              title: song.title ?? song.name,
              artist: song.artist ?? 'Unknown Artist',
              album: song.album ?? 'Unknown Album',
              trackNumber: song.trackNumber,
              duration: song.durationMillis != null ? song.durationMillis! ~/ 1000 : null,
              artworkPath: song.artworkPath,
            );
          }
        }

        if (m != null) {
          // Use a non-nullable reference
          SongMetadata meta = m;
          bool didScanImg = false;

          if (needsThemeColor || needsArtwork) {
            final artworkTheme = await artworkThemeService.getTrackArtworkTheme(
              song.path,
              controller: player,
              saveLargeArtwork: false,
              thumbnailSize: vynodyArtworkThumbnailSize,
            );
            if (_disposed || myId != _currentProcessId) return;
            didScanImg = true;

          if (artworkTheme != null &&
              (artworkTheme.hasArtworkPath || artworkTheme.hasThemeColors)) {
            meta = artworkTheme.toSongMetadata(base: meta);
            meta = meta.copyWith(metadataImgScanned: lastModified);
            await db.insertOrUpdateSong(meta);
            MemoryTrace.snapshot(
              'queueProcessor:artworkTheme',
              details: <String, Object?>{
                'path': song.path,
                'thumb': artworkTheme.thumbnailPath ?? '-',
                'theme': artworkTheme.themeColorsBlob?.length ?? 0,
              },
            );

            final updates = <String, dynamic>{
              'thumbnailPath': artworkTheme.thumbnailPath ?? meta.thumbnailPath,
              'artworkPath': artworkTheme.artworkPath ?? meta.artworkPath,
              'artworkWidth': meta.artworkWidth,
                'artworkHeight': meta.artworkHeight,
              };
              if (meta.themeColorsBlob != null) {
                updates['themeColorsBlob'] = meta.themeColorsBlob;
                updates['themeColors'] = ThemeColorHelper.blobToColors(
                  meta.themeColorsBlob!,
                );
              }

              onUpdate(song.path, updates);
            }
          }

          // Extract waveform if missing AND enabled in settings
          if (showWaveform && meta.waveformBlob == null) {
            try {
              final waveformResult = await waveformService.getWaveformData(
                path: song.path,
                expectedChunks: settingsService.waveformChunks,
                sampleStride: settingsService.sampleStride,
                baseMetadata: meta,
              );
              if (_disposed || myId != _currentProcessId) return;

              if (waveformResult.waveform.isNotEmpty) {
                meta = meta.copyWith(waveformBlob: waveformResult.waveformBlob);
                onUpdate(song.path, {
                  'waveform': waveformResult.waveform,
                  'waveformBlob': waveformResult.waveformBlob,
                });
              }
            } catch (e) {
              debugPrint('Waveform extraction error for ${song.path}: $e');
            }
          }

          // If we attempted image scan but didn't save metadataImgScanned above (e.g. because no artwork was found at all),
          // write it to DB now to prevent future repeated scans.
          if (didScanImg && meta.metadataImgScanned != lastModified) {
            meta = meta.copyWith(metadataImgScanned: lastModified);
            await db.insertOrUpdateSong(meta);
          }
        }

        // Small delay between songs to keep main thread snappy
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint('Error processing background song ${song.path}: $e');
    }
  }

  void dispose() {
    _disposed = true;
  }
}
