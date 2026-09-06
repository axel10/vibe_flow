import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:path/path.dart' as p;
import '../l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/library/music_file_utils.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/models/music_file.dart';

class GlobalDropTarget extends ConsumerStatefulWidget {
  final Widget child;
  final bool enable;

  const GlobalDropTarget({super.key, required this.child, this.enable = true});

  @override
  ConsumerState<GlobalDropTarget> createState() => _GlobalDropTargetState();
}

class _GlobalDropTargetState extends ConsumerState<GlobalDropTarget> {
  Future<List<MusicFile>> _getFilesFromPath(String path) async {
    final List<MusicFile> results = [];
    final entityType = FileSystemEntity.typeSync(path);

    if (entityType == FileSystemEntityType.file) {
      if (MusicFileUtils.isMusicFilePath(path)) {
        results.add(MusicFile(path: path, name: p.basename(path)));
      }
    } else if (entityType == FileSystemEntityType.directory) {
      final dir = Directory(path);
      try {
        await for (final item in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (item is File) {
            if (MusicFileUtils.isMusicFilePath(item.path)) {
              results.add(
                MusicFile(path: item.path, name: p.basename(item.path)),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Error scanning directory $path: $e');
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      enable: widget.enable,
      // 处理拖放完成事件
      onDragDone: (details) async {
        if (!widget.enable) return;
        final audio = ref.read(audioServiceProvider);
        final messenger = ScaffoldMessenger.of(context);
        final l10n = AppLocalizations.of(context)!;
        final List<MusicFile> allFiles = [];

        // 1. 递归扫描拖入的所有路径（支持拖入单个文件或整个文件夹）
        for (final file in details.files) {
          // 获取路径下符合音频扩展名的文件列表
          final files = await _getFilesFromPath(file.path);
          allFiles.addAll(files);
        }

        if (!mounted || allFiles.isEmpty) {
          return;
        }

        final uniqueFiles = <MusicFile>[];
        final seenPaths = <String>{};
        for (final song in allFiles) {
          if (seenPaths.add(song.path)) {
            uniqueFiles.add(song);
          }
        }

        if (uniqueFiles.length == 1) {
          final song = uniqueFiles.first;
          final queueIndex = audio.playbackQueue.indexWhere(
            (queuedSong) => queuedSong.path == song.path,
          );

          if (queueIndex >= 0) {
            await audio.playAtIndex(queueIndex);
          } else {
            await audio.playFile(song.path, song.name, append: true);
          }
          return;
        }

        final existingQueuePaths = audio.playbackQueue
            .map((song) => song.path)
            .toSet();
        final newSongs = <MusicFile>[];
        var existingCount = 0;

        for (final song in uniqueFiles) {
          if (existingQueuePaths.contains(song.path)) {
            existingCount++;
            continue;
          }
          newSongs.add(song);
        }

        if (newSongs.isNotEmpty) {
          final db = MetadataDatabase();
          final cachedMap =
              await db.getSongMetadataByPaths(newSongs.map((s) => s.path));
          for (var i = 0; i < newSongs.length; i++) {
            final s = newSongs[i];
            final cached = cachedMap[s.path];
            if (cached != null) {
              newSongs[i] = newSongs[i].copyWith(
                title: cached.title,
                artist: cached.artist,
                albumArtist: cached.albumArtist,
                album: cached.album,
                trackNumber: cached.trackNumber,
                durationMillis: cached.duration,
                thumbnailPath: cached.thumbnailPath,
                artworkPath: cached.artworkPath,
                artworkWidth: cached.artworkWidth,
                artworkHeight: cached.artworkHeight,
                themeColorsBlob: cached.themeColorsBlob,
                waveformBlob: cached.waveformBlob,
                lastModifiedTime: cached.lastModifiedTime,
              );
            }
          }
          await audio.appendToQueue(newSongs);
        }

        if (!mounted) return;

        final message = existingCount > 0
            ? l10n.dropAddedSongsWithExisting(newSongs.length, existingCount)
            : l10n.dropAddedSongs(newSongs.length);

        messenger.showSnackBar(SnackBar(content: Text(message)));

        // 多文件拖入只做静默入队，不改变当前播放歌曲。
      },
      child: widget.child,
    );
  }
}
