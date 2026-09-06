import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/models/album_summary.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/playback_source.dart';
import 'package:vynody/utils/folder_helpers.dart';
import 'package:vynody/utils/playback_utils.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/song_thumbnail.dart';
import '../../widgets/volume_controls.dart';

Future<void> showAlbumQuickDetailModal(
  BuildContext context,
  WidgetRef ref,
  AlbumSummary album,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Album Detail',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return AlbumCoverFlowQuickDetailDialog(album: album);
    },
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AlbumCoverFlowQuickDetailDialog extends ConsumerStatefulWidget {
  const AlbumCoverFlowQuickDetailDialog({super.key, required this.album});

  final AlbumSummary album;

  @override
  ConsumerState<AlbumCoverFlowQuickDetailDialog> createState() =>
      _AlbumCoverFlowQuickDetailDialogState();
}

class _AlbumCoverFlowQuickDetailDialogState
    extends ConsumerState<AlbumCoverFlowQuickDetailDialog> {
  bool _showVolumeSlider = false;
  Timer? _volumeSliderTimer;
  double? _dragPositionMs;

  void _startVolumeSliderTimer() {
    _volumeSliderTimer?.cancel();
    _volumeSliderTimer = Timer(const Duration(seconds: 4), () {
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

  @override
  void dispose() {
    _volumeSliderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final audio = ref.read(audioServiceProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isPlaying = ref.watch(audioIsPlayingProvider);
    final volume = ref.watch(audioVolumeProvider);
    final isMuted = ref.watch(audioIsMutedProvider);
    final position = ref.watch(audioPositionProvider);
    final duration = ref.watch(audioDurationProvider);

    final size = MediaQuery.of(context).size;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final bool useTwoColumn =
        (isLandscape && size.width >= 480) || (size.width >= 560 && size.height < 520);
    final bool isNarrow = size.width < 600 || size.height < 520;

    final double dialogWidth = useTwoColumn
        ? math.min(760.0, size.width - 24.0)
        : math.min(680.0, size.width - (isNarrow ? 24.0 : 32.0));
    final double dialogHeight = useTwoColumn
        ? math.min(520.0, size.height - 24.0)
        : math.min(580.0, size.height - (isNarrow ? 36.0 : 64.0));

    final dialogBg = isDark
        ? const Color(0xFF1E1E24).withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: 0.92);
    final borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.35);

    Widget buildSongList({EdgeInsets? padding}) {
      return ListView.builder(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: album.songs.length,
        itemBuilder: (context, index) {
          final song = album.songs[index];
          final isCurrent = currentMusic?.path == song.path;
          final trackNumberStr = (index + 1).toString().padLeft(2, '0');

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              audio.playPlaylist(
                album.songs,
                initialIndex: index,
                source: PlaybackSource(
                  type: PlaybackSourceType.album,
                  id: album.id,
                  name: album.title,
                ),
              );
            },
            onSecondaryTapDown: (details) {
              showSongContextMenu(
                context,
                details.globalPosition,
                song: song,
                songs: [song],
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: Row(
                children: [
                  // Track Number or Playing Icon
                  SizedBox(
                    width: 28,
                    child: isCurrent
                        ? Icon(
                            isPlaying
                                ? Icons.volume_up_rounded
                                : Icons.pause_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          )
                        : Text(
                            trackNumberStr,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  // Title & Artist
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title ?? song.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCurrent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song.artist ?? l10n.unknownArtist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Duration
                  Text(
                    formatDurationMs(song.durationMillis),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // More button
                  Builder(
                    builder: (btnContext) {
                      return IconButton(
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          final renderBox = btnContext.findRenderObject() as RenderBox?;
                          final position = renderBox != null
                              ? renderBox.localToGlobal(Offset.zero) + const Offset(0, 30)
                              : Offset.zero;
                          showSongContextMenu(
                            context,
                            position,
                            song: song,
                            songs: [song],
                          );
                        },
                        icon: const Icon(Icons.more_vert_rounded),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget buildLandscapeLayout() {
      final double leftWidth = (dialogWidth * 0.38).clamp(240.0, 285.0);
      final double coverSize = (dialogHeight * 0.36).clamp(80.0, 140.0);
      final bool isTight = dialogHeight < 390;
      final double actionGroupWidth = (leftWidth - 44).clamp(185.0, 215.0);

      final int totalDurationMs = (duration.inMilliseconds > 0)
          ? duration.inMilliseconds
          : (currentMusic?.durationMillis ?? 0);
      final double currentPositionMs =
          _dragPositionMs ?? position.inMilliseconds.toDouble();
      final double sliderValue = (totalDurationMs > 0)
          ? currentPositionMs.clamp(0.0, totalDurationMs.toDouble())
          : 0.0;
      final double maxDuration = math.max(1.0, totalDurationMs.toDouble());

      String formatPlaybackTime(Duration d) {
        final int totalSec = d.inSeconds;
        final int m = totalSec ~/ 60;
        final int s = totalSec % 60;
        return '$m:${s.toString().padLeft(2, '0')}';
      }

      return Row(
        children: [
          // Left: Album Info and Action Controls + Bottom Controls & Volume Dock
          SizedBox(
            width: leftWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTight ? 12 : 16,
                vertical: isTight ? 10 : 14,
              ),
              child: Column(
                children: [
                  // Upper area: Album Cover, metadata, and play/shuffle actions
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Album Cover with subtle elevation
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SongThumbnail(
                                path: album.representativeSong.path,
                                id: album.representativeSong.id,
                                bytes: album.representativeSong.artworkBytes,
                                size: coverSize,
                                width: coverSize,
                                height: coverSize,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isTight ? 8 : 12),
                        // Title & Artist
                        Text(
                          album.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: (isTight
                                  ? theme.textTheme.titleSmall
                                  : theme.textTheme.titleMedium)
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: isTight ? 3 : 4),
                        Text(
                          album.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: isTight ? 11.5 : 12.0,
                          ),
                        ),
                        SizedBox(height: isTight ? 10 : 14),
                        // Quick Action Buttons (Play All & Shuffle) - width aligned with bottom volume bar
                        Center(
                          child: SizedBox(
                            width: actionGroupWidth,
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: Size(0, isTight ? 28 : 31),
                                      fixedSize: Size.fromHeight(isTight ? 28 : 31),
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      side: BorderSide(
                                        color: theme.colorScheme.outline.withValues(alpha: 0.35),
                                        width: 0.9,
                                      ),
                                      shape: const StadiumBorder(),
                                      foregroundColor: theme.colorScheme.onSurface,
                                    ),
                                    onPressed: () {
                                      audio.playPlaylist(
                                        album.songs,
                                        source: PlaybackSource(
                                          type: PlaybackSourceType.album,
                                          id: album.id,
                                          name: album.title,
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.play_arrow_rounded, size: 16, color: theme.colorScheme.primary),
                                    label: Text(
                                      l10n.playAll,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isTight ? 11.5 : 12.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: Size(0, isTight ? 28 : 31),
                                      fixedSize: Size.fromHeight(isTight ? 28 : 31),
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      side: BorderSide(
                                        color: theme.colorScheme.outline.withValues(alpha: 0.35),
                                        width: 0.9,
                                      ),
                                      shape: const StadiumBorder(),
                                      foregroundColor: theme.colorScheme.onSurface,
                                    ),
                                    onPressed: () {
                                      audio.playPlaylist(
                                        List.of(album.songs)..shuffle(),
                                        source: PlaybackSource(
                                          type: PlaybackSourceType.album,
                                          id: album.id,
                                          name: album.title,
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.shuffle_rounded, size: 14, color: theme.colorScheme.primary),
                                    label: Text(
                                      l10n.shufflePlay,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isTight ? 11.5 : 12.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isTight ? 6 : 10),
                  // Apple Music styled Progress Bar with elapsed & total time below
                  Center(
                    child: SizedBox(
                      width: actionGroupWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3.0,
                              trackShape: const RoundedRectSliderTrackShape(),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 4.5,
                                elevation: 1,
                              ),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: theme.colorScheme.onSurface.withValues(
                                alpha: isDark ? 0.16 : 0.10,
                              ),
                              thumbColor: theme.colorScheme.primary,
                            ),
                            child: Slider(
                              value: sliderValue,
                              min: 0,
                              max: maxDuration,
                              onChanged: totalDurationMs > 0
                                  ? (val) {
                                      setState(() {
                                        _dragPositionMs = val;
                                      });
                                    }
                                  : null,
                              onChangeEnd: totalDurationMs > 0
                                  ? (val) {
                                      audio.seek(Duration(milliseconds: val.round()));
                                      setState(() {
                                        _dragPositionMs = null;
                                      });
                                    }
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatPlaybackTime(
                                    Duration(milliseconds: currentPositionMs.round()),
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: isTight ? 10.0 : 10.5,
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                                Text(
                                  formatPlaybackTime(
                                    Duration(milliseconds: totalDurationMs),
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: isTight ? 10.0 : 10.5,
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isTight ? 2 : 4),
                  // Playback Transport Controls (Prev, Play/Pause, Next) - Extra large & positioned above volume bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: l10n.previousTrack,
                        iconSize: isTight ? 28 : 32,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: isTight ? 42 : 48,
                          minHeight: isTight ? 42 : 48,
                        ),
                        onPressed: () => audio.previous(),
                        icon: const Icon(Icons.skip_previous_rounded),
                      ),
                      SizedBox(width: isTight ? 10 : 16),
                      IconButton(
                        tooltip: isPlaying ? l10n.pause : l10n.play,
                        iconSize: isTight ? 34 : 40,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: isTight ? 46 : 52,
                          minHeight: isTight ? 46 : 52,
                        ),
                        onPressed: () {
                          if (currentMusic == null && album.songs.isNotEmpty) {
                            audio.playPlaylist(
                              album.songs,
                              source: PlaybackSource(
                                type: PlaybackSourceType.album,
                                id: album.id,
                                name: album.title,
                              ),
                            );
                          } else {
                            audio.togglePlay();
                          }
                        },
                        icon: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        ),
                      ),
                      SizedBox(width: isTight ? 10 : 16),
                      IconButton(
                        tooltip: l10n.nextTrack,
                        iconSize: isTight ? 28 : 32,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: isTight ? 42 : 48,
                          minHeight: isTight ? 42 : 48,
                        ),
                        onPressed: () => audio.next(),
                        icon: const Icon(Icons.skip_next_rounded),
                      ),
                    ],
                  ),
                  SizedBox(height: isTight ? 4 : 8),
                  // Dedicated Compact Bottom Volume Bar with speaker icons on both sides (aligned width)
                  Center(
                    child: SizedBox(
                      width: actionGroupWidth,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: isMuted ? l10n.unmute : l10n.mute,
                            iconSize: 16,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            onPressed: () => audio.toggleMute(),
                            icon: Icon(
                              isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_mute_rounded,
                              color: isMuted
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Expanded(
                            child: Listener(
                              onPointerSignal: (pointerSignal) {
                                if (pointerSignal is PointerScrollEvent) {
                                  audio.setVolume(
                                    (audio.volume - pointerSignal.scrollDelta.dy * 0.1).roundToDouble(),
                                    showVolumeHud: false,
                                  );
                                }
                              },
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 3.0,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 4.5,
                                    elevation: 1,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                                  activeTrackColor: theme.colorScheme.primary,
                                  inactiveTrackColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                                  thumbColor: theme.colorScheme.primary,
                                ),
                                child: Slider(
                                  value: isMuted ? 0 : volume.clamp(0.0, 100.0),
                                  min: 0,
                                  max: 100,
                                  onChanged: (val) {
                                    audio.setVolume(
                                      val.roundToDouble(),
                                      showVolumeHud: false,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.volume,
                            iconSize: 16,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            onPressed: () {
                              if (audio.volume < 100) {
                                audio.setVolume(100, showVolumeHud: false);
                              }
                            },
                            icon: Icon(
                              Icons.volume_up_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 0.8,
            color: borderColor,
          ),
          // Right: Header bar + Song List
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 8, 6),
                  child: Row(
                    children: [
                      Text(
                        '${l10n.songCount(album.trackCount)} · ${formatDurationMs(album.totalDurationMillis)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: MaterialLocalizations.of(context).closeButtonLabel,
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: borderColor,
                ),
                Expanded(
                  child: buildSongList(),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget buildPortraitLayout() {
      final double headerHeight = isNarrow ? 80.0 : 100.0;
      final double buttonHeight = isNarrow ? 32.0 : 40.0;

      return Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              isNarrow ? 14 : 20,
              isNarrow ? 12 : 20,
              isNarrow ? 14 : 20,
              isNarrow ? 10 : 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album Artwork Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: headerHeight,
                    height: headerHeight,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SongThumbnail(
                      path: album.representativeSong.path,
                      id: album.representativeSong.id,
                      bytes: album.representativeSong.artworkBytes,
                      size: headerHeight,
                      width: headerHeight,
                      height: headerHeight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                SizedBox(width: isNarrow ? 12 : 16),
                // Album Info & Buttons
                Expanded(
                  child: SizedBox(
                    height: headerHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  album.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: (isNarrow
                                          ? theme.textTheme.titleMedium
                                          : theme.textTheme.titleLarge)
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${album.artist}  ·  ${l10n.songCount(album.trackCount)}  ·  ${formatDurationMs(album.totalDurationMillis)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: (isNarrow
                                          ? theme.textTheme.bodySmall
                                          : theme.textTheme.bodyMedium)
                                      ?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Close button
                          IconButton(
                            tooltip: MaterialLocalizations.of(context).closeButtonLabel,
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            alignment: Alignment.topRight,
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final bool showButtonLabels = isNarrow
                              ? constraints.maxWidth >= 360
                              : constraints.maxWidth >= 410;
                          final bool showVolumeButton = constraints.maxWidth >= 280;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              showButtonLabels
                                  ? OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: Size(0, buttonHeight),
                                        fixedSize: Size.fromHeight(buttonHeight),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isNarrow ? 12 : 16,
                                        ),
                                        side: BorderSide(
                                          color: theme.colorScheme.outline.withValues(alpha: 0.35),
                                          width: 0.9,
                                        ),
                                        shape: const StadiumBorder(),
                                        foregroundColor: theme.colorScheme.onSurface,
                                      ),
                                      onPressed: () {
                                        audio.playPlaylist(
                                          album.songs,
                                          source: PlaybackSource(
                                            type: PlaybackSourceType.album,
                                            id: album.id,
                                            name: album.title,
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.play_arrow_rounded, size: 20, color: theme.colorScheme.primary),
                                      label: Text(l10n.playAll),
                                    )
                                  : IconButton.outlined(
                                      tooltip: l10n.playAll,
                                      style: IconButton.styleFrom(
                                        minimumSize: Size(buttonHeight, buttonHeight),
                                        fixedSize: Size(buttonHeight, buttonHeight),
                                        padding: EdgeInsets.zero,
                                        side: BorderSide(
                                          color: theme.colorScheme.outline.withValues(alpha: 0.35),
                                          width: 0.9,
                                        ),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        audio.playPlaylist(
                                          album.songs,
                                          source: PlaybackSource(
                                            type: PlaybackSourceType.album,
                                            id: album.id,
                                            name: album.title,
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.play_arrow_rounded, size: 20, color: theme.colorScheme.primary),
                                    ),
                              const SizedBox(width: 8),
                              showButtonLabels
                                  ? OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: Size(0, buttonHeight),
                                        fixedSize: Size.fromHeight(buttonHeight),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isNarrow ? 12 : 16,
                                        ),
                                        side: BorderSide(
                                          color: theme.colorScheme.outline.withValues(alpha: 0.35),
                                          width: 0.9,
                                        ),
                                        shape: const StadiumBorder(),
                                        foregroundColor: theme.colorScheme.onSurface,
                                      ),
                                      onPressed: () {
                                        audio.playPlaylist(
                                          List.of(album.songs)..shuffle(),
                                          source: PlaybackSource(
                                            type: PlaybackSourceType.album,
                                            id: album.id,
                                            name: album.title,
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.shuffle_rounded, size: 20, color: theme.colorScheme.primary),
                                      label: Text(l10n.shufflePlay),
                                    )
                                  : IconButton.outlined(
                                      tooltip: l10n.shufflePlay,
                                      style: IconButton.styleFrom(
                                        minimumSize: Size(buttonHeight, buttonHeight),
                                        fixedSize: Size(buttonHeight, buttonHeight),
                                        padding: EdgeInsets.zero,
                                        side: BorderSide(
                                          color: theme.colorScheme.outline.withValues(alpha: 0.35),
                                          width: 0.9,
                                        ),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        audio.playPlaylist(
                                          List.of(album.songs)..shuffle(),
                                          source: PlaybackSource(
                                            type: PlaybackSourceType.album,
                                            id: album.id,
                                            name: album.title,
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.shuffle_rounded, size: 20, color: theme.colorScheme.primary),
                                    ),
                              const Spacer(),
                              Container(
                                height: buttonHeight,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                                    alpha: isDark ? 0.45 : 0.65,
                                  ),
                                  borderRadius: BorderRadius.circular(buttonHeight / 2),
                                  border: Border.all(
                                    color: borderColor.withValues(alpha: 0.5),
                                    width: 0.8,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      tooltip: l10n.previousTrack,
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: isNarrow ? 30 : 34,
                                        minHeight: buttonHeight - 2,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => audio.previous(),
                                      icon: const Icon(Icons.skip_previous_rounded),
                                    ),
                                    IconButton(
                                      tooltip: isPlaying ? l10n.pause : l10n.play,
                                      iconSize: 22,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: isNarrow ? 34 : 38,
                                        minHeight: buttonHeight - 2,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        if (currentMusic == null && album.songs.isNotEmpty) {
                                          audio.playPlaylist(
                                            album.songs,
                                            source: PlaybackSource(
                                              type: PlaybackSourceType.album,
                                              id: album.id,
                                              name: album.title,
                                            ),
                                          );
                                        } else {
                                          audio.togglePlay();
                                        }
                                      },
                                      icon: Icon(
                                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: l10n.nextTrack,
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: isNarrow ? 30 : 34,
                                        minHeight: buttonHeight - 2,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => audio.next(),
                                      icon: const Icon(Icons.skip_next_rounded),
                                    ),
                                  ],
                                ),
                              ),
                              if (showVolumeButton) ...[
                                const SizedBox(width: 8),
                                Listener(
                                  onPointerSignal: (pointerSignal) {
                                    if (pointerSignal is PointerScrollEvent) {
                                      _startVolumeSliderTimer();
                                      setState(() => _showVolumeSlider = true);
                                      audio.setVolume(
                                        (audio.volume - pointerSignal.scrollDelta.dy * 0.1).roundToDouble(),
                                        showVolumeHud: false,
                                      );
                                    }
                                  },
                                  child: IconButton(
                                    tooltip: l10n.volume,
                                    iconSize: 20,
                                    style: IconButton.styleFrom(
                                      minimumSize: Size(buttonHeight, buttonHeight),
                                      fixedSize: Size(buttonHeight, buttonHeight),
                                      padding: EdgeInsets.zero,
                                      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
                                        alpha: isDark ? 0.45 : 0.65,
                                      ),
                                      side: BorderSide(
                                        color: borderColor.withValues(alpha: 0.5),
                                        width: 0.8,
                                      ),
                                      shape: const CircleBorder(),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      setState(() {
                                        _showVolumeSlider = !_showVolumeSlider;
                                        if (_showVolumeSlider) {
                                          _startVolumeSliderTimer();
                                        } else {
                                          _cancelVolumeSliderTimer();
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      getVolumeIcon(volume, isMuted: isMuted),
                                      color: isMuted ? theme.colorScheme.error : null,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 0.8,
          color: borderColor,
        ),
        // Songs List
        Expanded(
          child: buildSongList(),
        ),
      ],
    );
  }

  return Stack(
    children: [
      Center(
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                  color: dialogBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: useTwoColumn ? buildLandscapeLayout() : buildPortraitLayout(),
              ),
            ),
          ),
        ),
      ),
      if (_showVolumeSlider)
        VolumeSliderOverlay(
          volume: volume,
          isMuted: isMuted,
          onToggleMute: () {
            _startVolumeSliderTimer();
            audio.toggleMute();
          },
          onVolumeChanged: (val) {
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
            audio.setVolume(
              (audio.volume - delta * 0.2).roundToDouble(),
              showVolumeHud: false,
            );
          },
          onScroll: (deltaY) {
            _startVolumeSliderTimer();
            audio.setVolume(
              (audio.volume - deltaY * 0.1).roundToDouble(),
              showVolumeHud: false,
            );
          },
          onInteraction: _startVolumeSliderTimer,
        ),
    ],
  );
}
}
