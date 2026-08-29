import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/audio/playback_queue_processor.dart';
import 'package:vynody/utils/memory_trace.dart';

class QueueBackgroundProcessor {
  final MetadataDatabase db;
  final PlaybackQueueProcessor queueProcessor;

  QueueBackgroundProcessor({
    required this.db,
    required this.queueProcessor,
  });

  void start({
    required List<MusicFile> queue,
    required String? priorityPath,
    required void Function() onChanged,
    required void Function(Map<String, Color>) onThemeChanged,
    required MusicFile? Function() currentMusic,
    required void Function(String) logTrace,
    required String Function(MusicFile?) debugSongLabel,
  }) {
    if (queue.isEmpty) return;
    MemoryTrace.snapshot(
      'audio:queueBackground:start',
      details: <String, Object?>{
        'priority': priorityPath ?? currentMusic()?.path ?? '-',
        'queue': queue.length,
        'current': currentMusic()?.path ?? '-',
      },
    );

    final String? currentPath = priorityPath ?? currentMusic()?.path;
    final Set<String> artworkPriorityPaths = <String>{};
    final Set<String> waveformMemoryPaths = <String>{};

    if (currentPath != null) {
      final int currIdx = queue.indexWhere((s) => s.path == currentPath);
      if (currIdx != -1) {
        for (int i = -1; i <= 1; i++) {
          final idx = (currIdx + i) % queue.length;
          final safeIdx = idx < 0 ? idx + queue.length : idx;
          artworkPriorityPaths.add(queue[safeIdx].path);
        }
        for (int i = -1; i <= 1; i++) {
          final idx = (currIdx + i) % queue.length;
          final safeIdx = idx < 0 ? idx + queue.length : idx;
          waveformMemoryPaths.add(queue[safeIdx].path);
        }
      }
    }

    bool changed = false;
    for (int i = 0; i < queue.length; i++) {
      final song = queue[i];
      if (!artworkPriorityPaths.contains(song.path) &&
          song.artworkBytes != null) {
        queue[i] = queue[i].copyWith(artworkBytes: null);
        changed = true;
      }
      if (!waveformMemoryPaths.contains(song.path) &&
          song.waveformBlob != null) {
        queue[i] = queue[i].copyWith(waveformBlob: null);
        changed = true;
      }
    }
    if (changed) {
      onChanged();
    }

    if (artworkPriorityPaths.isNotEmpty || waveformMemoryPaths.isNotEmpty) {
      unawaited(() async {
        bool asyncChanged = false;
        for (int i = 0; i < queue.length; i++) {
          final song = queue[i];
          final bool inWaveform = waveformMemoryPaths.contains(song.path);
          final bool needsDbSync = song.thumbnailPath == null ||
              (inWaveform && song.waveformBlob == null);

          if (needsDbSync) {
            final existing = await db.getSongMetadata(song.path);
            if (existing != null) {
              Uint8List? newWaveformBlob = song.waveformBlob;
              String? newThumbnailPath = song.thumbnailPath;
              String? newArtworkPath = song.artworkPath;
              int? newArtworkWidth = song.artworkWidth;
              int? newArtworkHeight = song.artworkHeight;
              Uint8List? newThemeColorsBlob = song.themeColorsBlob;

              if (inWaveform && song.waveformBlob == null) {
                newWaveformBlob = existing.waveformBlob;
              }
              if (existing.thumbnailPath != null) {
                newThumbnailPath = existing.thumbnailPath;
              }
              if (existing.artworkPath != null) {
                newArtworkPath = existing.artworkPath;
              }
              if (existing.artworkWidth != null) {
                newArtworkWidth = existing.artworkWidth;
              }
              if (existing.artworkHeight != null) {
                newArtworkHeight = existing.artworkHeight;
              }
              if (existing.themeColorsBlob != null) {
                newThemeColorsBlob = existing.themeColorsBlob;
              }

              if (i < queue.length && queue[i].path == song.path) {
                queue[i] = queue[i].copyWith(
                  waveformBlob: newWaveformBlob,
                  thumbnailPath: newThumbnailPath,
                  artworkPath: newArtworkPath,
                  artworkWidth: newArtworkWidth,
                  artworkHeight: newArtworkHeight,
                  themeColorsBlob: newThemeColorsBlob,
                );
                asyncChanged = true;
              }
            }
          }
        }
        if (asyncChanged) {
          onChanged();
        }
      }());
    }

    logTrace(
      '_startQueueBackgroundProcessing priority='
      '${priorityPath ?? currentMusic()?.path ?? '-'} '
      'current=${debugSongLabel(currentMusic())}',
    );

    unawaited(
      queueProcessor.processQueue(
        playlist: List.from(queue),
        currentFilePath: priorityPath ?? currentMusic()?.path,
        onUpdate: (path, updates) {
          logTrace(
            '_queueProcessor onUpdate path=$path '
            'keys=${updates.keys.toList()} '
            'current=${debugSongLabel(currentMusic())}',
          );

          final String? currentPath = currentMusic()?.path;
          final Set<String> waveformMemPaths = <String>{};
          if (currentPath != null) {
            final int currIdx =
                queue.indexWhere((s) => s.path == currentPath);
            if (currIdx != -1) {
              for (int i = -1; i <= 1; i++) {
                final idx = (currIdx + i) % queue.length;
                final safeIdx = idx < 0 ? idx + queue.length : idx;
                waveformMemPaths.add(queue[safeIdx].path);
              }
            }
          }

          bool queueChanged = false;
          for (int i = 0; i < queue.length; i++) {
            if (queue[i].path == path) {
              final bool inWaveformMemoryRange =
                  waveformMemPaths.contains(path);
              queue[i] = queue[i].copyWith(
                title: updates['title'] as String? ?? queue[i].title,
                artist: updates['artist'] as String? ?? queue[i].artist,
                album: updates['album'] as String? ?? queue[i].album,
                trackNumber: updates['trackNumber'] as int? ?? queue[i].trackNumber,
                durationMillis: updates['durationMillis'] as int? ?? queue[i].durationMillis,
                themeColorsBlob: updates['themeColorsBlob'] as Uint8List? ??
                    queue[i].themeColorsBlob,
                waveformBlob: inWaveformMemoryRange
                    ? (updates['waveformBlob'] as Uint8List? ??
                        queue[i].waveformBlob)
                    : null,
                thumbnailPath:
                    updates['thumbnailPath'] as String? ??
                        queue[i].thumbnailPath,
                artworkPath:
                    updates['artworkPath'] as String? ??
                        queue[i].artworkPath,
                artworkWidth:
                    updates['artworkWidth'] as int? ??
                        queue[i].artworkWidth,
                artworkHeight:
                    updates['artworkHeight'] as int? ??
                        queue[i].artworkHeight,
              );
              queueChanged = true;
            }
          }

          if (path == currentMusic()?.path && updates.containsKey('themeColors')) {
            onThemeChanged(updates['themeColors'] as Map<String, Color>);
          }
          if (queueChanged) {
            onChanged();
          }
        },

        onHdArtworkLoaded: (path, artworkPath) {
          logTrace(
            '_queueProcessor onHdArtworkLoaded path=$path '
            'artworkPath=$artworkPath '
            'current=${debugSongLabel(currentMusic())}',
          );
          MemoryTrace.snapshot(
            'audio:queueBackground:artworkLoaded',
            details: <String, Object?>{
              'path': path,
              'artworkPath': artworkPath,
              'queue': queue.length,
            },
          );

          final String? currentPath = currentMusic()?.path;
          final Set<String> artworkPriority = <String>{};
          if (currentPath != null) {
            final int currIdx =
                queue.indexWhere((s) => s.path == currentPath);
            if (currIdx != -1) {
              for (int i = -1; i <= 1; i++) {
                final idx = (currIdx + i) % queue.length;
                final safeIdx = idx < 0 ? idx + queue.length : idx;
                artworkPriority.add(queue[safeIdx].path);
              }
            }
          }

          if (artworkPriority.contains(path)) {
            for (int i = 0; i < queue.length; i++) {
              if (queue[i].path == path) {
                queue[i] = queue[i].copyWith(artworkPath: artworkPath);
              }
            }

            if (path == currentMusic()?.path) {
              onChanged();
            }

            final isPc =
                Platform.isWindows || Platform.isMacOS || Platform.isLinux;
            final int limit = isPc ? 1200 : 800;

            final provider = ResizeImage(
              FileImage(File(artworkPath)),
              width: limit,
              height: limit,
              allowUpscaling: false,
            );
            provider.resolve(ImageConfiguration.empty);
          }
        },
      ),
    );
  }
}
