import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_core/audio_core.dart';
import 'package:window_manager/window_manager.dart';
import '../l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/lyrics/lyrics_riverpod.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/player/metadata/musicbrainz_tag_completion_service.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import '../widgets/playback_hero_card.dart';
import '../widgets/visualizer_painter.dart';
import '../widgets/volume_controls.dart';
import '../widgets/dynamic_mesh_background.dart';
import 'package:vynody/utils/playback_utils.dart';
import 'package:vynody/models/music_file.dart';
import '../dialogs/visualizer_options_dialog.dart';
import '../dialogs/song_tag_edit_dialog.dart';
import '../dialogs/song_tag_completion_dialog.dart';
import '../dialogs/sleep_timer_sheet.dart';
import '../dialogs/playlist_mode_sheet.dart';
import 'package:vynody/utils/memory_trace.dart';
import '../widgets/equalizer_panel.dart';
import '../widgets/lyrics_task_status_banner.dart';
import '../widgets/playback_ui_tuning.dart';
import '../widgets/mini_queue_view.dart';
import '../widgets/mini_lyrics_view.dart';
import 'main_layout_riverpod.dart';
import 'package:vynody/utils/app_snack_bar.dart';
import 'package:oktoast/oktoast.dart';

// PlaybackPage is now cleaner as volume HUD is handled globally

class PlaybackPage extends ConsumerStatefulWidget {
  const PlaybackPage({super.key});

  @override
  ConsumerState<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends ConsumerState<PlaybackPage> {
  final GlobalKey _coverKey = GlobalKey();
  final GlobalKey _lyricsKey = GlobalKey();
  bool _showVolumeSlider = false;
  bool _isScrubbingProgress = false;
  double _scrubProgress = 0.0; // Added missing declaration
  Orientation? _lastOrientation;
  Uint8List? _pendingArtworkBytes;
  String? _pendingArtworkPath;
  Timer? _heroWarmupTimer;
  Timer? _volumeSliderTimer;
  final Map<String, Uint8List> _fileArtworkBytesCache = {};
  final Set<String> _loadingPaths = {};

  void _startVolumeSliderTimer() {
    _volumeSliderTimer?.cancel();
    _volumeSliderTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showVolumeSlider = false;
        });
      }
    });
  }

  void _cancelVolumeSliderTimer() {
    _volumeSliderTimer?.cancel();
    _volumeSliderTimer = null;
  }

  SettingsService? _settingsService;
  AudioService? _audioService;
  bool? _lastIsSmallWindow;

  MainLayoutUiController get _ui =>
      ref.read(mainLayoutUiControllerProvider.notifier);

  void _logPlaybackPageTrace(String message) {
    if (!kDebugMode) return;
    debugPrint('[PlaybackPage][Trace] $message');
  }

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(audioServiceProvider);
    if (ref.read(settingsServiceProvider).defaultToLyricsModeOnPlaybackOpen) {
      _audioService?.setLyricsActive(true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingArtworkBytes = ref.read(audioCurrentMusicProvider)?.artworkBytes;
      _pendingArtworkPath = ref.read(audioCurrentMusicProvider)?.path;
      MemoryTrace.snapshot(
        'playbackPage:init',
        details: <String, Object?>{
          'pendingBytes': _pendingArtworkBytes?.length ?? 0,
          'pendingPath': _pendingArtworkPath ?? '-',
        },
      );
      ref.read(settingsServiceProvider).resetInactivity();
      if (mounted) {
        setState(() {});
      }
    });

    // Keep the hero flight smooth: defer background warmup until after the
    // route transition finishes. The current main layout transition is 320ms.
    _heroWarmupTimer = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      _audioService?.completeHeroTransition();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsService ??= ref.read(settingsServiceProvider);
  }

  @override
  void dispose() {
    _heroWarmupTimer?.cancel();
    _volumeSliderTimer?.cancel();
    _fileArtworkBytesCache.clear();
    _loadingPaths.clear();
    // 延迟重置，避免在 dispose 过程中触发 notifyListeners 导致的 "locked" 错误
    final settings = _settingsService;
    if (settings != null) {
      Future.microtask(() {
        settings.isUserInactive = false;
      });
    }
    // 离开播放页时，显式关闭 AudioService 的歌词激活标记。
    // 这将停止在歌曲切换时自动从网络抓取歌词，从而节省网络资源。
    // 使用已缓存的服务实例，避免在 dispose 时查找 ref/context
    final audio = _audioService;
    if (audio != null) {
      Future.microtask(() {
        audio.setLyricsActive(false);
      });
    }
    super.dispose();
  }

  void _startInactivityTimer() {
    ref.read(settingsServiceProvider).resetInactivity();
  }

  void toNextMusic(AudioService audio) {
    audio.next();
  }

  void _handleInteraction() {
    _startInactivityTimer();
  }

  void _onCarouselAnimationComplete(
    Uint8List? artworkBytes,
    String? sourcePath,
  ) {
    if (!mounted) return;
    if (sourcePath == _pendingArtworkPath &&
        artworkBytes?.length == _pendingArtworkBytes?.length) {
      return;
    }
    _logPlaybackPageTrace(
      'carousel animation complete | source=$sourcePath '
      'bytes=${artworkBytes?.length ?? 0} '
      'pendingBefore=${_pendingArtworkPath ?? '-'}',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _pendingArtworkBytes = artworkBytes;
        _pendingArtworkPath = sourcePath;
      });
      MemoryTrace.snapshot(
        'playbackPage:carouselComplete',
        details: <String, Object?>{
          'source': sourcePath ?? '-',
          'bytes': artworkBytes?.length ?? 0,
        },
      );
      _logPlaybackPageTrace(
        'pending artwork updated from carousel | source=$sourcePath '
        'bytes=${artworkBytes?.length ?? 0}',
      );
    });
  }

  Uint8List? _getArtworkBytes(String songPath) {
    if (_pendingArtworkPath == songPath && _pendingArtworkBytes != null) {
      return _pendingArtworkBytes;
    }
    if (_fileArtworkBytesCache.containsKey(songPath)) {
      return _fileArtworkBytesCache[songPath];
    }
    final currentMusic = ref.read(audioCurrentMusicProvider);
    if (currentMusic?.path == songPath && currentMusic?.artworkBytes != null) {
      return currentMusic!.artworkBytes;
    }
    final cached = _audioService?.getCachedArtwork(songPath);
    if (cached != null) {
      return cached;
    }
    _asyncLoadFileBytes(songPath);
    return null;
  }

  void _asyncLoadFileBytes(String songPath) async {
    if (_loadingPaths.contains(songPath)) return;
    _loadingPaths.add(songPath);
    try {
      final currentMusic = ref.read(audioCurrentMusicProvider);
      final metadata = ref.read(scannerServiceProvider).metadataMap[songPath];
      String? imagePath = metadata?.thumbnailPath ?? metadata?.artworkPath;
      if (imagePath == null || imagePath.isEmpty) {
        if (songPath == currentMusic?.path) {
          imagePath = currentMusic?.thumbnailPath ?? currentMusic?.artworkPath;
        }
      }
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (mounted) {
            setState(() {
              _fileArtworkBytesCache.clear();
              _fileArtworkBytesCache[songPath] = bytes;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading artwork file: $e');
    } finally {
      _loadingPaths.remove(songPath);
    }
  }

  /// 当用户点击专辑封面时触发，切换歌词模式显示状态。
  ///
  /// 此函数的执行流程如下：
  /// 1. 切换当前的歌词模式布尔值（true -> false 或 false -> true）。
  /// 2. 调用 `setState()` 触发 UI 重绘。
  /// 3. 重绘过程中，`PlaybackHeroCard` 会接收到新的 `isLyricsMode` 状态。
  /// 4. `PlaybackHeroCard` 内部的 `TweenAnimationBuilder` 会启动一个 400ms 的动画。
  /// 5. 动画根据 `isLyricsMode` 线性插值计算封面、歌曲信息、控制栏及歌词面板的位置和尺寸，
  ///    实现从“普通模式”到“歌词模式”的平滑过渡效果（封面缩小并移至左上角，歌词面板从屏幕下方滑入并变亮）。
  void _toggleLyricsMode() {
    final settings = ref.read(settingsServiceProvider);
    if (!settings.hasShownCoverTapLyricTip) {
      settings.hasShownCoverTapLyricTip = true;
    }
    final nextLyricsMode = !ref.read(audioIsLyricsActiveProvider);
    _audioService?.setLyricsActive(nextLyricsMode);
  }

  void _flushLyricsTranslationsAfterSmallWindowExit(bool isSmallWindow) {
    final previousIsSmallWindow = _lastIsSmallWindow;
    _lastIsSmallWindow = isSmallWindow;

    if (previousIsSmallWindow != true || isSmallWindow) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref
            .read(lyricsControllerProvider.notifier)
            .flushPendingLyricsTranslationUpdates(),
      );
    });
  }

  void _adjustVolumeFromDrag(
    AudioService audio,
    double dragDelta, {
    bool showVolumeHud = true,
  }) {
    if (showVolumeHud) {
      _ui.setVolumeHudVisible(true);
    }
    audio.setVolume(
      (audio.volume - dragDelta * 0.2).roundToDouble(),
      showVolumeHud: showVolumeHud,
    );
  }

  void _adjustVolumeFromScroll(
    AudioService audio,
    double scrollDeltaY, {
    bool showVolumeHud = true,
  }) {
    if (showVolumeHud) {
      _ui.setVolumeHudVisible(true);
    }
    audio.setVolume(
      (audio.volume - scrollDeltaY * 0.1).roundToDouble(),
      showVolumeHud: showVolumeHud,
    );
  }

  Future<void> _toggleVisualizer(AudioService audio) async {
    final nextVisible = !ref.read(audioIsVisualizerEnabledProvider);
    audio.setVisualizerEnabled(nextVisible);
  }

  void _cyclePlaylistMode(AudioService audio) {
    final currentMode = audio.playbackMode;
    final nextMode = AppPlaybackMode
        .values[(currentMode.index + 1) % AppPlaybackMode.values.length];
    audio.setPlaybackMode(nextMode);
  }

  void _showEqualizerPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const EqualizerPanel(),
    );
  }

  void _showSleepTimerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SleepTimerSheet(),
    );
  }

  Future<void> _showSongTagCompletionSheet(
    BuildContext context,
    AudioService audio,
  ) async {
    final song = ref.read(audioCurrentMusicProvider);
    if (song == null) return;
    final duration = ref.read(audioDurationProvider);
    final messenger = ScaffoldMessenger.of(context);

    final l10n = AppLocalizations.of(context)!;
    final popped =
        await showModalBottomSheet<(MusicBrainzTagSelectionResult, bool)>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => SongTagCompletionSheet(
            songPath: song.path,
            currentTitle: song.displayName,
            currentArtist: song.artist,
            currentAlbum: song.album,
            durationMillis: duration.inMilliseconds,
          ),
        );

    if (popped == null || !mounted) return;
    final result = popped.$1;
    final savedToSourceFile = popped.$2;

    await _applySongMetadataResult(
      messenger,
      audio: audio,
      metadata: result.metadata,
      artworkBytes: result.artworkBytes,
      successMessage: savedToSourceFile
          ? l10n.songTagsSavedToSourceFileAndApp
          : (result.artworkBytes != null
                ? l10n.tagCompletionSuccessWithCover
                : l10n.tagCompletionSuccess),
    );
  }

  Future<void> _showSongTagEditSheet(
    BuildContext context,
    AudioService audio,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final song = ref.read(audioCurrentMusicProvider);
    if (song == null) return;
    final messenger = ScaffoldMessenger.of(context);

    final result = await showSongTagEditSheet(context, song: song);
    if (result == null || !mounted) return;

    await _applySongMetadataResult(
      messenger,
      audio: audio,
      metadata: result.metadata,
      artworkBytes: result.artworkBytes,
      successMessage: result.savedToSourceFile
          ? l10n.songTagsSavedToSourceFileAndApp
          : l10n.songTagsSavedToApp,
    );
  }

  Future<void> _applySongMetadataResult(
    ScaffoldMessengerState messenger, {
    required AudioService audio,
    required SongMetadata metadata,
    required Uint8List? artworkBytes,
    required String successMessage,
  }) async {
    final scanner = ref.read(scannerServiceProvider);
    final playlistService = ref.read(playlistServiceProvider);

    await audio.applyUpdatedSongMetadata(metadata, artworkBytes: artworkBytes);
    scanner.updateMetadataForPath(metadata, artworkBytes: artworkBytes);
    await playlistService.updateSongMetadataByPath(
      metadata,
      artworkBytes: artworkBytes,
    );

    if (mounted) {
      setState(() {
        _pendingArtworkBytes = artworkBytes;
        if (artworkBytes != null) {
          _fileArtworkBytesCache[metadata.path] = artworkBytes;
        } else {
          _fileArtworkBytesCache.remove(metadata.path);
        }
      });
    }

    if (mounted) {
      AppSnackBar.show(context, ref, SnackBar(content: Text(successMessage)));
    }
  }

  void _showTagSaveMenu(
    BuildContext context,
    AudioService audio, {
    required bool isModified,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final currentSong = ref.read(audioCurrentMusicProvider);
    final queue = ref.read(audioPlaybackQueueProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isEditEnabled = currentSong != null;
    final isSaveEnabled =
        currentSong != null &&
        isMetadataWritable(currentSong.path) &&
        isModified;
    final isQueueEnabled = queue.isNotEmpty;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : theme.colorScheme.surface,
        title: Text(
          l10n.saveTagsToFile,
          style: TextStyle(
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit_rounded,
                color: isEditEnabled
                    ? Colors.orangeAccent
                    : (isDark ? Colors.white30 : theme.disabledColor),
              ),
              title: Text(
                l10n.editSongTagsTitle,
                style: TextStyle(
                  color: isEditEnabled
                      ? (isDark ? Colors.white : theme.colorScheme.onSurface)
                      : (isDark ? Colors.white38 : theme.disabledColor),
                ),
              ),
              enabled: isEditEnabled,
              onTap: () {
                Navigator.pop(dialogContext);
                _showSongTagEditSheet(context, audio);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.music_note,
                color: isSaveEnabled
                    ? Colors.blueAccent
                    : (isDark ? Colors.white30 : theme.disabledColor),
              ),
              title: Text(
                l10n.saveCurrentTagsToFile,
                style: TextStyle(
                  color: isSaveEnabled
                      ? (isDark ? Colors.white : theme.colorScheme.onSurface)
                      : (isDark ? Colors.white38 : theme.disabledColor),
                ),
              ),
              enabled: isSaveEnabled,
              onTap: () {
                Navigator.pop(dialogContext);
                _saveCurrentSongTags(audio);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.queue_music,
                color: isQueueEnabled
                    ? Colors.greenAccent
                    : (isDark ? Colors.white30 : theme.disabledColor),
              ),
              title: Text(
                l10n.saveQueueTagsToFile,
                style: TextStyle(
                  color: isQueueEnabled
                      ? (isDark ? Colors.white : theme.colorScheme.onSurface)
                      : (isDark ? Colors.white38 : theme.disabledColor),
                ),
              ),
              enabled: isQueueEnabled,
              onTap: () {
                Navigator.pop(dialogContext);
                _saveQueueTags(audio);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCurrentSongTags(AudioService audio) async {
    final l10n = AppLocalizations.of(context)!;
    final snapshot = ref.read(audioSnapshotProvider);
    final song = snapshot.currentMusic;
    if (song == null) return;

    // Check if format is supported
    if (!isMetadataWritable(song.path)) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          ref,
          SnackBar(content: Text(l10n.unsupportedFormatSingle)),
        );
      }
      return;
    }

    // Show loading
    if (mounted) {
      AppSnackBar.show(context, ref, SnackBar(content: Text(l10n.savingTags)));
    }

    try {
      final success = await MetadataHelper.saveDatabaseMetadataToFile(
        song.path,
        fallbackMediaUri: song.mediaUri,
      );

      if (success) {
        final db = MetadataDatabase();
        final updatedMetadata = await db.getSongMetadata(song.path);
        if (updatedMetadata != null) {
          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          await _applySongMetadataResult(
            messenger,
            audio: audio,
            metadata: updatedMetadata,
            artworkBytes: song.artworkBytes,
            successMessage: l10n.tagsSaved,
          );
        }
      } else {
        if (!mounted) return;
        final isOccupied = MetadataHelper.lastWriteError == 'file_occupied';
        showToast(
          isOccupied ? l10n.fileOccupiedByOtherApp : l10n.tagsSaveFailed,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final isOccupied = MetadataHelper.lastWriteError == 'file_occupied';
      showToast(isOccupied ? l10n.fileOccupiedByOtherApp : l10n.tagsSaveFailed);
    }
  }

  Future<void> _saveQueueTags(AudioService audio) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final queue = ref.read(audioPlaybackQueueProvider);
    if (queue.isEmpty) return;

    // Show initial loading message
    AppSnackBar.show(
      context,
      ref,
      SnackBar(
        content: Text(l10n.savingTags),
        duration: const Duration(seconds: 5),
      ),
    );

    // First, get metadata from database for each song
    final db = MetadataDatabase();
    final queuePaths = queue.map((s) => s.path).toList();
    final metadataMap = <String, SongMetadata>{};

    for (final path in queuePaths) {
      final metadata = await db.getSongMetadata(path);
      if (metadata != null) {
        metadataMap[path] = metadata;
      }
    }

    // Filter songs that are modified and have writable format
    final modifiedSongs = <SongMetadata>[];
    final artworkBytesMap = <String, Uint8List?>{};
    final mediaUriMap = <String, String?>{};

    for (final song in queue) {
      if (!isMetadataWritable(song.path)) continue;

      final metadata = metadataMap[song.path];
      if (metadata != null && metadata.isModified) {
        modifiedSongs.add(metadata);
        artworkBytesMap[song.path] = song.artworkBytes;
        mediaUriMap[song.path] = song.mediaUri;
      }
    }

    if (modifiedSongs.isEmpty) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      AppSnackBar.show(
        context,
        ref,
        SnackBar(content: Text(l10n.noModifiedTagsToSave)),
      );
      return;
    }

    // Show initial snackbar with progress
    if (!mounted) return;
    messenger.hideCurrentSnackBar();
    AppSnackBar.show(
      context,
      ref,
      SnackBar(
        content: Text('${l10n.savingTags} 0/${modifiedSongs.length}'),
        duration: Duration(seconds: modifiedSongs.length + 2),
      ),
    );

    // Start background saving task
    _runBackgroundSaveTask(
      modifiedSongs,
      artworkBytesMap,
      mediaUriMap,
      messenger,
      l10n,
    );
  }

  void _runBackgroundSaveTask(
    List<SongMetadata> songs,
    Map<String, Uint8List?> artworkBytesMap,
    Map<String, String?> mediaUriMap,
    ScaffoldMessengerState messenger,
    AppLocalizations l10n,
  ) async {
    int savedCount = 0;
    int unsupportedCount = 0;
    int failedCount = 0;

    for (int i = 0; i < songs.length; i++) {
      final song = songs[i];
      final artworkBytes = artworkBytesMap[song.path];
      final mediaUri = mediaUriMap[song.path];

      final success = await MetadataHelper.saveDatabaseMetadataToFile(
        song.path,
        fallbackMediaUri: mediaUri,
      );

      if (success) {
        savedCount++;
        final db = MetadataDatabase();
        final updatedMetadata = await db.getSongMetadata(song.path);
        if (updatedMetadata != null) {
          final audio = ref.read(audioServiceProvider);
          final scanner = ref.read(scannerServiceProvider);
          final playlistService = ref.read(playlistServiceProvider);

          await audio.applyUpdatedSongMetadata(
            updatedMetadata,
            artworkBytes: artworkBytes,
          );
          scanner.updateMetadataForPath(
            updatedMetadata,
            artworkBytes: artworkBytes,
          );
          await playlistService.updateSongMetadataByPath(
            updatedMetadata,
            artworkBytes: artworkBytes,
          );
        }
      } else {
        if (isMetadataWritable(song.path)) {
          if (MetadataHelper.lastWriteError == 'file_occupied') {
            showToast(
              '${p.basename(song.path)}: ${l10n.fileOccupiedByOtherApp}',
            );
          }
          failedCount++;
        } else {
          unsupportedCount++;
        }
      }

      // Update progress snackbar
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      AppSnackBar.show(
        context,
        ref,
        SnackBar(
          content: Text('${l10n.savingTags} ${i + 1}/${songs.length}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Show final result
    if (!mounted) return;
    messenger.hideCurrentSnackBar();
    final messages = <String>[];
    if (savedCount > 0) {
      messages.add(l10n.tagsSavedCount(savedCount));
    }
    if (failedCount > 0) {
      messages.add(l10n.tagsSaveFailedCount(failedCount));
    }
    if (unsupportedCount > 0) {
      messages.add(l10n.unsupportedFormat(unsupportedCount));
    }

    AppSnackBar.show(context, ref, SnackBar(content: Text(messages.join(' '))));
  }

  void _showPlaylistModeSelector(BuildContext context, AudioService audio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const PlaylistModeSheet(),
    );
  }

  void _showMoreMenu(BuildContext context, AudioService audio) {
    final settings = ref.read(settingsServiceProvider);
    showVisualizerOptionsDialog(context, audio, settings);
  }

  @override
  Widget build(BuildContext context) {
    // Separate UI status from rendering visibility to avoid flicker
    final audio = ref.read(audioServiceProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    ref.listen<MusicFile?>(audioCurrentMusicProvider, (previous, next) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      final settings = ref.read(settingsServiceProvider);
      final bool isSmallWin = PlaybackPageUiTuning.isSmallWindow(
        size,
        isWaveformEnabled: settings.isWaveformProgressBarEnabled,
        isSmallWindowMode: settings.isSmallWindowMode,
      );
      if (isSmallWin) {
        if (next?.path == _pendingArtworkPath &&
            next?.artworkBytes?.length == _pendingArtworkBytes?.length) {
          return;
        }
        _logPlaybackPageTrace(
          'currentMusic listener | prev=${previous?.path ?? '-'} '
          'next=${next?.path ?? '-'} '
          'prevBytes=${previous?.artworkBytes?.length ?? 0} '
          'nextBytes=${next?.artworkBytes?.length ?? 0} '
          'pendingBefore=${_pendingArtworkPath ?? '-'}',
        );
        setState(() {
          _pendingArtworkBytes = next?.artworkBytes;
          _pendingArtworkPath = next?.path;
        });
        _logPlaybackPageTrace(
          'currentMusic listener applied pending | pendingAfter=${_pendingArtworkPath ?? '-'} '
          'bytes=${_pendingArtworkBytes?.length ?? 0}',
        );
      }
    });
    final currentMetadataAsync = currentMusic != null
        ? ref.watch(songMetadataProvider(currentMusic.path))
        : null;
    final isModified = currentMetadataAsync?.value?.isModified ?? false;
    final isLyricsMode = ref.watch(audioIsLyricsActiveProvider);
    final isVisualizerEnabled = ref.watch(audioIsVisualizerEnabledProvider);
    final isTransitioning = ref.watch(audioIsTransitioningProvider);
    final shouldDrawVisualizer = isVisualizerEnabled && !isTransitioning;
    final backgroundType = ref.watch(
      settingsServiceProvider.select((s) => s.playbackBackgroundType),
    );

    return Listener(
      onPointerDown: (event) {
        _handleInteraction();
      },
      onPointerMove: (event) => _handleInteraction(),
      onPointerHover: (event) => _handleInteraction(),
      child: OrientationBuilder(
        builder: (context, orientation) {
          final size = MediaQuery.of(context).size;
          final l10n = AppLocalizations.of(context)!;
          final settings = ref.watch(settingsServiceProvider);
          final bool isSmallWin = PlaybackPageUiTuning.isSmallWindow(
            size,
            isWaveformEnabled: settings.isWaveformProgressBarEnabled,
            isSmallWindowMode: settings.isSmallWindowMode,
          );
          _flushLyricsTranslationsAfterSmallWindowExit(isSmallWin);
          final isLandscape =
              !isSmallWin && (orientation == Orientation.landscape);
          final bool showCoverTip = !settings.hasShownCoverTapLyricTip &&
              !isLyricsMode &&
              !isSmallWin &&
              currentMusic != null;
          final bool showLyricsTip = !settings.hasShownLyricsMenuTip &&
              isLyricsMode &&
              !isSmallWin &&
              currentMusic != null;

          if (_lastOrientation != orientation) {
            _lastOrientation = orientation;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              audio.applyVisualizerSettings(orientation: orientation);
            });
          }
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          final isImmersiveTabBarEnabled = settings.isImmersiveTabBarEnabled;

          final shouldReserveBottomNavSpace =
              !isLyricsMode && !isLandscape && !isSmallWin;

          // When immersive tab bar is enabled, the NavigationBar in MainLayout
          // is positioned in a Stack over the content with height (60 + bottomPadding).
          double effectiveBottomPadding = bottomPadding;
          final lyricsBottomSpacerHeight = 0.0;
          double lyricsBottomTabBarHeight = 0.0;

          if (isImmersiveTabBarEnabled && !isLandscape && !isSmallWin) {
            // For lyrics mode, we want the background to be immersive (full screen),
            // so we don't pad the whole page. Instead, we pass the tab bar height
            // to the lyrics panel so it can add internal scrolling space.
            lyricsBottomTabBarHeight = 60.0;

            // For normal mode (controls visible), we pad the whole page to keep
            // the layout stable and avoid overlap with the tab bar.
            if (shouldReserveBottomNavSpace) {
              effectiveBottomPadding = 60.0 + bottomPadding;
            }
          }

          final smallWindowPanelMode = settings.smallWindowBottomPanelMode;
          final showMiniPanel =
              isSmallWin &&
              smallWindowPanelMode != SmallWindowBottomPanelMode.collapsed;

          Widget buildPlayerCard() {
            return Builder(
              builder: (context) {
                final isNext = ref.watch(audioLastActionNextProvider) ?? true;
                final currentMusic = ref.watch(audioCurrentMusicProvider);
                final duration = ref.watch(audioDurationProvider);
                final isVisualizerEnabled = ref.watch(
                  audioIsVisualizerEnabledProvider,
                );

                return PlaybackHeroCard(
                  coverKey: _coverKey,
                  lyricsKey: _lyricsKey,
                  isMini: false,
                  isLandscape: isLandscape,
                  isLyricsMode: isLyricsMode,
                  isNext: isNext,
                  lyricsBottomSpacerHeight: lyricsBottomSpacerHeight,
                  lyricsBottomTabBarHeight: lyricsBottomTabBarHeight,
                  overrideProgress: _isScrubbingProgress
                      ? _scrubProgress
                      : null,
                  overridePosition: _isScrubbingProgress
                      ? Duration(
                          milliseconds:
                              (_scrubProgress * duration.inMilliseconds)
                                  .round(),
                        )
                      : null,
                  showVisualizerToggle: isVisualizerEnabled,
                  onShowMoreMenu: () => _showMoreMenu(context, audio),
                  onCyclePlaylistMode: () => _cyclePlaylistMode(audio),
                  onShowPlaylistModeSelector: () =>
                      _showPlaylistModeSelector(context, audio),
                  onScrubbing: (val) {
                    _handleInteraction();
                    setState(() {
                      _isScrubbingProgress = true;
                      _scrubProgress = val;
                    });
                  },
                  onSeek: (val) {
                    final target = Duration(
                      milliseconds: (val * duration.inMilliseconds).round(),
                    );
                    setState(() {
                      _isScrubbingProgress = false;
                      _scrubProgress = val;
                    });
                    audio.seek(target);
                  },
                  onToggleVisualizer: () => _toggleVisualizer(audio),
                  onTagCompletionTap: currentMusic == null
                      ? null
                      : () => _showSongTagCompletionSheet(context, audio),
                  onTagCompletionLongPress: currentMusic == null
                      ? null
                      : () => _showTagSaveMenu(
                          context,
                          audio,
                          isModified: isModified,
                        ),
                  onSleepTimerTap: () => _showSleepTimerSheet(context),
                  onEqualizerTap: () => _showEqualizerPanel(context),
                  onCoverTap: _toggleLyricsMode,
                  onPrevious: audio.previous,
                  onPlayPause: audio.togglePlay,
                  onNext: () => toNextMusic(audio),
                  onVolumeTap: () {
                    _handleInteraction();
                    setState(() {
                      _showVolumeSlider = !_showVolumeSlider;
                      if (_showVolumeSlider) {
                        _startVolumeSliderTimer();
                      } else {
                        _cancelVolumeSliderTimer();
                      }
                    });
                  },
                  onVolumeDrag: (delta) {
                    _handleInteraction();
                    _adjustVolumeFromDrag(audio, delta);
                  },
                  onVolumeScroll: (deltaY) {
                    _handleInteraction();
                    _adjustVolumeFromScroll(audio, deltaY);
                  },
                  onCarouselAnimationComplete: _onCarouselAnimationComplete,
                );
              },
            );
          }

          final content = SafeArea(
            bottom: false,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              padding: PlaybackPageUiTuning.contentPadding(
                isLandscape: isLandscape,
                isLyricsMode: isLyricsMode,
                bottomPadding: effectiveBottomPadding,
                reserveBottomNavSpace: shouldReserveBottomNavSpace,
                isSmallWin: isSmallWin,
              ),
              child: Column(
                children: [
                  if (Platform.isWindows ||
                      Platform.isMacOS ||
                      Platform.isLinux)
                    const DragToMoveArea(
                      child: SizedBox(
                        height: PlaybackPageUiTuning.desktopTopSpacer,
                      ),
                    ),
                  if (showMiniPanel) ...[
                    SizedBox(
                      height: 360.0 - PlaybackPageUiTuning.desktopTopSpacer,
                      child: Center(child: buildPlayerCard()),
                    ),
                    Expanded(
                      child: switch (smallWindowPanelMode) {
                        SmallWindowBottomPanelMode.queue =>
                          const MiniQueueView(),
                        SmallWindowBottomPanelMode.lyrics =>
                          const MiniLyricsView(),
                        SmallWindowBottomPanelMode.collapsed =>
                          const SizedBox.shrink(),
                      },
                    ),
                  ] else
                    Expanded(child: Center(child: buildPlayerCard())),
                  if (isLandscape &&
                      (Platform.isWindows ||
                          Platform.isMacOS ||
                          Platform.isLinux))
                    const SizedBox(
                      height: PlaybackPageUiTuning.desktopTopSpacer,
                    ),
                ],
              ),
            ),
          );

          return Container(
            color: Colors.black,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      opacity: isSmallWin ? 0.0 : 1.0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        child: _buildBackgroundWidget(
                          context,
                          backgroundType,
                          settings,
                          forceSmallWin: false,
                          keySuffix: 'normal',
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !isSmallWin,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      opacity: isSmallWin ? 1.0 : 0.0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: ClipRect(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 800),
                                child: _buildBackgroundWidget(
                                  context,
                                  backgroundType,
                                  settings,
                                  forceSmallWin: true,
                                  keySuffix: 'small_clear',
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isWaveformEnabled =
                                    settings.isWaveformProgressBarEnabled;
                                const double scaleFactor = 0.82;

                                final pNormalControlsBaseIdealHeight =
                                    (PlaybackHeroCardUiTuning
                                            .controlsTopButtonsHeight +
                                        (isWaveformEnabled
                                            ? PlaybackHeroCardUiTuning
                                                  .waveformStandardTimeRowSpacing
                                            : PlaybackHeroCardUiTuning
                                                  .controlsRowPortraitGap) +
                                        (isWaveformEnabled
                                            ? PlaybackHeroCardUiTuning
                                                  .waveformOverlayHeight
                                            : 48.0) +
                                        (isWaveformEnabled
                                            ? 0.0
                                            : (8.0 +
                                                  PlaybackHeroCardUiTuning
                                                      .controlsTimeRowHeight +
                                                  PlaybackHeroCardUiTuning
                                                      .controlsRowPortraitGap +
                                                  PlaybackHeroCardUiTuning
                                                      .controlsMainButtonsHeight))) *
                                    scaleFactor;

                                final pNormalScale =
                                    (size.width /
                                            PlaybackHeroCardUiTuning
                                                .pControlsScaleBase)
                                        .clamp(0.9, 1.15) *
                                    scaleFactor;
                                final double maxControlsHeightFactor =
                                    isSmallWin
                                    ? 0.85
                                    : PlaybackHeroCardUiTuning
                                          .pControlsHeightFactor;
                                final pNormalControlsHeight =
                                    (pNormalControlsBaseIdealHeight *
                                            pNormalScale)
                                        .clamp(
                                          0.0,
                                          size.height * maxControlsHeightFactor,
                                        )
                                        .ceilToDouble();
                                final pNormalInfoHeight =
                                    PlaybackHeroCardUiTuning.pInfoHeight *
                                    pNormalScale;
                                final pNormalBottomLimit =
                                    size.height -
                                    PlaybackHeroCardUiTuning
                                        .portraitBottomReservedSpace;

                                const double bottomPadding = 12.0;
                                final pNormalControlsTop =
                                    pNormalBottomLimit -
                                    pNormalControlsHeight -
                                    bottomPadding;
                                final pNormalInfoTop =
                                    pNormalControlsTop -
                                    pNormalInfoHeight -
                                    4.0;

                                final double fadeStart =
                                    (pNormalInfoTop - 48.0) / size.height;
                                final double fadeEnd =
                                    pNormalInfoTop / size.height;
                                final double clampedStart = fadeStart.clamp(
                                  0.0,
                                  1.0,
                                );
                                final double clampedEnd = fadeEnd.clamp(
                                  0.0,
                                  1.0,
                                );

                                if (showMiniPanel) {
                                  // 小窗队列 / 小窗歌词模式统一对整块小窗做模糊，
                                  // 上下两个面板共享同一层背景，不再做分区处理。
                                  return ClipRect(
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(
                                        sigmaX: 20.0,
                                        sigmaY: 20.0,
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                  );
                                }

                                final Widget blurredBackground = ImageFiltered(
                                  imageFilter: ui.ImageFilter.blur(
                                    sigmaX: 20.0,
                                    sigmaY: 20.0,
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 800),
                                    child: _buildBackgroundWidget(
                                      context,
                                      backgroundType,
                                      settings,
                                      forceSmallWin: true,
                                      keySuffix: 'small_blurred',
                                    ),
                                  ),
                                );

                                return ClipRect(
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: const [
                                          Colors.transparent,
                                          Colors.black,
                                        ],
                                        stops: [clampedStart, clampedEnd],
                                      ).createShader(rect);
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: blurredBackground,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBackgroundScrim(
                  isLyricsMode,
                  backgroundType,
                  settings,
                  isSmallWin,
                ),
                if (shouldDrawVisualizer)
                  _buildVisualizerLayer(context, orientation),
                _buildLyricsModeScrim(
                  isLyricsMode,
                  backgroundType,
                  settings,
                  isSmallWin,
                ),
                RepaintBoundary(child: content),
                Positioned(
                  left: 0,
                  right: 0,
                  top: PlaybackPageUiTuning.statusBannerTop,
                  child: SafeArea(
                    bottom: false,
                    child: LyricsTaskStatusBanner(
                      key: const ValueKey('lyrics_task_status_banner'),
                    ),
                  ),
                ),
                if (_showVolumeSlider)
                  Builder(
                    builder: (context) {
                      final volume = ref.watch(audioVolumeProvider);
                      return VolumeSliderOverlay(
                        volume: volume,
                        onVolumeChanged: (val) {
                          _handleInteraction();
                          _startVolumeSliderTimer();
                          audio.setVolume(
                            val.roundToDouble(),
                            showVolumeHud: false,
                          );
                        },
                        onDismiss: () {
                          _cancelVolumeSliderTimer();
                          setState(() => _showVolumeSlider = false);
                        },
                        isLandscape: isLandscape,
                        getVolumeIcon: getVolumeIcon,
                        onDrag: (delta) {
                          _startVolumeSliderTimer();
                          _adjustVolumeFromDrag(
                            audio,
                            delta,
                            showVolumeHud: false,
                          );
                        },
                        onScroll: (deltaY) {
                          _startVolumeSliderTimer();
                          _adjustVolumeFromScroll(
                            audio,
                            deltaY,
                            showVolumeHud: false,
                          );
                        },
                        onInteraction: () {
                          _handleInteraction();
                          _startVolumeSliderTimer();
                        },
                      );
                    },
                  ),
                if (showCoverTip)
                  _TipOverlay(
                    targetKey: _coverKey,
                    isLandscape: isLandscape,
                    isLyricsMode: false,
                    onDismiss: () {
                      settings.hasShownCoverTapLyricTip = true;
                    },
                    tipCard: _buildTipCard(
                      context,
                      tipText: l10n.tapCoverToEnterLyricsMode,
                      onDismiss: () {
                        settings.hasShownCoverTapLyricTip = true;
                      },
                    ),
                  )
                else if (showLyricsTip)
                  _TipOverlay(
                    targetKey: _lyricsKey,
                    isLandscape: isLandscape,
                    isLyricsMode: true,
                    onDismiss: () {
                      settings.hasShownLyricsMenuTip = true;
                    },
                    tipCard: _buildTipCard(
                      context,
                      tipText: l10n.longPressLyricsPanelToOpenMenu,
                      onDismiss: () {
                        settings.hasShownLyricsMenuTip = true;
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundWidget(
    BuildContext context,
    int backgroundType,
    SettingsService settings, {
    bool? forceSmallWin,
    String? keySuffix,
  }) {
    switch (backgroundType) {
      case 1:
        return RepaintBoundary(
          key: ValueKey('fluid_bg_${keySuffix ?? 'default'}'),
          child: const DynamicMeshBackground(),
        );
      case 2:
        return Container(
          key: ValueKey(
            'solid_color_bg_${settings.playbackBackgroundColor}_${keySuffix ?? 'default'}',
          ),
          color: Color(settings.playbackBackgroundColor),
          width: double.infinity,
          height: double.infinity,
        );
      case 3:
        final path = settings.playbackBackgroundCustomImagePath;
        if (path.isEmpty || !File(path).existsSync()) {
          return Container(
            key: ValueKey('custom_image_empty_${keySuffix ?? 'default'}'),
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
          );
        }
        final imageWidget = Image.file(
          File(path),
          key: ValueKey('custom_image_bg_${path}_${keySuffix ?? 'default'}'),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white24,
                  size: 48,
                ),
              ),
            );
          },
        );
        final size = MediaQuery.of(context).size;
        final bool isSmallWinValue =
            forceSmallWin ??
            PlaybackPageUiTuning.isSmallWindow(
              size,
              isWaveformEnabled: settings.isWaveformProgressBarEnabled,
              isSmallWindowMode: settings.isSmallWindowMode,
            );
        final blur = settings.playbackCustomImageBlurSigma;
        if (blur > 0.0 && !isSmallWinValue) {
          return ImageFiltered(
            key: ValueKey(
              'custom_image_bg_blurred_${path}_${keySuffix ?? 'default'}',
            ),
            imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Transform.scale(scale: 1.2, child: imageWidget),
          );
        }
        return Transform.scale(scale: 1.2, child: imageWidget);
      case 0:
      default:
        return _buildBlurredBackground(
          context,
          settings,
          forceSmallWin: forceSmallWin,
          keySuffix: keySuffix,
        );
    }
  }

  Widget _buildBackgroundScrim(
    bool isLyricsMode,
    int backgroundType,
    SettingsService settings,
    bool isSmallWin,
  ) {
    double opacity = 0.30;
    if (backgroundType == 0 || backgroundType == 2 || backgroundType == 3) {
      opacity = settings.playbackBackgroundNormalOpacity;
    }

    final double targetOpacity = isSmallWin ? 0.0 : (isLyricsMode ? 0.0 : 1.0);

    return Positioned.fill(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        opacity: targetOpacity,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: settings.playbackRadialGradientEnabled
                  ? null
                  : Colors.black.withValues(alpha: opacity),
              gradient: settings.playbackRadialGradientEnabled
                  ? RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: opacity),
                      ],
                      stops: const [0.1, 1.0],
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLyricsModeScrim(
    bool isLyricsMode,
    int backgroundType,
    SettingsService settings,
    bool isSmallWin,
  ) {
    double opacity = SettingsService.defaultPlaybackBackgroundLyricsOpacity;
    if (backgroundType == 0 || backgroundType == 2 || backgroundType == 3) {
      opacity = settings.playbackBackgroundLyricsOpacity;
    }

    return Positioned.fill(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        opacity: isSmallWin || !isLyricsMode ? 0.0 : 1.0,
        child: IgnorePointer(
          child: ColoredBox(color: Colors.black.withValues(alpha: opacity)),
        ),
      ),
    );
  }

  /// 构建毛玻璃背景组件。
  ///
  /// 该组件实现了当音乐切换或封面更新时，背景图的平滑过渡效果。
  /// 使用 _pendingArtworkBytes，在轮播动画完成后才更新背景。
  Widget _buildBlurredBackground(
    BuildContext context,
    SettingsService settings, {
    bool? forceSmallWin,
    String? keySuffix,
  }) {
    final String finalSuffix =
        keySuffix ??
        (forceSmallWin == null ? 'auto' : (forceSmallWin ? 'small' : 'normal'));
    final size = MediaQuery.of(context).size;
    final bool isSmallWinValue =
        forceSmallWin ??
        PlaybackPageUiTuning.isSmallWindow(
          size,
          isWaveformEnabled: settings.isWaveformProgressBarEnabled,
          isSmallWindowMode: settings.isSmallWindowMode,
        );

    return RepaintBoundary(
      key: ValueKey('blurred_bg_$finalSuffix'),
      child: Stack(
        children: [
          // 简化后的背景渲染逻辑：在轮播动画完成后才更新背景。
          // 拿到原始大图后，利用 Image.memory 的 cacheWidth/cacheHeight 属性
          // 在解码阶段即完成缩小，从而替代之前手动生成的低清图逻辑。
          Builder(
            builder: (context) {
              final currentMusic = ref.watch(audioCurrentMusicProvider);
              final String? songPath = isSmallWinValue
                  ? currentMusic?.path
                  : (_pendingArtworkPath ?? currentMusic?.path);
              final songKey = songPath ?? 'empty';

              final metadata = songPath != null
                  ? ref.read(scannerServiceProvider).metadataMap[songPath]
                  : null;
              final String? artworkPath =
                  metadata?.artworkPath ??
                  (songPath == currentMusic?.path ? currentMusic?.artworkPath : null);
              final String? thumbnailPath =
                  metadata?.thumbnailPath ??
                  (songPath == currentMusic?.path ? currentMusic?.thumbnailPath : null);
              final Uint8List? cachedBytes = songPath != null
                  ? ((songPath == currentMusic?.path
                          ? currentMusic?.artworkBytes
                          : null) ??
                      ref.read(audioServiceProvider).getCachedArtwork(songPath))
                  : null;

              final isPc = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
              final int bgCacheSize = isSmallWinValue ? (isPc ? 1200 : 500) : 300;

              Widget? imageWidget;

              // 统一背景使用低清/缩略图逻辑：
              // 优先使用已缓存的缩略图文件，若未准备完成则回退至大图路径/字节，但强制使用小尺寸 cacheWidth/Height 解码，
              // 避免毛玻璃背景加载全高清大图占用过高内存和 GPU 开销。
              if (thumbnailPath != null &&
                  thumbnailPath.isNotEmpty &&
                  File(thumbnailPath).existsSync()) {
                imageWidget = Image.file(
                  File(thumbnailPath),
                  width: double.infinity,
                  height: double.infinity,
                  cacheWidth: bgCacheSize,
                  cacheHeight: bgCacheSize,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                );
              } else if (artworkPath != null &&
                  artworkPath.isNotEmpty &&
                  File(artworkPath).existsSync()) {
                imageWidget = Image.file(
                  File(artworkPath),
                  width: double.infinity,
                  height: double.infinity,
                  cacheWidth: bgCacheSize,
                  cacheHeight: bgCacheSize,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                );
              } else if (cachedBytes != null && cachedBytes.isNotEmpty) {
                imageWidget = Image.memory(
                  cachedBytes,
                  width: double.infinity,
                  height: double.infinity,
                  cacheWidth: bgCacheSize,
                  cacheHeight: bgCacheSize,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                );
              }

              final Widget content;
              if (imageWidget != null) {
                content = ImageFiltered(
                  // 使用稳定的 Key（依赖 songKey 而非动变图片 Key），
                  // 当同一首歌曲的图片源（缩略图 -> 内存字节）更新时，不会触发 ImageFiltered 的销毁重构，
                  // 从而消除了 Impeller (Vulkan) 下滤镜重建导致的单帧黑屏闪烁。
                  key: ValueKey('${songKey}_bg_cover_$finalSuffix'),
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: isSmallWinValue ? 0.0 : settings.playbackBlurredArtworkBlurSigma,
                    sigmaY: isSmallWinValue ? 0.0 : settings.playbackBlurredArtworkBlurSigma,
                  ),
                  child: Transform.scale(scale: 1.2, child: imageWidget),
                );
              } else {
                content = Container(
                  key: ValueKey('bg_empty_${songKey}_$finalSuffix'),
                  color: Colors.black,
                  width: double.infinity,
                  height: double.infinity,
                );
              }

              // 过渡动画逻辑：新封面直接淡入盖在旧封面之上。
              // 这种方式避免了传统的“双向淡入淡出（Cross-fade）”可能导致的背景短暂变暗或跳动。
              return _SafeBackgroundSwitcher(
                songKey: songKey,
                duration: const Duration(milliseconds: 1000),
                child: content,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizerLayer(BuildContext context, Orientation orientation) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: StreamBuilder<FftFrame>(
          stream: ref.read(audioServiceProvider).visualizerStream,
          builder: (context, snapshot) {
            final frame = snapshot.data;
            if (frame == null) return const SizedBox.shrink();

            final settings = ref.watch(settingsServiceProvider);
            final dynamicStartColor = ref.watch(audioDynamicStartColorProvider);
            final dynamicEndColor = ref.watch(audioDynamicEndColorProvider);
            final isLandscape = orientation == Orientation.landscape;
            final gap = isLandscape
                ? settings.landscapeGap
                : settings.portraitGap;

            return ExcludeSemantics(
              child: CustomPaint(
                painter: FftPainter(
                  values: frame.values,
                  gap: gap,
                  color: settings.isVisualizerDynamicColor
                      ? (dynamicStartColor ?? settings.visualizerColor)
                      : settings.visualizerColor,
                  opacity: settings.visualizerOpacity,
                  useGradient: settings.isVisualizerGradientEnabled,
                  startColor: settings.isVisualizerDynamicStartColor
                      ? (dynamicStartColor ?? settings.visualizerStartColor)
                      : settings.visualizerStartColor,
                  endColor: settings.isVisualizerDynamicEndColor
                      ? (dynamicEndColor ?? settings.visualizerEndColor)
                      : settings.visualizerEndColor,
                  gradientStop1: settings.visualizerGradientStop1,
                  gradientStop2: settings.visualizerGradientStop2,
                  gradientTileMode: settings.visualizerGradientTileMode,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required String tipText,
    required VoidCallback onDismiss,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final dismissText = l10n.gotIt;

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]!.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tipText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onDismiss,
                child: Text(
                  dismissText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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

class _SafeBackgroundSwitcher extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Object songKey;

  const _SafeBackgroundSwitcher({
    required this.child,
    required this.duration,
    required this.songKey,
  });

  @override
  State<_SafeBackgroundSwitcher> createState() =>
      _SafeBackgroundSwitcherState();
}

class _SafeBackgroundSwitcherState extends State<_SafeBackgroundSwitcher>
    with TickerProviderStateMixin {
  final List<_SwitcherItem> _items = [];

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[_SafeBackgroundSwitcher] $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _addNewChild(widget.child, animate: false);
  }

  @override
  void didUpdateWidget(_SafeBackgroundSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.songKey != oldWidget.songKey) {
      _addNewChild(widget.child, animate: true);
    } else {
      if (_items.isNotEmpty) {
        final last = _items.last;
        if (last.child.key != widget.child.key) {
          setState(() {
            _items[_items.length - 1] = _SwitcherItem(
              child: widget.child,
              controller: last.controller,
              animation: last.animation,
            );
          });
        }
      }
    }
  }

  void _addNewChild(Widget child, {required bool animate}) {
    final key = child.key;
    _log('Add new child: key=$key, animate=$animate');

    final controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final item = _SwitcherItem(
      child: child,
      controller: controller,
      animation: CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    setState(() {
      _items.add(item);
      // Immediately remove and dispose any background switcher items older than the last 2 items
      while (_items.length > 2) {
        final removed = _items.removeAt(0);
        removed.controller.dispose();
      }
    });

    if (animate) {
      controller.forward(from: 0.0).then((_) {
        if (mounted) {
          _cleanUpPreviousItems();
        }
      }).catchError((_) {});
    } else {
      controller.value = 1.0;
    }
  }

  void _cleanUpPreviousItems() {
    setState(() {
      if (_items.isNotEmpty && _items.last.controller.isCompleted) {
        final last = _items.last;
        final removedCount = _items.length - 1;
        _log(
          'Clean up previous items. Removing $removedCount items, keeping last key=${last.child.key}',
        );
        for (var i = 0; i < _items.length - 1; i++) {
          _items[i].controller.dispose();
        }
        _items.clear();
        _items.add(last);
      }
    });
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: _items.map((item) {
        final isLast = item == _items.last;
        if (isLast) {
          return FadeTransition(
            key: ObjectKey(item),
            opacity: item.animation,
            child: item.child,
          );
        } else {
          return KeyedSubtree(key: ObjectKey(item), child: item.child);
        }
      }).toList(),
    );
  }
}

class _SwitcherItem {
  final Widget child;
  final AnimationController controller;
  final Animation<double> animation;

  _SwitcherItem({
    required this.child,
    required this.controller,
    required this.animation,
  });
}

class _CoverCutoutClipper extends CustomClipper<Path> {
  final Rect coverRect;
  final double borderRadius;

  _CoverCutoutClipper({required this.coverRect, required this.borderRadius});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        coverRect,
        Radius.circular(borderRadius),
      ));
    return Path.combine(PathOperation.difference, path, cutoutPath);
  }

  @override
  bool shouldReclip(covariant _CoverCutoutClipper oldClipper) {
    return oldClipper.coverRect != coverRect || oldClipper.borderRadius != borderRadius;
  }
}

class _TipOverlay extends StatefulWidget {
  final GlobalKey targetKey;
  final bool isLandscape;
  final bool isLyricsMode;
  final VoidCallback onDismiss;
  final Widget tipCard;

  const _TipOverlay({
    required this.targetKey,
    required this.isLandscape,
    required this.isLyricsMode,
    required this.onDismiss,
    required this.tipCard,
  });

  @override
  State<_TipOverlay> createState() => _TipOverlayState();
}

class _TipOverlayState extends State<_TipOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  Rect? _targetRect;
  double _targetRadius = 24.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scheduleMeasurement();
    });
  }

  void _scheduleMeasurement() {
    if (!mounted) return;
    _measureTarget();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scheduleMeasurement();
    });
  }

  void _measureTarget() {
    final contextTarget = widget.targetKey.currentContext;
    if (contextTarget == null) return;

    final RenderBox? renderBox = contextTarget.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && renderBox.size.width > 0 && renderBox.size.height > 0) {
      final overlayRenderBox = context.findRenderObject() as RenderBox?;
      if (overlayRenderBox != null && overlayRenderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero, ancestor: overlayRenderBox);
        final rect = position & renderBox.size;
        if (_targetRect != rect) {
          setState(() {
            _targetRect = rect;
            _targetRadius = widget.isLyricsMode
                ? math.min(24.0, math.min(renderBox.size.width, renderBox.size.height) * 0.08)
                : math.min(24.0, renderBox.size.width * 0.2);
          });
        }
        if (_controller.status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        final rect = _targetRect;
        if (_opacityAnimation.value == 0.0 || rect == null) {
          return const SizedBox.shrink();
        }
        
        final size = MediaQuery.of(context).size;
        final double screenWidth = size.width;
        final double screenHeight = size.height;
        
        final double cardWidth = math.min(280.0, screenWidth - 32.0);
        
        final double left;
        final double top;

        if (widget.isLyricsMode) {
          left = (rect.left + (rect.width - cardWidth) / 2)
              .clamp(16.0, math.max(16.0, screenWidth - cardWidth - 16));
          top = widget.isLandscape
              ? (rect.top + (rect.height - 110) / 2)
                  .clamp(16.0, math.max(16.0, screenHeight - 130))
              : (rect.top + 48.0)
                  .clamp(rect.top + 16.0, math.max(rect.top + 16.0, rect.bottom - 130.0));
        } else {
          left = widget.isLandscape
              ? (rect.right + 24)
                  .clamp(16.0, math.max(16.0, screenWidth - cardWidth - 16))
              : (rect.left + (rect.width - cardWidth) / 2)
                  .clamp(16.0, math.max(16.0, screenWidth - cardWidth - 16));
          top = widget.isLandscape
              ? rect.top + (rect.height - 110) / 2
              : rect.bottom + 24;
        }

        return Positioned.fill(
          child: IgnorePointer(
            ignoring: _opacityAnimation.value < 0.1,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onDismiss,
                      child: ClipPath(
                        clipper: _CoverCutoutClipper(
                          coverRect: rect,
                          borderRadius: _targetRadius,
                        ),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: rect.left,
                    top: rect.top,
                    width: rect.width,
                    height: rect.height,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(_targetRadius),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: top,
                    left: left,
                    width: cardWidth,
                    child: widget.tipCard,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
