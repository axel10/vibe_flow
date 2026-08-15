import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/sharing/lan_device.dart';
import 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
import 'package:vynody/player/sharing/remote_control/remote_playback_model.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/player/sharing/sharing_service.dart';
import 'package:vynody/pages/remote_control_page.dart';
import 'package:vynody/l10n/app_localizations.dart';

void showRemoteControlSheet(BuildContext context, LanDevice device) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => RemoteControlPage(device: device),
    ),
  );
}

class _RemoteControlSheetContent extends ConsumerStatefulWidget {
  final LanDevice device;

  const _RemoteControlSheetContent({required this.device});

  @override
  ConsumerState<_RemoteControlSheetContent> createState() =>
      _RemoteControlSheetContentState();
}

class _RemoteControlSheetContentState
    extends ConsumerState<_RemoteControlSheetContent> {
  double? _draggingSliderValue;

  String _formatDuration(int milliseconds) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final remoteService = ref.watch(remoteControlServiceProvider);
    final remoteState = ref.watch(remotePlaybackStateProvider);
    final activeDevice = ref.watch(activeControllingDeviceProvider);

    final isConnected = activeDevice != null;
    final state = remoteState ?? const RemotePlaybackState();

    final currentPositionMs = state.positionMs;
    final totalDurationMs = state.durationMs > 0 ? state.durationMs : 1;
    final sliderMax = totalDurationMs.toDouble();
    final sliderValue = (_draggingSliderValue ?? currentPositionMs.toDouble())
        .clamp(0.0, sliderMax);
    final hasTrack = state.title.isNotEmpty;
    final coverUrl = hasTrack
        ? 'http://${formatHostForUrl(widget.device.ip)}:${widget.device.httpPort}/api/remote/cover?t=${Uri.encodeComponent(state.title)}_${Uri.encodeComponent(state.artist)}'
        : '';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header: Device Info & Disconnect Button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
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
                      children: [
                        Text(
                          widget.device.name,
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
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isConnected ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isConnected
                                  ? l10n.remoteConnected
                                  : l10n.remoteConnecting,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
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

              const SizedBox(height: 24),

              // Song Info Card / Visual representation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: theme.brightness == Brightness.dark
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.tertiary.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: hasTrack
                            ? Image.network(
                                coverUrl,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Icon(
                                    Icons.music_note_rounded,
                                    size: 44,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(
                                  Icons.music_note_rounded,
                                  size: 44,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const SizedBox(width: 44), // Balances the favorite button on the right
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                state.title.isNotEmpty ? state.title : l10n.noMusicPlaying,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.artist.isNotEmpty
                                    ? state.artist
                                    : (state.title.isNotEmpty ? l10n.unknownArtist : '--'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Progress Bar
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
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
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _formatDuration(state.durationMs),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Control Buttons Row (5 buttons, perfectly centered)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Playback Mode Button
                  IconButton(
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
                    iconSize: 32,
                    icon: const Icon(Icons.skip_previous_rounded),
                    tooltip: l10n.previousSong,
                    onPressed: remoteService.previous,
                  ),

                  // Play / Pause Large Button (Centered)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      iconSize: 42,
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
                    iconSize: 32,
                    icon: const Icon(Icons.skip_next_rounded),
                    tooltip: l10n.nextSong,
                    onPressed: remoteService.next,
                  ),

                  // Random / Shuffle Mode Button
                  IconButton(
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
            ],
          ),
        ),
      ),
    );
  }
}
