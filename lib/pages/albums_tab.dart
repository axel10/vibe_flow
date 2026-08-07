import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'package:vynody/models/album_summary.dart';
import 'package:vynody/player/library/album_library.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/playback_source.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import '../widgets/song_thumbnail.dart';
import 'album_detail_page.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../widgets/library_selection_scope.dart';
import '../widgets/library_selection_panel.dart';
import '../models/music_file.dart';

enum _AlbumSortField { artist, title, trackCount, duration, recentAdded }

class AlbumsTab extends ConsumerStatefulWidget {
  const AlbumsTab({super.key});

  @override
  ConsumerState<AlbumsTab> createState() => _AlbumsTabState();
}

class _AlbumsTabState extends ConsumerState<AlbumsTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  _AlbumSortField _sortField = _AlbumSortField.artist;
  bool _sortAscending = true;
  bool _is3DView = false;
  final Set<String> _selectedAlbumIds = {};

  List<AlbumSummary>? _lastRawAlbums;
  String? _lastSearchQuery;
  _AlbumSortField? _lastSortField;
  bool? _lastSortAscending;
  List<AlbumSummary>? _cachedFilteredAlbums;
  List<AlbumSummary>? _cachedKnownAlbums;
  List<AlbumSummary>? _cachedUnknownAlbums;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    final scopeNotifier = ref.read(librarySelectionScopeProvider.notifier);
    final currentScope = ref.read(librarySelectionScopeProvider);
    Future.microtask(() {
      if (currentScope == LibrarySelectionScope.album) {
        scopeNotifier.clear();
      }
    });
    super.dispose();
  }

  void _toggleAlbumSelection(String albumId) {
    setState(() {
      if (_selectedAlbumIds.contains(albumId)) {
        _selectedAlbumIds.remove(albumId);
        if (_selectedAlbumIds.isEmpty) {
          ref.read(librarySelectionScopeProvider.notifier).clear();
        }
      } else {
        _selectedAlbumIds.add(albumId);
      }
    });
  }

  void _enterAlbumSelectionMode(String albumId) {
    ref.read(librarySelectionScopeProvider.notifier).setScope(LibrarySelectionScope.album);
    setState(() {
      _selectedAlbumIds.clear();
      _selectedAlbumIds.add(albumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(albumLibraryProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final l10n = AppLocalizations.of(context)!;
    final selectionScope = ref.watch(librarySelectionScopeProvider);
    final isSelectionMode = selectionScope == LibrarySelectionScope.album;

    if (!isSelectionMode && _selectedAlbumIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedAlbumIds.clear();
          });
        }
      });
    }

    return albumsAsync.when(
      loading: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
      data: (albums) {
        if (!identical(_lastRawAlbums, albums) ||
            _lastSearchQuery != _searchQuery ||
            _lastSortField != _sortField ||
            _lastSortAscending != _sortAscending) {
          _lastRawAlbums = albums;
          _lastSearchQuery = _searchQuery;
          _lastSortField = _sortField;
          _lastSortAscending = _sortAscending;
          _cachedFilteredAlbums = _filterAndSortAlbums(albums);
          _cachedKnownAlbums = _cachedFilteredAlbums!
              .where((album) => !album.isUnknownAlbum)
              .toList(growable: false);
          _cachedUnknownAlbums = _cachedFilteredAlbums!
              .where((album) => album.isUnknownAlbum)
              .toList(growable: false);
        }
        final visibleAlbums = _cachedFilteredAlbums!;
        final knownAlbums = _cachedKnownAlbums!;
        final unknownAlbums = _cachedUnknownAlbums!;

        final List<MusicFile> selectedSongs;
        final List<MusicFile> allSongs;

        if (isSelectionMode) {
          selectedSongs = <MusicFile>[];
          final seenSelectedPaths = <String>{};
          for (final album in visibleAlbums) {
            if (_selectedAlbumIds.contains(album.id)) {
              for (final song in album.songs) {
                if (seenSelectedPaths.add(song.path)) {
                  selectedSongs.add(song);
                }
              }
            }
          }

          allSongs = <MusicFile>[];
          final seenAllPaths = <String>{};
          for (final album in visibleAlbums) {
            for (final song in album.songs) {
              if (seenAllPaths.add(song.path)) {
                allSongs.add(song);
              }
            }
          }
        } else {
          selectedSongs = const [];
          allSongs = const [];
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 780;
                final crossAxisCount = switch (constraints.maxWidth) {
                  >= 1350 => 6,
                  >= 1100 => 5,
                  >= 850 => 4,
                  >= 650 => 3,
                  _ => 2,
                };

                final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
                final textScale = MediaQuery.textScalerOf(context).scale(10) / 10;
                final clampedScale = textScale.clamp(1.0, 1.3);
                final double textHeight = (isPortrait ? 92.0 : 108.0) * clampedScale;
                final itemWidth = (constraints.maxWidth - 32 - (crossAxisCount - 1) * 16) / crossAxisCount;
                final childAspectRatio = itemWidth / (itemWidth + textHeight);

                final bottomPadding = 120.0 + (isSelectionMode ? 220.0 : 0.0);
                final bottomOffset = (currentMusic != null ? 140.0 : 40.0) + (isSelectionMode ? 220.0 : 0.0);

                final toolbar = _AlbumsToolbar(
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  sortField: _sortField,
                  sortAscending: _sortAscending,
                  albumCount: visibleAlbums.length,
                  isWide: isWide,
                  is3DView: _is3DView,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  onSearchCleared: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  onSortFieldSelected: (field) {
                    setState(() {
                      _sortField = field;
                    });
                  },
                  onSortOrderToggled: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                  },
                  onViewModeToggled: () {
                    setState(() {
                      _is3DView = !_is3DView;
                    });
                  },
                );

                final Widget mainContent;
                if (_is3DView) {
                  mainContent = Column(
                    children: [
                      toolbar,
                      Expanded(
                        child: visibleAlbums.isEmpty
                            ? Center(
                                child: Text(
                                  l10n.noAlbums,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              )
                            : _Album3DCoverFlowView(
                                albums: visibleAlbums,
                                isSelectionMode: isSelectionMode,
                                selectedAlbumIds: _selectedAlbumIds,
                                bottomOffset: bottomOffset,
                                onToggleSelection: _toggleAlbumSelection,
                                onEnterSelectionMode: _enterAlbumSelectionMode,
                              ),
                      ),
                    ],
                  );
                } else {
                  mainContent = ScrollToTopWrapper(
                    scrollController: _scrollController,
                    bottomOffset: bottomOffset,
                    child: CustomScrollView(
                      controller: _scrollController,
                      cacheExtent: 1000,
                      slivers: [
                        SliverToBoxAdapter(child: toolbar),
                        if (visibleAlbums.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                l10n.noAlbums,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          )
                        else ...[
                          if (knownAlbums.isNotEmpty) ...[
                            const SliverToBoxAdapter(child: SizedBox(height: 16)),
                            ..._albumSectionSlivers(
                              title: "",
                              albums: knownAlbums,
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              isSelectionMode: isSelectionMode,
                            ),
                          ],
                          if (knownAlbums.isNotEmpty && unknownAlbums.isNotEmpty)
                            const SliverToBoxAdapter(child: SizedBox(height: 24)),
                          if (unknownAlbums.isNotEmpty)
                            ..._albumSectionSlivers(
                              title: l10n.unknownAlbum,
                              albums: unknownAlbums,
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              isSelectionMode: isSelectionMode,
                            ),
                          SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
                        ],
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    Positioned.fill(child: mainContent),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        reverseDuration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0, 1.0),
                            end: Offset.zero,
                          ).animate(animation);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                        child: isSelectionMode
                            ? LibrarySelectionPanel(
                                key: const ValueKey('album-selection-panel'),
                                selectedSongs: selectedSongs,
                                allSongs: allSongs,
                                title: l10n.selectedAlbumsCount(_selectedAlbumIds.length),
                                onToggleSelectAll: () {
                                  final isAllSelected = _selectedAlbumIds.length == visibleAlbums.length && visibleAlbums.isNotEmpty;
                                  setState(() {
                                    if (isAllSelected) {
                                      _selectedAlbumIds.clear();
                                      ref.read(librarySelectionScopeProvider.notifier).clear();
                                    } else {
                                      _selectedAlbumIds.clear();
                                      _selectedAlbumIds.addAll(visibleAlbums.map((a) => a.id));
                                    }
                                  });
                                },
                                onCancel: () {
                                  setState(() {
                                    _selectedAlbumIds.clear();
                                  });
                                  ref.read(librarySelectionScopeProvider.notifier).clear();
                                },
                              )
                            : const SizedBox.shrink(key: ValueKey('album-selection-panel-hidden')),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<AlbumSummary> _filterAndSortAlbums(List<AlbumSummary> albums) {
    final query = _searchQuery.toLowerCase();
    final filtered = albums.where((album) {
      if (query.isEmpty) return true;
      return album.title.toLowerCase().contains(query) ||
          album.artist.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      final compare = switch (_sortField) {
        _AlbumSortField.artist => a.artist.toLowerCase().compareTo(
          b.artist.toLowerCase(),
        ),
        _AlbumSortField.title => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
        _AlbumSortField.trackCount => a.trackCount.compareTo(b.trackCount),
        _AlbumSortField.duration => a.totalDurationMillis.compareTo(
          b.totalDurationMillis,
        ),
        _AlbumSortField.recentAdded => a.latestTimestampMillis.compareTo(
          b.latestTimestampMillis,
        ),
      };
      if (compare != 0) {
        return _sortAscending ? compare : -compare;
      }
      final fallback = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      return _sortAscending ? fallback : -fallback;
    });
    return filtered;
  }

  List<Widget> _albumSectionSlivers({
    required String? title,
    required List<AlbumSummary> albums,
    required int crossAxisCount,
    required double childAspectRatio,
    required bool isSelectionMode,
  }) {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final album = albums[index];
              final isSelected = _selectedAlbumIds.contains(album.id);
              return _AlbumCard(
                album: album,
                isSelectionMode: isSelectionMode,
                isSelected: isSelected,
                onTap: () {
                  if (isSelectionMode) {
                    _toggleAlbumSelection(album.id);
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => AlbumDetailPage(album: album)),
                    );
                  }
                },
                onLongPress: () {
                  if (isSelectionMode) {
                    _toggleAlbumSelection(album.id);
                  } else {
                    _enterAlbumSelectionMode(album.id);
                  }
                },
              );
            },
            childCount: albums.length,
          ),
        ),
      ),
    ];
  }
}

class _AlbumCard extends ConsumerWidget {
  const _AlbumCard({
    required this.album,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  final AlbumSummary album;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final audio = ref.read(audioServiceProvider);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapDown: (details) {
          if (!isSelectionMode) {
            _showAlbumContextMenu(context, ref, album);
          }
        },
        onLongPress: () {
          if (onLongPress != null) {
            onLongPress!();
          } else if (!isSelectionMode) {
            _showAlbumContextMenu(context, ref, album);
          }
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () => _openAlbumDetail(context),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
                  theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                ],
              ),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'album-cover-${album.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SongThumbnail(
                            path: album.representativeSong.path,
                            id: album.representativeSong.id,
                            size: 250,
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: BorderRadius.zero,
                          ),
                          if (isSelectionMode)
                            Positioned.fill(
                              child: Container(
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                                    : Colors.black26,
                              ),
                            ),
                          if (isSelectionMode)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: SizedBox(
                                width: 28,
                                height: 28,
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
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isPortrait ? 10 : 12,
                      isPortrait ? 8 : 10,
                      isPortrait ? 10 : 12,
                      isPortrait ? 6 : 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              album.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: (isPortrait
                                      ? theme.textTheme.titleSmall
                                      : theme.textTheme.titleMedium)
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              album.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: (isPortrait
                                      ? theme.textTheme.bodySmall
                                      : theme.textTheme.bodyMedium)
                                  ?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.songCount(album.trackCount),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: isPortrait ? 10 : 11,
                                ),
                              ),
                            ),
                            if (!isSelectionMode)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: l10n.playAll,
                                onPressed: () => audio.playPlaylist(
                                  album.songs,
                                  source: PlaybackSource(
                                    type: PlaybackSourceType.album,
                                    id: album.id,
                                    name: album.title,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.play_circle_filled,
                                  size: isPortrait ? 22 : 26,
                                  color: theme.colorScheme.primary,
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
  }

  void _openAlbumDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AlbumDetailPage(album: album)),
    );
  }
}

Future<void> _showAlbumContextMenu(
  BuildContext context,
  WidgetRef ref,
  AlbumSummary album,
) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: GestureDetector(
                  onTap: () {}, // Prevent taps on the card itself from closing the sheet
                  child: Material(
                    elevation: 16,
                    color: theme.colorScheme.surface,
                    shadowColor: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header showing Album title and artwork
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: SongThumbnail(
                                    path: album.representativeSong.path,
                                    id: album.representativeSong.id,
                                    size: 52,
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
                                      album.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      album.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          // Actions list
                          _buildBottomSheetItem(
                            context: context,
                            value: 'play_all',
                            label: l10n.playAll,
                            icon: Icons.play_arrow_rounded,
                          ),
                          _buildBottomSheetItem(
                            context: context,
                            value: 'shuffle',
                            label: l10n.shufflePlay,
                            icon: Icons.shuffle_rounded,
                          ),
                          _buildBottomSheetItem(
                            context: context,
                            value: 'play_next',
                            label: l10n.playNext,
                            icon: Icons.queue_play_next_rounded,
                          ),
                          _buildBottomSheetItem(
                            context: context,
                            value: 'add_to_playlist',
                            label: l10n.addToPlaylist,
                            icon: Icons.playlist_add_rounded,
                          ),
                          _buildBottomSheetItem(
                            context: context,
                            value: 'add_to_favorites',
                            label: l10n.addToFavorites,
                            icon: Icons.favorite_border_rounded,
                          ),
                          _buildBottomSheetItem(
                            context: context,
                            value: 'copy_album',
                            label: l10n.copyAlbumTitle,
                            icon: Icons.copy_rounded,
                          ),
                          _buildBottomSheetItem(
                            context: context,
                            value: 'copy_artist',
                            label: l10n.copyArtistName,
                            icon: Icons.person_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!context.mounted || selected == null) return;

    switch (selected) {
      case 'play_all':
        await ref.read(audioServiceProvider).playPlaylist(
          album.songs,
          source: PlaybackSource(
            type: PlaybackSourceType.album,
            id: album.id,
            name: album.title,
          ),
        );
        break;
      case 'shuffle':
        await ref.read(audioServiceProvider).playPlaylist(
          List.of(album.songs)..shuffle(),
          source: PlaybackSource(
            type: PlaybackSourceType.album,
            id: album.id,
            name: album.title,
          ),
        );
        break;
      case 'play_next':
        await ref.read(audioServiceProvider).enqueueNext(album.songs);
        break;
      case 'add_to_playlist':
        await showAddSongsToPlaylistDialog(
          context,
          ref.read(playlistServiceProvider),
          album.songs,
        );
        break;
      case 'add_to_favorites':
        for (final song in album.songs) {
          await ref.read(playlistServiceProvider).addSongToFavorite(song);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.addToFavorites} · ${album.trackCount}'),
            ),
          );
        }
        break;
      case 'copy_album':
        await Clipboard.setData(ClipboardData(text: album.title));
        break;
      case 'copy_artist':
        await Clipboard.setData(ClipboardData(text: album.artist));
        break;
    }
  }

  Widget _buildBottomSheetItem({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () => Navigator.pop(context, value),
    );
  }

class _AlbumsToolbar extends StatelessWidget {
  const _AlbumsToolbar({
    required this.searchController,
    required this.searchQuery,
    required this.sortField,
    required this.sortAscending,
    required this.albumCount,
    required this.isWide,
    required this.is3DView,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onSortFieldSelected,
    required this.onSortOrderToggled,
    required this.onViewModeToggled,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final _AlbumSortField sortField;
  final bool sortAscending;
  final int albumCount;
  final bool isWide;
  final bool is3DView;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final ValueChanged<_AlbumSortField> onSortFieldSelected;
  final VoidCallback onSortOrderToggled;
  final VoidCallback onViewModeToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isZh = Localizations.localeOf(context).languageCode == 'zh';

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.albums,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.albumCount(albumCount),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    final searchField = TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: l10n.searchAlbums,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
        ),
        suffixIcon: searchQuery.isEmpty
            ? null
            : IconButton(
                onPressed: onSearchCleared,
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                  size: 18,
                ),
              ),
        filled: true,
        fillColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      style: TextStyle(
        color: theme.colorScheme.onSecondaryContainer,
        fontSize: 14,
      ),
    );

    final sortControls = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton.filledTonal(
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          padding: EdgeInsets.zero,
          tooltip: is3DView
              ? (isZh ? '网格视图' : 'Grid View')
              : (isZh ? '3D 视图' : '3D View'),
          onPressed: onViewModeToggled,
          icon: Icon(
            is3DView ? Icons.grid_view_rounded : Icons.view_carousel_rounded,
          ),
        ),
        PopupMenuButton<_AlbumSortField>(
          tooltip: l10n.albumSort,
          onSelected: onSortFieldSelected,
          itemBuilder: (context) => [
            buildContextMenuItem<_AlbumSortField>(
              value: _AlbumSortField.artist,
              label: l10n.sortArtistAsc,
              icon: Icons.person_rounded,
              context: context,
            ),
            buildContextMenuItem<_AlbumSortField>(
              value: _AlbumSortField.title,
              label: l10n.sortTitleAsc,
              icon: Icons.title_rounded,
              context: context,
            ),
            buildContextMenuItem<_AlbumSortField>(
              value: _AlbumSortField.trackCount,
              label: l10n.sortTrackCount,
              icon: Icons.format_list_numbered_rounded,
              context: context,
            ),
            buildContextMenuItem<_AlbumSortField>(
              value: _AlbumSortField.duration,
              label: l10n.sortDuration,
              icon: Icons.access_time_rounded,
              context: context,
            ),
            buildContextMenuItem<_AlbumSortField>(
              value: _AlbumSortField.recentAdded,
              label: l10n.sortRecentAdded,
              icon: Icons.add_circle_outline_rounded,
              context: context,
            ),
          ],
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort_rounded,
                  size: 18,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  _sortFieldLabel(l10n, sortField),
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton.filledTonal(
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          padding: EdgeInsets.zero,
          tooltip: sortAscending ? l10n.sortAscending : l10n.sortDescending,
          onPressed: onSortOrderToggled,
          icon: Icon(
            sortAscending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(flex: 3, child: titleBlock),
                Expanded(flex: 5, child: searchField),
                const SizedBox(width: 12),
                sortControls,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: titleBlock),
                    sortControls,
                  ],
                ),
                const SizedBox(height: 12),
                searchField,
              ],
            ),
    );
  }

  String _sortFieldLabel(AppLocalizations l10n, _AlbumSortField field) {
    return switch (field) {
      _AlbumSortField.artist => l10n.sortArtistAsc,
      _AlbumSortField.title => l10n.sortTitleAsc,
      _AlbumSortField.trackCount => l10n.sortTrackCount,
      _AlbumSortField.duration => l10n.sortDuration,
      _AlbumSortField.recentAdded => l10n.sortRecentAdded,
    };
  }
}

class _Album3DCoverFlowView extends ConsumerStatefulWidget {
  const _Album3DCoverFlowView({
    required this.albums,
    required this.isSelectionMode,
    required this.selectedAlbumIds,
    required this.bottomOffset,
    required this.onToggleSelection,
    required this.onEnterSelectionMode,
  });

  final List<AlbumSummary> albums;
  final bool isSelectionMode;
  final Set<String> selectedAlbumIds;
  final double bottomOffset;
  final ValueChanged<String> onToggleSelection;
  final ValueChanged<String> onEnterSelectionMode;

  @override
  ConsumerState<_Album3DCoverFlowView> createState() =>
      _Album3DCoverFlowViewState();
}

class _Album3DCoverFlowViewState extends ConsumerState<_Album3DCoverFlowView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Animation<double>? _animation;
  double _currentPage = 0.0;
  int _targetIndex = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didUpdateWidget(covariant _Album3DCoverFlowView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.albums.isEmpty) {
      _currentPage = 0.0;
      _targetIndex = 0;
    } else if (_targetIndex >= widget.albums.length) {
      _targetIndex = widget.albums.length - 1;
      _animateToPage(_targetIndex);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _animateToPage(int pageIndex, {Duration duration = const Duration(milliseconds: 350)}) {
    if (widget.albums.isEmpty) return;
    final clamped = pageIndex.clamp(0, widget.albums.length - 1);
    final target = clamped.toDouble();
    _targetIndex = clamped;

    if (_currentPage == target) return;

    _animController.stop();
    final startPage = _currentPage;
    _animController.duration = duration;
    _animation = Tween<double>(begin: startPage, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _currentPage = _animation!.value;
        });
      });

    _animController.reset();
    _animController.forward();
  }

  void _onPointerScroll(PointerScrollEvent event) {
    if (widget.albums.isEmpty) return;
    if (event.scrollDelta.dy > 0 || event.scrollDelta.dx > 0) {
      _animateToPage(_targetIndex + 1);
    } else if (event.scrollDelta.dy < 0 || event.scrollDelta.dx < 0) {
      _animateToPage(_targetIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.albums.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final audio = ref.watch(audioServiceProvider);

    final activeIndex = _currentPage.round().clamp(0, widget.albums.length - 1);
    final activeAlbum = widget.albums[activeIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final stageWidth = constraints.maxWidth;
        final stageHeight = constraints.maxHeight;

        final double availableHeight = (stageHeight - widget.bottomOffset).clamp(100.0, stageHeight);
        final isWide = stageWidth >= 780;
        final double coverSize = (isWide ? 260.0 : 200.0).clamp(140.0, availableHeight * 0.46);

        final int range = ((stageWidth / 2) / (coverSize * 0.44)).ceil().clamp(5, 16);
        final minIndex = (_currentPage - range).floor().clamp(0, widget.albums.length - 1);
        final maxIndex = (_currentPage + range).ceil().clamp(0, widget.albums.length - 1);

        final visibleIndices = List.generate(maxIndex - minIndex + 1, (i) => minIndex + i);
        visibleIndices.sort((a, b) {
          final distA = (a - _currentPage).abs();
          final distB = (b - _currentPage).abs();
          return distB.compareTo(distA);
        });

        final double stageCenterY = (availableHeight * 0.38).clamp(coverSize * 0.52, availableHeight * 0.48);

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                _animateToPage(_targetIndex - 1);
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                _animateToPage(_targetIndex + 1);
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                _onPointerScroll(pointerSignal);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) {
                _animController.stop();
              },
              onHorizontalDragUpdate: (details) {
                final deltaPages = details.primaryDelta! / (coverSize * 0.7);
                setState(() {
                  _currentPage = (_currentPage - deltaPages)
                      .clamp(-0.5, widget.albums.length - 0.5);
                  _targetIndex = _currentPage.round().clamp(0, widget.albums.length - 1);
                });
              },
              onHorizontalDragEnd: (details) {
                int nearest = _currentPage.round().clamp(0, widget.albums.length - 1);
                final velocity = details.primaryVelocity ?? 0;
                if (velocity.abs() > 200) {
                  final step = velocity < 0 ? 1 : -1;
                  nearest = (_currentPage + step).round().clamp(0, widget.albums.length - 1);
                }
                _animateToPage(nearest);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.3),
                          radius: 0.85,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                            theme.colorScheme.surface.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ...visibleIndices.map((i) {
                    final album = widget.albums[i];
                    final delta = i - _currentPage;
                    final absD = delta.abs();

                    final sign = delta.sign;
                    final baseGap = coverSize * 0.70;
                    final stepGap = coverSize * 0.38;
                    double xOffset = 0.0;
                    if (absD > 0) {
                      if (absD <= 1.0) {
                        xOffset = sign * (absD * baseGap);
                      } else {
                        xOffset = sign * (baseGap + (absD - 1.0) * stepGap);
                      }
                    }

                    final double distFromCenter = xOffset.abs();
                    final double stageHalfWidth = stageWidth / 2;
                    double opacity = 1.0;

                    if (distFromCenter > stageHalfWidth + coverSize * 0.5) {
                      opacity = 0.0;
                    } else if (distFromCenter > stageHalfWidth - 80.0) {
                      final fadeProgress = (stageHalfWidth + coverSize * 0.5 - distFromCenter) / (coverSize * 0.5 + 80.0);
                      opacity = (fadeProgress * fadeProgress).clamp(0.0, 1.0);
                    } else {
                      opacity = (1.0 - (absD - 1.0) * 0.05).clamp(0.55, 1.0);
                    }

                    if (opacity <= 0.001) {
                      return const SizedBox.shrink();
                    }

                    double rotationY = 0.0;
                    if (delta > 0) {
                      rotationY = -1.02 * delta.clamp(0.0, 1.0);
                    } else if (delta < 0) {
                      rotationY = 1.02 * (-delta).clamp(0.0, 1.0);
                    }

                    double scale = 1.0;
                    if (absD <= 1.0) {
                      scale = 1.06 - absD * 0.16;
                    } else {
                      scale = (0.90 - (absD - 1.0) * 0.08).clamp(0.58, 1.06);
                    }

                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, -0.0009)
                      ..translate(xOffset, 0.0, 0.0)
                      ..rotateY(rotationY)
                      ..scale(scale, scale, 1.0);

                    final isSelected = widget.selectedAlbumIds.contains(album.id);

                    return Positioned(
                      left: (stageWidth - coverSize) / 2,
                      top: stageCenterY - (coverSize * 0.5),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: transform,
                        child: Opacity(
                          opacity: opacity,
                          child: GestureDetector(
                            onTap: () {
                              if (absD < 0.3) {
                                if (widget.isSelectionMode) {
                                  widget.onToggleSelection(album.id);
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => AlbumDetailPage(album: album),
                                    ),
                                  );
                                }
                              } else {
                                _animateToPage(i);
                              }
                            },
                            onLongPress: () {
                              if (widget.isSelectionMode) {
                                widget.onToggleSelection(album.id);
                              } else {
                                widget.onEnterSelectionMode(album.id);
                              }
                            },
                            onSecondaryTapDown: (_) {
                              if (!widget.isSelectionMode) {
                                _showAlbumContextMenu(context, ref, album);
                              }
                            },
                            child: _Album3DCoverCard(
                              album: album,
                              coverSize: coverSize,
                              isSelected: isSelected,
                              isSelectionMode: widget.isSelectionMode,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Left edge gradient vignette
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: widget.bottomOffset,
                    width: 40,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              theme.colorScheme.surface.withValues(alpha: 0.7),
                              theme.colorScheme.surface.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Right edge gradient vignette
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: widget.bottomOffset,
                    width: 40,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              theme.colorScheme.surface.withValues(alpha: 0.7),
                              theme.colorScheme.surface.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (widget.albums.length > 1) ...[
                    Positioned(
                      left: 16,
                      top: stageCenterY - 24,
                      child: IconButton.filledTonal(
                        onPressed: _targetIndex > 0
                            ? () => _animateToPage(_targetIndex - 1)
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded, size: 28),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: stageCenterY - 24,
                      child: IconButton.filledTonal(
                        onPressed: _targetIndex < widget.albums.length - 1
                            ? () => _animateToPage(_targetIndex + 1)
                            : null,
                        icon: const Icon(Icons.chevron_right_rounded, size: 28),
                      ),
                    ),
                  ],
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: widget.bottomOffset + 12.0,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Column(
                            key: ValueKey(activeAlbum.id),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                activeAlbum.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${activeAlbum.artist}  ·  ${l10n.songCount(activeAlbum.trackCount)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () {
                                      audio.playPlaylist(
                                        activeAlbum.songs,
                                        source: PlaybackSource(
                                          type: PlaybackSourceType.album,
                                          id: activeAlbum.id,
                                          name: activeAlbum.title,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: Text(l10n.playAll),
                                  ),
                                  FilledButton.tonalIcon(
                                    onPressed: () {
                                      audio.playPlaylist(
                                        List.of(activeAlbum.songs)..shuffle(),
                                        source: PlaybackSource(
                                          type: PlaybackSourceType.album,
                                          id: activeAlbum.id,
                                          name: activeAlbum.title,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.shuffle_rounded),
                                    label: Text(l10n.shufflePlay),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              AlbumDetailPage(album: activeAlbum),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.album_rounded),
                                    label: Text(
                                      Localizations.localeOf(context).languageCode == 'zh'
                                          ? '查看详情'
                                          : 'Details',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Album3DCoverCard extends StatelessWidget {
  const _Album3DCoverCard({
    required this.album,
    required this.coverSize,
    required this.isSelected,
    required this.isSelectionMode,
  });

  final AlbumSummary album;
  final double coverSize;
  final bool isSelected;
  final bool isSelectionMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryAnimation = ModalRoute.of(context)?.secondaryAnimation;

    Widget reflectionWidget = SizedBox(
      width: coverSize,
      height: coverSize * 0.4,
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.38),
              Colors.black.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ClipRect(
          child: OverflowBox(
            minWidth: coverSize,
            maxWidth: coverSize,
            minHeight: coverSize,
            maxHeight: coverSize,
            alignment: Alignment.topCenter,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(1.0, -1.0, 1.0),
              child: SongThumbnail(
                path: album.representativeSong.path,
                id: album.representativeSong.id,
                size: coverSize,
                width: coverSize,
                height: coverSize,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
      ),
    );

    if (secondaryAnimation != null) {
      reflectionWidget = AnimatedBuilder(
        animation: secondaryAnimation,
        builder: (context, child) {
          final progress = (1.0 - secondaryAnimation.value).clamp(0.0, 1.0);
          final opacity = const Interval(0.35, 1.0, curve: Curves.easeOutCubic).transform(progress);
          return Opacity(
            opacity: opacity,
            child: child,
          );
        },
        child: reflectionWidget,
      );
    }

    return SizedBox(
      width: coverSize,
      height: coverSize * 1.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'album-cover-${album.id}',
            child: Container(
              width: coverSize,
              height: coverSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SongThumbnail(
                      path: album.representativeSong.path,
                      id: album.representativeSong.id,
                      size: coverSize,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.zero,
                    ),
                    if (isSelectionMode) ...[
                      Positioned.fill(
                        child: Container(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                              : Colors.black38,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isSelected ? theme.colorScheme.primary : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          reflectionWidget,
        ],
      ),
    );
  }
}
