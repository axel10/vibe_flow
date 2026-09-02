import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/widgets/animated_play_pause_button.dart';
import 'package:vynody/widgets/mini_player_widgets.dart';
import 'playback_progress_section.dart';
import '../../l10n/app_localizations.dart';

class MiniPlayerCard extends ConsumerWidget {
  final bool showMiniVolumeSlider;
  final VoidCallback? onMiniTap;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final ValueChanged<double>? onScrubbing;
  final ValueChanged<double>? onSeek;
  final VoidCallback? onVolumeTap;
  final ValueChanged<double>? onVolumeChanged;
  final ValueChanged<double>? onVolumeScroll;
  final VoidCallback? onMiniMouseExit;

  const MiniPlayerCard({
    super.key,
    this.showMiniVolumeSlider = false,
    this.onMiniTap,
    this.onPrevious,
    this.onPlayPause,
    this.onNext,
    this.onScrubbing,
    this.onSeek,
    this.onVolumeTap,
    this.onVolumeChanged,
    this.onVolumeScroll,
    this.onMiniMouseExit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isPlaying = ref.watch(audioIsPlayingProvider);
    final isBuffering = ref.watch(audioIsBufferingProvider);
    final progress = ref.watch(audioProgressProvider);
    final playlistService = ref.watch(playlistServiceProvider);
    final isFavorite =
        currentMusic != null && playlistService.isFavoriteSong(currentMusic);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final windowWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final showVolume = windowWidth >= 568.0 || isLandscape;
    final double infoMaxWidth =
        isLandscape || windowWidth >= 568.0 ? (windowWidth >= 800 ? 380.0 : 320.0) : 220.0;

    final double prevNextIconSize = isLandscape ? 28.0 : 20.0;
    final double playPauseIconSize = isLandscape ? 34.0 : 28.0;
    final double secondaryIconSize = isLandscape ? 21.0 : 18.0;
    final double controlsSpacing = isLandscape ? 6.0 : 4.0;

    final playControls = Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MiniControlButton(
            icon: Icons.skip_previous_rounded,
            onPressed: onPrevious,
            tooltip: l10n.previous,
            iconSize: prevNextIconSize,
          ),
          SizedBox(width: controlsSpacing),
          AnimatedPlayPauseButton(
            isPlaying: isPlaying,
            isLoading: isBuffering,
            onPressed: onPlayPause,
            color: isDark ? Colors.white : Colors.black87,
            size: playPauseIconSize,
            padding: const EdgeInsets.all(6.0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            tooltip: isPlaying ? l10n.pause : l10n.play,
          ),
          SizedBox(width: controlsSpacing),
          MiniControlButton(
            icon: Icons.skip_next_rounded,
            onPressed: onNext,
            tooltip: l10n.next,
            iconSize: prevNextIconSize,
          ),
        ],
      ),
    );

    final trackInfo = Flexible(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onMiniTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: infoMaxWidth),
          child: MiniPlayerProgressInfo(
            currentMusic: currentMusic,
            progress: progress,
            onScrubbing: onScrubbing,
            onSeek: onSeek,
          ),
        ),
      ),
    );

    final rightControls = Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MiniInlineVolumeControl(
            volume: ref.watch(audioVolumeProvider),
            isMuted: ref.watch(audioIsMutedProvider),
            showSlider: showMiniVolumeSlider,
            onTap: onVolumeTap,
            onChanged: onVolumeChanged,
            onScroll: onVolumeScroll,
            tooltip: l10n.volume,
            iconSize: secondaryIconSize,
          ),
          if (currentMusic != null) ...[
            SizedBox(width: isLandscape ? 4 : 2),
            MiniControlButton(
              icon: isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              onPressed: () async {
                await playlistService.toggleFavoriteSong(currentMusic);
              },
              tooltip: isFavorite
                  ? l10n.removeFromFavorites
                  : l10n.addToFavorites,
              iconSize: secondaryIconSize,
              padding: const EdgeInsets.all(6.0),
              color: isFavorite ? Colors.redAccent : null,
            ),
          ],
        ],
      ),
    );

    return MouseRegion(
      onExit: (_) => onMiniMouseExit?.call(),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.82)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey[400]!)
                  .withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              Positioned.fill(
                child: MiniSpectrumBackground(
                  audio: ref.read(audioServiceProvider),
                ),
              ),
              Padding(
  padding: const EdgeInsets.only(
    left: 16,
    right: 16,
    top: 10,     // 👈 在这里给顶部留出合适的上边距（例如 5 或 6）
    bottom: 2,  // 保持当前满意的下边距不变
  ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: showVolume
                      ? [
                          playControls,
                          const SizedBox(width: 14),
                          trackInfo,
                          const SizedBox(width: 12),
                          rightControls,
                        ]
                      : [
                          trackInfo,
                          const SizedBox(width: 14),
                          playControls,
                        ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

