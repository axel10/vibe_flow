import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/utils/playback_utils.dart';
import 'package:vynody/widgets/animated_play_pause_button.dart';
import 'package:vynody/widgets/app_tooltip.dart';
import 'package:vynody/widgets/mini_player_widgets.dart';

/// 一体化悬浮底部面板（Mini播放器 + 实时进度条分割线 + Tab栏）
class FloatingDockBottomBar extends ConsumerStatefulWidget {
  const FloatingDockBottomBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.isPlayback,
    required this.isHidden,
    this.hideMiniPlayer = false,
    this.additionalBottomOffset = 0.0,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isPlayback;
  final bool isHidden;
  final bool hideMiniPlayer;
  final double additionalBottomOffset;

  @override
  ConsumerState<FloatingDockBottomBar> createState() =>
      _FloatingDockBottomBarState();
}

class _FloatingDockBottomBarState extends ConsumerState<FloatingDockBottomBar> {
  bool _isDragging = false;
  double _dragProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isPlaying = ref.watch(audioIsPlayingProvider);
    final isBuffering = ref.watch(audioIsBufferingProvider);
    final progress = ref.watch(audioProgressProvider);
    final position = ref.watch(audioPositionProvider);
    final duration = ref.watch(audioDurationProvider);
    final audio = ref.watch(audioServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 当有正在播放的歌曲且不在全屏播放页且未被多选屏蔽时，展开 Mini 播放器
    final showMini = currentMusic != null && !widget.isPlayback && !widget.hideMiniPlayer;

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final totalBottomOffset = bottomPadding + 8.0 + widget.additionalBottomOffset;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: 16.0,
      right: 16.0,
      bottom: widget.isHidden ? -(200.0 + bottomPadding) : totalBottomOffset,
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          opacity: widget.isHidden ? 0.0 : 1.0,
          child: IgnorePointer(
            ignoring: widget.isHidden,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: widget.isPlayback
                          ? (isDark ? 0.22 : 0.08)
                          : (isDark ? 0.40 : 0.12),
                    ),
                    blurRadius: widget.isPlayback ? 20 : 28,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: widget.isPlayback
                          ? (isDark ? 0.10 : 0.04)
                          : (isDark ? 0.20 : 0.06),
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.isPlayback ? 28 : 24,
                    sigmaY: widget.isPlayback ? 28 : 24,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: widget.isPlayback
                          ? (isDark
                              ? Colors.black.withValues(alpha: 0.22)
                              : Colors.white.withValues(alpha: 0.32))
                          : theme.colorScheme.surface.withValues(
                              alpha: isDark ? 0.82 : 0.88,
                            ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: (isDark
                                ? Colors.white
                                : (widget.isPlayback ? Colors.white : Colors.black))
                            .withValues(
                              alpha: widget.isPlayback
                                  ? (isDark ? 0.16 : 0.28)
                                  : (isDark ? 0.12 : 0.08),
                            ),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. 上半部：Mini 播放器
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          child: showMini
                              ? _buildMiniPlayerHeader(
                                  context,
                                  ref,
                                  l10n: l10n,
                                  theme: theme,
                                  isDark: isDark,
                                  currentMusic: currentMusic,
                                  isPlaying: isPlaying,
                                  isBuffering: isBuffering,
                                  audio: audio,
                                  position: position,
                                  duration: duration,
                                )
                              : const SizedBox.shrink(),
                        ),

                        // 2. 中间：可拖拽胶囊滑块的实时播放进度条
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: showMini
                              ? _FloatingDockProgressBar(
                                  theme: theme,
                                  isDark: isDark,
                                  progress: progress,
                                  isDragging: _isDragging,
                                  dragProgress: _dragProgress,
                                  onDragStart: (val) {
                                    setState(() {
                                      _isDragging = true;
                                      _dragProgress = val;
                                    });
                                  },
                                  onDragUpdate: (val) {
                                    setState(() {
                                      _isDragging = true;
                                      _dragProgress = val;
                                    });
                                  },
                                  onDragEnd: (val) {
                                    final seekProgress = val.clamp(0.0, 1.0);
                                    if (duration.inMilliseconds > 0) {
                                      audio.seek(
                                        Duration(
                                          milliseconds:
                                              (duration.inMilliseconds *
                                                      seekProgress)
                                                  .toInt(),
                                        ),
                                      );
                                    }
                                    setState(() {
                                      _isDragging = false;
                                    });
                                  },
                                  onDragCancel: () {
                                    setState(() {
                                      _isDragging = false;
                                    });
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),

                        // 3. 下半部：Tab 导航栏
                        _buildBottomTabs(
                          context,
                          theme,
                          isDark,
                          l10n,
                          isPlayback: widget.isPlayback,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 上半部 Mini 播放器内容
  Widget _buildMiniPlayerHeader(
    BuildContext context,
    WidgetRef ref, {
    required AppLocalizations l10n,
    required ThemeData theme,
    required bool isDark,
    required dynamic currentMusic,
    required bool isPlaying,
    required bool isBuffering,
    required dynamic audio,
    required Duration position,
    required Duration duration,
  }) {
    final displayPosition = _isDragging
        ? Duration(
            milliseconds:
                (duration.inMilliseconds * _dragProgress.clamp(0.0, 1.0))
                    .toInt(),
          )
        : position;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 歌曲信息与按钮区域（拖动进度条时高斯模糊并淡出）
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              tween: Tween<double>(begin: 0, end: _isDragging ? 5.0 : 0.0),
              builder: (context, blur, child) {
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isDragging ? 0.25 : 1.0,
                    child: IgnorePointer(
                      ignoring: _isDragging,
                      child: child,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  // 左侧：封面 + 歌曲名/歌手（点击直达播放页）
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => widget.onDestinationSelected(1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 2.0,
                          ),
                          child: Row(
                            children: [
                              const MiniArtwork(),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentMusic.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      currentMusic.artist ?? l10n.unknownArtist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.black54,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 右侧：播放控制按钮
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MiniControlButton(
                        icon: Icons.skip_previous_rounded,
                        iconSize: 18,
                        padding: const EdgeInsets.all(5),
                        onPressed: audio.previous,
                        tooltip: l10n.previous,
                      ),
                      const SizedBox(width: 2),
                      AnimatedPlayPauseButton(
                        isPlaying: isPlaying,
                        isLoading: isBuffering,
                        onPressed: audio.togglePlay,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 28,
                        padding: const EdgeInsets.all(4.0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        tooltip: isPlaying ? l10n.pause : l10n.play,
                      ),
                      const SizedBox(width: 2),
                      MiniControlButton(
                        icon: Icons.skip_next_rounded,
                        iconSize: 18,
                        padding: const EdgeInsets.all(5),
                        onPressed: audio.next,
                        tooltip: l10n.next,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. 拖拽时浮现的时间指示层（左侧当前拖拽进度时间，右侧歌曲总时长）
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isDragging ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        formatDuration(displayPosition),
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        formatDuration(duration),
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// 下半部 Tab 导航项
  Widget _buildBottomTabs(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations l10n, {
    required bool isPlayback,
  }) {
    final tabs = [
      _TabItem(
        index: 0,
        label: l10n.file,
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder_rounded,
      ),
      _TabItem(
        index: 1,
        label: l10n.play,
        icon: Icons.play_circle_outline_rounded,
        selectedIcon: Icons.play_circle_rounded,
      ),
      _TabItem(
        index: 2,
        label: l10n.list,
        icon: Icons.playlist_play_outlined,
        selectedIcon: Icons.playlist_play_rounded,
      ),
      _TabItem(
        index: 3,
        label: l10n.queueTab,
        icon: Icons.queue_music_outlined,
        selectedIcon: Icons.queue_music_rounded,
      ),
      _TabItem(
        index: 4,
        label: l10n.share,
        icon: Icons.share_outlined,
        selectedIcon: Icons.share_rounded,
      ),
      _TabItem(
        index: 5,
        label: l10n.settings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
      ),
    ];

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.map((tab) {
          final isSelected = widget.currentIndex == tab.index;
          return Expanded(
            child: _TabButton(
              item: tab,
              isSelected: isSelected,
              isPlayback: isPlayback,
              theme: theme,
              isDark: isDark,
              onTap: () => widget.onDestinationSelected(tab.index),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TabItem {
  final int index;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _TabItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.isSelected,
    required this.isPlayback,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  final _TabItem item;
  final bool isSelected;
  final bool isPlayback;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = isPlayback
        ? (isDark
            ? Colors.white.withValues(alpha: 0.70)
            : Colors.black.withValues(alpha: 0.65))
        : (isDark ? Colors.white60 : Colors.black54);

    return AppTooltip(
      message: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected
                    ? (isPlayback
                        ? (isDark
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.40))
                        : (theme.colorScheme.primaryContainer.withValues(
                            alpha: isDark ? 0.45 : 0.7,
                          )))
                    : Colors.transparent,
              ),
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 具备可拖动胶囊滑块的实时播放进度条
class _FloatingDockProgressBar extends StatelessWidget {
  const _FloatingDockProgressBar({
    required this.theme,
    required this.isDark,
    required this.progress,
    required this.isDragging,
    required this.dragProgress,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final ThemeData theme;
  final bool isDark;
  final double progress;
  final bool isDragging;
  final double dragProgress;
  final ValueChanged<double> onDragStart;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double> onDragEnd;
  final VoidCallback onDragCancel;

  void _handleUpdate(double localX, double totalWidth, bool isStart) {
    if (totalWidth <= 0) return;
    final newProgress = (localX / totalWidth).clamp(0.0, 1.0);
    if (isStart) {
      onDragStart(newProgress);
    } else {
      onDragUpdate(newProgress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveProgress =
        (isDragging ? dragProgress : progress).clamp(0.0, 1.0);
    const trackHeight = 3.5;
    final thumbWidth = isDragging ? 18.0 : 14.0;
    final thumbHeight = isDragging ? 8.0 : 7.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final progressWidth = totalWidth * effectiveProgress;
        final thumbLeft =
            (progressWidth - thumbWidth / 2).clamp(0.0, totalWidth - thumbWidth);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) =>
              _handleUpdate(details.localPosition.dx, totalWidth, true),
          onHorizontalDragUpdate: (details) =>
              _handleUpdate(details.localPosition.dx, totalWidth, false),
          onHorizontalDragEnd: (details) => onDragEnd(dragProgress),
          onHorizontalDragCancel: onDragCancel,
          onTapDown: (details) =>
              _handleUpdate(details.localPosition.dx, totalWidth, true),
          onTapUp: (details) {
            if (totalWidth <= 0) return;
            final newProgress =
                (details.localPosition.dx / totalWidth).clamp(0.0, 1.0);
            onDragEnd(newProgress);
          },
          onTapCancel: onDragCancel,
          child: Container(
            height: 14.0, // 充足的手势触控热区
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                // 1. 底层轨道 (加粗至 3.5px)
                Container(
                  height: trackHeight,
                  width: totalWidth,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: isDark ? 0.12 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                  ),
                ),

                // 2. 已播放高亮轨道
                Container(
                  height: trackHeight,
                  width: progressWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.85),
                        theme.colorScheme.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                  ),
                ),

                // 3. 可拖拽胶囊形状滑块 (Capsule Thumb)
                Positioned(
                  left: thumbLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: thumbWidth,
                    height: thumbHeight,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(thumbHeight / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.45 : 0.25,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
