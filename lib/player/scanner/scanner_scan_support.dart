import 'dart:async';

import 'package:vynody/player/metadata/metadata_database.dart';

class ScanProgress {
  final String filePath;
  final int discoveredCount;
  final int preprocessedCount;
  final int completedCount;

  const ScanProgress({
    required this.filePath,
    required this.discoveredCount,
    required this.preprocessedCount,
    required this.completedCount,
  });
}

class ScanProgressState {
  ScanProgressState({
    int metadataConcurrency = 4,
    required int Function(String a, String b) comparePaths,
  }) : metadataRunner = OrderedTaskRunner(
         metadataConcurrency,
         comparePaths: comparePaths,
       );

  int discoveredCount = 0;
  int preprocessedCount = 0;
  int completedCount = 0;
  final OrderedTaskRunner metadataRunner;
  final List<Future<void>> pendingMetadataTasks = [];
  final List<String> pendingMetadataPaths = [];
}

class OrderedTaskRunner {
  OrderedTaskRunner(int maxConcurrent, {required this.comparePaths})
    : maxConcurrent = maxConcurrent < 1 ? 1 : maxConcurrent;

  final int maxConcurrent;
  final int Function(String a, String b) comparePaths;
  int _running = 0;
  int _sequence = 0;
  final List<QueuedTask<dynamic>> _queue = [];

  Future<T> run<T>(String path, Future<T> Function() task) {
    final completer = Completer<T>();
    final entry = QueuedTask<T>(
      path: path,
      sequence: _sequence++,
      completer: completer,
      task: task,
    );

    // Maintain _queue in sorted order using binary search insertion
    int low = 0;
    int high = _queue.length - 1;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final midItem = _queue[mid];
      final pathCmp = comparePaths(entry.path, midItem.path);
      final finalCmp = pathCmp != 0
          ? pathCmp
          : entry.sequence.compareTo(midItem.sequence);
      if (finalCmp < 0) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }
    _queue.insert(low, entry);

    _pump();
    return completer.future;
  }

  void _pump() {
    while (_running < maxConcurrent && _queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      _running++;
      unawaited(_execute(next));
    }
  }

  Future<void> _execute<T>(QueuedTask<T> entry) async {
    try {
      final result = await entry.task();
      if (!entry.completer.isCompleted) {
        entry.completer.complete(result);
      }
    } catch (e, st) {
      if (!entry.completer.isCompleted) {
        entry.completer.completeError(e, st);
      }
    } finally {
      _running--;
      _pump();
    }
  }
}

class QueuedTask<T> {
  QueuedTask({
    required this.path,
    required this.sequence,
    required this.completer,
    required this.task,
  });

  final String path;
  final int sequence;
  final Completer<T> completer;
  final Future<T> Function() task;
}

enum ScanFileStage { full, imageOnly, unchanged }

class ScanFileClassification {
  ScanFileClassification({
    required this.existingMetadataByPath,
    required this.stageByPath,
  });

  final Map<String, SongMetadata> existingMetadataByPath;
  final Map<String, ScanFileStage> stageByPath;

  List<String> pathsFor(ScanFileStage stage) {
    return stageByPath.entries
        .where((entry) => entry.value == stage)
        .map((entry) => entry.key)
        .toList(growable: false);
  }
}

class ScanPreprocessResult {
  const ScanPreprocessResult({
    required this.keptPaths,
    required this.artworkPendingPaths,
  });

  final List<String> keptPaths;
  final List<String> artworkPendingPaths;
}

class ScanDiscoveredFile {
  const ScanDiscoveredFile({
    required this.path,
    this.lastModifiedTime,
  });

  final String path;
  final int? lastModifiedTime;
}

