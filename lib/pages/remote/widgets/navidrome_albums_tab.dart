import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../player/remote/navidrome_navigation.dart';
import '../../../player/remote/remote_server_models.dart';
import '../../../utils/remote_context_menu_utils.dart';
import '../../../utils/selection_utils.dart';
import '../../../widgets/remote_artwork_widget.dart';

class NavidromeAlbumsToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final bool isSearchExpanded;
  final ValueChanged<bool> onToggleSearchExpanded;
  final String sortType;
  final ValueChanged<String> onSortTypeChanged;

  const NavidromeAlbumsToolbar({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.isSearchExpanded,
    required this.onToggleSearchExpanded,
    required this.sortType,
    required this.onSortTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          controller: searchController,
          focusNode: searchFocusNode,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: l10n.filterAlbums,
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: onClearSearch,
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
              final isSelected = sortType == key;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && sortType != key) {
                      onSortTypeChanged(key);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        );

        final isNarrowExpanded = isSearchExpanded || searchQuery.isNotEmpty;

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
                                searchFocusNode.unfocus();
                                onToggleSearchExpanded(false);
                                onClearSearch();
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
                                onToggleSearchExpanded(true);
                                searchFocusNode.requestFocus();
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
}

class NavidromeAlbumsView extends ConsumerWidget {
  final RemoteServer server;
  final String password;
  final List<Map<String, dynamic>> albums;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final String searchQuery;
  final double bottomOffset;
  final bool isSelectionMode;
  final Set<String> selectedAlbumIds;
  final int? lastAlbumAnchorIndex;
  final void Function(Set<String> keys) onSetSelection;
  final void Function(String albumId) onToggleSelection;
  final void Function(int? index) onUpdateAnchor;
  final void Function(String albumId, String albumTitle) onPlayAlbumDirectly;

  const NavidromeAlbumsView({
    super.key,
    required this.server,
    required this.password,
    required this.albums,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.searchQuery,
    required this.bottomOffset,
    required this.isSelectionMode,
    required this.selectedAlbumIds,
    required this.lastAlbumAnchorIndex,
    required this.onSetSelection,
    required this.onToggleSelection,
    required this.onUpdateAnchor,
    required this.onPlayAlbumDirectly,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.errorLoadingAlbums(error!)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRefresh,
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
            child: albums.isEmpty
                ? Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? l10n.noAlbumsOnServer
                          : l10n.noMatchingAlbums,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: onRefresh,
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
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        final albumId = album['id'] as String? ?? '';
                        final isSelected = selectedAlbumIds.contains(albumId);
                        final title = album['title'] as String? ??
                            album['name'] as String? ??
                            l10n.unknownAlbum;
                        final artist = album['artist'] as String? ??
                            l10n.unknownArtist;
                        final coverId = album['coverArt'] as String?;
                        final songCount = album['songCount'] as int?;
                        final year = album['year'] as int?;

                        return NavidromeAlbumCard(
                          server: server,
                          password: password,
                          album: album,
                          albumId: albumId,
                          title: title,
                          artist: artist,
                          coverId: coverId,
                          songCount: songCount,
                          year: year,
                          index: index,
                          isSelected: isSelected,
                          isSelectionMode: isSelectionMode,
                          filteredAlbums: albums,
                          selectedAlbumIds: selectedAlbumIds,
                          lastAlbumAnchorIndex: lastAlbumAnchorIndex,
                          isPortrait: isPortrait,
                          onSetSelection: onSetSelection,
                          onToggleSelection: onToggleSelection,
                          onUpdateAnchor: onUpdateAnchor,
                          onPlayAlbumDirectly: () =>
                              onPlayAlbumDirectly(albumId, title),
                        );
                      },
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class NavidromeAlbumCard extends ConsumerWidget {
  final RemoteServer server;
  final String password;
  final Map<String, dynamic> album;
  final String albumId;
  final String title;
  final String artist;
  final String? coverId;
  final int? songCount;
  final int? year;
  final int index;
  final bool isSelected;
  final bool isSelectionMode;
  final List<Map<String, dynamic>> filteredAlbums;
  final Set<String> selectedAlbumIds;
  final int? lastAlbumAnchorIndex;
  final bool isPortrait;
  final void Function(Set<String> keys) onSetSelection;
  final void Function(String albumId) onToggleSelection;
  final void Function(int? index) onUpdateAnchor;
  final VoidCallback onPlayAlbumDirectly;

  const NavidromeAlbumCard({
    super.key,
    required this.server,
    required this.password,
    required this.album,
    required this.albumId,
    required this.title,
    required this.artist,
    required this.coverId,
    required this.songCount,
    required this.year,
    required this.index,
    required this.isSelected,
    required this.isSelectionMode,
    required this.filteredAlbums,
    required this.selectedAlbumIds,
    required this.lastAlbumAnchorIndex,
    required this.isPortrait,
    required this.onSetSelection,
    required this.onToggleSelection,
    required this.onUpdateAnchor,
    required this.onPlayAlbumDirectly,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) {
        if (!isSelectionMode) {
          showRemoteAlbumContextMenu(
            context: context,
            globalPosition: details.globalPosition,
            ref: ref,
            server: server,
            password: password,
            albumId: albumId,
            albumTitle: title,
            artistName: artist,
            coverArtId: coverId,
            onViewDetails: () {
              NavidromeNavUtils.openAlbum(
                context,
                ref,
                server: server,
                password: password,
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
        onUpdateAnchor(index);
        onToggleSelection(albumId);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            SelectionActionHelper.handleItemTap(
              index: index,
              itemKey: albumId,
              items: filteredAlbums,
              keySelector: (a) => a['id'] as String? ?? '',
              isSelectionMode: isSelectionMode,
              selectedKeys: selectedAlbumIds,
              lastAnchorIndex: lastAlbumAnchorIndex,
              onUpdateAnchor: onUpdateAnchor,
              onSetSelection: onSetSelection,
              onToggleSelection: onToggleSelection,
              onNormalTap: () {
                NavidromeNavUtils.openAlbum(
                  context,
                  ref,
                  server: server,
                  password: password,
                  albumId: albumId,
                  albumName: title,
                  artistName: artist,
                  coverArtId: coverId,
                );
              },
            );
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          server: server,
                          password: password,
                          coverArtId: coverId,
                          size: 220,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    if (isSelectionMode)
                      Positioned.fill(
                        child: Container(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.3)
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
                            onChanged: (_) => onToggleSelection(albumId),
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isPortrait ? 10 : 12,
                      isPortrait ? 6 : 8,
                      isPortrait ? 10 : 12,
                      isPortrait ? 4 : 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: isPortrait ? 12 : 13,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              artist,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: isPortrait ? 11 : 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                songCount != null
                                    ? l10n.trackCountShort(songCount!)
                                    : (year != null && year! > 0
                                        ? '$year'
                                        : ''),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: isPortrait ? 10 : 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isSelectionMode)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: l10n.playAlbum,
                                onPressed: onPlayAlbumDirectly,
                                icon: Icon(
                                  Icons.play_circle_filled_rounded,
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
}
