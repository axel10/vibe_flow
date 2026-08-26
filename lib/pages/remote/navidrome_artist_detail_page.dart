import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';
import '../../models/music_file.dart';
import '../../player/audio/audio_riverpod.dart';
import '../../player/audio/playback_source.dart';
import '../../player/remote/remote_server_models.dart';
import '../../player/remote/clients/subsonic_client.dart';
import '../../player/remote/proxy/remote_media_resolver.dart';
import '../../widgets/remote_artwork_widget.dart';
import '../../widgets/desktop_window_title_bar.dart';
import '../../widgets/mini_player_wrapper.dart';
import '../../widgets/playing_equalizer_icon.dart';
import '../../l10n/app_localizations.dart';
import '../../player/remote/services/remote_download_service.dart';
import '../../utils/app_snack_bar.dart';
import '../../utils/remote_context_menu_utils.dart';
import 'navidrome_album_detail_page.dart';
import 'remote_download_manager_page.dart';

class NavidromeArtistDetailPage extends ConsumerWidget {
  final RemoteServer server;
  final String password;
  final String artistId;
  final String artistName;
  final String? coverArtId;
  final int? albumCount;

  const NavidromeArtistDetailPage({
    super.key,
    required this.server,
    required this.password,
    required this.artistId,
    required this.artistName,
    this.coverArtId,
    this.albumCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMacOS = Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    Widget content = Scaffold(
      appBar: AppBar(
        title: Text(artistName),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: ref.watch(activeDownloadsCountProvider) > 0,
              label: Text('${ref.watch(activeDownloadsCountProvider)}'),
              child: const Icon(Icons.download_rounded),
            ),
            tooltip: 'Download Manager',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RemoteDownloadManagerPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: NavidromeArtistDetailContent(
        server: server,
        password: password,
        artistId: artistId,
        artistName: artistName,
        coverArtId: coverArtId,
        albumCount: albumCount,
      ),
    );

    if (showCustomTitleBar || isMacOS) {
      content = Material(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            if (showCustomTitleBar)
              DesktopWindowTitleBar(brightness: theme.brightness)
            else
              const DragToMoveArea(child: SizedBox(height: 32)),
            Expanded(child: content),
          ],
        ),
      );
    }

    return MiniPlayerWrapper(child: content);
  }
}

class NavidromeArtistDetailContent extends ConsumerStatefulWidget {
  final RemoteServer server;
  final String password;
  final String artistId;
  final String artistName;
  final String? coverArtId;
  final int? albumCount;

  const NavidromeArtistDetailContent({
    super.key,
    required this.server,
    required this.password,
    required this.artistId,
    required this.artistName,
    this.coverArtId,
    this.albumCount,
  });

  @override
  ConsumerState<NavidromeArtistDetailContent> createState() =>
      _NavidromeArtistDetailContentState();
}

class _NavidromeAlbumSectionData {
  final String id;
  final String name;
  final String artist;
  final String? coverArt;
  final int? year;
  final int? songCount;
  final int? duration;
  final List<MusicFile> songs;

  _NavidromeAlbumSectionData({
    required this.id,
    required this.name,
    required this.artist,
    this.coverArt,
    this.year,
    this.songCount,
    this.duration,
    required this.songs,
  });
}

class _NavidromeArtistDetailContentState
    extends ConsumerState<NavidromeArtistDetailContent> {
  bool _isLoading = true;
  String? _error;
  List<_NavidromeAlbumSectionData> _albumSections = [];
  List<MusicFile> _allSongs = [];
  Map<String, dynamic>? _artistInfo;

  @override
  void initState() {
    super.initState();
    _loadArtistData();
  }

  @override
  void didUpdateWidget(NavidromeArtistDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artistId != widget.artistId ||
        oldWidget.server.id != widget.server.id) {
      _loadArtistData();
    }
  }

  Future<void> _loadArtistData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = SubsonicClient(
        server: widget.server,
        password: widget.password,
      );

      final artistMap = await client.getArtist(widget.artistId);
      if (artistMap == null) {
        setState(() {
          _error = 'Artist details not found on server';
          _isLoading = false;
        });
        return;
      }

      // Fetch artist bio / info if available
      client.getArtistInfo(widget.artistId).then((info) {
        if (mounted && info != null) {
          setState(() {
            _artistInfo = info;
          });
        }
      }).catchError((_) {});

      // Parse albums
      final dynamic rawAlbums = artistMap['album'];
      final List<Map<String, dynamic>> albumList = [];
      if (rawAlbums is List) {
        albumList.addAll(rawAlbums.whereType<Map<String, dynamic>>());
      } else if (rawAlbums is Map<String, dynamic>) {
        albumList.add(rawAlbums);
      }

      // If artist has songs directly (some Subsonic servers return directory format)
      final dynamic directSongs = artistMap['song'];
      final List<MusicFile> songsFromArtist = [];
      if (directSongs is List) {
        for (final s in directSongs) {
          if (s is Map<String, dynamic>) {
            songsFromArtist.add(
              RemoteMediaResolver.buildMusicFileFromSubsonic(s, widget.server),
            );
          }
        }
      }

      // Load songs for each album
      final List<_NavidromeAlbumSectionData> sections = [];
      final List<MusicFile> accumulatedSongs = [];

      if (albumList.isNotEmpty) {
        // Load details for albums concurrently
        final albumFutures = albumList.map((albumMeta) async {
          final albumId = albumMeta['id'] as String? ?? '';
          final title = albumMeta['title'] as String? ??
              albumMeta['name'] as String? ??
              'Untitled Album';
          final artist = albumMeta['artist'] as String? ?? widget.artistName;
          final coverArt = albumMeta['coverArt'] as String? ?? albumId;
          final year = albumMeta['year'] as int?;
          final songCount = albumMeta['songCount'] as int?;
          final duration = albumMeta['duration'] as int?;

          List<MusicFile> albumTracks = [];
          try {
            final fullAlbum = await client.getAlbum(albumId);
            final songData = fullAlbum?['song'] as List?;
            if (songData != null) {
              for (final s in songData) {
                if (s is Map<String, dynamic>) {
                  albumTracks.add(
                    RemoteMediaResolver.buildMusicFileFromSubsonic(
                      s,
                      widget.server,
                    ),
                  );
                }
              }
            }
          } catch (_) {}

          return _NavidromeAlbumSectionData(
            id: albumId,
            name: title,
            artist: artist,
            coverArt: coverArt,
            year: year,
            songCount: songCount ?? albumTracks.length,
            duration: duration,
            songs: albumTracks,
          );
        }).toList();

        final loadedSections = await Future.wait(albumFutures);
        for (final sec in loadedSections) {
          sections.add(sec);
          accumulatedSongs.addAll(sec.songs);
        }
      } else if (songsFromArtist.isNotEmpty) {
        // Group songs by album if albums array wasn't provided directly
        final Map<String, List<MusicFile>> byAlbum = {};
        for (final song in songsFromArtist) {
          final albumName = song.album ?? 'Singles';
          byAlbum.putIfAbsent(albumName, () => []).add(song);
        }
        byAlbum.forEach((albumName, sList) {
          sections.add(
            _NavidromeAlbumSectionData(
              id: widget.artistId,
              name: albumName,
              artist: widget.artistName,
              coverArt: widget.coverArtId,
              songCount: sList.length,
              songs: sList,
            ),
          );
          accumulatedSongs.addAll(sList);
        });
      }

      setState(() {
        _albumSections = sections;
        _allSongs = accumulatedSongs;
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
    if (_allSongs.isEmpty) {
      showToast('No tracks found for this artist');
      return;
    }
    final audio = ref.read(audioServiceProvider);
    final playlist = List<MusicFile>.from(_allSongs);
    if (shuffle) {
      playlist.shuffle();
    }
    await audio.playPlaylist(
      playlist,
      source: PlaybackSource(
        type: PlaybackSourceType.artist,
        id: 'remote-${widget.server.id}-${widget.artistId}',
        name: widget.artistName,
      ),
    );
    showToast('Playing ${_allSongs.length} tracks');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final headerColor = theme.colorScheme.tertiaryContainer.withValues(
      alpha: 0.65,
    );

    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Error: $_error',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadArtistData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final totalSongCount = _allSongs.isNotEmpty
        ? _allSongs.length
        : _albumSections.fold<int>(0, (sum, sec) => sum + (sec.songCount ?? 0));
    final totalAlbumCount = widget.albumCount ?? _albumSections.length;
    final biography = _artistInfo?['biography'] as String?;

    return RefreshIndicator(
      onRefresh: _loadArtistData,
      child: CustomScrollView(
        slivers: [
          // Artist Header (Styled similarly to local ArtistDetailContent)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [headerColor, theme.colorScheme.surface],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ARTIST',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.artistName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(label: '$totalAlbumCount albums'),
                      if (totalSongCount > 0)
                        _InfoChip(label: '$totalSongCount songs'),
                    ],
                  ),
                  if (biography != null && biography.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      biography.trim(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: _allSongs.isNotEmpty ? () => _playAll(shuffle: false) : null,
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text('Play All'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _allSongs.isNotEmpty ? () => _playAll(shuffle: true) : null,
                        icon: const Icon(Icons.shuffle_rounded, size: 18),
                        label: const Text('Shuffle'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _allSongs.isNotEmpty
                            ? () async {
                                final l10n = AppLocalizations.of(context)!;
                                final notifier = ref.read(
                                    remoteDownloadTasksProvider.notifier);
                                await notifier.enqueueSubsonicTracks(
                                  server: widget.server,
                                  password: widget.password,
                                  songs: _allSongs,
                                  collectionName: widget.artistName,
                                );
                                if (context.mounted) {
                                  AppSnackBar.show(
                                    context,
                                    ref,
                                    SnackBar(
                                      content: Text(
                                        l10n.batchAddedToDownloadQueue(
                                            _allSongs.length),
                                      ),
                                      action: SnackBarAction(
                                        label: l10n.viewDownloadProgress,
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RemoteDownloadManagerPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Download'),
                      ),
                      IconButton.outlined(
                        tooltip: 'Star / Favorite',
                        icon: const Icon(Icons.favorite_border_rounded, size: 18),
                        onPressed: () async {
                          final client = SubsonicClient(
                            server: widget.server,
                            password: widget.password,
                          );
                          final ok = await client.star(artistId: widget.artistId);
                          showToast(ok ? 'Added to favorites' : 'Star failed');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_albumSections.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No albums found for this artist',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else ...[
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            for (int i = 0; i < _albumSections.length; i++) ...[
              if (i > 0) const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildAlbumSection(theme, _albumSections[i], currentMusic),
            ],
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildAlbumSection(
    ThemeData theme,
    _NavidromeAlbumSectionData section,
    MusicFile? currentMusic,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section Header
              GestureDetector(
                onSecondaryTapDown: (details) {
                  showRemoteAlbumContextMenu(
                    context: context,
                    globalPosition: details.globalPosition,
                    ref: ref,
                    server: widget.server,
                    password: widget.password,
                    albumId: section.id,
                    albumTitle: section.name,
                    artistName: section.artist,
                    coverArtId: section.coverArt,
                    songs: section.songs,
                    onViewDetails: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NavidromeAlbumDetailPage(
                            server: widget.server,
                            password: widget.password,
                            albumId: section.id,
                            albumName: section.name,
                            artistName: section.artist,
                            coverArtId: section.coverArt,
                          ),
                        ),
                      );
                    },
                  );
                },
                onLongPress: () {
                  final renderBox = context.findRenderObject() as RenderBox?;
                  final offset = renderBox != null
                      ? renderBox.localToGlobal(Offset.zero)
                      : Offset.zero;
                  showRemoteAlbumContextMenu(
                    context: context,
                    globalPosition: offset,
                    ref: ref,
                    server: widget.server,
                    password: widget.password,
                    albumId: section.id,
                    albumTitle: section.name,
                    artistName: section.artist,
                    coverArtId: section.coverArt,
                    songs: section.songs,
                    onViewDetails: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NavidromeAlbumDetailPage(
                            server: widget.server,
                            password: widget.password,
                            albumId: section.id,
                            albumName: section.name,
                            artistName: section.artist,
                            coverArtId: section.coverArt,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NavidromeAlbumDetailPage(
                          server: widget.server,
                          password: widget.password,
                          albumId: section.id,
                          albumName: section.name,
                          artistName: section.artist,
                          coverArtId: section.coverArt,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        RemoteArtworkWidget(
                          server: widget.server,
                          password: widget.password,
                          coverArtId: section.coverArt,
                          size: 52,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                [
                                  if (section.year != null && section.year! > 0)
                                    '${section.year}',
                                  '${section.songs.length} tracks',
                                ].join(' • '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Play Album',
                          icon: Icon(
                            Icons.play_circle_filled_rounded,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: section.songs.isNotEmpty
                              ? () async {
                                  final audio = ref.read(audioServiceProvider);
                                  await audio.playPlaylist(
                                    section.songs,
                                    source: PlaybackSource(
                                      type: PlaybackSourceType.album,
                                      id: 'remote-${widget.server.id}-${section.id}',
                                      name: section.name,
                                    ),
                                  );
                                }
                              : null,
                        ),
                        IconButton(
                          tooltip: 'Shuffle Album',
                          icon: const Icon(Icons.shuffle_rounded, size: 20),
                          onPressed: section.songs.isNotEmpty
                              ? () async {
                                  final audio = ref.read(audioServiceProvider);
                                  await audio.playPlaylist(
                                    List.of(section.songs)..shuffle(),
                                    source: PlaybackSource(
                                      type: PlaybackSourceType.album,
                                      id: 'remote-${widget.server.id}-${section.id}',
                                      name: section.name,
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (section.songs.isNotEmpty) const Divider(height: 1),

              // Track items
              for (int j = 0; j < section.songs.length; j++) ...[
                _buildSongItem(
                  theme,
                  section.songs[j],
                  j + 1,
                  section.songs,
                  j,
                  currentMusic,
                  albumSection: section,
                  isLast: j == section.songs.length - 1,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongItem(
    ThemeData theme,
    MusicFile song,
    int trackNum,
    List<MusicFile> playlist,
    int initialIndex,
    MusicFile? currentMusic, {
    _NavidromeAlbumSectionData? albumSection,
    bool isLast = false,
  }) {
    final isPlaying = currentMusic?.path == song.path;
    final isAudioPlaying = ref.watch(audioIsPlayingProvider);
    final trackLabel = '$trackNum'.padLeft(2, '0');
    final durationLabel = song.durationMillis != null && song.durationMillis! > 0
        ? _formatDuration(song.durationMillis!)
        : null;
    final borderRadius = isLast
        ? const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : null;

    void openContextMenu(Offset position) {
      showRemoteSongContextMenu(
        context: context,
        globalPosition: position,
        ref: ref,
        server: widget.server,
        password: widget.password,
        song: song,
        playlist: playlist,
        onViewAlbum: albumSection != null
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NavidromeAlbumDetailPage(
                      server: widget.server,
                      password: widget.password,
                      albumId: albumSection.id,
                      albumName: albumSection.name,
                      artistName: albumSection.artist,
                      coverArtId: albumSection.coverArt,
                    ),
                  ),
                );
              }
            : null,
      );
    }

    return GestureDetector(
      onSecondaryTapDown: (details) => openContextMenu(details.globalPosition),
      onLongPress: () {
        final renderBox = context.findRenderObject() as RenderBox?;
        final offset = renderBox != null
            ? renderBox.localToGlobal(Offset.zero)
            : Offset.zero;
        openContextMenu(offset);
      },
      child: Material(
        color: isPlaying
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () async {
            final audio = ref.read(audioServiceProvider);
            await audio.playPlaylist(
              playlist,
              initialIndex: initialIndex,
              source: PlaybackSource(
                type: PlaybackSourceType.artist,
                id: 'remote-${widget.server.id}-${widget.artistId}',
                name: widget.artistName,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Center(
                    child: isPlaying
                        ? PlayingEqualizerIcon(
                            color: theme.colorScheme.primary,
                            size: 16,
                            isPlaying: isAudioPlaying,
                          )
                        : Text(
                            trackLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    song.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isPlaying ? theme.colorScheme.primary : null,
                      fontWeight: isPlaying ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                if (durationLabel != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    durationLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () {
                    final renderBox = context.findRenderObject() as RenderBox?;
                    final offset = renderBox != null
                        ? renderBox.localToGlobal(Offset.zero)
                        : Offset.zero;
                    openContextMenu(offset);
                  },
                ),
              ],
            ),
          ),
        ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
