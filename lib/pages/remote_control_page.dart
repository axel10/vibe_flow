import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/sharing/lan_device.dart';
import 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
import 'package:vynody/player/sharing/remote_control/remote_playback_model.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/player/sharing/sharing_service.dart';
import 'package:vynody/widgets/desktop_window_title_bar.dart';
import 'package:vynody/widgets/playing_equalizer_icon.dart';

class RemoteControlPage extends ConsumerStatefulWidget {
  final LanDevice device;

  const RemoteControlPage({
    super.key,
    required this.device,
  });

  @override
  ConsumerState<RemoteControlPage> createState() => _RemoteControlPageState();
}

class _RemoteControlPageState extends ConsumerState<RemoteControlPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _queueScrollController = ScrollController();
  final Set<int> _selectedIndices = {};
  bool get _isSelectionMode => _selectedIndices.isNotEmpty;
  double? _draggingSliderValue;
  double? _draggingVolumeValue;
  Timer? _volumeThrottleTimer;
  Timer? _progressTimer;
  DateTime _lastVolumeSent = DateTime.fromMillisecondsSinceEpoch(0);

  void _toggleSelectAll(int totalCount) {
    setState(() {
      if (_selectedIndices.length == totalCount) {
        _selectedIndices.clear();
      } else {
        _selectedIndices.clear();
        _selectedIndices.addAll(List.generate(totalCount, (i) => i));
      }
    });
  }

  void _deleteSelected(RemoteControlService remoteService) {
    if (_selectedIndices.isEmpty) return;
    final sorted = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    for (final idx in sorted) {
      remoteService.removeFromQueue(idx);
    }
    setState(() => _selectedIndices.clear());
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      final state = ref.read(remotePlaybackStateProvider);
      if (state != null && state.isPlaying && _draggingSliderValue == null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _tabController.dispose();
    _queueScrollController.dispose();
    _volumeThrottleTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds <= 0) return '0:00';
    final dur = Duration(milliseconds: milliseconds);
    final minutes = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (dur.inHours > 0) {
      return '${dur.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  IconData _getModeIcon(AppPlaybackMode mode) {
    switch (mode) {
      case AppPlaybackMode.single:
        return Icons.repeat_one_rounded;
      case AppPlaybackMode.singleLoop:
        return Icons.repeat_one_on_rounded;
      case AppPlaybackMode.queue:
        return Icons.format_list_numbered_rounded;
      case AppPlaybackMode.queueLoop:
      case AppPlaybackMode.autoQueueLoop:
        return Icons.repeat_rounded;
    }
  }

  String _getModeTooltip(AppPlaybackMode mode, AppLocalizations l10n) {
    switch (mode) {
      case AppPlaybackMode.single:
        return l10n.playlistModeSingle;
      case AppPlaybackMode.singleLoop:
        return l10n.playlistModeSingleLoop;
      case AppPlaybackMode.queue:
        return l10n.playlistModeQueue;
      case AppPlaybackMode.queueLoop:
      case AppPlaybackMode.autoQueueLoop:
        return l10n.playlistModeQueueLoop;
    }
  }

  AppPlaybackMode _getNextMode(AppPlaybackMode mode) {
    switch (mode) {
      case AppPlaybackMode.queueLoop:
        return AppPlaybackMode.singleLoop;
      case AppPlaybackMode.singleLoop:
        return AppPlaybackMode.queue;
      case AppPlaybackMode.queue:
        return AppPlaybackMode.single;
      case AppPlaybackMode.single:
      case AppPlaybackMode.autoQueueLoop:
        return AppPlaybackMode.queueLoop;
    }
  }

  void _scrollToCurrentTrack(int currentIndex) {
    if (!_queueScrollController.hasClients || currentIndex < 0) return;
    const itemHeight = 68.0;
    final targetOffset = (currentIndex * itemHeight) - 100.0;
    _queueScrollController.animateTo(
      targetOffset.clamp(0.0, _queueScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _confirmClearQueue(
    BuildContext context,
    RemoteControlService remoteService,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearQueue),
        content: Text(l10n.confirmClearQueue),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      remoteService.clearQueue();
    }
  }

  void _onVolumeChanged(double val, RemoteControlService remoteService) {
    setState(() => _draggingVolumeValue = val);
    final now = DateTime.now();
    if (now.difference(_lastVolumeSent).inMilliseconds >= 50) {
      _lastVolumeSent = now;
      _volumeThrottleTimer?.cancel();
      _volumeThrottleTimer = null;
      remoteService.setVolume(val);
    } else {
      _volumeThrottleTimer?.cancel();
      _volumeThrottleTimer = Timer(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        _lastVolumeSent = DateTime.now();
        remoteService.setVolume(val);
      });
    }
  }

  void _onVolumeChangeEnd(double val, RemoteControlService remoteService) {
    _volumeThrottleTimer?.cancel();
    _volumeThrottleTimer = null;
    remoteService.setVolume(val);
    setState(() => _draggingVolumeValue = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final remoteService = ref.watch(remoteControlServiceProvider);
    final remoteState = ref.watch(remotePlaybackStateProvider);
    final activeDevice = ref.watch(activeControllingDeviceProvider);

    final isConnected = activeDevice != null;
    final state = remoteState ?? RemotePlaybackState();

    final currentPositionMs = state.estimatedPositionMs;
    final totalDurationMs = state.durationMs > 0 ? state.durationMs : 1;
    final sliderMax = totalDurationMs.toDouble();
    final sliderValue = (_draggingSliderValue ?? currentPositionMs.toDouble())
        .clamp(0.0, sliderMax);

    final volumeValue = (_draggingVolumeValue ?? state.volume).clamp(0.0, 100.0);

    final authToken = remoteService.clientAuthToken ??
        remoteService.getTrustedTokenForDevice(widget.device.id) ??
        '';
    final hasTrack = state.title.isNotEmpty;
    final coverUrl = hasTrack
        ? 'https://${formatHostForUrl(widget.device.ip)}:${widget.device.httpPort}/api/remote/cover?t=${Uri.encodeComponent(state.title)}_${Uri.encodeComponent(state.artist)}${authToken.isNotEmpty ? '&token=${Uri.encodeComponent(authToken)}' : ''}'
        : '';

    final showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSelectionMode) {
          setState(() => _selectedIndices.clear());
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.brightness == Brightness.dark
                  ? [
                      theme.colorScheme.surface,
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                    ]
                  : [
                      theme.colorScheme.surface,
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                      theme.colorScheme.surfaceContainerLowest,
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (showCustomTitleBar)
                  DesktopWindowTitleBar(
                    brightness: theme.brightness,
                  ),
                // Top Navigation & Device Bar
                _buildTopBar(
                  context,
                  theme,
                  l10n,
                  remoteService,
                  isConnected,
                  state.hostDeviceName ?? widget.device.name,
                ),

              // Main Content: Split view on wide screen, TabView on narrow screen
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideScreen = constraints.maxWidth >= 800;

                    if (isWideScreen) {
                      return Row(
                        children: [
                          // Left Panel: Now Playing Player
                          Expanded(
                            flex: 5,
                            child: LayoutBuilder(
                              builder: (context, leftConstraints) {
                                return SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: leftConstraints.maxHeight,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0,
                                          vertical: 20.0,
                                        ),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 480),
                                          child: _buildPlayerCard(
                                            context,
                                            theme,
                                            l10n,
                                            remoteService,
                                            state,
                                            coverUrl,
                                            sliderValue,
                                            sliderMax,
                                            volumeValue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                          ),
                          // Right Panel: Queue
                          Expanded(
                            flex: 6,
                            child: _buildQueueView(
                              context,
                              theme,
                              l10n,
                              remoteService,
                              state,
                            ),
                          ),
                        ],
                      );
                    }

                    // Mobile / Narrow layout: Tab view
                    return Column(
                      children: [
                        // Segmented Tab Selector
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelColor: theme.colorScheme.onPrimaryContainer,
                              unselectedLabelColor:
                                  theme.colorScheme.onSurfaceVariant,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              tabs: [
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.music_note_rounded, size: 16),
                                      const SizedBox(width: 6),
                                      Text(l10n.play),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.queue_music_rounded, size: 16),
                                      const SizedBox(width: 6),
                                      Text('${l10n.queueTab} (${state.queue.length})'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Tab 1: Player View
                              LayoutBuilder(
                                builder: (context, tabConstraints) {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: tabConstraints.maxHeight,
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 480),
                                            child: _buildPlayerCard(
                                              context,
                                              theme,
                                              l10n,
                                              remoteService,
                                              state,
                                              coverUrl,
                                              sliderValue,
                                              sliderMax,
                                              volumeValue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Tab 2: Queue View
                              _buildQueueView(
                                context,
                                theme,
                                l10n,
                                remoteService,
                                state,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTopBar(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    RemoteControlService remoteService,
    bool isConnected,
    String deviceName,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              if (_isSelectionMode) {
                setState(() => _selectedIndices.clear());
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings_remote_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: isConnected
                            ? [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isConnected ? l10n.remoteConnected : l10n.remoteConnecting,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.link_off_rounded, size: 20),
            tooltip: l10n.remoteDisconnect,
            onPressed: () {
              remoteService.disconnectClient();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    RemoteControlService remoteService,
    RemotePlaybackState state,
    String coverUrl,
    double sliderValue,
    double sliderMax,
    double volumeValue,
  ) {
    final hasTrack = state.title.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Album Artwork
        Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                if (state.isPlaying)
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 36,
                    spreadRadius: 2,
                    offset: const Offset(0, 12),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: hasTrack
                  ? Image.network(
                      coverUrl,
                      width: 220,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.music_note_rounded,
                          size: 72,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 72,
                        color: theme.colorScheme.primary,
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Song Title & Artist & Favorite
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 48), // Balances the favorite button
            Expanded(
              child: Column(
                children: [
                  Text(
                    state.title.isNotEmpty ? state.title : l10n.noMusicPlaying,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.artist.isNotEmpty
                        ? state.artist
                        : (state.title.isNotEmpty ? l10n.unknownArtist : '--'),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (state.album.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      state.album,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              iconSize: 26,
              icon: Icon(
                state.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: state.isFavorite
                    ? Colors.redAccent
                    : theme.colorScheme.onSurfaceVariant,
              ),
              tooltip: state.isFavorite
                  ? l10n.removeFromFavorites
                  : l10n.addToFavorites,
              onPressed: hasTrack ? remoteService.toggleFavorite : null,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Progress Bar & Duration
        Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 7,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16,
                ),
              ),
              child: Slider(
                value: sliderValue,
                min: 0.0,
                max: sliderMax,
                onChanged: (val) {
                  setState(() => _draggingSliderValue = val);
                },
                onChangeEnd: (val) {
                  setState(() => _draggingSliderValue = null);
                  remoteService.seek(Duration(milliseconds: val.toInt()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(sliderValue.toInt()),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatDuration(state.durationMs),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 5-Button Primary Playback Controls Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Playback Mode Button
            IconButton(
              iconSize: 24,
              icon: Icon(_getModeIcon(state.playbackMode)),
              tooltip: _getModeTooltip(state.playbackMode, l10n),
              color: theme.colorScheme.onSurfaceVariant,
              onPressed: () {
                final next = _getNextMode(state.playbackMode);
                remoteService.setPlaybackMode(next);
              },
            ),

            // Previous Button
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.skip_previous_rounded),
              tooltip: l10n.previousSong,
              onPressed: remoteService.previous,
            ),

            // Play / Pause Large Button
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: IconButton(
                iconSize: 46,
                color: theme.colorScheme.onPrimary,
                icon: Icon(
                  state.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
                tooltip: state.isPlaying ? l10n.pause : l10n.play,
                onPressed: remoteService.togglePlayPause,
              ),
            ),

            // Next Button
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.skip_next_rounded),
              tooltip: l10n.nextSong,
              onPressed: remoteService.next,
            ),

            // Random / Shuffle Mode Button
            IconButton(
              iconSize: 24,
              icon: Icon(
                state.isRandomMode
                    ? Icons.shuffle_on_rounded
                    : Icons.shuffle_rounded,
                color: state.isRandomMode
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              tooltip: l10n.shufflePlayback,
              onPressed: remoteService.toggleRandomMode,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Volume Control Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  volumeValue == 0
                      ? Icons.volume_off_rounded
                      : (volumeValue < 50
                          ? Icons.volume_down_rounded
                          : Icons.volume_up_rounded),
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  if (volumeValue > 0) {
                    remoteService.setVolume(0);
                  } else {
                    remoteService.setVolume(80);
                  }
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: volumeValue,
                    min: 0.0,
                    max: 100.0,
                    onChanged: (val) => _onVolumeChanged(val, remoteService),
                    onChangeEnd: (val) => _onVolumeChangeEnd(val, remoteService),
                  ),
                ),
              ),
              SizedBox(
                width: 38,
                child: Text(
                  '${volumeValue.toInt()}%',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQueueView(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    RemoteControlService remoteService,
    RemotePlaybackState state,
  ) {
    final queue = state.queue;
    final currentIndex = state.currentIndex;

    if (_selectedIndices.isNotEmpty) {
      _selectedIndices.removeWhere((idx) => idx >= queue.length);
    }

    return Column(
      children: [
        // Queue Header Bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
          color: _isSelectionMode
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
              : Colors.transparent,
          child: _isSelectionMode
              ? Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: l10n.cancel,
                      onPressed: () => setState(() => _selectedIndices.clear()),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.selectedSongs(_selectedIndices.length),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _selectedIndices.length == queue.length
                            ? Icons.deselect_rounded
                            : Icons.select_all_rounded,
                        size: 20,
                      ),
                      tooltip: _selectedIndices.length == queue.length
                          ? l10n.deselectAll
                          : l10n.selectAll,
                      onPressed: () => _toggleSelectAll(queue.length),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: l10n.delete,
                      onPressed: () => _deleteSelected(remoteService),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.queue} (${queue.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (queue.isNotEmpty) ...[
                      IconButton(
                        icon: const Icon(Icons.my_location_rounded, size: 18),
                        tooltip: l10n.locateCurrentSong,
                        onPressed: () => _scrollToCurrentTrack(currentIndex),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear_all_rounded, size: 20),
                        tooltip: l10n.clearQueue,
                        onPressed: () => _confirmClearQueue(context, remoteService, l10n),
                      ),
                    ],
                  ],
                ),
        ),
        const Divider(height: 1, thickness: 0.5),

        // Queue List / Empty View
        Expanded(
          child: queue.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.queue_music_rounded,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.queueEmpty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  scrollController: _queueScrollController,
                  buildDefaultDragHandles: false,
                  itemCount: queue.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onReorder: _isSelectionMode
                      ? (_, _) {}
                      : (oldIndex, newIndex) {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          remoteService.reorderQueue(oldIndex, newIndex);
                        },
                  itemBuilder: (context, index) {
                    final item = queue[index];
                    final isCurrent = index == currentIndex;
                    final isSelected = _selectedIndices.contains(index);

                    return _RemoteQueueListTile(
                      key: ValueKey('remote_queue_${item.id}_$index'),
                      index: index,
                      item: item,
                      isCurrent: isCurrent,
                      isPlaying: state.isPlaying,
                      isSelectionMode: _isSelectionMode,
                      isSelected: isSelected,
                      onTap: () {
                        if (_isSelectionMode) {
                          setState(() {
                            if (_selectedIndices.contains(index)) {
                              _selectedIndices.remove(index);
                            } else {
                              _selectedIndices.add(index);
                            }
                          });
                        } else {
                          remoteService.playQueueIndex(index);
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          if (_selectedIndices.contains(index)) {
                            _selectedIndices.remove(index);
                          } else {
                            _selectedIndices.add(index);
                          }
                        });
                      },
                      onRemove: () => remoteService.removeFromQueue(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RemoteQueueListTile extends StatefulWidget {
  final int index;
  final RemoteQueueItem item;
  final bool isCurrent;
  final bool isPlaying;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRemove;

  const _RemoteQueueListTile({
    super.key,
    required this.index,
    required this.item,
    required this.isCurrent,
    required this.isPlaying,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onRemove,
  });

  @override
  State<_RemoteQueueListTile> createState() => _RemoteQueueListTileState();
}

class _RemoteQueueListTileState extends State<_RemoteQueueListTile> {
  bool _isHovered = false;

  String _formatDuration(int ms) {
    if (ms <= 0) return '0:00';
    final dur = Duration(milliseconds: ms);
    final minutes = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (dur.inHours > 0) {
      return '${dur.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : (widget.isCurrent
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                  : (_isHovered
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                      : Colors.transparent)),
          borderRadius: BorderRadius.circular(12),
          border: widget.isSelected
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                )
              : (widget.isCurrent
                  ? Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Track Index or Equalizer or Selection Checkbox
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: widget.isSelectionMode
                          ? Icon(
                              widget.isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: widget.isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              size: 20,
                            )
                          : (widget.isCurrent
                              ? PlayingEqualizerIcon(
                                  color: theme.colorScheme.primary,
                                  size: 16,
                                  isPlaying: widget.isPlaying,
                                )
                              : Text(
                                  '${widget.index + 1}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                                )),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Track Title & Artist
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item.title.isNotEmpty
                              ? widget.item.title
                              : widget.item.path.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: (widget.isCurrent || widget.isSelected)
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: (widget.isCurrent || widget.isSelected)
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.item.artist.isNotEmpty
                              ? widget.item.artist
                              : (widget.item.album.isNotEmpty
                                  ? widget.item.album
                                  : '--'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Duration or Delete button on hover (when not in selection mode)
                  if (!widget.isSelectionMode) ...[
                    if (_isHovered)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: theme.colorScheme.error,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: widget.onRemove,
                      )
                    else
                      Text(
                        _formatDuration(widget.item.durationMs),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(width: 8),

                    // Reorder drag handle
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: Icon(
                        Icons.drag_handle_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ] else ...[
                    Text(
                      _formatDuration(widget.item.durationMs),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
