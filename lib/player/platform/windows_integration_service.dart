import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import 'package:smtc_windows/smtc_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/utils/app_log.dart';

class WindowsIntegrationService with WindowListener {
  final AudioService audioService;
  SMTCWindows? _smtc;
  StreamSubscription? _smtcSubscription;
  bool _disposed = false;
  bool _taskbarReady = false;
  bool _taskbarInitScheduled = false;
  bool? _lastIsPlaying;
  Duration _lastPosition = Duration.zero;

  HttpServer? _artworkServer;
  int? _artworkServerPort;

  WindowsIntegrationService(this.audioService) {
    if (!Platform.isWindows) return;
    _init();
  }

  void _init() {
    _smtc = SMTCWindows();

    _smtcSubscription = _smtc?.buttonPressStream.listen((event) {
      switch (event) {
        case PressedButton.play:
          audioService.togglePlay();
          break;
        case PressedButton.pause:
          audioService.togglePlay();
          break;
        case PressedButton.next:
          audioService.next();
          break;
        case PressedButton.previous:
          audioService.previous();
          break;
        case PressedButton.stop:
          if (audioService.isPlaying) audioService.togglePlay();
          break;
        default:
          break;
      }
    });

    windowManager.addListener(this);
    _scheduleInitialTaskbarSetup();
    _startArtworkServer();
  }

  @override
  void onWindowRestore() {
    AppLog.log('[WindowsTaskbar] onWindowRestore triggered', mirrorToConsole: true);
    reapplyTaskbarButtons();
  }

  @override
  void onWindowFocus() {
    AppLog.log('[WindowsTaskbar] onWindowFocus triggered, taskbarReady=$_taskbarReady', mirrorToConsole: true);
    if (!_taskbarReady) {
      reapplyTaskbarButtons();
    }
  }

  void reapplyTaskbarButtons() {
    AppLog.log('[WindowsTaskbar] reapplyTaskbarButtons called, Platform.isWindows=${Platform.isWindows}, disposed=$_disposed', mirrorToConsole: true);
    if (!Platform.isWindows || _disposed) return;
    _taskbarReady = false;
    _taskbarInitScheduled = false;
    _scheduleInitialTaskbarSetup();
  }

  Future<void> _startArtworkServer() async {
    try {
      _artworkServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _artworkServerPort = _artworkServer!.port;
      _artworkServer!.listen((HttpRequest request) async {
        try {
          final path = request.uri.queryParameters['path'];
          if (path == null) {
            request.response.statusCode = HttpStatus.notFound;
            await request.response.close();
            return;
          }
          final decodedPath = Uri.decodeComponent(path);
          final file = File(decodedPath);
          if (await file.exists()) {
            request.response.headers.contentType = ContentType('image', '*');
            await file.openRead().pipe(request.response);
          } else {
            request.response.statusCode = HttpStatus.notFound;
            await request.response.close();
          }
        } catch (e) {
          debugPrint('Error serving artwork: $e');
          request.response.statusCode = HttpStatus.internalServerError;
          await request.response.close();
        }
      });
      // Trigger update if there's already metadata loaded
      if (audioService.currentMusic != null) {
        updateMetadata(audioService.currentMusic);
      }
    } catch (e) {
      debugPrint('Failed to start artwork server: $e');
    }
  }

  void updateMetadata(MusicFile? song) {
    if (!Platform.isWindows || _smtc == null) return;

    _smtc?.updateMetadata(
      MusicMetadata(
        title: audioService.currentMusic?.displayName ?? 'Unknown',
        artist: audioService.currentMusic?.artist ?? 'Unknown',
        album: audioService.currentMusic?.album ?? 'Unknown',
        albumArtist: audioService.currentMusic?.artist ?? 'Unknown',
        thumbnail: () {
          final artPath = audioService.currentMusic?.artworkPath ??
              audioService.currentMusic?.thumbnailPath;
          if (artPath != null && File(artPath).existsSync()) {
            if (_artworkServerPort != null) {
              return 'http://127.0.0.1:$_artworkServerPort/cover?path=${Uri.encodeComponent(artPath)}';
            }
            return Uri.file(artPath).toString();
          }
          return null;
        }(),
      ),
    );
  }

  void updatePlaybackStatus(bool isPlaying) {
    if (!Platform.isWindows || _smtc == null || _disposed) return;

    // Only update if the status has actually changed
    if (_lastIsPlaying == isPlaying) return;
    _lastIsPlaying = isPlaying;

    _smtc?.setPlaybackStatus(
      isPlaying ? PlaybackStatus.playing : PlaybackStatus.paused,
    );

    _updateTaskbarButtons();
  }

  void updateTimeline(Duration position, Duration duration) {
    if (!Platform.isWindows || _smtc == null || _disposed) return;

    _smtc?.updateTimeline(
      PlaybackTimeline(
        positionMs: position.inMilliseconds,
        startTimeMs: 0,
        endTimeMs: duration.inMilliseconds,
      ),
    );

    if (!_taskbarReady) return;

    // Throttled taskbar progress update (every 1 second or if it's a significant change like a seek)
    final diff = (position - _lastPosition).abs().inMilliseconds;
    if (diff >= 1000 || diff < 0 || position == Duration.zero) {
      _lastPosition = position;
      unawaited(() async {
        try {
          if (!await windowManager.isVisible()) return;
          if (duration.inMilliseconds > 0) {
            await WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
            await WindowsTaskbar.setProgress(
              position.inMilliseconds,
              duration.inMilliseconds,
            );
          } else {
            await WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
          }
        } catch (e) {
          if (!e.toString().contains('Window is not visible')) {
            debugPrint('WindowsTaskbar progress error: $e');
          }
        }
      }());
    }
  }

  void _updateTaskbarButtons() {
    if (!Platform.isWindows || _disposed) return;

    if (!_taskbarReady) {
      _scheduleInitialTaskbarSetup();
      return;
    }

    unawaited(_setThumbnailToolbar());
  }

  void _scheduleInitialTaskbarSetup() {
    AppLog.log('[WindowsTaskbar] _scheduleInitialTaskbarSetup, taskbarInitScheduled=$_taskbarInitScheduled', mirrorToConsole: true);
    if (!Platform.isWindows || _disposed || _taskbarInitScheduled) return;
    _taskbarInitScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_disposed) {
        _taskbarInitScheduled = false;
        return;
      }
      AppLog.log('[WindowsTaskbar] PostFrameCallback starting _retrySetThumbnailToolbar', mirrorToConsole: true);
      await _retrySetThumbnailToolbar();
      if (_disposed) return;
      _taskbarInitScheduled = false;
    });
  }

  Future<void> _retrySetThumbnailToolbar() async {
    const retryDelays = <Duration>[
      Duration(milliseconds: 200),
      Duration(milliseconds: 600),
      Duration(milliseconds: 1200),
      Duration(milliseconds: 2400),
    ];

    for (var i = 0; i < retryDelays.length; i++) {
      if (_disposed || _taskbarReady) {
        AppLog.log('[WindowsTaskbar] _retrySetThumbnailToolbar loop exit: disposed=$_disposed, taskbarReady=$_taskbarReady', mirrorToConsole: true);
        return;
      }

      if (i > 0) {
        AppLog.log('[WindowsTaskbar] _retrySetThumbnailToolbar waiting ${retryDelays[i].inMilliseconds}ms for attempt $i', mirrorToConsole: true);
        await Future.delayed(retryDelays[i]);
        if (_disposed) return;
      }

      final isVisible = await windowManager.isVisible();
      AppLog.log('[WindowsTaskbar] Attempt $i setting toolbar, isVisible=$isVisible', mirrorToConsole: true);
      final success = await _setThumbnailToolbar(logError: i == retryDelays.length - 1);
      AppLog.log('[WindowsTaskbar] Attempt $i setThumbnailToolbar result=$success', mirrorToConsole: true);
      if (success) {
        return;
      }
    }
  }

  Future<bool> _setThumbnailToolbar({bool logError = true}) async {
    if (_disposed) return false;

    try {
      final visible = await windowManager.isVisible();
      if (!visible) {
        AppLog.log('[WindowsTaskbar] _setThumbnailToolbar skipped because window is not visible', mirrorToConsole: true);
        return false;
      }
      AppLog.log('[WindowsTaskbar] Calling WindowsTaskbar.setThumbnailToolbar...', mirrorToConsole: true);
      await WindowsTaskbar.setThumbnailToolbar([
        ThumbnailToolbarButton(
          ThumbnailToolbarAssetIcon('assets/icons/skip_previous.ico'),
          'Previous',
          audioService.previous,
        ),
        ThumbnailToolbarButton(
          audioService.isPlaying
              ? ThumbnailToolbarAssetIcon('assets/icons/pause.ico')
              : ThumbnailToolbarAssetIcon('assets/icons/play_arrow.ico'),
          audioService.isPlaying ? 'Pause' : 'Play',
          audioService.togglePlay,
        ),
        ThumbnailToolbarButton(
          ThumbnailToolbarAssetIcon('assets/icons/skip_next.ico'),
          'Next',
          audioService.next,
        ),
      ]);
      _taskbarReady = true;
      AppLog.log('[WindowsTaskbar] WindowsTaskbar.setThumbnailToolbar succeeded! _taskbarReady=true', mirrorToConsole: true);
      return true;
    } catch (e, stack) {
      _taskbarReady = false;
      AppLog.log('[WindowsTaskbar] _setThumbnailToolbar threw exception: $e\n$stack', mirrorToConsole: true);
      return false;
    }
  }

  void dispose() {
    if (!Platform.isWindows) return;
    _disposed = true;
    windowManager.removeListener(this);
    _smtcSubscription?.cancel();
    _smtc?.dispose();
    _artworkServer?.close(force: true);
  }
}
