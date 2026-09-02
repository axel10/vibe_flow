import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';

import 'package:vynody/player/scanner/scanner_path_utils.dart';

class ScannerServiceRoots {
  ScannerServiceRoots({
    required bool Function() isDisposed,
    required void Function(String path) onPathChanged,
    void Function()? onRootsMutated,
  }) : _isDisposed = isDisposed,
       _onPathChanged = onPathChanged,
       _onRootsMutated = onRootsMutated;

  final bool Function() _isDisposed;
  final void Function(String path) _onPathChanged;
  final void Function()? _onRootsMutated;

  final List<String> _rootPaths = [];
  final Map<String, StreamSubscription<WatchEvent>> _rootWatchSubscriptions =
      {};

  List<String> get rootPaths => List.unmodifiable(_rootPaths);

  Future<List<String>> loadRootPaths({
    Future<bool> Function(String path)? hasPersistentAccess,
    Future<void> Function(String path)? forgetPersistentAccess,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList('root_paths') ?? [];
    final normalizedPaths = ScannerPathUtils.normalizeDeclaredRootPaths(paths);

    final removedPaths = <String>[];
    final retainedPaths = <String>[];
    for (final path in normalizedPaths) {
      var keepPath = true;
      if (hasPersistentAccess != null) {
        try {
          keepPath = await hasPersistentAccess(path);
        } catch (e) {
          debugPrint('Persistent access check failed for $path: $e');
          keepPath = false;
        }
      }

      if (keepPath) {
        retainedPaths.add(path);
        continue;
      }

      removedPaths.add(path);
      if (forgetPersistentAccess != null) {
        try {
          await forgetPersistentAccess(path);
        } catch (e) {
          debugPrint('Persistent access cleanup failed for $path: $e');
        }
      }
    }

    _rootPaths
      ..clear()
      ..addAll(retainedPaths);
    _onRootsMutated?.call();
    if (removedPaths.isNotEmpty) {
      await saveRootPaths();
    }
    await refreshRootWatchers();
    return removedPaths;
  }

  Future<void> saveRootPaths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('root_paths', _rootPaths);
  }

  Future<void> setRootPaths(Iterable<String> paths) async {
    final normalizedRoots = ScannerPathUtils.normalizeDeclaredRootPaths(paths);
    _rootPaths
      ..clear()
      ..addAll(normalizedRoots);
    _onRootsMutated?.call();
    await saveRootPaths();
    await refreshRootWatchers();
  }

  Future<void> refreshRootWatchers() async {
    if (_isDisposed()) return;

    final desiredRoots = ScannerPathUtils.computeScanRoots(_rootPaths);
    debugPrint(
      '[ScannerServiceRoots] refreshRootWatchers desiredRoots=$desiredRoots',
    );
    final desiredKeys = desiredRoots
        .map(ScannerPathUtils.pathLookupKey)
        .toSet();

    final existingKeys = _rootWatchSubscriptions.keys.toSet();
    final unchanged =
        existingKeys.length == desiredKeys.length &&
        existingKeys.containsAll(desiredKeys);
    if (unchanged) {
      return;
    }

    for (final subscription in _rootWatchSubscriptions.values) {
      await subscription.cancel();
    }
    _rootWatchSubscriptions.clear();

    for (final root in desiredRoots) {
      final directory = Directory(root);
      try {
        if (!directory.existsSync()) {
          debugPrint(
            '[ScannerServiceRoots] skip watcher for missing root=$root',
          );
          continue;
        }

        final key = ScannerPathUtils.pathLookupKey(root);
        final watcher = DirectoryWatcher(root);
        _rootWatchSubscriptions[key] = watcher.events.listen(
          (event) {
            final eventPath = event.path.trim();
            if (eventPath.isEmpty) {
              return;
            }
            _onPathChanged(eventPath);
          },
          onError: (err) {
            debugPrint('Root watcher error for $root: $err');
          },
        );
        debugPrint('[ScannerServiceRoots] watcher attached root=$root');
      } catch (e, st) {
        debugPrint(
          '[ScannerServiceRoots] failed to attach watcher root=$root: $e\n$st',
        );
      }
    }
  }

  void dispose() {
    for (final subscription in _rootWatchSubscriptions.values) {
      unawaited(subscription.cancel());
    }
    _rootWatchSubscriptions.clear();
  }
}
