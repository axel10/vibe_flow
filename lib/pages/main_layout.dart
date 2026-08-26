import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/app_tooltip.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

import '../l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import '../pages/folder_page.dart';
import '../pages/playback_page.dart';
import '../pages/library_page.dart';
import '../pages/queue_page.dart';
import '../pages/settings_page.dart';
import '../pages/sharing_page.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/player/sharing/sharing_service.dart';
import 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
import 'package:vynody/dialogs/transfer_dialogs.dart';
import 'package:vynody/dialogs/remote_pair_dialogs.dart';
import 'package:vynody/player/library/music_file_utils.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/player/settings/shortcut_bindings.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/audio/playback_source.dart';
import 'main_layout_riverpod.dart';
import 'onboarding_page.dart';
import '../widgets/desktop_window_title_bar.dart';
import '../widgets/playback_hero_card.dart';
import '../widgets/playback_ui_tuning.dart';
import '../widgets/volume_controls.dart';
import '../widgets/global_drop_target.dart';
import '../widgets/library_selection_scope.dart';
import 'package:vynody/utils/deleted_song_snack.dart';
import 'package:vynody/utils/app_snack_bar.dart';

Route<void> buildMainLayoutRoute({
  required List<String> args,
  required int initialIndex,
}) {
  return PageRouteBuilder<void>(
    settings: RouteSettings(name: 'main-tab-$initialIndex'),
    pageBuilder: (context, animation, secondaryAnimation) =>
        MainLayout(args: args, initialIndex: initialIndex),
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

Future<void> navigateToMainTab(
  BuildContext context, {
  required int index,
  List<String> args = const [],
}) async {
  // 切页前先收起所有 tooltip，避免鼠标事件在路由切换期间继续驱动
  // 旧页面或新页面上的 RawTooltip 状态。
  Tooltip.dismissAllToolTips();

  // 让当前指针事件先完全结束，再执行路由替换。
  await Future<void>.delayed(Duration.zero);
  if (!context.mounted) return;

  try {
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(mainTabIndexProvider.notifier).setIndex(index);
    return;
  } catch (e) {
    debugPrint('[navigateToMainTab] ProviderScope fallback: $e');
  }

  await Navigator.of(
    context,
    rootNavigator: true,
  ).pushReplacement(buildMainLayoutRoute(args: args, initialIndex: index));
}

class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}

class NextIntent extends Intent {
  const NextIntent();
}

class PreviousIntent extends Intent {
  const PreviousIntent();
}

class VolumeUpIntent extends Intent {
  const VolumeUpIntent();
}

class VolumeDownIntent extends Intent {
  const VolumeDownIntent();
}

class MuteIntent extends Intent {
  const MuteIntent();
}

class SeekForwardIntent extends Intent {
  const SeekForwardIntent();
}

class SeekBackwardIntent extends Intent {
  const SeekBackwardIntent();
}

class ToggleFullScreenIntent extends Intent {
  const ToggleFullScreenIntent();
}

class ExitFullScreenIntent extends Intent {
  const ExitFullScreenIntent();
}

class ExitFullScreenAction extends Action<ExitFullScreenIntent> {
  final _MainLayoutState state;
  ExitFullScreenAction(this.state);

  @override
  bool isEnabled(Intent intent) {
    return state._isFullScreen;
  }

  @override
  Object? invoke(ExitFullScreenIntent intent) {
    state._setFullScreen(false);
    return null;
  }
}

class MainLayout extends ConsumerStatefulWidget {
  final List<String> args;
  final int initialIndex;
  final int initialLibraryTabIndex;
  final bool initialAlbums3DView;
  final int initialAlbums3DIndex;

  const MainLayout({
    super.key,
    required this.args,
    this.initialIndex = 1,
    this.initialLibraryTabIndex = 0,
    this.initialAlbums3DView = false,
    this.initialAlbums3DIndex = 0,
  });

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout>
    with WindowListener, TickerProviderStateMixin {
  late int _currentIndex;
  double? _lastVolume;
  bool _showMiniVolumeSlider = false;
  late final AudioService _audioService;
  bool _isFullScreen = false;
  DateTime? _ignoreResizeEventsUntil;
  Timer? _windowResizeDebounceTimer;
  late final MainLayoutUiController _uiController;
  late final AppShortcutManager _shortcutManager;
  final GlobalKey<FoldersPageState> _foldersPageKey =
      GlobalKey<FoldersPageState>();

  AnimationController? _onboardingAnimController;
  bool _isOnboardingAnimatingOut = false;

  MainLayoutUiController get _ui => _uiController;

  void _handleDesktopPointerActivity(PointerEvent event) {
    final settings = ref.read(settingsServiceProvider);
    if (settings.isSmallWindowMode) {
      settings.resetInactivity();
    }

    if (event is PointerDownEvent) {
      debugPrint('event.buttons: ${event.buttons}');
      if (event.buttons == 16) {
        // Forward button
        _ui.setVolumeHudVisible(true);
        _audioService.setVolume((_audioService.volume + 5).roundToDouble());
      } else if (event.buttons == 8) {
        // Back button
        _ui.setVolumeHudVisible(true);
        _audioService.setVolume((_audioService.volume - 5).roundToDouble());
      }
    }

    if (_currentIndex != 1) {
      return;
    }
    if (settings.isImmersiveTabBarEnabled) {
      if (!ref.read(mainLayoutUiControllerProvider).showImmersiveTabBar) {
        _ui.showImmersiveTabBar();
      }
      _ui.hideImmersiveTabBarAfter(const Duration(seconds: 3));
    }
  }

  Future<void> _handleBackPressed() async {
    if (!Platform.isAndroid) return;

    // 如果在目录页，且当前处于非根目录，则返回上一级目录
    if (_currentIndex == 0) {
      if (_foldersPageKey.currentState?.handleBackPressed() ?? false) {
        return;
      }
    }

    await SystemNavigator.pop();
  }

  void _syncDeletedSongNoticeHandler() {
    _audioService.setMissingSongNoticeHandler(({required bool skipped}) {
      if (!mounted) return;
      showDeletedSongSnack(context, ref, skipped: skipped);
    });
  }

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    final isStressTest = widget.args.any(
      (arg) => arg == '--stress-test' || arg == '--audio-stress-test',
    );
    final initialIndex = isStressTest
        ? 0
        : (!settings.hasShownOnboarding ? 0 : widget.initialIndex);
    _currentIndex = initialIndex;
    Future.microtask(() {
      if (mounted) {
        ref.read(mainTabIndexProvider.notifier).setIndex(initialIndex);
      }
    });
    _lastVolume = ref.read(audioVolumeProvider);
    _audioService = ref.read(audioServiceProvider);
    _uiController = ref.read(mainLayoutUiControllerProvider.notifier);
    _shortcutManager = AppShortcutManager();
    _syncDeletedSongNoticeHandler();

    final isProUnlocked = ref.read(isProUnlockedProvider);
    if (settings.lanSharingEnabled && isProUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final serverState = ref.read(sharingServerStateProvider);
        if (!serverState.isRunning) {
          ref.read(sharingServerStateProvider.notifier).start();
        }
      });
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
      windowManager.isFullScreen().then((isFull) {
        if (mounted) {
          setState(() {
            _isFullScreen = isFull;
          });
          ref.read(isWindowFullScreenProvider.notifier).state = isFull;
        }
      });
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleArgs();
        _checkAndRunStressTestAutomation();
      });
    }
  }

  @override
  void dispose() {
    _onboardingAnimController?.dispose();
    _windowResizeDebounceTimer?.cancel();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    _audioService.setMissingSongNoticeHandler(null);
    super.dispose();
  }

  @override
  void onWindowMinimize() {
    ref.read(isWindowMinimizedProvider.notifier).state = true;
    debugPrint('[main_layout] Window minimized');
  }

  @override
  void onWindowRestore() {
    ref.read(isWindowMinimizedProvider.notifier).state = false;
    debugPrint('[main_layout] Window restored');
  }

  @override
  void onWindowMaximize() {
    ref.read(isWindowMinimizedProvider.notifier).state = false;
    debugPrint('[main_layout] Window maximized');
  }

  @override
  void onWindowUnmaximize() {
    ref.read(isWindowMinimizedProvider.notifier).state = false;
    debugPrint('[main_layout] Window unmaximized');
  }

  @override
  void onWindowFocus() {
    ref.read(isWindowMinimizedProvider.notifier).state = false;
    debugPrint('[main_layout] Window focused');
  }

  @override
  void onWindowEnterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
    ref.read(isWindowFullScreenProvider.notifier).state = true;
    debugPrint('[main_layout] Window entered full screen');
  }

  @override
  void onWindowLeaveFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
    ref.read(isWindowFullScreenProvider.notifier).state = false;
    debugPrint('[main_layout] Window left full screen');
  }

  @override
  void onWindowResized() {
    if (_ignoreResizeEventsUntil != null &&
        DateTime.now().isBefore(_ignoreResizeEventsUntil!)) {
      debugPrint(
        '[vynody] onWindowResized: IGNORED because within ignore period',
      );
      return;
    }
    _windowResizeDebounceTimer?.cancel();
    _windowResizeDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final settings = ref.read(settingsServiceProvider);
      if (settings.isSmallWindowMode) {
        final size = await windowManager.getSize();
        debugPrint(
          '[vynody] onWindowResized (debounced): size=$size, mode=${settings.smallWindowBottomPanelMode}',
        );
        if (settings.smallWindowBottomPanelMode !=
            SmallWindowBottomPanelMode.collapsed) {
          settings.savedSmallWindowQueueSize = size;
          debugPrint('[vynody] savedSmallWindowQueueSize updated to $size');
        } else {
          settings.savedSmallWindowSize = size;
          debugPrint('[vynody] savedSmallWindowSize updated to $size');
        }
      } else {
        final isMaximized = await windowManager.isMaximized();
        final isFullScreen = await windowManager.isFullScreen();
        final isMinimized = await windowManager.isMinimized();
        if (!isMaximized && !isFullScreen && !isMinimized) {
          final size = await windowManager.getSize();
          if (size.width >= 400 && size.height >= 650) {
            settings.savedRegularWindowSize = size;
            debugPrint('[vynody] savedRegularWindowSize updated to $size');
          }
        }
      }
    });
  }

  Future<void> _setFullScreen(bool enable) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (enable) {
        await windowManager.setFullScreen(true);
      } else {
        await windowManager.setFullScreen(false);
      }
      setState(() {
        _isFullScreen = enable;
      });
      ref.read(isWindowFullScreenProvider.notifier).state = enable;
    }
  }

  /// 处理启动时的命令行参数 (初次启动，例如双击打开应用)
  Future<void> _handleArgs() async {
    // 无参数直接返回
    if (!mounted || widget.args.isEmpty) {
      debugPrint(
        '[external-open] _handleArgs skipped mounted=$mounted args=${widget.args}',
      );
      return;
    }

    final audio = ref.read(audioServiceProvider);
    debugPrint('[external-open] _handleArgs start args=${widget.args}');

    for (var arg in widget.args) {
      // 预处理路径字符串
      final path = arg.replaceAll('"', '').trim();
      if (path.isEmpty) {
        debugPrint('[external-open] _handleArgs skip empty arg="$arg"');
        continue;
      }

      // 文件存在性校验
      final exists = File(path).existsSync();
      final isMusic = MusicFileUtils.isMusicFilePath(path);
      debugPrint(
        '[external-open] _handleArgs inspect path=$path exists=$exists isMusic=$isMusic',
      );
      if (!exists) {
        continue;
      }

      // 匹配后缀
      if (isMusic) {
        debugPrint('[external-open] _handleArgs playFile begin path=$path');
        // 调用播放服务读取音频并播放
        // append: false 确保清空队列并将此歌曲设为唯一歌曲播放
        await audio.playFile(path, p.basename(path), append: false);
        debugPrint('[external-open] _handleArgs playFile done path=$path');

        if (!mounted) {
          debugPrint(
            '[external-open] _handleArgs abort after playFile, widget unmounted',
          );
          return;
        }

        // 切换到播放详情视图 (索引 1)
        debugPrint(
          '[external-open] _handleArgs navigateToMainTab begin path=$path',
        );
        await navigateToMainTab(context, index: 1);
        debugPrint(
          '[external-open] _handleArgs navigateToMainTab done path=$path',
        );

        // 处理完一个核心音频文件后停止（通常双击只打开一个文件）
        break;
      }
    }

    debugPrint('[external-open] _handleArgs end');
  }

  Future<void> _checkAndRunStressTestAutomation() async {
    final isStressTest = widget.args.any(
      (arg) => arg == '--stress-test' || arg == '--audio-stress-test',
    );
    if (!isStressTest) return;

    debugPrint(
      '[stress-test] Stress test flag detected, starting root folders playback automation...',
    );

    // Wait for the scanner service to finish loading/initializing.
    final scanner = ref.read(scannerServiceProvider);
    await scanner.ready;

    // Poll for up to 10 seconds (50 * 200ms) until root folders are loaded and we can retrieve allRootSongs.
    AudioService? audioService;
    final allRootSongs = <MusicFile>[];
    final seenAll = <String>{};

    for (int i = 0; i < 50; i++) {
      if (!mounted) return;
      audioService = ref.read(audioServiceProvider);

      final rootFolders = scanner.rootFolders;
      seenAll.clear();
      allRootSongs.clear();
      for (final folder in rootFolders) {
        for (final song in folder.allSongs) {
          if (seenAll.add(song.path)) {
            allRootSongs.add(song);
          }
        }
      }

      if (allRootSongs.isNotEmpty) {
        debugPrint(
          '[stress-test] Found ${allRootSongs.length} root folder songs to play.',
        );
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    if (!mounted || audioService == null) return;

    // Fallback: If no root songs are scanned yet, try reading non-external songs from MetadataDatabase
    if (allRootSongs.isEmpty) {
      debugPrint(
        '[stress-test] Root folders empty. Checking database for non-external songs...',
      );
      try {
        final db = MetadataDatabase();
        final songs = await db.getAllSongMetadata();
        final filtered = songs.where((song) {
          final flags = song.sourceFlags ?? 0;
          return (flags & SongSourceFlags.external) == 0;
        });

        for (final firstMetadata in filtered) {
          allRootSongs.add(
            MusicFile(
              path: firstMetadata.path,
              name: p.basename(firstMetadata.path),
              title: firstMetadata.title,
              artist: firstMetadata.artist,
              album: firstMetadata.album,
              trackNumber: firstMetadata.trackNumber,
              id: firstMetadata.id,
              artworkPath: firstMetadata.artworkPath,
              thumbnailPath: firstMetadata.thumbnailPath,
              artworkWidth: firstMetadata.artworkWidth,
              artworkHeight: firstMetadata.artworkHeight,
              durationMillis: firstMetadata.duration,
              lastModifiedTime: firstMetadata.lastModifiedTime,
            ),
          );
        }
        debugPrint(
          '[stress-test] Fallback database query found ${allRootSongs.length} non-external songs.',
        );
      } catch (e) {
        debugPrint('[stress-test] Fallback database query failed: $e');
      }
    }

    if (allRootSongs.isNotEmpty) {
      debugPrint(
        '[stress-test] Triggering "Play All" on root directory and seeking first song to 0ms...',
      );
      await audioService.playPlaylist(
        allRootSongs,
        source: PlaybackSource(
          type: PlaybackSourceType.folder,
          id: 'root',
          name: 'Directory',
        ),
      );

      // Wait a bit for playback to be initialized
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      // Seek to 0ms and ensure playback is started
      await audioService.seek(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      final isPlaying = ref.read(audioIsPlayingProvider);
      if (!isPlaying) {
        debugPrint('[stress-test] Starting playback...');
        await audioService.togglePlay();
      }

      // Automatically navigate to the PlaybackPage (index 1) after clicking Play All
      debugPrint('[stress-test] Navigating to playback page...');
      await _onDestinationSelected(1);
    } else {
      debugPrint(
        '[stress-test] WARNING: No music files available to run Play All in stress test.',
      );
      // Still navigate to PlaybackPage so the UI is on the correct page
      await _onDestinationSelected(1);
    }
  }

  Future<void> _onDestinationSelected(int index) async {
    if (index == 5) {
      await _openSettingsPage();
      return;
    }
    if (index == _currentIndex) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
    ref.read(mainTabIndexProvider.notifier).setIndex(index);
  }

  Future<void> _openSettingsPage() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await Navigator.of(
        context,
      ).push(CupertinoPageRoute<void>(builder: (_) => const SettingsPage()));
    } else {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
    }
  }

  Map<ShortcutActivator, Intent> _buildShortcutMap(SettingsService settings) {
    final bindings = <AppShortcutAction, Intent>{
      AppShortcutAction.playPause: const PlayPauseIntent(),
      AppShortcutAction.next: const NextIntent(),
      AppShortcutAction.previous: const PreviousIntent(),
      AppShortcutAction.volumeUp: const VolumeUpIntent(),
      AppShortcutAction.volumeDown: const VolumeDownIntent(),
      AppShortcutAction.mute: const MuteIntent(),
      AppShortcutAction.seekForward: const SeekForwardIntent(),
      AppShortcutAction.seekBackward: const SeekBackwardIntent(),
      AppShortcutAction.toggleFullScreen: const ToggleFullScreenIntent(),
    };

    final shortcuts = <ShortcutActivator, Intent>{};
    for (final entry in bindings.entries) {
      final activator = settings.shortcutBinding(entry.key).toActivator();
      if (activator == null) {
        continue;
      }
      shortcuts[activator] = entry.value;
    }
    shortcuts[const SingleActivator(LogicalKeyboardKey.escape)] =
        const ExitFullScreenIntent();
    return shortcuts;
  }

  Widget _buildTooltipIcon({
    required String message,
    required IconData icon,
    Color? color,
    double? size,
  }) {
    return AppTooltip(
      message: message,
      child: Icon(icon, color: color, size: size),
    );
  }

  Widget _buildCurrentPage(bool isDesktop, bool useSidebar) {
    final double leftPadding = useSidebar ? 80.0 : 0.0;

    return IndexedStack(
      index: _currentIndex,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 0, left: leftPadding),
          child: FoldersPage(
            key: _foldersPageKey,
            onOpenPlayback: () => _onDestinationSelected(1),
          ),
        ),
        const PlaybackPage(),
        Padding(
          padding: EdgeInsets.only(top: isDesktop ? 32 : 0, left: leftPadding),
          child: LibraryPage(
            initialTabIndex: widget.initialLibraryTabIndex,
            initialAlbums3DView: widget.initialAlbums3DView,
            initialAlbums3DIndex: widget.initialAlbums3DIndex,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: isDesktop ? 32 : 0, left: leftPadding),
          child: const QueuePage(),
        ),
        Padding(
          padding: EdgeInsets.only(top: isDesktop ? 32 : 0, left: leftPadding),
          child: const SharingPage(),
        ),
      ],
    );
  }

  List<NavigationDestination> _buildBottomDestinations(
    BuildContext context,
    bool isPlayback,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return [
      NavigationDestination(
        icon: _buildTooltipIcon(
          message: l10n.file,
          icon: Icons.folder_outlined,
          color: isPlayback ? Colors.white70 : null,
        ),
        selectedIcon: _buildTooltipIcon(
          message: l10n.file,
          icon: Icons.folder,
          color: isPlayback ? Colors.white : null,
        ),
        label: l10n.file,
      ),
      NavigationDestination(
        icon: _buildTooltipIcon(
          message: l10n.play,
          icon: Icons.play_circle_outline,
          color: isPlayback ? Colors.white70 : null,
        ),
        selectedIcon: _buildTooltipIcon(
          message: l10n.play,
          icon: Icons.play_circle,
          color: isPlayback ? Colors.white : null,
        ),
        label: l10n.play,
      ),
      NavigationDestination(
        icon: _buildTooltipIcon(
          message: l10n.list,
          icon: Icons.playlist_play_outlined,
          color: isPlayback ? Colors.white70 : null,
        ),
        selectedIcon: _buildTooltipIcon(
          message: l10n.list,
          icon: Icons.playlist_play,
          color: isPlayback ? Colors.white : null,
        ),
        label: l10n.list,
      ),
      NavigationDestination(
        icon: _buildTooltipIcon(
          message: l10n.queueTab,
          icon: Icons.queue_music_outlined,
          color: isPlayback ? Colors.white70 : null,
        ),
        selectedIcon: _buildTooltipIcon(
          message: l10n.queueTab,
          icon: Icons.queue_music,
          color: isPlayback ? Colors.white : null,
        ),
        label: l10n.queueTab,
      ),
      NavigationDestination(
        icon: _buildTooltipIcon(
          message: l10n.share,
          icon: Icons.share_outlined,
          color: isPlayback ? Colors.white70 : null,
        ),
        selectedIcon: _buildTooltipIcon(
          message: l10n.share,
          icon: Icons.share,
          color: isPlayback ? Colors.white : null,
        ),
        label: l10n.share,
      ),
      NavigationDestination(
        icon: _buildTooltipIcon(
          message: l10n.settings,
          icon: Icons.settings_outlined,
          color: isPlayback ? Colors.white70 : null,
        ),
        selectedIcon: _buildTooltipIcon(
          message: l10n.settings,
          icon: Icons.settings,
          color: isPlayback ? Colors.white : null,
        ),
        label: l10n.settings,
      ),
    ];
  }

  List<NavigationRailDestination> _buildRailDestinations(
    BuildContext context,
    bool isPlayback,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Keep the destination box close to the rail's built-in M3 geometry.
    // A much taller custom box makes the hover/indicator highlight appear
    // vertically offset because NavigationRail positions it from the icon size.
    const iconBoxSize = 32.0;

    Widget railIcon(Widget child) {
      return SizedBox(
        width: iconBoxSize,
        height: iconBoxSize,
        child: Center(child: child),
      );
    }

    const verticalPadding = 10.0;
    return [
      NavigationRailDestination(
        padding: const EdgeInsets.symmetric(vertical: verticalPadding),
        icon: railIcon(
          _buildTooltipIcon(
            message: l10n.file,
            icon: Icons.folder_outlined,
            color: isPlayback ? Colors.white70 : null,
          ),
        ),
        selectedIcon: railIcon(
          _buildTooltipIcon(
            message: l10n.file,
            icon: Icons.folder,
            color: isPlayback ? Colors.white : null,
          ),
        ),
        label: Text(l10n.file),
      ),
      NavigationRailDestination(
        padding: const EdgeInsets.symmetric(vertical: verticalPadding),
        icon: railIcon(
          _buildTooltipIcon(
            message: l10n.play,
            icon: Icons.play_circle_outline,
            color: isPlayback ? Colors.white70 : null,
          ),
        ),
        selectedIcon: railIcon(
          _buildTooltipIcon(
            message: l10n.play,
            icon: Icons.play_circle,
            color: isPlayback ? Colors.white : null,
          ),
        ),
        label: Text(l10n.play),
      ),
      NavigationRailDestination(
        padding: const EdgeInsets.symmetric(vertical: verticalPadding),
        icon: railIcon(
          _buildTooltipIcon(
            message: l10n.list,
            icon: Icons.playlist_play_outlined,
            color: isPlayback ? Colors.white70 : null,
          ),
        ),
        selectedIcon: railIcon(
          _buildTooltipIcon(
            message: l10n.list,
            icon: Icons.playlist_play,
            color: isPlayback ? Colors.white : null,
          ),
        ),
        label: Text(l10n.list),
      ),
      NavigationRailDestination(
        padding: const EdgeInsets.symmetric(vertical: verticalPadding),
        icon: railIcon(
          _buildTooltipIcon(
            message: l10n.queueTab,
            icon: Icons.queue_music_outlined,
            color: isPlayback ? Colors.white70 : null,
          ),
        ),
        selectedIcon: railIcon(
          _buildTooltipIcon(
            message: l10n.queueTab,
            icon: Icons.queue_music,
            color: isPlayback ? Colors.white : null,
          ),
        ),
        label: Text(l10n.queueTab),
      ),
      NavigationRailDestination(
        padding: const EdgeInsets.symmetric(vertical: verticalPadding),
        icon: railIcon(
          _buildTooltipIcon(
            message: l10n.share,
            icon: Icons.share_outlined,
            color: isPlayback ? Colors.white70 : null,
          ),
        ),
        selectedIcon: railIcon(
          _buildTooltipIcon(
            message: l10n.share,
            icon: Icons.share,
            color: isPlayback ? Colors.white : null,
          ),
        ),
        label: Text(l10n.share),
      ),
      NavigationRailDestination(
        padding: const EdgeInsets.symmetric(vertical: verticalPadding),
        icon: railIcon(
          _buildTooltipIcon(
            message: l10n.settings,
            icon: Icons.settings_outlined,
            color: isPlayback ? Colors.white70 : null,
          ),
        ),
        selectedIcon: railIcon(
          _buildTooltipIcon(
            message: l10n.settings,
            icon: Icons.settings,
            color: isPlayback ? Colors.white : null,
          ),
        ),
        label: Text(l10n.settings),
      ),
    ];
  }

  void _completeOnboarding() {
    if (_isOnboardingAnimatingOut) return;
    setState(() {
      _isOnboardingAnimatingOut = true;
      _currentIndex = 0;
    });
    _onboardingAnimController?.forward().then((_) {
      final settings = ref.read(settingsServiceProvider);
      settings.hasShownOnboarding = true;
      if (mounted) {
        setState(() {
          _isOnboardingAnimatingOut = false;
        });
        _onDestinationSelected(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(mainTabIndexProvider, (previous, next) {
      if (next != _currentIndex && mounted) {
        setState(() {
          _currentIndex = next;
        });
      }
    });

    // Listen for small window mode transitions
    ref.listen<
      ({bool isSmallMode, SmallWindowBottomPanelMode bottomPanelMode})
    >(
      settingsServiceProvider.select(
        (s) => (
          isSmallMode: s.isSmallWindowMode,
          bottomPanelMode: s.smallWindowBottomPanelMode,
        ),
      ),
      (previous, next) async {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          final settings = ref.read(settingsServiceProvider);

          final nextSmallMode = next.isSmallMode;
          final prevSmallMode = previous?.isSmallMode ?? false;
          final nextExpanded =
              next.bottomPanelMode != SmallWindowBottomPanelMode.collapsed;
          final prevExpanded =
              previous?.bottomPanelMode != SmallWindowBottomPanelMode.collapsed;

          if (nextSmallMode != prevSmallMode || nextExpanded != prevExpanded) {
            _ignoreResizeEventsUntil = DateTime.now().add(
              const Duration(milliseconds: 800),
            );
          }

          debugPrint(
            '[vynody] transition listener: prevSmall=$prevSmallMode, nextSmall=$nextSmallMode, prevExpanded=$prevExpanded, nextExpanded=$nextExpanded',
          );
          if (nextSmallMode) {
            // Enter small window mode or update small window dimensions
            final isFullScreen = await windowManager.isFullScreen();
            final isMaximized = await windowManager.isMaximized();

            if (isFullScreen) {
              await windowManager.setFullScreen(false);
            }
            if (isMaximized) {
              await windowManager.unmaximize();
            }
            await windowManager.setAlwaysOnTop(
              settings.isSmallWindowAlwaysOnTop,
            );

            // Only save regular size if transitioning from regular mode to small window mode
            // AND only if the window was in a normal state (not maximized and not fullscreen)
            if (!prevSmallMode && !isFullScreen && !isMaximized) {
              final currentSize = await windowManager.getSize();
              debugPrint(
                '[vynody] transitioning from regular to small. currentSize=$currentSize',
              );
              if (currentSize.width >=
                      PlaybackPageUiTuning.smallWindowMaxSize.width ||
                  currentSize.height >=
                      PlaybackPageUiTuning.smallWindowMaxSize.height) {
                settings.savedRegularWindowSize = currentSize;
                debugPrint(
                  '[vynody] savedRegularWindowSize set to $currentSize',
                );
              }
            }

            if (nextExpanded) {
              // Expanded small-window bottom panel mode: resizable within constraints
              const minSize = Size(360.0, 450.0);
              const maxSize = Size(480.0, 99999.0);

              await windowManager.setMinimumSize(minSize);
              await windowManager.setMaximumSize(maxSize);

              // Only change size if we weren't already in expanded mode or small mode
              if (!prevExpanded || !prevSmallMode) {
                final savedSize = settings.savedSmallWindowQueueSize;
                final clampedSize = Size(
                  savedSize.width.clamp(minSize.width, maxSize.width),
                  savedSize.height.clamp(minSize.height, maxSize.height),
                );
                debugPrint(
                  '[vynody] setting size for expanded small mode: clampedSize=$clampedSize (savedSize=$savedSize)',
                );
                await windowManager.setSize(clampedSize);
              }
            } else {
              // Collapsed mode: resizable between 360x360 and 600x600
              const minSize = Size(360.0, 360.0);
              const maxSize = Size(600.0, 600.0);

              await windowManager.setMinimumSize(minSize);
              await windowManager.setMaximumSize(maxSize);

              // Only change size if transitioning from expanded mode back to collapsed, or entering small window mode
              if (prevExpanded || !prevSmallMode) {
                final savedSize = settings.savedSmallWindowSize;
                final clampedSize = Size(
                  savedSize.width.clamp(minSize.width, maxSize.width),
                  savedSize.height.clamp(minSize.height, maxSize.height),
                );
                debugPrint(
                  '[vynody] setting size for collapsed small mode: clampedSize=$clampedSize (savedSize=$savedSize)',
                );
                await windowManager.setSize(clampedSize);
              }
            }
          } else if (prevSmallMode && !nextSmallMode) {
            // Exit small window mode
            // Save the last small window size right before we exit
            final currentSmallSize = await windowManager.getSize();
            debugPrint(
              '[vynody] exiting small window mode. currentSmallSize=$currentSmallSize',
            );
            if (previous?.bottomPanelMode !=
                SmallWindowBottomPanelMode.collapsed) {
              settings.savedSmallWindowQueueSize = currentSmallSize;
              debugPrint(
                '[vynody] exiting: savedSmallWindowQueueSize saved as $currentSmallSize',
              );
            } else {
              settings.savedSmallWindowSize = currentSmallSize;
              debugPrint(
                '[vynody] exiting: savedSmallWindowSize saved as $currentSmallSize',
              );
            }

            await windowManager.setMinimumSize(const Size(400, 650));
            await windowManager.setMaximumSize(const Size(99999, 99999));
            final savedSize = settings.savedRegularWindowSize;
            debugPrint(
              '[vynody] restoring regular window size: savedSize=$savedSize',
            );
            await windowManager.setSize(savedSize);
            await windowManager.setAlwaysOnTop(false);
          }
        }
      },
    );

    // Listen for incoming LAN file transfers
    ref.listen<IncomingTransferRequest?>(incomingRequestProvider, (
      previous,
      next,
    ) {
      if (next != null) {
        showIncomingTransferDialog(context, next);
      }
    });

    // Listen for incoming LAN lyrics requests
    ref.listen<IncomingLyricsRequest?>(incomingLyricsRequestProvider, (
      previous,
      next,
    ) {
      if (next != null) {
        showIncomingLyricsDialog(context, next);
      }
    });

    // Listen for incoming remote control pair requests
    ref.listen<IncomingRemotePairRequest?>(incomingRemotePairProvider, (
      previous,
      next,
    ) {
      if (next != null) {
        showIncomingRemotePairDialog(context, next);
      }
    });


    // Listen for sharing warnings
    ref.listen<String?>(sharingWarningProvider, (previous, next) {
      if (next != null) {
        AppSnackBar.show(
          context,
          ref,
          SnackBar(
            content: Text(next),
            action: SnackBarAction(
              label: '去设置',
              onPressed: () {
                _onDestinationSelected(4);
              },
            ),
          ),
        );
        ref.read(sharingWarningProvider.notifier).setWarning(null);
      }
    });

    // Listen for transfer session completions to show SnackBar notifications
    ref.listen<List<TransferSession>>(activeTransfersProvider, (
      previous,
      next,
    ) {
      if (previous == null) return;

      for (final session in next) {
        // We only care about receiving files
        if (session.isSending) continue;

        // Check the previous state of this session
        final prevList = previous.where((s) => s.id == session.id).toList();
        final prevSession = prevList.isNotEmpty ? prevList.first : null;

        // If it was already finished in the previous state, don't show the SnackBar again
        final wasFinished =
            prevSession != null &&
            (prevSession.status == TransferStatus.success ||
                prevSession.status == TransferStatus.failed ||
                prevSession.status == TransferStatus.cancelled);

        if (wasFinished) continue;

        // Check if the session has transitioned to a finished state
        final isFinished =
            session.status == TransferStatus.success ||
            session.status == TransferStatus.failed ||
            session.status == TransferStatus.cancelled;

        if (isFinished) {
          final isSuccess = session.status == TransferStatus.success;
          final text = isSuccess
              ? '成功接收了 ${session.completedFilesCount ?? session.filesCount ?? 1} 首歌曲'
              : '接收 "${session.fileName}" 失败';

          AppSnackBar.show(context, ref, SnackBar(content: Text(text)));
        }
      }
    });

    final uiState = ref.watch(mainLayoutUiControllerProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final selectionScope = ref.watch(librarySelectionScopeProvider);
    final hideMiniPlayerForSelection =
        selectionScope == LibrarySelectionScope.folder ||
        selectionScope == LibrarySelectionScope.folderRoot ||
        selectionScope == LibrarySelectionScope.library ||
        selectionScope == LibrarySelectionScope.playlist ||
        selectionScope == LibrarySelectionScope.artist ||
        selectionScope == LibrarySelectionScope.album ||
        selectionScope == LibrarySelectionScope.queue;
    final isRootSelectionMode =
        selectionScope == LibrarySelectionScope.folderRoot;
    final isPlaylistSelectionMode =
        selectionScope == LibrarySelectionScope.playlist;
    final isQueueSelectionMode = selectionScope == LibrarySelectionScope.queue;
    ref.listen<double>(audioVolumeProvider, (previous, next) {
      if (!mounted) return;
      final volumeChanged =
          _lastVolume != null && (_lastVolume! - next).abs() > 0.1;
      if (volumeChanged &&
          _audioService.shouldShowVolumeHudForLastVolumeChange) {
        _ui.setVolumeHudVisible(true);
      }
      _lastVolume = next;
    });

    ref.listen<bool>(isProUnlockedProvider, (previous, isUnlocked) {
      final serverState = ref.read(sharingServerStateProvider);
      final lanEnabled = ref.read(settingsServiceProvider).lanSharingEnabled;
      if (!isUnlocked) {
        if (serverState.isRunning) {
          ref.read(sharingServerStateProvider.notifier).stop();
        }
      } else if (lanEnabled && !serverState.isRunning) {
        ref.read(sharingServerStateProvider.notifier).start();
      }
    });

    final settings = ref.watch(settingsServiceProvider);
    final theme = Theme.of(context);
    final bool isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final bool isPlayback = _currentIndex == 1;
    final navBgBaseColor =
        theme.navigationBarTheme.backgroundColor ?? theme.colorScheme.surface;
    final navIndicatorBaseColor =
        theme.navigationBarTheme.indicatorColor ??
        theme.colorScheme.secondaryContainer;
    final navBgOpacityTarget = isPlayback ? 0.0 : 1.0;

    final Size size = MediaQuery.of(context).size;
    final bool isSmallWin = PlaybackPageUiTuning.isSmallWindow(
      size,
      isWaveformEnabled: ref.watch(isEffectiveWaveformEnabledProvider),
      isSmallWindowMode: settings.isSmallWindowMode,
    );
    final bool isLandscape =
        !isSmallWin &&
        (MediaQuery.of(context).orientation == Orientation.landscape);
    final bool useSidebar = isLandscape;
    final bool hideImmersiveTabBar =
        isDesktop &&
        isPlayback &&
        settings.isImmersiveTabBarEnabled &&
        !uiState.showImmersiveTabBar;
    final bool hideBottomBar = isPlayback && isSmallWin;
    final bool useOverlayBottomNav =
        !useSidebar &&
        isPlayback &&
        settings.isImmersiveTabBarEnabled &&
        !hideBottomBar;

    final double railWidth = (useSidebar && !hideImmersiveTabBar) ? 80.0 : 0.0;

    _shortcutManager.shortcuts = _buildShortcutMap(settings);

    final mainAppWidget = Shortcuts.manager(
      manager: _shortcutManager,
      child: Actions(
        actions: <Type, Action<Intent>>{
          PlayPauseIntent: CallbackAction<PlayPauseIntent>(
            onInvoke: (_) => _audioService.togglePlay(),
          ),
          NextIntent: CallbackAction<NextIntent>(
            onInvoke: (_) => _audioService.next(),
          ),
          PreviousIntent: CallbackAction<PreviousIntent>(
            onInvoke: (_) => _audioService.previous(),
          ),
          VolumeUpIntent: CallbackAction<VolumeUpIntent>(
            onInvoke: (_) {
              _ui.setVolumeHudVisible(true);
              _audioService.setVolume(
                (_audioService.volume + 5).roundToDouble(),
              );
              return null;
            },
          ),
          VolumeDownIntent: CallbackAction<VolumeDownIntent>(
            onInvoke: (_) {
              _ui.setVolumeHudVisible(true);
              _audioService.setVolume(
                (_audioService.volume - 5).roundToDouble(),
              );
              return null;
            },
          ),
          MuteIntent: CallbackAction<MuteIntent>(
            onInvoke: (_) {
              _audioService.toggleMute();
              return null;
            },
          ),
          SeekForwardIntent: CallbackAction<SeekForwardIntent>(
            onInvoke: (_) =>
                _audioService.seekRelative(const Duration(seconds: 5)),
          ),
          SeekBackwardIntent: CallbackAction<SeekBackwardIntent>(
            onInvoke: (_) =>
                _audioService.seekRelative(const Duration(seconds: -5)),
          ),
          ToggleFullScreenIntent: CallbackAction<ToggleFullScreenIntent>(
            onInvoke: (_) async {
              final isFullScreen = await windowManager.isFullScreen();
              await _setFullScreen(!isFullScreen);
              return null;
            },
          ),
          ExitFullScreenIntent: ExitFullScreenAction(this),
        },
        child: Focus(
          autofocus: true,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _handleBackPressed();
            },
            child: GlobalDropTarget(
              enable:
                  _currentIndex != 3 &&
                  !(_currentIndex == 1 &&
                      isSmallWin &&
                      settings.smallWindowBottomPanelMode !=
                          SmallWindowBottomPanelMode.collapsed),
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _handleDesktopPointerActivity,
                onPointerMove: _handleDesktopPointerActivity,
                onPointerHover: _handleDesktopPointerActivity,
                child: Scaffold(
                  extendBody: true,
                  body: Stack(
                    children: [
                      Positioned.fill(
                        child: _buildCurrentPage(isDesktop, useSidebar),
                      ),
                      if (useSidebar)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: hideImmersiveTabBar ? 0.0 : 80.0,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              child: SizedBox(
                                width: 80,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: hideImmersiveTabBar ? 0.0 : 1.0,
                                  child: TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 120),
                                    curve: Curves.easeOut,
                                    tween: Tween<double>(
                                      begin: navBgOpacityTarget,
                                      end: navBgOpacityTarget,
                                    ),
                                    builder: (context, animatedOpacity, child) {
                                      return NavigationRail(
                                        leading: isDesktop
                                            ? const SizedBox(height: 32)
                                            : null,
                                        backgroundColor: Color.lerp(
                                          navBgBaseColor.withValues(alpha: 0.0),
                                          navBgBaseColor,
                                          animatedOpacity,
                                        ),
                                        selectedIndex: _currentIndex,
                                        onDestinationSelected:
                                            _onDestinationSelected,
                                        labelType: NavigationRailLabelType.none,
                                        indicatorColor: Color.lerp(
                                          navIndicatorBaseColor.withValues(alpha: 0.0),
                                          navIndicatorBaseColor,
                                          animatedOpacity,
                                        ),
                                        destinations: _buildRailDestinations(
                                          context,
                                          isPlayback,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (showCustomTitleBar)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: DesktopWindowTitleBar(
                            brightness: isPlayback
                                ? Brightness.dark
                                : theme.brightness,
                            showSmallWindowButton: isPlayback,
                            showButtonGroupBackground: isPlayback,
                            hideButtonsWhenInactive: isPlayback,
                          ),
                        ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        bottom:
                            (!isPlayback &&
                                currentMusic != null &&
                                !hideMiniPlayerForSelection)
                            ? ((useSidebar ? 20 : 80) +
                                  MediaQuery.of(context).padding.bottom +
                                  uiState.snackBarOffset +
                                  (((isRootSelectionMode &&
                                              _currentIndex == 0) ||
                                          (isPlaylistSelectionMode &&
                                              _currentIndex == 2) ||
                                          (isQueueSelectionMode &&
                                              _currentIndex == 3))
                                      ? 80.0
                                      : 0.0))
                            : -120.0,
                        left: railWidth,
                        right: 0,
                        child: Center(
                          child: !isPlayback && currentMusic != null
                              ? Builder(
                                  builder: (context) {
                                    final audio = ref.read(
                                      audioServiceProvider,
                                    );
                                    final isLandscape =
                                        MediaQuery.of(context).orientation ==
                                        Orientation.landscape;
                                    final availableWidth =
                                        MediaQuery.of(context).size.width -
                                        railWidth;

                                    return Container(
                                      key: const ValueKey('dynamic-island'),
                                      constraints: BoxConstraints(
                                        maxWidth: availableWidth * 0.9,
                                      ),
                                      child: PlaybackHeroCard(
                                        isMini: true,
                                        isLandscape: isLandscape,
                                        showMiniVolumeSlider:
                                            _showMiniVolumeSlider,
                                        onMiniTap: () =>
                                            _onDestinationSelected(1),
                                        onPrevious: audio.previous,
                                        onPlayPause: audio.togglePlay,
                                        onNext: audio.next,
                                        onScrubbing: (val) {
                                          // 迷你播放器内部会处理局部 UI 状态
                                        },
                                        onSeek: (val) {
                                          audio.seek(
                                            Duration(
                                              milliseconds:
                                                  (audio
                                                              .duration
                                                              .inMilliseconds *
                                                          val)
                                                      .toInt(),
                                            ),
                                          );
                                        },
                                        onVolumeTap: () {
                                          ref
                                              .read(settingsServiceProvider)
                                              .resetInactivity();
                                          final nextVisible =
                                              !_showMiniVolumeSlider;
                                          setState(() {
                                            _showMiniVolumeSlider = nextVisible;
                                          });
                                        },
                                        onMiniMouseExit: () {
                                          if (!_showMiniVolumeSlider) return;
                                          setState(() {
                                            _showMiniVolumeSlider = false;
                                          });
                                        },
                                        onVolumeChanged: (value) {
                                          ref
                                              .read(settingsServiceProvider)
                                              .resetInactivity();
                                          _ui.setVolumeHudVisible(true);
                                          audio.setVolume(
                                            value.roundToDouble(),
                                          );
                                        },
                                        onVolumeScroll: (deltaY) {
                                          ref
                                              .read(settingsServiceProvider)
                                              .resetInactivity();
                                          _ui.setVolumeHudVisible(true);
                                          audio.setVolume(
                                            (audio.volume - deltaY * 0.1)
                                                .clamp(0.0, 100.0)
                                                .roundToDouble(),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('empty-island'),
                                ),
                        ),
                      ),
                      if (uiState.showVolumeHud)
                        VolumeHUD(
                          volume: ref.watch(audioVolumeProvider),
                          isMuted: ref.watch(audioIsMutedProvider),
                        ),
                      if (useOverlayBottomNav)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _buildBottomNavigationBar(
                            context,
                            isPlayback: isPlayback,
                            navBgBaseColor: navBgBaseColor,
                            navIndicatorBaseColor: navIndicatorBaseColor,
                            navBgOpacityTarget: navBgOpacityTarget,
                            isHidden:
                                settings.isImmersiveTabBarEnabled &&
                                settings.isUserInactive,
                            includeBottomPadding: true,
                          ),
                        ),
                    ],
                  ),
                  bottomNavigationBar:
                      hideBottomBar || useSidebar || useOverlayBottomNav
                      ? null
                      : _buildBottomNavigationBar(
                          context,
                          isPlayback: isPlayback,
                          navBgBaseColor: navBgBaseColor,
                          navIndicatorBaseColor: navIndicatorBaseColor,
                          navBgOpacityTarget: navBgOpacityTarget,
                          isHidden:
                              isPlayback &&
                              settings.isImmersiveTabBarEnabled &&
                              settings.isUserInactive,
                          includeBottomPadding: false,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final showOnboarding =
        !settings.hasShownOnboarding || _isOnboardingAnimatingOut;

    if (showOnboarding) {
      _onboardingAnimController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      if (!_isOnboardingAnimatingOut &&
          _onboardingAnimController!.value != 0.0) {
        _onboardingAnimController!.value = 0.0;
      }

      final onboardingOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _onboardingAnimController!,
          curve: Curves.easeOutCubic,
        ),
      );

      final onboardingOffset =
          Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-1.0, 0.0), // Slide left off screen
          ).animate(
            CurvedAnimation(
              parent: _onboardingAnimController!,
              curve: Curves.easeOutCubic,
            ),
          );

      return Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Focus(canRequestFocus: false, child: mainAppWidget),
            ),
          ),
          Positioned.fill(
            child: FadeTransition(
              opacity: onboardingOpacity,
              child: SlideTransition(
                position: onboardingOffset,
                child: Scaffold(
                  body: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: _isOnboardingAnimatingOut,
                          child: OnboardingScreen(
                            onComplete: _completeOnboarding,
                          ),
                        ),
                      ),
                      if (showCustomTitleBar)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            ignoring: _isOnboardingAnimatingOut,
                            child: DesktopWindowTitleBar(
                              brightness: theme.brightness,
                              showSmallWindowButton: false,
                              showButtonGroupBackground: isPlayback,
                              hideButtonsWhenInactive: isPlayback,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return mainAppWidget;
  }

  Widget _buildBottomNavigationBar(
    BuildContext context, {
    required bool isPlayback,
    required Color navBgBaseColor,
    required Color navIndicatorBaseColor,
    required double navBgOpacityTarget,
    required bool isHidden,
    required bool includeBottomPadding,
  }) {
    final bottomPadding = includeBottomPadding
        ? MediaQuery.of(context).padding.bottom
        : 0.0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isHidden ? 0.0 : 1.0,
      child: IgnorePointer(
        ignoring: isHidden,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          tween: Tween<double>(
            begin: navBgOpacityTarget,
            end: navBgOpacityTarget,
          ),
          builder: (context, animatedOpacity, child) {
            return NavigationBar(
              height: 60 + bottomPadding,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              selectedIndex: _currentIndex,
              backgroundColor: Color.lerp(
                navBgBaseColor.withValues(alpha: 0.0),
                navBgBaseColor,
                animatedOpacity,
              ),
              elevation: 0,
              indicatorColor: Color.lerp(
                navIndicatorBaseColor.withValues(alpha: 0.0),
                navIndicatorBaseColor,
                animatedOpacity,
              ),
              onDestinationSelected: _onDestinationSelected,
              destinations: _buildBottomDestinations(context, isPlayback),
            );
          },
        ),
      ),
    );
  }
}

class AppShortcutManager extends ShortcutManager {
  @override
  KeyEventResult handleKeypress(BuildContext context, KeyEvent event) {
    if (_isTextInputFocused()) {
      return KeyEventResult.ignored;
    }
    return super.handleKeypress(context, event);
  }

  bool _isTextInputFocused() {
    final focusNode = FocusManager.instance.primaryFocus;
    if (focusNode == null) return false;

    final context = focusNode.context;
    if (context == null) return false;

    final widget = context.widget;
    if (widget is EditableText ||
        widget is TextField ||
        widget is TextFormField) {
      return true;
    }
    return context.findAncestorWidgetOfExactType<EditableText>() != null ||
        context.findAncestorWidgetOfExactType<TextField>() != null ||
        context.findAncestorWidgetOfExactType<TextFormField>() != null;
  }
}
