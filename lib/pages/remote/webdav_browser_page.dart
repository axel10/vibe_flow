import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';
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
import '../../player/metadata/metadata_database.dart';
import '../../player/settings/settings_service.dart';
import '../../utils/app_snack_bar.dart';
import '../../utils/folder_helpers.dart';
import '../../utils/remote_context_menu_utils.dart';
import '../../widgets/desktop_window_title_bar.dart';
import '../../widgets/folder_header_banner.dart';
import '../../widgets/folder_layout_utils.dart';
import '../../widgets/folder_grid_card.dart';
import '../../widgets/folder_content_slivers.dart';
import '../../widgets/mini_player_wrapper.dart';
import '../../widgets/playing_equalizer_icon.dart';
import '../../widgets/song_thumbnail.dart';
import 'remote_download_manager_page.dart';

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

  // Search & Scroll states
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _breadcrumbsScrollController = ScrollController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _breadcrumbsScrollController.dispose();
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
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _currentPath = path;
    });
    _scrollToTop();

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

  void _navigateToParent() {
    if (_isAtRoot) return;
    var parent = p.dirname(_currentPath);
    if (parent == '.' || parent.isEmpty) {
      parent = _rootPath;
    }
    _loadDirectory(parent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsServiceProvider);
    final viewMode = settings.folderViewMode;
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isAudioPlaying = ref.watch(audioIsPlayingProvider);
    final isMacOS = Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final bottomOffset = MiniPlayerUiTuning.getListBottomPadding(
      context,
      hasPlayingMusic: currentMusic != null,
    );

    // Current directory audio stats
    final audioItems = _items.where((i) => i.isAudio).toList();
    final audioCount = audioItems.length;
    int totalDurationMs = 0;
    for (final item in audioItems) {
      final virtualUri = RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path);
      final meta = _metadataMap[virtualUri] ?? ref.watch(scannerServiceProvider.select((s) => s.metadataMap[virtualUri]));
      if (meta?.duration != null) {
        totalDurationMs += meta!.duration!;
      }
    }

    // Banner cover finding logic:
    // Only search in current directory audio files for an existing thumbnail file. No deep recursive search.
    String? bannerCoverThumbnailPath;
    String? bannerCoverVirtualUri;
    for (final item in audioItems) {
      final virtualUri = RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path);
      final meta = _metadataMap[virtualUri] ?? ref.watch(scannerServiceProvider.select((s) => s.metadataMap[virtualUri]));
      if (meta?.thumbnailPath != null && File(meta!.thumbnailPath!).existsSync()) {
        bannerCoverThumbnailPath = meta.thumbnailPath;
        bannerCoverVirtualUri = virtualUri;
        break;
      }
    }

    // Current folder display name & subtitle
    final folderDisplayName = _isAtRoot ? widget.server.name : p.basename(_currentPath);
    final folderDisplaySubtitle = _currentPath;

    // Search filtering within current directory
    final lowercaseQuery = _searchQuery.toLowerCase();
    final List<WebDavFile> displayedItems;
    if (_searchQuery.isEmpty) {
      displayedItems = _items;
    } else {
      displayedItems = _items.where((item) {
        if (item.name.toLowerCase().contains(lowercaseQuery)) return true;
        final virtualUri = RemoteMediaResolver.buildWebDavUri(widget.server.id, item.path);
        final meta = _metadataMap[virtualUri] ?? ref.read(scannerServiceProvider).metadataMap[virtualUri];
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
    final noSearchResults = _searchQuery.isNotEmpty && displayedItems.isEmpty && !_isLoading;

    // Build Banner cover widget
    final int hash = _currentPath.hashCode;
    final double hue = (hash.abs() % 360).toDouble();
    final Color startColor = HSLColor.fromAHSL(1.0, hue, 0.65, 0.45).toColor();
    final Color endColor = HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.75, 0.35).toColor();

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
              child: Icon(Icons.cloud_queue_rounded, size: 42, color: Colors.white70),
            ),
          );

    Widget mainContent;
    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      mainContent = Center(
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
      );
    } else if (_items.isEmpty) {
      mainContent = RefreshIndicator(
        onRefresh: () => _loadDirectory(_currentPath, forceRefresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
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
          controller: _scrollController,
          slivers: [
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
                _WebDavSubfoldersSliver(
                  folders: matchedFolders,
                  viewMode: viewMode,
                  server: widget.server,
                  password: widget.password,
                  onOpenFolder: (folder) => _loadDirectory(folder.path),
                ),

              // 2. Section divider if both folders and files exist
              if (matchedFolders.isNotEmpty && matchedFiles.isNotEmpty)
                FolderSectionHeaderSliver(
                  title: l10n.songsCountFormat(matchedFiles.length),
                ),

              // 3. Files/Songs Sliver (Grid or List according to viewMode)
              if (matchedFiles.isNotEmpty)
                _WebDavSongsSliver(
                  files: matchedFiles,
                  viewMode: viewMode,
                  server: widget.server,
                  password: widget.password,
                  metadataMap: _metadataMap,
                  currentMusicPath: currentMusic?.path,
                  isAudioPlaying: isAudioPlaying,
                  allAudioFiles: _getAudioFiles(sourceList: displayedItems),
                  onDownloadSingle: _downloadSingleAudio,
                  bottomPadding: bottomOffset,
                ),
            ],
            SliverPadding(padding: EdgeInsets.only(bottom: bottomOffset + 24)),
          ],
        ),
      );
    }

    Widget scaffoldContent = PopScope(
      canPop: _isAtRoot,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(activeRemoteSessionProvider.notifier).clear();
          });
          return;
        }
        if (!_isAtRoot) {
          _navigateToParent();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(_isAtRoot ? Icons.arrow_back_rounded : Icons.arrow_upward_rounded),
            tooltip: _isAtRoot ? 'Exit' : 'Up to parent folder',
            onPressed: _isAtRoot
                ? () => ref.read(activeRemoteSessionProvider.notifier).clear()
                : _navigateToParent,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.server.name),
              Text(
                'WebDAV Storage',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            // View Mode switcher (List, Grid, Hybrid)
            PopupMenuButton<FolderViewMode>(
              icon: Icon(_getViewModeIcon(viewMode)),
              tooltip: 'View Mode',
              onSelected: (mode) {
                ref.read(settingsServiceProvider).folderViewMode = mode;
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: FolderViewMode.list,
                  child: Row(
                    children: [
                      Icon(
                        Icons.view_list_rounded,
                        color: viewMode == FolderViewMode.list
                            ? theme.colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'List View',
                        style: TextStyle(
                          fontWeight: viewMode == FolderViewMode.list
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: viewMode == FolderViewMode.list
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: FolderViewMode.grid,
                  child: Row(
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        color: viewMode == FolderViewMode.grid
                            ? theme.colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Grid View',
                        style: TextStyle(
                          fontWeight: viewMode == FolderViewMode.grid
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: viewMode == FolderViewMode.grid
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: FolderViewMode.hybrid,
                  child: Row(
                    children: [
                      Icon(
                        Icons.dashboard_customize_rounded,
                        color: viewMode == FolderViewMode.hybrid
                            ? theme.colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Hybrid View',
                        style: TextStyle(
                          fontWeight: viewMode == FolderViewMode.hybrid
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: viewMode == FolderViewMode.hybrid
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: () =>
                  _loadDirectory(_currentPath, forceRefresh: true),
            ),
            IconButton(
              icon: Badge(
                isLabelVisible:
                    ref.watch(activeDownloadsCountProvider) > 0,
                label:
                    Text('${ref.watch(activeDownloadsCountProvider)}'),
                child: const Icon(Icons.download_rounded),
              ),
              tooltip: 'Download Manager',
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const RemoteDownloadManagerPage(),
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(42.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBreadcrumbs(theme),
                const Divider(height: 1),
              ],
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: folderPageMaxWidth),
            child: mainContent,
          ),
        ),
      ),
    );

    if (showCustomTitleBar || isMacOS) {
      scaffoldContent = Material(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            if (showCustomTitleBar)
              DesktopWindowTitleBar(brightness: theme.brightness)
            else
              const DragToMoveArea(child: SizedBox(height: 32)),
            Expanded(child: scaffoldContent),
          ],
        ),
      );
    }

    if (widget.wrapWithMiniPlayer) {
      return MiniPlayerWrapper(child: scaffoldContent);
    }
    return scaffoldContent;
  }

  IconData _getViewModeIcon(FolderViewMode mode) {
    switch (mode) {
      case FolderViewMode.list:
        return Icons.view_list_rounded;
      case FolderViewMode.grid:
        return Icons.grid_view_rounded;
      case FolderViewMode.hybrid:
        return Icons.dashboard_customize_rounded;
    }
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
  }) {
    return FolderHeaderBanner(
      title: title,
      subtitle: subtitle,
      songsCount: audioCount,
      totalDuration: Duration(milliseconds: totalDurationMs),
      coverImagePath: bannerCoverThumbnailPath,
      coverWidget: bannerCoverWidget,
      heroTag: 'webdav-cover-$_currentPath',
      actionButtons: [
        FilledButton.icon(
          onPressed: audioCount > 0 ? () => _playFolder(shuffle: false) : null,
          icon: const Icon(Icons.play_arrow_rounded, size: 20),
          label: Text(l10n.playAll),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: audioCount > 0 ? () => _playFolder(shuffle: true) : null,
          icon: const Icon(Icons.shuffle_rounded, size: 18),
          label: Text(l10n.shufflePlay),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
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
      searchHintText: 'Search in current folder...',
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

  Widget _buildBreadcrumbs(ThemeData theme) {
    final segments = _currentPath
        .split('/')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _breadcrumbsScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _loadDirectory(_rootPath),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_queue_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.server.name,
                            style: TextStyle(
                              fontWeight: _isAtRoot ? FontWeight.bold : FontWeight.w500,
                              color: _isAtRoot ? theme.colorScheme.primary : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  for (int i = 0; i < segments.length; i++) ...[
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    InkWell(
                      onTap: () {
                        final targetPath = '/${segments.sublist(0, i + 1).join('/')}';
                        _loadDirectory(targetPath);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text(
                          segments[i],
                          style: TextStyle(
                            fontWeight: i == segments.length - 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: i == segments.length - 1
                                ? theme.colorScheme.primary
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders subfolders in grid or list mode for WebDAV.
/// Subfolders do NOT generate representative covers, using clean HSL gradient icons instead.
class _WebDavSubfoldersSliver extends ConsumerWidget {
  final List<WebDavFile> folders;
  final FolderViewMode viewMode;
  final RemoteServer server;
  final String password;
  final void Function(WebDavFile) onOpenFolder;

  const _WebDavSubfoldersSliver({
    required this.folders,
    required this.viewMode,
    required this.server,
    required this.password,
    required this.onOpenFolder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid =
        viewMode == FolderViewMode.hybrid || viewMode == FolderViewMode.grid;

    if (isGrid) {
      return SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final crossAxisCount = getFolderGridCrossAxisCount(width);
          final childAspectRatio = calculateFolderGridChildAspectRatio(
            context,
            width,
            crossAxisCount,
          );

          return SliverPadding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final folder = folders[index];
                  return HoverableCard(
                    child: _WebDavFolderGridCard(
                      folder: folder,
                      server: server,
                      password: password,
                      onTap: () => onOpenFolder(folder),
                    ),
                  );
                },
                childCount: folders.length,
              ),
            ),
          );
        },
      );
    } else {
      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      return SliverPadding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final folder = folders[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPortrait ? 8 : 16,
                  vertical: 4,
                ),
                child: _WebDavFolderListTile(
                  folder: folder,
                  server: server,
                  password: password,
                  onTap: () => onOpenFolder(folder),
                ),
              );
            },
            childCount: folders.length,
          ),
        ),
      );
    }
  }
}

/// Rich Grid Card widget for a WebDAV Folder.
class _WebDavFolderGridCard extends ConsumerWidget {
  final WebDavFile folder;
  final RemoteServer server;
  final String password;
  final VoidCallback onTap;

  const _WebDavFolderGridCard({
    required this.folder,
    required this.server,
    required this.password,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final int hash = folder.path.hashCode;
    final double hue = (hash.abs() % 360).toDouble();
    final Color startColor = HSLColor.fromAHSL(1.0, hue, 0.65, 0.45).toColor();
    final Color endColor = HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.75, 0.35).toColor();

    void showContextMenu(Offset pos) {
      showWebDavFolderContextMenu(
        context: context,
        globalPosition: pos,
        ref: ref,
        server: server,
        password: password,
        folder: folder,
        onOpen: onTap,
      );
    }

    return GestureDetector(
      onSecondaryTapDown: (details) => showContextMenu(details.globalPosition),
      onLongPressStart: (details) => showContextMenu(details.globalPosition),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        enableFeedback: false,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [startColor, endColor],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.folder_rounded,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (isPortrait
                                  ? theme.textTheme.titleSmall
                                  : theme.textTheme.titleMedium)
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Folder',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (isPortrait
                                  ? theme.textTheme.bodySmall
                                  : theme.textTheme.bodyMedium)
                              ?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rich List Tile widget for a WebDAV Folder.
class _WebDavFolderListTile extends ConsumerWidget {
  final WebDavFile folder;
  final RemoteServer server;
  final String password;
  final VoidCallback onTap;

  const _WebDavFolderListTile({
    required this.folder,
    required this.server,
    required this.password,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final int hash = folder.path.hashCode;
    final double hue = (hash.abs() % 360).toDouble();
    final Color startColor = HSLColor.fromAHSL(1.0, hue, 0.65, 0.45).toColor();
    final Color endColor = HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.75, 0.35).toColor();

    void showContextMenu(Offset pos) {
      showWebDavFolderContextMenu(
        context: context,
        globalPosition: pos,
        ref: ref,
        server: server,
        password: password,
        folder: folder,
        onOpen: onTap,
      );
    }

    final leadingWidget = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.folder_rounded,
          size: 28,
          color: Colors.white,
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) => showContextMenu(details.globalPosition),
      onLongPressStart: (details) => showContextMenu(details.globalPosition),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          enableFeedback: false,
          onTap: onTap,
          hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isPortrait ? 8 : 12,
              vertical: 6,
            ),
            child: Row(
              children: [
                leadingWidget,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        folder.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Folder',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (btnContext) {
                    return IconButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      tooltip: 'More',
                      onPressed: () {
                        final box = btnContext.findRenderObject() as RenderBox?;
                        final pos = box != null
                            ? box.localToGlobal(
                                Offset(box.size.width / 2, box.size.height / 2))
                            : Offset.zero;
                        showContextMenu(pos);
                      },
                    );
                  },
                ),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders songs & files in grid or list mode for WebDAV.
class _WebDavSongsSliver extends ConsumerWidget {
  final List<WebDavFile> files;
  final FolderViewMode viewMode;
  final RemoteServer server;
  final String password;
  final Map<String, SongMetadata> metadataMap;
  final String? currentMusicPath;
  final bool isAudioPlaying;
  final List<MusicFile> allAudioFiles;
  final void Function(WebDavFile) onDownloadSingle;
  final double bottomPadding;

  const _WebDavSongsSliver({
    required this.files,
    required this.viewMode,
    required this.server,
    required this.password,
    required this.metadataMap,
    required this.currentMusicPath,
    required this.isAudioPlaying,
    required this.allAudioFiles,
    required this.onDownloadSingle,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSongGrid = viewMode == FolderViewMode.grid;

    if (isSongGrid) {
      return SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final crossAxisCount = getFolderGridCrossAxisCount(width);
          final childAspectRatio = calculateFolderGridChildAspectRatio(
            context,
            width,
            crossAxisCount,
          );

          return SliverPadding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final file = files[index];
                  return HoverableCard(
                    child: _WebDavSongGridCard(
                      file: file,
                      server: server,
                      password: password,
                      metadata: metadataMap[RemoteMediaResolver.buildWebDavUri(server.id, file.path)] ??
                          ref.watch(scannerServiceProvider.select((s) => s.metadataMap[RemoteMediaResolver.buildWebDavUri(server.id, file.path)])),
                      currentMusicPath: currentMusicPath,
                      isAudioPlaying: isAudioPlaying,
                      allAudioFiles: allAudioFiles,
                    ),
                  );
                },
                childCount: files.length,
              ),
            ),
          );
        },
      );
    } else {
      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      return SliverPadding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final file = files[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPortrait ? 8 : 16,
                  vertical: 4,
                ),
                child: _WebDavSongListTile(
                  file: file,
                  server: server,
                  password: password,
                  metadata: metadataMap[RemoteMediaResolver.buildWebDavUri(server.id, file.path)] ??
                      ref.watch(scannerServiceProvider.select((s) => s.metadataMap[RemoteMediaResolver.buildWebDavUri(server.id, file.path)])),
                  currentMusicPath: currentMusicPath,
                  isAudioPlaying: isAudioPlaying,
                  allAudioFiles: allAudioFiles,
                  onDownload: () => onDownloadSingle(file),
                ),
              );
            },
            childCount: files.length,
          ),
        ),
      );
    }
  }
}

/// Rich Grid Card widget for a WebDAV Song / Audio File.
class _WebDavSongGridCard extends ConsumerWidget {
  final WebDavFile file;
  final RemoteServer server;
  final String password;
  final SongMetadata? metadata;
  final String? currentMusicPath;
  final bool isAudioPlaying;
  final List<MusicFile> allAudioFiles;

  const _WebDavSongGridCard({
    required this.file,
    required this.server,
    required this.password,
    required this.metadata,
    required this.currentMusicPath,
    required this.isAudioPlaying,
    required this.allAudioFiles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final isDark = theme.brightness == Brightness.dark;
    final isAudio = file.isAudio;
    final remoteUri = RemoteMediaResolver.buildWebDavUri(server.id, file.path);
    final isCurrent = currentMusicPath == remoteUri;

    final titleText = (metadata != null && metadata!.title.isNotEmpty)
        ? metadata!.title
        : file.name;

    final hasArtist = metadata != null &&
        metadata!.artist.isNotEmpty &&
        metadata!.artist != 'Unknown';
    final hasAlbum = metadata != null &&
        metadata!.album.isNotEmpty &&
        metadata!.album != 'Unknown';
    String artistAlbumStr = 'WebDAV File';
    if (hasArtist && hasAlbum) {
      artistAlbumStr = '${metadata!.artist} - ${metadata!.album}';
    } else if (hasArtist) {
      artistAlbumStr = metadata!.artist;
    } else if (hasAlbum) {
      artistAlbumStr = metadata!.album;
    }

    final durationStr = metadata?.duration != null
        ? _formatDuration(metadata!.duration!)
        : null;
    final ext = p.extension(file.name).replaceAll('.', '').toUpperCase();

    final capsuleBgColor = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.75);
    final capsuleTextColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.9);

    final titleColor = isCurrent
        ? theme.colorScheme.primary
        : (isAudio
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7));

    void showContextMenu(Offset pos) {
      showWebDavFileContextMenu(
        context: context,
        globalPosition: pos,
        ref: ref,
        server: server,
        password: password,
        file: file,
        currentAudioFiles: allAudioFiles,
        onPlay: isAudio
            ? () async {
                final target = RemoteMediaResolver.buildMusicFileFromWebDav(
                  file,
                  server,
                  metadata: metadata,
                );
                final initialIndex =
                    allAudioFiles.indexWhere((s) => s.path == target.path);
                final audioService = ref.read(audioServiceProvider);
                await audioService.playPlaylist(
                  allAudioFiles.isNotEmpty ? allAudioFiles : [target],
                  initialIndex: initialIndex >= 0 ? initialIndex : 0,
                );
              }
            : null,
      );
    }

    return GestureDetector(
      onSecondaryTapDown: (details) => showContextMenu(details.globalPosition),
      onLongPressStart: (details) => showContextMenu(details.globalPosition),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        enableFeedback: false,
        onTap: isAudio
            ? () async {
                final target = RemoteMediaResolver.buildMusicFileFromWebDav(
                  file,
                  server,
                  metadata: metadata,
                );
                final initialIndex =
                    allAudioFiles.indexWhere((s) => s.path == target.path);
                final audioService = ref.read(audioServiceProvider);
                await audioService.playPlaylist(
                  allAudioFiles.isNotEmpty ? allAudioFiles : [target],
                  initialIndex: initialIndex >= 0 ? initialIndex : 0,
                );
              }
            : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
            border: Border.all(
              color: isCurrent
                  ? theme.colorScheme.primary.withValues(alpha: 0.8)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              width: isCurrent ? 1.5 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (isAudio)
                          SongThumbnail(
                            path: remoteUri,
                            thumbnailPath: metadata?.thumbnailPath,
                            size: 200,
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: BorderRadius.zero,
                          )
                        else
                          Container(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            child: Center(
                              child: Icon(
                                Icons.insert_drive_file_outlined,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        if (isAudio && (durationStr != null || ext.isNotEmpty))
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: capsuleBgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.1),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '${ext.isNotEmpty ? ext : "AUDIO"}${durationStr != null ? " • $durationStr" : ""}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: capsuleTextColor,
                                ),
                              ),
                            ),
                          ),
                        if (isCurrent)
                          Container(
                            color: Colors.black45,
                            child: Center(
                              child: PlayingEqualizerIcon(
                                color: Colors.white,
                                size: 22,
                                isPlaying: isAudioPlaying,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            if (isCurrent) ...[
                              PlayingEqualizerIcon(
                                color: theme.colorScheme.primary,
                                size: 14,
                                isPlaying: isAudioPlaying,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                titleText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: (isPortrait
                                        ? theme.textTheme.titleSmall
                                        : theme.textTheme.titleMedium)
                                    ?.copyWith(
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAudio
                              ? artistAlbumStr
                              : _formatFileSize(file.contentLength),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (isPortrait
                                  ? theme.textTheme.bodySmall
                                  : theme.textTheme.bodyMedium)
                              ?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rich List Tile widget for a WebDAV Song / Audio File.
class _WebDavSongListTile extends ConsumerWidget {
  final WebDavFile file;
  final RemoteServer server;
  final String password;
  final SongMetadata? metadata;
  final String? currentMusicPath;
  final bool isAudioPlaying;
  final List<MusicFile> allAudioFiles;
  final VoidCallback onDownload;

  const _WebDavSongListTile({
    required this.file,
    required this.server,
    required this.password,
    required this.metadata,
    required this.currentMusicPath,
    required this.isAudioPlaying,
    required this.allAudioFiles,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAudio = file.isAudio;
    final remoteUri = RemoteMediaResolver.buildWebDavUri(server.id, file.path);
    final isCurrent = currentMusicPath == remoteUri;

    final titleText = (metadata != null && metadata!.title.isNotEmpty)
        ? metadata!.title
        : file.name;

    final hasArtist = metadata != null &&
        metadata!.artist.isNotEmpty &&
        metadata!.artist != 'Unknown';
    final hasAlbum = metadata != null &&
        metadata!.album.isNotEmpty &&
        metadata!.album != 'Unknown';
    String? artistAlbumStr;
    if (hasArtist && hasAlbum) {
      artistAlbumStr = '${metadata!.artist} - ${metadata!.album}';
    } else if (hasArtist) {
      artistAlbumStr = metadata!.artist;
    } else if (hasAlbum) {
      artistAlbumStr = metadata!.album;
    }

    final durationStr = metadata?.duration != null
        ? _formatDuration(metadata!.duration!)
        : null;
    final ext = p.extension(file.name).replaceAll('.', '').toUpperCase();
    final sizeStr = _formatFileSize(file.contentLength);

    final List<String> techParts = [];
    if (durationStr != null) techParts.add(durationStr);
    if (ext.isNotEmpty) techParts.add(ext);
    if (sizeStr.isNotEmpty) techParts.add(sizeStr);
    final techInfoStr = techParts.join(' | ');

    void showContextMenu(Offset pos) {
      showWebDavFileContextMenu(
        context: context,
        globalPosition: pos,
        ref: ref,
        server: server,
        password: password,
        file: file,
        currentAudioFiles: allAudioFiles,
        onPlay: isAudio
            ? () async {
                final target = RemoteMediaResolver.buildMusicFileFromWebDav(
                  file,
                  server,
                  metadata: metadata,
                );
                final initialIndex =
                    allAudioFiles.indexWhere((s) => s.path == target.path);
                final audioService = ref.read(audioServiceProvider);
                await audioService.playPlaylist(
                  allAudioFiles.isNotEmpty ? allAudioFiles : [target],
                  initialIndex: initialIndex >= 0 ? initialIndex : 0,
                );
              }
            : null,
      );
    }

    Widget leadingWidget;
    if (isAudio) {
      leadingWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SongThumbnail(
                path: remoteUri,
                thumbnailPath: metadata?.thumbnailPath,
                size: 52.0,
              ),
              if (isCurrent)
                Container(
                  color: Colors.black45,
                  child: Center(
                    child: PlayingEqualizerIcon(
                      color: Colors.white,
                      size: 18,
                      isPlaying: isAudioPlaying,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      leadingWidget = Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.insert_drive_file_outlined,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          size: 26,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) => showContextMenu(details.globalPosition),
      onLongPressStart: (details) => showContextMenu(details.globalPosition),
      child: ListTile(
        leading: leadingWidget,
        title: Text(
          titleText,
          style: TextStyle(
            color: isCurrent
                ? theme.colorScheme.primary
                : (isAudio
                    ? null
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: isAudio
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (artistAlbumStr != null) ...[
                    Text(
                      artistAlbumStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrent
                            ? theme.colorScheme.primary.withValues(alpha: 0.85)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                  ],
                  Text(
                    techInfoStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: isCurrent
                          ? theme.colorScheme.primary.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : Text(
                sizeStr,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAudio)
              IconButton(
                icon: Icon(
                  Icons.download_rounded,
                  size: 22,
                  color: isCurrent ? theme.colorScheme.primary : null,
                ),
                tooltip: 'Download',
                onPressed: onDownload,
              ),
            Builder(
              builder: (btnContext) {
                return IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: isCurrent ? theme.colorScheme.primary : null,
                  ),
                  tooltip: 'More',
                  onPressed: () {
                    final box = btnContext.findRenderObject() as RenderBox?;
                    final pos = box != null
                        ? box.localToGlobal(
                            Offset(box.size.width / 2, box.size.height / 2))
                        : Offset.zero;
                    showContextMenu(pos);
                  },
                );
              },
            ),
          ],
        ),
        onTap: isAudio
            ? () async {
                final target = RemoteMediaResolver.buildMusicFileFromWebDav(
                  file,
                  server,
                  metadata: metadata,
                );
                final initialIndex =
                    allAudioFiles.indexWhere((s) => s.path == target.path);
                final audioService = ref.read(audioServiceProvider);
                await audioService.playPlaylist(
                  allAudioFiles.isNotEmpty ? allAudioFiles : [target],
                  initialIndex: initialIndex >= 0 ? initialIndex : 0,
                );
              }
            : null,
      ),
    );
  }
}

String _formatDuration(int durationMs) {
  final duration = Duration(milliseconds: durationMs);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _formatFileSize(int bytes) {
  if (bytes <= 0) return '0 B';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
