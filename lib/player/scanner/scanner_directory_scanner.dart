import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'package:vynody/player/library/music_file_utils.dart';
import 'package:vynody/player/scanner/scanner_path_utils.dart';
import 'package:vynody/player/scanner/scanner_scan_support.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';

const Set<String> _windowsProtectedDirectoryNames = {
  r'$recycle.bin',
  'system volume information',
};

class ScannerDirectoryScanner {
  ScannerDirectoryScanner({
    required void Function(ScanProgressState scanState, String filePath)
    emitScanProgress,
  }) : _emitScanProgress = emitScanProgress;

  final void Function(ScanProgressState scanState, String filePath)
  _emitScanProgress;
  final bool _useInlineDiscovery =
      Platform.isMacOS ||
      Platform.isIOS ||
      ScannerPathUtils.isLikelyPackagedWindowsApp();

  Future<bool> _hasAndroidPermissions() async {
    if (!Platform.isAndroid) return true;
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return await Permission.audio.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } catch (e) {
      debugPrint('[ScannerDirectoryScanner] _hasAndroidPermissions check failed: $e');
      return false;
    }
  }

  Future<List<ScanDiscoveredFile>> discoverMusicFiles(
    String path,
    ScanProgressState scanState, {
    bool Function()? shouldCancel,
  }) async {
    debugPrint('[ScannerDirectoryScanner] discoverMusicFiles start path=$path');
    if (Platform.isAndroid) {
      final hasPermission = await _hasAndroidPermissions();
      if (!hasPermission) {
        debugPrint('[ScannerDirectoryScanner] Android system permission not granted. Checking SAF mapping for path=$path');
        final mapping = await AndroidSafStorageHelper.findBestMapping(path);
        if (mapping != null) {
          final treeUri = mapping.value;
          final displayPath = mapping.key;
          final relativeSubPath = p.relative(path, from: displayPath);
          debugPrint(
            '[ScannerDirectoryScanner] SAF mapping found: displayPath=$displayPath, '
            'treeUri=$treeUri, relativeSubPath=$relativeSubPath',
          );
          
          final relativePaths = await AndroidSafStorageHelper.listMusicFilesRecursively(
            treeUri,
            relativeSubPath: relativeSubPath == '.' ? '' : relativeSubPath,
          );
          
          final absolutePaths = relativePaths.map((rel) => p.join(displayPath, relativeSubPath == '.' ? '' : relativeSubPath, rel)).toList();
          debugPrint(
            '[ScannerDirectoryScanner] SAF discovery completed. Found ${absolutePaths.length} music files',
          );
          
          scanState.discoveredCount += absolutePaths.length;
          final discoveredFiles = <ScanDiscoveredFile>[];
          for (final file in absolutePaths) {
            _emitScanProgress(scanState, file);
            discoveredFiles.add(ScanDiscoveredFile(path: file));
          }
          return discoveredFiles;
        } else {
          debugPrint('[ScannerDirectoryScanner] No SAF mapping found for path=$path');
        }
      }
    }

    if (_useInlineDiscovery) {
      debugPrint('[ScannerDirectoryScanner] using inline discovery path=$path');
      final discoveredFiles = await _discoverMusicFilesInline(
        path,
        scanState,
        shouldCancel: shouldCancel,
      );
      debugPrint(
        '[ScannerDirectoryScanner] discoverMusicFiles finished via inline '
        'path=$path count=${discoveredFiles.length}',
      );
      return discoveredFiles;
    }
    try {
      final discoveredFiles = await _discoverMusicFilesWithIsolate(
        path,
        scanState,
        shouldCancel: shouldCancel,
      );
      debugPrint(
        '[ScannerDirectoryScanner] discoverMusicFiles finished via isolate '
        'path=$path count=${discoveredFiles.length}',
      );
      return discoveredFiles;
    } catch (e, st) {
      debugPrint(
        '[ScannerDirectoryScanner] isolate discovery failed for $path: $e\n$st',
      );
      final discoveredFiles = await _discoverMusicFilesInline(
        path,
        scanState,
        shouldCancel: shouldCancel,
      );
      debugPrint(
        '[ScannerDirectoryScanner] discoverMusicFiles finished via inline '
        'path=$path count=${discoveredFiles.length}',
      );
      return discoveredFiles;
    }
  }

  Future<List<ScanDiscoveredFile>> discoverMusicFilesInDirectory(
    String path,
    ScanProgressState scanState, {
    bool Function()? shouldCancel,
  }) async {
    debugPrint(
      '[ScannerDirectoryScanner] discoverMusicFilesInDirectory start '
      'path=$path',
    );
    final directory = Directory(path);
    if (!await directory.exists()) {
      debugPrint(
        '[ScannerDirectoryScanner] non-recursive discovery skipped missing '
        'path=$path',
      );
      return const <ScanDiscoveredFile>[];
    }

    final discoveredFiles = <ScanDiscoveredFile>[];
    try {
      await for (final entity in directory.list(followLinks: false)) {
        if (shouldCancel?.call() ?? false) {
          debugPrint(
            '[ScannerDirectoryScanner] non-recursive discovery cancelled '
            'path=$path discovered=${discoveredFiles.length}',
          );
          return discoveredFiles;
        }

        if (entity is File &&
            !_shouldSkipAppleDoubleFile(entity.path) &&
            MusicFileUtils.isMusicFilePath(entity.path)) {
          final filePath = entity.path;
          int? lastModified;
          try {
            lastModified = entity.lastModifiedSync().millisecondsSinceEpoch;
          } catch (_) {}
          discoveredFiles.add(
            ScanDiscoveredFile(path: filePath, lastModifiedTime: lastModified),
          );
          scanState.discoveredCount++;
          _emitScanProgress(scanState, filePath);
        }
      }
    } catch (e, st) {
      debugPrint(
        '[ScannerDirectoryScanner] non-recursive discovery list error '
        'path=$path: $e\n$st',
      );
    }

    debugPrint(
      '[ScannerDirectoryScanner] discoverMusicFilesInDirectory finished '
      'path=$path count=${discoveredFiles.length}',
    );
    return discoveredFiles;
  }

  Future<List<ScanDiscoveredFile>> _discoverMusicFilesWithIsolate(
    String path,
    ScanProgressState scanState, {
    bool Function()? shouldCancel,
  }) async {
    debugPrint(
      '[ScannerDirectoryScanner] spawning discovery isolate path=$path',
    );
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();
    final cancelPort = ReceivePort();
    final discoveredFiles = <ScanDiscoveredFile>[];

    Isolate? isolate;
    Timer? cancelTimer;
    try {
      isolate = await Isolate.spawn<_DirectoryDiscoveryRequest>(
        _discoverMusicFilesIsolateEntry,
        _DirectoryDiscoveryRequest(
          rootPath: path,
          replyPort: receivePort.sendPort,
          cancelPort: cancelPort.sendPort,
        ),
        onError: errorPort.sendPort,
        onExit: exitPort.sendPort,
        errorsAreFatal: true,
      );

      final completer = Completer<List<ScanDiscoveredFile>>();
      late final StreamSubscription receiveSub;
      late final StreamSubscription errorSub;
      late final StreamSubscription exitSub;
      late final StreamSubscription cancelSub;
      var finished = false;
      var cancelPending = false;
      var cancelSignalSent = false;
      SendPort? isolateCancelPort;

      void requestCancel() {
        if (cancelSignalSent) {
          return;
        }
        cancelPending = true;
        if (isolateCancelPort == null) {
          debugPrint(
            '[ScannerDirectoryScanner] cancel requested before isolate '
            'port ready path=$path',
          );
          return;
        }
        cancelSignalSent = true;
        isolateCancelPort!.send(true);
        debugPrint(
          '[ScannerDirectoryScanner] cancel signal sent to isolate path=$path',
        );
      }

      void completeSuccess() {
        if (finished) return;
        finished = true;
        completer.complete(discoveredFiles);
      }

      void completeError(Object error, [StackTrace? st]) {
        if (finished) return;
        finished = true;
        completer.completeError(error, st);
      }

      cancelSub = cancelPort.listen((message) {
        if (message is SendPort) {
          isolateCancelPort = message;
          debugPrint(
            '[ScannerDirectoryScanner] isolate cancel port ready path=$path',
          );
          if (cancelPending && !cancelSignalSent) {
            cancelSignalSent = true;
            isolateCancelPort!.send(true);
            debugPrint(
              '[ScannerDirectoryScanner] pending cancel delivered '
              'to isolate path=$path',
            );
          }
        }
      });

      receiveSub = receivePort.listen((message) {
        if (message is! Map) {
          return;
        }
        if (shouldCancel?.call() ?? false) {
          requestCancel();
        }
        final type = message['type'];
        if (type == _DirectoryDiscoveryMessage.batchType) {
          final rawFiles = message['files'];
          if (rawFiles is! List) {
            return;
          }
          final batch = <ScanDiscoveredFile>[];
          for (final item in rawFiles) {
            if (item is Map) {
              final filePath = item['path'] as String?;
              final mtime = item['mtime'] as int?;
              if (filePath != null) {
                batch.add(
                  ScanDiscoveredFile(path: filePath, lastModifiedTime: mtime),
                );
              }
            }
          }
          if (batch.isEmpty) {
            return;
          }
          discoveredFiles.addAll(batch);
          scanState.discoveredCount += batch.length;
          _emitScanProgress(scanState, batch.last.path);
          return;
        }
        if (type == _DirectoryDiscoveryMessage.doneType) {
          completeSuccess();
        }
      });

      errorSub = errorPort.listen((message) {
        if (message is List && message.isNotEmpty) {
          final error = message.first;
          final stackTrace = message.length > 1 && message[1] is String
              ? StackTrace.fromString(message[1] as String)
              : null;
          completeError(
            error is Object ? error : Exception(error.toString()),
            stackTrace,
          );
          return;
        }
        completeError(Exception('Directory discovery isolate failed.'));
      });

      exitSub = exitPort.listen((_) {
        if (!finished) {
          completeError(Exception('Directory discovery isolate exited early.'));
        }
      });

      if (shouldCancel != null) {
        cancelTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
          if (finished || cancelSignalSent) {
            return;
          }
          if (shouldCancel()) {
            requestCancel();
          }
        });
      }

      try {
        return await completer.future;
      } finally {
        cancelTimer?.cancel();
        await cancelSub.cancel();
        await receiveSub.cancel();
        await errorSub.cancel();
        await exitSub.cancel();
      }
    } finally {
      receivePort.close();
      errorPort.close();
      exitPort.close();
      cancelPort.close();
      isolate?.kill(priority: Isolate.immediate);
    }
  }

  Future<List<ScanDiscoveredFile>> _discoverMusicFilesInline(
    String path,
    ScanProgressState scanState, {
    bool Function()? shouldCancel,
  }) async {
    final rootDir = Directory(path);
    if (!await rootDir.exists()) {
      debugPrint(
        '[ScannerDirectoryScanner] inline discovery skipped missing path=$path',
      );
      return const <ScanDiscoveredFile>[];
    }

    if (Platform.isMacOS || Platform.isIOS) {
      return _discoverMusicFilesInlineForApple(
        rootDir,
        scanState,
        shouldCancel: shouldCancel,
      );
    }

    const yieldEvery = 256;
    final pendingDirectories = ListQueue<(String, int)>()..add((path, 0));
    final discoveredFiles = <ScanDiscoveredFile>[];
    var processedEntries = 0;
    final visited = <String>{};
    String rootCanonical;
    try {
      rootCanonical = Directory(path).resolveSymbolicLinksSync();
    } catch (_) {
      rootCanonical = path;
    }
    visited.add(rootCanonical);

    while (pendingDirectories.isNotEmpty) {
      if (shouldCancel?.call() ?? false) {
        debugPrint(
          '[ScannerDirectoryScanner] inline discovery cancelled before next '
          'directory path=$path discovered=${discoveredFiles.length}',
        );
        break;
      }
      final (currentPath, currentDepth) = pendingDirectories.removeFirst();
      if (currentDepth > 64) {
        debugPrint(
          '[ScannerDirectoryScanner] Max directory depth reached, skipping: $currentPath',
        );
        continue;
      }
      final dir = Directory(currentPath);
      try {
        await for (final entity in dir.list(followLinks: false)) {
          if (shouldCancel?.call() ?? false) {
            debugPrint(
              '[ScannerDirectoryScanner] inline discovery cancelled during '
              'listing root=$path current=$currentPath '
              'discovered=${discoveredFiles.length}',
            );
            return discoveredFiles;
          }
          if (entity is Directory) {
            if (_shouldSkipDirectory(entity.path)) {
              continue;
            }
            String canonicalPath;
            try {
              canonicalPath = entity.resolveSymbolicLinksSync();
            } catch (_) {
              canonicalPath = entity.path;
            }
            if (visited.add(canonicalPath)) {
              pendingDirectories.add((entity.path, currentDepth + 1));
            }
          } else if (entity is File &&
              !_shouldSkipAppleDoubleFile(entity.path) &&
              MusicFileUtils.isMusicFilePath(entity.path)) {
            final filePath = entity.path;
            int? lastModified;
            try {
              lastModified = entity.lastModifiedSync().millisecondsSinceEpoch;
            } catch (_) {}
            discoveredFiles.add(
              ScanDiscoveredFile(path: filePath, lastModifiedTime: lastModified),
            );
            scanState.discoveredCount++;
            _emitScanProgress(scanState, filePath);
          }

          processedEntries++;
          if (processedEntries % yieldEvery == 0) {
            await Future<void>.delayed(Duration.zero);
          }
        }
      } catch (e, st) {
        debugPrint(
          '[ScannerDirectoryScanner] inline discovery list error '
          'root=$path current=$currentPath: $e\n$st',
        );
      }
    }

    return discoveredFiles;
  }

  Future<List<ScanDiscoveredFile>> _discoverMusicFilesInlineForApple(
    Directory rootDir,
    ScanProgressState scanState, {
    bool Function()? shouldCancel,
  }) async {
    final discoveredFiles = <ScanDiscoveredFile>[];
    var processedEntries = 0;

    await for (final entity in rootDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (shouldCancel?.call() ?? false) {
        debugPrint(
          '[ScannerDirectoryScanner] apple inline discovery cancelled '
          'root=${rootDir.path} discovered=${discoveredFiles.length}',
        );
        return discoveredFiles;
      }

      if (entity is File &&
          !_shouldSkipAppleDoubleFile(entity.path) &&
          MusicFileUtils.isMusicFilePath(entity.path)) {
        final filePath = entity.path;
        int? lastModified;
        try {
          lastModified = entity.lastModifiedSync().millisecondsSinceEpoch;
        } catch (_) {}
        discoveredFiles.add(
          ScanDiscoveredFile(path: filePath, lastModifiedTime: lastModified),
        );
        scanState.discoveredCount++;
        _emitScanProgress(scanState, filePath);
      }

      processedEntries++;
      if (processedEntries % 256 == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    return discoveredFiles;
  }
}

class _DirectoryDiscoveryRequest {
  const _DirectoryDiscoveryRequest({
    required this.rootPath,
    required this.replyPort,
    required this.cancelPort,
  });

  final String rootPath;
  final SendPort replyPort;
  final SendPort cancelPort;
}

class _DirectoryDiscoveryMessage {
  static const String batchType = 'batch';
  static const String doneType = 'done';
}

Future<void> _discoverMusicFilesIsolateEntry(
  _DirectoryDiscoveryRequest request,
) async {
  debugPrint(
    '[ScannerDirectoryScanner] isolate entry start path=${request.rootPath}',
  );
  final cancelReceivePort = ReceivePort();
  request.cancelPort.send(cancelReceivePort.sendPort);
  var cancelled = false;
  late final StreamSubscription cancelSub;
  cancelSub = cancelReceivePort.listen((_) {
    cancelled = true;
  });

  final rootDir = Directory(request.rootPath);
  if (!await rootDir.exists()) {
    debugPrint(
      '[ScannerDirectoryScanner] isolate discovery skipped missing '
      'path=${request.rootPath}',
    );
    await cancelSub.cancel();
    cancelReceivePort.close();
    request.replyPort.send(const {'type': _DirectoryDiscoveryMessage.doneType});
    return;
  }

  const batchSize = 128;
  final pendingDirectories = ListQueue<(String, int)>()..add((request.rootPath, 0));
  final batch = <Map<String, dynamic>>[];
  final visited = <String>{};
  String rootCanonical;
  try {
    rootCanonical = Directory(request.rootPath).resolveSymbolicLinksSync();
  } catch (_) {
    rootCanonical = request.rootPath;
  }
  visited.add(rootCanonical);

  while (pendingDirectories.isNotEmpty && !cancelled) {
    final (currentPath, currentDepth) = pendingDirectories.removeFirst();
    if (currentDepth > 64) {
      debugPrint(
        '[ScannerDirectoryScanner] Max directory depth reached, skipping: $currentPath',
      );
      continue;
    }
    final dir = Directory(currentPath);
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (cancelled) {
          break;
        }
        if (entity is Directory) {
          if (_shouldSkipDirectory(entity.path)) {
            continue;
          }
          String canonicalPath;
          try {
            canonicalPath = entity.resolveSymbolicLinksSync();
          } catch (_) {
            canonicalPath = entity.path;
          }
          if (visited.add(canonicalPath)) {
            pendingDirectories.add((entity.path, currentDepth + 1));
          }
        } else if (entity is File &&
            !_shouldSkipAppleDoubleFile(entity.path) &&
            MusicFileUtils.isMusicFilePath(entity.path)) {
          int? lastModified;
          try {
            lastModified = entity.lastModifiedSync().millisecondsSinceEpoch;
          } catch (_) {}
          batch.add({'path': entity.path, 'mtime': lastModified});
          if (batch.length >= batchSize) {
            request.replyPort.send({
              'type': _DirectoryDiscoveryMessage.batchType,
              'files': List<Map<String, dynamic>>.from(batch),
            });
            batch.clear();
          }
        }
      }
    } catch (e, st) {
      debugPrint(
        '[ScannerDirectoryScanner] isolate discovery list error '
        'root=${request.rootPath} current=$currentPath: $e\n$st',
      );
    }
  }

  if (batch.isNotEmpty) {
    request.replyPort.send({
      'type': _DirectoryDiscoveryMessage.batchType,
      'files': List<Map<String, dynamic>>.from(batch),
    });
  }

  await cancelSub.cancel();
  cancelReceivePort.close();
  if (cancelled) {
    debugPrint(
      '[ScannerDirectoryScanner] isolate discovery cancelled '
      'path=${request.rootPath}',
    );
  }
  request.replyPort.send(const {'type': _DirectoryDiscoveryMessage.doneType});
}

bool _shouldSkipDirectory(String path) {
  final name = p.basename(path);
  if (name.isEmpty) {
    return false;
  }
  if (name.startsWith('.')) {
    return true;
  }
  if (Platform.isWindows &&
      _windowsProtectedDirectoryNames.contains(name.toLowerCase())) {
    return true;
  }
  return false;
}

bool _shouldSkipAppleDoubleFile(String path) {
  return (Platform.isMacOS || Platform.isIOS) &&
      MusicFileUtils.isAppleDoubleFilePath(path);
}
