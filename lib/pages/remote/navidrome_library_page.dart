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
import '../../utils/song_context_menu_utils.dart';
import '../../utils/app_snack_bar.dart';
import '../../player/remote/services/remote_download_service.dart';
import '../../player/remote/navidrome_navigation.dart';
import '../../widgets/library_selection_panel.dart';
import '../../widgets/library_selection_scope.dart';
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
  final FocusNode _albumSearchFocusNode = FocusNode();
  String _albumSearchQuery = '';
  bool _isAlbumSearchExpanded = false;

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

  // Multi-selection state
  final Set<String> _selectedAlbumIds = {};
  final Set<String> _selectedArtistIds = {};
  final Set<String> _selectedPlaylistIds = {};
  final Set<String> _selectedSongPaths = {};

  bool get _isAlbumSelectionMode => _selectedAlbumIds.isNotEmpty;
  bool get _isArtistSelectionMode => _selectedArtistIds.isNotEmpty;
  bool get _isPlaylistSelectionMode => _selectedPlaylistIds.isNotEmpty;
  bool get _isSongSelectionMode => _selectedSongPaths.isNotEmpty;
  bool get _isSelectionMode =>
      _isAlbumSelectionMode ||
      _isArtistSelectionMode ||
      _isPlaylistSelectionMode ||
      _isSongSelectionMode;

  void _updateSelectionScope([bool? forceActive]) {
    final active = forceActive ?? _isSelectionMode;
    if (active) {
      ref
          .read(librarySelectionScopeProvider.notifier)
          .setScope(LibrarySelectionScope.navidrome);
    } else {
      ref.read(librarySelectionScopeProvider.notifier).clear();
    }
  }

  void _cancelSelection() {
    if (_selectedAlbumIds.isNotEmpty ||
        _selectedArtistIds.isNotEmpty ||
        _selectedPlaylistIds.isNotEmpty ||
        _selectedSongPaths.isNotEmpty) {
      setState(() {
        _selectedAlbumIds.clear();
        _selectedArtistIds.clear();
        _selectedPlaylistIds.clear();
        _selectedSongPaths.clear();
      });
      _updateSelectionScope(false);
    }
  }

  void _toggleAlbumSelection(String albumId) {
    setState(() {
      _selectedArtistIds.clear();
      _selectedPlaylistIds.clear();
      _selectedSongPaths.clear();
      if (_selectedAlbumIds.contains(albumId)) {
        _selectedAlbumIds.remove(albumId);
      } else {
        _selectedAlbumIds.add(albumId);
      }
    });
    _updateSelectionScope();
  }

  void _toggleSelectAllAlbums(List<Map<String, dynamic>> filteredAlbums) {
    final allIds = filteredAlbums
        .map((a) => a['id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    setState(() {
      _selectedArtistIds.clear();
      _selectedPlaylistIds.clear();
      _selectedSongPaths.clear();
      if (_selectedAlbumIds.length == allIds.length && allIds.isNotEmpty) {
        _selectedAlbumIds.clear();
      } else {
        _selectedAlbumIds.clear();
        _selectedAlbumIds.addAll(allIds);
      }
    });
    _updateSelectionScope();
  }

  void _toggleArtistSelection(String artistId) {
    setState(() {
      _selectedAlbumIds.clear();
      _selectedPlaylistIds.clear();
      _selectedSongPaths.clear();
      if (_selectedArtistIds.contains(artistId)) {
        _selectedArtistIds.remove(artistId);
      } else {
        _selectedArtistIds.add(artistId);
      }
    });
    _updateSelectionScope();
  }

  void _toggleSelectAllArtists(List<Map<String, dynamic>> filteredArtists) {
    final allIds = filteredArtists
        .map((a) => a['id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    setState(() {
      _selectedAlbumIds.clear();
      _selectedPlaylistIds.clear();
      _selectedSongPaths.clear();
      if (_selectedArtistIds.length == allIds.length && allIds.isNotEmpty) {
        _selectedArtistIds.clear();
      } else {
        _selectedArtistIds.clear();
        _selectedArtistIds.addAll(allIds);
      }
    });
    _updateSelectionScope();
  }

  void _togglePlaylistSelection(String playlistId) {
    setState(() {
      _selectedAlbumIds.clear();
      _selectedArtistIds.clear();
      _selectedSongPaths.clear();
      if (_selectedPlaylistIds.contains(playlistId)) {
        _selectedPlaylistIds.remove(playlistId);
      } else {
        _selectedPlaylistIds.add(playlistId);
      }
    });
    _updateSelectionScope();
  }

  void _toggleSelectAllPlaylists(List<Map<String, dynamic>> filteredPlaylists) {
    final allIds = filteredPlaylists
        .map((p) => p['id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    setState(() {
      _selectedAlbumIds.clear();
      _selectedArtistIds.clear();
      _selectedSongPaths.clear();
      if (_selectedPlaylistIds.length == allIds.length && allIds.isNotEmpty) {
        _selectedPlaylistIds.clear();
      } else {
        _selectedPlaylistIds.clear();
        _selectedPlaylistIds.addAll(allIds);
      }
    });
    _updateSelectionScope();
  }

  void _toggleSongSelection(String songPath) {
    setState(() {
      _selectedAlbumIds.clear();
      _selectedArtistIds.clear();
      _selectedPlaylistIds.clear();
      if (_selectedSongPaths.contains(songPath)) {
        _selectedSongPaths.remove(songPath);
      } else {
        _selectedSongPaths.add(songPath);
      }
    });
    _updateSelectionScope();
  }

  void _toggleSelectAllSongs(List<MusicFile> songs) {
    final allPaths = songs.map((s) => s.path).toSet();
    setState(() {
      _selectedAlbumIds.clear();
      _selectedArtistIds.clear();
      _selectedPlaylistIds.clear();
      if (_selectedSongPaths.length == allPaths.length && allPaths.isNotEmpty) {
        _selectedSongPaths.clear();
      } else {
        _selectedSongPaths.clear();
        _selectedSongPaths.addAll(allPaths);
      }
    });
    _updateSelectionScope();
  }

  Future<List<MusicFile>> _fetchSelectedSongs() async {
    final client = SubsonicClient(
      server: widget.server,
      password: widget.password,
    );
    final List<MusicFile> allSongs = [];
    if (_isAlbumSelectionMode) {
      for (final albumId in _selectedAlbumIds) {
        final tracks =
            await fetchSubsonicAlbumTracks(client, widget.server, albumId);
        allSongs.addAll(tracks);
      }
    } else if (_isArtistSelectionMode) {
      for (final artistId in _selectedArtistIds) {
        final tracks =
            await fetchSubsonicArtistTracks(client, widget.server, artistId);
        allSongs.addAll(tracks);
      }
    } else if (_isPlaylistSelectionMode) {
      for (final playlistId in _selectedPlaylistIds) {
        final tracks =
            await fetchSubsonicPlaylistTracks(client, widget.server, playlistId);
        allSongs.addAll(tracks);
      }
    } else if (_isSongSelectionMode) {
      for (final song in _searchedSongs) {
        if (_selectedSongPaths.contains(song.path)) {
          allSongs.add(song);
        }
      }
    }
    return allSongs;
  }

  Future<void> _handleBatchPlayNext() async {
    final songs = await _fetchSelectedSongs();
    if (songs.isEmpty) return;
    final audio = ref.read(audioServiceProvider);
    await audio.enqueueNext(songs);
    _cancelSelection();
  }

  Future<void> _handleBatchAddToQueue() async {
    final songs = await _fetchSelectedSongs();
    if (songs.isEmpty) return;
    final audio = ref.read(audioServiceProvider);
    await audio.appendToQueue(songs);
    _cancelSelection();
  }

  Future<void> _handleBatchAddToPlaylist() async {
    final songs = await _fetchSelectedSongs();
    if (songs.isEmpty) return;
    if (!mounted) return;
    final playlistService = ref.read(playlistServiceProvider);
    await showAddSongsToPlaylistDialog(context, playlistService, songs);
    _cancelSelection();
  }

  Future<void> _handleBatchDownload() async {
    final songs = await _fetchSelectedSongs();
    if (songs.isEmpty) return;
    final notifier = ref.read(remoteDownloadTasksProvider.notifier);
    await notifier.enqueueSubsonicTracks(
      server: widget.server,
      password: widget.password,
      songs: songs,
      collectionName: widget.server.name,
    );
    _cancelSelection();
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppSnackBar.show(
        context,
        ref,
        SnackBar(
          content: Text(l10n.batchAddedToDownloadQueue(songs.length)),
          action: SnackBarAction(
            label: l10n.viewDownloadProgress,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const RemoteDownloadManagerPage(),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _handleBatchDeletePlaylists() async {
    final toDelete = _selectedPlaylistIds
        .where((id) => id != _starredPlaylistId && id != 'starred_songs')
        .toList();
    if (toDelete.isEmpty) return;
    final client = SubsonicClient(
      server: widget.server,
      password: widget.password,
    );
    for (final plId in toDelete) {
      await client.deletePlaylist(plId);
    }
    _cancelSelection();
    _loadPlaylists(forceRefresh: true);
  }

  List<Map<String, dynamic>> _getFilteredAlbums() {
    return _albums.where((album) {
      if (_albumSearchQuery.isEmpty) return true;
      final q = _albumSearchQuery.toLowerCase();
      final title = (album['title'] as String? ?? album['name'] as String? ?? '')
          .toLowerCase();
      final artist = (album['artist'] as String? ?? '').toLowerCase();
      return title.contains(q) || artist.contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredArtists() {
    var result = _artists.where((artist) {
      if (_artistSearchQuery.isEmpty) return true;
      final q = _artistSearchQuery.toLowerCase();
      final name = (artist['name'] as String? ?? '').toLowerCase();
      return name.contains(q);
    }).toList();
    if (_artistStarredOnly) {
      result =
          result.where((a) => _starredArtistIds.contains(a['id'])).toList();
    }
    return result;
  }

  List<Map<String, dynamic>> _getFilteredPlaylists() {
    final l10n = AppLocalizations.of(context)!;
    final allPlaylists = <Map<String, dynamic>>[
      {
        'id': _starredPlaylistId,
        'name': l10n.starredSongs,
        'songCount': 0,
        'duration': 0,
        'coverArt': null,
        'isStarred': true,
      },
      ..._playlists,
    ];
    return allPlaylists.where((pl) {
      if (_playlistSearchQuery.isEmpty) return true;
      final q = _playlistSearchQuery.toLowerCase();
      final name = (pl['name'] as String? ?? '').toLowerCase();
      return name.contains(q);
    }).toList();
  }

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
    final session = ref.read(activeRemoteSessionProvider);
    final isSameServer =
        session != null && session.server.id == widget.server.id;
    if (isSameServer && session.navidromeSearchQuery != null) {
      _searchController.text = session.navidromeSearchQuery!;
      _searchedSongs =
          List<MusicFile>.from(session.navidromeSearchedSongs ?? const []);
      _searchedAlbums = List<Map<String, dynamic>>.from(
        session.navidromeSearchedAlbums ?? const [],
      );
      _searchedArtists = List<Map<String, dynamic>>.from(
        session.navidromeSearchedArtists ?? const [],
      );
    }
    if (isSameServer && session.navidromePlaylistSearchQuery != null) {
      _playlistSearchQuery = session.navidromePlaylistSearchQuery!;
      _playlistSearchController.text = session.navidromePlaylistSearchQuery!;
    }
    _loadAlbums();
    _loadArtists();
    _loadPlaylists();
  }

  void _handleTabChanged() {
    _cancelSelection();
    if (mounted) {
      setState(() {});
    }
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
    if (_isSelectionMode) {
      Future.microtask(() {
        try {
          ref.read(librarySelectionScopeProvider.notifier).clear();
        } catch (_) {}
      });
    }
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _albumSearchController.dispose();
    _albumSearchFocusNode.dispose();
    _artistSearchController.dispose();
    _playlistSearchController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAlbums({bool forceRefresh = false}) async {
    final session = ref.read(activeRemoteSessionProvider);
    final isSameServer =
        session != null && session.server.id == widget.server.id;

    if (!forceRefresh &&
        isSameServer &&
        session.navidromeAlbums != null &&
        session.navidromeAlbumSortType == _albumSortType) {
      setState(() {
        _albums = session.navidromeAlbums!;
        _isLoadingAlbums = false;
        _albumsError = null;
      });
      return;
    }

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(activeRemoteSessionProvider.notifier).updateNavidromeAlbums(
              list,
              sortType: _albumSortType,
            );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _albumsError = e.toString();
        _isLoadingAlbums = false;
      });
    }
  }

  Future<void> _loadArtists({bool forceRefresh = false}) async {
    final session = ref.read(activeRemoteSessionProvider);
    final isSameServer =
        session != null && session.server.id == widget.server.id;

    if (!forceRefresh && isSameServer && session.navidromeArtists != null) {
      setState(() {
        _artists = session.navidromeArtists!;
        _starredArtistIds
          ..clear()
          ..addAll(session.navidromeStarredArtistIds ?? {});
        _selectedArtistId = session.navidromeSelectedArtistId ??
            (_artists.isNotEmpty ? _artists.first['id'] as String? : null);
        _isLoadingArtists = false;
        _artistsError = null;
      });
      return;
    }

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(activeRemoteSessionProvider.notifier).updateNavidromeArtists(
              artists: list,
              selectedArtistId: _selectedArtistId,
            );
      });
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
        ref.read(activeRemoteSessionProvider.notifier).updateNavidromeArtists(
              starredArtistIds: _starredArtistIds,
            );
      }
    } catch (_) {}
  }

  Future<void> _loadPlaylists({bool forceRefresh = false}) async {
    final session = ref.read(activeRemoteSessionProvider);
    final isSameServer =
        session != null && session.server.id == widget.server.id;

    if (!forceRefresh && isSameServer && session.navidromePlaylists != null) {
      setState(() {
        _playlists = session.navidromePlaylists!;
        _selectedPlaylistId =
            session.navidromeSelectedPlaylistId ?? _starredPlaylistId;
        _isLoadingPlaylists = false;
        _playlistsError = null;
      });
      return;
    }

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(activeRemoteSessionProvider.notifier)
            .updateNavidromePlaylists(
              playlists: list,
              selectedPlaylistId: _selectedPlaylistId,
            );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _playlistsError = e.toString();
        _isLoadingPlaylists = false;
      });
    }
  }



  void _showCreatePlaylistDialog() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.createNewServerPlaylist),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.playlistName,
            hintText: l10n.enterPlaylistName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                final created = await _client.createPlaylist(name: name);
                if (created != null && mounted) {
                  showToast(l10n.createdPlaylistSuccess(name));
                  await _loadPlaylists(forceRefresh: true);
                  final createdId = created['id'] as String?;
                  if (createdId != null) {
                    setState(() {
                      _selectedPlaylistId = createdId;
                    });
                    ref
                        .read(activeRemoteSessionProvider.notifier)
                        .updateNavidromePlaylists(
                          selectedPlaylistId: createdId,
                        );
                  }
                }
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _playAlbumDirectly(String albumId, String albumTitle) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      showToast(l10n.loadingAlbumTracks);
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
      showToast(l10n.playAlbumFailed(e.toString()));
    }
  }



  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (_isSelectionMode) {
      _cancelSelection();
    }
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchedSongs = [];
        _searchedAlbums = [];
        _searchedArtists = [];
      });
      final activeSession = ref.read(activeRemoteSessionProvider);
      if (activeSession != null && activeSession.server.id == widget.server.id) {
        ref.read(activeRemoteSessionProvider.notifier).updateNavidromeSearch(
              query: '',
              songs: const [],
              albums: const [],
              artists: const [],
            );
      }
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
          final albums = (albumList ?? [])
              .whereType<Map<String, dynamic>>()
              .toList();
          final artists = (artistList ?? [])
              .whereType<Map<String, dynamic>>()
              .toList();

          setState(() {
            _searchedSongs = songs;
            _searchedAlbums = albums;
            _searchedArtists = artists;
            _isSearching = false;
          });

          final activeSession = ref.read(activeRemoteSessionProvider);
          if (activeSession != null &&
              activeSession.server.id == widget.server.id) {
            ref.read(activeRemoteSessionProvider.notifier).updateNavidromeSearch(
                  query: query,
                  songs: songs,
                  albums: albums,
                  artists: artists,
                );
          }
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isMacOS = Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final bottomOffset = MiniPlayerUiTuning.getListBottomPadding(
      context,
      hasPlayingMusic: currentMusic != null,
      isSelectionMode: _isSelectionMode,
      selectionPanelHeight: 220.0,
    );

    String? panelTitle;
    VoidCallback? panelToggleSelectAll;
    bool? panelIsAllSelected;
    VoidCallback? panelDelete;
    String? panelDeleteLabel;

    if (_isAlbumSelectionMode) {
      final filteredAlbums = _tabController.index == 3
          ? _searchedAlbums
          : _getFilteredAlbums();
      panelTitle = l10n.selectedAlbumsCount(_selectedAlbumIds.length);
      panelToggleSelectAll = () => _toggleSelectAllAlbums(filteredAlbums);
      panelIsAllSelected = _selectedAlbumIds.length == filteredAlbums.length &&
          filteredAlbums.isNotEmpty;
    } else if (_isArtistSelectionMode) {
      final filteredArtists = _tabController.index == 3
          ? _searchedArtists
          : _getFilteredArtists();
      panelTitle = l10n.selectedArtistsCount(_selectedArtistIds.length);
      panelToggleSelectAll = () => _toggleSelectAllArtists(filteredArtists);
      panelIsAllSelected =
          _selectedArtistIds.length == filteredArtists.length &&
              filteredArtists.isNotEmpty;
    } else if (_isPlaylistSelectionMode) {
      final filteredPlaylists = _getFilteredPlaylists();
      panelTitle = l10n.selectedPlaylistsCount(_selectedPlaylistIds.length);
      panelToggleSelectAll =
          () => _toggleSelectAllPlaylists(filteredPlaylists);
      panelIsAllSelected =
          _selectedPlaylistIds.length == filteredPlaylists.length &&
              filteredPlaylists.isNotEmpty;
      panelDelete = _handleBatchDeletePlaylists;
      panelDeleteLabel = l10n.deletePlaylist;
    } else if (_isSongSelectionMode) {
      final songs = _searchedSongs;
      panelTitle = l10n.selectedSongs(_selectedSongPaths.length);
      panelToggleSelectAll = () => _toggleSelectAllSongs(songs);
      panelIsAllSelected =
          _selectedSongPaths.length == songs.length && songs.isNotEmpty;
    }

    Widget content = PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(activeRemoteSessionProvider.notifier).clear();
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      floating: true,
                      snap: false,
                      pinned: false,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      surfaceTintColor: Colors.transparent,
                      backgroundColor: theme.colorScheme.surface,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: l10n.close,
                        onPressed: () {
                          ref.read(activeRemoteSessionProvider.notifier).clear();
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
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          tooltip: l10n.refresh,
                          onPressed: () {
                            switch (_tabController.index) {
                              case 0:
                                _loadAlbums(forceRefresh: true);
                                break;
                              case 1:
                                _loadArtists(forceRefresh: true);
                                break;
                              case 2:
                                _loadPlaylists(forceRefresh: true);
                                break;
                              case 3:
                                if (_searchController.text.isNotEmpty) {
                                  _onSearchChanged(_searchController.text);
                                }
                                break;
                            }
                          },
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final activeCount =
                                ref.watch(activeDownloadsCountProvider);
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
                                    builder: (_) =>
                                        const RemoteDownloadManagerPage(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                      bottom: _NavidromeHeaderBottom(
                        tabBar: TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(icon: const Icon(Icons.album_rounded), text: l10n.albums),
                            Tab(icon: const Icon(Icons.person_rounded), text: l10n.artists),
                            Tab(
                              icon: const Icon(Icons.playlist_play_rounded),
                              text: l10n.playlists,
                            ),
                            Tab(icon: const Icon(Icons.search_rounded), text: l10n.search),
                          ],
                        ),
                        toolbar: _buildCurrentTabToolbar(theme),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAlbumsTab(theme, bottomOffset),
                    _buildArtistsTab(theme, bottomOffset),
                    _buildPlaylistsTab(theme, bottomOffset),
                    _buildSearchTab(theme, bottomOffset),
                  ],
                ),
              ),
            ),
            AnimatedSelectionPanel(
              isVisible: _isSelectionMode,
              child: LibrarySelectionPanel(
                key: ValueKey(
                  'navidrome-library-selection-panel-${_tabController.index}',
                ),
                selectedSongs: _isSongSelectionMode
                    ? _searchedSongs
                        .where((s) => _selectedSongPaths.contains(s.path))
                        .toList()
                    : const [],
                allSongs: _isSongSelectionMode ? _searchedSongs : const [],
                title: panelTitle,
                isSelectionEmpty: !_isSelectionMode,
                isAllSelected: panelIsAllSelected,
                onToggleSelectAll: panelToggleSelectAll ?? () {},
                onCancel: _cancelSelection,
                onPlayNext: _handleBatchPlayNext,
                onAddToQueue: _handleBatchAddToQueue,
                onAddToPlaylist: _handleBatchAddToPlaylist,
                onDownload: _handleBatchDownload,
                onDelete: panelDelete,
                deleteLabel: panelDeleteLabel,
              ),
            ),
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

  Widget? _buildCurrentTabToolbar(ThemeData theme) {
    switch (_tabController.index) {
      case 0:
        return _buildAlbumsToolbar(theme);
      case 1:
        return _buildArtistsToolbar(theme);
      case 2:
        return _buildPlaylistsToolbar(theme);
      case 3:
        return _buildSearchToolbar(theme);
      default:
        return null;
    }
  }

  Widget _buildAlbumsToolbar(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final sortOptions = [
      {'key': 'alphabeticalByName', 'label': l10n.sortAllAZ},
      {'key': 'newest', 'label': l10n.sortRecentAdded},
      {'key': 'recent', 'label': l10n.sortRecentlyPlayed},
      {'key': 'frequent', 'label': l10n.sortMostPlayed},
      {'key': 'starred', 'label': l10n.sortStarred},
      {'key': 'random', 'label': l10n.sortRandom},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 650;
        final searchField = TextField(
          controller: _albumSearchController,
          focusNode: _albumSearchFocusNode,
          onChanged: (val) {
            setState(() {
              _albumSearchQuery = val.trim();
            });
          },
          decoration: InputDecoration(
            hintText: l10n.filterAlbums,
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
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        );

        final sortChips = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: sortOptions.map((opt) {
              final key = opt['key']!;
              final label = opt['label']!;
              final isSelected = _albumSortType == key;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && _albumSortType != key) {
                      setState(() {
                        _albumSortType = key;
                      });
                      _loadAlbums(forceRefresh: true);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        );

        final isNarrowExpanded =
            _isAlbumSearchExpanded || _albumSearchQuery.isNotEmpty;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: isNarrowExpanded
                      ? Row(
                          key: const ValueKey('album_search_expanded'),
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded,
                                  size: 20),
                              tooltip: l10n.closeSearch,
                              onPressed: () {
                                _albumSearchFocusNode.unfocus();
                                setState(() {
                                  _isAlbumSearchExpanded = false;
                                  _albumSearchController.clear();
                                  _albumSearchQuery = '';
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            Expanded(child: searchField),
                          ],
                        )
                      : Row(
                          key: const ValueKey('album_search_collapsed'),
                          children: [
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                minimumSize: const Size(32, 32),
                                fixedSize: const Size(32, 32),
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.search_rounded, size: 18),
                              tooltip: l10n.filterAlbums,
                              onPressed: () {
                                setState(() {
                                  _isAlbumSearchExpanded = true;
                                });
                                _albumSearchFocusNode.requestFocus();
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: sortChips),
                          ],
                        ),
                ),
        );
      },
    );
  }

  Widget _buildArtistsToolbar(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
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
                hintText: l10n.filterArtists,
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
                  vertical: 8,
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
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
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
              _artistSortField == 'albumCount' ? l10n.albums : 'A-Z',
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

  Widget _buildPlaylistsToolbar(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _playlistSearchController,
              onChanged: (val) {
                setState(() {
                  _playlistSearchQuery = val;
                });
                final activeSession = ref.read(activeRemoteSessionProvider);
                if (activeSession != null &&
                    activeSession.server.id == widget.server.id) {
                  ref
                      .read(activeRemoteSessionProvider.notifier)
                      .updateNavidromePlaylistSearchQuery(val);
                }
              },
              decoration: InputDecoration(
                hintText: l10n.searchPlaylists,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _playlistSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _playlistSearchController.clear();
                          setState(() {
                            _playlistSearchQuery = '';
                          });
                          final activeSession =
                              ref.read(activeRemoteSessionProvider);
                          if (activeSession != null &&
                              activeSession.server.id == widget.server.id) {
                            ref
                                .read(activeRemoteSessionProvider.notifier)
                                .updateNavidromePlaylistSearchQuery('');
                          }
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
            tooltip: l10n.createNewServerPlaylist,
            icon: const Icon(Icons.add_rounded),
            onPressed: _showCreatePlaylistDialog,
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: l10n.refresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadPlaylists(forceRefresh: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchToolbar(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.searchRemoteHint,
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
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_isSearching) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  // ================= ALBUMS TAB =================
  Widget _buildAlbumsTab(ThemeData theme, double bottomOffset) {
    final l10n = AppLocalizations.of(context)!;
    final filteredAlbums = _getFilteredAlbums();

    if (_isLoadingAlbums) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_albumsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.errorLoadingAlbums(_albumsError!)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _loadAlbums(forceRefresh: true),
              child: Text(l10n.retry),
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
            child: filteredAlbums.isEmpty
                ? Center(
                    child: Text(
                      _albumSearchQuery.isEmpty
                          ? l10n.noAlbumsOnServer
                          : l10n.noMatchingAlbums,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadAlbums(forceRefresh: true),
                    child: GridView.builder(
                      padding:
                          EdgeInsets.fromLTRB(16, 8, 16, bottomOffset),
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
                        final isSelected = _selectedAlbumIds.contains(albumId);
                        final title = album['title'] as String? ??
                            album['name'] as String? ??
                            l10n.unknownAlbum;
                        final artist = album['artist'] as String? ??
                            l10n.unknownArtist;
                        final coverId = album['coverArt'] as String?;
                        final songCount = album['songCount'] as int?;
                        final year = album['year'] as int?;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onSecondaryTapDown: (details) {
                            if (!_isAlbumSelectionMode) {
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
                                  NavidromeNavUtils.openAlbum(
                                    context,
                                    ref,
                                    server: widget.server,
                                    password: widget.password,
                                    albumId: albumId,
                                    albumName: title,
                                    artistName: artist,
                                    coverArtId: coverId,
                                  );
                                },
                              );
                            }
                          },
                          onLongPressStart: (details) {
                            _toggleAlbumSelection(albumId);
                          },
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (_isAlbumSelectionMode) {
                                  _toggleAlbumSelection(albumId);
                                } else {
                                  NavidromeNavUtils.openAlbum(
                                    context,
                                    ref,
                                    server: widget.server,
                                    password: widget.password,
                                    albumId: albumId,
                                    albumName: title,
                                    artistName: artist,
                                    coverArtId: coverId,
                                  );
                                }
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isSelected
                                        ? [
                                            theme.colorScheme.primaryContainer
                                                .withValues(alpha: 0.6),
                                            theme.colorScheme.primaryContainer
                                                .withValues(alpha: 0.35),
                                          ]
                                        : [
                                            theme.colorScheme.primaryContainer
                                                .withValues(alpha: 0.25),
                                            theme.colorScheme.surfaceContainerHighest
                                                .withValues(alpha: 0.45),
                                          ],
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outlineVariant
                                            .withValues(alpha: 0.35),
                                    width: isSelected ? 2.0 : 0.8,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Stack(
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
                                        if (_isAlbumSelectionMode)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : Colors.black.withValues(alpha: 0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isSelected
                                                    ? Icons.check_rounded
                                                    : Icons.radio_button_unchecked_rounded,
                                                size: 18,
                                                color: isSelected
                                                    ? theme.colorScheme.onPrimary
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
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
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    fontSize: isPortrait
                                                        ? 12
                                                        : 13,
                                                    color: isSelected
                                                        ? theme.colorScheme.primary
                                                        : null,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  artist,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: isPortrait
                                                        ? 11
                                                        : 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    songCount != null
                                                        ? l10n.trackCountShort(songCount)
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
                                                if (!_isAlbumSelectionMode)
                                                  IconButton(
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                    tooltip: l10n.playAlbum,
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
        );
      },
    );
  }

  // ================= ARTISTS TAB =================
  Widget _buildArtistsTab(ThemeData theme, double bottomOffset) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoadingArtists) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_artistsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.errorLoadingArtists(_artistsError!)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _loadArtists(forceRefresh: true),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final filteredArtists = _getFilteredArtists();

    filteredArtists.sort((a, b) {
      if (_artistSortField == 'albumCount') {
        final countA = (a['albumCount'] as num?)?.toInt() ?? 0;
        final countB = (b['albumCount'] as num?)?.toInt() ?? 0;
        final cmp = countA.compareTo(countB);
        return _artistSortAsc ? cmp : -cmp;
      } else {
        final nameA = (a['name'] as String? ?? '').toLowerCase();
        final nameB = (b['name'] as String? ?? '').toLowerCase();
        final cmp = nameA.compareTo(nameB);
        return _artistSortAsc ? cmp : -cmp;
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth >= 750;

        // Ensure a selected artist exists for landscape split view
        final selectedArtist = filteredArtists.firstWhere(
          (a) => a['id'] == _selectedArtistId,
          orElse: () =>
              filteredArtists.isNotEmpty ? filteredArtists.first : const {},
        );

        if (isLandscape && filteredArtists.isNotEmpty) {
          // Master-Detail Split View for Desktop / Landscape
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Artist Master List
              SizedBox(
                width: 320,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 8, 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: () => _loadArtists(forceRefresh: true),
                    child: ListView.builder(
                      padding:
                          EdgeInsets.fromLTRB(12, 12, 12, bottomOffset),
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
                              final id = artist['id'] as String?;
                              setState(() {
                                _selectedArtistId = id;
                              });
                              ref
                                  .read(
                                      activeRemoteSessionProvider.notifier)
                                  .updateNavidromeArtists(
                                    selectedArtistId: id,
                                  );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Right: Artist Detail Pane
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8, 12, 16, 16),
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
                                l10n.unknownArtist,
                            coverArtId: selectedArtist['coverArt'] as String?,
                            albumCount: selectedArtist['albumCount'] as int?,
                          )
                        : Center(child: Text(l10n.noArtistSelected)),
                  ),
                ),
              ),
            ],
          );
        }

        // Portrait: Vertical List of Artist Cards
        return filteredArtists.isEmpty
            ? Center(
                child: Text(
                  _artistSearchQuery.isEmpty
                      ? l10n.noArtistsFound
                      : l10n.noMatchingArtists,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => _loadArtists(forceRefresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottomOffset),
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
                          NavidromeNavUtils.openArtist(
                            context,
                            ref,
                            server: widget.server,
                            password: widget.password,
                            artistId: artist['id'] as String? ?? '',
                            artistName: artist['name'] as String? ??
                                l10n.unknownArtist,
                            coverArtId: artist['coverArt'] as String?,
                            albumCount: artist['albumCount'] as int?,
                          );
                        },
                      ),
                    );
                  },
                ),
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
    final l10n = AppLocalizations.of(context)!;
    final name = artist['name'] as String? ?? l10n.unknownArtist;
    final albumCount = artist['albumCount'] as int? ?? 0;
    final coverArtId = artist['coverArt'] as String?;
    final artistId = artist['id'] as String? ?? '';
    final isStarred = _starredArtistIds.contains(artistId);
    final isMultiSelected = _selectedArtistIds.contains(artistId);

    final backgroundColor = _isArtistSelectionMode && isMultiSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
        : (isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) {
        if (!_isArtistSelectionMode) {
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
        }
      },
      onLongPressStart: (details) {
        _toggleArtistSelection(artistId);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (_isArtistSelectionMode) {
              _toggleArtistSelection(artistId);
            } else {
              onTap();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (_isArtistSelectionMode && isMultiSelected) || isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: (_isArtistSelectionMode && isMultiSelected) || isSelected
                    ? 1.5
                    : 0.8,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RemoteArtworkWidget(
                    server: widget.server,
                    password: widget.password,
                    coverArtId: coverArtId,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: (_isArtistSelectionMode &&
                                            isMultiSelected) ||
                                        isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 13,
                                color: (_isArtistSelectionMode &&
                                            isMultiSelected) ||
                                        isSelected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isStarred)
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: Colors.redAccent,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.albumCount(albumCount),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isArtistSelectionMode)
                  Icon(
                    isMultiSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isMultiSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    size: 20,
                  )
                else
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    tooltip: l10n.more,
                    onPressed: () {
                      final box = context.findRenderObject() as RenderBox?;
                      final pos = box != null
                          ? box.localToGlobal(
                              Offset(box.size.width / 2, box.size.height / 2))
                          : Offset.zero;
                      showRemoteArtistContextMenu(
                        context: context,
                        globalPosition: pos,
                        ref: ref,
                        server: widget.server,
                        password: widget.password,
                        artistId: artistId,
                        artistName: name,
                        onViewDetails: onTap,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= PLAYLISTS TAB =================
  Widget _buildPlaylistsTab(ThemeData theme, double bottomOffset) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoadingPlaylists) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_playlistsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.errorLoadingPlaylists(_playlistsError!)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _loadPlaylists(forceRefresh: true),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final filteredPlaylists = _getFilteredPlaylists();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape =
            constraints.maxWidth >= 750 && filteredPlaylists.isNotEmpty;

        final selectedPlaylist = filteredPlaylists.firstWhere(
          (pl) => pl['id'] == _selectedPlaylistId,
          orElse: () => filteredPlaylists.isNotEmpty
              ? filteredPlaylists.first
              : const {},
        );

        if (isLandscape) {
          // Master-Detail Split View for Playlists (Desktop/Landscape)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Playlist List Pane
              SizedBox(
                width: constraints.maxWidth >= 1100 ? 380 : 320,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 8, 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: () => _loadPlaylists(forceRefresh: true),
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(12, 12, 12, bottomOffset),
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
                              final id = pl['id'] as String?;
                              setState(() {
                                _selectedPlaylistId = id;
                              });
                              ref
                                  .read(activeRemoteSessionProvider.notifier)
                                  .updateNavidromePlaylists(
                                    selectedPlaylistId: id,
                                  );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Right: Playlist Detail Pane
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8, 12, 16, 16),
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
                                    l10n.playlist,
                            coverArtId:
                                selectedPlaylist['coverArt'] as String?,
                            songCount: selectedPlaylist['songCount'] as int?,
                            duration: selectedPlaylist['duration'] as int?,
                            isStarred: selectedPlaylist['isStarred'] == true ||
                                selectedPlaylist['id'] == _starredPlaylistId,
                            onPlaylistModified: () =>
                                _loadPlaylists(forceRefresh: true),
                            onDeleted: () {
                              _loadPlaylists(forceRefresh: true);
                            },
                          )
                        : Center(child: Text(l10n.noPlaylistSelected)),
                  ),
                ),
              ),
            ],
          );
        }

        // Portrait: Vertical List of Playlist Cards
        return filteredPlaylists.isEmpty
            ? Center(
                child: Text(
                  _playlistSearchQuery.isEmpty
                      ? l10n.noPlaylistsFound
                      : l10n.noMatchingPlaylists,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => _loadPlaylists(forceRefresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottomOffset),
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
                          NavidromeNavUtils.openPlaylist(
                            context,
                            ref,
                            server: widget.server,
                            password: widget.password,
                            playlistId: pl['id'] as String? ?? '',
                            playlistName:
                                pl['name'] as String? ?? l10n.playlist,
                            coverArtId: pl['coverArt'] as String?,
                            songCount: pl['songCount'] as int?,
                            duration: pl['duration'] as int?,
                            isStarred: pl['isStarred'] == true ||
                                pl['id'] == _starredPlaylistId,
                            onPlaylistModified: () =>
                                _loadPlaylists(forceRefresh: true),
                          );
                        },
                      ),
                    );
                  },
                ),
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
    final name = playlist['name'] as String? ?? l10n.playlist;
    final songCount = playlist['songCount'] as int? ?? 0;
    final durationSec = playlist['duration'] as int? ?? 0;
    final durationMin = durationSec ~/ 60;
    final coverArt = playlist['coverArt'] as String?;
    final playlistId = playlist['id'] as String? ?? '';
    final isStarredItem =
        playlist['isStarred'] == true || playlistId == _starredPlaylistId;
    final isMultiSelected = _selectedPlaylistIds.contains(playlistId);

    final backgroundColor = _isPlaylistSelectionMode && isMultiSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
        : (isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: isStarredItem || _isPlaylistSelectionMode
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
                onRename: () => _loadPlaylists(forceRefresh: true),
                onDelete: () => _loadPlaylists(forceRefresh: true),
              );
            },
      onLongPressStart: (details) {
        _togglePlaylistSelection(playlistId);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (_isPlaylistSelectionMode) {
              _togglePlaylistSelection(playlistId);
            } else {
              onTap();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (_isPlaylistSelectionMode && isMultiSelected) || isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: (_isPlaylistSelectionMode && isMultiSelected) || isSelected
                    ? 1.5
                    : 0.8,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: coverArt != null && coverArt.isNotEmpty
                      ? RemoteArtworkWidget(
                          server: widget.server,
                          password: widget.password,
                          coverArtId: coverArt,
                          size: 44,
                        )
                      : Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isStarredItem
                                ? Colors.redAccent.withValues(alpha: 0.15)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isStarredItem
                                ? Icons.favorite_rounded
                                : Icons.playlist_play_rounded,
                            color: isStarredItem
                                ? Colors.redAccent
                                : theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isStarredItem ? l10n.starredSongs : name,
                              style: TextStyle(
                                fontWeight: (_isPlaylistSelectionMode &&
                                            isMultiSelected) ||
                                        isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 13,
                                color: (_isPlaylistSelectionMode &&
                                            isMultiSelected) ||
                                        isSelected
                                    ? theme.colorScheme.primary
                                    : (isStarredItem
                                        ? Colors.redAccent
                                        : null),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isStarredItem)
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: Colors.redAccent,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.trackCountShort(songCount)} • $durationMin min',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isPlaylistSelectionMode)
                  Icon(
                    isMultiSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isMultiSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    size: 20,
                  )
                else if (!isStarredItem)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    tooltip: l10n.more,
                    onPressed: () {
                      final box = context.findRenderObject() as RenderBox?;
                      final pos = box != null
                          ? box.localToGlobal(
                              Offset(box.size.width / 2, box.size.height / 2))
                          : Offset.zero;
                      showRemotePlaylistContextMenu(
                        context: context,
                        globalPosition: pos,
                        ref: ref,
                        server: widget.server,
                        password: widget.password,
                        playlistId: playlistId,
                        playlistName: name,
                        onViewDetails: onTap,
                        onRename: () => _loadPlaylists(forceRefresh: true),
                        onDelete: () => _loadPlaylists(forceRefresh: true),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= SEARCH TAB =================
  Widget _buildSearchTab(ThemeData theme, double bottomOffset) {
    final l10n = AppLocalizations.of(context)!;
    if (_searchedSongs.isEmpty &&
        _searchedAlbums.isEmpty &&
        _searchedArtists.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.trim().isEmpty
              ? l10n.typeToSearch
              : l10n.noMatchingResults,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomOffset),
      children: [
        if (_searchedArtists.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${l10n.artists} (${_searchedArtists.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          for (final artist in _searchedArtists) () {
            final artistId = artist['id'] as String? ?? '';
            final artistName = artist['name'] as String? ?? l10n.unknownArtist;
            final coverArtId = artist['coverArt'] as String?;
            final albumCount = artist['albumCount'] as int?;
            final isMultiSelected = _selectedArtistIds.contains(artistId);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onSecondaryTapDown: (details) {
                if (!_isArtistSelectionMode) {
                  showRemoteArtistContextMenu(
                    context: context,
                    globalPosition: details.globalPosition,
                    ref: ref,
                    server: widget.server,
                    password: widget.password,
                    artistId: artistId,
                    artistName: artistName,
                    onViewDetails: () {
                      NavidromeNavUtils.openArtist(
                        context,
                        ref,
                        server: widget.server,
                        password: widget.password,
                        artistId: artistId,
                        artistName: artistName,
                        coverArtId: coverArtId,
                        albumCount: albumCount,
                      );
                    },
                  );
                }
              },
              onLongPressStart: (details) {
                _toggleArtistSelection(artistId);
              },
              child: Material(
                color: _isArtistSelectionMode && isMultiSelected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (_isArtistSelectionMode) {
                      _toggleArtistSelection(artistId);
                    } else {
                      NavidromeNavUtils.openArtist(
                        context,
                        ref,
                        server: widget.server,
                        password: widget.password,
                        artistId: artistId,
                        artistName: artistName,
                        coverArtId: coverArtId,
                        albumCount: albumCount,
                      );
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: RemoteArtworkWidget(
                        server: widget.server,
                        password: widget.password,
                        coverArtId: coverArtId,
                        size: 40,
                      ),
                    ),
                    title: Text(
                      artistName,
                      style: TextStyle(
                        fontWeight: _isArtistSelectionMode && isMultiSelected
                            ? FontWeight.bold
                            : null,
                        color: _isArtistSelectionMode && isMultiSelected
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                    subtitle: albumCount != null
                        ? Text(l10n.albumCount(albumCount))
                        : null,
                    trailing: _isArtistSelectionMode
                        ? Icon(
                            isMultiSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isMultiSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            size: 20,
                          )
                        : null,
                  ),
                ),
              ),
            );
          }(),
          const SizedBox(height: 12),
        ],
        if (_searchedAlbums.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${l10n.albums} (${_searchedAlbums.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 124,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _searchedAlbums.length,
              itemBuilder: (context, index) {
                final album = _searchedAlbums[index];
                final albumId = album['id'] as String? ?? '';
                final title = album['name'] as String? ??
                    album['title'] as String? ??
                    l10n.unknownAlbum;
                final artist =
                    album['artist'] as String? ?? l10n.unknownArtist;
                final coverId = album['coverArt'] as String?;
                final isSelected = _selectedAlbumIds.contains(albumId);

                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onSecondaryTapDown: (details) {
                      if (!_isAlbumSelectionMode) {
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
                            NavidromeNavUtils.openAlbum(
                              context,
                              ref,
                              server: widget.server,
                              password: widget.password,
                              albumId: albumId,
                              albumName: title,
                              artistName: artist,
                              coverArtId: coverId,
                            );
                          },
                        );
                      }
                    },
                    onLongPressStart: (details) {
                      _toggleAlbumSelection(albumId);
                    },
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (_isAlbumSelectionMode) {
                          _toggleAlbumSelection(albumId);
                        } else {
                          NavidromeNavUtils.openAlbum(
                            context,
                            ref,
                            server: widget.server,
                            password: widget.password,
                            albumId: albumId,
                            albumName: title,
                            artistName: artist,
                            coverArtId: coverId,
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _isAlbumSelectionMode && isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    width: _isAlbumSelectionMode && isSelected ? 2 : 0,
                                  ),
                                ),
                                child: RemoteArtworkWidget(
                                  server: widget.server,
                                  password: widget.password,
                                  coverArtId: coverId,
                                  size: 80,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              if (_isAlbumSelectionMode)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.surface.withValues(alpha: 0.8),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_rounded
                                          : Icons.circle_outlined,
                                      size: 14,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: _isAlbumSelectionMode && isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _isAlbumSelectionMode && isSelected
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
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
              '${l10n.songs} (${_searchedSongs.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          for (int i = 0; i < _searchedSongs.length; i++) () {
            final song = _searchedSongs[i];
            final isSelected = _selectedSongPaths.contains(song.path);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onSecondaryTapDown: (details) {
                if (!_isSongSelectionMode) {
                  showRemoteSongContextMenu(
                    context: context,
                    globalPosition: details.globalPosition,
                    ref: ref,
                    server: widget.server,
                    password: widget.password,
                    song: song,
                  );
                }
              },
              onLongPressStart: (details) {
                _toggleSongSelection(song.path);
              },
              child: Material(
                color: _isSongSelectionMode && isSelected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    if (_isSongSelectionMode) {
                      _toggleSongSelection(song.path);
                    } else {
                      final audioService = ref.read(audioServiceProvider);
                      await audioService.playPlaylist(
                        _searchedSongs,
                        initialIndex: i,
                      );
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: _isSongSelectionMode
                        ? Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            size: 20,
                          )
                        : const Icon(Icons.music_note_rounded),
                    title: Text(
                      song.title ?? song.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: _isSongSelectionMode && isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _isSongSelectionMode && isSelected
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      _buildSongSubtitle(song, l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          }(),
        ],
      ],
    );
  }

  String _buildSongSubtitle(MusicFile song, AppLocalizations l10n) {
    final album = song.album?.trim();
    final artist = song.artist?.trim();
    final parts = [
      if (album != null && album.isNotEmpty) album,
      if (artist != null && artist.isNotEmpty) artist,
    ];
    if (parts.isNotEmpty) {
      return parts.join(' - ');
    }
    return l10n.unknownArtist;
  }
}

class _NavidromeHeaderBottom extends StatelessWidget
    implements PreferredSizeWidget {
  final TabBar tabBar;
  final Widget? toolbar;

  const _NavidromeHeaderBottom({
    required this.tabBar,
    this.toolbar,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        tabBar.preferredSize.height + (toolbar != null ? 52.0 : 0.0),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tabBar,
        if (toolbar != null)
          SizedBox(
            height: 52.0,
            child: toolbar!,
          ),
      ],
    );
  }
}
