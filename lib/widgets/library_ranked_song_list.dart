import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/library/library_insights_service.dart';
import 'package:vynody/player/library/playlist_service.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import 'song_thumbnail.dart';
import 'playing_equalizer_icon.dart';
import 'library_selection_panel.dart';
import 'library_selection_scope.dart';
import 'scroll_to_top_wrapper.dart';

class LibraryRankedSongList extends ConsumerStatefulWidget {
  const LibraryRankedSongList({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.emptyText,
    required this.trailingBuilder,
  });

  final String title;
  final String subtitle;
  final List<LibraryInsightSongEntry> items;
  final LibraryTimeRange selectedRange;
  final ValueChanged<LibraryTimeRange> onRangeChanged;
  final String emptyText;
  final Widget Function(BuildContext, LibraryInsightSongEntry) trailingBuilder;

  @override
  ConsumerState<LibraryRankedSongList> createState() => _LibraryRankedSongListState();
}

class _LibraryRankedSongListState extends ConsumerState<LibraryRankedSongList> {
  bool _isSelectionMode = false;
  final Set<String> _selectedSongPaths = {};
  final ScrollController _scrollController = ScrollController();
  late final LibrarySelectionScopeController _librarySelectionScopeController;

  @override
  void initState() {
    super.initState();
    _librarySelectionScopeController =
        ref.read(librarySelectionScopeProvider.notifier);
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedSongPaths.clear();
        _librarySelectionScopeController.clear();
      } else {
        _librarySelectionScopeController.setScope(
          LibrarySelectionScope.library,
        );
      }
    });
  }

  void _toggleSelection(String path) {
    setState(() {
      if (_selectedSongPaths.contains(path)) {
        _selectedSongPaths.remove(path);
      } else {
        _selectedSongPaths.add(path);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedSongPaths.clear();
      _librarySelectionScopeController.clear();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Future.microtask(() {
      _librarySelectionScopeController.clear();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final audio = ref.read(audioServiceProvider);
    final playlistService = ref.read(playlistServiceProvider);

    final selectedSongs = _isSelectionMode
        ? widget.items
            .where((entry) => _selectedSongPaths.contains(entry.song.path))
            .map((entry) => entry.song)
            .toList()
        : const <MusicFile>[];

    void toggleSelectAll() {
      setState(() {
        if (_selectedSongPaths.length == widget.items.length) {
          _selectedSongPaths.clear();
        } else {
          _selectedSongPaths.addAll(widget.items.map((s) => s.song.path));
        }
      });
    }

    Widget currentBody = CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              return Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, isWide ? 12 : 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWide)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.items.isNotEmpty) ...[
                            FilledButton.icon(
                              onPressed: () {
                                audio.playPlaylist(widget.items.map((e) => e.song).toList());
                              },
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(l10n.playAll),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                final songs = widget.items.map((e) => e.song).toList()..shuffle();
                                audio.playPlaylist(songs);
                              },
                              icon: const Icon(Icons.shuffle_rounded),
                              label: Text(l10n.shufflePlay),
                            ),
                          ],
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (widget.items.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () {
                                      audio.playPlaylist(widget.items.map((e) => e.song).toList());
                                    },
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: Text(l10n.playAll),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      final songs = widget.items.map((e) => e.song).toList()..shuffle();
                                      audio.playPlaylist(songs);
                                    },
                                    icon: const Icon(Icons.shuffle_rounded),
                                    label: Text(l10n.shufflePlay),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          for (int i = 0; i < LibraryTimeRange.values.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(_timeRangeLabel(l10n, LibraryTimeRange.values[i])),
                              selected: widget.selectedRange == LibraryTimeRange.values[i],
                              onSelected: (_) => widget.onRangeChanged(LibraryTimeRange.values[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.emptyText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 140 + (_isSelectionMode ? 220.0 : 0.0)),
            sliver: SliverFixedExtentList.builder(
              itemExtent: 80.0,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final entry = widget.items[index];
                final isSelected = _selectedSongPaths.contains(entry.song.path);
                return Padding(
                  key: ValueKey(entry.song.path),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SongListItem(
                    entry: entry,
                    index: index,
                    l10n: l10n,
                    audio: audio,
                    playlistService: playlistService,
                    items: widget.items,
                    trailingBuilder: widget.trailingBuilder,
                    isSelectionMode: _isSelectionMode,
                    isSelected: isSelected,
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleSelection(entry.song.path);
                      } else {
                        audio.playPlaylist(
                          widget.items.map((e) => e.song).toList(),
                          initialIndex: index,
                        );
                      }
                    },
                    onLongPress: () {
                      if (!_isSelectionMode) {
                        _toggleSelectionMode();
                        _toggleSelection(entry.song.path);
                      }
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );

    return ScrollToTopWrapper(
      scrollController: _scrollController,
      bottomOffset: 140.0 + (_isSelectionMode ? 220.0 : 0.0),
      child: Stack(
        children: [
          currentBody,
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
            child: _isSelectionMode
                ? LibrarySelectionPanel(
                    key: const ValueKey('library-selection-panel'),
                    selectedSongs: selectedSongs,
                    allSongs: widget.items.map((e) => e.song).toList(),
                    onToggleSelectAll: toggleSelectAll,
                    onCancel: _cancelSelection,
                  )
                : const SizedBox.shrink(key: ValueKey('library-selection-panel-hidden')),
          ),
        ),
      ],
    ),
  );
}

  String _timeRangeLabel(AppLocalizations l10n, LibraryTimeRange range) {
    return switch (range) {
      LibraryTimeRange.allTime => l10n.allTime,
      LibraryTimeRange.last7Days => l10n.pastWeek,
      LibraryTimeRange.last30Days => l10n.pastMonth,
      LibraryTimeRange.last90Days => l10n.past90Days,
    };
  }
}

class _SongListItem extends ConsumerWidget {
  const _SongListItem({
    required this.entry,
    required this.index,
    required this.l10n,
    required this.audio,
    required this.playlistService,
    required this.items,
    required this.trailingBuilder,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
  });

  final LibraryInsightSongEntry entry;
  final int index;
  final AppLocalizations l10n;
  final AudioService audio;
  final PlaylistService playlistService;
  final List<LibraryInsightSongEntry> items;
  final Widget Function(BuildContext, LibraryInsightSongEntry) trailingBuilder;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final song = entry.song;
    final isMissing = song.isMissing;
    final currentSong = ref.watch(audioCurrentMusicProvider);
    final isPlaying = ref.watch(audioIsPlayingProvider);
    final isCurrent = currentSong != null && currentSong.path == song.path;

    final maxDigits = items.length.toString().length;
    final double indexWidth = isSelectionMode
        ? 24.0
        : (maxDigits >= 3 ? (maxDigits * 9.5 + 6.0).clamp(24.0, 56.0) : 24.0);
    final double leadingWidth = indexWidth + 8.0 + 40.0;

    final textColor = isMissing
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.55)
        : isCurrent
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface;

    return RepaintBoundary(
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: isSelectionMode && isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : isCurrent
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
                : theme.colorScheme.surfaceContainerLow,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onSecondaryTapDown: (details) async {
              if (!isSelectionMode) {
                await showSongBottomSheet(context, ref, song);
              }
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              selected: isSelectionMode ? isSelected : isCurrent,
              selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              leading: SizedBox(
                width: leadingWidth,
                child: Row(
                  children: [
                    SizedBox(
                      width: indexWidth,
                      child: isSelectionMode
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (_) => onTap(),
                            )
                          : Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${index + 1}',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: isCurrent
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Opacity(
                      opacity: isMissing
                          ? 0.35
                          : isSelectionMode
                              ? (isSelected ? 0.5 : 0.7)
                              : 1.0,
                      child: SongThumbnail(
                        path: song.path,
                        id: song.id,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              title: Row(
                children: [
                  if (isCurrent && !isMissing) ...[
                    PlayingEqualizerIcon(
                      color: theme.colorScheme.primary,
                      size: 16,
                      isPlaying: isPlaying,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      song.displayName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: textColor,
                        fontWeight: isCurrent && !isMissing ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                _songSubtitle(l10n, entry),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isMissing
                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : isCurrent
                          ? theme.colorScheme.primary.withValues(alpha: 0.8)
                          : theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 96),
                child: trailingBuilder(context, entry),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _songSubtitle(AppLocalizations l10n, LibraryInsightSongEntry entry) {
    final song = entry.song;
    final artist = isVisibleSongText(song.artist)
        ? song.artist!.trim()
        : l10n.unknownArtist;
    final album = isVisibleSongText(song.album)
        ? song.album!.trim()
        : l10n.unknownAlbum;
    final baseSubtitle = '$artist · $album';
    if ((entry.sourceFlags ?? 0) & SongSourceFlags.external != 0) {
      return '$baseSubtitle  •  [${l10n.externalSourceTag}]';
    }
    return baseSubtitle;
  }
}

class InsightMetricText extends StatelessWidget {
  const InsightMetricText({super.key, required this.primary, this.secondary});

  final String primary;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          primary,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.right,
        ),
        if (secondary != null) ...[
          const SizedBox(height: 2),
          Text(
            secondary!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ],
    );
  }
}

String formatInsightDate(BuildContext context, int? millis) {
  if (millis == null) return '';
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(
    locale,
  ).format(DateTime.fromMillisecondsSinceEpoch(millis));
}

String formatRelativeInsightDate(BuildContext context, int? millis) {
  if (millis == null) return '';
  final date = DateTime.fromMillisecondsSinceEpoch(millis);
  final now = DateTime.now();
  final difference = now.difference(date);

  final isZh = Localizations.localeOf(context).languageCode == 'zh';
  if (difference.inSeconds < 60 && difference.inSeconds >= 0) {
    return isZh ? '刚刚' : 'Just now';
  } else if (difference.inMinutes < 60 && difference.inMinutes >= 1) {
    return isZh ? '${difference.inMinutes}分钟前' : '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24 && difference.inHours >= 1 && now.day == date.day) {
    final timeStr = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(date);
    return isZh ? '今天 $timeStr' : 'Today $timeStr';
  } else if (now.year == date.year && now.subtract(const Duration(days: 1)).day == date.day && now.subtract(const Duration(days: 1)).month == date.month) {
    final timeStr = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(date);
    return isZh ? '昨天 $timeStr' : 'Yesterday $timeStr';
  } else if (now.year == date.year) {
    return DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag()).format(date);
  } else {
    return DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(date);
  }
}
