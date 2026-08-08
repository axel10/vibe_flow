import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

String formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, "0")}';
}

IconData getPlaylistModeIcon(AppPlaybackMode mode) {
  switch (mode) {
    case AppPlaybackMode.single:
      return Icons.looks_one_outlined;
    case AppPlaybackMode.singleLoop:
      return Icons.repeat_one_rounded;
    case AppPlaybackMode.queue:
      return Icons.reorder_rounded;
    case AppPlaybackMode.queueLoop:
      return Icons.repeat_rounded;
    case AppPlaybackMode.autoQueueLoop:
      return Icons.all_inclusive_rounded;
  }
}

String getPlaylistModeName(AppPlaybackMode mode, AppLocalizations l10n) {
  switch (mode) {
    case AppPlaybackMode.single:
      return l10n.playlistModeSingle;
    case AppPlaybackMode.singleLoop:
      return l10n.playlistModeSingleLoop;
    case AppPlaybackMode.queue:
      return l10n.playlistModeQueue;
    case AppPlaybackMode.queueLoop:
      return l10n.playlistModeQueueLoop;
    case AppPlaybackMode.autoQueueLoop:
      return l10n.playlistModeAutoQueueLoop;
  }
}

IconData getVolumeIcon(double volume, {bool isMuted = false}) {
  if (isMuted) return Icons.volume_off;
  if (volume <= 0) return Icons.volume_mute;
  if (volume < 75) return Icons.volume_down;
  return Icons.volume_up;
}
