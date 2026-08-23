import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/utils/playback_utils.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import 'package:vynody/widgets/app_tooltip.dart';
import 'package:vynody/widgets/marquee_text.dart';
import 'package:vynody/player/library/playlist_service.dart';
import 'package:vynody/widgets/playback_ui_tuning.dart';
import '../../l10n/app_localizations.dart';

enum TrackInfoMenuTarget { title, artistAlbum }

class PlaybackTrackInfo extends ConsumerWidget {
  final MusicFile? currentMusic;
  final TextAlign align;
  final double lyricsModeT;
  final double landscapeT;
  final double controlsScale;
  final bool showVisualizerToggle;
  final VoidCallback? onShowMoreMenu;
  final VoidCallback? onCyclePlaylistMode;
  final VoidCallback? onToggleVisualizer;
  final VoidCallback? onTagCompletionTap;
  final VoidCallback? onSleepTimerTap;
  final VoidCallback? onEqualizerTap;
  final VoidCallback? onVolumeTap;
  final ValueChanged<double>? onVolumeScroll;
  final ValueChanged<double>? onVolumeDrag;

  const PlaybackTrackInfo({
    super.key,
    required this.currentMusic,
    required this.align,
    required this.lyricsModeT,
    required this.landscapeT,
    required this.controlsScale,
    this.showVisualizerToggle = true,
    this.onShowMoreMenu,
    this.onCyclePlaylistMode,
    this.onToggleVisualizer,
    this.onTagCompletionTap,
    this.onSleepTimerTap,
    this.onEqualizerTap,
    this.onVolumeTap,
    this.onVolumeScroll,
    this.onVolumeDrag,
  });

  Future<void> _showTrackInfoContextMenu(
    BuildContext context,
    Offset globalPosition, {
    required TrackInfoMenuTarget target,
    required MusicFile? currentMusic,
  }) async {
    await showSongContextMenu(
      context,
      globalPosition,
      song: currentMusic,
      mode: target == TrackInfoMenuTarget.title
          ? SongContextMenuMode.title
          : SongContextMenuMode.artistAlbum,
    );
  }

  static String _formatSleepTimer(Duration duration) {
    final safe = duration < Duration.zero ? Duration.zero : duration;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLyricsHeaderRightButton({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required bool isFavorite,
    required MusicFile? currentMusic,
    required PlaylistService playlistService,
    required AppPlaybackMode playbackMode,
    required bool isRandomMode,
    required bool showVisualizerToggle,
    required Duration? sleepTimerRemaining,
    required double buttonControlsScale,
  }) {
    final headerKey = ref.watch(
      settingsServiceProvider.select((s) => s.lyricsHeaderRightButton),
    );

    final IconData iconData;
    final String tooltipMsg;
    final VoidCallback? onTapAction;
    final Color? iconColor;

    switch (headerKey) {
      case 'more':
        iconData = Icons.more_horiz;
        tooltipMsg = l10n.more;
        onTapAction = onShowMoreMenu;
        iconColor = Colors.white70;
        break;
      case 'favorite':
        iconData = isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded;
        tooltipMsg = isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites;
        final songForFav = currentMusic;
        onTapAction = songForFav == null
            ? null
            : () async {
                await playlistService.toggleFavoriteSong(songForFav);
              };
        iconColor = isFavorite ? Colors.redAccent : Colors.white70;
        break;
      case 'playlist_mode':
        iconData = getPlaylistModeIcon(playbackMode);
        tooltipMsg = getPlaylistModeName(playbackMode, l10n);
        onTapAction = onCyclePlaylistMode;
        iconColor = Colors.white70;
        break;
      case 'shuffle':
        iconData = Icons.shuffle_rounded;
        tooltipMsg = l10n.randomMode;
        onTapAction = () {
          final audio = ref.read(audioServiceProvider);
          if (audio.settingsService.randomRange == 1 && !isRandomMode) {
            final List<MusicFile> allSongs = [];
            final pathSet = <String>{};
            for (final p in playlistService.playlists) {
              for (final s in p.songs) {
                if (pathSet.add(s.path)) allSongs.add(s);
              }
            }
            audio.toggleRandomMode(globalSongs: allSongs);
          } else {
            audio.toggleRandomMode();
          }
        };
        iconColor = isRandomMode ? Theme.of(context).colorScheme.primary : Colors.white70;
        break;
      case 'tag_completion':
        iconData = Icons.auto_fix_high_rounded;
        tooltipMsg = l10n.tagCompletion;
        onTapAction = onTagCompletionTap;
        iconColor = Colors.white70;
        break;
      case 'sleep_timer':
        iconData = Icons.bedtime_rounded;
        tooltipMsg = sleepTimerRemaining != null
            ? l10n.sleepTimerRemaining(
                _formatSleepTimer(sleepTimerRemaining),
              )
            : l10n.sleepTimer;
        onTapAction = onSleepTimerTap;
        iconColor = sleepTimerRemaining != null
            ? Theme.of(context).colorScheme.primary
            : Colors.white70;
        break;
      case 'equalizer':
        iconData = Icons.tune_rounded;
        tooltipMsg = l10n.effects;
        onTapAction = onEqualizerTap;
        iconColor = Colors.white70;
        break;
      case 'visualizer':
        iconData = showVisualizerToggle ? Icons.analytics : Icons.analytics_outlined;
        tooltipMsg = l10n.visualizer;
        onTapAction = onToggleVisualizer;
        iconColor = showVisualizerToggle ? Theme.of(context).colorScheme.primary : Colors.white70;
        break;
      case 'volume':
        iconData = getVolumeIcon(
          ref.watch(audioVolumeProvider),
          isMuted: ref.watch(audioIsMutedProvider),
        );
        tooltipMsg = l10n.volume;
        onTapAction = onVolumeTap;
        iconColor = Colors.white70;
        break;
      default:
        iconData = isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded;
        tooltipMsg = isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites;
        final songForDefaultFav = currentMusic;
        onTapAction = songForDefaultFav == null
            ? null
            : () async {
                await playlistService.toggleFavoriteSong(songForDefaultFav);
              };
        iconColor = isFavorite ? Colors.redAccent : Colors.white70;
        break;
    }

    Widget buttonWidget = SizedBox(
      width: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight * buttonControlsScale,
      height: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight * buttonControlsScale,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(
          iconData,
          size: PlaybackHeroCardUiTuning.lLyricsTitleIconSize * buttonControlsScale,
          color: iconColor,
        ),
        onPressed: onTapAction,
      ),
    );

    if (headerKey == 'volume') {
      buttonWidget = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          onVolumeDrag?.call(details.primaryDelta ?? 0);
        },
        child: Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              onVolumeScroll?.call(pointerSignal.scrollDelta.dy);
            }
          },
          child: buttonWidget,
        ),
      );
    }

    return AppTooltip(
      message: tooltipMsg,
      child: buttonWidget,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final title = currentMusic?.displayName ?? l10n.notSelected;
    final showArtistAlbum = currentMusic != null;

    final rawAlbum = currentMusic?.album?.trim() ?? '';
    final rawArtist = currentMusic?.artist?.trim() ?? '';

    bool isUnknown(String val) {
      if (val.isEmpty) return true;
      final lower = val.toLowerCase();
      return lower == 'unknown' ||
          lower == 'unknown artist' ||
          lower == 'unknown album';
    }

    final bool hasArtist = !isUnknown(rawArtist);
    final bool hasAlbum = !isUnknown(rawAlbum);
    final shouldCollapse = ref.watch(
      settingsServiceProvider.select(
        (s) => s.collapseButtonsInLandscapeLyrics,
      ),
    );
    final transition = lyricsModeT.clamp(0.0, 1.0);
    final double simplifiedT = shouldCollapse ? (landscapeT * transition) : 0.0;
    final double portraitLyricsT = (1.0 - landscapeT) * transition;
    final double rightButtonsFactor = math.max(simplifiedT, portraitLyricsT);
    final bool showFavoriteIconButton = simplifiedT > 0.0;

    final double buttonControlsScale = controlsScale;

    final titleAlignment = Alignment.lerp(
      Alignment.center,
      (shouldCollapse || landscapeT == 0.0)
          ? Alignment.centerLeft
          : Alignment.center,
      transition,
    )!;

    final double baseTitleSize = lerpDouble(
      lerpDouble(
        PlaybackHeroCardUiTuning.trackTitleStandardFont,
        PlaybackHeroCardUiTuning.trackTitlePortraitLyricsFont,
        transition,
      )!,
      lerpDouble(
        PlaybackHeroCardUiTuning.trackTitleStandardFont,
        shouldCollapse
            ? PlaybackHeroCardUiTuning.trackTitleLandscapeLyricsFont
            : PlaybackHeroCardUiTuning.trackTitleStandardFont,
        transition,
      )!,
      landscapeT,
    )!;
    final double minTitleFont = lerpDouble(
      PlaybackHeroCardUiTuning.minTrackTitleFontSize,
      PlaybackHeroCardUiTuning.minTrackTitleFontSize * controlsScale,
      simplifiedT,
    )!.clamp(9.0, PlaybackHeroCardUiTuning.minTrackTitleFontSize);
    final titleSize = math.max(
      minTitleFont,
      baseTitleSize * controlsScale,
    );

    final double baseArtistSize = lerpDouble(
      lerpDouble(
        PlaybackHeroCardUiTuning.trackArtistStandardFont,
        PlaybackHeroCardUiTuning.trackArtistPortraitLyricsFont,
        transition,
      )!,
      lerpDouble(
        PlaybackHeroCardUiTuning.trackArtistStandardFont,
        shouldCollapse
            ? PlaybackHeroCardUiTuning.trackArtistLandscapeLyricsFont
            : PlaybackHeroCardUiTuning.trackArtistStandardFont,
        transition,
      )!,
      landscapeT,
    )!;
    final double minArtistFont = lerpDouble(
      PlaybackHeroCardUiTuning.minTrackArtistFontSize,
      PlaybackHeroCardUiTuning.minTrackArtistFontSize * controlsScale,
      simplifiedT,
    )!.clamp(8.0, PlaybackHeroCardUiTuning.minTrackArtistFontSize);
    final artistSize = math.max(
      minArtistFont,
      baseArtistSize * controlsScale,
    );

    final textContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: Align(
            alignment: titleAlignment,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onSecondaryTapDown: (details) {
                _showTrackInfoContextMenu(
                  context,
                  details.globalPosition,
                  target: TrackInfoMenuTarget.title,
                  currentMusic: currentMusic,
                );
              },
              onLongPressStart: (details) {
                _showTrackInfoContextMenu(
                  context,
                  details.globalPosition,
                  target: TrackInfoMenuTarget.title,
                  currentMusic: currentMusic,
                );
              },
              child: DefaultTextStyle(
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  height: lerpDouble(
                    lerpDouble(1.2, 1.1, transition),
                    lerpDouble(1.2, 1.25, transition),
                    landscapeT,
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    final style = DefaultTextStyle.of(context).style;
                    return MarqueeText(
                      text: title,
                      style: style,
                      alignment: titleAlignment,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (showArtistAlbum)
          Padding(
            padding: EdgeInsets.only(
              top: lerpDouble(
                6.0,
                PlaybackHeroCardUiTuning.trackInfoLandscapeLyricsGap,
                simplifiedT,
              )!,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Align(
                alignment: titleAlignment,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onSecondaryTapDown: (details) {
                    _showTrackInfoContextMenu(
                      context,
                      details.globalPosition,
                      target: TrackInfoMenuTarget.artistAlbum,
                      currentMusic: currentMusic,
                    );
                  },
                  onLongPressStart: (details) {
                    _showTrackInfoContextMenu(
                      context,
                      details.globalPosition,
                      target: TrackInfoMenuTarget.artistAlbum,
                      currentMusic: currentMusic,
                    );
                  },
                  child: DefaultTextStyle(
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white70,
                      fontSize: artistSize,
                      height: lerpDouble(
                        lerpDouble(1.3, 1.1, transition),
                        lerpDouble(1.3, 1.25, transition),
                        landscapeT,
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        final style = DefaultTextStyle.of(context).style;
                        return MarqueeText(
                          text: hasArtist && hasAlbum
                              ? '$rawArtist — $rawAlbum'
                              : (hasArtist
                                    ? rawArtist
                                    : (hasAlbum ? rawAlbum : l10n.unknown)),
                          style: style,
                          alignment: titleAlignment,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (rightButtonsFactor > 0.0) {
      final playlistService = ref.watch(playlistServiceProvider);
      final songForIsFav = currentMusic;
      final isFavorite =
          songForIsFav != null && playlistService.isFavoriteSong(songForIsFav);
      final isRandomMode = ref.watch(audioIsRandomModeProvider);
      final sleepTimerRemaining = ref.watch(audioSleepTimerRemainingProvider);
      final playbackMode = ref.watch(audioPlaybackModeProvider);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: textContent),
          SizedBox(width: 8 * buttonControlsScale * rightButtonsFactor),
          if (sleepTimerRemaining != null) ...[
            Opacity(
              opacity: rightButtonsFactor,
              child: SizedBox(
                width: PlaybackHeroCardUiTuning.lLyricsSleepTimerButtonWidth *
                    buttonControlsScale *
                    rightButtonsFactor,
                height: PlaybackHeroCardUiTuning.lLyricsSleepTimerButtonHeight *
                    buttonControlsScale,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AppTooltip(
                    message: l10n.sleepTimerRemaining(
                      _formatSleepTimer(sleepTimerRemaining),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onSleepTimerTap,
                      child: SizedBox(
                        width: PlaybackHeroCardUiTuning.lLyricsSleepTimerButtonWidth *
                            buttonControlsScale,
                        height: PlaybackHeroCardUiTuning.lLyricsSleepTimerButtonHeight *
                            buttonControlsScale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bedtime_rounded,
                              size: PlaybackHeroCardUiTuning.lLyricsTitleIconSize *
                                  buttonControlsScale,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatSleepTimer(sleepTimerRemaining),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: PlaybackHeroCardUiTuning.lLyricsSleepTimerFontSize *
                                    buttonControlsScale,
                                height: 1.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * buttonControlsScale * rightButtonsFactor),
          ],
          if (showFavoriteIconButton) ...[
            Opacity(
              opacity: rightButtonsFactor,
              child: SizedBox(
                width: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                    buttonControlsScale *
                    rightButtonsFactor,
                height: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                    buttonControlsScale,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _buildLyricsHeaderRightButton(
                    context: context,
                    ref: ref,
                    l10n: l10n,
                    isFavorite: isFavorite,
                    currentMusic: currentMusic,
                    playlistService: playlistService,
                    playbackMode: playbackMode,
                    isRandomMode: isRandomMode,
                    showVisualizerToggle: showVisualizerToggle,
                    sleepTimerRemaining: sleepTimerRemaining,
                    buttonControlsScale: buttonControlsScale,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * buttonControlsScale * rightButtonsFactor),
          ],
          Opacity(
            opacity: rightButtonsFactor,
            child: SizedBox(
              width: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                  buttonControlsScale *
                  rightButtonsFactor,
              height: PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                  buttonControlsScale,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: PopupMenuButton<String>(
                  tooltip: l10n.more,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                    fixedSize: Size(
                      PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                          buttonControlsScale,
                      PlaybackHeroCardUiTuning.lLyricsTitleButtonHeight *
                          buttonControlsScale,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  icon: Icon(
                    Icons.more_horiz,
                    size: PlaybackHeroCardUiTuning.lLyricsTitleIconSize *
                        buttonControlsScale,
                    color: Colors.white70,
                  ),
                  onSelected: (value) async {
                    final audio = ref.read(audioServiceProvider);
                    switch (value) {
                      case 'favorite':
                        if (currentMusic != null) {
                          await playlistService.toggleFavoriteSong(currentMusic!);
                        }
                        break;
                      case 'settings':
                        onShowMoreMenu?.call();
                        break;
                      case 'visualizer':
                        onToggleVisualizer?.call();
                        break;
                      case 'random':
                        if (audio.settingsService.randomRange == 1 &&
                            !isRandomMode) {
                          final playlistService = ref.read(
                            playlistServiceProvider,
                          );
                          final List<MusicFile> allSongs = [];
                          final pathSet = <String>{};
                          for (final p in playlistService.playlists) {
                            for (final s in p.songs) {
                              if (pathSet.add(s.path)) allSongs.add(s);
                            }
                          }
                          audio.toggleRandomMode(globalSongs: allSongs);
                        } else {
                          audio.toggleRandomMode();
                        }
                        break;
                      case 'tag':
                        onTagCompletionTap?.call();
                        break;
                      case 'sleep':
                        onSleepTimerTap?.call();
                        break;
                      case 'effects':
                        onEqualizerTap?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    buildContextMenuItem<String>(
                      value: 'favorite',
                      label: isFavorite
                          ? l10n.removeFromFavorites
                          : l10n.addToFavorites,
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      context: context,
                      iconColor: isFavorite ? Colors.redAccent : null,
                    ),
                    buildContextMenuItem<String>(
                      value: 'settings',
                      label: l10n.visualizerSettings,
                      icon: Icons.settings_outlined,
                      context: context,
                    ),
                    buildContextMenuItem<String>(
                      value: 'visualizer',
                      label: l10n.visualizer,
                      icon: showVisualizerToggle
                          ? Icons.analytics
                          : Icons.analytics_outlined,
                      context: context,
                      iconColor: showVisualizerToggle
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    buildContextMenuItem<String>(
                      value: 'random',
                      label: l10n.randomMode,
                      icon: Icons.shuffle_rounded,
                      context: context,
                      iconColor: isRandomMode
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    buildContextMenuItem<String>(
                      value: 'tag',
                      label: l10n.tagCompletion,
                      icon: Icons.auto_fix_high_rounded,
                      context: context,
                      enabled: currentMusic != null,
                    ),
                    buildContextMenuItem<String>(
                      value: 'sleep',
                      label: sleepTimerRemaining != null
                          ? l10n.sleepTimerRemaining(
                              _formatSleepTimer(sleepTimerRemaining),
                            )
                          : l10n.sleepTimer,
                      icon: Icons.bedtime_rounded,
                      context: context,
                      iconColor: sleepTimerRemaining != null
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    buildContextMenuItem<String>(
                      value: 'effects',
                      label: l10n.effects,
                      icon: Icons.tune_rounded,
                      context: context,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return textContent;
  }
}
