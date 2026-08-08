import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/widgets/animated_play_pause_button.dart';
import 'package:vynody/widgets/app_tooltip.dart';
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
    final progress = ref.watch(audioProgressProvider);
    final playlistService = ref.watch(playlistServiceProvider);
    final isFavorite =
        currentMusic != null && playlistService.isFavoriteSong(currentMusic);
    final l10n = AppLocalizations.of(context)!;

    final windowWidth = MediaQuery.of(context).size.width;
    final showVolumeAndFavorite = windowWidth >= 568.0;

    final playControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MiniControlButton(
          icon: Icons.skip_previous_rounded,
          onPressed: onPrevious,
          tooltip: l10n.previous,
        ),
        const SizedBox(width: 4),
        AnimatedPlayPauseButton(
          isPlaying: isPlaying,
          onPressed: onPlayPause,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
          size: 24,
          padding: const EdgeInsets.all(6.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          tooltip: isPlaying ? l10n.pause : l10n.play,
        ),
        const SizedBox(width: 4),
        MiniControlButton(
          icon: Icons.skip_next_rounded,
          onPressed: onNext,
          tooltip: l10n.next,
        ),
      ],
    );

    final trackInfo = Flexible(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onMiniTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniArtwork(),
            const SizedBox(width: 14),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: MiniPlayerProgressInfo(
                  currentMusic: currentMusic,
                  progress: progress,
                  onScrubbing: onScrubbing,
                  onSeek: onSeek,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final rightControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTooltip(
          message: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
          child: IconButton(
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite
                  ? Colors.redAccent
                  : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87),
              size: 18,
            ),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: currentMusic == null
                ? null
                : () async {
                    await playlistService.toggleFavoriteSong(currentMusic);
                  },
          ),
        ),
        const SizedBox(width: 4),
        MiniInlineVolumeControl(
          volume: ref.watch(audioVolumeProvider),
          isMuted: ref.watch(audioIsMutedProvider),
          onToggleMute: () {
            ref.read(settingsServiceProvider).resetInactivity();
            ref.read(audioServiceProvider).toggleMute();
          },
          showSlider: showMiniVolumeSlider,
          onTap: onVolumeTap,
          onChanged: onVolumeChanged,
          onScroll: onVolumeScroll,
          tooltip: l10n.volume,
        ),
      ],
    );

    return MouseRegion(
      onExit: (_) => onMiniMouseExit?.call(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withValues(alpha: 0.82)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color:
                  (Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.grey[400]!)
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
                child: Opacity(
                  opacity: 0.6,
                  child: MiniSpectrumBackground(
                    audio: ref.read(audioServiceProvider),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: showVolumeAndFavorite
                      ? [
                          playControls,
                          const SizedBox(width: 14),
                          trackInfo,
                          const SizedBox(width: 14),
                          rightControls,
                        ]
                      : [trackInfo, const SizedBox(width: 14), playControls],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
