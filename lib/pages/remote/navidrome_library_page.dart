import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';
import '../../models/music_file.dart';
import '../../player/audio/audio_riverpod.dart';
import '../../player/remote/remote_server_models.dart';
import '../../player/remote/remote_server_riverpod.dart';
import '../../player/remote/clients/subsonic_client.dart';
import '../../player/remote/proxy/remote_media_resolver.dart';
import '../../player/remote/navidrome_navigation.dart';
import '../../widgets/desktop_window_title_bar.dart';
import '../../widgets/mini_player_wrapper.dart';
import '../../l10n/app_localizations.dart';
import '../../player/remote/services/remote_download_service.dart';
import '../../widgets/library_selection_panel.dart';
import '../../widgets/library_selection_scope.dart';
import 'remote_download_manager_page.dart';
import 'widgets/navidrome_header_bottom.dart';
import 'widgets/navidrome_selection_actions.dart';
import 'widgets/navidrome_albums_tab.dart';
import 'widgets/navidrome_artists_tab.dart';
import 'widgets/navidrome_playlists_tab.dart';
import 'widgets/navidrome_search_tab.dart';

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
  static const String _starredPlaylistId =
      NavidromeSelectionActions.starredPlaylistId;
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

  int? _lastAlbumAnchorIndex;
  int? _lastArtistAnchorIndex;
  int? _lastPlaylistAnchorIndex;
  int? _lastSongAnchorIndex;

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
        _lastAlbumAnchorIndex = null;
        _lastArtistAnchorIndex = null;
        _lastPlaylistAnchorIndex = null;
        _lastSongAnchorIndex = null;
      });
      _updateSelectionScope(false);
    }
  }

  void _setAlbumSelection(Set<String> keys) {
    setState(() {
      _selectedArtistIds.clear();
      _selectedPlaylistIds.clear();
      _selectedSongPaths.clear();
      _selectedAlbumIds
        ..clear()
        ..addAll(keys);
    });
    _updateSelectionScope();
  }

  void _setArtistSelection(Set<String> keys) {
    setState(() {
      _selectedAlbumIds.clear();
      _selectedPlaylistIds.clear();
      _selectedSongPaths.clear();
      _selectedArtistIds
        ..clear()
        ..addAll(keys);
    });
    _updateSelectionScope();
  }

  void _setPlaylistSelection(Set<String> keys) {
    setState(() {
      _selectedAlbumIds.clear();
      _selectedArtistIds.clear();
      _selectedSongPaths.clear();
      _selectedPlaylistIds
        ..clear()
        ..addAll(keys);
    });
    _updateSelectionScope();
  }

  void _setSongSelection(Set<String> keys) {
    setState(() {
      _selectedAlbumIds.clear();
      _selectedArtistIds.clear();
      _selectedPlaylistIds.clear();
      _selectedSongPaths
        ..clear()
        ..addAll(keys);
    });
    _updateSelectionScope();
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

  Future<List<MusicFile>> _fetchSelectedSongs() {
    return NavidromeSelectionActions.fetchSelectedSongs(
      server: widget.server,
      password: widget.password,
      isAlbumSelectionMode: _isAlbumSelectionMode,
      isArtistSelectionMode: _isArtistSelectionMode,
      isPlaylistSelectionMode: _isPlaylistSelectionMode,
      isSongSelectionMode: _isSongSelectionMode,
      selectedAlbumIds: _selectedAlbumIds,
      selectedArtistIds: _selectedArtistIds,
      selectedPlaylistIds: _selectedPlaylistIds,
      selectedSongPaths: _selectedSongPaths,
      searchedSongs: _searchedSongs,
    );
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
    final settings = ref.read(settingsServiceProvider);
    _albumSortType = settings.navidromeAlbumSortType;
    _artistSortField = settings.navidromeArtistSortField;
    _artistSortAsc = settings.navidromeArtistSortAscending;
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

  LibrarySelectionScopeController? _selectionScopeController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectionScopeController =
        ref.read(librarySelectionScopeProvider.notifier);
  }

  @override
  void dispose() {
    if (_isSelectionMode) {
      final controller = _selectionScopeController;
      Future.microtask(() {
        controller?.clear();
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

  Future<void> _locateCurrentSong() async {
    final currentMusic = ref.read(audioCurrentMusicProvider);
    if (currentMusic == null) return;
    final l10n = AppLocalizations.of(context)!;

    final info = RemoteMediaResolver.parseUri(currentMusic.path);
    if (info != null &&
        info.type == RemoteServerType.subsonic &&
        info.serverId == widget.server.id) {
      try {
        final songData = await _client.getSong(info.trackIdOrPath);
        if (songData != null) {
          final albumId =
              songData['albumId'] as String? ?? songData['parent'] as String?;
          final albumName = songData['album'] as String? ?? 'Album';
          final artistName = songData['artist'] as String?;
          final coverArtId = songData['coverArt'] as String?;
          if (albumId != null && mounted) {
            NavidromeNavUtils.openAlbum(
              context,
              ref,
              server: widget.server,
              password: widget.password,
              albumId: albumId,
              albumName: albumName,
              artistName: artistName,
              coverArtId: coverArtId,
              highlightedSongPath: currentMusic.path,
            );
            return;
          }
        }
      } catch (_) {}
    } else if (info != null) {
      final servers = ref.read(remoteServersProvider).asData?.value ?? [];
      final server = servers.firstWhereOrNull((s) => s.id == info.serverId);
      if (server != null) {
        final password = await ref
                .read(remoteServersProvider.notifier)
                .getPassword(server.id) ??
            '';
        if (info.type == RemoteServerType.webdav) {
          final targetDir = p.posix.dirname(info.trackIdOrPath);
          final rootPath = server.customPath?.trim().isNotEmpty == true
              ? server.customPath!
              : '/';
          final stack =
              ActiveRemoteSession.buildWebDavPathStack(rootPath, targetDir);
          ref.read(activeRemoteSessionProvider.notifier).setSession(
                ActiveRemoteSession(
                  server: server,
                  password: password,
                  rootPath: rootPath,
                  initialPath: targetDir,
                  webDavPathStack: stack,
                  webDavHighlightedSongPath: currentMusic.path,
                ),
              );
          return;
        } else if (info.type == RemoteServerType.subsonic) {
          try {
            final client = SubsonicClient(server: server, password: password);
            final songData = await client.getSong(info.trackIdOrPath);
            if (songData != null && mounted) {
              final albumId = songData['albumId'] as String? ??
                  songData['parent'] as String?;
              final albumName = songData['album'] as String? ?? 'Album';
              final artistName = songData['artist'] as String?;
              final coverArtId = songData['coverArt'] as String?;
              if (albumId != null) {
                ref.read(activeRemoteSessionProvider.notifier).setSession(
                      ActiveRemoteSession(
                        server: server,
                        password: password,
                        navidromeDetailStack: [
                          NavidromeAlbumRoute(
                            albumId: albumId,
                            albumName: albumName,
                            artistName: artistName,
                            coverArtId: coverArtId,
                            highlightedSongPath: currentMusic.path,
                          ),
                        ],
                      ),
                    );
                return;
              }
            }
          } catch (_) {}
        }
      }
    } else {
      ref.read(activeRemoteSessionProvider.notifier).clear();
      return;
    }

    showToast(l10n.songNotInScannedFolders);
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
      panelDelete = () => NavidromeSelectionActions.handleBatchDeletePlaylists(
            server: widget.server,
            password: widget.password,
            selectedPlaylistIds: _selectedPlaylistIds,
            onClearSelection: _cancelSelection,
            onReloadPlaylists: () => _loadPlaylists(forceRefresh: true),
          );
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
                          icon: const Icon(Icons.my_location_rounded),
                          tooltip: l10n.locateCurrentSong,
                          onPressed: _locateCurrentSong,
                        ),
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
                      bottom: NavidromeHeaderBottom(
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
                    NavidromeAlbumsView(
                      server: widget.server,
                      password: widget.password,
                      albums: _getFilteredAlbums(),
                      isLoading: _isLoadingAlbums,
                      error: _albumsError,
                      onRefresh: () => _loadAlbums(forceRefresh: true),
                      searchQuery: _albumSearchQuery,
                      bottomOffset: bottomOffset,
                      isSelectionMode: _isAlbumSelectionMode,
                      selectedAlbumIds: _selectedAlbumIds,
                      lastAlbumAnchorIndex: _lastAlbumAnchorIndex,
                      onSetSelection: _setAlbumSelection,
                      onToggleSelection: _toggleAlbumSelection,
                      onUpdateAnchor: (a) => setState(() => _lastAlbumAnchorIndex = a),
                      onPlayAlbumDirectly: (id, title) =>
                          NavidromeSelectionActions.playAlbumDirectly(
                        context: context,
                        ref: ref,
                        server: widget.server,
                        password: widget.password,
                        albumId: id,
                        albumTitle: title,
                      ),
                    ),
                    NavidromeArtistsView(
                      server: widget.server,
                      password: widget.password,
                      artists: _getFilteredArtists(),
                      starredArtistIds: _starredArtistIds,
                      selectedArtistId: _selectedArtistId,
                      isLoading: _isLoadingArtists,
                      error: _artistsError,
                      onRefresh: () => _loadArtists(forceRefresh: true),
                      searchQuery: _artistSearchQuery,
                      bottomOffset: bottomOffset,
                      isSelectionMode: _isArtistSelectionMode,
                      selectedArtistIds: _selectedArtistIds,
                      lastArtistAnchorIndex: _lastArtistAnchorIndex,
                      onSelectArtistId: (id) {
                        setState(() {
                          _selectedArtistId = id;
                        });
                        ref
                            .read(activeRemoteSessionProvider.notifier)
                            .updateNavidromeArtists(
                              selectedArtistId: id,
                            );
                      },
                      onSetSelection: _setArtistSelection,
                      onToggleSelection: _toggleArtistSelection,
                      onUpdateAnchor: (a) =>
                          setState(() => _lastArtistAnchorIndex = a),
                    ),
                    NavidromePlaylistsView(
                      server: widget.server,
                      password: widget.password,
                      playlists: _getFilteredPlaylists(),
                      selectedPlaylistId: _selectedPlaylistId,
                      isLoading: _isLoadingPlaylists,
                      error: _playlistsError,
                      onRefresh: () => _loadPlaylists(forceRefresh: true),
                      searchQuery: _playlistSearchQuery,
                      bottomOffset: bottomOffset,
                      isSelectionMode: _isPlaylistSelectionMode,
                      selectedPlaylistIds: _selectedPlaylistIds,
                      lastPlaylistAnchorIndex: _lastPlaylistAnchorIndex,
                      onSelectPlaylistId: (id) {
                        setState(() {
                          _selectedPlaylistId = id;
                        });
                        ref
                            .read(activeRemoteSessionProvider.notifier)
                            .updateNavidromePlaylists(
                              selectedPlaylistId: id,
                            );
                      },
                      onSetSelection: _setPlaylistSelection,
                      onToggleSelection: _togglePlaylistSelection,
                      onUpdateAnchor: (a) =>
                          setState(() => _lastPlaylistAnchorIndex = a),
                    ),
                    NavidromeSearchView(
                      server: widget.server,
                      password: widget.password,
                      searchController: _searchController,
                      searchedSongs: _searchedSongs,
                      searchedAlbums: _searchedAlbums,
                      searchedArtists: _searchedArtists,
                      bottomOffset: bottomOffset,
                      isArtistSelectionMode: _isArtistSelectionMode,
                      isAlbumSelectionMode: _isAlbumSelectionMode,
                      isSongSelectionMode: _isSongSelectionMode,
                      selectedArtistIds: _selectedArtistIds,
                      selectedAlbumIds: _selectedAlbumIds,
                      selectedSongPaths: _selectedSongPaths,
                      lastSongAnchorIndex: _lastSongAnchorIndex,
                      onSetSongSelection: _setSongSelection,
                      onToggleSongSelection: _toggleSongSelection,
                      onUpdateSongAnchor: (a) =>
                          setState(() => _lastSongAnchorIndex = a),
                      onToggleArtistSelection: _toggleArtistSelection,
                      onToggleAlbumSelection: _toggleAlbumSelection,
                    ),
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
                onPlayNext: () => NavidromeSelectionActions.handleBatchPlayNext(
                  context: context,
                  ref: ref,
                  onFetchSongs: _fetchSelectedSongs,
                  onClearSelection: _cancelSelection,
                ),
                onAddToQueue: () =>
                    NavidromeSelectionActions.handleBatchAddToQueue(
                  context: context,
                  ref: ref,
                  onFetchSongs: _fetchSelectedSongs,
                  onClearSelection: _cancelSelection,
                ),
                onAddToPlaylist: () =>
                    NavidromeSelectionActions.handleBatchAddToPlaylist(
                  context: context,
                  ref: ref,
                  onFetchSongs: _fetchSelectedSongs,
                  onClearSelection: _cancelSelection,
                ),
                onDownload: () => NavidromeSelectionActions.handleBatchDownload(
                  context: context,
                  ref: ref,
                  server: widget.server,
                  password: widget.password,
                  onFetchSongs: _fetchSelectedSongs,
                  onClearSelection: _cancelSelection,
                ),
                onTranscode: () =>
                    NavidromeSelectionActions.handleBatchTranscode(
                  context: context,
                  onFetchSongs: _fetchSelectedSongs,
                  onClearSelection: _cancelSelection,
                ),
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
        return NavidromeAlbumsToolbar(
          searchController: _albumSearchController,
          searchFocusNode: _albumSearchFocusNode,
          searchQuery: _albumSearchQuery,
          isSearchExpanded: _isAlbumSearchExpanded,
          sortType: _albumSortType,
          onSearchChanged: (val) {
            setState(() {
              _albumSearchQuery = val.trim();
            });
          },
          onClearSearch: () {
            _albumSearchController.clear();
            setState(() {
              _albumSearchQuery = '';
            });
          },
          onToggleSearchExpanded: (expanded) {
            setState(() {
              _isAlbumSearchExpanded = expanded;
            });
          },
          onSortTypeChanged: (newSort) {
            setState(() {
              _albumSortType = newSort;
            });
            ref.read(settingsServiceProvider).navidromeAlbumSortType = newSort;
            _loadAlbums(forceRefresh: true);
          },
        );
      case 1:
        return NavidromeArtistsToolbar(
          searchController: _artistSearchController,
          searchQuery: _artistSearchQuery,
          starredOnly: _artistStarredOnly,
          sortAsc: _artistSortAsc,
          sortField: _artistSortField,
          onSearchChanged: (val) {
            setState(() {
              _artistSearchQuery = val.trim();
            });
          },
          onClearSearch: () {
            _artistSearchController.clear();
            setState(() {
              _artistSearchQuery = '';
            });
          },
          onToggleStarredOnly: (selected) {
            setState(() {
              _artistStarredOnly = selected;
            });
            if (selected && _starredArtistIds.isEmpty) {
              _fetchStarredArtists();
            }
          },
          onToggleSort: () {
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
            final settings = ref.read(settingsServiceProvider);
            settings.navidromeArtistSortField = _artistSortField;
            settings.navidromeArtistSortAscending = _artistSortAsc;
          },
        );
      case 2:
        return NavidromePlaylistsToolbar(
          searchController: _playlistSearchController,
          onSearchChanged: (val) {
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
          onClearSearch: () {
            _playlistSearchController.clear();
            setState(() {
              _playlistSearchQuery = '';
            });
            final activeSession = ref.read(activeRemoteSessionProvider);
            if (activeSession != null &&
                activeSession.server.id == widget.server.id) {
              ref
                  .read(activeRemoteSessionProvider.notifier)
                  .updateNavidromePlaylistSearchQuery('');
            }
          },
          onCreatePlaylist: () => showCreateNavidromePlaylistDialog(
            context: context,
            client: _client,
            onCreated: (created) async {
              await _loadPlaylists(forceRefresh: true);
              final createdId = created['id'] as String?;
              if (createdId != null && mounted) {
                setState(() {
                  _selectedPlaylistId = createdId;
                });
                ref
                    .read(activeRemoteSessionProvider.notifier)
                    .updateNavidromePlaylists(
                      selectedPlaylistId: createdId,
                    );
              }
            },
          ),
          onRefresh: () => _loadPlaylists(forceRefresh: true),
        );
      case 3:
        return NavidromeSearchToolbar(
          searchController: _searchController,
          isSearching: _isSearching,
          onSearchChanged: _onSearchChanged,
          onClearSearch: () {
            _searchController.clear();
            _onSearchChanged('');
          },
        );
      default:
        return null;
    }
  }
}
