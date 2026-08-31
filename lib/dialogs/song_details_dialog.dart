import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_core/audio_core.dart';
import 'package:path/path.dart' as p;
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/widgets/song_thumbnail.dart';
import 'package:vynody/l10n/app_localizations.dart';

Future<void> showSongDetailsDialog(BuildContext context, MusicFile song) async {
  await showDialog(
    context: context,
    builder: (dialogContext) {
      return _SongDetailsDialog(song: song);
    },
  );
}

class _SongDetailsDialog extends ConsumerStatefulWidget {
  const _SongDetailsDialog({required this.song});

  final MusicFile song;

  @override
  ConsumerState<_SongDetailsDialog> createState() => _SongDetailsDialogState();
}

class _SongDetailsDialogState extends ConsumerState<_SongDetailsDialog> {
  late final Future<AudioDetails> _detailsFuture;

  @override
  void initState() {
    super.initState();
    final audioService = ref.read(audioServiceProvider);
    _detailsFuture = _loadDetails(audioService);
  }

  Future<AudioDetails> _loadDetails(AudioService audioService) async {
    try {
      return await audioService.getAudioDetails(path: widget.song.path);
    } catch (_) {
      // Gracefully construct fallback audio details from existing MusicFile metadata
      var ext = p.extension(widget.song.path).replaceAll('.', '').toLowerCase();
      if (ext.contains('?')) ext = ext.split('?').first;
      if (ext.isEmpty) {
        ext = p.extension(widget.song.name).replaceAll('.', '').toLowerCase();
      }
      final formatName = ext.isNotEmpty ? ext : '';
      String codecName = formatName;
      if (formatName == 'mp3' || formatName == 'mpeg') {
        codecName = 'mp3';
      } else if (formatName == 'm4a' || formatName == 'mp4') {
        codecName = 'aac';
      }

      final duration = widget.song.durationMillis != null && widget.song.durationMillis! > 0
          ? Duration(milliseconds: widget.song.durationMillis!)
          : Duration.zero;

      int fileSize = 0;
      try {
        final localFile = File(widget.song.path);
        if (localFile.existsSync()) {
          fileSize = localFile.lengthSync();
        }
      } catch (_) {}

      return AudioDetails(
        formatName: formatName,
        codecName: codecName,
        duration: duration,
        bitrate: 0,
        sampleRate: 0,
        channels: 0,
        bitrateMode: '',
        fileSize: fileSize,
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '—';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  String _formatDuration(Duration duration) {
    if (duration <= Duration.zero) return '—';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatChannels(int channels, AppLocalizations l10n) {
    if (channels <= 0) return '—';
    if (channels == 1) {
      return l10n.detailMono;
    } else if (channels == 2) {
      return l10n.detailStereo;
    }
    return l10n.detailChannelsCount(channels);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.songProperties),
      content: SizedBox(
        width: 480,
        child: FutureBuilder<AudioDetails>(
          future: _detailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final details = snapshot.data;
            if (details == null) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    l10n.noPropertiesAvailable,
                  ),
                ),
              );
            }

            final isRemote = RemoteMediaResolver.isRemoteUri(widget.song.path);
            final isUncachedCloud = isRemote && details.bitrate == 0 && details.sampleRate == 0;

            final rows = [
              _DetailRow(
                label: l10n.detailFilePath,
                value: widget.song.path,
                selectable: true,
              ),
              _DetailRow(
                label: l10n.detailFormat,
                value: details.formatName.isNotEmpty ? details.formatName.toUpperCase() : '—',
              ),
              _DetailRow(
                label: l10n.detailCodec,
                value: details.codecName.isNotEmpty ? details.codecName.toUpperCase() : '—',
              ),
              _DetailRow(
                label: l10n.detailDuration,
                value: details.duration > Duration.zero ? _formatDuration(details.duration) : '—',
              ),
              _DetailRow(
                label: l10n.detailFileSize,
                value: details.fileSize > 0 ? _formatFileSize(details.fileSize) : '—',
              ),
              _DetailRow(
                label: l10n.detailBitrate,
                value: details.bitrate > 0 ? '${(details.bitrate / 1000).round()} kbps' : '—',
              ),
              _DetailRow(
                label: l10n.detailSampleRate,
                value: details.sampleRate > 0 ? '${details.sampleRate} Hz' : '—',
              ),
              _DetailRow(
                label: l10n.detailChannels,
                value: details.channels > 0 ? _formatChannels(details.channels, l10n) : '—',
              ),
              if (details.bitDepth != null && details.bitDepth! > 0)
                _DetailRow(
                  label: l10n.detailBitDepth,
                  value: '${details.bitDepth} bit',
                ),
            ];

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Song info header card
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: SongThumbnail(
                            path: widget.song.path,
                            id: widget.song.id,
                            size: 64,
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.song.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.song.artist ?? l10n.unknownArtist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.song.album ?? l10n.unknownAlbum,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Attributes table
                  ...rows,
                  if (isUncachedCloud) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.remoteAudioNotCachedHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: selectable
                ? SelectableText(
                    value,
                    style: theme.textTheme.bodyMedium,
                  )
                : Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
