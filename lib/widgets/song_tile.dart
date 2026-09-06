import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/widgets/song_thumbnail.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/widgets/playing_equalizer_icon.dart';

class SongTile extends ConsumerWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.isCurrent,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.isHighlighted = false,
    this.dragHandle,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTapDown,
    this.onMorePressed,
  });

  final MusicFile song;
  final bool isCurrent;
  final bool isSelected;
  final bool isSelectionMode;
  final bool isHighlighted;
  final Widget? dragHandle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final void Function(TapDownDetails details)? onSecondaryTapDown;
  final void Function(BuildContext context)? onMorePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final metadata = ref.watch(
      scannerServiceProvider.select((s) => s.metadataMap[song.path]),
    );
    final isPlaying = ref.watch(audioIsPlayingProvider);
    
    final isMissing = song.isMissing;
    
    // Resolve metadata (artist and album)
    final artist = metadata?.artist ?? song.artist ?? l10n.unknownArtist;
    final album = metadata?.album ?? song.album ?? l10n.unknownAlbum;
    final artistAlbumText = '$artist - $album';

    // Format track number, duration and file format
    final trackNumber = metadata?.trackNumber ?? song.trackNumber;
    final trackStr = (trackNumber != null && trackNumber > 0)
        ? trackNumber.toString().padLeft(2, '0')
        : null;
    final durationStr = _formatDuration(metadata?.duration ?? song.durationMillis);
    final ext = p.extension(song.path).replaceAll('.', '').toUpperCase();
    final formatStr = ext.isNotEmpty ? ext : 'UNKNOWN';
    final durationFormatText = [
      ?trackStr,
      durationStr,
      formatStr,
    ].join(' | ');

    // Build leading widget (thumbnail + selection checkbox)
    final leadingWidget = SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: isMissing
                ? 0.35
                : isSelectionMode
                    ? (isSelected ? 0.5 : 0.7)
                    : 1.0,
            child: SongThumbnail(
              path: song.path,
              id: song.id,
              thumbnailPath: song.thumbnailPath,
              artworkPath: song.artworkPath,
              bytes: song.artworkBytes,
              size: 56.0,
            ),
          ),
          if (isSelectionMode)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap?.call(),
                    fillColor: WidgetStateProperty.all(Colors.white),
                    checkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Build trailing widget (more button or drag handle)
    Widget? trailingWidget;
    if (isSelectionMode) {
      if (dragHandle != null) {
        trailingWidget = IconTheme(
          data: theme.iconTheme.copyWith(
            color: isCurrent && !isMissing
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          child: dragHandle!,
        );
      }
    } else {
      trailingWidget = Builder(
        builder: (buttonContext) {
          return IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: isCurrent && !isMissing
                  ? theme.colorScheme.primary
                  : null,
            ),
            onPressed: onMorePressed != null
                ? () => onMorePressed!(buttonContext)
                : null,
          );
        },
      );
    }

    // Colors
    final textColor = isMissing
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.55)
        : isCurrent
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: onSecondaryTapDown,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelectionMode && isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
              : isHighlighted
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            enableFeedback: false,
            onTap: onTap,
            onLongPress: onLongPress,
            hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).orientation == Orientation.portrait ? 12 : 16,
                vertical: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  leadingWidget,
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  if (isCurrent && !isMissing) ...[
                                    PlayingEqualizerIcon(
                                      color: theme.colorScheme.primary,
                                      size: 16,
                                      isPlaying: isPlaying,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Expanded(
                                    child: Text(
                                      song.displayName,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: textColor,
                                        fontWeight: isCurrent && !isMissing ? FontWeight.bold : FontWeight.normal,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                artistAlbumText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  height: 1.2,
                                  color: isMissing
                                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                                      : isCurrent
                                          ? theme.colorScheme.primary.withValues(alpha: 0.8)
                                          : theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Text(
                            durationFormatText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              height: 1.2,
                              color: isMissing
                                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                                  : isCurrent
                                      ? theme.colorScheme.primary.withValues(alpha: 0.6)
                                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (trailingWidget != null) ...[
                    const SizedBox(width: 16),
                    trailingWidget,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int? durationMs) {
    if (durationMs == null) return '--:--';
    final duration = Duration(milliseconds: durationMs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
