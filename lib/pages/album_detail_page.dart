import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../l10n/app_localizations.dart';
import 'package:vynody/models/album_summary.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/playback_source.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import '../widgets/desktop_window_title_bar.dart';
import '../widgets/song_thumbnail.dart';
import '../widgets/mini_player_wrapper.dart';
import '../widgets/library_selection_panel.dart';
import '../widgets/library_selection_scope.dart';
import 'package:vynody/utils/layout_constants.dart';

class AlbumDetailPage extends ConsumerStatefulWidget {
  const AlbumDetailPage({super.key, required this.album});

  final AlbumSummary album;

  @override
  ConsumerState<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends ConsumerState<AlbumDetailPage>
    with SongSelectionMixin<AlbumDetailPage> {
  @override
  LibrarySelectionScope get selectionScope => LibrarySelectionScope.library;
  late final ScrollController _scrollController;
  bool _isCoverVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    final isVisible = _scrollController.offset < 200.0;
    if (isVisible != _isCoverVisible) {
      setState(() {
        _isCoverVisible = isVisible;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final audio = ref.read(audioServiceProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final headerColor = theme.colorScheme.secondaryContainer.withValues(
      alpha: 0.65,
    );

    final isMacOS = Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    final selectedSongs = isSelectionMode
        ? getSelectedSongs(widget.album.songs)
        : const <MusicFile>[];
    final isLargeAlbum = widget.album.songs.length >= 100;
    final unknownArtist = l10n.unknownArtist;

    Widget content = Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isCoverVisible
              ? const SizedBox.shrink()
              : Text(
                  widget.album.title,
                  key: const ValueKey('album_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [headerColor, theme.colorScheme.surface],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: kSingleColumnContentMaxWidth),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 700;
                            final cover = HeroMode(
                              enabled: _isCoverVisible,
                              child: Hero(
                                tag: 'album-cover-${widget.album.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SongThumbnail(
                                    path: widget.album.representativeSong.path,
                                    id: widget.album.representativeSong.id,
                                    size: isWide
                                        ? 220
                                        : math.min(220, constraints.maxWidth),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                            );
                            final info = _AlbumInfo(
                              album: widget.album,
                              onPlayAll: () => audio.playPlaylist(
                                widget.album.songs,
                                source: PlaybackSource(
                                  type: PlaybackSourceType.album,
                                  id: widget.album.id,
                                  name: widget.album.title,
                                ),
                              ),
                              onShufflePlay: () => audio.playPlaylist(
                                List.of(widget.album.songs)..shuffle(),
                                source: PlaybackSource(
                                  type: PlaybackSourceType.album,
                                  id: widget.album.id,
                                  name: widget.album.title,
                                ),
                              ),
                            );

                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  cover,
                                  const SizedBox(width: 24),
                                  Expanded(child: info),
                                ],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(child: cover),
                                const SizedBox(height: 20),
                                info,
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverFixedExtentList.builder(
                itemExtent: 64.0,
                itemCount: widget.album.songs.length,
                itemBuilder: (context, index) {
                  final song = widget.album.songs[index];
                  final isCurrent = currentMusic?.path == song.path;
                  final isSelected = isSongSelected(song.path);

                  return _AlbumSongItem(
                    song: song,
                    index: index,
                    isCurrent: isCurrent,
                    isSelected: isSelected,
                    isSelectionMode: isSelectionMode,
                    isLargeAlbum: isLargeAlbum,
                    unknownArtist: unknownArtist,
                    onTap: () {
                      handleSongTap(
                        index: index,
                        songPath: song.path,
                        allSongs: widget.album.songs,
                        onNormalTap: () {
                          audio.playPlaylist(
                            widget.album.songs,
                            initialIndex: index,
                            source: PlaybackSource(
                              type: PlaybackSourceType.album,
                              id: widget.album.id,
                              name: widget.album.title,
                            ),
                          );
                        },
                      );
                    },
                    onLongPress: () {
                      lastAnchorIndex = index;
                      if (!isSelectionMode) {
                        enterSongSelectionMode(song.path);
                      }
                    },
                    onSecondaryTapDown: (details) {
                      if (!isSelectionMode) {
                        showSongBottomSheet(context, ref, song);
                      }
                    },
                    onToggleSelection: () {
                      lastAnchorIndex = index;
                      toggleSongSelection(song.path);
                    },
                  );
                },
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MiniPlayerUiTuning.getListBottomPadding(
                    context,
                    hasPlayingMusic: currentMusic != null,
                    isSelectionMode: isSelectionMode,
                    selectionPanelHeight: 220.0,
                  ),
                ),
              ),
            ],
          ),
          AnimatedSelectionPanel(
            isVisible: isSelectionMode,
            child: LibrarySelectionPanel(
              key: const ValueKey('library-selection-panel'),
              selectedSongs: selectedSongs,
              allSongs: widget.album.songs,
              onToggleSelectAll: () =>
                  toggleSelectAllSongs(widget.album.songs),
              onCancel: cancelSongSelection,
            ),
          ),
        ],
      ),
    );

    if (showCustomTitleBar || isMacOS) {
      content = Material(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            if (showCustomTitleBar)
              DesktopWindowTitleBar(
                brightness: theme.brightness,
              )
            else
              const DragToMoveArea(child: SizedBox(height: 32)),
            Expanded(child: content),
          ],
        ),
      );
    }

    return MiniPlayerWrapper(child: content);
  }
}

class _AlbumInfo extends StatelessWidget {
  const _AlbumInfo({
    required this.album,
    required this.onPlayAll,
    required this.onShufflePlay,
  });

  final AlbumSummary album;
  final VoidCallback onPlayAll;
  final VoidCallback onShufflePlay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          album.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          album.artist,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${l10n.songCount(album.trackCount)} · ${_formatDuration(album.totalDurationMillis) ?? l10n.durationZero}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onPlayAll,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.playAll),
            ),
            OutlinedButton.icon(
              onPressed: onShufflePlay,
              icon: const Icon(Icons.shuffle),
              label: Text(l10n.shufflePlay),
            ),
          ],
        ),
      ],
    );
  }
}

String? _formatDuration(int? durationMs) {
  if (durationMs == null) return null;
  final duration = Duration(milliseconds: durationMs);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${duration.inMinutes}:${seconds.toString().padLeft(2, '0')}';
}

class _AlbumSongItem extends StatelessWidget {
  const _AlbumSongItem({
    required this.song,
    required this.index,
    required this.isCurrent,
    required this.isSelected,
    required this.isSelectionMode,
    required this.isLargeAlbum,
    required this.unknownArtist,
    required this.onTap,
    required this.onLongPress,
    required this.onSecondaryTapDown,
    required this.onToggleSelection,
  });

  final MusicFile song;
  final int index;
  final bool isCurrent;
  final bool isSelected;
  final bool isSelectionMode;
  final bool isLargeAlbum;
  final String unknownArtist;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<TapDownDetails> onSecondaryTapDown;
  final VoidCallback onToggleSelection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationLabel = _formatDuration(song.durationMillis);
    final trackLabel = '${index + 1}'.padLeft(2, '0');
    final isTileSelected = isSelectionMode ? isSelected : isCurrent;

    final leadingWidget = isSelectionMode
        ? SizedBox(
            width: isLargeAlbum ? 40 : 32,
            child: Center(
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelection(),
              ),
            ),
          )
        : SizedBox(
            width: isLargeAlbum ? 40 : 32,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  trackLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isCurrent ? theme.colorScheme.primary : null,
                    fontWeight: isCurrent ? FontWeight.w700 : null,
                  ),
                ),
              ),
            ),
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: onSecondaryTapDown,
      child: Material(
        color: isTileSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : Colors.transparent,
        child: InkWell(
          enableFeedback: false,
          canRequestFocus: false,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kSingleColumnContentMaxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    leadingWidget,
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isCurrent ? theme.colorScheme.primary : null,
                              fontWeight: isCurrent ? FontWeight.w700 : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist ?? unknownArtist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (durationLabel != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        durationLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

