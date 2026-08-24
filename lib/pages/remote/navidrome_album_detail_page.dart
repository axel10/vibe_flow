import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import '../../models/music_file.dart';
import '../../player/audio/audio_riverpod.dart';
import '../../player/remote/remote_server_models.dart';
import '../../player/remote/clients/subsonic_client.dart';
import '../../player/remote/proxy/remote_media_resolver.dart';
import '../../widgets/remote_artwork_widget.dart';

class NavidromeAlbumDetailPage extends ConsumerStatefulWidget {
  final RemoteServer server;
  final String password;
  final String albumId;
  final String albumName;
  final String? artistName;
  final String? coverArtId;

  const NavidromeAlbumDetailPage({
    super.key,
    required this.server,
    required this.password,
    required this.albumId,
    required this.albumName,
    this.artistName,
    this.coverArtId,
  });

  @override
  ConsumerState<NavidromeAlbumDetailPage> createState() =>
      _NavidromeAlbumDetailPageState();
}

class _NavidromeAlbumDetailPageState
    extends ConsumerState<NavidromeAlbumDetailPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _albumData;
  List<MusicFile> _tracks = [];

  @override
  void initState() {
    super.initState();
    _loadAlbumDetails();
  }

  Future<void> _loadAlbumDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = SubsonicClient(
        server: widget.server,
        password: widget.password,
      );
      final album = await client.getAlbum(widget.albumId);
      if (album == null) {
        setState(() {
          _error = 'Album details not found';
          _isLoading = false;
        });
        return;
      }

      final songList = album['song'] as List?;
      final List<MusicFile> parsedTracks = [];
      if (songList != null) {
        for (final item in songList) {
          if (item is Map<String, dynamic>) {
            parsedTracks.add(
              RemoteMediaResolver.buildMusicFileFromSubsonic(
                item,
                widget.server,
              ),
            );
          }
        }
      }

      setState(() {
        _albumData = album;
        _tracks = parsedTracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _playAll({bool shuffle = false}) async {
    if (_tracks.isEmpty) return;
    final audioService = ref.read(audioServiceProvider);
    final playlist = List<MusicFile>.from(_tracks);
    if (shuffle) {
      playlist.shuffle();
    }
    await audioService.playPlaylist(playlist);
    showToast('Playing ${_tracks.length} tracks');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final coverId = widget.coverArtId ?? _albumData?['coverArt'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albumName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadAlbumDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RemoteArtworkWidget(
                              server: widget.server,
                              password: widget.password,
                              coverArtId: coverId,
                              size: 130,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.albumName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.artistName ??
                                        _albumData?['artist'] ??
                                        'Unknown Artist',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_tracks.length} songs',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      FilledButton.icon(
                                        onPressed: () => _playAll(shuffle: false),
                                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                        label: const Text('Play All'),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton.filledTonal(
                                        onPressed: () => _playAll(shuffle: true),
                                        icon: const Icon(Icons.shuffle_rounded, size: 18),
                                        tooltip: 'Shuffle',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider(height: 1)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = _tracks[index];
                          final isPlaying = currentMusic?.path == song.path;
                          final trackNum = song.trackNumber ?? (index + 1);

                          return ListTile(
                            leading: SizedBox(
                              width: 32,
                              child: Center(
                                child: isPlaying
                                    ? Icon(
                                        Icons.volume_up_rounded,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      )
                                    : Text(
                                        '$trackNum',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                              ),
                            ),
                            title: Text(
                              song.title ?? song.name,
                              style: TextStyle(
                                fontWeight: isPlaying
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isPlaying
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: song.durationMillis != null
                                ? Text(
                                    _formatDuration(song.durationMillis!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                : null,
                            onTap: () async {
                              final audioService =
                                  ref.read(audioServiceProvider);
                              await audioService.playPlaylist(
                                _tracks,
                                initialIndex: index,
                              );
                            },
                          );
                        },
                        childCount: _tracks.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
    );
  }

  String _formatDuration(int millis) {
    final dur = Duration(milliseconds: millis);
    final m = dur.inMinutes;
    final s = dur.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
