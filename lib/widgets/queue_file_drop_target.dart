import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/library/music_file_utils.dart';

class QueueFileDropTarget extends ConsumerStatefulWidget {
  const QueueFileDropTarget({
    super.key,
    required this.child,
    required this.displayQueue,
    required this.queueSongs,
    required this.itemKeyBuilder,
    this.enabled = true,
    this.showPreview = true,
  });

  final Widget child;
  final List<MusicFile> displayQueue;
  final List<MusicFile> queueSongs;
  final GlobalKey Function(int index, MusicFile song) itemKeyBuilder;
  final bool enabled;
  final bool showPreview;

  @override
  ConsumerState<QueueFileDropTarget> createState() =>
      _QueueFileDropTargetState();
}

class _QueueFileDropTargetState extends ConsumerState<QueueFileDropTarget> {
  final GlobalKey _surfaceKey = GlobalKey(debugLabel: 'queue-drop-surface');
  bool _isDraggingFiles = false;
  double? _dropIndicatorTop;
  int? _dropInsertIndex;

  Future<List<MusicFile>> _getFilesFromPath(String path) async {
    final results = <MusicFile>[];
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
          if (item is File && MusicFileUtils.isMusicFilePath(item.path)) {
            results.add(
              MusicFile(path: item.path, name: p.basename(item.path)),
            );
          }
        }
      } catch (e) {
        debugPrint('Error scanning directory $path: $e');
      }
    }

    return results;
  }

  List<MusicFile> _dedupeDroppedFiles(List<MusicFile> files) {
    final uniqueFiles = <MusicFile>[];
    final seenPaths = <String>{};
    for (final song in files) {
      if (seenPaths.add(song.path)) {
        uniqueFiles.add(song);
      }
    }
    return uniqueFiles;
  }

  ({int insertIndex, double indicatorTop})? _calculateDropPreview(
    Offset localPosition,
  ) {
    final surfaceBox =
        _surfaceKey.currentContext?.findRenderObject() as RenderBox?;
    if (surfaceBox == null) {
      return null;
    }

    final visibleItems = <({int index, double top, double bottom})>[];
    for (var i = 0; i < widget.displayQueue.length; i++) {
      final key = widget.itemKeyBuilder(i, widget.displayQueue[i]);
      final renderObject = key.currentContext?.findRenderObject();
      final itemBox = renderObject is RenderBox ? renderObject : null;
      if (itemBox == null) continue;

      final topLeft = surfaceBox.globalToLocal(
        itemBox.localToGlobal(Offset.zero),
      );
      visibleItems.add((
        index: i,
        top: topLeft.dy,
        bottom: topLeft.dy + itemBox.size.height,
      ));
    }

    if (visibleItems.isEmpty) {
      return (insertIndex: 0, indicatorTop: 0);
    }

    visibleItems.sort((a, b) => a.index.compareTo(b.index));

    final firstItem = visibleItems.first;
    final lastItem = visibleItems.last;
    var insertIndex = lastItem.index + 1;
    var indicatorTop = lastItem.bottom;

    if (localPosition.dy <= firstItem.top) {
      return (insertIndex: firstItem.index, indicatorTop: firstItem.top);
    }

    for (final item in visibleItems) {
      final itemMid = item.top + ((item.bottom - item.top) / 2);
      if (localPosition.dy < itemMid) {
        insertIndex = item.index;
        indicatorTop = item.top;
        break;
      }
    }

    return (insertIndex: insertIndex, indicatorTop: indicatorTop);
  }

  void _clearDropPreview() {
    if (!_isDraggingFiles &&
        _dropIndicatorTop == null &&
        _dropInsertIndex == null) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isDraggingFiles = false;
      _dropIndicatorTop = null;
      _dropInsertIndex = null;
    });
  }

  Future<void> _handleDroppedFiles(
    List<DropItem> droppedItems, {
    required Offset dropLocalPosition,
  }) async {
    final audio = ref.read(audioServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final List<MusicFile> allFiles = [];

    for (final item in droppedItems) {
      final files = await _getFilesFromPath(item.path);
      allFiles.addAll(files);
    }

    if (!mounted) return;

    final uniqueFiles = _dedupeDroppedFiles(allFiles);
    if (uniqueFiles.isEmpty) {
      _clearDropPreview();
      return;
    }

    final existingQueuePaths = widget.queueSongs
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

    if (newSongs.isEmpty) {
      _clearDropPreview();
      return;
    }

    final preview = widget.showPreview
        ? _calculateDropPreview(dropLocalPosition)
        : null;
    final insertIndex = (preview?.insertIndex ?? widget.queueSongs.length)
        .clamp(0, widget.queueSongs.length);

    if (widget.showPreview) {
      await audio.insertIntoQueueAt(insertIndex, newSongs);
    } else {
      await audio.appendToQueue(newSongs);
    }

    if (!mounted) return;

    _clearDropPreview();
    final message = existingCount > 0
        ? l10n.dropAddedSongsWithExisting(newSongs.length, existingCount)
        : l10n.dropAddedSongs(newSongs.length);

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropTarget(
      enable: widget.enabled,
      onDragEntered: (details) {
        if (!widget.enabled) return;
        if (!widget.showPreview) {
          if (!_isDraggingFiles) {
            setState(() {
              _isDraggingFiles = true;
            });
          }
          return;
        }

        final preview = _calculateDropPreview(details.localPosition);
        if (preview == null) return;

        if (_isDraggingFiles &&
            _dropInsertIndex == preview.insertIndex &&
            _dropIndicatorTop == preview.indicatorTop) {
          return;
        }

        setState(() {
          _isDraggingFiles = true;
          _dropInsertIndex = preview.insertIndex;
          _dropIndicatorTop = preview.indicatorTop;
        });
      },
      onDragUpdated: (details) {
        if (!widget.enabled || !widget.showPreview) return;
        final preview = _calculateDropPreview(details.localPosition);
        if (preview == null) return;

        if (_isDraggingFiles &&
            _dropInsertIndex == preview.insertIndex &&
            _dropIndicatorTop == preview.indicatorTop) {
          return;
        }

        setState(() {
          _isDraggingFiles = true;
          _dropInsertIndex = preview.insertIndex;
          _dropIndicatorTop = preview.indicatorTop;
        });
      },
      onDragExited: (_) {
        _clearDropPreview();
      },
      onDragDone: (details) async {
        if (!widget.enabled) return;
        await _handleDroppedFiles(
          details.files,
          dropLocalPosition: details.localPosition,
        );
      },
      child: Container(
        key: _surfaceKey,
        child: Stack(
          children: [
            widget.child,
            if (widget.enabled &&
                widget.showPreview &&
                _dropIndicatorTop != null)
              Positioned(
                top: _dropIndicatorTop! - 1.5,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
