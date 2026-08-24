import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import '../../models/music_file.dart';
import '../../player/audio/audio_riverpod.dart';
import '../../player/remote/remote_server_models.dart';
import '../../player/remote/clients/subsonic_client.dart';
import '../../player/remote/proxy/remote_media_resolver.dart';
import '../../widgets/remote_artwork_widget.dart';
import 'navidrome_album_detail_page.dart';

class NavidromeLibraryPage extends ConsumerStatefulWidget {
  final RemoteServer server;
  final String password;

  const NavidromeLibraryPage({
    super.key,
    required this.server,
    required this.password,
  });

  @override
  ConsumerState<NavidromeLibraryPage> createState() =>
      _NavidromeLibraryPageState();
}

class _NavidromeLibraryPageState extends ConsumerState<NavidromeLibraryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final SubsonicClient _client;

  // Data states
  bool _isLoadingAlbums = false;
  String _albumSortType = 'alphabeticalByName';
  List<Map<String, dynamic>> _albums = [];
  String? _albumsError;

  bool _isLoadingArtists = false;
  List<Map<String, dynamic>> _artists = [];
  String? _artistsError;

  bool _isLoadingPlaylists = false;
  List<Map<String, dynamic>> _playlists = [];
  String? _playlistsError;

  // Search state
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isSearching = false;
  List<MusicFile> _searchedSongs = [];
  List<Map<String, dynamic>> _searchedAlbums = [];
  List<Map<String, dynamic>> _searchedArtists = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _client = SubsonicClient(
      server: widget.server,
      password: widget.password,
    );
    _loadAlbums();
    _loadArtists();
    _loadPlaylists();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      setState(() {
        _albums = list;
        _isLoadingAlbums = false;
      });
    } catch (e) {
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
      setState(() {
        _artists = list;
        _isLoadingArtists = false;
      });
    } catch (e) {
      setState(() {
        _artistsError = e.toString();
        _isLoadingArtists = false;
      });
    }
  }

  Future<void> _loadPlaylists() async {
    setState(() {
      _isLoadingPlaylists = true;
      _playlistsError = null;
    });
    try {
      final list = await _client.getPlaylists();
      setState(() {
        _playlists = list;
        _isLoadingPlaylists = false;
      });
    } catch (e) {
      setState(() {
        _playlistsError = e.toString();
        _isLoadingPlaylists = false;
      });
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
              songs.add(RemoteMediaResolver.buildMusicFileFromSubsonic(s, widget.server));
            }
          }
        }

        if (mounted) {
          setState(() {
            _searchedSongs = songs;
            _searchedAlbums = (albumList ?? []).whereType<Map<String, dynamic>>().toList();
            _searchedArtists = (artistList ?? []).whereType<Map<String, dynamic>>().toList();
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

    return Scaffold(
      appBar: AppBar(
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
    );
  }

  Widget _buildAlbumsTab(ThemeData theme) {
    const sortOptions = [
      {'key': 'alphabeticalByName', 'label': 'All (A-Z)'},
      {'key': 'newest', 'label': 'Recently Added'},
      {'key': 'recent', 'label': 'Recently Played'},
      {'key': 'frequent', 'label': 'Most Played'},
      {'key': 'starred', 'label': 'Starred'},
      {'key': 'random', 'label': 'Random'},
    ];

    Widget buildSortChips() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: sortOptions.map((opt) {
            final key = opt['key']!;
            final label = opt['label']!;
            final isSelected = _albumSortType == key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label),
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
    }

    if (_isLoadingAlbums) {
      return Column(
        children: [
          buildSortChips(),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      );
    }
    if (_albumsError != null) {
      return Column(
        children: [
          buildSortChips(),
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
      );
    }
    if (_albums.isEmpty) {
      return Column(
        children: [
          buildSortChips(),
          const Expanded(child: Center(child: Text('No albums found on server'))),
        ],
      );
    }

    return Column(
      children: [
        buildSortChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAlbums,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                childAspectRatio: 0.75,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                final album = _albums[index];
                final albumId = album['id'] as String? ?? '';
                final title = album['title'] as String? ?? album['name'] as String? ?? 'Untitled';
                final artist = album['artist'] as String? ?? 'Unknown Artist';
                final coverId = album['coverArt'] as String? ?? albumId;

                return InkWell(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: RemoteArtworkWidget(
                            server: widget.server,
                            password: widget.password,
                            coverArtId: coverId,
                            size: 160,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        artist,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

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

    return RefreshIndicator(
      onRefresh: _loadArtists,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _artists.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
        itemBuilder: (context, index) {
          final artist = _artists[index];
          final name = artist['name'] as String? ?? 'Unknown Artist';
          final albumCount = artist['albumCount'] as int?;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person_rounded,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: albumCount != null ? Text('$albumCount albums') : null,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              showToast('Artist: $name');
            },
          );
        },
      ),
    );
  }

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
    if (_playlists.isEmpty) {
      return const Center(child: Text('No server playlists available'));
    }

    return RefreshIndicator(
      onRefresh: _loadPlaylists,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _playlists.length,
        itemBuilder: (context, index) {
          final pl = _playlists[index];
          final name = pl['name'] as String? ?? 'Playlist';
          final songCount = pl['songCount'] as int? ?? 0;
          final durationSec = pl['duration'] as int? ?? 0;
          final durationMin = durationSec ~/ 60;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.queue_music_rounded, color: Colors.orange),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$songCount songs • $durationMin mins'),
              trailing: const Icon(Icons.play_circle_fill_rounded, size: 28),
              onTap: () {
                showToast('Playing playlist $name');
              },
            ),
          );
        },
      ),
    );
  }

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
        if (_isSearching)
          const LinearProgressIndicator(),
        Expanded(
          child: _searchedSongs.isEmpty && _searchedAlbums.isEmpty
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
                            final title = album['title'] as String? ?? 'Untitled';
                            final coverId = album['coverArt'] as String? ?? albumId;

                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
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
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.music_note_rounded),
                          title: Text(song.title ?? song.name),
                          subtitle: Text(song.artist ?? 'Unknown Artist'),
                          onTap: () async {
                            final audioService = ref.read(audioServiceProvider);
                            await audioService.playPlaylist([song]);
                          },
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
