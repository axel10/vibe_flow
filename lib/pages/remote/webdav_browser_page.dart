import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as p;
import '../../models/music_file.dart';
import '../../player/audio/audio_riverpod.dart';
import '../../player/audio/playback_source.dart';
import '../../player/remote/remote_server_models.dart';
import '../../player/remote/remote_server_riverpod.dart';
import '../../player/remote/clients/webdav_client.dart';
import '../../player/remote/proxy/remote_media_resolver.dart';
import '../../l10n/app_localizations.dart';
import '../../player/remote/services/remote_download_service.dart';
import '../../player/remote/services/webdav_metadata_helper.dart';
import '../../player/library/playlist_service.dart';
import '../../player/metadata/metadata_database.dart';
import '../../player/settings/settings_service.dart';
import '../../utils/app_snack_bar.dart';
import '../../utils/folder_helpers.dart';
import '../../utils/remote_context_menu_utils.dart';
import '../../utils/song_context_menu_utils.dart';
import '../../widgets/library_selection_panel.dart';
import '../../widgets/library_selection_scope.dart';
import '../../widgets/folder_header_banner.dart';
import '../../widgets/folder_layout_utils.dart';
import '../../widgets/folder_content_slivers.dart';
import '../../widgets/mini_player_wrapper.dart';
import '../../widgets/song_thumbnail.dart';
import 'remote_download_manager_page.dart';
import 'widgets/webdav_content_slivers.dart';


class WebDavBrowserPage extends ConsumerStatefulWidget {
  final RemoteServer server;
  final String password;
  final String? initialPath;
  final String? rootPath;
  final bool wrapWithMiniPlayer;

  const WebDavBrowserPage({
    super.key,
    required this.server,
    required this.password,
    this.initialPath,
    this.rootPath,
    this.wrapWithMiniPlayer = false,
  });

  @override
  ConsumerState<WebDavBrowserPage> createState() => _WebDavBrowserPageState();
}

class _WebDavBrowserPageState extends ConsumerState<WebDavBrowserPage> {
  late final WebDavClient _client;
  late String _rootPath;
  late String _currentPath;
  bool _isLoading = false;
  String? _error;
  List<WebDavFile> _items = [];
  final Map<String, SongMetadata> _metadataMap = {};
  int _loadEpoch = 0;

  // Selection states
  bool _isSelectionMode = false;
  final Set<String> _selectedSongPaths = {};
  final Set<String> _selectedFolderPaths = {};

  // Search & Scroll states
  late final LibrarySelectionScopeController _selectionScopeNotifier;
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _breadcrumbsScrollController = ScrollController();
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0.0);
  bool _isCoverVisible = true;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectionScopeNotifier =
        ref.read(librarySelectionScopeProvider.notifier);
    _searchController = TextEditingController();
    _client = WebDavClient(
      server: widget.server,
      password: widget.password,
    );

    final session = ref.read(activeRemoteSessionProvider);
    final isSameServer =
        session != null && session.server.id == widget.server.id;

    if (isSameServer && session.webDavMetadataCache.isNotEmpty) {
      _metadataMap.addAll(session.webDavMetadataCache);
    }

    _rootPath = widget.rootPath ??
        (isSameServer && session.rootPath != null ? session.rootPath! : null) ??
        (widget.server.customPath?.trim().isNotEmpty == true
            ? widget.server.customPath!
            : '/');

    _currentPath = widget.initialPath ??
        (isSameServer && session.initialPath != null
            ? session.initialPath!
            : null) ??
        _rootPath;

    if (isSameServer &&
        session.webDavDirectoryCache.containsKey(_currentPath)) {
      _items = session.webDavDirectoryCache[_currentPath]!;
      _isLoading = false;
      _startMetadataExtraction(_items, _loadEpoch);
    } else {
      _loadDirectory(_currentPath);
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      final offset = notification.metrics.pixels;
      final isVisible = offset < 160.0;
      final progress = (offset / 160.0).clamp(0.0, 1.0);
      _scrollProgress.value = progress;
      if (isVisible != _isCoverVisible) {
        setState(() {
          _isCoverVisible = isVisible;
        });
      }
    }
    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _breadcrumbsScrollController.dispose();
    _scrollProgress.dispose();
    Future.microtask(() {
      _selectionScopeNotifier.clear();
    });
    super.dispose();
  }

  bool get _isAtRoot {
    if (_currentPath.isEmpty || _currentPath == '/' || _currentPath == _rootPath) {
      return true;
    }
    final cleanCurrent = _currentPath.endsWith('/') && _currentPath.length > 1
        ? _currentPath.substring(0, _currentPath.length - 1)
        : _currentPath;
    final cleanRoot = _rootPath.endsWith('/') && _rootPath.length > 1
        ? _rootPath.substring(0, _rootPath.length - 1)
        : _rootPath;
    return cleanCurrent == cleanRoot;
  }

  Future<void> _loadDirectory(String path, {bool forceRefresh = false}) async {
    _clearAllSelection();
    final session = ref.read(activeRemoteSessionProvider);
    final isSameServer =
        session != null && session.server.id == widget.server.id;

    _loadEpoch++;
    final currentEpoch = _loadEpoch;

    // Reset search on directory change
    if (_isSearching || _searchQuery.isNotEmpty) {
      setState(() {
        _isSearching = false;
        _searchQuery = '';
        _searchController.clear();
      });
    }

    if (!forceRefresh &&
        isSameServer &&
        session.webDavDirectoryCache.containsKey(path)) {
      setState(() {
        _currentPath = path;
        _items = session.webDavDirectoryCache[path]!;
        _isLoading = false;
        _error = null;
      });
      _scrollToTop();
      _startMetadataExtraction(_items, currentEpoch);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(activeRemoteSessionProvider.notifier).updateWebDavState(
              currentPath: path,
              rootPath: _rootPath,
            );
        if (_breadcrumbsScrollController.hasClients) {
          _breadcrumbsScrollController.animateTo(
            _breadcrumbsScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _currentPath = path;
    });
    _scrollToTop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_breadcrumbsScrollController.hasClients) {
        _breadcrumbsScrollController.animateTo(
          _breadcrumbsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final list = await _client.listFiles(path);
      // Sort: folders first, then files alphabetically
      list.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      var effectivePath = path;
      if (path == '/' && list.isNotEmpty && list.first.path.startsWith('/dav')) {
        effectivePath = '/dav';
        if (_rootPath == '/') {
          _rootPath = '/dav';
        }
      }

      if (mounted && _loadEpoch == currentEpoch) {
        setState(() {
          _items = list;
          _currentPath = effectivePath;
          _isLoading = false;
        });
        _startMetadataExtraction(list, currentEpoch);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(activeRemoteSessionProvider.notifier).updateWebDavState(
                currentPath: effectivePath,
                rootPath: _rootPath,
                items: list,
              );
        });
      }
    } catch (e) {
      if (mounted && _loadEpoch == currentEpoch) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _scrollProgress.value = 0.0;
    _isCoverVisible = true;
  }

  Future<void> _startMetadataExtraction(List<WebDavFile> files, int epoch) async {
    final audioFiles = files.where((f) => f.isAudio).toList();
    if (audioFiles.isEmpty) return;

    // 1. Check local SQLite metadata database first for instant cache hits
    final db = MetadataDatabase();
    final Map<String, SongMetadata> dbHits = {};
    for (final file in audioFiles) {
      final virtualUri = RemoteMediaResolver.buildWebDavUri(widget.server.id, file.path);
      if (!_metadataMap.containsKey(virtualUri)) {
        final cached = await db.getSongMetadata(virtualUri);
        if (cached != null) {
          dbHits[virtualUri] = cached;
          _metadataMap[virtualUri] = cached;
        }
      }
    }

    if (dbHits.isNotEmpty && mounted && _loadEpoch == epoch) {
      setState(() {});
      for (final meta in dbHits.values) {
        ref.read(scannerServiceProvider).updateMetadataForPath(meta);
      }
      ref.read(activeRemoteSessionProvider.notifier).updateWebDavState(
            currentPath: _currentPath,
            rootPath: _rootPath,
            metadataMap: dbHits,
          );
    }

    // 2. Identify unparsed files that need HTTP Range tag extraction
    final unparsedFiles = audioFiles.where((f) {
      final virtualUri = RemoteMediaResolver.buildWebDavUri(widget.server.id, f.path);
      return !_metadataMap.containsKey(virtualUri);
    }).toList();

    if (unparsedFiles.isEmpty) return;

    // 3. Concurrently extract metadata with pool of 3
    final Map<String, SongMetadata> newMetas = {};
    await WebDavMetadataHelper.processBatchMetadata(
      files: unparsedFiles,
      server: widget.server,
      password: widget.password,
      concurrency: 3,
      isCancelled: () => !mounted || _loadEpoch != epoch,
      onMetadataLoaded: (virtualUri, meta) {
        if (!mounted || _loadEpoch != epoch) return;
        _metadataMap[virtualUri] = meta;
        newMetas[virtualUri] = meta;
        ref.read(scannerServiceProvider).updateMetadataForPath(meta);
        setState(() {});
      },
    );

    if (newMetas.isNotEmpty && mounted && _loadEpoch == epoch) {
      ref.read(activeRemoteSessionProvider.notifier).updateWebDavState(
            currentPath: _currentPath,
            rootPath: _rootPath,
            metadataMap: newMetas,
          );
    }
  }

  List<MusicFile> _getAudioFiles({List<WebDavFile>? sourceList}) {
    final scanner = ref.read(scannerServiceProvider);
    final list = sourceList ?? _items;
    return list
        .where((item) => item.isAudio)
        .map((item) {
          final virtualUri = RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path);
          final meta = _metadataMap[virtualUri] ?? scanner.metadataMap[virtualUri];
          return RemoteMediaResolver.buildMusicFileFromWebDav(
            item,
            widget.server,
            metadata: meta,
          );
        })
        .toList();
  }

  Future<void> _playFolder({bool shuffle = false}) async {
    final audioFiles = _getAudioFiles();
    if (audioFiles.isEmpty) {
      showToast('No audio files in this folder');
      return;
    }

    final audioService = ref.read(audioServiceProvider);
    final playlist = List<MusicFile>.from(audioFiles);
    if (shuffle) {
      playlist.shuffle();
    }
    final folderName = _isAtRoot ? widget.server.name : p.basename(_currentPath);
    await audioService.playPlaylist(
      playlist,
      source: PlaybackSource(
        type: PlaybackSourceType.folder,
        id: 'webdav-${widget.server.id}-$_currentPath',
        name: folderName,
      ),
    );
    showToast('Playing ${playlist.length} songs');
  }

  Future<void> _downloadAllAudio() async {
    final l10n = AppLocalizations.of(context)!;
    final audioItems =
        _items.where((i) => !i.isDirectory && i.isAudio).toList();
    if (audioItems.isEmpty) {
      showToast(l10n.noActiveDownloads);
      return;
    }

    final notifier = ref.read(remoteDownloadTasksProvider.notifier);
    await notifier.enqueueWebDavFiles(
      server: widget.server,
      password: widget.password,
      files: audioItems,
    );

    if (mounted) {
      AppSnackBar.show(
        context,
        ref,
        SnackBar(
          content: Text(l10n.batchAddedToDownloadQueue(audioItems.length)),
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

  Future<void> _downloadSingleAudio(WebDavFile item) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(remoteDownloadTasksProvider.notifier);
    await notifier.enqueueWebDavFile(
      server: widget.server,
      password: widget.password,
      file: item,
    );

    if (mounted) {
      AppSnackBar.show(
        context,
        ref,
        SnackBar(
          content: Text(l10n.addedToDownloadQueue),
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

  void _clearAllSelection() {
    final shouldClearSelection = _isSelectionMode ||
        _selectedSongPaths.isNotEmpty ||
        _selectedFolderPaths.isNotEmpty;
    final currentScope = ref.read(librarySelectionScopeProvider);
    final isWebDavScope = currentScope == LibrarySelectionScope.webdav ||
        currentScope == LibrarySelectionScope.folder;
    if (!shouldClearSelection && !isWebDavScope) return;

    if (isWebDavScope) {
      _selectionScopeNotifier.clear();
    }
    if (shouldClearSelection) {
      if (mounted) {
        setState(() {
          _isSelectionMode = false;
          _selectedSongPaths.clear();
          _selectedFolderPaths.clear();
        });
      } else {
        _isSelectionMode = false;
        _selectedSongPaths.clear();
        _selectedFolderPaths.clear();
      }
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedSongPaths.clear();
        _selectedFolderPaths.clear();
        _selectionScopeNotifier.clear();
      } else {
        _selectionScopeNotifier.setScope(LibrarySelectionScope.webdav);
      }
    });
  }

  void _toggleSongSelection(String virtualUri) {
    setState(() {
      if (_selectedSongPaths.contains(virtualUri)) {
        _selectedSongPaths.remove(virtualUri);
      } else {
        _selectedSongPaths.add(virtualUri);
      }
      if (_selectedSongPaths.isEmpty && _selectedFolderPaths.isEmpty) {
        _isSelectionMode = false;
        _selectionScopeNotifier.clear();
      } else {
        _selectionScopeNotifier.setScope(LibrarySelectionScope.webdav);
      }
    });
  }

  void _toggleFolderSelection(String folderPath) {
    setState(() {
      if (_selectedFolderPaths.contains(folderPath)) {
        _selectedFolderPaths.remove(folderPath);
      } else {
        _selectedFolderPaths.add(folderPath);
      }
      if (_selectedSongPaths.isEmpty && _selectedFolderPaths.isEmpty) {
        _isSelectionMode = false;
        _selectionScopeNotifier.clear();
      } else {
        _selectionScopeNotifier.setScope(LibrarySelectionScope.webdav);
      }
    });
  }

  void _selectAllVisible(List<WebDavFile> displayedItems) {
    _selectionScopeNotifier.setScope(LibrarySelectionScope.webdav);
    setState(() {
      _isSelectionMode = true;
      for (final item in displayedItems) {
        if (item.isDirectory) {
          _selectedFolderPaths.add(item.path);
        } else if (item.isAudio) {
          final uri =
              RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path);
          _selectedSongPaths.add(uri);
        }
      }
    });
  }

  List<MusicFile> _getSelectedSongs({List<WebDavFile>? sourceList}) {
    final allAudio = _getAudioFiles(sourceList: sourceList);
    final songs = <MusicFile>[];
    for (final song in allAudio) {
      if (_selectedSongPaths.contains(song.path)) {
        songs.add(song);
      }
    }
    final seen = <String>{};
    return songs.where((s) => seen.add(s.path)).toList(growable: false);
  }

  Future<List<MusicFile>> _resolveAllSelectedSongs({
    List<WebDavFile>? sourceList,
  }) async {
    final songs = <MusicFile>[];
    songs.addAll(_getSelectedSongs(sourceList: sourceList));

    if (_selectedFolderPaths.isNotEmpty) {
      showToast('Loading selected folders...');
      for (final folderPath in _selectedFolderPaths) {
        final folderAudios = await fetchWebDavFolderAudioFiles(
          _client,
          widget.server,
          folderPath,
        );
        songs.addAll(folderAudios);
      }
    }

    final seen = <String>{};
    return songs.where((s) => seen.add(s.path)).toList(growable: false);
  }

  void _handleSongTap(
    WebDavFile file,
    int index,
    List<MusicFile> allAudio,
  ) async {
    final uri = RemoteMediaResolver.buildWebDavUri(widget.server.id, file.path);
    if (_isSelectionMode) {
      _toggleSongSelection(uri);
    } else if (file.isAudio) {
      final target = RemoteMediaResolver.buildMusicFileFromWebDav(
        file,
        widget.server,
        metadata: _metadataMap[uri] ??
            ref.read(scannerServiceProvider).metadataMap[uri],
      );
      final initialIndex = allAudio.indexWhere((s) => s.path == target.path);
      final audioService = ref.read(audioServiceProvider);
      await audioService.playPlaylist(
        allAudio.isNotEmpty ? allAudio : [target],
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
        source: PlaybackSource(
          type: PlaybackSourceType.folder,
          id: 'webdav-${widget.server.id}-$_currentPath',
          name: _isAtRoot ? widget.server.name : p.basename(_currentPath),
        ),
      );
    }
  }

  void _handleSongLongPress(WebDavFile file) {
    final uri = RemoteMediaResolver.buildWebDavUri(widget.server.id, file.path);
    if (!_isSelectionMode) {
      _toggleSelectionMode();
      _toggleSongSelection(uri);
    } else {
      _toggleSongSelection(uri);
    }
  }

  void _handleSongContextMenu(
    WebDavFile file,
    Offset globalPosition,
    List<MusicFile> allAudio,
    List<WebDavFile> displayedItems,
  ) {
    final uri = RemoteMediaResolver.buildWebDavUri(widget.server.id, file.path);
    final target = RemoteMediaResolver.buildMusicFileFromWebDav(
      file,
      widget.server,
      metadata: _metadataMap[uri] ??
          ref.read(scannerServiceProvider).metadataMap[uri],
    );
    final selectedSongs = _getSelectedSongs(sourceList: displayedItems);
    final songsToAdd =
        (_selectedSongPaths.isNotEmpty || _selectedFolderPaths.isNotEmpty) &&
                selectedSongs.isNotEmpty
            ? selectedSongs
            : [target];

    showSongContextMenu(
      context,
      globalPosition,
      song: target,
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
      onDownload: () {
        if (songsToAdd.length > 1) {
          final notifier = ref.read(remoteDownloadTasksProvider.notifier);
          final webDavFiles = <WebDavFile>[];
          for (final song in songsToAdd) {
            final uriInfo = RemoteMediaResolver.parseUri(song.path);
            final remotePath = (uriInfo != null &&
                    uriInfo.type == RemoteServerType.webdav)
                ? uriInfo.trackIdOrPath
                : null;
            if (remotePath != null) {
              webDavFiles.add(WebDavFile(
                path: remotePath,
                name: p.basename(remotePath),
                isDirectory: false,
                contentLength: 0,
              ));
            }
          }
          if (webDavFiles.isNotEmpty && mounted) {
            notifier.enqueueWebDavFiles(
              server: widget.server,
              password: widget.password,
              files: webDavFiles,
            );
            AppSnackBar.show(
              context,
              ref,
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!
                      .batchAddedToDownloadQueue(webDavFiles.length),
                ),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.viewDownloadProgress,
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
        } else {
          _downloadSingleAudio(file);
        }
      },
    );
  }

  void _handleShowFolderBottomSheet(WebDavFile folder) {
    showWebDavFolderBottomSheet(
      context: context,
      ref: ref,
      server: widget.server,
      password: widget.password,
      folder: folder,
      onOpen: () => _openFolder(folder),
      onMultiSelect: (folderPath) {
        if (!_isSelectionMode) _toggleSelectionMode();
        _toggleFolderSelection(folderPath);
      },
    );
  }

  void _openFolder(WebDavFile folder) {
    _clearAllSelection();
    ref.read(activeRemoteSessionProvider.notifier).pushWebDavPath(folder.path);
  }

  void _handleGoBack() {
    if (_isSelectionMode) {
      _clearAllSelection();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _navigateToBreadcrumb(int index) {
    _clearAllSelection();
    if (index < 0) {
      ref
          .read(activeRemoteSessionProvider.notifier)
          .setWebDavPathStack(const []);
      return;
    }
    final targetStack = <String>[];
    for (int i = 0; i <= index; i++) {
      targetStack.add(_buildSegmentPath(i));
    }
    ref
        .read(activeRemoteSessionProvider.notifier)
        .setWebDavPathStack(targetStack);
  }

  List<String> get _pathSegments {
    if (_isAtRoot) return [];
    var relative = _currentPath;
    if (_rootPath != '/' && relative.startsWith(_rootPath)) {
      relative = relative.substring(_rootPath.length);
    }
    final segments = relative
        .split('/')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return segments;
  }

  String _buildSegmentPath(int index) {
    final segments = _pathSegments;
    final sub = segments.sublist(0, index + 1).join('/');
    if (_rootPath == '/' || _rootPath.isEmpty) {
      return '/$sub';
    }
    final base = _rootPath.endsWith('/')
        ? _rootPath.substring(0, _rootPath.length - 1)
        : _rootPath;
    return '$base/$sub';
  }

  void _locateCurrentSong() {
    final currentMusic = ref.read(audioCurrentMusicProvider);
    if (currentMusic == null) return;

    final lowercaseQuery = _searchQuery.toLowerCase();
    final List<WebDavFile> displayedItems;
    if (_searchQuery.isEmpty) {
      displayedItems = _items;
    } else {
      displayedItems = _items.where((item) {
        if (item.name.toLowerCase().contains(lowercaseQuery)) return true;
        final virtualUri =
            RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path);
        final meta = _metadataMap[virtualUri] ??
            ref.read(scannerServiceProvider).metadataMap[virtualUri];
        if (meta != null) {
          if (meta.title.toLowerCase().contains(lowercaseQuery)) return true;
          if (meta.artist.toLowerCase().contains(lowercaseQuery)) return true;
          if (meta.album.toLowerCase().contains(lowercaseQuery)) return true;
        }
        return false;
      }).toList();
    }

    final matchedFolders = displayedItems.where((i) => i.isDirectory).toList();
    final matchedFiles = displayedItems.where((i) => !i.isDirectory).toList();

    final fileIndex = matchedFiles.indexWhere((f) {
      final uri = RemoteMediaResolver.buildWebDavUri(widget.server.id, f.path);
      return uri == currentMusic.path;
    });

    if (fileIndex == -1) {
      showToast(AppLocalizations.of(context)!.songNotInScannedFolders);
      return;
    }

    final settings = ref.read(settingsServiceProvider);
    final viewMode = settings.folderViewMode;
    final isFolderGrid =
        viewMode == FolderViewMode.hybrid || viewMode == FolderViewMode.grid;
    final isSongGrid = viewMode == FolderViewMode.grid;

    final screenWidth = MediaQuery.of(context).size.width;
    final double crossAxisExtent = screenWidth - 32;
    final int crossAxisCount = getFolderGridCrossAxisCount(crossAxisExtent);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final textScale = MediaQuery.textScalerOf(context).scale(10) / 10;
    final clampedScale = textScale.clamp(1.0, 1.3);
    final double textHeight = (isPortrait ? 72.0 : 84.0) * clampedScale;
    final double cardWidth =
        (crossAxisExtent - (crossAxisCount - 1) * 16) / crossAxisCount;
    final double cardHeight = cardWidth + textHeight;

    double fileOffset = 48.0 + 190.0;
    if (isFolderGrid) {
      final rows = (matchedFolders.length / crossAxisCount).ceil();
      fileOffset += rows * (cardHeight + 16);
    } else {
      fileOffset += matchedFolders.length * 80.0;
    }

    if (isSongGrid) {
      final songRows = (fileIndex / crossAxisCount).floor();
      fileOffset += songRows * (cardHeight + 16);
    } else {
      fileOffset += fileIndex * 80.0;
    }

    if (_scrollController.hasClients) {
      final double viewportHeight =
          _scrollController.position.viewportDimension;
      double targetOffset = fileOffset -
          (viewportHeight / 2) +
          (isSongGrid ? cardHeight / 2 : 40.0);
      final maxScroll = _scrollController.position.maxScrollExtent;
      targetOffset = targetOffset.clamp(0.0, maxScroll);
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsServiceProvider);
    final viewMode = settings.folderViewMode;
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isAudioPlaying = ref.watch(audioIsPlayingProvider);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final double headerHeight = 64.0 +
        (MediaQuery.of(context).padding.top > 0
            ? MediaQuery.of(context).padding.top
            : ((Platform.isMacOS || Platform.isWindows || Platform.isLinux)
                ? 24.0
                : 0.0));
    final bottomOffset = MiniPlayerUiTuning.getListBottomPadding(
      context,
      hasPlayingMusic: currentMusic != null,
    );

    // Current directory audio stats
    final audioItems = _items.where((i) => i.isAudio).toList();
    final audioCount = audioItems.length;
    int totalDurationMs = 0;
    for (final item in audioItems) {
      final virtualUri =
          RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path);
      final meta = _metadataMap[virtualUri] ??
          ref.watch(
            scannerServiceProvider.select((s) => s.metadataMap[virtualUri]),
          );
      if (meta?.duration != null) {
        totalDurationMs += meta!.duration!;
      }
    }

    // Banner cover finding logic:
    // Only search in current directory audio files for an existing thumbnail file. No deep recursive search.
    String? bannerCoverThumbnailPath;
    String? bannerCoverVirtualUri;
    for (final item in audioItems) {
      final virtualUri =
          RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path);
      final meta = _metadataMap[virtualUri] ??
          ref.watch(
            scannerServiceProvider.select((s) => s.metadataMap[virtualUri]),
          );
      if (meta?.thumbnailPath != null &&
          File(meta!.thumbnailPath!).existsSync()) {
        bannerCoverThumbnailPath = meta.thumbnailPath;
        bannerCoverVirtualUri = virtualUri;
        break;
      }
    }

    // Current folder display name & subtitle
    final folderDisplayName =
        _isAtRoot ? widget.server.name : p.basename(_currentPath);
    final folderDisplaySubtitle = _currentPath;

    // Search filtering within current directory
    final lowercaseQuery = _searchQuery.toLowerCase();
    final List<WebDavFile> displayedItems;
    if (_searchQuery.isEmpty) {
      displayedItems = _items;
    } else {
      displayedItems = _items.where((item) {
        if (item.name.toLowerCase().contains(lowercaseQuery)) return true;
        final virtualUri =
            RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path);
        final meta = _metadataMap[virtualUri] ??
            ref.read(scannerServiceProvider).metadataMap[virtualUri];
        if (meta != null) {
          if (meta.title.toLowerCase().contains(lowercaseQuery)) return true;
          if (meta.artist.toLowerCase().contains(lowercaseQuery)) return true;
          if (meta.album.toLowerCase().contains(lowercaseQuery)) return true;
        }
        return false;
      }).toList();
    }

    final matchedFolders = displayedItems.where((i) => i.isDirectory).toList();
    final matchedFiles = displayedItems.where((i) => !i.isDirectory).toList();
    final noSearchResults =
        _searchQuery.isNotEmpty && displayedItems.isEmpty && !_isLoading;

    // Build Banner cover widget
    final int hash = _currentPath.hashCode;
    final double hue = (hash.abs() % 360).toDouble();
    final Color startColor = HSLColor.fromAHSL(1.0, hue, 0.65, 0.45).toColor();
    final Color endColor =
        HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.75, 0.35).toColor();

    final Widget bannerCoverWidget = bannerCoverThumbnailPath != null
        ? SongThumbnail(
            path: bannerCoverVirtualUri!,
            thumbnailPath: bannerCoverThumbnailPath,
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
                colors: [startColor, endColor],
              ),
            ),
            child: const Center(
              child: Icon(Icons.cloud_queue_rounded,
                  size: 42, color: Colors.white70),
            ),
          );

    Widget mainContent;
    if (_isLoading) {
      mainContent = CustomScrollView(
        key: PageStorageKey<String>(
            'webdav-browser-${widget.server.id}-$_currentPath'),
        controller: _scrollController,
        cacheExtent: 1000.0,
        slivers: [
          if (!isPortrait)
            SliverToBoxAdapter(
              child: SizedBox(height: headerHeight),
            ),
          SliverToBoxAdapter(
            child: _buildBanner(
              theme: theme,
              l10n: l10n,
              title: folderDisplayName,
              subtitle: folderDisplaySubtitle,
              audioCount: audioCount,
              totalDurationMs: totalDurationMs,
              bannerCoverThumbnailPath: bannerCoverThumbnailPath,
              bannerCoverWidget: bannerCoverWidget,
              topHeader: isPortrait ? SizedBox(height: headerHeight) : null,
            ),
          ),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ),
        ],
      );
    } else if (_error != null) {
      mainContent = CustomScrollView(
        key: PageStorageKey<String>(
            'webdav-browser-${widget.server.id}-$_currentPath'),
        controller: _scrollController,
        cacheExtent: 1000.0,
        slivers: [
          if (!isPortrait)
            SliverToBoxAdapter(
              child: SizedBox(height: headerHeight),
            ),
          SliverToBoxAdapter(
            child: _buildBanner(
              theme: theme,
              l10n: l10n,
              title: folderDisplayName,
              subtitle: folderDisplaySubtitle,
              audioCount: audioCount,
              totalDurationMs: totalDurationMs,
              bannerCoverThumbnailPath: bannerCoverThumbnailPath,
              bannerCoverWidget: bannerCoverWidget,
              topHeader: isPortrait ? SizedBox(height: headerHeight) : null,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error: $_error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          _loadDirectory(_currentPath, forceRefresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_items.isEmpty) {
      mainContent = RefreshIndicator(
        onRefresh: () => _loadDirectory(_currentPath, forceRefresh: true),
        child: CustomScrollView(
          key: PageStorageKey<String>(
              'webdav-browser-${widget.server.id}-$_currentPath'),
          controller: _scrollController,
          cacheExtent: 1000.0,
          slivers: [
            if (!isPortrait)
              SliverToBoxAdapter(
                child: SizedBox(height: headerHeight),
              ),
            SliverToBoxAdapter(
              child: _buildBanner(
                theme: theme,
                l10n: l10n,
                title: folderDisplayName,
                subtitle: folderDisplaySubtitle,
                audioCount: audioCount,
                totalDurationMs: totalDurationMs,
                bannerCoverThumbnailPath: bannerCoverThumbnailPath,
                bannerCoverWidget: bannerCoverWidget,
                topHeader: isPortrait ? SizedBox(height: headerHeight) : null,
              ),
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Folder is empty')),
            ),
          ],
        ),
      );
    } else {
      mainContent = RefreshIndicator(
        onRefresh: () => _loadDirectory(_currentPath, forceRefresh: true),
        child: CustomScrollView(
          key: PageStorageKey<String>(
              'webdav-browser-${widget.server.id}-$_currentPath'),
          controller: _scrollController,
          cacheExtent: 1000.0,
          slivers: [
            if (!isPortrait)
              SliverToBoxAdapter(
                child: SizedBox(height: headerHeight),
              ),
            SliverToBoxAdapter(
              child: _buildBanner(
                theme: theme,
                l10n: l10n,
                title: folderDisplayName,
                subtitle: folderDisplaySubtitle,
                audioCount: audioCount,
                totalDurationMs: totalDurationMs,
                bannerCoverThumbnailPath: bannerCoverThumbnailPath,
                bannerCoverWidget: bannerCoverWidget,
                topHeader: isPortrait ? SizedBox(height: headerHeight) : null,
              ),
            ),
            if (noSearchResults)
              FolderEmptySearchResultsSliver(
                message: l10n.noMatchingFoldersOrSongs,
                isSearching: false,
              )
            else ...[
              // 1. Subfolders Sliver (Grid or List according to viewMode)
              if (matchedFolders.isNotEmpty)
                WebDavSubfoldersSliver(
                  folders: matchedFolders,
                  viewMode: viewMode,
                  server: widget.server,
                  password: widget.password,
                  isSelectionMode: _isSelectionMode,
                  selectedFolderPaths: _selectedFolderPaths,
                  onOpenFolder: (folder) => _openFolder(folder),
                  onToggleFolderSelection: _toggleFolderSelection,
                  onToggleSelectionMode: _toggleSelectionMode,
                  onShowFolderBottomSheet: _handleShowFolderBottomSheet,
                ),

              // 2. Section divider if both folders and files exist
              if (matchedFolders.isNotEmpty && matchedFiles.isNotEmpty)
                FolderSectionHeaderSliver(
                  title: l10n.songsCountFormat(matchedFiles.length),
                ),

              // 3. Files/Songs Sliver (Grid or List according to viewMode)
              if (matchedFiles.isNotEmpty)
                WebDavSongsSliver(
                  files: matchedFiles,
                  viewMode: viewMode,
                  server: widget.server,
                  password: widget.password,
                  metadataMap: _metadataMap,
                  currentMusicPath: currentMusic?.path,
                  isAudioPlaying: isAudioPlaying,
                  allAudioFiles: _getAudioFiles(sourceList: displayedItems),
                  isSelectionMode: _isSelectionMode,
                  selectedSongPaths: _selectedSongPaths,
                  onSongTap: (file, index) => _handleSongTap(
                    file,
                    index,
                    _getAudioFiles(sourceList: displayedItems),
                  ),
                  onSongLongPress: _handleSongLongPress,
                  onSongSecondaryTapDown: (file, details) =>
                      _handleSongContextMenu(
                    file,
                    details.globalPosition,
                    _getAudioFiles(sourceList: displayedItems),
                    displayedItems,
                  ),
                  onSongMorePressed: (file, btnContext) {
                    final box = btnContext.findRenderObject() as RenderBox?;
                    final pos = box != null
                        ? box.localToGlobal(
                            Offset(box.size.width / 2, box.size.height / 2))
                        : Offset.zero;
                    _handleSongContextMenu(
                      file,
                      pos,
                      _getAudioFiles(sourceList: displayedItems),
                      displayedItems,
                    );
                  },
                  onDownloadSingle: _downloadSingleAudio,
                  bottomPadding: bottomOffset,
                ),

            ],
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: bottomOffset + (_isSelectionMode ? 220.0 : 0.0) + 24,
              ),
            ),
          ],
        ),
      );
    }

    final displayedAudio = _getAudioFiles(sourceList: displayedItems);
    final selectedSongs = _getSelectedSongs(sourceList: displayedItems);

    final selectedFoldersCount = _selectedFolderPaths.length;
    final selectedSongsCount = _selectedSongPaths.length;
    final totalSelectedCount = selectedFoldersCount + selectedSongsCount;
    final isSelectionEmpty = totalSelectedCount == 0;

    final allVisibleFoldersCount =
        displayedItems.where((i) => i.isDirectory).length;
    final allVisibleAudioCount =
        displayedItems.where((i) => !i.isDirectory && i.isAudio).length;
    final isAllSelected = (allVisibleFoldersCount + allVisibleAudioCount > 0) &&
        selectedFoldersCount == allVisibleFoldersCount &&
        selectedSongsCount == allVisibleAudioCount;

    final String selectionTitle;
    if (selectedFoldersCount > 0 && selectedSongsCount > 0) {
      selectionTitle =
          '${l10n.selectedFolders(selectedFoldersCount)}, ${l10n.selectedSongs(selectedSongsCount)}';
    } else if (selectedFoldersCount > 0) {
      selectionTitle = l10n.selectedFolders(selectedFoldersCount);
    } else {
      selectionTitle = l10n.selectedSongs(selectedSongsCount);
    }

    final scaffold = Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: folderPageMaxWidth),
                child: NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: mainContent,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: folderPageMaxWidth),
                  child: _buildHeaderNavBar(context, isOverlay: true),
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
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                child: _isSelectionMode
                    ? LibrarySelectionPanel(
                        key: const ValueKey('webdav-selection-panel'),
                        selectedSongs: selectedSongs,
                        allSongs: displayedAudio,
                        title: selectionTitle,
                        isSelectionEmpty: isSelectionEmpty,
                        isAllSelected: isAllSelected,
                        hideSongProperties:
                            selectedFoldersCount > 0 || selectedSongsCount != 1,
                        onToggleSelectAll: () {
                          if (isAllSelected) {
                            _clearAllSelection();
                          } else {
                            _selectAllVisible(displayedItems);
                          }
                        },
                        onCancel: _clearAllSelection,
                        onPlayNext: () async {
                          final songs = await _resolveAllSelectedSongs(
                            sourceList: displayedItems,
                          );
                          if (songs.isNotEmpty) {
                            await ref.read(audioServiceProvider).enqueueNext(songs);
                            showToast(l10n.addedToQueue);
                          } else {
                            showToast('No audio files in selected items');
                          }
                          _clearAllSelection();
                        },
                        onAddToQueue: () async {
                          final songs = await _resolveAllSelectedSongs(
                            sourceList: displayedItems,
                          );
                          if (songs.isNotEmpty) {
                            await ref.read(audioServiceProvider).appendToQueue(songs);
                            showToast(l10n.addedToQueue);
                          } else {
                            showToast('No audio files in selected items');
                          }
                          _clearAllSelection();
                        },
                        onAddToPlaylist: () async {
                          final songs = await _resolveAllSelectedSongs(
                            sourceList: displayedItems,
                          );
                          if (songs.isNotEmpty && mounted) {
                            final playlistService =
                                ref.read(playlistServiceProvider);
                            await showAddSongsToPlaylistDialog(
                              context,
                              playlistService,
                              songs,
                            );
                          } else if (mounted) {
                            showToast('No audio files in selected items');
                          }
                          _clearAllSelection();
                        },
                        onAddToFavorites: () async {
                          final songs = await _resolveAllSelectedSongs(
                            sourceList: displayedItems,
                          );
                          if (songs.isNotEmpty && mounted) {
                            final playlistService =
                                ref.read(playlistServiceProvider);
                            await playlistService.addSongsToPlaylist(
                              PlaylistService.favoritePlaylistId,
                              songs,
                            );
                            AppSnackBar.show(
                              context,
                              ref,
                              SnackBar(
                                content: Text(
                                  l10n.addedToPlaylist(
                                    songs.length,
                                    l10n.favorites,
                                  ),
                                ),
                              ),
                            );
                          } else if (mounted) {
                            showToast('No audio files in selected items');
                          }
                          _clearAllSelection();
                        },
                        onDownload: () async {
                          final songs = await _resolveAllSelectedSongs(
                            sourceList: displayedItems,
                          );
                          if (songs.isEmpty) {
                            showToast(l10n.noActiveDownloads);
                            return;
                          }
                          final notifier =
                              ref.read(remoteDownloadTasksProvider.notifier);
                          final webDavFiles = <WebDavFile>[];
                          for (final song in songs) {
                            final uriInfo =
                                RemoteMediaResolver.parseUri(song.path);
                            final remotePath = (uriInfo != null &&
                                    uriInfo.type == RemoteServerType.webdav)
                                ? uriInfo.trackIdOrPath
                                : null;
                            if (remotePath != null) {
                              webDavFiles.add(WebDavFile(
                                path: remotePath,
                                name: p.basename(remotePath),
                                isDirectory: false,
                                contentLength: 0,
                              ));
                            }
                          }
                          if (webDavFiles.isNotEmpty && mounted) {
                            await notifier.enqueueWebDavFiles(
                              server: widget.server,
                              password: widget.password,
                              files: webDavFiles,
                            );
                            if (mounted) {
                              AppSnackBar.show(
                                context,
                                ref,
                                SnackBar(
                                  content: Text(
                                    l10n.batchAddedToDownloadQueue(
                                        webDavFiles.length),
                                  ),
                                  action: SnackBarAction(
                                    label: l10n.viewDownloadProgress,
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RemoteDownloadManagerPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          }
                          _clearAllSelection();
                        },
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('webdav-selection-panel-hidden'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    final content = PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _clearAllSelection();
      },
      child: scaffold,
    );

    if (widget.wrapWithMiniPlayer) {
      return MiniPlayerWrapper(child: content);
    }
    return content;
  }

  Widget _buildBanner({
    required ThemeData theme,
    required AppLocalizations l10n,
    required String title,
    required String subtitle,
    required int audioCount,
    required int totalDurationMs,
    required String? bannerCoverThumbnailPath,
    required Widget bannerCoverWidget,
    Widget? topHeader,
  }) {
    return FolderHeaderBanner(
      title: title,
      subtitle: subtitle,
      songsCount: audioCount,
      totalDuration: Duration(milliseconds: totalDurationMs),
      coverImagePath: bannerCoverThumbnailPath,
      coverWidget: bannerCoverWidget,
      topHeader: topHeader,
      heroTag: 'webdav-cover-$_currentPath',
      isHeroModeEnabled: _isCoverVisible,
      actionButtons: [
        FolderPlayActionButtons(
          totalSongsCount: audioCount,
          onPlayAll: audioCount > 0 ? () => _playFolder(shuffle: false) : () {},
          onShufflePlay:
              audioCount > 0 ? () => _playFolder(shuffle: true) : () {},
        ),
        if (audioCount > 0) ...[
          const SizedBox(width: 8),
          IconButton.outlined(
            icon: const Icon(Icons.download_for_offline_outlined, size: 18),
            tooltip: 'Download All Audio',
            onPressed: _downloadAllAudio,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
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
      },
      onToggleSearch: (val) {
        setState(() {
          _isSearching = val;
          if (!val) {
            _searchQuery = '';
            _searchController.clear();
          }
        });
      },
    );
  }

  Widget _buildHeaderNavBar(BuildContext context, {bool isOverlay = true}) {
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final settings = ref.watch(settingsServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final activeDownloadsCount = ref.watch(activeDownloadsCountProvider);

    final lowercaseQuery = _searchQuery.toLowerCase();
    final List<WebDavFile> displayedItems;
    if (_searchQuery.isEmpty) {
      displayedItems = _items;
    } else {
      displayedItems = _items.where((item) {
        if (item.name.toLowerCase().contains(lowercaseQuery)) return true;
        final virtualUri =
            RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path);
        final meta = _metadataMap[virtualUri] ??
            ref.read(scannerServiceProvider).metadataMap[virtualUri];
        if (meta != null) {
          if (meta.title.toLowerCase().contains(lowercaseQuery)) return true;
          if (meta.artist.toLowerCase().contains(lowercaseQuery)) return true;
          if (meta.album.toLowerCase().contains(lowercaseQuery)) return true;
        }
        return false;
      }).toList();
    }
    final isCurrentMusicInFolder = currentMusic != null &&
        displayedItems.any((item) =>
            RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path) ==
            currentMusic.path);

    return ValueListenableBuilder<double>(
      valueListenable: _scrollProgress,
      builder: (context, progressValue, child) {
        final progress = progressValue.clamp(0.0, 1.0);

        final targetSurface = theme.colorScheme.surface;
        final navBackgroundColor = isOverlay
            ? Color.lerp(
                targetSurface.withValues(alpha: 0.0), targetSurface, progress)!
            : theme.scaffoldBackgroundColor;

        final overlayIconColor = isDark
            ? Colors.white
            : theme.colorScheme.onSurface.withValues(alpha: 0.85);
        final solidIconColor =
            theme.colorScheme.onSurface.withValues(alpha: 0.85);
        final iconColor = isOverlay
            ? (Color.lerp(overlayIconColor, solidIconColor, progress) ??
                solidIconColor)
            : solidIconColor;

        final overlayChevronColor = isDark
            ? Colors.white.withValues(alpha: 0.6)
            : theme.colorScheme.onSurface.withValues(alpha: 0.4);
        final solidChevronColor =
            theme.colorScheme.onSurface.withValues(alpha: 0.4);
        final chevronColor = isOverlay
            ? (Color.lerp(overlayChevronColor, solidChevronColor, progress) ??
                solidChevronColor)
            : solidChevronColor;

        final overlayFolderTextColor = isDark
            ? Colors.white.withValues(alpha: 0.9)
            : theme.colorScheme.onSurface.withValues(alpha: 0.85);
        final solidFolderTextColor =
            theme.colorScheme.onSurface.withValues(alpha: 0.85);
        final folderTextColor = isOverlay
            ? (Color.lerp(
                    overlayFolderTextColor, solidFolderTextColor, progress) ??
                solidFolderTextColor)
            : solidFolderTextColor;

        final shadowAlpha = 1.0 - progress;
        final shadows = (isOverlay && isDark && shadowAlpha > 0.05)
            ? [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.87 * shadowAlpha),
                ),
              ]
            : null;

        final backButton = Material(
          color: Colors.transparent,
          child: InkResponse(
            radius: 18,
            highlightShape: BoxShape.circle,
            onTap: _handleGoBack,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: iconColor,
                shadows: shadows,
              ),
            ),
          ),
        );

        final backChevron = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: chevronColor,
            shadows: shadows,
          ),
        );

        final List<Widget> breadcrumbItems = [];

        // Server root icon
        breadcrumbItems.add(
          Material(
            color: Colors.transparent,
            child: InkResponse(
              radius: 18,
              highlightShape: BoxShape.circle,
              onTap: () => _navigateToBreadcrumb(-1),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.cloud_queue_rounded,
                  size: 20,
                  color: iconColor,
                  shadows: shadows,
                ),
              ),
            ),
          ),
        );

        final segments = _pathSegments;
        if (segments.isEmpty) {
          breadcrumbItems.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: chevronColor,
                shadows: shadows,
              ),
            ),
          );
          breadcrumbItems.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              child: Text(
                widget.server.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: folderTextColor,
                  shadows: shadows,
                ),
              ),
            ),
          );
        } else {
          breadcrumbItems.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: chevronColor,
                shadows: shadows,
              ),
            ),
          );
          breadcrumbItems.add(
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _navigateToBreadcrumb(-1),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  child: Text(
                    widget.server.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: folderTextColor,
                      shadows: shadows,
                    ),
                  ),
                ),
              ),
            ),
          );

          for (int i = 0; i < segments.length; i++) {
            final isLast = i == segments.length - 1;
            breadcrumbItems.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: chevronColor,
                  shadows: shadows,
                ),
              ),
            );

            if (isLast) {
              breadcrumbItems.add(
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  child: Text(
                    segments[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: folderTextColor,
                      shadows: shadows,
                    ),
                  ),
                ),
              );
            } else {
              breadcrumbItems.add(
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _navigateToBreadcrumb(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 6),
                      child: Text(
                        segments[i],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: folderTextColor,
                          shadows: shadows,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        }

        final statusBarHeight = MediaQuery.of(context).padding.top;
        final isDesktop =
            Platform.isMacOS || Platform.isWindows || Platform.isLinux;
        final topPadding = statusBarHeight > 0
            ? statusBarHeight + 8
            : (isDesktop ? 44.0 : 8.0);

        return Container(
          padding: EdgeInsets.only(
            top: topPadding,
            bottom: 8,
            left: 8,
            right: 8,
          ),
          decoration: BoxDecoration(
            color: navBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: isOverlay
                    ? theme.dividerColor.withValues(alpha: 0.12 * progress)
                    : theme.dividerColor.withValues(alpha: 0.05),
              ),
            ),
            boxShadow: isOverlay && progress > 0.05
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.black : theme.colorScheme.shadow)
                          .withValues(alpha: 0.1 * progress),
                      blurRadius: 8 * progress,
                      offset: Offset(0, 2 * progress),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              backButton,
              backChevron,
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: _breadcrumbsScrollController,
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(children: breadcrumbItems),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (isPortrait)
                PopupMenuButton<String>(
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: iconColor,
                    shadows: shadows,
                  ),
                  onSelected: (value) {
                    if (value == 'locate') {
                      _locateCurrentSong();
                    } else if (value == 'view_mode') {
                      settings.folderViewMode =
                          switch (settings.folderViewMode) {
                        FolderViewMode.list => FolderViewMode.hybrid,
                        FolderViewMode.hybrid => FolderViewMode.grid,
                        FolderViewMode.grid => FolderViewMode.list,
                      };
                    } else if (value == 'refresh') {
                      _loadDirectory(_currentPath, forceRefresh: true);
                    } else if (value == 'downloads') {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const RemoteDownloadManagerPage(),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    if (isCurrentMusicInFolder)
                      PopupMenuItem(
                        value: 'locate',
                        child: Row(
                          children: [
                            const Icon(Icons.my_location_rounded, size: 20),
                            const SizedBox(width: 12),
                            Text(l10n.locateCurrentSong),
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
                              FolderViewMode.hybrid =>
                                Icons.view_module_rounded,
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
                    PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          const Icon(Icons.refresh_rounded, size: 20),
                          const SizedBox(width: 12),
                          Text(l10n.refreshResults),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'downloads',
                      child: Row(
                        children: [
                          Badge(
                            isLabelVisible: activeDownloadsCount > 0,
                            label: Text('$activeDownloadsCount'),
                            child: const Icon(Icons.download_rounded, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.downloadManager),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                if (isCurrentMusicInFolder) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkResponse(
                      radius: 18,
                      highlightShape: BoxShape.circle,
                      onTap: _locateCurrentSong,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.my_location_rounded,
                          size: 20,
                          color: iconColor,
                          shadows: shadows,
                        ),
                      ),
                    ),
                  ),
                ],
                Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    radius: 18,
                    highlightShape: BoxShape.circle,
                    onTap: () {
                      settings.folderViewMode =
                          switch (settings.folderViewMode) {
                        FolderViewMode.list => FolderViewMode.hybrid,
                        FolderViewMode.hybrid => FolderViewMode.grid,
                        FolderViewMode.grid => FolderViewMode.list,
                      };
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        switch (settings.folderViewMode) {
                          FolderViewMode.list => Icons.grid_view_rounded,
                          FolderViewMode.hybrid =>
                            Icons.view_module_rounded,
                          FolderViewMode.grid => Icons.view_list_rounded,
                        },
                        size: 20,
                        color: iconColor,
                        shadows: shadows,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    radius: 18,
                    highlightShape: BoxShape.circle,
                    onTap: () =>
                        _loadDirectory(_currentPath, forceRefresh: true),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: iconColor,
                        shadows: shadows,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    radius: 18,
                    highlightShape: BoxShape.circle,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const RemoteDownloadManagerPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Badge(
                        isLabelVisible: activeDownloadsCount > 0,
                        label: Text('$activeDownloadsCount'),
                        child: Icon(
                          Icons.download_rounded,
                          size: 20,
                          color: iconColor,
                          shadows: shadows,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
