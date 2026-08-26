import 'dart:async';
import 'package:collection/collection.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_core/audio_core.dart';
import 'package:path_provider/path_provider.dart';

import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_snapshot.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/audio/playback_source.dart';
import 'package:vynody/player/library/album_library.dart';
import 'package:vynody/player/library/artist_library.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/metadata/artwork_constants.dart';

import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/player/settings/theme_color_helper.dart';
import 'package:vynody/player/settings/track_artwork_theme_service.dart';
import 'package:vynody/player/settings/visualizer_options_service.dart';
import 'package:vynody/player/audio/playback_queue_processor.dart';
import 'package:vynody/player/audio/waveform_service.dart';
import 'package:vynody/player/platform/windows_integration_service.dart';
import 'package:vynody/player/platform/android_integration_service.dart';
import 'package:vynody/player/platform/darwin_integration_service.dart';
import 'package:vynody/player/platform/linux_integration_service.dart';
import 'package:vynody/player/platform/desktop_tray_service.dart';
import 'package:vynody/player/scanner/scanner_service.dart';
import 'package:vynody/player/library/playlist_service.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:vynody/utils/memory_trace.dart';
import 'package:vynody/player/lyrics/lyrics_controller.dart';
import 'package:vynody/player/lyrics/lyrics_controller_state.dart';
import 'package:vynody/player/lyrics/lyrics_controller_dependencies.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/playback_session_manager.dart';
import 'package:vynody/player/audio/queue_background_processor.dart';
import 'package:vynody/player/library/library_insights_service.dart';
import 'package:vynody/player/lyrics/lyrics_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vynody/player/remote/remote_server_riverpod.dart';
import 'package:vynody/player/remote/remote_service_providers.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';

class AudioService extends Notifier<AudioSnapshot> {
  static const String _volumeStorageKey = 'player_volume';
  static const String _previousVolumeStorageKey = 'player_previous_volume';
  static const String _isMutedStorageKey = 'player_is_muted';

  late final AudioCoreController _player;
  AppPlaybackMode _playbackMode = AppPlaybackMode.queue;
  PlaybackSource? _currentSource;
  bool _isHandlingQueueFinished = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 100.0;
  double _previousVolume = 100.0;
  bool _isMuted = false;
  final MetadataDatabase _db = MetadataDatabase();
  final List<MusicFile> _queue = [];
  int _currentIndex = -1;
  bool? _lastActionNext;
  bool _isTransitioning = false;
  DateTime _lastPlayerNotifyAt = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _lastNotifiedPosition = Duration.zero;
  Duration _lastNotifiedDuration = Duration.zero;
  bool? _lastNotifiedIsPlaying;
  int _lastNotifiedIndex = -1;
  String? _lastNotifiedFilePath;
  late final SettingsService settingsService;
  late final VisualizerOptionsService _visualizerOptions;
  late final PlaybackQueueProcessor _queueProcessor;
  late final WaveformService _waveformService;
  ScannerService? _scannerService;
  PlaylistService? _playlistService;
  void Function({required bool skipped})? _missingSongNoticeHandler;
  bool _isLyricsActive = false;
  Timer? _sleepTimer;
  DateTime? _sleepTimerEndAt;
  Duration? _sleepTimerDuration;
  bool _sleepTimerStopAfterCurrentSong = false;
  bool _sleepTimerWaitingForTrackEnd = false;
  String? _sleepTimerWaitingTrackPath;
  int _lastWaveformChunks = -1;
  StreamSubscription<List<double>>? _currentWaveformSubscription;
  bool _disposed = false;
  bool _restoringPlaybackSession = false;
  bool _playbackSessionReady = false;
  late final PlaybackSessionManager _sessionManager;
  late final QueueBackgroundProcessor _queueBackgroundProcessor;
  bool _userVisualizerEnabled = true;
  bool _isWindowMinimized = false;
  bool _isAppBackgrounded = false;
  AppLifecycleListener? _lifecycleListener;
  bool _initialVolumeApplied = false;
  bool _showVolumeHudForLastVolumeChange = true;
  late final VoidCallback _settingsListener;
  DateTime _lastPositionDebugLogAt = DateTime.fromMillisecondsSinceEpoch(0);
  String? _trackedPlaybackSongPath;
  bool _hasLoggedCurrentPlayback = false;
  Duration _lastPlaybackObservedPosition = Duration.zero;
  String? _lastMissingCurrentTrackPathHandled;

  Duration? _seekTargetPosition;
  bool _isSeeking = false;
  DateTime? _lastSeekTime;

  // 独立的 FFT 输出流（用于迷你播放器）
  VisualizerOutputStream? _miniPlayerFftStream;

  Color? _dynamicStartColor;
  Color? _dynamicEndColor;
  Map<String, Color> _currentThemeColorsMap = const {};
  late final WindowsIntegrationService? _windowsIntegration;
  late final AndroidIntegrationService? _androidIntegration;
  late final DarwinIntegrationService? _darwinIntegration;
  late final LinuxIntegrationService? _linuxIntegration;
  late final DesktopTrayService? _desktopTrayIntegration;
  String? _themePaletteRecomputeInProgressPath;

  WindowsIntegrationService? get windowsIntegration => _windowsIntegration;
  Color? get dynamicStartColor => _dynamicStartColor;
  Color? get dynamicEndColor => _dynamicEndColor;
  Map<String, Color> get currentThemeColorsMap => _currentThemeColorsMap;
  bool get isLyricsActive => _isLyricsActive;
  bool get isLyricsLoading => _lyricsState.isLyricsLoading;
  bool get hasLyrics => _lyricsState.hasLyrics;
  bool get lyricsSearchAttempted => _lyricsState.lyricsSearchAttempted;
  Duration? get sleepTimerRemaining {
    final endAt = _sleepTimerEndAt;
    if (endAt == null) {
      return _sleepTimerWaitingForTrackEnd ? Duration.zero : null;
    }

    final remaining = endAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      return Duration.zero;
    }
    return remaining;
  }

  Duration? get sleepTimerDuration => _sleepTimerDuration;
  bool get hasSleepTimer =>
      _sleepTimerEndAt != null || _sleepTimerWaitingForTrackEnd;
  bool get sleepTimerStopAfterCurrentSong => _sleepTimerStopAfterCurrentSong;

  @override
  AudioSnapshot build() {
    settingsService = ref.read(settingsServiceProvider);
    _volume = settingsService.prefs.getDouble(_volumeStorageKey) ?? 100.0;
    _previousVolume =
        settingsService.prefs.getDouble(_previousVolumeStorageKey) ?? 100.0;
    _isMuted = settingsService.prefs.getBool(_isMutedStorageKey) ?? false;

    final initialFadeEnabled = settingsService.enableFadeEffect;
    _player = AudioCoreController(
      fadeSettings: FadeSettings(
        fadeOnSwitch: initialFadeEnabled,
        fadeOnPauseResume: initialFadeEnabled,
        mode: FadeMode.crossfade,
      ),
      streamCacheManager: AudioStreamCacheManager(
        maxCacheSizeBytesGetter: () => settingsService.remoteCacheMaxSizeBytes,
      ),
    );

    _player.setUriResolver((rawUri) async {
      if (RemoteMediaResolver.isRemoteUri(rawUri)) {
        try {
          final storage = await ref.read(remoteServerStorageProvider.future);
          final proxy = ref.read(localStreamCacheProxyProvider);
          final resolver = RemoteMediaResolver(storage: storage, proxy: proxy);
          return await resolver.resolvePlayableSource(rawUri);
        } catch (e) {
          debugPrint('[AudioService] Custom URI resolver error: $e');
        }
      }
      return rawUri;
    });

    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        final nextBackgrounded =
            (state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden);
        if (_isAppBackgrounded != nextBackgrounded) {
          _isAppBackgrounded = nextBackgrounded;
          _updateEffectiveVisualizerState();
        }
      },
    );
    ref.onDispose(() {
      _lifecycleListener?.dispose();
    });

    ref.listen<bool>(isWindowMinimizedProvider, (previous, next) {
      _isWindowMinimized = next;
      _updateEffectiveVisualizerState();
    });
    _visualizerOptions = VisualizerOptionsService(
      controller: _player,
      settingsService: settingsService,
    );
    _waveformService = WaveformService(db: _db, player: _player);
    _queueProcessor = PlaybackQueueProcessor(
      db: _db,
      player: _player,
      settingsService: settingsService,
      waveformService: _waveformService,
    );
    _lastWaveformChunks = settingsService.waveformChunks;

    _sessionManager = PlaybackSessionManager();
    _queueBackgroundProcessor = QueueBackgroundProcessor(
      db: _db,
      queueProcessor: _queueProcessor,
    );

    _windowsIntegration = Platform.isWindows
        ? WindowsIntegrationService(this)
        : null;
    _androidIntegration = Platform.isAndroid
        ? AndroidIntegrationService(this)
        : null;
    _darwinIntegration = (Platform.isIOS || Platform.isMacOS)
        ? DarwinIntegrationService(this)
        : null;
    _linuxIntegration = Platform.isLinux ? LinuxIntegrationService(this) : null;
    _desktopTrayIntegration =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
        ? DesktopTrayService(
            audioService: this,
            settingsService: settingsService,
          )
        : null;
    _player.addListener(_handlePlayerChanges);
    _player.equalizer.addListener(notifyListeners);
    _settingsListener = () {
      if (_disposed) return;
      final fadeEnabled = settingsService.enableFadeEffect;
      final currentFade = _player.player.fadeSettings;
      if (currentFade.fadeOnSwitch != fadeEnabled ||
          currentFade.fadeOnPauseResume != fadeEnabled) {
        _player.player.setFadeSettings(
          FadeSettings(
            fadeOnSwitch: fadeEnabled,
            fadeOnPauseResume: fadeEnabled,
            mode: FadeMode.crossfade,
          ),
        );
      }

      final currentBandCount = settingsService.equalizerBandCount;
      if (_player.equalizerConfig.bandCount != currentBandCount) {
        _player.setEqualizerBandCount(currentBandCount);
        notifyListeners();
      }

      final currentWaveformChunks = settingsService.waveformChunks;
      if (_lastWaveformChunks != currentWaveformChunks) {
        _lastWaveformChunks = currentWaveformChunks;
        unawaited(_handleWaveformChunkChange());
        return;
      }

      unawaited(_refreshCurrentWaveform());
    };
    settingsService.addListener(_settingsListener);
    ref.onDispose(_dispose);
    unawaited(
      _player.initialize().then((_) async {
        if (_disposed) return;
        final bandCount = settingsService.equalizerBandCount;
        final savedEnabled = settingsService.equalizerEnabled;
        final savedGains = settingsService.equalizerGains;
        final savedPreamp = settingsService.equalizerPreamp;
        final savedBassBoost = settingsService.equalizerBassBoost;

        final gainsList = Float32List(EqualizerController.maxEqualizerBands);
        for (int i = 0;
            i < savedGains.length && i < EqualizerController.maxEqualizerBands;
            i++) {
          gainsList[i] = savedGains[i];
        }

        await _player.setEqualizerConfig(
          EqualizerConfig(
            enabled: savedEnabled,
            bandCount: bandCount,
            preampDb: savedPreamp,
            bassBoostDb: savedBassBoost,
            bassBoostFrequencyHz: EqualizerController.bassBoostFrequencyHz,
            bassBoostQ: EqualizerController.bassBoostQ,
            bandGainsDb: gainsList,
          ),
        );
        await _restorePlaybackSession();
        if (_disposed) return;

        final targetVolume = _isMuted ? 0.0 : _volume;
        await setVolume(targetVolume, showVolumeHud: false);
        _initialVolumeApplied = true;

        _visualizerOptions.loadOptions().then((_) => notifyListeners());
        if (_disposed) return;
        _initializeMiniPlayerFftStream();
      }),
    );
    return snapshot;
  }

  void notifyListeners() {
    if (_disposed) return;
    state = snapshot;
    _desktopTrayIntegration?.updateMenu();
  }

  Future<void> _restorePlaybackSession() async {
    if (_restoringPlaybackSession) return;
    _restoringPlaybackSession = true;
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        await ref.read(scannerServiceProvider).ready;
      }
      if (_queue.isNotEmpty || _currentSource != null) {
        debugPrint(
          'AudioService: queue is already occupied, skipping restorePlaybackSession',
        );
        _playbackSessionReady = true;
        return;
      }
      final session = await _sessionManager.loadFromPrefs(
        settingsService.prefs,
      );
      if (session == null) {
        _playbackSessionReady = true;
        return;
      }

      _stopPlaybackSessionAutoSaveTimer();
      await _player.playlist.resetPlaybackState();

      _queue
        ..clear()
        ..addAll(session.queue);

      if (Platform.isIOS || Platform.isMacOS) {
        for (final song in _queue) {
          if (!RemoteMediaResolver.isRemoteUri(song.path)) {
            await _player.registerPersistentAccess(path: song.path);
            await _player.beginScopedAccess(path: song.path);
          }
        }
      }

      _position = Duration.zero;
      _duration = Duration.zero;
      _isPlaying = false;
      _lastActionNext = null;
      _isTransitioning = false;
      _currentIndex = -1;
      _resetPlaybackTrackingForSong(null);
      notifyListeners();

      await _player.playlist.ensureQueuePlaylist();
      final tracks = _queue.map(_audioTrackForSong).toList(growable: false);
      await _player.playlist.addTracksToPlaylist(
        _player.playlist.queuePlaylistId,
        tracks,
        reconcile: false,
      );

      _playbackMode = session.playbackMode;
      _currentSource = session.source;
      _player.playlist.setMode(_playbackMode.toCoreMode());

      final restoredIndex =
          await PlaybackSessionManager.resolveRestoredQueueIndex(session);
      if (restoredIndex >= 0) {
        _currentIndex = restoredIndex;
        await _player.playlist.setActivePlaylist(
          _player.playlist.queuePlaylistId,
          startIndex: restoredIndex,
          autoPlay: false,
        );

        await _restoreCurrentThemeColors();
        unawaited(_refreshCurrentWaveform());

        final maxPositionMs = _duration.inMilliseconds > 0
            ? _duration.inMilliseconds
            : (currentMusic?.durationMillis ?? 0);
        final safeMaxMs = maxPositionMs > 0
            ? maxPositionMs
            : (session.positionMs < 0 ? 0 : session.positionMs);
        final restorePosition = Duration(
          milliseconds: session.positionMs.clamp(0, safeMaxMs).toInt(),
        );
        if (restorePosition > Duration.zero) {
          await seek(restorePosition);
        }

        _position = restorePosition;
        _isPlaying = false;

        final currentSong = _queue[restoredIndex];
        final duration = _duration > Duration.zero
            ? _duration
            : Duration(milliseconds: currentSong.durationMillis ?? 0);
        _windowsIntegration?.updateMetadata(currentSong);
        _androidIntegration?.updateMetadata(currentSong);
        _darwinIntegration?.updateMetadata(currentSong);
        _linuxIntegration?.updateMetadata(currentSong);
        _windowsIntegration?.updatePlaybackStatus(_isPlaying);
        _androidIntegration?.updatePlaybackStatus(_isPlaying);
        _darwinIntegration?.updatePlaybackStatus(_isPlaying);
        _linuxIntegration?.updatePlaybackStatus(_isPlaying);
        _windowsIntegration?.updateTimeline(_position, duration);
        _androidIntegration?.updateTimeline(_position, duration);
        _darwinIntegration?.updateTimeline(_position, duration);
        _linuxIntegration?.updateTimeline(_position, duration);
        unawaited(_updateCurrentMetadata(currentSong));
      } else {
        _queue.clear();
        _currentIndex = -1;
        _position = Duration.zero;
        _duration = Duration.zero;
        _isPlaying = false;
        _isMuted = false;
        _lastActionNext = null;
        _isTransitioning = false;
        _resetPlaybackTrackingForSong(null);
        await _player.playlist.clear();
        await _sessionManager.clearFromPrefs(settingsService.prefs);
      }

      await _restoreRandomPlaybackSession(session.randomPlayback);

      _playbackSessionReady = true;
      _updatePlaybackSessionAutoSaveTimer();
      notifyListeners();
    } catch (e) {
      debugPrint('AudioService: failed to restore playback session: $e');
      _playbackSessionReady = true;
    } finally {
      _restoringPlaybackSession = false;
    }
  }

  Future<void> _restoreRandomPlaybackSession(RandomPlaybackData random) async {
    if (!random.enabled) {
      _player.playlist.setRandomPolicy(null);
      return;
    }

    _applyRandomPolicy(globalSongs: _queue);

    _player.playlist.restoreRandomPlaybackState(
      policy: _player.playlist.randomPolicy,
      history: random.history,
      historyCursor: random.historyCursor,
      deck: random.deck,
      deckCursor: random.deckCursor,
      deckSignature: random.deckSignature,
      stashedNextTrackId: random.stashedNextTrackId,
      stashedForTrackId: random.stashedForTrackId,
    );
  }

  Future<void> _restoreCurrentThemeColors() async {
    final song = currentMusic;
    if (song == null) {
      _dynamicStartColor = null;
      _dynamicEndColor = null;
      _currentThemeColorsMap = const {};
      notifyListeners();
      return;
    }

    final themeColorsBlob = song.themeColorsBlob;
    if (themeColorsBlob != null && themeColorsBlob.isNotEmpty) {
      _applyThemeColors(ThemeColorHelper.blobToColors(themeColorsBlob));
      notifyListeners();
      return;
    }

    await _updatePalette();
  }

  void _updatePlaybackSessionAutoSaveTimer() {
    if (!_playbackSessionReady || _disposed) return;

    final shouldRun = _queue.isNotEmpty && _isPlaying;
    if (shouldRun) {
      _sessionManager.ensureAutoSaveTimer(() => _persistPlaybackSession());
    } else {
      _sessionManager.stopAutoSaveTimer();
    }
  }

  void _stopPlaybackSessionAutoSaveTimer() {
    _sessionManager.stopAutoSaveTimer();
  }

  Future<void> _persistPlaybackSession({bool allowWhenDisposed = false}) async {
    if ((_disposed && !allowWhenDisposed) ||
        _restoringPlaybackSession ||
        !_playbackSessionReady) {
      return;
    }

    final prefs = settingsService.prefs;
    if (_queue.isEmpty || _currentIndex < 0 || _currentIndex >= _queue.length) {
      await _sessionManager.clearFromPrefs(prefs);
      return;
    }

    final data = PlaybackSessionData(
      queue: _queue,
      currentIndex: _currentIndex,
      positionMs: _position.inMilliseconds,
      playbackMode: _playbackMode,
      randomPlayback: _captureRandomPlaybackSession(),
      source: _currentSource,
    );

    await _sessionManager.saveToPrefs(prefs, data);
    _updatePlaybackSessionAutoSaveTimer();
  }

  RandomPlaybackData _captureRandomPlaybackSession() {
    return RandomPlaybackData(
      enabled: isRandomMode,
      history: _player.playlist.randomHistory.toList(),
      historyCursor: _player.playlist.historyCursor,
      deck: List<String>.unmodifiable(_player.playlist.currentDeck),
      deckCursor: _player.playlist.deckCursor,
      deckSignature: _player.playlist.deckSignature,
      stashedNextTrackId: _player.playlist.stashedNextTrackId,
      stashedForTrackId: _player.playlist.stashedForTrackId,
    );
  }

  LyricsControllerDependencies get lyricsControllerDependencies {
    return LyricsControllerDependencies(
      db: _db,
      currentMusic: () => currentMusic,
      queue: () => _queue,
      currentIndex: () => _currentIndex,
      playerDuration: () => _duration,
      isLyricsActive: () => isLyricsActive,
      cacheSongDuration: _cacheSongDuration,
    );
  }

  LyricsController get _lyricsController {
    return ref.read(lyricsControllerProvider.notifier);
  }

  LyricsControllerState get _lyricsState {
    return ref.read(lyricsControllerProvider);
  }

  void _initializeMiniPlayerFftStream() {
    // 创建独立的 FFT 输出流，专用于迷你播放器
    _miniPlayerFftStream = _player.visualizer.createOutput(
      const VisualizerOutputConfig(
        id: 'mini_player',
        label: 'Mini Player',
        options: VisualizerOptimizationOptions(
          smoothingCoefficient: 0.2,
          gravityCoefficient: 3,
          logarithmicScale: 5.0,
          normalizationFloorDb: -75,
          aggregationMode: FftAggregationMode.peak,
          frequencyGroups: 128,
          targetFrameRate: 60,
          groupContrastExponent: 0.5,
          // skipHighFrequencyGroups: 10,
          // overallMultiplier: 1.2
        ),
      ),
    );
  }

  /// 独立的 FFT 流，用于迷你播放器
  Stream<FftFrame>? get miniPlayerFftStream => _miniPlayerFftStream?.fftStream;

  VisualizerOptionsService get visualizerOptions => _visualizerOptions;

  Future<void> saveVisualizerOptions() async {
    await _visualizerOptions.saveOptions();
  }

  void applyVisualizerSettings({required Orientation orientation}) {
    _visualizerOptions.applySettings(orientation: orientation);
    notifyListeners();
  }

  void setScannerService(ScannerService? scanner) {
    _scannerService = scanner;
  }

  void setPlaylistService(PlaylistService? playlistService) {
    _playlistService = playlistService;
  }

  void setSongMissingStateByPath(String path, bool isMissing) {
    var changed = false;
    for (var i = 0; i < _queue.length; i++) {
      final song = _queue[i];
      if (song.path != path || song.isMissing == isMissing) continue;
      _queue[i] = song.copyWith(isMissing: isMissing);
      changed = true;
    }

    if (changed) {
      if (isMissing &&
          currentMusic?.path == path &&
          !_isTransitioning &&
          _queue.isNotEmpty) {
        unawaited(_skipMissingCurrentTrack());
      } else {
        notifyListeners();
      }
    }
  }

  void setMissingSongNoticeHandler(
    void Function({required bool skipped})? handler,
  ) {
    _missingSongNoticeHandler = handler;
  }

  void _showMissingSongNotice({required bool skipped}) {
    _missingSongNoticeHandler?.call(skipped: skipped);
  }

  Future<bool> _songExists(String path) async {
    return PlaybackSessionManager.songExists(path);
  }

  Future<void> _skipMissingCurrentTrack() async {
    if (_isTransitioning || _queue.isEmpty || _currentIndex < 0) {
      return;
    }

    _isTransitioning = true;
    try {
      var attempts = 0;
      while (_queue.isNotEmpty && attempts < _queue.length) {
        if (_currentIndex < 0 || _currentIndex >= _queue.length) {
          break;
        }

        final current = _queue[_currentIndex];
        if (await _songExists(current.path)) {
          _lastMissingCurrentTrackPathHandled = null;
          await _syncCurrentPlaybackSong(current);
          return;
        }

        if (_lastMissingCurrentTrackPathHandled == current.path) {
          return;
        }
        _lastMissingCurrentTrackPathHandled = current.path;

        setSongMissingStateByPath(current.path, true);
        _showMissingSongNotice(skipped: true);

        final success = await _player.playlist.playNext();
        final newIndex = _player.playlist.currentIndex ?? -1;
        if (!success || newIndex < 0 || newIndex >= _queue.length) {
          await _player.player.pause(bypassGuard: true);
          _isPlaying = false;
          _currentIndex = -1;
          _duration = Duration.zero;
          _position = Duration.zero;
          _lastMissingCurrentTrackPathHandled = null;
          notifyListeners();
          return;
        }

        _currentIndex = newIndex;
        attempts++;
      }
    } finally {
      _isTransitioning = false;
      notifyListeners();
    }
  }

  MusicFile _songFromMetadata(
    MusicFile song,
    SongMetadata metadata, {
    Uint8List? artworkBytes,
  }) {
    return song.copyWith(
      title: metadata.title,
      artist: metadata.artist,
      album: metadata.album,
      trackNumber: metadata.trackNumber,
      thumbnailPath: metadata.thumbnailPath,
      artworkPath: metadata.artworkPath,
      artworkWidth: metadata.artworkWidth,
      artworkHeight: metadata.artworkHeight,
      themeColorsBlob: metadata.themeColorsBlob,
      waveformBlob: metadata.waveformBlob,
      artworkBytes: artworkBytes != null
          ? (artworkBytes.isEmpty ? null : artworkBytes)
          : song.artworkBytes,
      lastModifiedTime: metadata.lastModifiedTime,
      lyrics: song.lyrics,
    );
  }

  void _replaceQueueSongsByPath(String path, MusicFile updatedSong) {
    for (var i = 0; i < _queue.length; i++) {
      if (_queue[i].path == path) {
        _queue[i] = updatedSong.copyWith(
          lyrics: updatedSong.lyrics ?? _queue[i].lyrics,
        );
      }
    }
  }

  bool _hasMeaningfulTrackText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return false;
    }

    final lower = text.toLowerCase();
    return lower != 'unknown' &&
        lower != 'unknown artist' &&
        lower != 'unknown album';
  }

  bool _needsPlaybackMetadataRefresh(MusicFile song) {
    return !_hasMeaningfulTrackText(song.title) ||
        !_hasMeaningfulTrackText(song.artist) ||
        !_hasMeaningfulTrackText(song.album);
  }

  Future<MusicFile> _resolveMetadataForPlayback(MusicFile song) async {
    if (song.isMissing ||
        song.path.isEmpty ||
        RemoteMediaResolver.isRemoteUri(song.path) ||
        !File(song.path).existsSync()) {
      return song;
    }

    if (!_needsPlaybackMetadataRefresh(song)) {
      return song;
    }

    final result = await MetadataHelper.loadMetadataForPlayback(
      song.path,
      generateThumbnail: false,
    );
    if (result == null) {
      return song;
    }

    final metadata = result.$1;
    final artworkBytes = result.$2;
    final updatedSong = _songFromMetadata(
      song,
      metadata,
      artworkBytes: artworkBytes,
    );

    _replaceQueueSongsByPath(song.path, updatedSong);
    _scannerService?.updateMetadataForPath(
      metadata,
      artworkBytes: artworkBytes,
    );
    return updatedSong;
  }

  Future<void> _syncCurrentPlaybackSong(MusicFile song) async {
    _logPlaybackTrace(
      '_syncCurrentPlaybackSong start -> ${_debugSongLabel(song)} '
      'currentBefore=${_debugSongLabel(currentMusic)}',
    );
    if (_trackedPlaybackSongPath != song.path) {
      _resetPlaybackTrackingForSong(song);
      _position = Duration.zero;
    }
    await _updateCurrentMetadata(song);
    await _refreshCurrentWaveform(notify: false);
    _logPlaybackTrace(
      '_syncCurrentPlaybackSong end -> current=${_debugSongLabel(currentMusic)} '
      'queueIndex=$_currentIndex',
    );
  }

  void _resetPlaybackTrackingForSong(MusicFile? song) {
    _trackedPlaybackSongPath = song?.path;
    _hasLoggedCurrentPlayback = false;
    _lastPlaybackObservedPosition = Duration.zero;
    _lastMissingCurrentTrackPathHandled = null;
  }

  void _updatePlaybackTrackingForCurrentSong() {
    if (_isTransitioning) {
      return;
    }

    final song = currentMusic;
    if (song == null) {
      _resetPlaybackTrackingForSong(null);
      return;
    }

    if (_trackedPlaybackSongPath != song.path) {
      _resetPlaybackTrackingForSong(song);
      return;
    } else if (_position <= const Duration(seconds: 2) &&
        _lastPlaybackObservedPosition >= const Duration(seconds: 10)) {
      // Treat a jump back to the beginning after meaningful progress as a new play.
      _resetPlaybackTrackingForSong(song);
      return;
    }

    _lastPlaybackObservedPosition = _position;

    if (!_isPlaying || _hasLoggedCurrentPlayback) {
      return;
    }

    final durationMillis = _duration.inMilliseconds > 0
        ? _duration.inMilliseconds
        : (song.durationMillis ?? 0);
    final positionMillis = _position.inMilliseconds;
    final reachedPlaybackThreshold = positionMillis >= 5000;
    final reachedHalfway =
        durationMillis > 0 && positionMillis * 2 >= durationMillis;

    if (!reachedPlaybackThreshold && !reachedHalfway) {
      return;
    }

    _hasLoggedCurrentPlayback = true;
    unawaited(
      ref
          .read(libraryInsightsServiceProvider)
          .recordPlayback(
            song: song,
            playedAtMillis: DateTime.now().millisecondsSinceEpoch,
            playedDurationMillis: positionMillis,
            source: 'queue',
          )
          .catchError((Object error, StackTrace stackTrace) {
            _hasLoggedCurrentPlayback = false;
            debugPrint(
              'AudioService: failed to record playback for ${song.path}: $error',
            );
          }),
    );
  }

  Future<void> _prepareCurrentPlaybackArtwork(MusicFile song) async {
    final sw = Stopwatch()..start();
    MemoryTrace.snapshot(
      'audio:preparePlaybackArtwork',
      details: <String, Object?>{
        'path': song.path,
        'hasArtworkBytes': song.artworkBytes != null,
        'artwork': song.artworkPath ?? '-',
        'thumb': song.thumbnailPath ?? '-',
      },
    );
    try {
      _logPlaybackTrace(
        '_prepareCurrentPlaybackArtwork start -> ${_debugSongLabel(song)} '
        'currentBefore=${_debugSongLabel(currentMusic)}',
      );
      if (song.isMissing ||
          song.path.isEmpty ||
          (!RemoteMediaResolver.isRemoteUri(song.path) &&
              !File(song.path).existsSync())) {
        return;
      }

      Uint8List? artworkBytes = song.artworkBytes;
      String? artworkPath = song.artworkPath;
      String? thumbnailPath = song.thumbnailPath;
      Uint8List? themeColorsBlob = song.themeColorsBlob;

      final artworkThemeService = TrackArtworkThemeService(db: _db);
      final dbMetadata = await _db.getSongMetadata(song.path);
      if (dbMetadata != null) {
        artworkPath ??= dbMetadata.artworkPath;
        thumbnailPath ??= dbMetadata.thumbnailPath;
        themeColorsBlob ??= dbMetadata.themeColorsBlob;

        final dbArtworkPath = dbMetadata.artworkPath;
        if (dbArtworkPath != null && dbArtworkPath.trim().isNotEmpty) {
          artworkPath = dbArtworkPath;
          try {
            final file = File(dbArtworkPath);
            if (await file.exists()) {
              final swRead = Stopwatch()..start();
              artworkBytes = await file.readAsBytes();
              debugPrint(
                '[PERF] Read artwork file took ${swRead.elapsedMilliseconds}ms, size=${artworkBytes.length} bytes',
              );
            }
          } catch (_) {}
        }
      }

      final isRemote = RemoteMediaResolver.isRemoteUri(song.path);
      if (!isRemote) {
        if (artworkBytes == null) {
          final swDecode = Stopwatch()..start();
          artworkBytes = await MetadataHelper.decodeEmbeddedArtwork(song.path);
          debugPrint(
            '[PERF] decodeEmbeddedArtwork took ${swDecode.elapsedMilliseconds}ms, size=${artworkBytes?.length ?? 0} bytes',
          );
        }

        if (thumbnailPath == null || themeColorsBlob == null) {
          final supportDir = await getApplicationSupportDirectory();
          final swTheme = Stopwatch()..start();
          final artworkTheme = await artworkThemeService.getTrackArtworkTheme(
            song.path,
            controller: _player,
            cacheRootPath: supportDir.path,
            saveLargeArtwork: false,
          );
          debugPrint(
            '[PERF] getTrackArtworkTheme took ${swTheme.elapsedMilliseconds}ms',
          );
          if (artworkTheme != null) {
            artworkPath ??=
                artworkTheme.artworkPath ?? artworkTheme.thumbnailPath;
            thumbnailPath = artworkTheme.thumbnailPath;
            themeColorsBlob = artworkTheme.themeColorsBlob;
          }
        }
      } else {
        if (thumbnailPath == null ||
            themeColorsBlob == null ||
            (artworkBytes == null && !File(thumbnailPath).existsSync())) {
          final supportDir = await getApplicationSupportDirectory();
          final swTheme = Stopwatch()..start();
          final songMeta = dbMetadata ??
              SongMetadata(
                path: song.path,
                title: song.title ?? song.name,
                artist: song.artist ?? 'Unknown Artist',
                album: song.album ?? 'Unknown Album',
                artworkPath: song.artworkPath,
              );
          final artworkTheme = await artworkThemeService.getTrackArtworkTheme(
            song.path,
            controller: _player,
            cacheRootPath: supportDir.path,
            saveLargeArtwork: false,
            existingMetadata: songMeta,
          );
          debugPrint(
            '[PERF] remote getTrackArtworkTheme took ${swTheme.elapsedMilliseconds}ms',
          );
          if (artworkTheme != null) {
            artworkPath ??=
                artworkTheme.artworkPath ?? artworkTheme.thumbnailPath;
            thumbnailPath = artworkTheme.thumbnailPath;
            themeColorsBlob = artworkTheme.themeColorsBlob;
          }
        }
      }

      // If we still don't have artworkBytes but we have a thumbnailPath, read it
      if (artworkBytes == null && thumbnailPath != null) {
        try {
          final file = File(thumbnailPath);
          if (await file.exists()) {
            artworkBytes = await file.readAsBytes();
          }
        } catch (_) {}
      }

      if (_currentIndex >= 0 && _currentIndex < _queue.length) {
        final currentSong = _queue[_currentIndex];
        if (currentSong.path == song.path) {
          _queue[_currentIndex] = currentSong.copyWith(
            artworkBytes: artworkBytes,
            artworkPath: artworkPath,
            thumbnailPath: thumbnailPath,
            themeColorsBlob: themeColorsBlob ?? currentSong.themeColorsBlob,
          );
          notifyListeners();
          _logPlaybackTrace(
            '_prepareCurrentPlaybackArtwork applied -> '
            'current=${_debugSongLabel(currentMusic)}',
          );
        }
      }

      if (artworkBytes != null && artworkBytes.isNotEmpty) {
        // Keep the hero destination image sharp without allowing a full-size
        // decode to block the transition.
        final isPc = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
        final int limit = isPc ? 1200 : 800;
        final provider = ResizeImage(
          MemoryImage(artworkBytes),
          width: limit,
          height: limit,
          allowUpscaling: false,
        );
        provider.resolve(ImageConfiguration.empty);
      }

      if (themeColorsBlob != null && themeColorsBlob.isNotEmpty) {
        _applyThemeColors(ThemeColorHelper.blobToColors(themeColorsBlob));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AudioService: hero artwork prep failed for ${song.path}: $e');
    } finally {
      MemoryTrace.snapshot(
        'audio:prepareArtwork:end',
        details: <String, Object?>{
          'path': song.path,
          'queue': _queue.length,
          'current': currentMusic?.path ?? '-',
        },
      );
      debugPrint(
        '[PERF] _prepareCurrentPlaybackArtwork TOTAL took ${sw.elapsedMilliseconds}ms',
      );
    }
  }

  Future<List<double>> getWaveform({
    int expectedChunks = 80,
    int sampleStride = 4,
  }) async {
    final path = currentMusic?.path;
    if (path == null) return [];

    return _waveformService.getWaveform(
      path: path,
      expectedChunks: expectedChunks,
      sampleStride: sampleStride,
    );
  }

  void _handlePlayerChanges() {
    _isPlaying = _player.player.isPlaying;
    _duration = _player.player.duration;

    if (_player.player.currentState == PlayerState.error) {
      final err = _player.player.error;
      debugPrint('[AudioService] Playback error state detected for track ${currentMusic?.title} (${currentMusic?.path}): $err');
    }

    final realPosition = _player.player.position;
    if (_isSeeking) {
      final target = _seekTargetPosition ?? Duration.zero;
      final difference = (realPosition - target).abs();
      final timeSinceSeek = _lastSeekTime != null
          ? DateTime.now().difference(_lastSeekTime!)
          : Duration.zero;

      if (difference < const Duration(seconds: 1) ||
          timeSinceSeek > const Duration(milliseconds: 1000)) {
        _isSeeking = false;
        _seekTargetPosition = null;
        _position = realPosition;
      } else {
        _position = target;
      }
    } else {
      _position = realPosition;
    }

    if (_initialVolumeApplied) {
      _volume = (_player.player.volume * 100.0).roundToDouble();
    }
    _logPositionDebug();

    if (_sleepTimerWaitingForTrackEnd &&
        _player.player.currentState == PlayerState.completed &&
        currentMusic?.path == _sleepTimerWaitingTrackPath) {
      _sleepTimerWaitingForTrackEnd = false;
      _sleepTimerWaitingTrackPath = null;
      _sleepTimerStopAfterCurrentSong = false;
      _sleepTimerDuration = null;
      unawaited(_stopPlaybackForSleepTimer());
      notifyListeners();
      return;
    }

    if (_player.player.currentState == PlayerState.completed &&
        !_player.playlist.hasNext &&
        _playbackMode == AppPlaybackMode.autoQueueLoop &&
        !_isHandlingQueueFinished) {
      unawaited(_handleQueueFinished());
      return;
    }

    final int newIndex = _player.playlist.currentIndex ?? -1;
    if (newIndex != _currentIndex && !_isTransitioning) {
      if (_sleepTimerWaitingForTrackEnd &&
          _sleepTimerWaitingTrackPath != null &&
          (newIndex < 0 ||
              newIndex >= _queue.length ||
              _queue[newIndex].path != _sleepTimerWaitingTrackPath)) {
        _player.cancelStopAfterCurrentTrack();
        _sleepTimerWaitingForTrackEnd = false;
        _sleepTimerWaitingTrackPath = null;
        _sleepTimerStopAfterCurrentSong = false;
      }
      // 检测到歌曲切换
      if (_currentIndex >= 0) {
        _lastActionNext = true; // 记录为自动切歌
      }
      _currentIndex = newIndex;
      _lastMissingCurrentTrackPathHandled = null;
      if (_currentIndex >= 0 && _currentIndex < _queue.length) {
        final song = _queue[_currentIndex];
        if (song.path.isNotEmpty &&
            !song.path.startsWith('content://') &&
            !RemoteMediaResolver.isRemoteUri(song.path) &&
            !File(song.path).existsSync()) {
          unawaited(_skipMissingCurrentTrack());
          return;
        }
        _logLyricsDebug(
          'track changed -> index=$_currentIndex title="${song.displayName}" '
          'path="${song.path}" duration=$_duration active=$isLyricsActive',
        );
        unawaited(
          // 发起元数据更新和后台处理
          _updateCurrentMetadata(song).then((_) {
            _windowsIntegration?.updateMetadata(_queue[newIndex]);
            _androidIntegration?.updateMetadata(_queue[newIndex]);
            _darwinIntegration?.updateMetadata(_queue[newIndex]);
            _linuxIntegration?.updateMetadata(_queue[newIndex]);
            _startQueueBackgroundProcessing();
          }),
        );
        unawaited(_refreshCurrentWaveform());
      }
      _notifyIfNeeded(force: true);
    }

    if (!_isTransitioning &&
        _currentIndex >= 0 &&
        _currentIndex < _queue.length &&
        _queue[_currentIndex].path.isNotEmpty &&
        !_queue[_currentIndex].path.startsWith('content://') &&
        !RemoteMediaResolver.isRemoteUri(_queue[_currentIndex].path) &&
        !(File(_queue[_currentIndex].path).existsSync())) {
      unawaited(_skipMissingCurrentTrack());
      return;
    }


    _windowsIntegration?.updateTimeline(_position, _duration);
    _androidIntegration?.updateTimeline(_position, _duration);
    _darwinIntegration?.updateTimeline(_position, _duration);
    _linuxIntegration?.updateTimeline(_position, _duration);
    _windowsIntegration?.updatePlaybackStatus(_isPlaying);
    _androidIntegration?.updatePlaybackStatus(_isPlaying);
    _darwinIntegration?.updatePlaybackStatus(_isPlaying);
    _linuxIntegration?.updatePlaybackStatus(_isPlaying);
    _updatePlaybackTrackingForCurrentSong();

    // 如果当前开启了歌词模式，但因为切歌瞬间加载太快（时长 Duration 还没准备好）
    // 导致 API 没匹配到或尚未开始加载，当时长变为有效正值时，自动触发补抓取。
    if (isLyricsActive &&
        currentMusic != null &&
        _duration > Duration.zero &&
        !hasLyrics &&
        !isLyricsLoading &&
        !_lyricsController.isLyricsGenerationForSong(currentMusic!.path) &&
        !lyricsSearchAttempted &&
        _currentIndex >= 0 &&
        _currentIndex < _queue.length) {
      final song = _queue[_currentIndex];
      if (song.path == currentMusic?.path) {
        _logLyricsDebug(
          'auto retry trigger -> index=$_currentIndex title="${song.displayName}" '
          'duration=$_duration hasLyrics=$hasLyrics loading=$isLyricsLoading '
          'searched=$lyricsSearchAttempted',
        );
        unawaited(_lyricsController.fetchAndLog(song));
      }
    }

    _notifyIfNeeded();
    _updatePlaybackSessionAutoSaveTimer();
  }

  void _notifyIfNeeded({bool force = false}) {
    final now = DateTime.now();
    final playbackChanged =
        _isPlaying != _lastNotifiedIsPlaying ||
        _duration != _lastNotifiedDuration ||
        _currentIndex != _lastNotifiedIndex ||
        currentMusic?.path != _lastNotifiedFilePath;
    final positionJump = (_position - _lastNotifiedPosition)
        .abs()
        .inMilliseconds;
    final positionChangedSignificantly = positionJump >= 120;
    final elapsed = now.difference(_lastPlayerNotifyAt);
    final shouldNotify =
        force ||
        playbackChanged ||
        positionChangedSignificantly ||
        (_isPlaying && elapsed >= const Duration(milliseconds: 120));

    if (!shouldNotify) return;

    _lastPlayerNotifyAt = now;
    _lastNotifiedPosition = _position;
    _lastNotifiedDuration = _duration;
    _lastNotifiedIsPlaying = _isPlaying;
    _lastNotifiedIndex = _currentIndex;
    _lastNotifiedFilePath = currentMusic?.path;
    notifyListeners();
  }

  void _logPositionDebug() {
    if (!kDebugMode) return;

    final now = DateTime.now();
    if (now.difference(_lastPositionDebugLogAt) < const Duration(seconds: 1)) {
      return;
    }
    _lastPositionDebugLogAt = now;

    // debugPrint(
    //   '[AudioService][Position] playing=$_isPlaying '
    //   'index=$_currentIndex '
    //   'pos=${_formatDuration(_position)} '
    //   'duration=${_formatDuration(_duration)} '
    //   'volume=${_volume.toStringAsFixed(1)} '
    //   'track=${currentMusic?.displayName ?? 'null'}',
    // );
  }

  bool? get isLastActionNext => _lastActionNext;
  bool get isTransitioning => _isTransitioning;

  @Deprecated('Use playbackController or dedicated AudioService wrappers.')
  AudioCoreController get player => _player;

  AudioCoreController get playbackController => _player;

  // Keep UI and platform adapters behind this facade so the player
  // implementation can change without spreading direct player access.
  bool get isVisualizerEnabled => _userVisualizerEnabled;

  Stream<FftFrame> get visualizerStream => _player.visualizer.optimizedStream;

  VisualizerOptimizationOptions get currentVisualizerOptions =>
      _player.visualizer.options;

  AppPlaybackMode get playbackMode => _playbackMode;

  EqualizerConfig get equalizerConfig => _player.equalizerConfig;

  void _updateEffectiveVisualizerState() {
    final bool effectiveEnabled =
        _userVisualizerEnabled && !_isAppBackgrounded && !_isWindowMinimized;
    _player.visualizer.setEnabled(effectiveEnabled);
    notifyListeners();
  }

  void setVisualizerEnabled(bool enabled) {
    _userVisualizerEnabled = enabled;
    _updateEffectiveVisualizerState();
  }

  void setPlaybackMode(AppPlaybackMode mode) {
    _playbackMode = mode;
    _player.playlist.setMode(mode.toCoreMode());
    notifyListeners();
    unawaited(_persistPlaybackSession());
  }

  /// 设置歌词模式是否激活。
  /// 当激活时，如果当前歌曲尚未加载歌词，则立即触发加载。
  void setLyricsActive(bool active) {
    if (isLyricsActive == active) return;
    _isLyricsActive = active;
    _logLyricsDebug(
      'lyrics mode ${active ? 'enabled' : 'disabled'} -> '
      'currentIndex=$_currentIndex duration=$_duration hasLyrics=$hasLyrics '
      'loading=$isLyricsLoading searched=$lyricsSearchAttempted',
    );

    if (isLyricsActive &&
        currentMusic?.path != null &&
        !hasLyrics &&
        !isLyricsLoading &&
        !_lyricsController.isLyricsGenerationForSong(currentMusic!.path)) {
      final song = (_currentIndex >= 0 && _currentIndex < _queue.length)
          ? _queue[_currentIndex]
          : null;
      if (song != null) {
        _logLyricsDebug(
          'lyrics mode immediate fetch -> index=$_currentIndex '
          'title="${song.displayName}" duration=$_duration',
        );
        _lyricsController.scheduleFetch(song);
      }
    }
    notifyListeners();
  }

  void _cancelSleepTimer({bool notify = true}) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerEndAt = null;
    _sleepTimerDuration = null;
    _player.cancelStopAfterCurrentTrack();
    _sleepTimerStopAfterCurrentSong = false;
    _sleepTimerWaitingForTrackEnd = false;
    _sleepTimerWaitingTrackPath = null;
    if (notify) {
      notifyListeners();
    }
  }

  void _tickSleepTimer() {
    final endAt = _sleepTimerEndAt;
    if (endAt == null) return;

    if (DateTime.now().isBefore(endAt)) {
      notifyListeners();
      return;
    }

    final shouldWaitForCurrentSong =
        _sleepTimerStopAfterCurrentSong &&
        _isPlaying &&
        _player.player.currentState != PlayerState.completed;

    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerEndAt = null;
    if (shouldWaitForCurrentSong) {
      _player.armStopAfterCurrentTrack();
      _sleepTimerWaitingForTrackEnd = true;
      _sleepTimerWaitingTrackPath = currentMusic?.path;
      notifyListeners();
      return;
    }

    _sleepTimerStopAfterCurrentSong = false;
    _sleepTimerWaitingForTrackEnd = false;
    _sleepTimerWaitingTrackPath = null;
    unawaited(_stopPlaybackForSleepTimer());
    notifyListeners();
  }

  Future<void> _stopPlaybackForSleepTimer() async {
    if (_isPlaying) {
      await _player.player.pause(bypassGuard: true);
    }
  }

  Future<void> startSleepTimer(
    Duration duration, {
    bool stopAfterCurrentSong = false,
  }) async {
    final normalized = Duration(
      milliseconds: duration.inMilliseconds < 0 ? 0 : duration.inMilliseconds,
    );
    if (normalized <= Duration.zero) {
      await cancelSleepTimer();
      return;
    }

    _sleepTimer?.cancel();
    _player.cancelStopAfterCurrentTrack();
    _sleepTimerWaitingForTrackEnd = false;
    _sleepTimerWaitingTrackPath = null;
    _sleepTimerStopAfterCurrentSong = stopAfterCurrentSong;
    _sleepTimerDuration = normalized;
    _sleepTimerEndAt = DateTime.now().add(normalized);
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickSleepTimer();
    });
    notifyListeners();
  }

  Future<void> cancelSleepTimer({bool notify = true}) async {
    _cancelSleepTimer(notify: notify);
  }

  void moveQueueTrack(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _queue.length ||
        newIndex < 0 ||
        newIndex >= _queue.length ||
        oldIndex == newIndex) {
      return;
    }

    final movedSong = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, movedSong);
    _player.playlist.moveTrack(oldIndex, newIndex);

    if (currentMusic?.path != null) {
      final updatedIndex = _queue.indexWhere(
        (song) => song.path == currentMusic?.path,
      );
      if (updatedIndex != -1) {
        _currentIndex = updatedIndex;
      }
    }

    _startQueueBackgroundProcessing();
    notifyListeners();
    unawaited(_persistPlaybackSession());
  }

  void ensureEqualizerBandCount(int bandCount) {
    if (_player.equalizerConfig.bandCount == bandCount) {
      return;
    }
    _player.setEqualizerBandCount(bandCount);
    settingsService.equalizerBandCount = bandCount;
    notifyListeners();
  }

  List<double> getEqualizerBandCenters({required int bandCount}) {
    return _player.getEqualizerBandCenters(bandCount: bandCount);
  }

  Future<void> setEqualizerEnabled(bool value) async {
    await _player.setEqualizerEnabled(value);
    settingsService.equalizerEnabled = value;
    notifyListeners();
  }

  Future<void> setEqualizerBandGain(int index, double value) async {
    await _player.setEqualizerBandGain(index, value);
    settingsService.equalizerGains =
        _player.equalizerConfig.bandGainsDb.toList();
    notifyListeners();
  }

  Future<void> setEqualizerBandGains(List<double> gains) async {
    await _player.setEqualizerBandGains(gains);
    settingsService.equalizerGains =
        _player.equalizerConfig.bandGainsDb.toList();
    notifyListeners();
  }

  Future<void> setBassBoost(double value) async {
    await _player.setBassBoost(value);
    settingsService.equalizerBassBoost = value;
    notifyListeners();
  }

  Future<void> setEqualizerPreamp(double value) async {
    await _player.setEqualizerPreamp(value);
    settingsService.equalizerPreamp = value;
    notifyListeners();
  }

  Future<void> resetEqualizerDefaults() async {
    _player.resetEqualizerDefaults();
    settingsService.equalizerEnabled = false;
    settingsService.equalizerGains = const [];
    settingsService.equalizerPreamp = 0.0;
    settingsService.equalizerBassBoost = 0.0;
    notifyListeners();
  }

  bool get isPlaying => _isPlaying;
  MusicFile? get currentMusic =>
      (_currentIndex >= 0 && _currentIndex < _queue.length)
      ? _queue[_currentIndex]
      : null;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get isMuted => _isMuted;

  List<MusicFile> get playbackQueue => List.unmodifiable(_queue);

  int get currentIndex => _currentIndex;

  bool get isRandomMode => _player.playlist.randomPolicy != null;
  AudioSnapshot get snapshot => AudioSnapshot(
    isPlaying: _isPlaying,
    isTransitioning: _isTransitioning,
    isLastActionNext: _lastActionNext,
    currentMusic: currentMusic,
    position: _position,
    duration: _duration,
    volume: _volume,
    isMuted: _isMuted,
    playbackQueue: List<MusicFile>.unmodifiable(_queue),
    currentIndex: _currentIndex,
    isRandomMode: isRandomMode,
    isShuffleRandomMode: isShuffleRandomMode,
    playbackMode: playbackMode,
    equalizerConfig: equalizerConfig,
    currentVisualizerOptions: currentVisualizerOptions,
    randomHistory: List<MusicFile>.unmodifiable(randomHistory),
    randomQueue: List<MusicFile>.unmodifiable(randomQueue),
    historyCursor: historyCursor,
    deckCursor: deckCursor,
    isVisualizerEnabled: isVisualizerEnabled,
    dynamicStartColor: _dynamicStartColor,
    dynamicEndColor: _dynamicEndColor,
    currentThemeColorsMap: Map<String, Color>.unmodifiable(
      _currentThemeColorsMap,
    ),
    isLyricsActive: isLyricsActive,
    sleepTimerRemaining: sleepTimerRemaining,
    sleepTimerDuration: sleepTimerDuration,
    playbackSpeed: _player.player.playbackSpeed,
  );

  Uint8List? getCachedArtwork(String? path) {
    if (path == null) return null;
    final song = _queue.firstWhereOrNull((s) => s.path == path);
    return song?.artworkBytes;
  }

  bool get isShuffleRandomMode =>
      _player.playlist.randomPolicy?.label == 'shuffleRandom';

  int? get historyCursor => _player.playlist.historyCursor;

  List<MusicFile> get randomHistory {
    final history = _player.playlist.randomHistory;
    return history.map((entry) {
      if (entry.trackIndex >= 0 && entry.trackIndex < _queue.length) {
        return _queue[entry.trackIndex];
      }
      return MusicFile(
        path: entry.trackId, // Fallback if index invalid
        name: 'Unknown',
      );
    }).toList();
  }

  List<MusicFile> get randomQueue {
    final deck = _player.playlist.currentDeck;
    return deck.map((id) {
      final index = int.tryParse(id) ?? -1;
      if (index >= 0 && index < _queue.length) {
        return _queue[index];
      }
      return MusicFile(
        path: id, // Fallback
        name: 'Unknown',
      );
    }).toList();
  }

  int? get deckCursor => _player.playlist.deckCursor;

  double get progress => _duration.inMilliseconds > 0
      ? _position.inMilliseconds / _duration.inMilliseconds
      : 0.0;

  Future<void> updateDynamicColors() async {
    await _updatePalette();
    notifyListeners();
  }

  Future<void> applyUpdatedSongMetadata(
    SongMetadata metadata, {
    Uint8List? artworkBytes,
  }) async {
    bool queueChanged = false;
    for (var i = 0; i < _queue.length; i++) {
      final song = _queue[i];
      if (song.path != metadata.path) continue;

      _queue[i] = _songFromMetadata(song, metadata, artworkBytes: artworkBytes);

      queueChanged = true;
    }

    final isCurrentTrack = currentMusic?.path == metadata.path;

    await _updatePalette();

    if (queueChanged || isCurrentTrack) {
      if (isCurrentTrack &&
          isLyricsActive &&
          !hasLyrics &&
          !isLyricsLoading &&
          !_lyricsController.isLyricsGenerationForSong(metadata.path)) {
        final current = currentMusic;
        if (current != null) {
          unawaited(_lyricsController.fetchAndLog(current));
        }
      }
      notifyListeners();
    }
  }

  Future<void> _refreshCurrentWaveform({bool notify = true}) async {
    final path = currentMusic?.path;
    if (path == null || !settingsService.isWaveformProgressBarEnabled) {
      if (notify) {
        notifyListeners();
      }
      return;
    }
    final isRemote = RemoteMediaResolver.isRemoteUri(path);
    if (!isRemote && !File(path).existsSync()) {
      if (notify) {
        notifyListeners();
      }
      return;
    }

    _currentWaveformSubscription?.cancel();
    _currentWaveformSubscription = _waveformService
        .streamWaveform(
          path: path,
          expectedChunks: settingsService.waveformChunks,
          sampleStride: settingsService.sampleStride,
        )
        .listen((waveformChunk) {
      if (path == currentMusic?.path && waveformChunk.isNotEmpty) {
        if (_currentIndex >= 0 &&
            _currentIndex < _queue.length &&
            _queue[_currentIndex].path == path) {
          final blob = _waveformService.waveformToBlob(waveformChunk);
          MusicFile.invalidateWaveformCache(path);
          _queue[_currentIndex] = _queue[_currentIndex].copyWith(
            waveformBlob: blob,
          );
          if (notify) {
            notifyListeners();
          }
        }
      }
    });
  }

  Future<void> clearWaveformCache() async {
    await _db.clearWaveformCache();
    _clearInMemoryWaveformCache();

    if (settingsService.isWaveformProgressBarEnabled) {
      await _refreshCurrentWaveform();
    } else {
      notifyListeners();
    }
  }

  Future<void> _handleWaveformChunkChange() async {
    await clearWaveformCache();
  }

  void _clearInMemoryWaveformCache() {
    MusicFile.clearCache();
    bool changed = false;
    for (var i = 0; i < _queue.length; i++) {
      if (_queue[i].waveformBlob != null) {
        _queue[i] = _queue[i].copyWith(waveformBlob: null);
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  void _applyThemeColors(Map<String, Color> colors) {
    _currentThemeColorsMap = colors;
    _dynamicStartColor = colors['dominant'] ?? colors['vibrant'];
    _dynamicEndColor =
        (colors['vibrant']?.withValues(alpha: 0.8)) ?? colors['muted'];
  }

  Future<void> saveCurrentSongThemeColors(Map<String, Color> colors) async {
    final current = currentMusic;
    if (current == null) return;
    final existingMetadata = await _db.getSongMetadata(current.path);

    final themeColorsBlob = ThemeColorHelper.colorsMapToBlob(colors);
    final updatedSong = current.copyWith(themeColorsBlob: themeColorsBlob);
    final updatedMetadata = SongMetadata(
      id: updatedSong.id,
      path: updatedSong.path,
      title: updatedSong.title ?? updatedSong.displayName,
      album: updatedSong.album ?? 'Unknown',
      artist: updatedSong.artist ?? 'Unknown',
      duration: updatedSong.durationMillis,
      artworkPath: updatedSong.artworkPath,
      thumbnailPath: updatedSong.thumbnailPath,
      artworkWidth: updatedSong.artworkWidth,
      artworkHeight: updatedSong.artworkHeight,
      trackNumber: updatedSong.trackNumber,
      themeColorsBlob: themeColorsBlob,
      waveformBlob: updatedSong.waveformBlob,
      lastModifiedTime: updatedSong.lastModifiedTime,
      metadataTextScanned:
          existingMetadata?.metadataTextScanned ?? updatedSong.lastModifiedTime,
      metadataImgScanned:
          existingMetadata?.metadataImgScanned ?? updatedSong.lastModifiedTime,
      createdAt: existingMetadata?.createdAt,
      genres: existingMetadata?.genres,
    );

    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      _queue[_currentIndex] = updatedSong;
    }

    _applyThemeColors(colors);
    await _db.insertOrUpdateSong(updatedMetadata);
    _scannerService?.updateMetadataForPath(
      updatedMetadata,
      artworkBytes: updatedSong.artworkBytes,
    );
    await _playlistService?.updateSongMetadataByPath(
      updatedMetadata,
      artworkBytes: updatedSong.artworkBytes,
    );
    notifyListeners();
  }

  Future<void> recomputeThemeColorsWithMaster({
    required String songPath,
  }) async {
    if (_themePaletteRecomputeInProgressPath == songPath) {
      return;
    }

    final current = currentMusic;
    if (current == null || current.path != songPath) {
      return;
    }

    _themePaletteRecomputeInProgressPath = songPath;
    try {
      final artworkThemeService = TrackArtworkThemeService(db: _db);
      final artworkTheme = await artworkThemeService.getTrackArtworkTheme(
        songPath,
        controller: _player,
        saveLargeArtwork: false,
        thumbnailSize: vynodyArtworkThumbnailSize,
      );

      if (currentMusic?.path != songPath ||
          artworkTheme == null ||
          artworkTheme.themeColorsBlob == null) {
        return;
      }

      await saveCurrentSongThemeColors(
        ThemeColorHelper.blobToColors(artworkTheme.themeColorsBlob!),
      );
    } catch (e) {
      debugPrint('Error recomputing theme colors for $songPath: $e');
    } finally {
      if (_themePaletteRecomputeInProgressPath == songPath) {
        _themePaletteRecomputeInProgressPath = null;
      }
    }
  }

  Future<void> _updatePalette() async {
    final artworkBytes = currentMusic?.artworkBytes;
    final artworkPath =
        currentMusic?.artworkPath ?? currentMusic?.thumbnailPath;
    final themeColorsBlob = currentMusic?.themeColorsBlob;

    if (artworkBytes == null &&
        artworkPath == null &&
        themeColorsBlob == null) {
      _dynamicStartColor = null;
      _dynamicEndColor = null;
      _currentThemeColorsMap = const {};
      notifyListeners();
      return;
    }

    if (themeColorsBlob != null && themeColorsBlob.isNotEmpty) {
      final colorsMap = ThemeColorHelper.blobToColors(themeColorsBlob);
      _applyThemeColors(colorsMap);
      _dynamicStartColor = colorsMap['dominant'] ?? colorsMap['vibrant'];
      _dynamicEndColor =
          (colorsMap['vibrant']?.withValues(alpha: 0.8)) ?? colorsMap['muted'];
      notifyListeners();
      return;
    }

    final songPath = currentMusic?.path;
    if (songPath == null) return;

    final artworkThemeService = TrackArtworkThemeService(db: _db);
    final artworkTheme = await artworkThemeService.getTrackArtworkTheme(
      songPath,
      controller: _player,
      saveLargeArtwork: false,
      thumbnailSize: vynodyArtworkThumbnailSize,
    );

    final paletteBlob = artworkTheme?.themeColorsBlob;

    if (paletteBlob == null || paletteBlob.isEmpty) {
      _dynamicStartColor = null;
      _dynamicEndColor = null;
      _currentThemeColorsMap = const {};
      notifyListeners();
      return;
    }

    final colorsMap = ThemeColorHelper.blobToColors(paletteBlob);
    await saveCurrentSongThemeColors(colorsMap);
  }

  /// Synchronizes the currently playing song with the in-memory playback state.
  ///
  /// This method does not "scan" the file or rebuild the database. Its job is to:
  /// - make sure the current queue item reflects the newest `MusicFile` data
  /// - preserve any existing lyrics already attached to that song
  /// - hydrate artwork and theme colors if they are already available
  /// - push the current track metadata to Windows / Android integration layers
  /// - kick off lyrics loading when lyric mode is enabled
  ///
  /// In short: this is the "apply current song metadata to the player/UI" step
  /// that runs after a track becomes current.
  Future<void> _updateCurrentMetadata(MusicFile inputSong) async {
    _logPlaybackTrace(
      '_updateCurrentMetadata start -> input=${_debugSongLabel(inputSong)} '
      'currentBefore=${_debugSongLabel(currentMusic)}',
    );
    final song = await _resolveMetadataForPlayback(inputSong);
    final path = song.path;
    final isCurrentSong =
        _currentIndex >= 0 &&
        _currentIndex < _queue.length &&
        _queue[_currentIndex].path == path;
    // Guard against async races:
    // if the queue has already moved on to another track, do not let this call
    // overwrite the newer song's state with stale metadata.
    if (isCurrentSong) {
      // Keep any existing lyrics that are already attached to the current item.
      // A normal metadata refresh should not wipe lyrics that were loaded or cached.
      final existingLyrics = _queue[_currentIndex].lyrics;
      _queue[_currentIndex] = song.copyWith(
        lyrics: song.lyrics ?? existingLyrics,
      );
      _logPlaybackTrace(
        '_updateCurrentMetadata queue replace -> currentIndex=$_currentIndex '
        'song=${_debugSongLabel(_queue[_currentIndex])}',
      );
    } else {
      _logLyricsDebug(
        'metadata refresh ignored for stale song -> title="${song.displayName}" '
        'path="$path" currentPath="${currentMusic?.path}"',
      );
      return;
    }

    // Apply cached theme colors immediately so the UI can update without waiting
    // for the slower artwork/palette pipeline.
    final hasCachedThemeColors = song.themeColorsBlob != null;
    if (song.themeColorsBlob != null) {
      final colorsMap = ThemeColorHelper.blobToColors(song.themeColorsBlob!);
      _applyThemeColors(colorsMap);
    }

    // Hydrate artwork bytes asynchronously:
    // prefer the higher-quality file saved in the metadata database, then fall
    // back to embedded artwork inside the audio file.
    unawaited(() async {
      final swHydrate = Stopwatch()..start();
      _logPlaybackTrace(
        '_updateCurrentMetadata artwork hydrate scheduled -> '
        'song=${_debugSongLabel(song)}',
      );
      Uint8List? highResBytes;
      String? highResPath;
      String? thumbnailPath;

      final isRemote = RemoteMediaResolver.isRemoteUri(path);
      final dbMetadata = await _db.getSongMetadata(path);
      if (dbMetadata != null) {
        highResPath = dbMetadata.artworkPath;
        thumbnailPath = dbMetadata.thumbnailPath;
        if (highResPath != null && highResPath.trim().isNotEmpty && !isRemote) {
          try {
            highResBytes = await File(highResPath).readAsBytes();
          } catch (_) {}
        }
      }

      if (!isRemote) {
        final swDecode = Stopwatch()..start();
        highResBytes ??= await MetadataHelper.decodeEmbeddedArtwork(path);
        if (highResBytes != null) {
          debugPrint(
            '[PERF] _updateCurrentMetadata decodeEmbeddedArtwork took ${swDecode.elapsedMilliseconds}ms, size=${highResBytes.length} bytes',
          );
        }
      }

      // Fallback to thumbnail bytes if needed
      if (highResBytes == null && thumbnailPath != null) {
        try {
          final file = File(thumbnailPath);
          if (await file.exists()) {
            highResBytes = await file.readAsBytes();
          }
        } catch (_) {}
      }

      // If still missing for remote track, fetch via TrackArtworkThemeService
      if (highResBytes == null && isRemote) {
        try {
          final artworkThemeService = TrackArtworkThemeService(db: _db);
          final songMeta = dbMetadata ??
              SongMetadata(
                path: path,
                title: song.title ?? song.name,
                artist: song.artist ?? 'Unknown Artist',
                album: song.album ?? 'Unknown Album',
                artworkPath: song.artworkPath,
              );
          final artworkTheme = await artworkThemeService.getTrackArtworkTheme(
            path,
            controller: _player,
            saveLargeArtwork: false,
            existingMetadata: songMeta,
          );
          final resThumbnail = artworkTheme?.thumbnailPath;
          if (resThumbnail != null && File(resThumbnail).existsSync()) {
            thumbnailPath = resThumbnail;
            highResBytes = await File(resThumbnail).readAsBytes();
          }
        } catch (e) {
          debugPrint('AudioService: remote artwork hydrate error: $e');
        }
      }

      if (highResBytes == null && Platform.isAndroid && song.id != null) {
        try {
          final queryBytes = await OnAudioQuery().queryArtwork(
            song.id!,
            ArtworkType.AUDIO,
            size: 800,
          );
          if (queryBytes != null && queryBytes.isNotEmpty) {
            highResBytes = queryBytes;
            unawaited(
              MetadataHelper.saveArtworkAndThumbnail(
                path,
                queryBytes,
                saveLarge: false,
              ).then((info) async {
                if (info != null) {
                  final db = MetadataDatabase();
                  final existingSong = await db.getSongMetadata(path);
                  if (existingSong != null) {
                    await db.insertOrUpdateSong(
                      existingSong.copyWith(
                        artworkPath: info['artworkPath'] as String?,
                        thumbnailPath: info['thumbnailPath'] as String?,
                        artworkWidth: info['width'] as int?,
                        artworkHeight: info['height'] as int?,
                        themeColorsBlob: info['themeColorsBlob'] as Uint8List?,
                      ),
                    );
                  }
                }
              }),
            );
          }
        } catch (e) {
          debugPrint('AudioService: queryArtwork fallback error for ${song.id}: $e');
        }
      }

      if (_currentIndex >= 0 &&
          _currentIndex < _queue.length &&
          _queue[_currentIndex].path == path) {
        _queue[_currentIndex] = _queue[_currentIndex].copyWith(
          artworkBytes: highResBytes,
          artworkPath: highResPath,
          thumbnailPath: thumbnailPath,
        );

        notifyListeners();
        _logPlaybackTrace(
          '_updateCurrentMetadata artwork hydrate applied -> '
          'current=${_debugSongLabel(currentMusic)}',
        );

        final updatedSong = _queue[_currentIndex];
        _windowsIntegration?.updateMetadata(updatedSong);
        _androidIntegration?.updateMetadata(updatedSong);
        _darwinIntegration?.updateMetadata(updatedSong);
        _linuxIntegration?.updateMetadata(updatedSong);

        // If we already have cached theme colors from the database, keep them
        // as the final source of truth to avoid a second visual color change.
        if (!hasCachedThemeColors) {
          final swPalette = Stopwatch()..start();
          await _updatePalette();
          debugPrint(
            '[PERF] _updateCurrentMetadata _updatePalette took ${swPalette.elapsedMilliseconds}ms',
          );
        }
      }
      debugPrint(
        '[PERF] _updateCurrentMetadata artwork hydrate TOTAL took ${swHydrate.elapsedMilliseconds}ms',
      );
    }());

    // Prefer the latest current queue item here rather than the async input
    // snapshot. A lyrics fetch can complete while metadata refresh is still in
    // flight, and the queue entry may already contain the freshly attached
    // lyrics even if `song` was captured earlier without them.
    final latestCurrentSong =
        (_currentIndex >= 0 && _currentIndex < _queue.length)
        ? _queue[_currentIndex]
        : song;

    // If the current song already carries lyrics, restore them directly.
    // Otherwise clear lyric state and let the async lyric fetch pipeline decide
    // whether anything should be loaded.
    final songLyrics = latestCurrentSong.lyrics;
    if (isLyricsActive && songLyrics != null) {
      _lyricsController.restoreFromSongLyrics(latestCurrentSong);
    } else {
      _logLyricsDebug(
        'lyrics state cleared -> title="${song.displayName}" '
        'mode=$isLyricsActive hasCache=${songLyrics != null}',
      );
      _lyricsController.clearState(preserveTaskState: true);
    }

    notifyListeners();
    _logPlaybackTrace(
      '_updateCurrentMetadata end -> current=${_debugSongLabel(currentMusic)} '
      'queueIndex=$_currentIndex',
    );

    // Fallback palette refresh:
    // if artwork bytes/path are still missing here, keep the UI color state in
    // sync with whatever is currently available.
    if (!hasCachedThemeColors &&
        currentMusic?.artworkBytes == null &&
        currentMusic?.artworkPath == null) {
      await _updatePalette();
    }

    // Propagate the current track to platform integrations so Windows media
    // controls / Android notification UI stay in sync with playback.
    _windowsIntegration?.updateMetadata(song);
    _androidIntegration?.updateMetadata(song);
    _darwinIntegration?.updateMetadata(song);
    _linuxIntegration?.updateMetadata(song);

    // Trigger lyric loading only when lyric mode is active and we still do not
    // have lyrics for this track.
    if (isLyricsActive && !hasLyrics) {
      if (_lyricsController.isLyricsGenerationForSong(song.path)) {
        _logLyricsDebug(
          'post-metadata fetch skipped because lyrics generation is active '
          '-> title="${song.displayName}"',
        );
      } else {
        _logLyricsDebug(
          'post-metadata fetch -> title="${song.displayName}" '
          'duration=$_duration hasLyrics=$hasLyrics loading=$isLyricsLoading',
        );
        _lyricsController.scheduleFetch(song);
      }
    }

    notifyListeners();
  }

  void _cacheSongDuration(String path, int durationMillis) {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;
    final currentSong = _queue[_currentIndex];
    if (currentSong.path != path) return;
    if (currentSong.durationMillis == durationMillis) return;

    _queue[_currentIndex] = currentSong.copyWith(
      durationMillis: durationMillis,
    );
    notifyListeners();
  }

  void _logLyricsDebug(String message) {
    if (!kDebugMode) return;
    // debugPrint('[AudioService][Lyrics] $message');
  }

  String _debugSongLabel(MusicFile? song) {
    if (song == null) return 'null';
    return '${song.displayName} | path=${song.path} | idx=$_currentIndex | '
        'artBytes=${song.artworkBytes?.length ?? 0} | '
        'artPath=${song.artworkPath ?? '-'} | '
        'thumb=${song.thumbnailPath ?? '-'}';
  }

  void _logPlaybackTrace(String message) {
    if (!kDebugMode) return;
    // debugPrint('[AudioService][Trace] $message');
  }

  Future<MusicFile> _buildMusicFileFromPath(
    String path, {
    required String name,
    int? id,
    String? mediaUri,
  }) async {
    if (RemoteMediaResolver.isRemoteUri(path)) {
      return MusicFile(
        path: path,
        name: name,
        id: id,
        mediaUri: mediaUri,
      );
    }
    final resolved = await MetadataHelper.loadMetadataForPlayback(
      path,
      generateThumbnail: false,
    );
    final metadata = resolved?.$1;
    final artworkBytes = resolved?.$2;

    return MusicFile(
      path: path,
      name: name,
      title: metadata?.title,
      artist: metadata?.artist,
      album: metadata?.album,
      trackNumber: metadata?.trackNumber,
      durationMillis: metadata?.duration,
      thumbnailPath: metadata?.thumbnailPath,
      artworkPath: metadata?.artworkPath,
      artworkWidth: metadata?.artworkWidth,
      artworkHeight: metadata?.artworkHeight,
      themeColorsBlob: metadata?.themeColorsBlob,
      artworkBytes: artworkBytes,
      lastModifiedTime: metadata?.lastModifiedTime,
      id: id,
      mediaUri: mediaUri,
    );
  }

  Future<void> _playQueueTracks({
    required List<MusicFile> songs,
    required int startIndex,
    required bool clearPlayerQueue,
    bool startBackgroundProcessing = true,
  }) async {
    if (songs.isEmpty) return;

    final safeIndex = startIndex.clamp(0, songs.length - 1);
    final tracks = songs.map(_audioTrackForSong).toList(growable: false);

    if (Platform.isIOS || Platform.isMacOS) {
      for (final song in songs) {
        if (!RemoteMediaResolver.isRemoteUri(song.path)) {
          await _player.registerPersistentAccess(path: song.path);
          await _player.beginScopedAccess(path: song.path);
        }
      }
    }

    await _player.playlist.ensureQueuePlaylist();
    if (clearPlayerQueue) {
      await _player.playlist.clear();
    }

    await _player.playlist.addTracksToPlaylist(
      _player.playlist.queuePlaylistId,
      tracks,
    );

    await _player.playlist.setActivePlaylist(
      _player.playlist.queuePlaylistId,
      startIndex: safeIndex,
      autoPlay: true,
    );

    final current = songs[safeIndex];
    _currentIndex = safeIndex;
    await _syncCurrentPlaybackSong(current);
    await _player.player.setVolume(_volume / 100.0);
    if (startBackgroundProcessing) {
      _startQueueBackgroundProcessing(priorityPath: current.path);
    }
  }

  Future<void> playFile(
    String path,
    String name, {
    int? id,
    String? mediaUri,
    bool append = false,
  }) async {
    if (!await _songExists(path)) {
      setSongMissingStateByPath(path, true);
      _showMissingSongNotice(skipped: false);
      return;
    }

    // 1. 设置正在切换状态
    _isTransitioning = true;
    notifyListeners();

    try {
      final song = await _buildMusicFileFromPath(
        path,
        name: name,
        id: id,
        mediaUri: mediaUri,
      );
      if (!append) {
        _queue.clear();
        _currentSource = null;
      }

      _queue.add(song);
      await _playQueueTracks(
        songs: _queue,
        startIndex: _queue.length - 1,
        clearPlayerQueue: !append,
      );
    } finally {
      _isTransitioning = false;
      notifyListeners();
      unawaited(_persistPlaybackSession());
    }
  }

  /// 播放选定的一组歌曲（歌单），由 UI 触发（如点击文件夹中的一首歌）。
  Future<void> playPlaylist(
    List<MusicFile> songs, {
    int initialIndex = 0,
    PlaybackSource? source,
  }) async {
    if (songs.isEmpty) return;
    final safeIndex = initialIndex.clamp(0, songs.length - 1);

    _currentSource = source;

    // 1. 同步设置正在切换状态与播放队列并通知 UI
    _isTransitioning = true;
    _queueProcessor.pause();
    _scannerService?.pauseBackgroundTasks();

    _queue.clear();
    _queue.addAll(songs);
    _currentIndex = safeIndex;
    _position = Duration.zero;
    _resetPlaybackTrackingForSong(songs[safeIndex]);
    notifyListeners();

    if (!await _songExists(songs[safeIndex].path)) {
      setSongMissingStateByPath(songs[safeIndex].path, true);
      _showMissingSongNotice(skipped: false);
      _isTransitioning = false;
      _queueProcessor.resume();
      _scannerService?.resumeBackgroundTasks();
      notifyListeners();
      return;
    }

    try {
      final current = _queue[safeIndex];

      await _playQueueTracks(
        songs: _queue,
        startIndex: safeIndex,
        clearPlayerQueue: true,
        startBackgroundProcessing: false,
      );

      _prefetchNextRemoteTracks(safeIndex);

      await _prepareCurrentPlaybackArtwork(current);
      unawaited(_persistPlaybackSession());
    } catch (e) {
      debugPrint('AudioService: failed to start playlist playback: $e');
    } finally {
      _isTransitioning = false;
      _queueProcessor.resume();
      _scannerService?.resumeBackgroundTasks();
      notifyListeners();
    }
  }

  Future<void> addToPlaylist(List<MusicFile> songs) async {
    if (songs.isEmpty) return;

    final bool wasEmpty = _queue.isEmpty;
    _queue.addAll(songs);

    if (wasEmpty) {
      await _playQueueTracks(
        songs: _queue,
        startIndex: 0,
        clearPlayerQueue: false,
      );
      unawaited(_persistPlaybackSession());
      return;
    }

    final tracks = songs.map(_audioTrackForSong).toList(growable: false);
    await _player.playlist.addTracks(tracks);
    _startQueueBackgroundProcessing();
    notifyListeners();
    unawaited(_persistPlaybackSession());
  }

  /// Append songs to the end of the playback queue without changing the
  /// currently playing song.
  Future<void> appendToQueue(List<MusicFile> songs) async {
    if (songs.isEmpty) return;

    _queue.addAll(songs);

    final tracks = songs.map(_audioTrackForSong).toList(growable: false);
    await _player.playlist.addTracksToPlaylist(
      _player.playlist.queuePlaylistId,
      tracks,
      reconcile: false,
    );

    _startQueueBackgroundProcessing();
    notifyListeners();
    unawaited(_persistPlaybackSession());
  }

  /// Insert songs into the playback queue at a specific index.
  ///
  /// The current track keeps playing, and the current index is shifted forward
  /// when the insertion happens before it.
  Future<void> insertIntoQueueAt(int index, List<MusicFile> songs) async {
    if (songs.isEmpty) return;

    final insertAt = index.clamp(0, _queue.length).toInt();
    if (insertAt >= _queue.length) {
      await appendToQueue(songs);
      return;
    }

    final shouldShiftCurrentIndex =
        _currentIndex >= 0 && insertAt <= _currentIndex;

    for (var i = 0; i < songs.length; i++) {
      final song = songs[i];
      _queue.insert(insertAt + i, song);
      await _player.playlist.insertTrack(
        insertAt + i,
        _audioTrackForSong(song),
      );
    }

    if (shouldShiftCurrentIndex) {
      _currentIndex += songs.length;
    }

    _startQueueBackgroundProcessing(priorityPath: currentMusic?.path);
    notifyListeners();
    unawaited(_persistPlaybackSession());
  }

  Future<AudioDetails> getAudioDetails({required String path}) async {
    return _player.engine.getAudioDetails(path: path);
  }

  Future<void> enqueueNext(List<MusicFile> songs) async {
    if (songs.isEmpty) return;

    if (_queue.isEmpty) {
      await playPlaylist(songs);
      return;
    }

    final insertAt = (_currentIndex >= 0 && _currentIndex < _queue.length)
        ? _currentIndex + 1
        : _queue.length;

    for (var i = 0; i < songs.length; i++) {
      final song = songs[i];
      _queue.insert(insertAt + i, song);
      await _player.playlist.insertTrack(
        insertAt + i,
        _audioTrackForSong(song),
      );
    }

    _startQueueBackgroundProcessing(priorityPath: currentMusic?.path);
    notifyListeners();
    unawaited(_persistPlaybackSession());
  }

  Future<void> removeFromPlaylist(int index) async {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      await _player.playlist.removeTrackAt(index);
      if (currentMusic?.path != null) {
        final updatedIndex = _queue.indexWhere(
          (song) => song.path == currentMusic?.path,
        );
        if (updatedIndex != -1) {
          _currentIndex = updatedIndex;
        }
      }
      _startQueueBackgroundProcessing();
      notifyListeners();
      unawaited(_persistPlaybackSession());
    }
  }

  Future<void> _clearCurrentMusicState() async {
    _currentIndex = -1;
    _resetPlaybackTrackingForSong(null);
  }

  Future<void> clearPlaylist() async {
    _cancelSleepTimer(notify: false);
    _queue.clear();
    _currentSource = null;
    await _clearCurrentMusicState();

    await _player.playlist.clear();
    _duration = Duration.zero;
    _position = Duration.zero;
    _isPlaying = false;
    notifyListeners();
    unawaited(_persistPlaybackSession());
  }

  Future<void> _handleQueueFinished() async {
    if (_isHandlingQueueFinished) return;
    _isHandlingQueueFinished = true;

    try {
      final source = _currentSource;
      if (source == null) {
        debugPrint(
          '[AudioService] _handleQueueFinished: currentSource is null',
        );
        return;
      }

      debugPrint(
        '[AudioService] _handleQueueFinished: type=${source.type} id=${source.id}',
      );

      switch (source.type) {
        case PlaybackSourceType.playlist:
          final list = _playlistService?.playlists ?? [];
          final playableList = list.where((p) => p.songs.isNotEmpty).toList();
          if (playableList.isEmpty) return;
          int idx = playableList.indexWhere((p) => p.id == source.id);
          if (idx == -1) {
            idx = 0;
          } else {
            idx = (idx + 1) % playableList.length;
          }
          final nextPlaylist = playableList[idx];
          await playPlaylist(
            nextPlaylist.songs,
            source: PlaybackSource(
              type: PlaybackSourceType.playlist,
              id: nextPlaylist.id,
              name: nextPlaylist.name,
            ),
          );
          break;

        case PlaybackSourceType.folder:
          if (_scannerService == null) return;
          final nextFolder = _scannerService!.findNextFolderWithMusic(
            source.id,
          );
          if (nextFolder == null || nextFolder.allSongs.isEmpty) return;
          await playPlaylist(
            nextFolder.allSongs,
            source: PlaybackSource(
              type: PlaybackSourceType.folder,
              id: nextFolder.path,
              name: nextFolder.name,
            ),
          );
          break;

        case PlaybackSourceType.album:
          final allSongs = await _db.getAllSongMetadata();
          final albums = buildAlbumSummaries(allSongs);
          final playableAlbums = albums
              .where((a) => a.songs.isNotEmpty)
              .toList();
          if (playableAlbums.isEmpty) return;
          int idx = playableAlbums.indexWhere((a) => a.id == source.id);
          if (idx == -1) {
            idx = 0;
          } else {
            idx = (idx + 1) % playableAlbums.length;
          }
          final nextAlbum = playableAlbums[idx];
          await playPlaylist(
            nextAlbum.songs,
            source: PlaybackSource(
              type: PlaybackSourceType.album,
              id: nextAlbum.id,
              name: nextAlbum.title,
            ),
          );
          break;

        case PlaybackSourceType.artist:
          final repository = ArtistLibraryRepository(database: _db);
          final artists = await repository.watchArtistSummaries().first;
          final playableArtists = artists
              .where((a) => a.songs.isNotEmpty)
              .toList();
          if (playableArtists.isEmpty) return;
          int idx = playableArtists.indexWhere((a) => a.queryKey == source.id);
          if (idx == -1) {
            idx = 0;
          } else {
            idx = (idx + 1) % playableArtists.length;
          }
          final nextArtist = playableArtists[idx];
          await playPlaylist(
            nextArtist.songs,
            source: PlaybackSource(
              type: PlaybackSourceType.artist,
              id: nextArtist.queryKey,
              name: nextArtist.name,
            ),
          );
          break;
      }
    } catch (e) {
      debugPrint('[AudioService] Error handling queue finished: $e');
    } finally {
      _isHandlingQueueFinished = false;
    }
  }

  Future<void> next() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _lastActionNext = true;
    _logPlaybackTrace(
      'next() start | current=${_debugSongLabel(currentMusic)} '
      'transitioning=$_isTransitioning',
    );
    notifyListeners();
    try {
      final success = await _player.playlist.playNext();
      _logPlaybackTrace(
        'next() playlist.playNext() -> success=$success '
        'playlistIndex=${_player.playlist.currentIndex}',
      );
      if (success) {
        final newIndex = _player.playlist.currentIndex ?? -1;
        if (newIndex >= 0 && newIndex < _queue.length) {
          _currentIndex = newIndex;
          notifyListeners();
          final song = _queue[_currentIndex];
          _logPlaybackTrace('next() sync target -> ${_debugSongLabel(song)}');
          await _syncCurrentPlaybackSong(song);
        }
      } else {
        if (_playbackMode == AppPlaybackMode.autoQueueLoop) {
          await _handleQueueFinished();
        }
      }
    } finally {
      _isTransitioning = false;
      _logPlaybackTrace(
        'next() end | current=${_debugSongLabel(currentMusic)} '
        'transitioning=$_isTransitioning',
      );
      notifyListeners();
      unawaited(_persistPlaybackSession());
    }
  }

  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    if (!await _songExists(_queue[index].path)) {
      setSongMissingStateByPath(_queue[index].path, true);
      _showMissingSongNotice(skipped: false);
      return;
    }
    if (_isTransitioning) return;
    if (index == _currentIndex && _isPlaying) return;

    _isTransitioning = true;
    _lastActionNext = (index > _currentIndex);
    _logPlaybackTrace(
      'playAtIndex($index) start | current=${_debugSongLabel(currentMusic)} '
      'transitioning=$_isTransitioning',
    );
    notifyListeners();
    try {
      final song = _queue[index];
      _logPlaybackTrace(
        'playAtIndex($index) target -> ${_debugSongLabel(song)}',
      );

      await _player.playTrack(
        _audioTrackForSong(song),
        preferredPlaylistId:
            _player.playlist.activePlaylistId ??
            _player.playlist.queuePlaylistId,
      );
      _prefetchNextRemoteTracks(index);
      _currentIndex = index;
      _position = Duration.zero;
      _resetPlaybackTrackingForSong(song);
      notifyListeners();
      await _syncCurrentPlaybackSong(song);
    } finally {
      _isTransitioning = false;
      _logPlaybackTrace(
        'playAtIndex($index) end | current=${_debugSongLabel(currentMusic)} '
        'transitioning=$_isTransitioning',
      );
      notifyListeners();
      unawaited(_persistPlaybackSession());
    }
  }

  Future<void> _handleQueuePrevious() async {
    if (_isHandlingQueueFinished) return;
    _isHandlingQueueFinished = true;

    try {
      final source = _currentSource;
      if (source == null) {
        debugPrint(
          '[AudioService] _handleQueuePrevious: currentSource is null',
        );
        return;
      }

      debugPrint(
        '[AudioService] _handleQueuePrevious: type=${source.type} id=${source.id}',
      );

      switch (source.type) {
        case PlaybackSourceType.playlist:
          final list = _playlistService?.playlists ?? [];
          final playableList = list.where((p) => p.songs.isNotEmpty).toList();
          if (playableList.isEmpty) return;
          int idx = playableList.indexWhere((p) => p.id == source.id);
          if (idx == -1) {
            idx = playableList.length - 1;
          } else {
            idx = (idx - 1 + playableList.length) % playableList.length;
          }
          final nextPlaylist = playableList[idx];
          await playPlaylist(
            nextPlaylist.songs,
            initialIndex: nextPlaylist.songs.length - 1,
            source: PlaybackSource(
              type: PlaybackSourceType.playlist,
              id: nextPlaylist.id,
              name: nextPlaylist.name,
            ),
          );
          break;

        case PlaybackSourceType.folder:
          if (_scannerService == null) return;
          final nextFolder = _scannerService!.findPreviousFolderWithMusic(
            source.id,
          );
          if (nextFolder == null || nextFolder.allSongs.isEmpty) return;
          await playPlaylist(
            nextFolder.allSongs,
            initialIndex: nextFolder.allSongs.length - 1,
            source: PlaybackSource(
              type: PlaybackSourceType.folder,
              id: nextFolder.path,
              name: nextFolder.name,
            ),
          );
          break;

        case PlaybackSourceType.album:
          final allSongs = await _db.getAllSongMetadata();
          final albums = buildAlbumSummaries(allSongs);
          final playableAlbums = albums
              .where((a) => a.songs.isNotEmpty)
              .toList();
          if (playableAlbums.isEmpty) return;
          int idx = playableAlbums.indexWhere((a) => a.id == source.id);
          if (idx == -1) {
            idx = playableAlbums.length - 1;
          } else {
            idx = (idx - 1 + playableAlbums.length) % playableAlbums.length;
          }
          final nextAlbum = playableAlbums[idx];
          await playPlaylist(
            nextAlbum.songs,
            initialIndex: nextAlbum.songs.length - 1,
            source: PlaybackSource(
              type: PlaybackSourceType.album,
              id: nextAlbum.id,
              name: nextAlbum.title,
            ),
          );
          break;

        case PlaybackSourceType.artist:
          final repository = ArtistLibraryRepository(database: _db);
          final artists = await repository.watchArtistSummaries().first;
          final playableArtists = artists
              .where((a) => a.songs.isNotEmpty)
              .toList();
          if (playableArtists.isEmpty) return;
          int idx = playableArtists.indexWhere((a) => a.queryKey == source.id);
          if (idx == -1) {
            idx = playableArtists.length - 1;
          } else {
            idx = (idx - 1 + playableArtists.length) % playableArtists.length;
          }
          final nextArtist = playableArtists[idx];
          await playPlaylist(
            nextArtist.songs,
            initialIndex: nextArtist.songs.length - 1,
            source: PlaybackSource(
              type: PlaybackSourceType.artist,
              id: nextArtist.queryKey,
              name: nextArtist.name,
            ),
          );
          break;
      }
    } catch (e) {
      debugPrint('[AudioService] Error handling queue previous: $e');
    } finally {
      _isHandlingQueueFinished = false;
    }
  }

  Future<void> previous() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _lastActionNext = false;
    _logPlaybackTrace(
      'previous() start | current=${_debugSongLabel(currentMusic)} '
      'transitioning=$_isTransitioning',
    );
    notifyListeners();
    try {
      final success = await _player.playlist.playPrevious();
      _logPlaybackTrace(
        'previous() playlist.playPrevious() -> success=$success '
        'playlistIndex=${_player.playlist.currentIndex}',
      );
      if (success) {
        final newIndex = _player.playlist.currentIndex ?? -1;
        if (newIndex >= 0 && newIndex < _queue.length) {
          _currentIndex = newIndex;
          notifyListeners();
          final song = _queue[_currentIndex];
          _logPlaybackTrace(
            'previous() sync target -> ${_debugSongLabel(song)}',
          );
          await _syncCurrentPlaybackSong(song);
        }
      } else {
        if (_playbackMode == AppPlaybackMode.autoQueueLoop) {
          await _handleQueuePrevious();
        }
      }
    } finally {
      _isTransitioning = false;
      _logPlaybackTrace(
        'previous() end | current=${_debugSongLabel(currentMusic)} '
        'transitioning=$_isTransitioning',
      );
      notifyListeners();
      unawaited(_persistPlaybackSession());
    }
  }

  Future<void> togglePlay() async {
    await _player.player.togglePlayPause();
  }

  Future<void> seek(Duration position) async {
    _seekTargetPosition = position;
    _isSeeking = true;
    _lastSeekTime = DateTime.now();
    _position = position;
    notifyListeners();

    await _player.player.seek(position);
    unawaited(_persistPlaybackSession());
  }

  bool get shouldShowVolumeHudForLastVolumeChange =>
      _showVolumeHudForLastVolumeChange;

  Future<void> setVolume(double volume, {bool showVolumeHud = true}) async {
    _volume = volume.clamp(0.0, 100.0);
    _showVolumeHudForLastVolumeChange = showVolumeHud;
    if (_volume > 0) {
      _isMuted = false;
    }
    await _player.player.setVolume(_volume / 100.0);

    final prefs = settingsService.prefs;
    unawaited(prefs.setDouble(_volumeStorageKey, _volume));
    unawaited(prefs.setBool(_isMutedStorageKey, _isMuted));

    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _player.player.setPlaybackSpeed(speed);
    notifyListeners();
  }

  Future<void> toggleMute() async {
    final prefs = settingsService.prefs;
    if (_isMuted) {
      _isMuted = false;
      unawaited(prefs.setBool(_isMutedStorageKey, false));
      await setVolume(_previousVolume);
    } else {
      _previousVolume = _volume;
      unawaited(prefs.setDouble(_previousVolumeStorageKey, _previousVolume));
      _isMuted = true;
      unawaited(prefs.setBool(_isMutedStorageKey, true));
      await setVolume(0);
    }
  }

  Future<void> seekRelative(Duration delta) async {
    final target = _position + delta;
    final clampedTarget = Duration(
      milliseconds: target.inMilliseconds.clamp(0, _duration.inMilliseconds),
    );
    await seek(clampedTarget);
  }

  void updateVisualOptions(VisualizerOptimizationOptions options) {
    _visualizerOptions.updateOptions(options);
    notifyListeners();
  }

  void resetVisualizerOptions({required Orientation orientation}) {
    _visualizerOptions.resetToAutoSettings(orientation: orientation);
    notifyListeners();
  }

  void toggleRandomMode({List<MusicFile>? globalSongs}) {
    if (isRandomMode) {
      _player.playlist.setRandomPolicy(null);
    } else {
      _applyRandomPolicy(globalSongs: globalSongs);
    }
    notifyListeners();
    unawaited(_persistPlaybackSession());
  }

  void _applyRandomPolicy({List<MusicFile>? globalSongs}) {
    final range = settingsService.randomRange;
    final method = settingsService.randomMethod;

    if (range == 1 && globalSongs != null) {
      _expandPlaylistToGlobal(globalSongs);
    }

    final strategy = method == 0
        ? RandomStrategy.random()
        : RandomStrategy.fisherYates();

    _player.playlist.setRandomPolicy(
      RandomPolicy(
        scope: RandomScope.all(),
        strategy: strategy,
        label: method == 0 ? 'completeRandom' : 'shuffleRandom',
      ),
    );
  }

  void _expandPlaylistToGlobal(List<MusicFile> globalSongs) {
    // Merge current playlist with global songs, deduplicate by path
    final existingPaths = _queue.map((s) => s.path).toSet();
    final newSongs = globalSongs
        .where((s) => !existingPaths.contains(s.path))
        .toList();

    if (newSongs.isEmpty) return;

    _queue.addAll(newSongs);

    final tracks = newSongs.map(_audioTrackForSong).toList(growable: false);

    // We don't use await here to keep it synchronous for the toggle
    unawaited(_player.playlist.addTracks(tracks));
    _startQueueBackgroundProcessing();
  }

  AudioTrack _audioTrackForSong(MusicFile song) {
    return AudioTrack(
      id: song.path,
      uri: song.path,
      title: song.title ?? song.displayName,
      artist: song.artist,
      album: song.album,
      metadata: <String, Object?>{
        'filePath': song.path,
        if (song.mediaUri != null) 'mediaUri': song.mediaUri,
      },
    );
  }

  void _prefetchNextRemoteTracks(int currentIndex) {
    if (_queue.isEmpty) return;
    unawaited(() async {
      try {
        final storage = await ref.read(remoteServerStorageProvider.future);
        final proxy = ref.read(localStreamCacheProxyProvider);
        final resolver = RemoteMediaResolver(storage: storage, proxy: proxy);

        for (var i = 1; i <= 2; i++) {
          final nextIndex = (currentIndex + i) % _queue.length;
          final nextSong = _queue[nextIndex];
          if (RemoteMediaResolver.isRemoteUri(nextSong.path)) {
            final source = await resolver.resolvePlayableSource(nextSong.path);
            final cacheKey = source.cacheKey ?? source.uri;
            await _player.streamCacheManager.ensureTrackCached(
              cacheKey: cacheKey,
              remoteUrl: source.uri,
              headers: source.headers,
            );
            debugPrint('[AudioService] Prefetched remote track ($nextIndex): ${nextSong.title}');
          }
        }
      } catch (e) {
        debugPrint('[AudioService] Error prefetching remote tracks: $e');
      }
    }());
  }


  void _startQueueBackgroundProcessing({String? priorityPath}) {
    _queueBackgroundProcessor.start(
      queue: _queue,
      priorityPath: priorityPath,
      onChanged: notifyListeners,
      onThemeChanged: _applyThemeColors,
      currentMusic: () => currentMusic,
      logTrace: _logPlaybackTrace,
      debugSongLabel: _debugSongLabel,
    );
  }

  Future<void> completeHeroTransition({String? priorityPath}) async {
    if (_disposed) return;

    _queueProcessor.resume();
    _scannerService?.resumeBackgroundTasks();

    if (_isTransitioning) {
      _isTransitioning = false;
    }

    if (_queue.isNotEmpty) {
      _startQueueBackgroundProcessing(
        priorityPath: priorityPath ?? currentMusic?.path,
      );
    }

    notifyListeners();
  }

  void _dispose() {
    _stopPlaybackSessionAutoSaveTimer();
    unawaited(_persistPlaybackSession(allowWhenDisposed: true));
    _disposed = true;
    _sessionManager.dispose();
    _currentWaveformSubscription?.cancel();
    _sleepTimer?.cancel();
    _player.removeListener(_handlePlayerChanges);
    _player.equalizer.removeListener(notifyListeners);
    settingsService.removeListener(_settingsListener);
    _queueProcessor.dispose();
    _player.visualizer.removeOutput('mini_player');
    _windowsIntegration?.dispose();
    _linuxIntegration?.dispose();
    _desktopTrayIntegration?.dispose();
    _player.dispose();
  }
}
