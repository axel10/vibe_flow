import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../player/remote/navidrome_navigation.dart';
import '../../../player/remote/remote_server_models.dart';
import '../../../utils/remote_context_menu_utils.dart';
import '../../../utils/selection_utils.dart';
import '../../../widgets/remote_artwork_widget.dart';
import '../navidrome_artist_detail_page.dart';

class NavidromeArtistsToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final bool starredOnly;
  final ValueChanged<bool> onToggleStarredOnly;
  final bool sortAsc;
  final String sortField; // 'name' or 'albumCount'
  final VoidCallback onToggleSort;

  const NavidromeArtistsToolbar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.starredOnly,
    required this.onToggleStarredOnly,
    required this.sortAsc,
    required this.sortField,
    required this.onToggleSort,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.filterArtists,
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
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            avatar: Icon(
              starredOnly
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 14,
              color: starredOnly ? Colors.redAccent : null,
            ),
            label: Text(
              l10n.starredArtists,
              style: TextStyle(
                fontSize: 12,
                color: starredOnly ? Colors.redAccent : null,
              ),
            ),
            selected: starredOnly,
            onSelected: onToggleStarredOnly,
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: Icon(
              sortAsc
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 16,
            ),
            label: Text(
              sortField == 'albumCount' ? l10n.albums : 'A-Z',
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: onToggleSort,
          ),
        ],
      ),
    );
  }
}

class NavidromeArtistsView extends ConsumerWidget {
  final RemoteServer server;
  final String password;
  final List<Map<String, dynamic>> artists;
  final Set<String> starredArtistIds;
  final String? selectedArtistId;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final String searchQuery;
  final double bottomOffset;
  final bool isSelectionMode;
  final Set<String> selectedArtistIds;
  final int? lastArtistAnchorIndex;
  final ValueChanged<String?> onSelectArtistId;
  final void Function(Set<String> keys) onSetSelection;
  final void Function(String artistId) onToggleSelection;
  final void Function(int? index) onUpdateAnchor;

  const NavidromeArtistsView({
    super.key,
    required this.server,
    required this.password,
    required this.artists,
    required this.starredArtistIds,
    required this.selectedArtistId,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.searchQuery,
    required this.bottomOffset,
    required this.isSelectionMode,
    required this.selectedArtistIds,
    required this.lastArtistAnchorIndex,
    required this.onSelectArtistId,
    required this.onSetSelection,
    required this.onToggleSelection,
    required this.onUpdateAnchor,
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
            Text(l10n.errorLoadingArtists(error!)),
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
        final isLandscape = constraints.maxWidth >= 750;

        final selectedArtist = artists.firstWhere(
          (a) => a['id'] == selectedArtistId,
          orElse: () => artists.isNotEmpty ? artists.first : const {},
        );

        if (isLandscape && artists.isNotEmpty) {
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
                    onRefresh: onRefresh,
                    child: ListView.builder(
                      padding:
                          EdgeInsets.fromLTRB(12, 12, 12, bottomOffset),
                      itemCount: artists.length,
                      itemBuilder: (context, index) {
                        final artist = artists[index];
                        final isSelected =
                            artist['id'] == selectedArtist['id'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: NavidromeArtistItem(
                            server: server,
                            password: password,
                            artist: artist,
                            index: index,
                            allArtists: artists,
                            isSelected: isSelected,
                            isMultiSelected: selectedArtistIds
                                .contains(artist['id'] as String? ?? ''),
                            isStarred: starredArtistIds
                                .contains(artist['id'] as String? ?? ''),
                            isSelectionMode: isSelectionMode,
                            selectedArtistIds: selectedArtistIds,
                            lastArtistAnchorIndex: lastArtistAnchorIndex,
                            onSetSelection: onSetSelection,
                            onToggleSelection: onToggleSelection,
                            onUpdateAnchor: onUpdateAnchor,
                            onTap: () {
                              final id = artist['id'] as String?;
                              onSelectArtistId(id);
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
                            server: server,
                            password: password,
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
        return artists.isEmpty
            ? Center(
                child: Text(
                  searchQuery.isEmpty
                      ? l10n.noArtistsFound
                      : l10n.noMatchingArtists,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottomOffset),
                  itemCount: artists.length,
                  itemBuilder: (context, index) {
                    final artist = artists[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: NavidromeArtistItem(
                        server: server,
                        password: password,
                        artist: artist,
                        index: index,
                        allArtists: artists,
                        isSelected: false,
                        isMultiSelected: selectedArtistIds
                            .contains(artist['id'] as String? ?? ''),
                        isStarred: starredArtistIds
                            .contains(artist['id'] as String? ?? ''),
                        isSelectionMode: isSelectionMode,
                        selectedArtistIds: selectedArtistIds,
                        lastArtistAnchorIndex: lastArtistAnchorIndex,
                        onSetSelection: onSetSelection,
                        onToggleSelection: onToggleSelection,
                        onUpdateAnchor: onUpdateAnchor,
                        onTap: () {
                          NavidromeNavUtils.openArtist(
                            context,
                            ref,
                            server: server,
                            password: password,
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
}

class NavidromeArtistItem extends ConsumerWidget {
  final RemoteServer server;
  final String password;
  final Map<String, dynamic> artist;
  final int index;
  final List<Map<String, dynamic>> allArtists;
  final bool isSelected;
  final bool isMultiSelected;
  final bool isStarred;
  final bool isSelectionMode;
  final Set<String> selectedArtistIds;
  final int? lastArtistAnchorIndex;
  final void Function(Set<String> keys) onSetSelection;
  final void Function(String artistId) onToggleSelection;
  final void Function(int? index) onUpdateAnchor;
  final VoidCallback onTap;

  const NavidromeArtistItem({
    super.key,
    required this.server,
    required this.password,
    required this.artist,
    required this.index,
    required this.allArtists,
    required this.isSelected,
    required this.isMultiSelected,
    required this.isStarred,
    required this.isSelectionMode,
    required this.selectedArtistIds,
    required this.lastArtistAnchorIndex,
    required this.onSetSelection,
    required this.onToggleSelection,
    required this.onUpdateAnchor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final name = artist['name'] as String? ?? l10n.unknownArtist;
    final albumCount = artist['albumCount'] as int? ?? 0;
    final coverArtId = artist['coverArt'] as String?;
    final artistId = artist['id'] as String? ?? '';

    final backgroundColor = isSelectionMode && isMultiSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
        : (isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) {
        if (!isSelectionMode) {
          showRemoteArtistContextMenu(
            context: context,
            globalPosition: details.globalPosition,
            ref: ref,
            server: server,
            password: password,
            artistId: artistId,
            artistName: name,
            onViewDetails: onTap,
          );
        }
      },
      onLongPressStart: (details) {
        onUpdateAnchor(index);
        onToggleSelection(artistId);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            SelectionActionHelper.handleItemTap(
              index: index,
              itemKey: artistId,
              items: allArtists,
              keySelector: (a) => a['id'] as String? ?? '',
              isSelectionMode: isSelectionMode,
              selectedKeys: selectedArtistIds,
              lastAnchorIndex: lastArtistAnchorIndex,
              onUpdateAnchor: onUpdateAnchor,
              onSetSelection: onSetSelection,
              onToggleSelection: onToggleSelection,
              onNormalTap: onTap,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isSelectionMode && isMultiSelected) || isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: (isSelectionMode && isMultiSelected) || isSelected
                    ? 1.5
                    : 0.8,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RemoteArtworkWidget(
                    server: server,
                    password: password,
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
                                fontWeight: (isSelectionMode &&
                                            isMultiSelected) ||
                                        isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 13,
                                color: (isSelectionMode &&
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
                if (isSelectionMode)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isMultiSelected,
                      onChanged: (_) {
                        onToggleSelection(artistId);
                      },
                    ),
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
                        server: server,
                        password: password,
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
}
