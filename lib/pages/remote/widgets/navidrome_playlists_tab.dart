import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import '../../../l10n/app_localizations.dart';
import '../../../player/remote/clients/subsonic_client.dart';
import '../../../player/remote/navidrome_navigation.dart';
import '../../../player/remote/remote_server_models.dart';
import '../../../utils/remote_context_menu_utils.dart';
import '../../../utils/selection_utils.dart';
import '../../../widgets/remote_artwork_widget.dart';
import '../navidrome_playlist_detail_page.dart';

class NavidromePlaylistsToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onCreatePlaylist;
  final VoidCallback onRefresh;

  const NavidromePlaylistsToolbar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCreatePlaylist,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.searchPlaylists,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: onClearSearch,
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
            onPressed: onCreatePlaylist,
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: l10n.refresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}

class NavidromePlaylistsView extends ConsumerWidget {
  static const String starredPlaylistId = '__navidrome_starred_songs__';

  final RemoteServer server;
  final String password;
  final List<Map<String, dynamic>> playlists;
  final String? selectedPlaylistId;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final String searchQuery;
  final double bottomOffset;
  final bool isSelectionMode;
  final Set<String> selectedPlaylistIds;
  final int? lastPlaylistAnchorIndex;
  final ValueChanged<String?> onSelectPlaylistId;
  final void Function(Set<String> keys) onSetSelection;
  final void Function(String playlistId) onToggleSelection;
  final void Function(int? index) onUpdateAnchor;

  const NavidromePlaylistsView({
    super.key,
    required this.server,
    required this.password,
    required this.playlists,
    required this.selectedPlaylistId,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.searchQuery,
    required this.bottomOffset,
    required this.isSelectionMode,
    required this.selectedPlaylistIds,
    required this.lastPlaylistAnchorIndex,
    required this.onSelectPlaylistId,
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
            Text(l10n.errorLoadingPlaylists(error!)),
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
        final isLandscape =
            constraints.maxWidth >= 750 && playlists.isNotEmpty;

        final selectedPlaylist = playlists.firstWhere(
          (pl) => pl['id'] == selectedPlaylistId,
          orElse: () =>
              playlists.isNotEmpty ? playlists.first : const {},
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
                    onRefresh: onRefresh,
                    child: ListView.builder(
                      padding:
                          EdgeInsets.fromLTRB(12, 12, 12, bottomOffset),
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final pl = playlists[index];
                        final isSelected =
                            pl['id'] == selectedPlaylist['id'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: NavidromePlaylistItem(
                            server: server,
                            password: password,
                            playlist: pl,
                            index: index,
                            allPlaylists: playlists,
                            isSelected: isSelected,
                            isMultiSelected: selectedPlaylistIds
                                .contains(pl['id'] as String? ?? ''),
                            isSelectionMode: isSelectionMode,
                            selectedPlaylistIds: selectedPlaylistIds,
                            lastPlaylistAnchorIndex:
                                lastPlaylistAnchorIndex,
                            onSetSelection: onSetSelection,
                            onToggleSelection: onToggleSelection,
                            onUpdateAnchor: onUpdateAnchor,
                            onRefreshPlaylists: onRefresh,
                            onTap: () {
                              final id = pl['id'] as String?;
                              onSelectPlaylistId(id);
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
                            server: server,
                            password: password,
                            playlistId:
                                selectedPlaylist['id'] as String? ?? '',
                            playlistName:
                                selectedPlaylist['name'] as String? ??
                                    l10n.playlist,
                            coverArtId:
                                selectedPlaylist['coverArt'] as String?,
                            songCount:
                                selectedPlaylist['songCount'] as int?,
                            duration:
                                selectedPlaylist['duration'] as int?,
                            isStarred: selectedPlaylist['isStarred'] ==
                                    true ||
                                selectedPlaylist['id'] ==
                                    starredPlaylistId,
                            onPlaylistModified: onRefresh,
                            onDeleted: () {
                              onRefresh();
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
        return playlists.isEmpty
            ? Center(
                child: Text(
                  searchQuery.isEmpty
                      ? l10n.noPlaylistsFound
                      : l10n.noMatchingPlaylists,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottomOffset),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final pl = playlists[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: NavidromePlaylistItem(
                        server: server,
                        password: password,
                        playlist: pl,
                        index: index,
                        allPlaylists: playlists,
                        isSelected: false,
                        isMultiSelected: selectedPlaylistIds
                            .contains(pl['id'] as String? ?? ''),
                        isSelectionMode: isSelectionMode,
                        selectedPlaylistIds: selectedPlaylistIds,
                        lastPlaylistAnchorIndex: lastPlaylistAnchorIndex,
                        onSetSelection: onSetSelection,
                        onToggleSelection: onToggleSelection,
                        onUpdateAnchor: onUpdateAnchor,
                        onRefreshPlaylists: onRefresh,
                        onTap: () {
                          NavidromeNavUtils.openPlaylist(
                            context,
                            ref,
                            server: server,
                            password: password,
                            playlistId: pl['id'] as String? ?? '',
                            playlistName:
                                pl['name'] as String? ?? l10n.playlist,
                            coverArtId: pl['coverArt'] as String?,
                            songCount: pl['songCount'] as int?,
                            duration: pl['duration'] as int?,
                            isStarred: pl['isStarred'] == true ||
                                pl['id'] == starredPlaylistId,
                            onPlaylistModified: onRefresh,
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

class NavidromePlaylistItem extends ConsumerWidget {
  static const String starredPlaylistId = '__navidrome_starred_songs__';

  final RemoteServer server;
  final String password;
  final Map<String, dynamic> playlist;
  final int index;
  final List<Map<String, dynamic>> allPlaylists;
  final bool isSelected;
  final bool isMultiSelected;
  final bool isSelectionMode;
  final Set<String> selectedPlaylistIds;
  final int? lastPlaylistAnchorIndex;
  final void Function(Set<String> keys) onSetSelection;
  final void Function(String playlistId) onToggleSelection;
  final void Function(int? index) onUpdateAnchor;
  final VoidCallback onRefreshPlaylists;
  final VoidCallback onTap;

  const NavidromePlaylistItem({
    super.key,
    required this.server,
    required this.password,
    required this.playlist,
    required this.index,
    required this.allPlaylists,
    required this.isSelected,
    required this.isMultiSelected,
    required this.isSelectionMode,
    required this.selectedPlaylistIds,
    required this.lastPlaylistAnchorIndex,
    required this.onSetSelection,
    required this.onToggleSelection,
    required this.onUpdateAnchor,
    required this.onRefreshPlaylists,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final name = playlist['name'] as String? ?? l10n.playlist;
    final songCount = playlist['songCount'] as int? ?? 0;
    final durationSec = playlist['duration'] as int? ?? 0;
    final durationMin = durationSec ~/ 60;
    final coverArt = playlist['coverArt'] as String?;
    final playlistId = playlist['id'] as String? ?? '';
    final isStarredItem =
        playlist['isStarred'] == true || playlistId == starredPlaylistId;

    final backgroundColor = isSelectionMode && isMultiSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
        : (isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: isStarredItem || isSelectionMode
          ? null
          : (details) {
              showRemotePlaylistContextMenu(
                context: context,
                globalPosition: details.globalPosition,
                ref: ref,
                server: server,
                password: password,
                playlistId: playlistId,
                playlistName: name,
                onViewDetails: onTap,
                onRename: onRefreshPlaylists,
                onDelete: onRefreshPlaylists,
              );
            },
      onLongPressStart: (details) {
        onUpdateAnchor(index);
        onToggleSelection(playlistId);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            SelectionActionHelper.handleItemTap(
              index: index,
              itemKey: playlistId,
              items: allPlaylists,
              keySelector: (p) => p['id'] as String? ?? '',
              isSelectionMode: isSelectionMode,
              selectedKeys: selectedPlaylistIds,
              lastAnchorIndex: lastPlaylistAnchorIndex,
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
                  borderRadius: BorderRadius.circular(8),
                  child: coverArt != null && coverArt.isNotEmpty
                      ? RemoteArtworkWidget(
                          server: server,
                          password: password,
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
                if (isSelectionMode)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isMultiSelected,
                      onChanged: (_) {
                        onToggleSelection(playlistId);
                      },
                    ),
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
                        server: server,
                        password: password,
                        playlistId: playlistId,
                        playlistName: name,
                        onViewDetails: onTap,
                        onRename: onRefreshPlaylists,
                        onDelete: onRefreshPlaylists,
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

Future<void> showCreateNavidromePlaylistDialog({
  required BuildContext context,
  required SubsonicClient client,
  required void Function(Map<String, dynamic> created) onCreated,
}) async {
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
              final created = await client.createPlaylist(name: name);
              if (created != null && context.mounted) {
                showToast(l10n.createdPlaylistSuccess(name));
                onCreated(created);
              }
            }
          },
          child: Text(l10n.confirm),
        ),
      ],
    ),
  );
}
