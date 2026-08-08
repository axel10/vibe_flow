import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'package:vynody/models/artist_summary.dart';
import 'package:vynody/player/library/artist_library.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/playback_source.dart';
import 'artist_detail_page.dart';
import '../widgets/artist_avatar.dart';
import '../widgets/scroll_to_top_wrapper.dart';
import '../utils/song_context_menu_utils.dart';
import '../widgets/library_selection_scope.dart';
import '../widgets/library_selection_panel.dart';
import '../models/music_file.dart';
import '../dialogs/sort_options_dialog.dart';

enum _ArtistSortField { artist, songCount }

class ArtistsTab extends ConsumerStatefulWidget {
  const ArtistsTab({super.key});

  @override
  ConsumerState<ArtistsTab> createState() => _ArtistsTabState();
}

class _ArtistsTabState extends ConsumerState<ArtistsTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  _ArtistSortField _sortField = _ArtistSortField.artist;
  bool _sortAscending = true;
  String? _selectedArtistKey;
  final Set<String> _selectedArtistKeys = {};
  late final ArtistSongSelectionController _songSelectionController;

  List<ArtistSummary>? _lastRawArtists;
  String? _lastSearchQuery;
  _ArtistSortField? _lastSortField;
  bool? _lastSortAscending;
  List<ArtistSummary>? _cachedFilteredArtists;

  late final LibrarySelectionScopeController _librarySelectionScopeController;

  @override
  void initState() {
    super.initState();
    _librarySelectionScopeController =
        ref.read(librarySelectionScopeProvider.notifier);
    _songSelectionController = ArtistSongSelectionController()
      ..addListener(_onSongSelectionChanged);
  }

  void _onSongSelectionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _songSelectionController.removeListener(_onSongSelectionChanged);
    _songSelectionController.dispose();
    Future.microtask(() {
      _librarySelectionScopeController.clear();
    });
    super.dispose();
  }

  void _toggleArtistSelection(String artistKey) {
    setState(() {
      if (_selectedArtistKeys.contains(artistKey)) {
        _selectedArtistKeys.remove(artistKey);
        if (_selectedArtistKeys.isEmpty) {
          ref.read(librarySelectionScopeProvider.notifier).clear();
        }
      } else {
        _selectedArtistKeys.add(artistKey);
      }
    });
  }

  void _enterArtistSelectionMode(String artistKey) {
    ref.read(librarySelectionScopeProvider.notifier).setScope(LibrarySelectionScope.artist);
    setState(() {
      _selectedArtistKeys.clear();
      _selectedArtistKeys.add(artistKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final artistsAsync = ref.watch(artistLibraryProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final selectionScope = ref.watch(librarySelectionScopeProvider);
    final isSelectionMode = selectionScope == LibrarySelectionScope.artist;
    final isSongSelectionMode = selectionScope == LibrarySelectionScope.library;

    if (!isSelectionMode && _selectedArtistKeys.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedArtistKeys.clear();
          });
        }
      });
    }

    if (!isSongSelectionMode && _songSelectionController.isSelectionMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _songSelectionController.cancelSelection();
        }
      });
    }

    debugPrint(
      '[ArtistsTab] build loading=${artistsAsync.isLoading} '
      'hasValue=${artistsAsync.hasValue} hasError=${artistsAsync.hasError}',
    );
    final l10n = AppLocalizations.of(context)!;
    final artistsLabel = l10n.artists;
    final noArtistsLabel = l10n.noArtists;

    return artistsAsync.when(
      loading: () => const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
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
      data: (artists) {
        if (!identical(_lastRawArtists, artists) ||
            _lastSearchQuery != _searchQuery ||
            _lastSortField != _sortField ||
            _lastSortAscending != _sortAscending) {
          _lastRawArtists = artists;
          _lastSearchQuery = _searchQuery;
          _lastSortField = _sortField;
          _lastSortAscending = _sortAscending;
          _cachedFilteredArtists = _filterAndSortArtists(artists);
        }
        final visibleArtists = _cachedFilteredArtists!;

        final List<MusicFile> selectedSongs;
        final List<MusicFile> allSongs;

        if (isSelectionMode || isSongSelectionMode) {
          selectedSongs = <MusicFile>[];
          final seenSelectedPaths = <String>{};
          for (final artist in visibleArtists) {
            if (_selectedArtistKeys.contains(artist.queryKey)) {
              for (final song in artist.songs) {
                if (seenSelectedPaths.add(song.path)) {
                  selectedSongs.add(song);
                }
              }
            }
          }

          allSongs = <MusicFile>[];
          final seenAllPaths = <String>{};
          for (final artist in visibleArtists) {
            for (final song in artist.songs) {
              if (seenAllPaths.add(song.path)) {
                allSongs.add(song);
              }
            }
          }
        } else {
          selectedSongs = const [];
          allSongs = const [];
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape =
                MediaQuery.orientationOf(context) == Orientation.landscape;
            final selectedArtist = _resolveSelectedArtist(visibleArtists);

            Widget mainContent;

            if (isLandscape) {
              _syncSelectedArtist(visibleArtists);
              final showBottomPanel = isSelectionMode || (isLandscape && isSongSelectionMode);
              mainContent = Column(
                children: [
                  _ArtistsToolbar(
                    searchController: _searchController,
                    searchQuery: _searchQuery,
                    sortField: _sortField,
                    sortAscending: _sortAscending,
                    artistCount: visibleArtists.length,
                    artistsLabel: artistsLabel,
                    isWide: true,
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
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: constraints.maxWidth >= 1100 ? 380 : 320,
                            child: _ArtistListPane(
                              artists: visibleArtists,
                              selectedArtistKey: selectedArtist?.queryKey,
                              noArtistsLabel: noArtistsLabel,
                              scrollController: _scrollController,
                              isSelectionMode: isSelectionMode,
                              selectedArtistKeysInSelectionMode: _selectedArtistKeys,
                              hasBottomPanel: showBottomPanel,
                              onArtistSelected: (artist) {
                                if (isSelectionMode) {
                                  _toggleArtistSelection(artist.queryKey);
                                } else if (!isSongSelectionMode) {
                                  setState(() {
                                    _selectedArtistKey = artist.queryKey;
                                  });
                                }
                              },
                              onArtistLongPressed: (artist) {
                                if (isSelectionMode) {
                                  _toggleArtistSelection(artist.queryKey);
                                } else if (!isSongSelectionMode) {
                                  _enterArtistSelectionMode(artist.queryKey);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ArtistDetailPane(
                              artist: selectedArtist,
                              emptyLabel: noArtistsLabel,
                              songSelectionController: _songSelectionController,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              final bottomOffset = (currentMusic != null ? 140.0 : 40.0) + (isSelectionMode ? 220.0 : 0.0);
              mainContent = ScrollToTopWrapper(
                scrollController: _scrollController,
                bottomOffset: bottomOffset,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _ArtistsToolbar(
                        searchController: _searchController,
                        searchQuery: _searchQuery,
                        sortField: _sortField,
                        sortAscending: _sortAscending,
                        artistCount: visibleArtists.length,
                        artistsLabel: artistsLabel,
                        isWide: false,
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
                          });
                        },
                      ),
                    ),
                    if (visibleArtists.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            noArtistsLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomOffset),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index.isOdd) {
                                return const SizedBox(height: 8);
                              }
                              final artistIndex = index ~/ 2;
                              final artist = visibleArtists[artistIndex];
                              final isSelected = _selectedArtistKeys.contains(artist.queryKey);
                              return _ArtistListItem(
                                artist: artist,
                                selected: false,
                                isSelectionMode: isSelectionMode,
                                isSelectedInSelectionMode: isSelected,
                                onTap: () {
                                  if (isSelectionMode) {
                                    _toggleArtistSelection(artist.queryKey);
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            ArtistDetailPage(artist: artist),
                                      ),
                                    );
                                  }
                                },
                                onLongPress: () {
                                  if (isSelectionMode) {
                                    _toggleArtistSelection(artist.queryKey);
                                  } else {
                                    _enterArtistSelectionMode(artist.queryKey);
                                  }
                                },
                                onSelectionToggled: () => _toggleArtistSelection(artist.queryKey),
                              );
                            },
                            childCount: visibleArtists.length * 2 - 1,
                          ),
                        ),
                      ),
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
                            key: const ValueKey('artist-selection-panel'),
                            selectedSongs: selectedSongs,
                            allSongs: allSongs,
                            title: l10n.selectedArtistsCount(_selectedArtistKeys.length),
                            onToggleSelectAll: () {
                              final isAllSelected = _selectedArtistKeys.length == visibleArtists.length && visibleArtists.isNotEmpty;
                              setState(() {
                                if (isAllSelected) {
                                  _selectedArtistKeys.clear();
                                  ref.read(librarySelectionScopeProvider.notifier).clear();
                                } else {
                                  _selectedArtistKeys.clear();
                                  _selectedArtistKeys.addAll(visibleArtists.map((a) => a.queryKey));
                                }
                              });
                            },
                            onCancel: () {
                              setState(() {
                                _selectedArtistKeys.clear();
                              });
                              ref.read(librarySelectionScopeProvider.notifier).clear();
                            },
                          )
                        : (isLandscape && isSongSelectionMode
                            ? LibrarySelectionPanel(
                                key: const ValueKey('song-selection-panel'),
                                selectedSongs: _songSelectionController.allSongs
                                    .where((s) => _songSelectionController.selectedSongPaths.contains(s.path))
                                    .toList(),
                                allSongs: _songSelectionController.allSongs,
                                onToggleSelectAll: _songSelectionController.toggleSelectAll,
                                onCancel: () {
                                  _songSelectionController.cancelSelection();
                                  ref.read(librarySelectionScopeProvider.notifier).clear();
                                },
                              )
                            : const SizedBox.shrink(key: ValueKey('artist-selection-panel-hidden'))),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<ArtistSummary> _filterAndSortArtists(List<ArtistSummary> artists) {
    final query = _searchQuery.toLowerCase();
    final filtered = artists
        .where(
          (artist) =>
              query.isEmpty ||
              artist.name.toLowerCase().contains(query) ||
              artist.disambiguation?.toLowerCase().contains(query) == true ||
              artist.country?.toLowerCase().contains(query) == true ||
              artist.tags.any((tag) => tag.toLowerCase().contains(query)),
        )
        .toList();

    filtered.sort((a, b) {
      final compare = switch (_sortField) {
        _ArtistSortField.artist => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
        _ArtistSortField.songCount => a.songCount.compareTo(b.songCount),
      };
      if (compare != 0) {
        return _sortAscending ? compare : -compare;
      }

      final fallback = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return _sortAscending ? fallback : -fallback;
    });

    return filtered;
  }

  ArtistSummary? _resolveSelectedArtist(List<ArtistSummary> visibleArtists) {
    if (visibleArtists.isEmpty) return null;

    final selectedKey = _selectedArtistKey;
    if (selectedKey != null) {
      for (final artist in visibleArtists) {
        if (artist.queryKey == selectedKey) {
          return artist;
        }
      }
    }

    return visibleArtists.first;
  }

  void _syncSelectedArtist(List<ArtistSummary> visibleArtists) {
    if (visibleArtists.isEmpty) return;

    final selectedKey = _selectedArtistKey;
    if (selectedKey != null &&
        visibleArtists.any((artist) => artist.queryKey == selectedKey)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || visibleArtists.isEmpty) return;
      final fallbackKey = visibleArtists.first.queryKey;
      if (_selectedArtistKey == fallbackKey) return;
      setState(() {
        _selectedArtistKey = fallbackKey;
      });
    });
  }
}

class _ArtistListPane extends StatelessWidget {
  const _ArtistListPane({
    required this.artists,
    required this.selectedArtistKey,
    required this.noArtistsLabel,
    required this.scrollController,
    required this.onArtistSelected,
    this.isSelectionMode = false,
    this.selectedArtistKeysInSelectionMode = const {},
    this.onArtistLongPressed,
    this.hasBottomPanel = false,
  });

  final List<ArtistSummary> artists;
  final String? selectedArtistKey;
  final String noArtistsLabel;
  final ScrollController scrollController;
  final ValueChanged<ArtistSummary> onArtistSelected;
  final bool isSelectionMode;
  final Set<String> selectedArtistKeysInSelectionMode;
  final ValueChanged<ArtistSummary>? onArtistLongPressed;
  final bool hasBottomPanel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = hasBottomPanel ? 180.0 : 12.0;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: artists.isEmpty
          ? Center(
              child: Text(noArtistsLabel, style: theme.textTheme.titleMedium),
            )
          : Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPadding),
                itemExtent: 80.0,
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  final selected = artist.queryKey == selectedArtistKey;
                  final isSelected = selectedArtistKeysInSelectionMode.contains(artist.queryKey);
                  return Padding(
                    key: ValueKey(artist.queryKey),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ArtistListItem(
                      artist: artist,
                      selected: selected,
                      isSelectionMode: isSelectionMode,
                      isSelectedInSelectionMode: isSelected,
                      onTap: () => onArtistSelected(artist),
                      onLongPress: onArtistLongPressed != null ? () => onArtistLongPressed!(artist) : null,
                      onSelectionToggled: () => onArtistSelected(artist),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _ArtistListItem extends ConsumerWidget {
  const _ArtistListItem({
    required this.artist,
    required this.selected,
    required this.onTap,
    this.isSelectionMode = false,
    this.isSelectedInSelectionMode = false,
    this.onSelectionToggled,
    this.onLongPress,
  });

  final ArtistSummary artist;
  final bool selected;
  final VoidCallback onTap;
  final bool isSelectionMode;
  final bool isSelectedInSelectionMode;
  final VoidCallback? onSelectionToggled;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final audio = ref.read(audioServiceProvider);
    final playAllLabel = l10n.playAll;
    final songCountLabel = l10n.songCount(artist.songCount);
    final subtitleParts = <String>[
      songCountLabel,
      if ((artist.country?.trim().isNotEmpty ?? false)) artist.country!.trim(),
    ];
    if (artist.disambiguation?.trim().isNotEmpty ?? false) {
      subtitleParts.add(artist.disambiguation!.trim());
    }

    final backgroundColor = isSelectionMode
        ? (isSelectedInSelectionMode
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35))
        : (selected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35));

    return RepaintBoundary(
      child: Material(
        color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapDown: (details) {
          if (!isSelectionMode) {
            _showArtistContextMenuForArtist(
              context,
              ref,
              artist,
            );
          }
        },
        onLongPress: () {
          if (onLongPress != null) {
            onLongPress!();
          } else if (!isSelectionMode) {
            _showArtistContextMenuForArtist(
              context,
              ref,
              artist,
            );
          }
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Checkbox(
                      value: isSelectedInSelectionMode,
                      onChanged: (_) => onSelectionToggled?.call(),
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(child: ArtistAvatar(diameter: 48)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleParts.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!isSelectionMode)
                  IconButton(
                    tooltip: playAllLabel,
                    onPressed: () => audio.playPlaylist(
                      artist.songs,
                      source: PlaybackSource(
                        type: PlaybackSourceType.artist,
                        id: artist.queryKey,
                        name: artist.name,
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _ArtistDetailPane extends StatelessWidget {
  const _ArtistDetailPane({
    required this.artist,
    required this.emptyLabel,
    this.songSelectionController,
  });

  final ArtistSummary? artist;
  final String emptyLabel;
  final ArtistSongSelectionController? songSelectionController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentArtist = artist;
    if (currentArtist == null) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 56,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                emptyLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ArtistDetailContent(
          artist: currentArtist,
          songSelectionController: songSelectionController,
        ),
      ),
    );
  }
}

Future<void> _showArtistContextMenuForArtist(
  BuildContext context,
  WidgetRef ref,
  ArtistSummary artist,
) async {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final subtitleParts = <String>[
    l10n.songCount(artist.songCount),
    if ((artist.country?.trim().isNotEmpty ?? false)) artist.country!.trim(),
  ];
  if (artist.disambiguation?.trim().isNotEmpty ?? false) {
    subtitleParts.add(artist.disambiguation!.trim());
  }

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
                        // Header showing Artist name and avatar
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: const SizedBox(
                                width: 52,
                                height: 52,
                                child: Center(child: ArtistAvatar(diameter: 52)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    artist.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitleParts.join(' · '),
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
                        _buildArtistBottomSheetItem(
                          context: context,
                          value: 'play_all',
                          label: l10n.playAll,
                          icon: Icons.play_arrow_rounded,
                        ),
                        _buildArtistBottomSheetItem(
                          context: context,
                          value: 'shuffle',
                          label: l10n.shufflePlay,
                          icon: Icons.shuffle_rounded,
                        ),
                        _buildArtistBottomSheetItem(
                          context: context,
                          value: 'view_details',
                          label: l10n.viewArtistDetails,
                          icon: Icons.person_rounded,
                        ),
                        _buildArtistBottomSheetItem(
                          context: context,
                          value: 'copy_artist',
                          label: l10n.copyArtistName,
                          icon: Icons.copy_rounded,
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
        artist.songs,
        source: PlaybackSource(
          type: PlaybackSourceType.artist,
          id: artist.queryKey,
          name: artist.name,
        ),
      );
      break;
    case 'shuffle':
      await ref.read(audioServiceProvider).playPlaylist(
        List.of(artist.songs)..shuffle(),
        source: PlaybackSource(
          type: PlaybackSourceType.artist,
          id: artist.queryKey,
          name: artist.name,
        ),
      );
      break;
    case 'view_details':
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ArtistDetailPage(artist: artist),
        ),
      );
      break;
    case 'copy_artist':
      await Clipboard.setData(ClipboardData(text: artist.name));
      break;
  }
}

Widget _buildArtistBottomSheetItem({
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

class _ArtistsToolbar extends StatelessWidget {
  const _ArtistsToolbar({
    required this.searchController,
    required this.searchQuery,
    required this.sortField,
    required this.sortAscending,
    required this.artistCount,
    required this.artistsLabel,
    required this.isWide,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final _ArtistSortField sortField;
  final bool sortAscending;
  final int artistCount;
  final String artistsLabel;
  final bool isWide;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final void Function(_ArtistSortField field, bool sortAscending) onSortChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final searchArtistsLabel = l10n.searchArtists;
    final artistCountLabel = '$artistCount $artistsLabel';
    final sortControls = IconButton.filledTonal(
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
      tooltip: l10n.albumSort,
      onPressed: () async {
        final result = await showDialog<SortResult<_ArtistSortField>>(
          context: context,
          builder: (context) => SortOptionsDialog<_ArtistSortField>(
            title: l10n.albumSort,
            currentField: sortField,
            sortAscending: sortAscending,
            options: [
              SortOptionItem(
                value: _ArtistSortField.artist,
                label: l10n.sortArtistAsc,
                icon: Icons.person_rounded,
              ),
              SortOptionItem(
                value: _ArtistSortField.songCount,
                label: l10n.sortTrackCount,
                icon: Icons.format_list_numbered_rounded,
              ),
            ],
          ),
        );
        if (result != null) {
          onSortChanged(result.field, result.sortAscending);
        }
      },
      icon: const Icon(Icons.sort_rounded),
    );

    Widget buildTextField() {
      return TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: searchArtistsLabel,
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
    }

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
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artistsLabel,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        artistCountLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: buildTextField(),
                ),
                const SizedBox(width: 12),
                sortControls,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artistsLabel,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            artistCountLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    sortControls,
                  ],
                ),
                const SizedBox(height: 12),
                buildTextField(),
              ],
            ),
    );
  }
}
