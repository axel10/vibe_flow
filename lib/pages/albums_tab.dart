import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'cover_flow/album_3d_cover_flow_view.dart';
import 'cover_flow/floating_cover_flow_toolbar.dart';
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
import '../dialogs/sort_options_dialog.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'main_layout_riverpod.dart';
import 'package:vynody/utils/layout_constants.dart';

class AlbumsTab extends ConsumerStatefulWidget {
  const AlbumsTab({
    super.key,
    this.initial3DView = false,
    this.initial3DIndex = 0,
    this.contentTopPadding = 0.0,
    this.contentLeftPadding = 0.0,
  });

  final bool initial3DView;
  final int initial3DIndex;
  final double contentTopPadding;
  final double contentLeftPadding;

  @override
  ConsumerState<AlbumsTab> createState() => _AlbumsTabState();
}

class _AlbumsTabState extends ConsumerState<AlbumsTab>
    with SelectionStateMixin<AlbumsTab, String> {
  @override
  LibrarySelectionScope get selectionScope => LibrarySelectionScope.album;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  AlbumSortField _sortField = AlbumSortField.artist;
  bool _sortAscending = true;
  late bool _is3DView;
  bool _isShuffledMode = false;
  List<AlbumSummary>? _shuffledAlbums;
  final GlobalKey<Album3DCoverFlowViewState> _coverFlowKey = GlobalKey();

  List<AlbumSummary>? _lastRawAlbums;
  String? _lastSearchQuery;
  AlbumSortField? _lastSortField;
  bool? _lastSortAscending;
  List<AlbumSummary>? _cachedFilteredAlbums;
  List<AlbumSummary>? _cachedKnownAlbums;
  List<AlbumSummary>? _cachedUnknownAlbums;
  late final IsAlbum3DViewActiveNotifier _isAlbum3DNotifier;

  @override
  void initState() {
    super.initState();
    _isAlbum3DNotifier = ref.read(isAlbum3DViewActiveProvider.notifier);
    _is3DView = widget.initial3DView;
    final settings = ref.read(settingsServiceProvider);
    _sortField = settings.albumSortField;
    _sortAscending = settings.albumSortAscending;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _isAlbum3DNotifier.set(_is3DView);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _isAlbum3DNotifier.set(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isAlbum3DViewActiveProvider, (prev, next) {
      if (_is3DView != next) {
        setState(() {
          _is3DView = next;
        });
      }
    });

    final albumsAsync = ref.watch(albumLibraryProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final l10n = AppLocalizations.of(context)!;

    final albums = albumsAsync.value ?? _lastRawAlbums;
    if (albums == null) {
      if (albumsAsync.isLoading) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              SizedBox(height: 12),
            ],
          ),
        );
      }
      if (albumsAsync.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              albumsAsync.error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }
        if (!identical(_lastRawAlbums, albums) ||
            _lastSearchQuery != _searchQuery ||
            _lastSortField != _sortField ||
            _lastSortAscending != _sortAscending) {
          if (_lastSortField != _sortField || _lastSortAscending != _sortAscending) {
            _isShuffledMode = false;
            _shuffledAlbums = null;
          }
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
            if (isSelected(album.id)) {
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
            constraints: const BoxConstraints(maxWidth: kMultiColumnGridMaxWidth),
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
                final bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
                final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                final bool isCoverFlowImmersive = isLandscape && _is3DView;

                final textScale = MediaQuery.textScalerOf(context).scale(10) / 10;
                final clampedScale = textScale.clamp(1.0, 1.3);
                final double textHeight = (isPortrait ? 92.0 : 108.0) * clampedScale;
                final itemWidth = (constraints.maxWidth - 32 - (crossAxisCount - 1) * 16) / crossAxisCount;
                final childAspectRatio = itemWidth / (itemWidth + textHeight);

                final bottomPadding = 120.0 + (isSelectionMode ? 220.0 : 0.0);
                final bottomOffset = isCoverFlowImmersive
                    ? (isSelectionMode ? 120.0 : 0.0)
                    : ((currentMusic != null ? (isLandscape ? 96.0 : 140.0) : 40.0) + (isSelectionMode ? 220.0 : 0.0));

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
                  onSortChanged: (field, sortAscending) {
                    setState(() {
                      _sortField = field;
                      _sortAscending = sortAscending;
                      _isShuffledMode = false;
                      _shuffledAlbums = null;
                    });
                    final settings = ref.read(settingsServiceProvider);
                    settings.albumSortField = field;
                    settings.albumSortAscending = sortAscending;
                  },
                  onViewModeToggled: () {
                    setState(() {
                      _is3DView = !_is3DView;
                    });
                    ref.read(isAlbum3DViewActiveProvider.notifier).set(_is3DView);
                  },
                  onShufflePressed: () => _onShufflePressed(albums),
                );

                final Widget mainContent = AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: _is3DView
                      ? KeyedSubtree(
                          key: const ValueKey('album_3d_cover_flow_view'),
                          child: isCoverFlowImmersive
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Positioned.fill(
                                      child: visibleAlbums.isEmpty
                                          ? Center(
                                              child: Text(
                                                l10n.noAlbums,
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                            )
                                          : Album3DCoverFlowView(
                                              key: _coverFlowKey,
                                              albums: visibleAlbums,
                                              initialIndex: widget.initial3DIndex,
                                              isSelectionMode: isSelectionMode,
                                              selectedAlbumIds: selectedKeys,
                                              bottomOffset: bottomOffset,
                                              isHeroEnabled: _is3DView,
                                              onToggleSelection: toggleSelection,
                                              onEnterSelectionMode: enterSelectionMode,
                                              onExit3DView: () {
                                                setState(() {
                                                  _is3DView = false;
                                                });
                                                ref.read(isAlbum3DViewActiveProvider.notifier).set(false);
                                              },
                                            ),
                                    ),
                                    Positioned(
                                      top: MediaQuery.of(context).padding.top + (isDesktop ? 36 : 8),
                                      left: isDesktop ? 80 : 16,
                                      right: isDesktop ? 80 : 16,
                                      child: FloatingCoverFlowToolbar(
                                        albumCount: visibleAlbums.length,
                                        sortField: _sortField,
                                        sortAscending: _sortAscending,
                                        searchController: _searchController,
                                        searchQuery: _searchQuery,
                                        isDesktop: isDesktop,
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
                                        onViewModeToggled: () {
                                          setState(() {
                                            _is3DView = !_is3DView;
                                          });
                                          ref.read(isAlbum3DViewActiveProvider.notifier).set(_is3DView);
                                        },
                                        onShufflePressed: () => _onShufflePressed(albums),
                                        onSortChanged: (field, sortAscending) {
                                          setState(() {
                                            _sortField = field;
                                            _sortAscending = sortAscending;
                                            _isShuffledMode = false;
                                            _shuffledAlbums = null;
                                          });
                                          final settings = ref.read(settingsServiceProvider);
                                          settings.albumSortField = field;
                                          settings.albumSortAscending = sortAscending;
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding: EdgeInsets.only(
                                    top: widget.contentTopPadding,
                                    left: widget.contentLeftPadding,
                                  ),
                                  child: Column(
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
                                            : Album3DCoverFlowView(
                                                key: _coverFlowKey,
                                                albums: visibleAlbums,
                                                initialIndex: widget.initial3DIndex,
                                                isSelectionMode: isSelectionMode,
                                                selectedAlbumIds: selectedKeys,
                                                bottomOffset: bottomOffset,
                                                isHeroEnabled: _is3DView,
                                                onToggleSelection: toggleSelection,
                                                onEnterSelectionMode: enterSelectionMode,
                                                onAlbumContextMenu: (album) =>
                                                    _showAlbumContextMenu(context, ref, album),
                                                onExit3DView: () {
                                                  setState(() {
                                                    _is3DView = false;
                                                  });
                                                  ref.read(isAlbum3DViewActiveProvider.notifier).set(false);
                                                },
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                            top: widget.contentTopPadding,
                            left: widget.contentLeftPadding,
                          ),
                          child: ScrollToTopWrapper(
                            key: const ValueKey('album_grid_view'),
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
                                      isHeroEnabled: !_is3DView,
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
                                      isHeroEnabled: !_is3DView,
                                    ),
                                  SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
                                ],
                              ],
                            ),
                          ),
                        ),
                );

                return Stack(
                  children: [
                    Positioned.fill(child: mainContent),
                    AnimatedSelectionPanel(
                      isVisible: isSelectionMode,
                      child: LibrarySelectionPanel(
                        key: const ValueKey('album-selection-panel'),
                        selectedSongs: selectedSongs,
                        allSongs: allSongs,
                        title: l10n.selectedAlbumsCount(selectedCount),
                        onToggleSelectAll: () =>
                            toggleSelectAll(visibleAlbums.map((a) => a.id)),
                        onCancel: cancelSelection,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
  }

  void _onShufflePressed(List<AlbumSummary> albums) {
    final coverFlowState = _coverFlowKey.currentState;
    void doShuffle() {
      setState(() {
        _isShuffledMode = true;
        final baseFiltered = _filterAndSortAlbums(albums, ignoreShuffle: true);
        _shuffledAlbums = List<AlbumSummary>.from(baseFiltered)..shuffle();
        _cachedFilteredAlbums = _shuffledAlbums;
        _cachedKnownAlbums = _cachedFilteredAlbums!
            .where((album) => !album.isUnknownAlbum)
            .toList(growable: false);
        _cachedUnknownAlbums = _cachedFilteredAlbums!
            .where((album) => album.isUnknownAlbum)
            .toList(growable: false);
      });
    }

    if (coverFlowState != null) {
      coverFlowState.animateShuffle(doShuffle);
    } else {
      doShuffle();
    }
  }

  List<AlbumSummary> _filterAndSortAlbums(
    List<AlbumSummary> albums, {
    bool ignoreShuffle = false,
  }) {
    if (_isShuffledMode && !ignoreShuffle && _shuffledAlbums != null) {
      if (_searchQuery.isEmpty) {
        return _shuffledAlbums!;
      } else {
        final query = _searchQuery.toLowerCase();
        return _shuffledAlbums!.where((album) {
          return album.title.toLowerCase().contains(query) ||
              album.artist.toLowerCase().contains(query);
        }).toList();
      }
    }

    final query = _searchQuery.toLowerCase();
    final filtered = albums.where((album) {
      if (query.isEmpty) return true;
      return album.title.toLowerCase().contains(query) ||
          album.artist.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      final compare = switch (_sortField) {
        AlbumSortField.artist => a.artist.toLowerCase().compareTo(
          b.artist.toLowerCase(),
        ),
        AlbumSortField.title => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
        AlbumSortField.trackCount => a.trackCount.compareTo(b.trackCount),
        AlbumSortField.duration => a.totalDurationMillis.compareTo(
          b.totalDurationMillis,
        ),
        AlbumSortField.recentAdded => a.latestTimestampMillis.compareTo(
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
    bool isHeroEnabled = true,
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
              final isSelected = this.isSelected(album.id);
              return _AlbumCard(
                album: album,
                isSelectionMode: isSelectionMode,
                isSelected: isSelected,
                isHeroEnabled: isHeroEnabled,
                onTap: () {
                  handleItemTap(
                    index: index,
                    itemKey: album.id,
                    allKeys: albums.map((a) => a.id).toList(),
                    onNormalTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => AlbumDetailPage(album: album)),
                      );
                    },
                  );
                },
                onLongPress: () {
                  lastAnchorIndex = index;
                  if (isSelectionMode) {
                    toggleSelection(album.id);
                  } else {
                    enterSelectionMode(album.id);
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
    this.isHeroEnabled = true,
    this.onTap,
    this.onLongPress,
  });

  final AlbumSummary album;
  final bool isSelectionMode;
  final bool isSelected;
  final bool isHeroEnabled;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final audio = ref.read(audioServiceProvider);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final coverContent = ClipRRect(
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
              bytes: album.representativeSong.artworkBytes,
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
    );

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
          enableFeedback: false,
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
                isHeroEnabled
                    ? Hero(
                        tag: 'album-cover-${album.id}',
                        child: coverContent,
                      )
                    : coverContent,
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
      useRootNavigator: true,
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
    required this.onSortChanged,
    required this.onViewModeToggled,
    this.onShufflePressed,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final AlbumSortField sortField;
  final bool sortAscending;
  final int albumCount;
  final bool isWide;
  final bool is3DView;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final void Function(AlbumSortField field, bool sortAscending) onSortChanged;
  final VoidCallback onViewModeToggled;
  final VoidCallback? onShufflePressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
        if (is3DView)
          IconButton(
            tooltip: l10n.shuffleAlbumOrder,
            onPressed: onShufflePressed,
            icon: const Icon(Icons.shuffle_rounded),
          ),
        IconButton(
          tooltip: is3DView ? l10n.gridView : l10n.threeDView,
          onPressed: onViewModeToggled,
          icon: Icon(
            is3DView ? Icons.grid_view_rounded : Icons.view_carousel_rounded,
          ),
        ),
        IconButton(
          tooltip: l10n.albumSort,
          onPressed: () async {
            final result = await showDialog<SortResult<AlbumSortField>>(
              context: context,
              builder: (context) => SortOptionsDialog<AlbumSortField>(
                title: l10n.albumSort,
                currentField: sortField,
                sortAscending: sortAscending,
                options: [
                  SortOptionItem(
                    value: AlbumSortField.artist,
                    label: l10n.sortArtistAsc,
                    icon: Icons.person_rounded,
                  ),
                  SortOptionItem(
                    value: AlbumSortField.title,
                    label: l10n.sortTitleAsc,
                    icon: Icons.album_rounded,
                  ),
                  SortOptionItem(
                    value: AlbumSortField.trackCount,
                    label: l10n.sortTrackCount,
                    icon: Icons.format_list_numbered_rounded,
                  ),
                  SortOptionItem(
                    value: AlbumSortField.duration,
                    label: l10n.sortDuration,
                    icon: Icons.access_time_rounded,
                  ),
                  SortOptionItem(
                    value: AlbumSortField.recentAdded,
                    label: l10n.sortRecentAdded,
                    icon: Icons.add_circle_outline_rounded,
                  ),
                ],
              ),
            );
            if (result != null) {
              onSortChanged(result.field, result.sortAscending);
            }
          },
          icon: const Icon(Icons.sort_rounded),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: is3DView ? Colors.transparent : theme.colorScheme.surface,
        border: is3DView
            ? null
            : Border(
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
}

