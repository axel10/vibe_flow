import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/library/library_insights_service.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/utils/selection_utils.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import 'song_thumbnail.dart';
import 'playing_equalizer_icon.dart';
import 'library_selection_panel.dart';
import 'library_selection_scope.dart';

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

class _LibraryRankedSongListState extends ConsumerState<LibraryRankedSongList>
    with SongSelectionMixin<LibraryRankedSongList> {
  @override
  LibrarySelectionScope get selectionScope => LibrarySelectionScope.library;

  int? _lastAnchorIndex;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<LibraryInsightSongEntry> _filterItems(List<LibraryInsightSongEntry> items) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items.where((entry) {
      final song = entry.song;
      final title = song.displayName.toLowerCase();
      final artist = (song.artist ?? '').toLowerCase();
      final album = (song.album ?? '').toLowerCase();
      return title.contains(q) || artist.contains(q) || album.contains(q);
    }).toList();
  }

  Widget _buildSearchField(ThemeData theme, AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: (val) {
        setState(() {
          _searchQuery = val.trim();
        });
      },
      decoration: InputDecoration(
        hintText: l10n.search,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: l10n.clearSearch,
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      style: TextStyle(
        color: theme.colorScheme.onSecondaryContainer,
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final audio = ref.read(audioServiceProvider);

    final filteredItems = _filterItems(widget.items);
    final filteredSongs = filteredItems.map((e) => e.song).toList();
    final selectedSongs = isSelectionMode
        ? getSelectedSongs(filteredSongs)
        : const <MusicFile>[];

    Widget currentBody = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null &&
            _searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;
                      return Container(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, isWide ? 12 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isWide)
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
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
                                          _searchQuery.isNotEmpty
                                              ? l10n.songCount(filteredItems.length)
                                              : widget.subtitle,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 4,
                                    child: _buildSearchField(theme, l10n),
                                  ),
                                  const SizedBox(width: 16),
                                  if (filteredItems.isNotEmpty) ...[
                                    FilledButton.icon(
                                      onPressed: () {
                                        audio.playPlaylist(filteredItems.map((e) => e.song).toList());
                                      },
                                      icon: const Icon(Icons.play_arrow_rounded),
                                      label: Text(l10n.playAll),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        final songs = filteredItems.map((e) => e.song).toList()..shuffle();
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
                                              _searchQuery.isNotEmpty
                                                  ? l10n.songCount(filteredItems.length)
                                              : widget.subtitle,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _isSearchExpanded || _searchQuery.isNotEmpty
                                            ? Icons.search_off_rounded
                                            : Icons.search_rounded,
                                      ),
                                      tooltip: l10n.search,
                                      onPressed: () {
                                        setState(() {
                                          _isSearchExpanded = !_isSearchExpanded;
                                          if (_isSearchExpanded) {
                                            _searchFocusNode.requestFocus();
                                          } else {
                                            _searchController.clear();
                                            _searchQuery = '';
                                            _searchFocusNode.unfocus();
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                AnimatedCrossFade(
                                  firstChild: const SizedBox.shrink(),
                                  secondChild: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: _buildSearchField(theme, l10n),
                                  ),
                                  crossFadeState: (_isSearchExpanded || _searchQuery.isNotEmpty)
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 200),
                                ),
                                if (filteredItems.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: () {
                                            audio.playPlaylist(filteredItems.map((e) => e.song).toList());
                                          },
                                          icon: const Icon(Icons.play_arrow_rounded),
                                          label: Text(l10n.playAll),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            final songs = filteredItems.map((e) => e.song).toList()..shuffle();
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
            ),
          ),
        ),
          if (widget.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
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
              ),
            )
          else if (filteredItems.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noMatchingResults,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          label: Text(l10n.clearSearch),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 140 + (isSelectionMode ? 220.0 : 0.0)),
              sliver: SliverFixedExtentList.builder(
                itemExtent: 74.0,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final entry = filteredItems[index];
                  final isSelected = isSongSelected(entry.song.path);
                  return Align(
                    key: ValueKey(entry.song.path),
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SongListItem(
                          entry: entry,
                          l10n: l10n,
                          audio: audio,
                          trailingBuilder: widget.trailingBuilder,
                          isSelectionMode: isSelectionMode,
                          isSelected: isSelected,
                          onTap: () {
                            final isShift = ModifierKeyUtils.isRangeSelectPressed;
                            final isCtrl = ModifierKeyUtils.isDiscreteSelectPressed;

                            if (isShift) {
                              final anchor = _lastAnchorIndex ?? index;
                              final range = ModifierKeyUtils.getIndexRange(anchor, index);
                              final nextPaths = Set<String>.from(selectedSongPaths);
                              for (final i in range) {
                                if (i >= 0 && i < filteredItems.length) {
                                  nextPaths.add(filteredItems[i].song.path);
                                }
                              }
                              ref
                                  .read(librarySelectionStateProvider.notifier)
                                  .setSelection(nextPaths, scope: selectionScope);
                            } else if (isCtrl) {
                              toggleSongSelection(entry.song.path);
                              _lastAnchorIndex = index;
                            } else {
                              if (isSelectionMode) {
                                toggleSongSelection(entry.song.path);
                                _lastAnchorIndex = index;
                              } else {
                                _lastAnchorIndex = index;
                                audio.playPlaylist(
                                  filteredSongs,
                                  initialIndex: index,
                                );
                              }
                            }
                          },
                          onLongPress: () {
                            _lastAnchorIndex = index;
                            if (!isSelectionMode) {
                              enterSongSelectionMode(entry.song.path);
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );

    return Stack(
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
            child: isSelectionMode
                ? LibrarySelectionPanel(
                    key: const ValueKey('library-selection-panel'),
                    selectedSongs: selectedSongs,
                    allSongs: filteredSongs,
                    onToggleSelectAll: () => toggleSelectAllSongs(filteredSongs),
                    onCancel: cancelSongSelection,
                  )
                : const SizedBox.shrink(key: ValueKey('library-selection-panel-hidden')),
          ),
        ),
      ],
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
    required this.l10n,
    required this.audio,
    required this.trailingBuilder,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
  });

  final LibraryInsightSongEntry entry;
  final AppLocalizations l10n;
  final AudioService audio;
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
          enableFeedback: false,
          onTap: onTap,
          onLongPress: onLongPress,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onSecondaryTapDown: (details) async {
              if (!isSelectionMode) {
                await showSongBottomSheet(context, ref, song);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: isMissing
                              ? 0.35
                              : isSelectionMode
                                  ? (isSelected ? 0.5 : 0.7)
                                  : 1.0,
                          child: SongThumbnail(
                            path: song.path,
                            id: song.id,
                            size: 44,
                          ),
                        ),
                        if (isSelectionMode)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => onTap(),
                                  fillColor: WidgetStateProperty.all(Colors.white),
                                  checkColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                        const SizedBox(height: 3),
                        Text(
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 90),
                    child: trailingBuilder(context, entry),
                  ),
                ],
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
      mainAxisSize: MainAxisSize.min,
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
  final l10n = AppLocalizations.of(context);

  if (difference.inSeconds < 60 && difference.inSeconds >= 0) {
    return l10n?.justNow ?? 'Just now';
  } else if (difference.inMinutes < 60 && difference.inMinutes >= 1) {
    return l10n?.minutesAgo(difference.inMinutes) ?? '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24 && difference.inHours >= 1 && now.day == date.day) {
    final timeStr = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(date);
    return l10n?.todayTime(timeStr) ?? 'Today $timeStr';
  } else if (now.year == date.year && now.subtract(const Duration(days: 1)).day == date.day && now.subtract(const Duration(days: 1)).month == date.month) {
    final timeStr = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(date);
    return l10n?.yesterdayTime(timeStr) ?? 'Yesterday $timeStr';
  } else if (now.year == date.year) {
    return DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag()).format(date);
  } else {
    return DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(date);
  }
}
