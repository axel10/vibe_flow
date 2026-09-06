import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import '../widgets/song_tile.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import 'package:vynody/utils/deleted_song_snack.dart';
import 'package:vynody/utils/app_snack_bar.dart';
import 'package:vynody/widgets/queue_file_drop_target.dart';
import '../widgets/library_selection_scope.dart';
import '../widgets/library_selection_panel.dart';
import 'package:vynody/utils/layout_constants.dart';
import 'package:vynody/dialogs/sort_options_dialog.dart';

enum QueueSortField {
  title,
  artist,
  album,
  duration,
  filename,
  trackNumber,
}

// 队列页面
class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  ConsumerState<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends ConsumerState<QueuePage>
    with SelectionStateMixin<QueuePage, int> {
  @override
  LibrarySelectionScope get selectionScope => LibrarySelectionScope.queue;

  final Map<int, GlobalKey> _songTileKeys = {};
  int _viewIndex = 0; // 0: Normal Queue, 1: Random History, 2: Random Queue
  late final ScrollController _scrollController;
  int? _highlightedIndex;
  Timer? _highlightTimer;
  QueueSortField _sortField = QueueSortField.title;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _highlightTimer?.cancel();
    _songTileKeys.clear();
    super.dispose();
  }

  void _reorderSelectedIndices(int oldIndex, int newIndex) {
    if (selectedKeys.isEmpty) return;

    final updated = <int>{};
    for (final index in selectedKeys) {
      if (index == oldIndex) {
        updated.add(newIndex);
      } else if (oldIndex < newIndex) {
        if (index > oldIndex && index <= newIndex) {
          updated.add(index - 1);
        } else {
          updated.add(index);
        }
      } else if (newIndex < oldIndex) {
        if (index >= newIndex && index < oldIndex) {
          updated.add(index + 1);
        } else {
          updated.add(index);
        }
      } else {
        updated.add(index);
      }
    }

    ref
        .read(librarySelectionStateProvider.notifier)
        .setSelection(updated, scope: selectionScope);
  }

  List<MusicFile> _selectedSongsFromDisplay(List<MusicFile> displayQueue) {
    return selectedKeys
        .where((index) => index >= 0 && index < displayQueue.length)
        .map((index) => displayQueue[index])
        .toList(growable: false);
  }

  void _scrollToCurrentPlay() {
    final queue = ref.read(audioPlaybackQueueProvider);
    final randomHistory = ref.read(audioRandomHistoryProvider);
    final randomQueue = ref.read(audioRandomQueueProvider);
    final currentIndex = ref.read(audioCurrentIndexProvider);
    final historyCursor = ref.read(audioHistoryCursorProvider);
    final deckCursor = ref.read(audioDeckCursorProvider);

    final displayQueueLength = _viewIndex == 1
        ? randomHistory.length
        : _viewIndex == 2
        ? randomQueue.length
        : queue.length;

    final int? targetIndex;
    if (_viewIndex == 1) {
      targetIndex = historyCursor;
    } else if (_viewIndex == 2) {
      targetIndex = deckCursor;
    } else {
      targetIndex = currentIndex;
    }

    if (targetIndex != null && targetIndex >= 0 && targetIndex < displayQueueLength) {
      if (_scrollController.hasClients) {
        const double itemHeight = 80.0;
        final double viewportHeight = _scrollController.position.viewportDimension;
        double targetOffset = (targetIndex * itemHeight) - (viewportHeight / 2) + (itemHeight / 2);
        
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (targetOffset < 0) {
          targetOffset = 0;
        } else if (targetOffset > maxScroll) {
          targetOffset = maxScroll;
        }

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ).then((_) {
          if (mounted) {
            _highlightTimer?.cancel();
            setState(() {
              _highlightedIndex = targetIndex;
            });
            _highlightTimer = Timer(const Duration(milliseconds: 1000), () {
              if (mounted) {
                setState(() {
                  _highlightedIndex = null;
                });
              }
            });
          }
        });
      }
    }
  }

  GlobalKey _songTileKeyFor(int index, [MusicFile? song]) {
    return _songTileKeys.putIfAbsent(
      index,
      () => GlobalKey(debugLabel: 'queue-tile-$index'),
    );
  }

  void _showClearQueueDialog(BuildContext context) {
    final audio = ref.read(audioServiceProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearQueue),
        content: Text(AppLocalizations.of(context)!.confirmClearQueue),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              audio.clearPlaylist();
              Navigator.pop(context);
              if (context.mounted) {
                if (context.mounted) {
                  AppSnackBar.show(
                    context,
                    ref,
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.queueCleared),
                    ),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.clearQueue),
          ),
        ],
      ),
    );
  }

  Future<void> _showSortDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<SortResult<QueueSortField>>(
      context: context,
      builder: (context) => SortOptionsDialog<QueueSortField>(
        title: l10n.sort,
        currentField: _sortField,
        sortAscending: _sortAscending,
        options: [
          SortOptionItem(
            value: QueueSortField.title,
            label: l10n.title,
            icon: Icons.title_rounded,
          ),
          SortOptionItem(
            value: QueueSortField.artist,
            label: l10n.artists,
            icon: Icons.person_rounded,
          ),
          SortOptionItem(
            value: QueueSortField.album,
            label: l10n.albums,
            icon: Icons.album_rounded,
          ),
          SortOptionItem(
            value: QueueSortField.duration,
            label: l10n.sortDuration,
            icon: Icons.schedule_rounded,
          ),
          SortOptionItem(
            value: QueueSortField.filename,
            label: l10n.fileName,
            icon: Icons.insert_drive_file_outlined,
          ),
          SortOptionItem(
            value: QueueSortField.trackNumber,
            label: l10n.trackNumber,
            icon: Icons.numbers_rounded,
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _sortField = result.field;
        _sortAscending = result.sortAscending;
      });
      _applySort(result.field, result.sortAscending);
    }
  }

  void _applySort(QueueSortField field, bool ascending) {
    final currentQueue = ref.read(audioPlaybackQueueProvider);
    if (currentQueue.isEmpty) return;

    final sortedList = List<MusicFile>.from(currentQueue);
    sortedList.sort((a, b) {
      int cmp = 0;
      switch (field) {
        case QueueSortField.title:
          cmp = compareNatural(
            a.displayName.toLowerCase(),
            b.displayName.toLowerCase(),
          );
          break;
        case QueueSortField.artist:
          cmp = compareNatural(
            (a.artist ?? '').toLowerCase(),
            (b.artist ?? '').toLowerCase(),
          );
          if (cmp == 0) {
            cmp = compareNatural(
              a.displayName.toLowerCase(),
              b.displayName.toLowerCase(),
            );
          }
          break;
        case QueueSortField.album:
          cmp = compareNatural(
            (a.album ?? '').toLowerCase(),
            (b.album ?? '').toLowerCase(),
          );
          if (cmp == 0) {
            final aTrack = a.trackNumber ?? 0;
            final bTrack = b.trackNumber ?? 0;
            cmp = aTrack.compareTo(bTrack);
            if (cmp == 0) {
              cmp = compareNatural(
                a.displayName.toLowerCase(),
                b.displayName.toLowerCase(),
              );
            }
          }
          break;
        case QueueSortField.duration:
          final aDur = a.durationMillis ?? 0;
          final bDur = b.durationMillis ?? 0;
          cmp = aDur.compareTo(bDur);
          if (cmp == 0) {
            cmp = compareNatural(
              a.displayName.toLowerCase(),
              b.displayName.toLowerCase(),
            );
          }
          break;
        case QueueSortField.filename:
          cmp = compareNatural(a.name.toLowerCase(), b.name.toLowerCase());
          break;
        case QueueSortField.trackNumber:
          if (a.trackNumber != null && b.trackNumber != null) {
            cmp = a.trackNumber!.compareTo(b.trackNumber!);
          } else if (a.trackNumber != null) {
            cmp = -1;
          } else if (b.trackNumber != null) {
            cmp = 1;
          } else {
            cmp = compareNatural(
              a.displayName.toLowerCase(),
              b.displayName.toLowerCase(),
            );
          }
          break;
      }
      return ascending ? cmp : -cmp;
    });

    if (ref.read(librarySelectionScopeProvider) ==
        LibrarySelectionScope.queue) {
      cancelSelection();
    }
    ref.read(audioServiceProvider).updateQueue(sortedList);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Validate current view index against current mode
    if (_viewIndex == 1 && !ref.read(audioIsRandomModeProvider)) {
      _viewIndex = 0;
    }
    if (_viewIndex == 2 && !ref.read(audioIsShuffleRandomModeProvider)) {
      if (ref.read(audioIsRandomModeProvider)) {
        _viewIndex = 1;
      } else {
        _viewIndex = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode =
        ref.watch(librarySelectionScopeProvider) ==
        LibrarySelectionScope.queue;
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final bottomOffset = (currentMusic != null ? 140.0 : 40.0) +
        (isSelectionMode ? 220.0 : 0.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRandomMode = ref.watch(audioIsRandomModeProvider);
    final isShuffleRandomMode = ref.watch(audioIsShuffleRandomModeProvider);
    final queue = ref.watch(audioPlaybackQueueProvider);
    final randomHistory = ref.watch(audioRandomHistoryProvider);
    final randomQueue = ref.watch(audioRandomQueueProvider);
    final currentIndex = ref.watch(audioCurrentIndexProvider);
    final historyCursor = ref.watch(audioHistoryCursorProvider);
    final deckCursor = ref.watch(audioDeckCursorProvider);
    final showPreview = _viewIndex == 0;
    final displayQueue = _viewIndex == 1
        ? randomHistory
        : _viewIndex == 2
        ? randomQueue
        : queue;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final headerHorizontalPadding = isPortrait ? 20.0 : 32.0;
    final headerIconColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.85);

    if (queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          notificationPredicate: (_) => false,
          titleSpacing: 0,
          centerTitle: true,
          title: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kSingleColumnContentMaxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: headerHorizontalPadding,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.queue,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: isPortrait
                          ? IconButton(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: 20,
                                color: headerIconColor.withValues(alpha: 0.38),
                              ),
                              onPressed: null,
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.sort_rounded,
                                    size: 20,
                                    color:
                                        headerIconColor.withValues(alpha: 0.38),
                                  ),
                                  onPressed: null,
                                  tooltip: AppLocalizations.of(context)!.sort,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.my_location_rounded,
                                    size: 20,
                                    color:
                                        headerIconColor.withValues(alpha: 0.38),
                                  ),
                                  onPressed: null,
                                  tooltip: AppLocalizations.of(
                                    context,
                                  )!.locateCurrentSong,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_sweep_rounded,
                                    size: 20,
                                    color:
                                        headerIconColor.withValues(alpha: 0.38),
                                  ),
                                  onPressed: null,
                                  tooltip:
                                      AppLocalizations.of(context)!.queueEmpty,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: QueueFileDropTarget(
          enabled: true,
          displayQueue: displayQueue,
          queueSongs: queue,
          itemKeyBuilder: _songTileKeyFor,
          showPreview: showPreview,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kSingleColumnContentMaxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.queue_music,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.queueEmpty,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        notificationPredicate: (_) => false,
        titleSpacing: 0,
        centerTitle: true,
        title: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kSingleColumnContentMaxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: headerHorizontalPadding,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: isRandomMode
                        ? _buildViewSelector(
                            context,
                            theme,
                            isDark,
                            isShuffleRandomMode,
                          )
                        : Text(
                            AppLocalizations.of(context)!.queue,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    child: isPortrait
                        ? PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              size: 20,
                              color: headerIconColor,
                            ),
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).moreButtonTooltip,
                            onSelected: (value) {
                              if (value == 'sort') {
                                _showSortDialog(context);
                              } else if (value == 'locate') {
                                _scrollToCurrentPlay();
                              } else if (value == 'clear') {
                                _showClearQueueDialog(context);
                              }
                            },
                            itemBuilder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return [
                                PopupMenuItem(
                                  value: 'sort',
                                  enabled: _viewIndex == 0,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.sort_rounded, size: 20),
                                      const SizedBox(width: 12),
                                      Text(l10n.sort),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'locate',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.my_location_rounded,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(l10n.locateCurrentSong),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'clear',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete_sweep_rounded,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(l10n.clearQueue),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.sort_rounded,
                                  size: 20,
                                  color: _viewIndex == 0
                                      ? headerIconColor
                                      : headerIconColor.withValues(alpha: 0.38),
                                ),
                                onPressed: _viewIndex == 0
                                    ? () => _showSortDialog(context)
                                    : null,
                                tooltip: AppLocalizations.of(context)!.sort,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.my_location_rounded,
                                  size: 20,
                                  color: headerIconColor,
                                ),
                                onPressed: _scrollToCurrentPlay,
                                tooltip: AppLocalizations.of(
                                  context,
                                )!.locateCurrentSong,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_sweep_rounded,
                                  size: 20,
                                  color: headerIconColor,
                                ),
                                onPressed: () => _showClearQueueDialog(context),
                                tooltip: AppLocalizations.of(
                                  context,
                                )!.clearQueue,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: QueueFileDropTarget(
        enabled: true,
        displayQueue: displayQueue,
        queueSongs: queue,
        itemKeyBuilder: _songTileKeyFor,
        showPreview: showPreview,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ReorderableListView.builder(
                          scrollController: _scrollController,
                          buildDefaultDragHandles: false,
                          cacheExtent: 1000,
                          padding: EdgeInsets.only(bottom: bottomOffset),
                          itemCount: displayQueue.length,
                          onReorder: (oldIndex, newIndex) {
                            if (_viewIndex != 0) return;
                            if (newIndex > oldIndex) newIndex--;
                            setState(() {
                              _reorderSelectedIndices(oldIndex, newIndex);
                            });
                            ref
                                .read(audioServiceProvider)
                                .moveQueueTrack(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final song = displayQueue[index];
                            final isMissing = song.isMissing;

                            final bool isCurrent;
                            if (_viewIndex == 1) {
                              isCurrent = (index == historyCursor);
                            } else if (_viewIndex == 2) {
                              isCurrent = (index == deckCursor);
                            } else {
                              isCurrent = (currentIndex == index);
                            }
                            final isSelected = this.isSelected(index);
                            final songsToAdd = selectedKeys.isNotEmpty
                                ? _selectedSongsFromDisplay(displayQueue)
                                : <MusicFile>[song];

                            void handleShowMenu(
                              BuildContext menuContext,
                              Offset position,
                            ) {
                              showSongContextMenu(
                                menuContext,
                                position,
                                song: song,
                                songs: songsToAdd,
                                mode: SongContextMenuMode.full,
                                onAddToPlaylist: () =>
                                    showAddSongsToPlaylistDialog(
                                      menuContext,
                                      ref.read(playlistServiceProvider),
                                      songsToAdd,
                                    ),
                                onPlayNext:
                                    (isCurrent ||
                                        isSelectionMode ||
                                        _viewIndex == 1 ||
                                        _viewIndex == 2)
                                    ? null
                                    : () {
                                        final curIdx = ref.read(
                                          audioCurrentIndexProvider,
                                        );
                                        if (curIdx >= 0) {
                                          final insertIndex = index < curIdx
                                              ? curIdx
                                              : curIdx + 1;
                                          ref
                                              .read(audioServiceProvider)
                                              .moveQueueTrack(
                                                index,
                                                insertIndex,
                                              );
                                        }
                                      },
                                onRemoveFromQueue:
                                    (isSelectionMode ||
                                        _viewIndex == 1 ||
                                        _viewIndex == 2)
                                    ? null
                                    : () => ref
                                          .read(audioServiceProvider)
                                          .removeFromPlaylist(index),
                              );
                            }

                            return Align(
                              key: _songTileKeyFor(index, song),
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: kSingleColumnContentMaxWidth),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? 8
                                        : 16,
                                    vertical: 4,
                                  ),
                                  child: SongTile(
                                    song: song,
                                    isCurrent: isCurrent,
                                    isSelected: isSelected,
                                    isSelectionMode: isSelectionMode,
                                    isHighlighted: _highlightedIndex == index,
                                    dragHandle: ReorderableDragStartListener(
                                      index: index,
                                      child: const Icon(Icons.drag_handle),
                                    ),
                                    onTap: () {
                                      if (isMissing) {
                                        showDeletedSongSnack(
                                          context,
                                          ref,
                                          skipped: false,
                                        );
                                        return;
                                      }

                                      handleItemTap(
                                        index: index,
                                        itemKey: index,
                                        allKeys: List.generate(
                                          displayQueue.length,
                                          (i) => i,
                                        ),
                                        onNormalTap: () {
                                          if (_viewIndex == 1 ||
                                              _viewIndex == 2) {
                                            final actualIndex = queue
                                                .indexWhere(
                                                  (s) => s.path == song.path,
                                                );
                                            if (actualIndex >= 0) {
                                              ref
                                                  .read(audioServiceProvider)
                                                  .playAtIndex(actualIndex);
                                            }
                                          } else {
                                            ref
                                                .read(audioServiceProvider)
                                                .playAtIndex(index);
                                          }
                                        },
                                      );
                                    },
                                     onLongPress: () {
                                       lastAnchorIndex = index;
                                       if (!isSelectionMode) {
                                         enterSelectionMode(index);
                                       }
                                     },
                                    onSecondaryTapDown: (details) {
                                      handleShowMenu(
                                        context,
                                        details.globalPosition,
                                      );
                                    },
                                    onMorePressed: (buttonContext) {
                                      final renderObject = buttonContext
                                          .findRenderObject();
                                      final renderBox =
                                          renderObject is RenderBox
                                              ? renderObject
                                              : null;
                                      if (renderBox == null) return;
                                      final Offset offset = renderBox
                                          .localToGlobal(Offset.zero);
                                      handleShowMenu(buttonContext, offset);
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
                ),
              ],
            ),
            AnimatedSelectionPanel(
              isVisible: isSelectionMode,
              child: LibrarySelectionPanel(
                key: const ValueKey('library-selection-panel'),
                selectedSongs: _selectedSongsFromDisplay(
                  displayQueue,
                ),
                allSongs: displayQueue,
                onToggleSelectAll: () => toggleSelectAll(
                  List.generate(displayQueue.length, (i) => i),
                ),
                onCancel: cancelSelection,
                replaceFavoritesWithSongDetails: true,
                onDelete: _viewIndex == 0
                    ? () {
                        final sortedIndices =
                            selectedKeys.toList()..sort();
                        // Remove in reverse order to maintain indices
                        for (
                          int i = sortedIndices.length - 1;
                          i >= 0;
                          i--
                        ) {
                          ref
                              .read(audioServiceProvider)
                              .removeFromPlaylist(sortedIndices[i]);
                        }
                        cancelSelection();
                        if (context.mounted) {
                          AppSnackBar.show(
                            context,
                            ref,
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.deletedSongs(sortedIndices.length),
                              ),
                            ),
                          );
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSelector(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isShuffleRandomMode,
  ) {
    String selectedText = '';
    IconData selectedIcon = Icons.queue_music;
    if (_viewIndex == 0) {
      selectedText = AppLocalizations.of(context)!.queue;
      selectedIcon = Icons.queue_music;
    } else if (_viewIndex == 1) {
      selectedText = AppLocalizations.of(context)!.randomHistory;
      selectedIcon = Icons.history;
    } else if (_viewIndex == 2) {
      selectedText = AppLocalizations.of(context)!.randomQueue;
      selectedIcon = Icons.shuffle;
    }

    return Theme(
      data: theme.copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<int>(
        offset: const Offset(0, 8),
        position: PopupMenuPosition.under,
        tooltip: AppLocalizations.of(context)!.queue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        color: isDark ? Colors.grey[900] : theme.colorScheme.surface,
        elevation: 8,
        onSelected: (val) {
          setState(() {
            _viewIndex = val;
          });
        },
        itemBuilder: (context) => [
          _buildPopupMenuItem(
            context,
            value: 0,
            text: AppLocalizations.of(context)!.queue,
            icon: Icons.queue_music,
            isSelected: _viewIndex == 0,
          ),
          _buildPopupMenuItem(
            context,
            value: 1,
            text: AppLocalizations.of(context)!.randomHistory,
            icon: Icons.history,
            isSelected: _viewIndex == 1,
          ),
          if (isShuffleRandomMode)
            _buildPopupMenuItem(
              context,
              value: 2,
              text: AppLocalizations.of(context)!.randomQueue,
              icon: Icons.shuffle,
              isSelected: _viewIndex == 2,
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDark ? Colors.white : theme.colorScheme.primary).withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selectedIcon,
                size: 16,
                color: isDark ? Colors.white70 : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                selectedText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isDark ? Colors.white.withValues(alpha: 0.5) : theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem(
    BuildContext context, {
    required int value,
    required String text,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getForegroundColor() {
      if (isSelected) {
        return theme.colorScheme.primary;
      }
      return isDark ? Colors.white70 : Colors.black87;
    }

    return PopupMenuItem<int>(
      value: value,
      height: 48,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: getForegroundColor(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: getForegroundColor(),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
