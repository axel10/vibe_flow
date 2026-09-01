import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/music_file.dart';
import '../../../player/audio/audio_riverpod.dart';
import '../../../player/remote/navidrome_navigation.dart';
import '../../../player/remote/remote_server_models.dart';
import '../../../utils/remote_context_menu_utils.dart';
import '../../../utils/selection_utils.dart';
import '../../../widgets/remote_artwork_widget.dart';

class NavidromeSearchToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool isSearching;
  final VoidCallback onClearSearch;

  const NavidromeSearchToolbar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.isSearching,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: l10n.searchRemoteHint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: isSearching
              ? const UnconstrainedBox(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: onClearSearch,
                    )
                  : null),
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
    );
  }
}

class NavidromeSearchView extends ConsumerWidget {
  final RemoteServer server;
  final String password;
  final TextEditingController searchController;
  final List<MusicFile> searchedSongs;
  final List<Map<String, dynamic>> searchedAlbums;
  final List<Map<String, dynamic>> searchedArtists;
  final double bottomOffset;
  final bool isArtistSelectionMode;
  final bool isAlbumSelectionMode;
  final bool isSongSelectionMode;
  final Set<String> selectedArtistIds;
  final Set<String> selectedAlbumIds;
  final Set<String> selectedSongPaths;
  final int? lastSongAnchorIndex;
  final void Function(Set<String> keys) onSetSongSelection;
  final void Function(String path) onToggleSongSelection;
  final void Function(int? index) onUpdateSongAnchor;
  final void Function(String artistId) onToggleArtistSelection;
  final void Function(String albumId) onToggleAlbumSelection;

  const NavidromeSearchView({
    super.key,
    required this.server,
    required this.password,
    required this.searchController,
    required this.searchedSongs,
    required this.searchedAlbums,
    required this.searchedArtists,
    required this.bottomOffset,
    required this.isArtistSelectionMode,
    required this.isAlbumSelectionMode,
    required this.isSongSelectionMode,
    required this.selectedArtistIds,
    required this.selectedAlbumIds,
    required this.selectedSongPaths,
    required this.lastSongAnchorIndex,
    required this.onSetSongSelection,
    required this.onToggleSongSelection,
    required this.onUpdateSongAnchor,
    required this.onToggleArtistSelection,
    required this.onToggleAlbumSelection,
  });

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (searchedSongs.isEmpty &&
        searchedAlbums.isEmpty &&
        searchedArtists.isEmpty) {
      return Center(
        child: Text(
          searchController.text.trim().isEmpty
              ? l10n.typeToSearch
              : l10n.noMatchingResults,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomOffset),
      children: [
        if (searchedArtists.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${l10n.artists} (${searchedArtists.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          for (final artist in searchedArtists) () {
            final artistId = artist['id'] as String? ?? '';
            final artistName =
                artist['name'] as String? ?? l10n.unknownArtist;
            final coverArtId = artist['coverArt'] as String?;
            final albumCount = artist['albumCount'] as int?;
            final isMultiSelected = selectedArtistIds.contains(artistId);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onSecondaryTapDown: (details) {
                if (!isArtistSelectionMode) {
                  showRemoteArtistContextMenu(
                    context: context,
                    globalPosition: details.globalPosition,
                    ref: ref,
                    server: server,
                    password: password,
                    artistId: artistId,
                    artistName: artistName,
                    onViewDetails: () {
                      NavidromeNavUtils.openArtist(
                        context,
                        ref,
                        server: server,
                        password: password,
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
                onToggleArtistSelection(artistId);
              },
              child: Material(
                color: isArtistSelectionMode && isMultiSelected
                    ? theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.35)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (isArtistSelectionMode) {
                      onToggleArtistSelection(artistId);
                    } else {
                      NavidromeNavUtils.openArtist(
                        context,
                        ref,
                        server: server,
                        password: password,
                        artistId: artistId,
                        artistName: artistName,
                        coverArtId: coverArtId,
                        albumCount: albumCount,
                      );
                    }
                  },
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: RemoteArtworkWidget(
                        server: server,
                        password: password,
                        coverArtId: coverArtId,
                        size: 40,
                      ),
                    ),
                    title: Text(
                      artistName,
                      style: TextStyle(
                        fontWeight: isArtistSelectionMode && isMultiSelected
                            ? FontWeight.bold
                            : null,
                        color: isArtistSelectionMode && isMultiSelected
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                    subtitle: albumCount != null
                        ? Text(l10n.albumCount(albumCount))
                        : null,
                    trailing: isArtistSelectionMode
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
        if (searchedAlbums.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${l10n.albums} (${searchedAlbums.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 124,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: searchedAlbums.length,
              itemBuilder: (context, index) {
                final album = searchedAlbums[index];
                final albumId = album['id'] as String? ?? '';
                final title = album['name'] as String? ??
                    album['title'] as String? ??
                    l10n.unknownAlbum;
                final artist =
                    album['artist'] as String? ?? l10n.unknownArtist;
                final coverId = album['coverArt'] as String?;
                final isSelected = selectedAlbumIds.contains(albumId);

                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onSecondaryTapDown: (details) {
                      if (!isAlbumSelectionMode) {
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
                      onToggleAlbumSelection(albumId);
                    },
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (isAlbumSelectionMode) {
                          onToggleAlbumSelection(albumId);
                        } else {
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
                                    color: isAlbumSelectionMode && isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    width: isAlbumSelectionMode && isSelected
                                        ? 2
                                        : 0,
                                  ),
                                ),
                                child: RemoteArtworkWidget(
                                  server: server,
                                  password: password,
                                  coverArtId: coverId,
                                  size: 80,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              if (isAlbumSelectionMode)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: isSelected
                                          ? theme.colorScheme.primaryContainer
                                              .withValues(alpha: 0.3)
                                          : Colors.black26,
                                    ),
                                  ),
                                ),
                              if (isAlbumSelectionMode)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (_) =>
                                          onToggleAlbumSelection(albumId),
                                      fillColor: WidgetStateProperty.all(
                                          Colors.white),
                                      checkColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(3),
                                      ),
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
                              fontWeight:
                                  isAlbumSelectionMode && isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color: isAlbumSelectionMode && isSelected
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
        if (searchedSongs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${l10n.songs} (${searchedSongs.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          for (int i = 0; i < searchedSongs.length; i++) () {
            final song = searchedSongs[i];
            final isSelected = selectedSongPaths.contains(song.path);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onSecondaryTapDown: (details) {
                if (!isSongSelectionMode) {
                  showRemoteSongContextMenu(
                    context: context,
                    globalPosition: details.globalPosition,
                    ref: ref,
                    server: server,
                    password: password,
                    song: song,
                  );
                }
              },
              onLongPressStart: (details) {
                onUpdateSongAnchor(i);
                onToggleSongSelection(song.path);
              },
              child: Material(
                color: isSongSelectionMode && isSelected
                    ? theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.35)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    SelectionActionHelper.handleItemTap(
                      index: i,
                      itemKey: song.path,
                      items: searchedSongs,
                      keySelector: (s) => s.path,
                      isSelectionMode: isSongSelectionMode,
                      selectedKeys: selectedSongPaths,
                      lastAnchorIndex: lastSongAnchorIndex,
                      onUpdateAnchor: onUpdateSongAnchor,
                      onSetSelection: onSetSongSelection,
                      onToggleSelection: onToggleSongSelection,
                      onNormalTap: () async {
                        final audioService =
                            ref.read(audioServiceProvider);
                        await audioService.playPlaylist(
                          searchedSongs,
                          initialIndex: i,
                        );
                      },
                    );
                  },
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    leading: isSongSelectionMode
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
                        fontWeight: isSongSelectionMode && isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSongSelectionMode && isSelected
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
}
