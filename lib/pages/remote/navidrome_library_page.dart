import 'dart:async';
import 'dart:io';
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
import '../../widgets/desktop_window_title_bar.dart';
import '../../widgets/mini_player_wrapper.dart';
import '../../widgets/remote_artwork_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/remote_context_menu_utils.dart';
import '../../player/remote/services/remote_download_service.dart';
import 'navidrome_album_detail_page.dart';
import 'navidrome_artist_detail_page.dart';
import 'navidrome_playlist_detail_page.dart';
import 'remote_download_manager_page.dart';

class NavidromeLibraryPage extends ConsumerStatefulWidget {
  final RemoteServer server;
  final String password;
  final bool wrapWithMiniPlayer;
  final int? initialTabIndex;

  const NavidromeLibraryPage({
    super.key,
    required this.server,
    required this.password,
    this.wrapWithMiniPlayer = false,
    this.initialTabIndex,
  });

  @override
  ConsumerState<NavidromeLibraryPage> createState() =>
      _NavidromeLibraryPageState();
}

class _NavidromeLibraryPageState extends ConsumerState<NavidromeLibraryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final SubsonicClient _client;

  // Albums state
  bool _isLoadingAlbums = false;
  String _albumSortType = 'alphabeticalByName';
  List<Map<String, dynamic>> _albums = [];
  String? _albumsError;
  final TextEditingController _albumSearchController = TextEditingController();
  String _albumSearchQuery = '';

  // Artists state
  bool _isLoadingArtists = false;
  List<Map<String, dynamic>> _artists = [];
  String? _artistsError;
  String? _selectedArtistId;
  final TextEditingController _artistSearchController = TextEditingController();
  String _artistSearchQuery = '';
  bool _artistSortAsc = true;
  String _artistSortField = 'name'; // 'name' or 'albumCount'
  bool _artistStarredOnly = false;
  final Set<String> _starredArtistIds = {};

  // Playlists state
  static const String _starredPlaylistId = '__navidrome_starred_songs__';
  bool _isLoadingPlaylists = false;
  List<Map<String, dynamic>> _playlists = [];
  String? _playlistsError;
  String? _selectedPlaylistId = _starredPlaylistId;
  final TextEditingController _playlistSearchController =
      TextEditingController();
  String _playlistSearchQuery = '';

  // Search tab state
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isSearching = false;
  List<MusicFile> _searchedSongs = [];
  List<Map<String, dynamic>> _searchedAlbums = [];
  List<Map<String, dynamic>> _searchedArtists = [];

  @override
  void initState() {
    super.initState();
    final initialIndex = (widget.initialTabIndex != null &&
            widget.initialTabIndex! >= 0 &&
            widget.initialTabIndex! < 4)
        ? widget.initialTabIndex!
        : 0;
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChanged);
    _client = SubsonicClient(
      server: widget.server,
      password: widget.password,
    );
    _loadAlbums();
    _loadArtists();
    _loadPlaylists();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    final newIndex = _tabController.index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final activeSession = ref.read(activeRemoteSessionProvider);
      if (activeSession != null &&
          activeSession.server.id == widget.server.id &&
          activeSession.initialTabIndex != newIndex) {
        ref
            .read(activeRemoteSessionProvider.notifier)
            .updateInitialTabIndex(newIndex);
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _albumSearchController.dispose();
    _artistSearchController.dispose();
    _playlistSearchController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAlbums() async {
    setState(() {
      _isLoadingAlbums = true;
      _albumsError = null;
    });
    try {
      final list = await _client.getAlbumList(type: _albumSortType, size: 500);
      if (!mounted) return;
      setState(() {
        _albums = list;
        _isLoadingAlbums = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _albumsError = e.toString();
        _isLoadingAlbums = false;
      });
    }
  }

  Future<void> _loadArtists() async {
    setState(() {
      _isLoadingArtists = true;
      _artistsError = null;
    });
    try {
      final list = await _client.getArtists();
      if (!mounted) return;
      setState(() {
        _artists = list;
        _isLoadingArtists = false;
        if (_selectedArtistId == null && list.isNotEmpty) {
          _selectedArtistId = list.first['id'] as String?;
        }
      });
      _fetchStarredArtists();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _artistsError = e.toString();
        _isLoadingArtists = false;
      });
    }
  }

  Future<void> _fetchStarredArtists() async {
    try {
      final starredList = await _client.getStarredArtists();
      final ids = starredList
          .map((e) => e['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      if (mounted) {
        setState(() {
          _starredArtistIds
            ..clear()
            ..addAll(ids);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadPlaylists() async {
    setState(() {
      _isLoadingPlaylists = true;
      _playlistsError = null;
    });
    try {
      final list = await _client.getPlaylists();
      if (!mounted) return;
      setState(() {
        _playlists = list;
        _isLoadingPlaylists = false;
        _selectedPlaylistId ??= _starredPlaylistId;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _playlistsError = e.toString();
        _isLoadingPlaylists = false;
      });
    }
  }

  Future<void> _playPlaylistDirectly(
    String playlistId,
    String playlistName,
  ) async {
    try {
      showToast('Loading playlist tracks...');
      final List<MusicFile> tracks = [];
      if (playlistId == _starredPlaylistId) {
        final songList = await _client.getStarredSongs();
        for (final s in songList) {
          tracks.add(
            RemoteMediaResolver.buildMusicFileFromSubsonic(s, widget.server),
          );
        }
      } else {
        final pl = await _client.getPlaylist(playlistId);
        final songList = pl?['entry'] as List?;
        if (songList != null && songList.isNotEmpty) {
          for (final s in songList) {
            if (s is Map<String, dynamic>) {
              tracks.add(
                RemoteMediaResolver.buildMusicFileFromSubsonic(s, widget.server),
              );
            }
          }
        }
      }
      if (tracks.isNotEmpty && mounted) {
        final audio = ref.read(audioServiceProvider);
        await audio.playPlaylist(
          tracks,
          source: PlaybackSource(
            type: PlaybackSourceType.playlist,
            id: 'remote-${widget.server.id}-$playlistId',
            name: playlistName,
          ),
        );
        showToast('Playing ${tracks.length} tracks');
      } else if (mounted) {
        showToast('Playlist is empty');
      }
    } catch (e) {
      if (mounted) {
        showToast('Failed to play playlist: $e');
      }
    }
  }

  void _showCreatePlaylistDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Playlist Name',
            hintText: 'Enter playlist name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                final created = await _client.createPlaylist(name: name);
                if (created != null && mounted) {
                  showToast('Created playlist: $name');
                  await _loadPlaylists();
                  final createdId = created['id'] as String?;
                  if (createdId != null) {
                    setState(() {
                      _selectedPlaylistId = createdId;
                    });
                  }
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _playAlbumDirectly(String albumId, String albumTitle) async {
    try {
      showToast('Loading album tracks...');
      final album = await _client.getAlbum(albumId);
      final songList = album?['song'] as List?;
      if (songList != null && songList.isNotEmpty) {
        final List<MusicFile> parsed = [];
        for (final item in songList) {
          if (item is Map<String, dynamic>) {
            parsed.add(
              RemoteMediaResolver.buildMusicFileFromSubsonic(
                item,
                widget.server,
              ),
            );
          }
        }
        if (parsed.isNotEmpty) {
          final audio = ref.read(audioServiceProvider);
          await audio.playPlaylist(
            parsed,
            source: PlaybackSource(
              type: PlaybackSourceType.album,
              id: 'remote-${widget.server.id}-$albumId',
              name: albumTitle,
            ),
          );
        }
      }
    } catch (e) {
      showToast('Failed to play album: $e');
    }
  }

  Future<void> _playArtistDirectly(String artistId, String artistName) async {
    try {
      showToast('Loading artist tracks...');
      final artistMap = await _client.getArtist(artistId);
      if (artistMap != null) {
        final dynamic rawAlbums = artistMap['album'];
        final List<Map<String, dynamic>> albumList = [];
        if (rawAlbums is List) {
          albumList.addAll(rawAlbums.whereType<Map<String, dynamic>>());
        } else if (rawAlbums is Map<String, dynamic>) {
          albumList.add(rawAlbums);
        }

        final List<MusicFile> allSongs = [];
        for (final al in albumList) {
          final aId = al['id'] as String?;
          if (aId != null) {
            final fullAlbum = await _client.getAlbum(aId);
            final sData = fullAlbum?['song'] as List?;
            if (sData != null) {
              for (final s in sData) {
                if (s is Map<String, dynamic>) {
                  allSongs.add(
                    RemoteMediaResolver.buildMusicFileFromSubsonic(
                      s,
                      widget.server,
                    ),
                  );
                }
              }
            }
          }
        }

        if (allSongs.isNotEmpty) {
          final audio = ref.read(audioServiceProvider);
          await audio.playPlaylist(
            allSongs,
            source: PlaybackSource(
              type: PlaybackSourceType.artist,
              id: 'remote-${widget.server.id}-$artistId',
              name: artistName,
            ),
          );
          showToast('Playing ${allSongs.length} tracks');
        } else {
          showToast('No tracks found for this artist');
        }
      }
    } catch (e) {
      showToast('Failed to play artist tracks: $e');
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchedSongs = [];
        _searchedAlbums = [];
        _searchedArtists = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final result = await _client.search(trimmed);
        final songList = result['song'] as List?;
        final albumList = result['album'] as List?;
        final artistList = result['artist'] as List?;

        final songs = <MusicFile>[];
        if (songList != null) {
          for (final s in songList) {
            if (s is Map<String, dynamic>) {
              songs.add(
                RemoteMediaResolver.buildMusicFileFromSubsonic(
                  s,
                  widget.server,
                ),
              );
            }
          }
        }

        if (mounted) {
          setState(() {
            _searchedSongs = songs;
            _searchedAlbums = (albumList ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();
            _searchedArtists = (artistList ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMacOS = Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    Widget content = PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(activeRemoteSessionProvider.notifier).clear();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Exit',
            onPressed: () {
              ref.read(activeRemoteSessionProvider.notifier).clear();
              Navigator.of(context).maybePop();
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.server.name),
            Text(
              'Navidrome / Subsonic',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final activeCount = ref.watch(activeDownloadsCountProvider);
              return IconButton(
                icon: Badge(
                  isLabelVisible: activeCount > 0,
                  label: Text('$activeCount'),
                  child: const Icon(Icons.download_rounded),
                ),
                tooltip: 'Download Manager',
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.album_rounded), text: 'Albums'),
            Tab(icon: Icon(Icons.person_rounded), text: 'Artists'),
            Tab(icon: Icon(Icons.playlist_play_rounded), text: 'Playlists'),
            Tab(icon: Icon(Icons.search_rounded), text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlbumsTab(theme),
          _buildArtistsTab(theme),
          _buildPlaylistsTab(theme),
          _buildSearchTab(theme),
        ],
      ),
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

    if (widget.wrapWithMiniPlayer) {
      return MiniPlayerWrapper(child: content);
    }
    return content;
  }

  // ================= ALBUMS TAB =================
  Widget _buildAlbumsTab(ThemeData theme) {
    const sortOptions = [
      {'key': 'alphabeticalByName', 'label': 'All (A-Z)'},
      {'key': 'newest', 'label': 'Recently Added'},
      {'key': 'recent', 'label': 'Recently Played'},
      {'key': 'frequent', 'label': 'Most Played'},
      {'key': 'starred', 'label': 'Starred'},
      {'key': 'random', 'label': 'Random'},
    ];

    final filteredAlbums = _albums.where((album) {
      if (_albumSearchQuery.isEmpty) return true;
      final q = _albumSearchQuery.toLowerCase();
      final title = (album['title'] as String? ?? album['name'] as String? ?? '').toLowerCase();
      final artist = (album['artist'] as String? ?? '').toLowerCase();
      return title.contains(q) || artist.contains(q);
    }).toList();

    Widget buildToolbar(bool isWide) {
      final searchField = TextField(
        controller: _albumSearchController,
        onChanged: (val) {
          setState(() {
            _albumSearchQuery = val.trim();
          });
        },
        decoration: InputDecoration(
          hintText: 'Filter albums...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _albumSearchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _albumSearchController.clear();
                    setState(() {
                      _albumSearchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );

      final sortChips = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sortOptions.map((opt) {
            final key = opt['key']!;
            final label = opt['label']!;
            final isSelected = _albumSortType == key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected && _albumSortType != key) {
                    setState(() {
                      _albumSortType = key;
                    });
                    _loadAlbums();
                  }
                },
              ),
            );
          }).toList(),
        ),
      );

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: isWide
            ? Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: searchField,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6,
                    child: sortChips,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchField,
                  const SizedBox(height: 6),
                  sortChips,
                ],
              ),
      );
    }

    if (_isLoadingAlbums) {
      return LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            buildToolbar(constraints.maxWidth >= 650),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }
    if (_albumsError != null) {
      return LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            buildToolbar(constraints.maxWidth >= 650),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading albums: $_albumsError'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadAlbums,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.maxWidth) {
          >= 1350 => 6,
          >= 1100 => 5,
          >= 850 => 4,
          >= 650 => 3,
          _ => 2,
        };

        final isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;
        final textScale = MediaQuery.textScalerOf(context).scale(10) / 10;
        final clampedScale = textScale.clamp(1.0, 1.3);
        final double textHeight = (isPortrait ? 96.0 : 116.0) * clampedScale;
        final itemWidth =
            (constraints.maxWidth - 32 - (crossAxisCount - 1) * 16) /
                crossAxisCount;
        final childAspectRatio = itemWidth / (itemWidth + textHeight);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Column(
              children: [
                buildToolbar(constraints.maxWidth >= 650),
                Expanded(
                  child: filteredAlbums.isEmpty
                      ? Center(
                          child: Text(
                            _albumSearchQuery.isEmpty
                                ? 'No albums found on server'
                                : 'No matching albums',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAlbums,
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filteredAlbums.length,
                            itemBuilder: (context, index) {
                              final album = filteredAlbums[index];
                              final albumId = album['id'] as String? ?? '';
                              final title = album['title'] as String? ??
                                  album['name'] as String? ??
                                  'Untitled';
                              final artist = album['artist'] as String? ??
                                  'Unknown Artist';
                              final coverId =
                                  album['coverArt'] as String?;
                              final songCount = album['songCount'] as int?;
                              final year = album['year'] as int?;

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onSecondaryTapDown: (details) {
                                  showRemoteAlbumContextMenu(
                                    context: context,
                                    globalPosition: details.globalPosition,
                                    ref: ref,
                                    server: widget.server,
                                    password: widget.password,
                                    albumId: albumId,
                                    albumTitle: title,
                                    artistName: artist,
                                    coverArtId: coverId,
                                    onViewDetails: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => NavidromeAlbumDetailPage(
                                            server: widget.server,
                                            password: widget.password,
                                            albumId: albumId,
                                            albumName: title,
                                            artistName: artist,
                                            coverArtId: coverId,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                onLongPressStart: (details) {
                                  showRemoteAlbumContextMenu(
                                    context: context,
                                    globalPosition: details.globalPosition,
                                    ref: ref,
                                    server: widget.server,
                                    password: widget.password,
                                    albumId: albumId,
                                    albumTitle: title,
                                    artistName: artist,
                                    coverArtId: coverId,
                                    onViewDetails: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => NavidromeAlbumDetailPage(
                                            server: widget.server,
                                            password: widget.password,
                                            albumId: albumId,
                                            albumName: title,
                                            artistName: artist,
                                            coverArtId: coverId,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => NavidromeAlbumDetailPage(
                                            server: widget.server,
                                            password: widget.password,
                                            albumId: albumId,
                                            albumName: title,
                                            artistName: artist,
                                            coverArtId: coverId,
                                          ),
                                        ),
                                      );
                                    },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          theme.colorScheme.primaryContainer
                                              .withValues(alpha: 0.65),
                                          theme
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.55),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: theme.colorScheme.outlineVariant
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(11),
                                            topRight: Radius.circular(11),
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: RemoteArtworkWidget(
                                              server: widget.server,
                                              password: widget.password,
                                              coverArtId: coverId,
                                              size: 220,
                                              borderRadius: BorderRadius.zero,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                              isPortrait ? 10 : 12,
                                              isPortrait ? 6 : 8,
                                              isPortrait ? 10 : 12,
                                              isPortrait ? 4 : 6,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      title,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: (isPortrait
                                                              ? theme.textTheme
                                                                  .titleSmall
                                                              : theme.textTheme
                                                                  .titleMedium)
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      artist,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: (isPortrait
                                                              ? theme.textTheme
                                                                  .bodySmall
                                                              : theme.textTheme
                                                                  .bodyMedium)
                                                          ?.copyWith(
                                                        color: theme.colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        songCount != null
                                                            ? '$songCount tracks'
                                                            : (year != null &&
                                                                    year > 0
                                                                ? '$year'
                                                                : ''),
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                          fontSize: isPortrait
                                                              ? 10
                                                              : 11,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(),
                                                      tooltip: 'Play Album',
                                                      onPressed: () =>
                                                          _playAlbumDirectly(
                                                        albumId,
                                                        title,
                                                      ),
                                                      icon: Icon(
                                                        Icons
                                                            .play_circle_filled_rounded,
                                                        size: isPortrait
                                                            ? 22
                                                            : 26,
                                                        color: theme
                                                            .colorScheme.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= ARTISTS TAB =================
  Widget _buildArtistsTab(ThemeData theme) {
    if (_isLoadingArtists) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_artistsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading artists: $_artistsError'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loadArtists,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_artists.isEmpty) {
      return const Center(child: Text('No artists found'));
    }

    final l10n = AppLocalizations.of(context)!;

    // Filter & sort
    final filteredArtists = _artists.where((a) {
      if (_artistStarredOnly) {
        final id = a['id']?.toString() ?? '';
        final isStarred =
            a['starred'] != null || _starredArtistIds.contains(id);
        if (!isStarred) return false;
      }
      if (_artistSearchQuery.isEmpty) return true;
      final q = _artistSearchQuery.toLowerCase();
      final name = (a['name'] as String? ?? '').toLowerCase();
      return name.contains(q);
    }).toList();

    filteredArtists.sort((a, b) {
      if (_artistSortField == 'albumCount') {
        final aCnt = a['albumCount'] as int? ?? 0;
        final bCnt = b['albumCount'] as int? ?? 0;
        final cmp = aCnt.compareTo(bCnt);
        return _artistSortAsc ? cmp : -cmp;
      } else {
        final aName = (a['name'] as String? ?? '').toLowerCase();
        final bName = (b['name'] as String? ?? '').toLowerCase();
        final cmp = aName.compareTo(bName);
        return _artistSortAsc ? cmp : -cmp;
      }
    });

    Widget buildArtistToolbar() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _artistSearchController,
                onChanged: (val) {
                  setState(() {
                    _artistSearchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Filter artists...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _artistSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _artistSearchController.clear();
                            setState(() {
                              _artistSearchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilterChip(
              avatar: Icon(
                _artistStarredOnly
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 14,
                color: _artistStarredOnly ? Colors.redAccent : null,
              ),
              label: Text(
                l10n.starredArtists,
                style: TextStyle(
                  fontSize: 12,
                  color: _artistStarredOnly ? Colors.redAccent : null,
                ),
              ),
              selected: _artistStarredOnly,
              onSelected: (selected) {
                setState(() {
                  _artistStarredOnly = selected;
                  if (selected &&
                      filteredArtists.isNotEmpty &&
                      !filteredArtists.any((a) => a['id'] == _selectedArtistId)) {
                    _selectedArtistId = filteredArtists.first['id'] as String?;
                  }
                });
                if (selected && _starredArtistIds.isEmpty) {
                  _fetchStarredArtists();
                }
              },
            ),
            const SizedBox(width: 8),
            ActionChip(
              avatar: Icon(
                _artistSortAsc
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 16,
              ),
              label: Text(
                _artistSortField == 'albumCount' ? 'Albums' : 'A-Z',
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () {
                setState(() {
                  if (_artistSortField == 'name') {
                    if (_artistSortAsc) {
                      _artistSortAsc = false;
                    } else {
                      _artistSortField = 'albumCount';
                      _artistSortAsc = false;
                    }
                  } else {
                    _artistSortField = 'name';
                    _artistSortAsc = true;
                  }
                });
              },
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

        // Ensure a selected artist exists for landscape split view
        final selectedArtist = filteredArtists.firstWhere(
          (a) => a['id'] == _selectedArtistId,
          orElse: () =>
              filteredArtists.isNotEmpty ? filteredArtists.first : const {},
        );

        if (isLandscape && filteredArtists.isNotEmpty) {
          // Landscape Split View (similar to local ArtistsTab landscape split view)
          return Row(
            children: [
              // Left: Artist List Pane
              SizedBox(
                width: constraints.maxWidth >= 1100 ? 380 : 320,
                child: Column(
                  children: [
                    buildArtistToolbar(),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 8, 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.45),
                          ),
                        ),
                        child: RefreshIndicator(
                          onRefresh: _loadArtists,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredArtists.length,
                            itemBuilder: (context, index) {
                              final artist = filteredArtists[index];
                              final isSelected =
                                  artist['id'] == selectedArtist['id'];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _buildArtistItem(
                                  theme: theme,
                                  artist: artist,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      _selectedArtistId =
                                          artist['id'] as String?;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Artist Detail Pane
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: selectedArtist.isNotEmpty
                        ? NavidromeArtistDetailContent(
                            key: ValueKey(selectedArtist['id']),
                            server: widget.server,
                            password: widget.password,
                            artistId: selectedArtist['id'] as String? ?? '',
                            artistName: selectedArtist['name'] as String? ??
                                'Unknown Artist',
                            coverArtId: selectedArtist['coverArt'] as String?,
                            albumCount: selectedArtist['albumCount'] as int?,
                          )
                        : const Center(child: Text('No artist selected')),
                  ),
                ),
              ),
            ],
          );
        }

        // Portrait: Vertical List of Artist Cards
        return Column(
          children: [
            buildArtistToolbar(),
            Expanded(
              child: filteredArtists.isEmpty
                  ? Center(
                      child: Text(
                        _artistSearchQuery.isEmpty
                            ? 'No artists found'
                            : 'No matching artists',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadArtists,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: filteredArtists.length,
                        itemBuilder: (context, index) {
                          final artist = filteredArtists[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildArtistItem(
                              theme: theme,
                              artist: artist,
                              isSelected: false,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NavidromeArtistDetailPage(
                                      server: widget.server,
                                      password: widget.password,
                                      artistId:
                                          artist['id'] as String? ?? '',
                                      artistName: artist['name'] as String? ??
                                          'Unknown Artist',
                                      coverArtId:
                                          artist['coverArt'] as String?,
                                      albumCount:
                                          artist['albumCount'] as int?,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArtistItem({
    required ThemeData theme,
    required Map<String, dynamic> artist,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final name = artist['name'] as String? ?? 'Unknown Artist';
    final albumCount = artist['albumCount'] as int?;
    final coverArt = artist['coverArt'] as String? ??
        artist['artistImageUrl'] as String? ??
        artist['id'] as String?;
    final artistId = artist['id'] as String? ?? '';

    final backgroundColor = isSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) {
        showRemoteArtistContextMenu(
          context: context,
          globalPosition: details.globalPosition,
          ref: ref,
          server: widget.server,
          password: widget.password,
          artistId: artistId,
          artistName: name,
          onViewDetails: onTap,
        );
      },
      onLongPressStart: (details) {
        showRemoteArtistContextMenu(
          context: context,
          globalPosition: details.globalPosition,
          ref: ref,
          server: widget.server,
          password: widget.password,
          artistId: artistId,
          artistName: name,
          onViewDetails: onTap,
        );
      },
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: RemoteArtworkWidget(
                      server: widget.server,
                      password: widget.password,
                      coverArtId: coverArt,
                      isArtist: true,
                      size: 46,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (albumCount != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          '$albumCount albums',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Play Artist',
                  icon: const Icon(Icons.play_arrow_rounded),
                  onPressed: () => _playArtistDirectly(artistId, name),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= PLAYLISTS TAB =================
  Widget _buildPlaylistsTab(ThemeData theme) {
    if (_isLoadingPlaylists) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_playlistsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading playlists: $_playlistsError'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loadPlaylists,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final starredPlaylist = {
      'id': _starredPlaylistId,
      'name': l10n.starredSongs,
      'isStarred': true,
      'comment': l10n.starredSongsDesc,
    };

    final List<Map<String, dynamic>> allPlaylists = [
      starredPlaylist,
      ..._playlists,
    ];

    final filteredPlaylists = allPlaylists.where((pl) {
      if (_playlistSearchQuery.isEmpty) return true;
      final q = _playlistSearchQuery.toLowerCase();
      final name = (pl['name'] as String? ?? '').toLowerCase();
      return name.contains(q);
    }).toList();

    Widget buildPlaylistToolbar() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _playlistSearchController,
                onChanged: (val) {
                  setState(() {
                    _playlistSearchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search playlists...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _playlistSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _playlistSearchController.clear();
                            setState(() {
                              _playlistSearchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Create Playlist',
              icon: const Icon(Icons.add_rounded),
              onPressed: _showCreatePlaylistDialog,
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadPlaylists,
            ),
          ],
        ),
      );
    }

    if (filteredPlaylists.isEmpty) {
      return Column(
        children: [
          buildPlaylistToolbar(),
          const Expanded(
            child: Center(child: Text('No playlists found')),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

        // Ensure a selected playlist exists for landscape split view
        final selectedPlaylist = filteredPlaylists.firstWhere(
          (p) => p['id'] == _selectedPlaylistId,
          orElse: () =>
              filteredPlaylists.isNotEmpty ? filteredPlaylists.first : const {},
        );

        if (isLandscape && filteredPlaylists.isNotEmpty) {
          // Landscape Split View
          return Row(
            children: [
              // Left: Playlist List Pane
              SizedBox(
                width: constraints.maxWidth >= 1100 ? 380 : 320,
                child: Column(
                  children: [
                    buildPlaylistToolbar(),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 8, 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.45),
                          ),
                        ),
                        child: RefreshIndicator(
                          onRefresh: _loadPlaylists,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredPlaylists.length,
                            itemBuilder: (context, index) {
                              final pl = filteredPlaylists[index];
                              final isSelected =
                                  pl['id'] == selectedPlaylist['id'];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _buildPlaylistItem(
                                  theme: theme,
                                  playlist: pl,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      _selectedPlaylistId =
                                          pl['id'] as String?;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Playlist Detail Pane
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: selectedPlaylist.isNotEmpty
                        ? NavidromePlaylistDetailContent(
                            key: ValueKey(selectedPlaylist['id']),
                            server: widget.server,
                            password: widget.password,
                            playlistId:
                                selectedPlaylist['id'] as String? ?? '',
                            playlistName:
                                selectedPlaylist['name'] as String? ??
                                    'Playlist',
                            coverArtId:
                                selectedPlaylist['coverArt'] as String?,
                            songCount: selectedPlaylist['songCount'] as int?,
                            duration: selectedPlaylist['duration'] as int?,
                            isStarred: selectedPlaylist['isStarred'] == true ||
                                selectedPlaylist['id'] == _starredPlaylistId,
                            onPlaylistModified: _loadPlaylists,
                            onDeleted: () {
                              _loadPlaylists();
                            },
                          )
                        : const Center(child: Text('No playlist selected')),
                  ),
                ),
              ),
            ],
          );
        }

        // Portrait: Vertical List of Playlist Cards
        return Column(
          children: [
            buildPlaylistToolbar(),
            Expanded(
              child: filteredPlaylists.isEmpty
                  ? Center(
                      child: Text(
                        _playlistSearchQuery.isEmpty
                            ? 'No playlists found'
                            : 'No matching playlists',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPlaylists,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: filteredPlaylists.length,
                        itemBuilder: (context, index) {
                          final pl = filteredPlaylists[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildPlaylistItem(
                              theme: theme,
                              playlist: pl,
                              isSelected: false,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NavidromePlaylistDetailPage(
                                      server: widget.server,
                                      password: widget.password,
                                      playlistId:
                                          pl['id'] as String? ?? '',
                                      playlistName:
                                          pl['name'] as String? ??
                                              'Playlist',
                                      coverArtId:
                                          pl['coverArt'] as String?,
                                      songCount: pl['songCount'] as int?,
                                      duration: pl['duration'] as int?,
                                      isStarred: pl['isStarred'] == true ||
                                          pl['id'] == _starredPlaylistId,
                                      onPlaylistModified: _loadPlaylists,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaylistItem({
    required ThemeData theme,
    required Map<String, dynamic> playlist,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final name = playlist['name'] as String? ?? 'Playlist';
    final songCount = playlist['songCount'] as int? ?? 0;
    final durationSec = playlist['duration'] as int? ?? 0;
    final durationMin = durationSec ~/ 60;
    final coverArt = playlist['coverArt'] as String?;
    final playlistId = playlist['id'] as String? ?? '';
    final isStarredItem =
        playlist['isStarred'] == true || playlistId == _starredPlaylistId;

    final backgroundColor = isSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: isStarredItem
          ? null
          : (details) {
              showRemotePlaylistContextMenu(
                context: context,
                globalPosition: details.globalPosition,
                ref: ref,
                server: widget.server,
                password: widget.password,
                playlistId: playlistId,
                playlistName: name,
                onViewDetails: onTap,
                onRename: () => _loadPlaylists(),
                onDelete: () => _loadPlaylists(),
              );
            },
      onLongPressStart: isStarredItem
          ? null
          : (details) {
              showRemotePlaylistContextMenu(
                context: context,
                globalPosition: details.globalPosition,
                ref: ref,
                server: widget.server,
                password: widget.password,
                playlistId: playlistId,
                playlistName: name,
                onViewDetails: onTap,
                onRename: () => _loadPlaylists(),
                onDelete: () => _loadPlaylists(),
              );
            },
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: isStarredItem
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFE53935),
                                  Color(0xFFE91E63),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          )
                        : coverArt != null && coverArt.isNotEmpty
                            ? RemoteArtworkWidget(
                                server: widget.server,
                                password: widget.password,
                                coverArtId: coverArt,
                                size: 46,
                                borderRadius: BorderRadius.circular(12),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepPurple.shade400,
                                      Colors.indigo.shade600,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.playlist_play_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isStarredItem
                            ? l10n.starredSongsDesc
                            : '$songCount songs • $durationMin mins',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Play Playlist',
                  icon: const Icon(Icons.play_arrow_rounded),
                  onPressed: () => _playPlaylistDirectly(playlistId, name),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= SEARCH TAB =================
  Widget _buildSearchTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search songs, albums, artists...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (_isSearching) const LinearProgressIndicator(),
        Expanded(
          child: _searchedSongs.isEmpty &&
                  _searchedAlbums.isEmpty &&
                  _searchedArtists.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.trim().isEmpty
                        ? 'Type something to search'
                        : 'No matching results',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (_searchedArtists.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Artists (${_searchedArtists.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      for (final artist in _searchedArtists)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onSecondaryTapDown: (details) {
                            showRemoteArtistContextMenu(
                              context: context,
                              globalPosition: details.globalPosition,
                              ref: ref,
                              server: widget.server,
                              password: widget.password,
                              artistId: artist['id'] as String? ?? '',
                              artistName: artist['name'] as String? ?? '',
                              onViewDetails: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NavidromeArtistDetailPage(
                                      server: widget.server,
                                      password: widget.password,
                                      artistId: artist['id'] as String? ?? '',
                                      artistName: artist['name'] as String? ?? '',
                                      coverArtId: artist['coverArt'] as String?,
                                      albumCount: artist['albumCount'] as int?,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          onLongPressStart: (details) {
                            showRemoteArtistContextMenu(
                              context: context,
                              globalPosition: details.globalPosition,
                              ref: ref,
                              server: widget.server,
                              password: widget.password,
                              artistId: artist['id'] as String? ?? '',
                              artistName: artist['name'] as String? ?? '',
                              onViewDetails: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NavidromeArtistDetailPage(
                                      server: widget.server,
                                      password: widget.password,
                                      artistId: artist['id'] as String? ?? '',
                                      artistName: artist['name'] as String? ?? '',
                                      coverArtId: artist['coverArt'] as String?,
                                      albumCount: artist['albumCount'] as int?,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.person_rounded),
                            ),
                            title: Text(artist['name'] as String? ?? ''),
                            subtitle: artist['albumCount'] != null
                                ? Text('${artist['albumCount']} albums')
                                : null,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => NavidromeArtistDetailPage(
                                    server: widget.server,
                                    password: widget.password,
                                    artistId: artist['id'] as String? ?? '',
                                    artistName:
                                        artist['name'] as String? ?? '',
                                    coverArtId: artist['coverArt'] as String?,
                                    albumCount: artist['albumCount'] as int?,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],
                    if (_searchedAlbums.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Albums (${_searchedAlbums.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _searchedAlbums.length,
                          itemBuilder: (context, index) {
                            final album = _searchedAlbums[index];
                            final albumId = album['id'] as String? ?? '';
                            final title = album['name'] as String? ??
                                album['title'] as String? ??
                                'Untitled';
                            final artist = album['artist'] as String? ?? 'Unknown Artist';
                            final coverId =
                                album['coverArt'] as String?;

                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onSecondaryTapDown: (details) {
                                  showRemoteAlbumContextMenu(
                                    context: context,
                                    globalPosition: details.globalPosition,
                                    ref: ref,
                                    server: widget.server,
                                    password: widget.password,
                                    albumId: albumId,
                                    albumTitle: title,
                                    artistName: artist,
                                    coverArtId: coverId,
                                    onViewDetails: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => NavidromeAlbumDetailPage(
                                            server: widget.server,
                                            password: widget.password,
                                            albumId: albumId,
                                            albumName: title,
                                            coverArtId: coverId,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                onLongPressStart: (details) {
                                  showRemoteAlbumContextMenu(
                                    context: context,
                                    globalPosition: details.globalPosition,
                                    ref: ref,
                                    server: widget.server,
                                    password: widget.password,
                                    albumId: albumId,
                                    albumTitle: title,
                                    artistName: artist,
                                    coverArtId: coverId,
                                    onViewDetails: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => NavidromeAlbumDetailPage(
                                            server: widget.server,
                                            password: widget.password,
                                            albumId: albumId,
                                            albumName: title,
                                            coverArtId: coverId,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => NavidromeAlbumDetailPage(
                                          server: widget.server,
                                          password: widget.password,
                                          albumId: albumId,
                                          albumName: title,
                                          coverArtId: coverId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      RemoteArtworkWidget(
                                        server: widget.server,
                                        password: widget.password,
                                        coverArtId: coverId,
                                        size: 80,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_searchedSongs.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Songs (${_searchedSongs.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      for (final song in _searchedSongs)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onSecondaryTapDown: (details) {
                            showRemoteSongContextMenu(
                              context: context,
                              globalPosition: details.globalPosition,
                              ref: ref,
                              server: widget.server,
                              password: widget.password,
                              song: song,
                            );
                          },
                          onLongPressStart: (details) {
                            showRemoteSongContextMenu(
                              context: context,
                              globalPosition: details.globalPosition,
                              ref: ref,
                              server: widget.server,
                              password: widget.password,
                              song: song,
                            );
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.music_note_rounded),
                            title: Text(
                              song.title ?? song.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _buildSongSubtitle(song),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () async {
                              final audioService =
                                  ref.read(audioServiceProvider);
                              await audioService.playPlaylist([song]);
                            },
                          ),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  String _buildSongSubtitle(MusicFile song) {
    final album = song.album?.trim();
    final artist = song.artist?.trim();
    final parts = [
      if (album != null && album.isNotEmpty) album,
      if (artist != null && artist.isNotEmpty) artist,
    ];
    if (parts.isNotEmpty) {
      return parts.join(' - ');
    }
    return 'Unknown Artist';
  }
}

