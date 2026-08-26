import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../models/music_file.dart';
import '../../audio/audio_riverpod.dart';
import '../../sharing/sharing_riverpod.dart';
import '../clients/subsonic_client.dart';
import '../clients/webdav_client.dart';
import '../proxy/remote_media_resolver.dart';
import '../remote_server_models.dart';

enum RemoteDownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

class RemoteDownloadTask {
  final String id;
  final RemoteServer server;
  final MusicFile song;
  final String? trackId;
  final String? webDavPath;
  final String downloadUrl;
  final Map<String, String>? headers;
  final String targetPath;
  final RemoteDownloadStatus status;
  final int bytesDownloaded;
  final int totalBytes;
  final double speedBytesPerSec;
  final String? error;
  final DateTime createdAt;
  final DateTime? completedAt;

  RemoteDownloadTask({
    required this.id,
    required this.server,
    required this.song,
    this.trackId,
    this.webDavPath,
    required this.downloadUrl,
    this.headers,
    required this.targetPath,
    this.status = RemoteDownloadStatus.pending,
    this.bytesDownloaded = 0,
    this.totalBytes = 0,
    this.speedBytesPerSec = 0,
    this.error,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress =>
      totalBytes > 0 ? (bytesDownloaded / totalBytes).clamp(0.0, 1.0) : 0.0;
  bool get isSubsonic => server.type == RemoteServerType.subsonic;
  bool get isWebDav => server.type == RemoteServerType.webdav;

  RemoteDownloadTask copyWith({
    RemoteDownloadStatus? status,
    int? bytesDownloaded,
    int? totalBytes,
    double? speedBytesPerSec,
    String? error,
    DateTime? completedAt,
  }) {
    return RemoteDownloadTask(
      id: id,
      server: server,
      song: song,
      trackId: trackId,
      webDavPath: webDavPath,
      downloadUrl: downloadUrl,
      headers: headers,
      targetPath: targetPath,
      status: status ?? this.status,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
      error: error ?? this.error,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class RemoteDownloadNotifier extends Notifier<List<RemoteDownloadTask>> {
  static const int _maxConcurrent = 2;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 10),
    ),
  );

  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, int> _lastBytesMap = {};
  final Map<String, DateTime> _lastTimeMap = {};

  @override
  List<RemoteDownloadTask> build() {
    return [];
  }

  /// Resolves the destination directory for downloaded music.
  Future<String> getDownloadFolderPath() async {
    final settings = ref.read(settingsServiceProvider);
    if (settings.hasLanSharingFolderPath) {
      return settings.lanSharingFolderPath;
    }
    final sharingService = ref.read(sharingServiceProvider);
    return await sharingService.getDefaultSharingFolderPath();
  }

  String _sanitize(String? input, {String fallback = 'Unknown'}) {
    if (input == null || input.trim().isEmpty) return fallback;
    return input.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  /// Builds the local destination file path for a remote music track.
  Future<String> buildLocalTrackPath({
    required MusicFile song,
    required String baseFolder,
    RemoteServer? server,
  }) async {
    final artist = _sanitize(song.artist, fallback: 'Unknown Artist');
    final album = _sanitize(song.album, fallback: 'Unknown Album');
    final trackNum = song.trackNumber;
    final trackPrefix = trackNum != null && trackNum > 0
        ? '${trackNum.toString().padLeft(2, '0')} - '
        : '';
    final title = _sanitize(song.title ?? song.name, fallback: 'Track');

    String ext = '.mp3';
    if (song.path.isNotEmpty) {
      final uri = Uri.tryParse(song.path);
      final rawExt =
          uri != null ? p.extension(uri.path) : p.extension(song.path);
      if (rawExt.isNotEmpty && rawExt.length <= 5) {
        ext = rawExt;
      }
    }

    final filename = '$trackPrefix$title$ext';

    // If artist & album are unknown and it's a webdav server, organize under WebDAV folder
    if (artist == 'Unknown Artist' && album == 'Unknown Album' && server != null) {
      return p.join(baseFolder, 'WebDAV', _sanitize(server.name), filename);
    }

    return p.join(baseFolder, artist, album, filename);
  }

  /// Enqueues a single Subsonic track for download.
  Future<RemoteDownloadTask?> enqueueSubsonicTrack({
    required RemoteServer server,
    required String password,
    required MusicFile song,
    String? trackId,
  }) async {
    final client = SubsonicClient(server: server, password: password);
    final baseFolder = await getDownloadFolderPath();

    String actualTrackId = trackId ?? song.id.toString();
    if (trackId == null && song.path.contains('/track_')) {
      actualTrackId = song.path.split('/track_').last;
    }

    final targetPath = await buildLocalTrackPath(
      song: song,
      baseFolder: baseFolder,
      server: server,
    );

    final taskId = 'subsonic_${server.id}_$actualTrackId';

    // If already in queue, don't duplicate
    final existingIndex = state.indexWhere((t) => t.id == taskId);
    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      if (existing.status == RemoteDownloadStatus.completed) {
        return existing;
      }
      if (existing.status == RemoteDownloadStatus.failed ||
          existing.status == RemoteDownloadStatus.cancelled ||
          existing.status == RemoteDownloadStatus.paused) {
        retryTask(taskId);
        return state.firstWhere((t) => t.id == taskId);
      }
      return existing;
    }

    // Check if target file already exists locally
    final targetFile = File(targetPath);
    if (targetFile.existsSync() && targetFile.lengthSync() > 0) {
      final task = RemoteDownloadTask(
        id: taskId,
        server: server,
        song: song,
        trackId: actualTrackId,
        downloadUrl: client.buildDownloadUrl(actualTrackId),
        targetPath: targetPath,
        status: RemoteDownloadStatus.completed,
        bytesDownloaded: targetFile.lengthSync(),
        totalBytes: targetFile.lengthSync(),
        completedAt: DateTime.now(),
      );
      state = [task, ...state];
      return task;
    }

    final downloadUrl = client.buildDownloadUrl(actualTrackId);
    final task = RemoteDownloadTask(
      id: taskId,
      server: server,
      song: song,
      trackId: actualTrackId,
      downloadUrl: downloadUrl,
      targetPath: targetPath,
      status: RemoteDownloadStatus.pending,
    );

    state = [...state, task];
    _processQueue();
    return task;
  }

  /// Enqueues multiple Subsonic tracks.
  Future<List<RemoteDownloadTask>> enqueueSubsonicTracks({
    required RemoteServer server,
    required String password,
    required List<MusicFile> songs,
    String? collectionName,
  }) async {
    final List<RemoteDownloadTask> enqueued = [];
    for (final song in songs) {
      final task = await enqueueSubsonicTrack(
        server: server,
        password: password,
        song: song,
      );
      if (task != null) {
        enqueued.add(task);
      }
    }
    return enqueued;
  }

  /// Enqueues a WebDAV file for download.
  Future<RemoteDownloadTask?> enqueueWebDavFile({
    required RemoteServer server,
    required String password,
    required WebDavFile file,
  }) async {
    final client = WebDavClient(server: server, password: password);
    final baseFolder = await getDownloadFolderPath();
    final song = RemoteMediaResolver.buildMusicFileFromWebDav(file, server);

    final targetPath = await buildLocalTrackPath(
      song: song,
      baseFolder: baseFolder,
      server: server,
    );

    final taskId = 'webdav_${server.id}_${file.path.hashCode}';

    // If already in queue, don't duplicate
    final existingIndex = state.indexWhere((t) => t.id == taskId);
    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      if (existing.status == RemoteDownloadStatus.completed) {
        return existing;
      }
      if (existing.status == RemoteDownloadStatus.failed ||
          existing.status == RemoteDownloadStatus.cancelled ||
          existing.status == RemoteDownloadStatus.paused) {
        retryTask(taskId);
        return state.firstWhere((t) => t.id == taskId);
      }
      return existing;
    }

    // Check if target file already exists locally
    final targetFile = File(targetPath);
    if (targetFile.existsSync() && targetFile.lengthSync() > 0) {
      final task = RemoteDownloadTask(
        id: taskId,
        server: server,
        song: song,
        webDavPath: file.path,
        downloadUrl: client.buildFullUrl(file.path),
        headers: client.authHeaders,
        targetPath: targetPath,
        status: RemoteDownloadStatus.completed,
        bytesDownloaded: targetFile.lengthSync(),
        totalBytes: targetFile.lengthSync(),
        completedAt: DateTime.now(),
      );
      state = [task, ...state];
      return task;
    }

    final downloadUrl = client.buildFullUrl(file.path);
    final task = RemoteDownloadTask(
      id: taskId,
      server: server,
      song: song,
      webDavPath: file.path,
      downloadUrl: downloadUrl,
      headers: client.authHeaders,
      targetPath: targetPath,
      status: RemoteDownloadStatus.pending,
      totalBytes: file.contentLength,
    );

    state = [...state, task];
    _processQueue();
    return task;
  }

  /// Enqueues multiple WebDAV files.
  Future<List<RemoteDownloadTask>> enqueueWebDavFiles({
    required RemoteServer server,
    required String password,
    required List<WebDavFile> files,
  }) async {
    final List<RemoteDownloadTask> enqueued = [];
    for (final file in files) {
      if (!file.isDirectory && file.isAudio) {
        final task = await enqueueWebDavFile(
          server: server,
          password: password,
          file: file,
        );
        if (task != null) {
          enqueued.add(task);
        }
      }
    }
    return enqueued;
  }

  /// Concurrency scheduler: starts pending tasks up to [_maxConcurrent].
  void _processQueue() {
    final activeDownloadingCount =
        state.where((t) => t.status == RemoteDownloadStatus.downloading).length;

    if (activeDownloadingCount >= _maxConcurrent) {
      return;
    }

    final slotsAvailable = _maxConcurrent - activeDownloadingCount;
    final pendingTasks = state
        .where((t) => t.status == RemoteDownloadStatus.pending)
        .take(slotsAvailable)
        .toList();

    for (final task in pendingTasks) {
      _startDownload(task);
    }
  }

  Future<void> _startDownload(RemoteDownloadTask task) async {
    final cancelToken = CancelToken();
    _cancelTokens[task.id] = cancelToken;
    _lastBytesMap[task.id] = 0;
    _lastTimeMap[task.id] = DateTime.now();

    _updateTask(task.id, (t) => t.copyWith(
          status: RemoteDownloadStatus.downloading,
          error: null,
        ));

    final targetFile = File(task.targetPath);
    final tempPath = '${task.targetPath}.part';
    final tempFile = File(tempPath);

    try {
      final dir = targetFile.parent;
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      await _dio.download(
        task.downloadUrl,
        tempPath,
        cancelToken: cancelToken,
        options: Options(
          headers: task.headers,
        ),
        onReceiveProgress: (received, total) {
          final now = DateTime.now();
          final lastTime = _lastTimeMap[task.id] ?? now;
          final lastBytes = _lastBytesMap[task.id] ?? 0;
          final diffMs = now.difference(lastTime).inMilliseconds;

          double speed = 0.0;
          if (diffMs >= 500) {
            final byteDiff = received - lastBytes;
            speed = (byteDiff / (diffMs / 1000.0));
            _lastBytesMap[task.id] = received;
            _lastTimeMap[task.id] = now;
          }

          _updateTask(task.id, (t) {
            return t.copyWith(
              bytesDownloaded: received,
              totalBytes: total > 0 ? total : t.totalBytes,
              speedBytesPerSec: speed > 0 ? speed : t.speedBytesPerSec,
            );
          });
        },
      );

      if (tempFile.existsSync() && tempFile.lengthSync() > 0) {
        if (targetFile.existsSync()) {
          targetFile.deleteSync();
        }
        tempFile.renameSync(task.targetPath);

        // Ensure base directory is registered with scanner
        final baseFolder = await getDownloadFolderPath();
        final scanner = ref.read(scannerServiceProvider);
        await scanner.ready;
        if (!scanner.rootPaths.any((path) => p.equals(path, baseFolder))) {
          await scanner.addRootPath(baseFolder);
        }

        _cancelTokens.remove(task.id);
        _lastBytesMap.remove(task.id);
        _lastTimeMap.remove(task.id);

        _updateTask(task.id, (t) => t.copyWith(
              status: RemoteDownloadStatus.completed,
              bytesDownloaded: t.totalBytes > 0 ? t.totalBytes : tempFile.lengthSync(),
              speedBytesPerSec: 0,
              completedAt: DateTime.now(),
            ));
      } else {
        if (tempFile.existsSync()) tempFile.deleteSync();
        _cancelTokens.remove(task.id);
        _updateTask(task.id, (t) => t.copyWith(
              status: RemoteDownloadStatus.failed,
              error: 'Empty response received from server',
              speedBytesPerSec: 0,
            ));
      }
    } catch (e) {
      if (cancelToken.isCancelled) {
        // Paused or cancelled by user
        final current = state.firstWhere((t) => t.id == task.id, orElse: () => task);
        if (current.status != RemoteDownloadStatus.paused &&
            current.status != RemoteDownloadStatus.cancelled) {
          _updateTask(task.id, (t) => t.copyWith(
                status: RemoteDownloadStatus.cancelled,
                speedBytesPerSec: 0,
              ));
        }
      } else {
        debugPrint('[RemoteDownload] Download error for ${task.song.displayName}: $e');
        _updateTask(task.id, (t) => t.copyWith(
              status: RemoteDownloadStatus.failed,
              error: e.toString(),
              speedBytesPerSec: 0,
            ));
      }
      _cancelTokens.remove(task.id);
      _lastBytesMap.remove(task.id);
      _lastTimeMap.remove(task.id);
    }

    _processQueue();
  }

  void pauseTask(String id) {
    final token = _cancelTokens[id];
    if (token != null && !token.isCancelled) {
      token.cancel('User paused download');
    }
    _cancelTokens.remove(id);
    _updateTask(id, (t) => t.copyWith(
          status: RemoteDownloadStatus.paused,
          speedBytesPerSec: 0,
        ));
    _processQueue();
  }

  void resumeTask(String id) {
    _updateTask(id, (t) => t.copyWith(
          status: RemoteDownloadStatus.pending,
          error: null,
          speedBytesPerSec: 0,
        ));
    _processQueue();
  }

  void cancelTask(String id) {
    final token = _cancelTokens[id];
    if (token != null && !token.isCancelled) {
      token.cancel('User cancelled download');
    }
    _cancelTokens.remove(id);

    final task = state.firstWhere((t) => t.id == id, orElse: () => state.first);
    final tempFile = File('${task.targetPath}.part');
    if (tempFile.existsSync()) {
      try {
        tempFile.deleteSync();
      } catch (_) {}
    }

    state = state.where((t) => t.id != id).toList();
    _processQueue();
  }

  void retryTask(String id) {
    final token = _cancelTokens[id];
    if (token != null && !token.isCancelled) {
      token.cancel('Retrying');
    }
    _cancelTokens.remove(id);

    _updateTask(id, (t) => t.copyWith(
          status: RemoteDownloadStatus.pending,
          bytesDownloaded: 0,
          speedBytesPerSec: 0,
          error: null,
        ));
    _processQueue();
  }

  void pauseAll() {
    for (final task in state) {
      if (task.status == RemoteDownloadStatus.downloading ||
          task.status == RemoteDownloadStatus.pending) {
        final token = _cancelTokens[task.id];
        if (token != null && !token.isCancelled) {
          token.cancel('User paused all');
        }
        _cancelTokens.remove(task.id);
      }
    }
    state = state.map((t) {
      if (t.status == RemoteDownloadStatus.downloading ||
          t.status == RemoteDownloadStatus.pending) {
        return t.copyWith(
          status: RemoteDownloadStatus.paused,
          speedBytesPerSec: 0,
        );
      }
      return t;
    }).toList();
  }

  void resumeAll() {
    state = state.map((t) {
      if (t.status == RemoteDownloadStatus.paused ||
          t.status == RemoteDownloadStatus.failed) {
        return t.copyWith(
          status: RemoteDownloadStatus.pending,
          error: null,
          speedBytesPerSec: 0,
        );
      }
      return t;
    }).toList();
    _processQueue();
  }

  void cancelAll() {
    for (final task in state) {
      if (task.status == RemoteDownloadStatus.downloading ||
          task.status == RemoteDownloadStatus.pending ||
          task.status == RemoteDownloadStatus.paused) {
        final token = _cancelTokens[task.id];
        if (token != null && !token.isCancelled) {
          token.cancel('User cancelled all');
        }
        _cancelTokens.remove(task.id);

        final tempFile = File('${task.targetPath}.part');
        if (tempFile.existsSync()) {
          try {
            tempFile.deleteSync();
          } catch (_) {}
        }
      }
    }
    state = state.where((t) => t.status == RemoteDownloadStatus.completed).toList();
  }

  void clearCompleted() {
    state = state
        .where((t) =>
            t.status == RemoteDownloadStatus.downloading ||
            t.status == RemoteDownloadStatus.pending ||
            t.status == RemoteDownloadStatus.paused)
        .toList();
  }

  void removeTask(String id) {
    cancelTask(id);
  }

  void _updateTask(String id, RemoteDownloadTask Function(RemoteDownloadTask) updater) {
    state = [
      for (final task in state)
        if (task.id == id) updater(task) else task,
    ];
  }
}

final remoteDownloadTasksProvider =
    NotifierProvider<RemoteDownloadNotifier, List<RemoteDownloadTask>>(
  RemoteDownloadNotifier.new,
);

final activeDownloadsCountProvider = Provider<int>((ref) {
  final tasks = ref.watch(remoteDownloadTasksProvider);
  return tasks
      .where((t) =>
          t.status == RemoteDownloadStatus.downloading ||
          t.status == RemoteDownloadStatus.pending)
      .length;
});

final activeTotalSpeedProvider = Provider<double>((ref) {
  final tasks = ref.watch(remoteDownloadTasksProvider);
  return tasks
      .where((t) => t.status == RemoteDownloadStatus.downloading)
      .fold(0.0, (sum, t) => sum + t.speedBytesPerSec);
});

/// Legacy wrapper for backwards compatibility
final remoteDownloadServiceProvider = Provider<RemoteDownloadService>((ref) {
  return RemoteDownloadService(ref);
});

class RemoteDownloadService {
  final Ref _ref;
  RemoteDownloadService(this._ref);

  Future<String> getDownloadFolderPath() async {
    return _ref.read(remoteDownloadTasksProvider.notifier).getDownloadFolderPath();
  }

  Future<bool> downloadTrack({
    required RemoteServer server,
    required String password,
    required MusicFile song,
    required String trackId,
  }) async {
    final task = await _ref.read(remoteDownloadTasksProvider.notifier).enqueueSubsonicTrack(
          server: server,
          password: password,
          song: song,
          trackId: trackId,
        );
    return task != null;
  }

  Future<void> downloadTracks({
    required RemoteServer server,
    required String password,
    required List<MusicFile> songs,
    required String collectionName,
  }) async {
    await _ref.read(remoteDownloadTasksProvider.notifier).enqueueSubsonicTracks(
          server: server,
          password: password,
          songs: songs,
          collectionName: collectionName,
        );
  }
}
