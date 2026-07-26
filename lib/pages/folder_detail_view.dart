import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/playback_source.dart';
import 'package:vynody/player/scanner/scanner_sorting.dart';
import 'package:vynody/player/scanner/scanner_service.dart';
import 'package:vynody/player/scanner/scanner_path_utils.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import '../widgets/library_selection_panel.dart';
import '../widgets/folder_header_banner.dart';
import '../widgets/song_thumbnail.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/utils/folder_helpers.dart';
import '../widgets/folder_layout_utils.dart';
import '../widgets/folder_content_slivers.dart';

class FolderDetailView extends ConsumerStatefulWidget {
  const FolderDetailView({
    super.key,
    required this.folder,
    required this.onOpenPlayback,
    required this.isSelectionMode,
    required this.selectedSongPaths,
    required this.selectedFolderPaths,
    required this.onNavigateTo,
    required this.onGoBack,
    required this.onToggleSelectionMode,
    required this.onToggleFolderSelection,
    required this.onToggleSelection,
    required this.onSelectAllVisible,
    required this.onClearAllSelection,
    required this.onLocateCurrentSong,
    required this.onShowFolderBottomSheet,
    required this.highlightedSongPath,
  });

  final MusicFolder folder;
  final Future<void> Function()? onOpenPlayback;
  final bool isSelectionMode;
  final Set<String> selectedSongPaths;
  final Set<String> selectedFolderPaths;
  final void Function(MusicFolder) onNavigateTo;
  final VoidCallback onGoBack;
  final VoidCallback onToggleSelectionMode;
  final void Function(String) onToggleFolderSelection;
  final void Function(String) onToggleSelection;
  final VoidCallback onSelectAllVisible;
  final VoidCallback onClearAllSelection;
  final VoidCallback onLocateCurrentSong;
  final void Function(MusicFolder, {required bool isRoot}) onShowFolderBottomSheet;
  final String? highlightedSongPath;

  @override
  ConsumerState<FolderDetailView> createState() => _FolderDetailViewState();
}

class _FolderDetailViewState extends ConsumerState<FolderDetailView> {
  late final ScrollController _localScrollController;
  late final TextEditingController _searchController;
  final ScrollController _breadcrumbsScrollController = ScrollController();
  bool _isSearching = false;
  bool _isSearchLoading = false;
  String _searchQuery = '';
  List<MusicFile> _matchedSongs = [];
  Timer? _searchDebounce;
  String? _lastHighlightedPath;
  bool _isCoverVisible = true;
  bool _showStatusBarOverlay = false;

  void _performSearch(String query) {
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _matchedSongs = [];
        _isSearchLoading = false;
      });
      return;
    }
    setState(() {
      _isSearchLoading = true;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      final results = await ref.read(scannerServiceProvider).searchSongs(
        query,
        folderPath: _effectiveFolder.path,
      );
      if (mounted) {
        setState(() {
          _matchedSongs = results;
          _isSearchLoading = false;
        });
      }
    });
  }

  MusicFolder get _effectiveFolder {
    if (widget.folder.path == 'system') {
      return ref.read(scannerServiceProvider).systemMediaFolder ?? widget.folder;
    }
    return widget.folder;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    final targetOffset = ref.read(scannerServiceProvider).getFolderScrollOffset(_effectiveFolder.path);
    _localScrollController = ScrollController(initialScrollOffset: targetOffset);
    _isCoverVisible = targetOffset < 160.0;
    _localScrollController.addListener(_onScroll);

    if (widget.highlightedSongPath != null) {
      _lastHighlightedPath = widget.highlightedSongPath;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlightedSong());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_breadcrumbsScrollController.hasClients) {
        _breadcrumbsScrollController.jumpTo(
          _breadcrumbsScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  void didUpdateWidget(FolderDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedSongPath != null && widget.highlightedSongPath != _lastHighlightedPath) {
      _lastHighlightedPath = widget.highlightedSongPath;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlightedSong());
    }
  }

  void _onScroll() {
    final offset = _localScrollController.offset;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = 64.0 + statusBarHeight;

    ref.read(scannerServiceProvider).setFolderScrollOffset(
      _effectiveFolder.path,
      offset,
    );
    final isVisible = offset < 160.0;
    if (isVisible != _isCoverVisible) {
      setState(() {
        _isCoverVisible = isVisible;
      });
    }

    bool showOverlay = false;
    if (offset > headerHeight) {
      final direction = _localScrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse) {
        showOverlay = true;
      } else if (direction == ScrollDirection.forward) {
        showOverlay = false;
      } else {
        showOverlay = _showStatusBarOverlay;
      }
    } else {
      showOverlay = false;
    }

    if (showOverlay != _showStatusBarOverlay) {
      setState(() {
        _showStatusBarOverlay = showOverlay;
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _localScrollController.removeListener(_onScroll);
    _localScrollController.dispose();
    _breadcrumbsScrollController.dispose();
    super.dispose();
  }

  List<MusicFolder> _findMatchingFolders(MusicFolder root, String query) {
    final results = <MusicFolder>[];
    final lowercaseQuery = query.toLowerCase();

    void search(MusicFolder folder) {
      if (folder.name.toLowerCase().contains(lowercaseQuery)) {
        results.add(folder);
      }
      for (final sub in folder.subFolders) {
        search(sub);
      }
    }

    for (final sub in root.subFolders) {
      search(sub);
    }
    return results;
  }

  void _scrollToHighlightedSong() {
    if (!mounted) return;
    final songPath = widget.highlightedSongPath;
    if (songPath == null) return;

    final folder = _effectiveFolder;
    final matchedFolders = _searchQuery.isNotEmpty
        ? _findMatchingFolders(folder, _searchQuery)
        : folder.subFolders;
    final matchedSongs = _searchQuery.isNotEmpty
        ? _matchedSongs
        : folder.files;
    final fileIndex = matchedSongs.indexWhere((file) => p.equals(file.path, songPath));
    if (fileIndex == -1) return;

    final hasPermission = ref.read(scannerServiceProvider).hasPermission;
    final showPermissionWarning = folder.path == 'system' && !hasPermission;
    final settings = ref.read(settingsServiceProvider);

    double fileOffset = 48.0;
    fileOffset += 190.0;

    if (showPermissionWarning) {
      fileOffset += 200.0;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final double crossAxisExtent = screenWidth - 32;
    final int crossAxisCount = getFolderGridCrossAxisCount(crossAxisExtent);

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final textScale = MediaQuery.textScalerOf(context).scale(10) / 10;
    final clampedScale = textScale.clamp(1.0, 1.3);
    final double textHeight = (isPortrait ? 72.0 : 84.0) * clampedScale;
    final double cardWidth = (crossAxisExtent - (crossAxisCount - 1) * 16) / crossAxisCount;
    final double cardHeight = cardWidth + textHeight;

    final isFolderGrid = settings.folderViewMode == FolderViewMode.hybrid ||
        settings.folderViewMode == FolderViewMode.grid;
    final isSongGrid = settings.folderViewMode == FolderViewMode.grid;

    if (isFolderGrid) {
      final totalGridItems = matchedFolders.length;
      final int rows = (totalGridItems / crossAxisCount).ceil();
      fileOffset += rows * (cardHeight + 16);
    } else {
      fileOffset += matchedFolders.length * 80.0;
    }

    if (isSongGrid) {
      final int songRows = (fileIndex / crossAxisCount).floor();
      fileOffset += songRows * (cardHeight + 16);
    } else {
      fileOffset += fileIndex * 80.0;
    }

    if (_localScrollController.hasClients) {
      final double viewportHeight = _localScrollController.position.viewportDimension;
      double targetOffset = fileOffset - (viewportHeight / 2) + (isSongGrid ? cardHeight / 2 : 40.0);
      final maxScroll = _localScrollController.position.maxScrollExtent;
      targetOffset = targetOffset.clamp(0.0, maxScroll);

      _localScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<MusicFile> _getSelectedSongs() {
    final songs = <MusicFile>[];
    final folder = _effectiveFolder;
    songs.addAll(
      folder.allSongs.where(
        (file) => widget.selectedSongPaths.contains(file.path),
      ),
    );
    for (final sub in folder.subFolders) {
      if (widget.selectedFolderPaths.contains(sub.path)) {
        songs.addAll(sub.allSongs);
      }
    }
    final seen = <String>{};
    return songs.where((song) => seen.add(song.path)).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final folder = _effectiveFolder;
    final scanner = ref.watch(scannerServiceProvider);
    final settings = ref.watch(settingsServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    final hasPermission = ref.watch(
      scannerServiceProvider.select((scanner) => scanner.hasPermission),
    );
    final audio = ref.read(audioServiceProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isPlaying = ref.watch(audioIsPlayingProvider);

    final matchedFolders = _searchQuery.isNotEmpty
        ? _findMatchingFolders(folder, _searchQuery)
        : folder.subFolders;
    final matchedSongs = _searchQuery.isNotEmpty
        ? _matchedSongs
        : folder.files;

    final showSelectionPanel =
        widget.isSelectionMode &&
        isUserRootSelectionContext(
          scanner,
          folder,
          scanner.navigationHistory,
        );
    final selectionPanelHeight = showSelectionPanel ? 220.0 : 0.0;

    final representativeSong = scanner.getRepresentativeSongForFolder(folder);

    final totalDurationMs = folder.allSongs.fold<int>(
      0,
      (sum, song) => sum + (song.durationMillis ?? 0),
    );

    final showSearchLoading = _searchQuery.isNotEmpty && _isSearchLoading && matchedFolders.isEmpty && matchedSongs.isEmpty;
    final noResults = _searchQuery.isNotEmpty && matchedFolders.isEmpty && matchedSongs.isEmpty && !_isSearchLoading;

    final Widget scrollBody = CustomScrollView(
      key: ValueKey(folder.path),
      controller: _localScrollController,
      cacheExtent: 1000.0,
      slivers: [
        SliverPersistentHeader(
          delegate: _BreadcrumbsHeaderDelegate(
            child: _buildBreadcrumbs(folder, scanner),
            height: 64.0 + MediaQuery.of(context).padding.top,
          ),
          pinned: !Platform.isAndroid && !Platform.isIOS,
          floating: Platform.isAndroid || Platform.isIOS,
        ),
        SliverToBoxAdapter(
          child: FolderHeaderBanner(
            title: folder.name,
            subtitle: ScannerPathUtils.cleanDisplayPath(folder.path),
            songsCount: folder.allSongs.length,
            totalDuration: Duration(milliseconds: totalDurationMs),
            coverWidget: representativeSong != null
                ? SongThumbnail(
                    path: representativeSong.path,
                    id: representativeSong.id,
                    thumbnailPath: representativeSong.thumbnailPath,
                    size: 100,
                    width: 100,
                    height: 100,
                    borderRadius: BorderRadius.zero,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          HSLColor.fromAHSL(1.0, (folder.path.hashCode.abs() % 360).toDouble(), 0.65, 0.45).toColor(),
                          HSLColor.fromAHSL(1.0, ((folder.path.hashCode.abs() % 360 + 40) % 360).toDouble(), 0.75, 0.35).toColor(),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.folder_rounded, size: 40, color: Colors.white70),
                    ),
                  ),
            actionButtons: [
              FolderPlayActionButtons(
                totalSongsCount: folder.allSongs.length,
                onPlayAll: () => audio.playPlaylist(
                  folder.allSongs,
                  source: PlaybackSource(
                    type: PlaybackSourceType.folder,
                    id: folder.path,
                    name: folder.name,
                  ),
                ),
                onShufflePlay: () => audio.playPlaylist(
                  List.of(folder.allSongs)..shuffle(),
                  source: PlaybackSource(
                    type: PlaybackSourceType.folder,
                    id: folder.path,
                    name: folder.name,
                  ),
                ),
              ),
            ],
            actionButtonsScrollable: false,
            isSearching: _isSearching,
            searchController: _searchController,
            searchQuery: _searchQuery,
            searchHintText: l10n.searchInFolderAndSubfolders,
            onSearchQueryChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
              _performSearch(val.trim());
            },
            onToggleSearch: (val) {
              setState(() {
                _isSearching = val;
                if (!val) {
                  _searchQuery = '';
                  _matchedSongs = [];
                  _isSearchLoading = false;
                }
              });
            },
            heroTag: 'folder-cover-${folder.path}',
            isHeroModeEnabled: _isCoverVisible,
          ),
        ),
        if (folder.path == 'system' && !hasPermission)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.noMediaLibraryPermission),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => scanner.checkAndRequestPermissions(),
                      child: Text(l10n.grantPermission),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (showSearchLoading)
          FolderEmptySearchResultsSliver(
            message: l10n.searching,
            isSearching: true,
          )
        else if (noResults)
          FolderEmptySearchResultsSliver(
            message: l10n.noMatchingFoldersOrSongs,
            isSearching: false,
          )
        else ...[
          FolderSubfoldersSliver(
            folders: matchedFolders,
            viewMode: settings.folderViewMode,
            scanner: scanner,
            isSelectionMode: widget.isSelectionMode,
            selectedFolderPaths: widget.selectedFolderPaths,
            isRoot: false,
            onNavigateTo: widget.onNavigateTo,
            onToggleFolderSelection: widget.onToggleFolderSelection,
            onToggleSelectionMode: widget.onToggleSelectionMode,
            onShowFolderBottomSheet: widget.onShowFolderBottomSheet,
          ),
          if (matchedFolders.isNotEmpty && matchedSongs.isNotEmpty)
            FolderSectionHeaderSliver(
              title: l10n.songsCountFormat(matchedSongs.length),
            ),
          FolderSongsSliver(
            songs: matchedSongs,
            viewMode: settings.folderViewMode,
            currentSongPath: currentMusic?.path,
            isPlaying: isPlaying,
            isSelectionMode: widget.isSelectionMode,
            selectedSongPaths: widget.selectedSongPaths,
            highlightedSongPath: widget.highlightedSongPath,
            onSongTap: (file, fileIndex) async {
              if (widget.isSelectionMode) {
                widget.onToggleSelection(file.path);
              } else {
                unawaited(() async {
                  try {
                    await audio.playPlaylist(
                      matchedSongs,
                      initialIndex: fileIndex,
                      source: PlaybackSource(
                        type: PlaybackSourceType.folder,
                        id: folder.path,
                        name: folder.name,
                      ),
                    );
                  } catch (e, st) {
                    debugPrint(
                      'FoldersPage: failed to start folder playback for ${file.path}: $e',
                    );
                    debugPrintStack(stackTrace: st);
                  }
                }());

                if (mounted) {
                  widget.onClearAllSelection();
                  if (settings.openPlaybackOnDirectorySongTap) {
                    await widget.onOpenPlayback?.call();
                  }
                }
              }
            },
            onSongLongPress: (file) {
              if (!widget.isSelectionMode) {
                widget.onToggleSelectionMode();
                widget.onToggleSelection(file.path);
              } else {
                widget.onToggleSelection(file.path);
              }
            },
            onSongSecondaryTapDown: (file, details) {
              final songsToAdd = (widget.selectedSongPaths.isNotEmpty ||
                      widget.selectedFolderPaths.isNotEmpty)
                  ? _getSelectedSongs()
                  : <MusicFile>[file];
              showSongContextMenu(
                context,
                details.globalPosition,
                song: file,
                songs: songsToAdd,
                mode: SongContextMenuMode.full,
                onAddToPlaylist: () => showAddSongsToPlaylistDialog(
                  context,
                  ref.read(playlistServiceProvider),
                  songsToAdd,
                ),
                onPlayNext: () =>
                    ref.read(audioServiceProvider).enqueueNext(songsToAdd),
                onAddToQueue: () =>
                    ref.read(audioServiceProvider).appendToQueue(songsToAdd),
              );
            },
            onSongMorePressed: (file, buttonContext) {
              final renderObject = buttonContext.findRenderObject();
              final renderBox =
                  renderObject is RenderBox ? renderObject : null;
              if (renderBox == null) return;
              final Offset offset = renderBox.localToGlobal(Offset.zero);
              final songsToAdd = (widget.selectedSongPaths.isNotEmpty ||
                      widget.selectedFolderPaths.isNotEmpty)
                  ? _getSelectedSongs()
                  : <MusicFile>[file];
              showSongContextMenu(
                buttonContext,
                offset,
                song: file,
                songs: songsToAdd,
                mode: SongContextMenuMode.full,
                onAddToPlaylist: () => showAddSongsToPlaylistDialog(
                  buttonContext,
                  ref.read(playlistServiceProvider),
                  songsToAdd,
                ),
                onPlayNext: () =>
                    ref.read(audioServiceProvider).enqueueNext(songsToAdd),
                onAddToQueue: () =>
                    ref.read(audioServiceProvider).appendToQueue(songsToAdd),
              );
            },
            bottomPadding: 0,
          ),
        ],
        SliverPadding(
          padding: EdgeInsets.only(bottom: 160 + selectionPanelHeight),
        ),
      ],
    );

    final selectedSongs = showSelectionPanel ? _getSelectedSongs() : <MusicFile>[];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        widget.onGoBack();
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              Column(
                children: [
                  if (widget.isSelectionMode && !showSelectionPanel)
                    Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      padding: EdgeInsets.only(
                        top: 8 + MediaQuery.of(context).padding.top,
                        bottom: 8,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        children: [
                          Text(l10n.selectedSongs(_getSelectedSongs().length)),
                          const Spacer(),
                          TextButton(
                            onPressed: widget.onToggleSelectionMode,
                            child: Text(l10n.cancel),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: folderPageMaxWidth),
                        child: scrollBody,
                      ),
                    ),
                  ),
                ],
              ),
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
                  child: showSelectionPanel
                      ? LibrarySelectionPanel(
                          key: const ValueKey('folder-selection-panel'),
                          selectedSongs: selectedSongs,
                          allSongs: folder.allSongs,
                          onToggleSelectAll: () {
                            final isAllSelected =
                                selectedSongs.length == folder.allSongs.length &&
                                folder.allSongs.isNotEmpty;
                            if (isAllSelected) {
                              widget.onClearAllSelection();
                            } else {
                              widget.onSelectAllVisible();
                            }
                          },
                          onCancel: widget.onClearAllSelection,
                          onOpenLocation: (widget.selectedFolderPaths.length == 1 &&
                                  widget.selectedSongPaths.isEmpty)
                              ? () => openFolderLocation(widget.selectedFolderPaths.first)
                              : null,
                          openLocationLabel: (widget.selectedFolderPaths.length == 1 &&
                                  widget.selectedSongPaths.isEmpty)
                              ? l10n.openFolderLocation
                              : null,
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('folder-selection-panel-hidden'),
                        ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).padding.top,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _showStatusBarOverlay ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs(MusicFolder current, ScannerService scanner) {
    final theme = Theme.of(context);
    final currentMusic = ref.watch(audioCurrentMusicProvider);

    final backButton = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onGoBack,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );

    final backChevron = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );

    List<Widget> breadcrumbItems = [];

    breadcrumbItems.add(
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            scanner.setNavigationState(null, []);
            widget.onClearAllSelection();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Icon(
              Icons.home_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );

    for (int i = 0; i < scanner.navigationHistory.length; i++) {
      final folder = scanner.navigationHistory[i];
      breadcrumbItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      );
      breadcrumbItems.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              scanner.setNavigationState(
                folder,
                scanner.navigationHistory.take(i).toList(),
              );
              widget.onClearAllSelection();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Text(
                folder.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        ),
      );
    }

    breadcrumbItems.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          Icons.chevron_right_rounded,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
    breadcrumbItems.add(
      Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Text(
          current.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );

    final settings = ref.watch(settingsServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: 8 + statusBarHeight,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          backButton,
          backChevron,
          Expanded(
            child: SingleChildScrollView(
              controller: _breadcrumbsScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(children: breadcrumbItems),
            ),
          ),
          const SizedBox(width: 8),
          if (isPortrait)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'locate') {
                  widget.onLocateCurrentSong();
                } else if (value == 'sort') {
                  _showSortDialog(context, scanner);
                } else if (value == 'view_mode') {
                  settings.folderViewMode = switch (settings.folderViewMode) {
                    FolderViewMode.list => FolderViewMode.hybrid,
                    FolderViewMode.hybrid => FolderViewMode.grid,
                    FolderViewMode.grid => FolderViewMode.list,
                  };
                }
              },
              itemBuilder: (context) => [
                if (currentMusic != null)
                  PopupMenuItem(
                    value: 'locate',
                    child: Row(
                      children: [
                        const Icon(Icons.my_location_rounded, size: 20),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.locateCurrentSong),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'sort',
                  child: Row(
                    children: [
                      const Icon(Icons.sort, size: 20),
                      const SizedBox(width: 12),
                      Text(AppLocalizations.of(context)!.sort),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'view_mode',
                  child: Row(
                    children: [
                      Icon(
                        switch (settings.folderViewMode) {
                          FolderViewMode.list => Icons.grid_view_rounded,
                          FolderViewMode.hybrid => Icons.view_module_rounded,
                          FolderViewMode.grid => Icons.view_list_rounded,
                        },
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        switch (settings.folderViewMode) {
                          FolderViewMode.list => l10n.hybridView,
                          FolderViewMode.hybrid => l10n.gridView,
                          FolderViewMode.grid => l10n.listView,
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            if (currentMusic != null) ...[
              IconButton(
                icon: const Icon(Icons.my_location_rounded),
                onPressed: widget.onLocateCurrentSong,
                tooltip: AppLocalizations.of(context)!.locateCurrentSong,
              ),
              const SizedBox(width: 8),
            ],
            IconButton(
              icon: Icon(
                switch (settings.folderViewMode) {
                  FolderViewMode.list => Icons.grid_view_rounded,
                  FolderViewMode.hybrid => Icons.view_module_rounded,
                  FolderViewMode.grid => Icons.view_list_rounded,
                },
              ),
              onPressed: () {
                settings.folderViewMode = switch (settings.folderViewMode) {
                  FolderViewMode.list => FolderViewMode.hybrid,
                  FolderViewMode.hybrid => FolderViewMode.grid,
                  FolderViewMode.grid => FolderViewMode.list,
                };
              },
              tooltip: switch (settings.folderViewMode) {
                FolderViewMode.list => l10n.hybridView,
                FolderViewMode.hybrid => l10n.gridView,
                FolderViewMode.grid => l10n.listView,
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () => _showSortDialog(context, scanner),
              tooltip: AppLocalizations.of(context)!.sort,
            ),
          ],
        ],
      ),
    );
  }

  void _showSortDialog(BuildContext context, ScannerService scanner) {
    final currentFolder = _effectiveFolder;
    final currentFolderPath = currentFolder.path;
    final globalSettings = scanner.getGlobalSortSettings();
    final currentFolderSettings = scanner.getSortSettingsForFolder(currentFolderPath);
    final initialScope = scanner.hasSortOverrideForFolder(currentFolderPath)
        ? SortScope.currentFolder
        : SortScope.global;
    var selectedScope = initialScope;
    var selectedCriteria = initialScope == SortScope.currentFolder
        ? currentFolderSettings.criteria
        : globalSettings.criteria;
    var selectedOrder = initialScope == SortScope.currentFolder
        ? currentFolderSettings.order
        : globalSettings.order;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void syncSelectionForScope(SortScope scope) {
              final settings =
                  scope == SortScope.currentFolder
                  ? scanner.getSortSettingsForFolder(currentFolderPath)
                  : scanner.getGlobalSortSettings();
              selectedCriteria = settings.criteria;
              selectedOrder = settings.order;
            }

            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.sortBy),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.sortScope,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  RadioGroup<SortScope>(
                    onChanged: (v) {
                      if (v == null || v == selectedScope) return;
                      setState(() {
                        selectedScope = v;
                        syncSelectionForScope(v);
                      });
                    },
                    groupValue: selectedScope,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.currentFolderScope,
                          ),
                          leading: const Radio(
                            value: SortScope.currentFolder,
                          ),
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.globalScope,
                          ),
                          leading: const Radio(value: SortScope.global),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.sortBy,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  RadioGroup<SortCriteria>(
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        selectedCriteria = v;
                      });
                      scanner.setSortCriteria(
                        v,
                        scope: selectedScope,
                        folderPath: currentFolder.path,
                      );
                    },
                    groupValue: selectedCriteria,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.title),
                          leading: const Radio(value: SortCriteria.title),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.fileName),
                          leading: const Radio(value: SortCriteria.filename),
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.trackNumber,
                          ),
                          leading: const Radio(value: SortCriteria.trackNumber),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.sortOrder,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  RadioGroup<SortOrder>(
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        selectedOrder = v;
                      });
                      scanner.setSortOrder(
                        v,
                        scope: selectedScope,
                        folderPath: currentFolder.path,
                      );
                    },
                    groupValue: selectedOrder,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.ascending),
                          leading: const Radio(value: SortOrder.ascending),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.descending),
                          leading: const Radio(value: SortOrder.descending),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

}

class _BreadcrumbsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _BreadcrumbsHeaderDelegate({
    required this.child,
    required this.height,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: height,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _BreadcrumbsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
