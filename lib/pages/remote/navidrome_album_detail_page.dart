import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';
import '../../models/music_file.dart';
import '../../player/audio/audio_riverpod.dart';
import '../../player/audio/playback_source.dart';
import '../../player/remote/remote_server_models.dart';
import '../../player/remote/remote_server_riverpod.dart';
import '../../player/remote/clients/subsonic_client.dart';
import '../../player/remote/proxy/remote_media_resolver.dart';
import '../../widgets/remote_artwork_widget.dart';
import '../../widgets/desktop_window_title_bar.dart';
import '../../widgets/mini_player_wrapper.dart';
import '../../widgets/playing_equalizer_icon.dart';
import '../../dialogs/remote_playlist_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../../player/remote/services/remote_download_service.dart';
import '../../player/remote/navidrome_navigation.dart';
import '../../utils/app_snack_bar.dart';
import '../../utils/layout_constants.dart';
import '../../utils/remote_context_menu_utils.dart';
import '../../widgets/library_selection_panel.dart';
import '../../widgets/library_selection_scope.dart';
import 'remote_download_manager_page.dart';
import '../../utils/song_locator_helper.dart';

class NavidromeAlbumDetailPage extends ConsumerStatefulWidget {
  final RemoteServer server;
  final String password;
  final String albumId;
  final String albumName;
  final String? artistName;
  final String? coverArtId;
  final String? highlightedSongPath;

  const NavidromeAlbumDetailPage({
    super.key,
    required this.server,
    required this.password,
    required this.albumId,
    required this.albumName,
    this.artistName,
    this.coverArtId,
    this.highlightedSongPath,
  });

  @override
  ConsumerState<NavidromeAlbumDetailPage> createState() =>
      _NavidromeAlbumDetailPageState();
}

class _NavidromeAlbumDetailPageState
    extends ConsumerState<NavidromeAlbumDetailPage>
    with SongSelectionMixin {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _albumData;
  List<MusicFile> _tracks = [];
  bool _isStarred = false;
  final ScrollController _scrollController = ScrollController();
  bool _isCoverVisible = true;
  String? _highlightedSongPath;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.highlightedSongPath != null) {
      _highlightedSongPath = widget.highlightedSongPath;
    }
    _loadAlbumDetails();
  }

  @override
  void didUpdateWidget(NavidromeAlbumDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedSongPath != null &&
        widget.highlightedSongPath != oldWidget.highlightedSongPath) {
      _scrollToTrack(widget.highlightedSongPath!);
    }
  }

  void _onScroll() {
    final isVisible = _scrollController.offset < 200.0;
    if (isVisible != _isCoverVisible) {
      setState(() {
        _isCoverVisible = isVisible;
      });
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTrack(String songPath) {
    if (!mounted || _tracks.isEmpty) return;
    final index = _tracks.indexWhere((t) => t.path == songPath);
    if (index == -1) return;

    setState(() {
      _highlightedSongPath = songPath;
    });
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _highlightedSongPath = null;
        });
      }
    });

    if (_scrollController.hasClients) {
      final double headerEstimatedHeight = 280.0;
      final double trackHeight = 52.0;
      final double itemOffset = headerEstimatedHeight + index * trackHeight;
      final double viewportHeight = _scrollController.position.viewportDimension;
      double targetOffset = itemOffset - (viewportHeight / 2) + (trackHeight / 2);
      final maxScroll = _scrollController.position.maxScrollExtent;
      targetOffset = targetOffset.clamp(0.0, maxScroll);
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _locateCurrentSong() async {
    final currentMusic = ref.read(audioCurrentMusicProvider);
    if (currentMusic == null) return;

    final inCurrentAlbum = _tracks.any((t) => t.path == currentMusic.path);
    if (inCurrentAlbum) {
      _scrollToTrack(currentMusic.path);
      return;
    }

    await SongLocatorHelper.locateCurrentPlayingSong(ref, context);
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
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.albumNotFound;
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

      final isStarred = album['starred'] != null;
      if (!mounted) return;
      setState(() {
        _albumData = album;
        _tracks = parsedTracks;
        _isStarred = isStarred;
        _isLoading = false;
      });

      if (_highlightedSongPath != null) {
        final targetPath = _highlightedSongPath!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToTrack(targetPath);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _playAll({bool shuffle = false}) async {
    if (_tracks.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final audioService = ref.read(audioServiceProvider);
    final playlist = List<MusicFile>.from(_tracks);
    if (shuffle) {
      playlist.shuffle();
    }
    await audioService.playPlaylist(
      playlist,
      source: PlaybackSource(
        type: PlaybackSourceType.album,
        id: 'remote-${widget.server.id}-${widget.albumId}',
        name: widget.albumName,
      ),
    );
    showToast(l10n.playingTracksCount(_tracks.length));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final coverId = widget.coverArtId ?? _albumData?['coverArt'] as String?;
    final artist = widget.artistName ??
        _albumData?['artist'] as String? ??
        l10n.unknownArtist;
    final year = _albumData?['year'] as int?;
    final genre = _albumData?['genre'] as String?;
    final headerColor = theme.colorScheme.secondaryContainer.withValues(
      alpha: 0.65,
    );

    final isMacOS = Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final bottomOffset = MiniPlayerUiTuning.getListBottomPadding(
      context,
      hasPlayingMusic: currentMusic != null,
      isSelectionMode: isSelectionMode,
      selectionPanelHeight: 220.0,
    );
    final selectedSongs = getSelectedSongs(_tracks);

    final albumTitle = (widget.albumName.isNotEmpty && widget.albumName != 'Untitled')
        ? widget.albumName
        : (_albumData?['name'] as String? ??
            _albumData?['title'] as String? ??
            widget.albumName);

    Widget content = Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isCoverVisible
              ? const SizedBox.shrink()
              : Text(
                  albumTitle,
                  key: const ValueKey('album_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            tooltip: l10n.locateCurrentSong,
            onPressed: _locateCurrentSong,
          ),
          Consumer(
            builder: (context, ref, child) {
              final activeCount = ref.watch(activeDownloadsCountProvider);
              return IconButton(
                icon: Badge(
                  isLabelVisible: activeCount > 0,
                  label: Text('$activeCount'),
                  child: const Icon(Icons.download_rounded),
                ),
                tooltip: l10n.downloadManager,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => const RemoteDownloadManagerPage(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            )
          : _error != null
              ? Center(
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
                        Text(l10n.errorWithMessage(_error!), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _loadAlbumDetails,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Positioned.fill(
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // Header Container
                          SliverToBoxAdapter(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [headerColor, theme.colorScheme.surface],
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: kSingleColumnContentMaxWidth),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isWide = constraints.maxWidth >= 700;
                                        final cover = RemoteArtworkWidget(
                                          server: widget.server,
                                          password: widget.password,
                                          coverArtId: coverId,
                                          size: isWide
                                              ? 200
                                              : math.min(200, constraints.maxWidth),
                                          borderRadius: BorderRadius.circular(16),
                                        );
                                        final info = _buildAlbumInfo(
                                          theme,
                                          albumTitle,
                                          artist,
                                          year,
                                          genre,
                                        );

                                        if (isWide) {
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              cover,
                                              const SizedBox(width: 24),
                                              Expanded(child: info),
                                            ],
                                          );
                                        }

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Center(child: cover),
                                            const SizedBox(height: 20),
                                            info,
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 8)),

                          // Track List
                          SliverFixedExtentList.builder(
                            itemExtent: 52.0,
                            itemCount: _tracks.length,
                            itemBuilder: (context, index) {
                              final song = _tracks[index];
                              final isPlaying = currentMusic?.path == song.path;
                              final isHighlighted = _highlightedSongPath == song.path;
                              final isAudioPlaying = ref.watch(audioIsPlayingProvider);
                              final isSelected = isSongSelected(song.path);
                              final trackNum = song.trackNumber ?? (index + 1);
                              final trackLabel = '$trackNum'.padLeft(2, '0');
                              final durationLabel = song.durationMillis != null &&
                                      song.durationMillis! > 0
                                  ? _formatDuration(song.durationMillis!)
                                  : null;

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onSecondaryTapDown: (details) {
                                  if (!isSelectionMode) {
                                    showRemoteSongContextMenu(
                                      context: context,
                                      globalPosition: details.globalPosition,
                                      ref: ref,
                                      server: widget.server,
                                      password: widget.password,
                                      song: song,
                                      playlist: _tracks,
                                      onViewArtist: () {
                                        if (song.artist != null && song.artist!.isNotEmpty) {
                                          NavidromeNavUtils.openArtist(
                                            context,
                                            ref,
                                            server: widget.server,
                                            password: widget.password,
                                            artistId: '',
                                            artistName: song.artist!,
                                          );
                                        }
                                      },
                                    );
                                  }
                                },
                                onLongPressStart: (details) {
                                  lastAnchorIndex = index;
                                  if (!isSelectionMode) {
                                    enterSongSelectionMode(song.path);
                                  } else {
                                    toggleSongSelection(song.path);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: isSelectionMode && isSelected
                                        ? theme.colorScheme.primaryContainer
                                            .withValues(alpha: 0.35)
                                        : (isHighlighted
                                            ? theme.colorScheme.primaryContainer
                                                .withValues(alpha: 0.6)
                                            : (isPlaying
                                                ? theme.colorScheme.primaryContainer
                                                    .withValues(alpha: 0.35)
                                                : Colors.transparent)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        handleSongTap(
                                          index: index,
                                          songPath: song.path,
                                          allSongs: _tracks,
                                          onNormalTap: () async {
                                            final audioService =
                                                ref.read(audioServiceProvider);
                                            await audioService.playPlaylist(
                                              _tracks,
                                              initialIndex: index,
                                              source: PlaybackSource(
                                                type: PlaybackSourceType.album,
                                                id: 'remote-${widget.server.id}-${widget.albumId}',
                                                name: widget.albumName,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: ConstrainedBox(
                                          constraints:
                                              const BoxConstraints(maxWidth: kSingleColumnContentMaxWidth),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: _tracks.length >= 100 ? 40 : 32,
                                                  child: Center(
                                                    child: isSelectionMode
                                                        ? Checkbox(
                                                            value: isSelected,
                                                            onChanged: (_) =>
                                                                toggleSongSelection(
                                                              song.path,
                                                            ),
                                                          )
                                                        : (isPlaying
                                                            ? PlayingEqualizerIcon(
                                                                color:
                                                                    theme.colorScheme.primary,
                                                                size: 16,
                                                                isPlaying: isAudioPlaying,
                                                              )
                                                            : FittedBox(
                                                                fit: BoxFit.scaleDown,
                                                                child: Text(
                                                                  trackLabel,
                                                                  textAlign: TextAlign.center,
                                                                  style: theme
                                                                      .textTheme.bodyMedium
                                                                      ?.copyWith(
                                                                    color: isHighlighted
                                                                        ? theme.colorScheme.primary
                                                                        : theme.colorScheme
                                                                            .onSurfaceVariant,
                                                                    fontWeight:
                                                                        FontWeight.w600,
                                                                  ),
                                                                ),
                                                              )),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    song.displayName,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.bodyLarge
                                                        ?.copyWith(
                                                      color: (isPlaying || isHighlighted)
                                                          ? theme.colorScheme.primary
                                                          : null,
                                                      fontWeight: (isPlaying || isHighlighted)
                                                          ? FontWeight.w700
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                                if (durationLabel != null) ...[
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    durationLabel,
                                                  style: theme.textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                              if (!isSelectionMode) ...[
                                                const SizedBox(width: 4),
                                                Builder(
                                                  builder: (btnContext) => IconButton(
                                                    icon: const Icon(Icons.more_vert_rounded, size: 18),
                                                    visualDensity: VisualDensity.compact,
                                                    padding: EdgeInsets.zero,
                                                    splashRadius: 18,
                                                    onPressed: () {
                                                      final renderBox = btnContext
                                                          .findRenderObject() as RenderBox?;
                                                      if (renderBox != null) {
                                                        final position = renderBox
                                                            .localToGlobal(Offset.zero);
                                                        final size = renderBox.size;
                                                        showRemoteSongContextMenu(
                                                          context: context,
                                                          globalPosition: position +
                                                              Offset(
                                                                size.width / 2,
                                                                size.height,
                                                              ),
                                                          ref: ref,
                                                          server: widget.server,
                                                          password: widget.password,
                                                          song: song,
                                                          playlist: _tracks,
                                                          onViewArtist: () {
                                                            if (song.artist != null &&
                                                                song.artist!.isNotEmpty) {
                                                              NavidromeNavUtils.openArtist(
                                                                context,
                                                                ref,
                                                                server: widget.server,
                                                                password: widget.password,
                                                                artistId: '',
                                                                artistName: song.artist!,
                                                              );
                                                            }
                                                          },
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: bottomOffset)),
                        ],
                      ),
                    ),
                    AnimatedSelectionPanel(
                      isVisible: isSelectionMode,
                      child: LibrarySelectionPanel(
                        key: const ValueKey('navidrome-album-selection-panel'),
                        selectedSongs: selectedSongs,
                        allSongs: _tracks,
                        onToggleSelectAll: () => toggleSelectAllSongs(_tracks),
                        onCancel: cancelSongSelection,
                        onDownload: () async {
                          final sel = List<MusicFile>.from(selectedSongs);
                          if (sel.isEmpty) return;
                          final notifier =
                              ref.read(remoteDownloadTasksProvider.notifier);
                          await notifier.enqueueSubsonicTracks(
                            server: widget.server,
                            password: widget.password,
                            songs: sel,
                            collectionName: widget.albumName,
                          );
                          cancelSongSelection();
                          if (context.mounted) {
                            AppSnackBar.show(
                              context,
                              ref,
                              SnackBar(
                                content: Text(
                                  l10n.batchAddedToDownloadQueue(sel.length),
                                ),
                                action: SnackBarAction(
                                  label: l10n.viewDownloadProgress,
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .push(
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
                        },
                      ),
                    ),
                  ],
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

  Widget _buildAlbumInfo(
    ThemeData theme,
    String albumTitle,
    String artist,
    int? year,
    String? genre,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.albumLabel.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          albumTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          artist,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(label: l10n.songCount(_tracks.length)),
            if (year != null && year > 0) _InfoChip(label: '$year'),
            if (genre != null && genre.isNotEmpty) _InfoChip(label: genre),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: _tracks.isNotEmpty ? () => _playAll(shuffle: false) : null,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(l10n.playAll),
            ),
            OutlinedButton.icon(
              onPressed: _tracks.isNotEmpty ? () => _playAll(shuffle: true) : null,
              icon: const Icon(Icons.shuffle_rounded, size: 18),
              label: Text(l10n.shufflePlay),
            ),
            OutlinedButton.icon(
              onPressed: _tracks.isNotEmpty
                  ? () => RemoteAddToPlaylistDialog.show(
                        context,
                        ref: ref,
                        server: widget.server,
                        password: widget.password,
                        songs: _tracks,
                      )
                  : null,
              icon: const Icon(Icons.playlist_add_rounded, size: 18),
              label: Text(l10n.addToPlaylist),
            ),
            OutlinedButton.icon(
              onPressed: _tracks.isNotEmpty
                  ? () async {
                      final notifier =
                          ref.read(remoteDownloadTasksProvider.notifier);
                      await notifier.enqueueSubsonicTracks(
                        server: widget.server,
                        password: widget.password,
                        songs: _tracks,
                        collectionName: widget.albumName,
                      );
                      if (mounted) {
                        AppSnackBar.show(
                          context,
                          ref,
                          SnackBar(
                            content: Text(
                              l10n.batchAddedToDownloadQueue(_tracks.length),
                            ),
                            action: SnackBarAction(
                              label: l10n.viewDownloadProgress,
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).push(
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
              label: Text(l10n.download),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final l10n = AppLocalizations.of(context)!;
                final client = SubsonicClient(
                  server: widget.server,
                  password: widget.password,
                );
                if (_isStarred) {
                  final ok = await client.unstar(albumId: widget.albumId);
                  if (ok && mounted) {
                    setState(() => _isStarred = false);
                    showToast(l10n.unstarredSuccess);
                  }
                } else {
                  final ok = await client.star(albumId: widget.albumId);
                  if (ok && mounted) {
                    setState(() => _isStarred = true);
                    showToast(l10n.starredSuccess);
                  }
                }
              },
              icon: Icon(
                _isStarred ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 18,
                color: _isStarred ? theme.colorScheme.primary : null,
              ),
              label: Text(
                l10n.btnFavorite,
                style: TextStyle(
                  color: _isStarred ? theme.colorScheme.primary : null,
                ),
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
