import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/widgets/library_selection_scope.dart';
import 'package:vynody/widgets/playback_hero_card.dart';
import '../pages/main_layout.dart';
import '../pages/main_layout_riverpod.dart';
export 'playback_ui_tuning.dart';

class MiniPlayerWrapper extends ConsumerStatefulWidget {
  const MiniPlayerWrapper({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MiniPlayerWrapper> createState() => _MiniPlayerWrapperState();
}

class _MiniPlayerWrapperState extends ConsumerState<MiniPlayerWrapper> {
  bool _showMiniVolumeSlider = false;

  @override
  Widget build(BuildContext context) {
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final uiState = ref.watch(mainLayoutUiControllerProvider);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final selectionScope = ref.watch(librarySelectionScopeProvider);
    final librarySelectionActive = selectionScope != LibrarySelectionScope.none;
    final showPlayer = currentMusic != null && !librarySelectionActive;

    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          bottom: showPlayer
              ? (20.0 +
                    MediaQuery.of(context).padding.bottom +
                    uiState.snackBarOffset)
              : -120.0,
          left: 0,
          right: 0,
          child: Center(
            child: currentMusic != null
                ? Builder(
                    builder: (context) {
                      final audio = ref.read(audioServiceProvider);
                      return Container(
                        key: const ValueKey('dynamic-island-detail'),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width >= 568.0
                              ? (MediaQuery.of(context).size.width * 0.9)
                                  .clamp(568.0, double.infinity)
                              : MediaQuery.of(context).size.width * 0.9,
                        ),
                        child: PlaybackHeroCard(
                          isMini: true,
                          enableHero: false,
                          isLandscape: isLandscape,
                          showMiniVolumeSlider: _showMiniVolumeSlider,
                          onMiniTap: () => navigateToMainTab(context, index: 1),
                          onPrevious: audio.previous,
                          onPlayPause: audio.togglePlay,
                          onNext: audio.next,
                          onScrubbing: (val) {
                            // Mini player handles scrubbing internally
                          },
                          onSeek: (val) {
                            audio.seek(
                              Duration(
                                milliseconds:
                                    (audio.duration.inMilliseconds * val)
                                        .toInt(),
                              ),
                            );
                          },
                          onVolumeTap: () {
                            ref.read(settingsServiceProvider).resetInactivity();
                            final nextVisible = !_showMiniVolumeSlider;
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
                            ref.read(settingsServiceProvider).resetInactivity();
                            ref
                                .read(mainLayoutUiControllerProvider.notifier)
                                .setVolumeHudVisible(true);
                            audio.setVolume(value.roundToDouble());
                          },
                          onVolumeScroll: (deltaY) {
                            ref.read(settingsServiceProvider).resetInactivity();
                            ref
                                .read(mainLayoutUiControllerProvider.notifier)
                                .setVolumeHudVisible(true);
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
                : const SizedBox.shrink(key: ValueKey('empty-island-detail')),
          ),
        ),
      ],
    );
  }
}
