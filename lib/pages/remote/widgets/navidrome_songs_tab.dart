import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/music_file.dart';
import '../../../player/audio/audio_riverpod.dart';
import '../../../player/audio/playback_source.dart';
import '../../../player/remote/proxy/remote_media_resolver.dart';
import '../../../player/remote/remote_server_models.dart';
import '../../../player/remote/services/remote_download_service.dart';
import '../../../utils/app_snack_bar.dart';
import '../../../utils/layout_constants.dart';
import '../../../utils/remote_context_menu_utils.dart';
import '../../../utils/selection_utils.dart';
import '../../../utils/song_locator_helper.dart';
import '../../../widgets/playing_equalizer_icon.dart';
import '../../../widgets/remote_artwork_widget.dart';
import '../../../player/remote/navidrome_navigation.dart';
import '../remote_download_manager_page.dart';

class NavidromeSongsToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final bool starredOnly;
  final ValueChanged<bool> onToggleStarredOnly;
  final String sortField; // 'title', 'artist', 'album', 'duration'
  final bool sortAsc;
  final void Function(String field, bool asc) onSortChanged;

  const NavidromeSongsToolbar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.starredOnly,
    required this.onToggleStarredOnly,
    required this.sortField,
    required this.sortAsc,
    required this.onSortChanged,
  });

  String _getSortLabel(AppLocalizations l10n) {
    switch (sortField) {
      case 'artist':
        return l10n.artists;
      case 'album':
        return l10n.albums;
      case 'duration':
        return l10n.durationLabel;
      case 'title':
      default:
        return l10n.songs;
    }
  }

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
                hintText: l10n.filterSongs,
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
              l10n.starredSongsOnly,
              style: TextStyle(
                fontSize: 12,
                color: starredOnly ? Colors.redAccent : null,
              ),
            ),
            selected: starredOnly,
            onSelected: onToggleStarredOnly,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: l10n.sort,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'toggle_direction',
                child: Row(
                  children: [
                    Icon(
                      sortAsc
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sortAsc ? 'A-Z (Asc)' : 'Z-A (Desc)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'title',
                child: Row(
                  children: [
                    if (sortField == 'title')
                      Icon(Icons.check_rounded,
                          size: 18, color: theme.colorScheme.primary)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(l10n.songs),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'artist',
                child: Row(
                  children: [
                    if (sortField == 'artist')
                      Icon(Icons.check_rounded,
                          size: 18, color: theme.colorScheme.primary)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(l10n.artists),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'album',
                child: Row(
                  children: [
                    if (sortField == 'album')
                      Icon(Icons.check_rounded,
                          size: 18, color: theme.colorScheme.primary)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(l10n.albums),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duration',
                child: Row(
                  children: [
                    if (sortField == 'duration')
                      Icon(Icons.check_rounded,
                          size: 18, color: theme.colorScheme.primary)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(l10n.durationLabel),
                  ],
                ),
              ),
            ],
            onSelected: (val) {
              if (val == 'toggle_direction') {
                onSortChanged(sortField, !sortAsc);
              } else {
                onSortChanged(val, sortAsc);
              }
            },
            child: ActionChip(
              avatar: Icon(
                sortAsc
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 16,
              ),
              label: Text(
                _getSortLabel(l10n),
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: null,
            ),
          ),
        ],
      ),
    );
  }
}

class NavidromeSongsView extends ConsumerStatefulWidget {
  final RemoteServer server;
  final String password;
  final List<MusicFile> songs;
  final int totalServerSongsCount;
  final Set<String> starredSongIds;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final Future<void> Function() onRefresh;
  final VoidCallback? onLoadMore;
  final String searchQuery;
  final double bottomOffset;
  final bool isSelectionMode;
  final Set<String> selectedSongPaths;
  final int? lastSongAnchorIndex;
  final void Function(Set<String> keys) onSetSelection;
  final void Function(String songPath) onToggleSelection;
  final void Function(int? index) onUpdateAnchor;
  final void Function(MusicFile song) onToggleStar;

  const NavidromeSongsView({
    super.key,
    required this.server,
    required this.password,
    required this.songs,
    required this.totalServerSongsCount,
    required this.starredSongIds,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.error,
    required this.onRefresh,
    required this.onLoadMore,
    required this.searchQuery,
    required this.bottomOffset,
    required this.isSelectionMode,
    required this.selectedSongPaths,
    required this.lastSongAnchorIndex,
    required this.onSetSelection,
    required this.onToggleSelection,
    required this.onUpdateAnchor,
    required this.onToggleStar,
  });

  @override
  ConsumerState<NavidromeSongsView> createState() => _NavidromeSongsViewState();
}

class _NavidromeSongsViewState extends ConsumerState<NavidromeSongsView> {

  String _formatTrackDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '--:--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _formatTotalDuration(List<MusicFile> songs) {
    int totalMs = 0;
    for (final s in songs) {
      if (s.durationMillis != null) {
        totalMs += s.durationMillis!;
      }
    }
    final totalSeconds = totalMs ~/ 1000;
    if (totalSeconds <= 0) return '';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '$minutes min';
  }

  Future<void> _playAll({bool shuffle = false}) async {
    if (widget.songs.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final audioService = ref.read(audioServiceProvider);
    final playlist = List<MusicFile>.from(widget.songs);
    if (shuffle) {
      playlist.shuffle();
    }
    await audioService.playPlaylist(
      playlist,
      source: PlaybackSource(
        type: PlaybackSourceType.playlist,
        id: 'remote-${widget.server.id}-songs',
        name: l10n.songs,
      ),
    );
  }

  Future<void> _downloadAll() async {
    if (widget.songs.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(remoteDownloadTasksProvider.notifier);

    await notifier.enqueueSubsonicTracks(
      server: widget.server,
      password: widget.password,
      songs: widget.songs,
      collectionName: l10n.songs,
    );

    if (mounted) {
      AppSnackBar.show(
        context,
        ref,
        SnackBar(
          content: Text(l10n.batchAddedToDownloadQueue(widget.songs.length)),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isAudioPlaying = ref.watch(audioIsPlayingProvider);
    final highlightedPath = ref.watch(songHighlightProvider);

    if (widget.isLoading && widget.songs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.error != null && widget.songs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(
                l10n.errorLoadingSongs(widget.error!),
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.songs.isEmpty) {
      return Center(
        child: Text(
          widget.searchQuery.isEmpty
              ? l10n.noSongsOnServer
              : l10n.noMatchingSongs,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    final totalDurationStr = _formatTotalDuration(widget.songs);

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 300) {
          if (widget.hasMore && !widget.isLoadingMore && !widget.isLoading) {
            widget.onLoadMore?.call();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, 8, 16, widget.bottomOffset),
        itemCount: widget.songs.length + 1 + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Header action bar
          if (index == 0) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: kSingleColumnContentMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      FilledButton.icon(
                        onPressed:
                            widget.songs.isNotEmpty ? () => _playAll() : null,
                        icon:
                            const Icon(Icons.play_arrow_rounded, size: 20),
                        label: Text(l10n.playAll),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: l10n.shufflePlay,
                        onPressed: widget.songs.isNotEmpty
                            ? () => _playAll(shuffle: true)
                            : null,
                        icon: const Icon(Icons.shuffle_rounded, size: 18),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: l10n.downloadAllTracks,
                        onPressed:
                            widget.songs.isNotEmpty ? _downloadAll : null,
                        icon: const Icon(Icons.download_rounded, size: 18),
                      ),
                      const Spacer(),
                      Text(
                        totalDurationStr.isNotEmpty
                            ? '${l10n.trackCountShort(widget.songs.length)} · $totalDurationStr'
                            : l10n.trackCountShort(widget.songs.length),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Loader item at bottom
          final songIndex = index - 1;
          if (songIndex >= widget.songs.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: widget.isLoadingMore
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : (widget.hasMore
                        ? TextButton.icon(
                            onPressed: widget.onLoadMore,
                            icon: const Icon(Icons.expand_more_rounded),
                            label: Text(l10n.loadMore),
                          )
                        : const SizedBox.shrink()),
              ),
            );
          }

          final song = widget.songs[songIndex];
          final isCurrent = currentMusic?.path == song.path;
          final isHighlighted = highlightedPath == song.path;
          final isSelected =
              widget.selectedSongPaths.contains(song.path);
          final trackDuration =
              _formatTrackDuration((song.durationMillis ?? 0) ~/ 1000);

          final trackId =
              RemoteMediaResolver.extractSubsonicTrackId(song) ??
                  (song.id != null && song.id! > 0 ? song.id.toString() : '');
          final isStarred = widget.starredSongIds.contains(trackId);

          String? coverId;
          if (song.artworkPath != null && song.artworkPath!.isNotEmpty) {
            coverId = song.artworkPath!
                .replaceFirst('subsonic-cover://${widget.server.id}/', '');
          }
          if (coverId == null || coverId.isEmpty) {
            coverId = trackId.isNotEmpty ? trackId : null;
          }

          return Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: kSingleColumnContentMaxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onSecondaryTapDown: (details) {
                    if (!widget.isSelectionMode) {
                      showRemoteSongContextMenu(
                        context: context,
                        globalPosition: details.globalPosition,
                        ref: ref,
                        server: widget.server,
                        password: widget.password,
                        song: song,
                        playlist: widget.songs,
                        onViewArtist: () {
                          if (song.artist != null &&
                              song.artist!.isNotEmpty) {
                            NavidromeNavUtils.openArtist(
                              context,
                              ref,
                              server: widget.server,
                              password: widget.password,
                              artistId: '',
                              artistName: song.artist!,
                            );
                          }
                        },
                      );
                    }
                  },
                  onLongPressStart: (details) {
                    widget.onUpdateAnchor(songIndex);
                    widget.onToggleSelection(song.path);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: widget.isSelectionMode && isSelected
                          ? theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.35)
                          : (isHighlighted
                              ? theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.6)
                              : (isCurrent
                                  ? theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.35)
                                  : Colors.transparent)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          SelectionActionHelper.handleItemTap(
                            index: songIndex,
                            itemKey: song.path,
                            items: widget.songs,
                            keySelector: (s) => s.path,
                            isSelectionMode: widget.isSelectionMode,
                            selectedKeys: widget.selectedSongPaths,
                            lastAnchorIndex: widget.lastSongAnchorIndex,
                            onUpdateAnchor: widget.onUpdateAnchor,
                            onSetSelection: widget.onSetSelection,
                            onToggleSelection: widget.onToggleSelection,
                            onNormalTap: () async {
                              final audio = ref.read(audioServiceProvider);
                              await audio.playPlaylist(
                                widget.songs,
                                initialIndex: songIndex,
                                source: PlaybackSource(
                                  type: PlaybackSourceType.playlist,
                                  id: 'remote-${widget.server.id}-songs',
                                  name: l10n.songs,
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              // Leading: Selection checkbox or Artwork thumbnail with equalizer
                              if (widget.isSelectionMode)
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Center(
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (_) =>
                                          widget.onToggleSelection(song.path),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    RemoteArtworkWidget(
                                      server: widget.server,
                                      password: widget.password,
                                      coverArtId: coverId,
                                      size: 44,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    if (isCurrent && isAudioPlaying)
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: PlayingEqualizerIcon(
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              const SizedBox(width: 14),

                              // Song Title & Artist/Album subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      song.title ?? song.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: isCurrent ||
                                                (widget.isSelectionMode &&
                                                    isSelected)
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isCurrent
                                            ? theme.colorScheme.primary
                                            : (widget.isSelectionMode &&
                                                    isSelected
                                                ? theme.colorScheme.primary
                                                : theme
                                                    .colorScheme.onSurface),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      [
                                        if (song.artist?.isNotEmpty == true)
                                          song.artist!,
                                        if (song.album?.isNotEmpty == true)
                                          song.album!,
                                      ].join(' · '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Trailing: duration & star & more actions
                              if (trackDuration != '--:--') ...[
                                const SizedBox(width: 8),
                                Text(
                                  trackDuration,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(width: 4),
                              IconButton(
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                icon: Icon(
                                  isStarred
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isStarred
                                      ? Colors.redAccent
                                      : theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                ),
                                tooltip: isStarred
                                    ? l10n.starredSongsOnly
                                    : l10n.addToFavorites,
                                onPressed: () => widget.onToggleStar(song),
                              ),
                              Builder(
                                builder: (btnContext) => IconButton(
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  icon: const Icon(Icons.more_vert_rounded),
                                  tooltip: l10n.more,
                                  onPressed: () {
                                    final renderBox = btnContext
                                        .findRenderObject() as RenderBox?;
                                    final position = renderBox != null
                                        ? renderBox.localToGlobal(Offset.zero) +
                                            Offset(
                                              renderBox.size.width / 2,
                                              renderBox.size.height,
                                            )
                                        : Offset.zero;
                                    showRemoteSongContextMenu(
                                      context: context,
                                      globalPosition: position,
                                      ref: ref,
                                      server: widget.server,
                                      password: widget.password,
                                      song: song,
                                      playlist: widget.songs,
                                      onViewArtist: () {
                                        if (song.artist != null &&
                                            song.artist!.isNotEmpty) {
                                          NavidromeNavUtils.openArtist(
                                            context,
                                            ref,
                                            server: widget.server,
                                            password: widget.password,
                                            artistId: '',
                                            artistName: song.artist!,
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
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
          );
        },
      ),
    ),
  );
}
}
