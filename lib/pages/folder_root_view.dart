import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/playback_source.dart';
import '../widgets/library_selection_panel.dart';
import '../widgets/library_selection_scope.dart';
import '../widgets/folder_header_banner.dart';
import '../widgets/song_thumbnail.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/remote_server_riverpod.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import 'package:vynody/utils/folder_helpers.dart';
import '../widgets/folder_header_nav_bar.dart';
import '../widgets/folder_content_slivers.dart';
import '../widgets/remote_server_slivers.dart';
import '../dialogs/add_edit_remote_server_dialog.dart';
import '../utils/selection_utils.dart';

class FolderRootView extends ConsumerStatefulWidget {
  const FolderRootView({
    super.key,
    required this.onOpenPlayback,
    required this.isSelectionMode,
    this.isSortMode = false,
    required this.selectedRootPaths,
    required this.onPickFolder,
    required this.onToggleRootSelection,
    required this.onToggleRootSelectionMode,
    required this.onToggleSortMode,
    required this.onDeleteSelectedRootFolders,
    required this.onNavigateTo,
    this.onLocateCurrentSong,
    required this.onShowFolderBottomSheet,
    required this.onShowFolderContextMenu,
  });

  final Future<void> Function()? onOpenPlayback;
  final bool isSelectionMode;
  final bool isSortMode;
  final Set<String> selectedRootPaths;
  final VoidCallback onPickFolder;
  final void Function(String) onToggleRootSelection;
  final VoidCallback onToggleRootSelectionMode;
  final VoidCallback onToggleSortMode;
  final Future<void> Function() onDeleteSelectedRootFolders;
  final void Function(MusicFolder) onNavigateTo;
  final VoidCallback? onLocateCurrentSong;
  final void Function(MusicFolder, {required bool isRoot}) onShowFolderBottomSheet;
  final void Function(MusicFolder, Offset, {required bool isRoot}) onShowFolderContextMenu;

  @override
  ConsumerState<FolderRootView> createState() => _FolderRootViewState();
}

class _FolderRootViewState extends ConsumerState<FolderRootView> {
  late final ScrollController _localScrollController;
  late final TextEditingController _searchController;
  bool _isSearching = false;
  bool _isSearchLoading = false;
  String _searchQuery = '';
  bool _showStatusBarOverlay = false;
  int? _lastRootAnchorIndex;

  List<MusicFile> _matchedSongs = [];
  List<MusicFolder> _matchedFolders = [];
  Timer? _searchDebounce;
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0.0);

  void _performSearch(String query) {
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _matchedSongs = [];
        _matchedFolders = [];
        _isSearchLoading = false;
      });
      return;
    }
    setState(() {
      _isSearchLoading = true;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      final songs = await ref.read(scannerServiceProvider).searchSongs(query);
      final folders =
          await ref.read(scannerServiceProvider).searchFolders(query);
      if (mounted) {
        setState(() {
          _matchedSongs = songs;
          _matchedFolders = folders;
          _isSearchLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    final targetOffset = ref.read(scannerServiceProvider).getFolderScrollOffset('root');
    _localScrollController = ScrollController(initialScrollOffset: targetOffset);
    _scrollProgress.value = (targetOffset / 160.0).clamp(0.0, 1.0);
    _localScrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _localScrollController.offset;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = 64.0 + statusBarHeight;

    ref.read(scannerServiceProvider).setFolderScrollOffset(
      'root',
      offset,
    );

    final progress = (offset / 160.0).clamp(0.0, 1.0);
    _scrollProgress.value = progress;

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
    _scrollProgress.dispose();
    super.dispose();
  }

  void _handleShowMenu(
    BuildContext menuContext,
    Offset position,
    MusicFile file,
  ) {
    final songsToAdd = <MusicFile>[file];
    showSongContextMenu(
      menuContext,
      position,
      song: file,
      songs: songsToAdd,
      mode: SongContextMenuMode.full,
      onAddToPlaylist: () => showAddSongsToPlaylistDialog(
        menuContext,
        ref.read(playlistServiceProvider),
        songsToAdd,
      ),
      onPlayNext: () => ref
          .read(audioServiceProvider)
          .enqueueNext(songsToAdd),
      onAddToQueue: () => ref
          .read(audioServiceProvider)
          .appendToQueue(songsToAdd),
    );
  }

  Future<void> _openRemoteServer(
    BuildContext context,
    RemoteServer server,
  ) async {
    final pwd = await ref
        .read(remoteServersProvider.notifier)
        .getPassword(server.id);
    if (!context.mounted) return;

    ref.read(activeRemoteSessionProvider.notifier).setSession(
      ActiveRemoteSession(
        server: server,
        password: pwd ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanner = ref.watch(scannerServiceProvider);
    final settings = ref.watch(settingsServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    final isRootSelectionMode =
        ref.watch(librarySelectionScopeProvider) ==
        LibrarySelectionScope.folderRoot;
    final rootFolders = ref.watch(
      scannerServiceProvider.select((scanner) => scanner.rootFolders),
    );
    final remoteServers =
        ref.watch(remoteServersProvider).asData?.value ?? [];
    final hasPermission = ref.watch(
      scannerServiceProvider.select((scanner) => scanner.hasPermission),
    );
    final audio = ref.read(audioServiceProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);

    final isLargeScreen = MediaQuery.of(context).size.width >= 1000;
    final selectionLabel = l10n.selectedFolders(widget.selectedRootPaths.length);
    final rootListBottomPadding = isRootSelectionMode ? 224.0 : 160.0;

    final systemFolder = MusicFolder(path: 'system', name: '');
    final systemSongCount = Platform.isAndroid
        ? scanner.getSongCountForFolder(systemFolder)
        : 0;
    final systemDurationMs = Platform.isAndroid
        ? scanner.getSongDurationForFolder(systemFolder)
        : 0;

    final totalSongsCount = rootFolders.fold<int>(
      systemSongCount,
      (sum, folder) => sum + scanner.getSongCountForFolder(folder),
    );
    final totalDurationMs = rootFolders.fold<int>(
      systemDurationMs,
      (sum, folder) => sum + scanner.getSongDurationForFolder(folder),
    );

    // We pass stub lists to satisfy LibrarySelectionPanel length checks.
    final selectedRootSongs = List.filled(widget.selectedRootPaths.length, MusicFile(path: '', name: ''));
    final allRootSongs = List.filled(rootFolders.length, MusicFile(path: '', name: ''));

    final representativeSong = () {
      if (Platform.isAndroid) {
        final systemRep = scanner.getRepresentativeSongForFolder(systemFolder);
        if (systemRep != null) return systemRep;
      }
      for (final folder in rootFolders) {
        final song = scanner.getRepresentativeSongForFolder(folder);
        if (song != null) return song;
      }
      return null;
    }();

    final matchedRootFolders = _searchQuery.isNotEmpty
        ? _matchedFolders
        : rootFolders;

    final matchedRemoteServers = _searchQuery.isNotEmpty
        ? remoteServers.where((server) {
            final q = _searchQuery.toLowerCase();
            return server.name.toLowerCase().contains(q) ||
                server.url.toLowerCase().contains(q);
          }).toList()
        : remoteServers;

    final matchedSongs = _searchQuery.isNotEmpty
        ? _matchedSongs
        : <MusicFile>[];

    final showSearchLoading = _searchQuery.isNotEmpty &&
        _isSearchLoading &&
        matchedRootFolders.isEmpty &&
        matchedSongs.isEmpty &&
        matchedRemoteServers.isEmpty;
    final noResults = _searchQuery.isNotEmpty &&
        matchedRootFolders.isEmpty &&
        matchedSongs.isEmpty &&
        matchedRemoteServers.isEmpty &&
        !_isSearchLoading;

    final double localFoldersBottomPadding =
        (matchedRemoteServers.isNotEmpty || matchedSongs.isNotEmpty)
            ? 16.0
            : rootListBottomPadding;
    final double remoteServersBottomPadding =
        matchedSongs.isNotEmpty ? 16.0 : rootListBottomPadding;

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final double headerHeight = 64.0 + (MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top : ((Platform.isMacOS || Platform.isWindows || Platform.isLinux) ? 24.0 : 0.0));

    final rootList = CustomScrollView(
      key: const PageStorageKey<String>('root_folders_scroll_view'),
      controller: _localScrollController,
      cacheExtent: 1000.0,
      slivers: [
        if (!isPortrait)
          SliverToBoxAdapter(
            child: SizedBox(height: headerHeight),
          ),
        SliverToBoxAdapter(
          child: FolderHeaderBanner(
            title: l10n.scanDirectory,
            subtitle: '',
            songsCount: totalSongsCount,
            totalDuration: Duration(milliseconds: totalDurationMs),
            coverImagePath: representativeSong?.thumbnailPath ?? (representativeSong != null ? scanner.metadataMap[representativeSong.path]?.thumbnailPath : null),
            topHeader: isPortrait ? SizedBox(height: headerHeight) : null,
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
                          HSLColor.fromAHSL(1.0, ('root'.hashCode.abs() % 360).toDouble(), 0.65, 0.45).toColor(),
                          HSLColor.fromAHSL(1.0, (('root'.hashCode.abs() % 360 + 40) % 360).toDouble(), 0.75, 0.35).toColor(),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.library_music_rounded, size: 40, color: Colors.white70),
                    ),
                  ),
            actionButtons: [
              FilledButton.icon(
                onPressed: widget.onPickFolder,
                icon: Icon(Icons.add_circle_outline, size: isLargeScreen ? 18 : 16),
                label: Text(l10n.addRootDirectory),
                style: FilledButton.styleFrom(
                  minimumSize: Size(0, isLargeScreen ? 38 : 32),
                  padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 16 : 12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  textStyle: TextStyle(
                    fontSize: isLargeScreen ? 13.0 : 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FolderPlayActionButtons(
                totalSongsCount: totalSongsCount,
                onPlayAll: () async {
                  final songs = await scanner.getAllRootSongs();
                  if (songs.isNotEmpty) {
                    await audio.playPlaylist(
                      songs,
                      source: PlaybackSource(
                        type: PlaybackSourceType.folder,
                        id: 'root',
                        name: l10n.scanDirectory,
                      ),
                    );
                  }
                },
                onShufflePlay: () async {
                  final songs = await scanner.getAllRootSongs();
                  if (songs.isNotEmpty) {
                    await audio.playPlaylist(
                      List.of(songs)..shuffle(),
                      source: PlaybackSource(
                        type: PlaybackSourceType.folder,
                        id: 'root',
                        name: l10n.scanDirectory,
                      ),
                    );
                  }
                },
              ),
            ],
            actionButtonsScrollable: true,
            isSearching: _isSearching,
            searchController: _searchController,
            searchQuery: _searchQuery,
            searchHintText: '${l10n.search}...',
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
                  _matchedFolders = [];
                  _isSearchLoading = false;
                }
              });
            },
            heroTag: 'folder-cover-root',
            isHeroModeEnabled: true,
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
            folders: matchedRootFolders,
            viewMode: settings.folderViewMode,
            scanner: scanner,
            isRoot: true,
            isSelectionMode: isRootSelectionMode,
            isSortMode: widget.isSortMode,
            selectedFolderPaths: widget.selectedRootPaths,
            showSystemMedia: Platform.isAndroid && _searchQuery.isEmpty,
            hasPermission: hasPermission,
            systemMediaTitle: l10n.systemMediaLibrary,
            systemMediaSubtitle: l10n.needPermissionToScan,
            onNavigateTo: widget.onNavigateTo,
            onFolderTap: (folder, index) {
              SelectionActionHelper.handleItemTap(
                index: index,
                itemKey: folder.path,
                items: matchedRootFolders,
                keySelector: (f) => f.path,
                isSelectionMode: isRootSelectionMode,
                selectedKeys: widget.selectedRootPaths,
                lastAnchorIndex: _lastRootAnchorIndex,
                onUpdateAnchor: (a) => setState(() => _lastRootAnchorIndex = a),
                onSetSelection: (keys) {
                  for (final k in keys) {
                    if (!widget.selectedRootPaths.contains(k)) {
                      widget.onToggleRootSelection(k);
                    }
                  }
                },
                onToggleSelection: (key) => widget.onToggleRootSelection(key),
                onEnterSelectionMode: () => widget.onToggleRootSelectionMode(),
                onNormalTap: () => widget.onNavigateTo(folder),
              );
            },
            onFolderLongPress: (folder, index) {
              _lastRootAnchorIndex = index;
              if (!isRootSelectionMode) {
                widget.onToggleRootSelectionMode();
              }
              widget.onToggleRootSelection(folder.path);
            },
            onToggleFolderSelection: widget.onToggleRootSelection,
            onToggleSelectionMode: widget.onToggleRootSelectionMode,
            onShowFolderContextMenu: widget.onShowFolderContextMenu,
            bottomPadding: localFoldersBottomPadding,
          ),
          if (matchedRemoteServers.isNotEmpty) ...[
            RemoteServersSectionHeaderSliver(
              title: l10n.tabCloudServers,
              count: matchedRemoteServers.length,
              onAddServer: () => AddEditRemoteServerDialog.show(context),
            ),
            RemoteServersSliver(
              servers: matchedRemoteServers,
              viewMode: settings.folderViewMode,
              isSortMode: widget.isSortMode,
              onOpenServer: (server) => _openRemoteServer(context, server),
              bottomPadding: remoteServersBottomPadding,
            ),
          ],
          if (matchedRootFolders.isNotEmpty && matchedSongs.isNotEmpty)
            FolderSectionHeaderSliver(
              title: l10n.songsCountFormat(matchedSongs.length),
            ),
          FolderSongsSliver(
            songs: matchedSongs,
            viewMode: settings.folderViewMode,
            currentSongPath: currentMusic?.path,
            isPlaying: ref.watch(audioIsPlayingProvider),
            onSongTap: (file, fileIndex) async {
              unawaited(() async {
                try {
                  await audio.playPlaylist(
                    matchedSongs,
                    initialIndex: fileIndex,
                    source: PlaybackSource(
                      type: PlaybackSourceType.folder,
                      id: 'search_results',
                      name: l10n.search,
                    ),
                  );
                } catch (e, st) {
                  debugPrint(
                    'FolderRootView: failed to start matched song playback: $e',
                  );
                  debugPrintStack(stackTrace: st);
                }
              }());

              if (settings.openPlaybackOnDirectorySongTap) {
                await widget.onOpenPlayback?.call();
              }
            },
            onSongSecondaryTapDown: (file, details) {
              _handleShowMenu(context, details.globalPosition, file);
            },
            onSongMorePressed: (file, buttonContext) {
              final renderObject = buttonContext.findRenderObject();
              final renderBox =
                  renderObject is RenderBox ? renderObject : null;
              if (renderBox == null) return;
              final Offset offset = renderBox.localToGlobal(Offset.zero);
              _handleShowMenu(buttonContext, offset, file);
            },
          ),
        ],
      ],
    );

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: folderPageMaxWidth),
                child: rootList,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: folderPageMaxWidth),
                  child: _buildRootTopHeader(context, isOverlay: true),
                ),
              ),
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
                child: isRootSelectionMode
                    ? LibrarySelectionPanel(
                        key: const ValueKey('root-selection-panel'),
                        selectedSongs: selectedRootSongs,
                        allSongs: allRootSongs,
                        title: selectionLabel,
                        hideSongProperties: true,
                        onToggleSelectAll: () {
                          final isAllSelected =
                              widget.selectedRootPaths.length == rootFolders.length;
                          if (isAllSelected) {
                            for (final f in rootFolders) {
                              widget.onToggleRootSelection(f.path);
                            }
                          } else {
                            for (final f in rootFolders) {
                              if (!widget.selectedRootPaths.contains(f.path)) {
                                widget.onToggleRootSelection(f.path);
                              }
                            }
                          }
                        },
                        onCancel: widget.onToggleRootSelectionMode,
                        onDelete: widget.selectedRootPaths.isEmpty
                            ? null
                            : widget.onDeleteSelectedRootFolders,
                        deleteLabel: l10n.delete,
                        onOpenLocation: widget.selectedRootPaths.length == 1
                            ? () => openFolderLocation(widget.selectedRootPaths.first)
                            : null,
                        openLocationLabel: l10n.openFolderLocation,
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('root-selection-panel-hidden'),
                      ),
              ),
            ),
            if (widget.isSortMode && !isRootSelectionMode)
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(24),
                    color: Theme.of(context).colorScheme.primary,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: widget.onToggleSortMode,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.localeName == 'zh' ? '完成排序' : 'Done',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRootTopHeader(BuildContext context, {bool isOverlay = true}) {
    return Hero(
      tag: 'folder-header-nav-bar',
      child: Material(
        type: MaterialType.transparency,
        child: FolderHeaderNavBar(
          isOverlay: isOverlay,
          scrollProgress: _scrollProgress,
          onLocateCurrentSong: widget.onLocateCurrentSong,
          onSortPressed: widget.onToggleSortMode,
          isSortActive: widget.isSortMode,
        ),
      ),
    );
  }
}
