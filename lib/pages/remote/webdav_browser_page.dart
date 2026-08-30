import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';
import '../../models/music_file.dart';
import '../../player/audio/audio_riverpod.dart';
import '../../player/remote/remote_server_models.dart';
import '../../player/remote/remote_server_riverpod.dart';
import '../../player/remote/clients/webdav_client.dart';
import '../../player/remote/proxy/remote_media_resolver.dart';
import '../../l10n/app_localizations.dart';
import '../../player/remote/services/remote_download_service.dart';
import '../../player/remote/services/webdav_metadata_helper.dart';
import '../../player/metadata/metadata_database.dart';
import '../../player/scanner/scanner_service.dart';
import '../../utils/app_snack_bar.dart';
import '../../utils/remote_context_menu_utils.dart';
import '../../widgets/desktop_window_title_bar.dart';
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

  @override
  void initState() {
    super.initState();
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

    if (!forceRefresh &&
        isSameServer &&
        session.webDavDirectoryCache.containsKey(path)) {
      setState(() {
        _currentPath = path;
        _items = session.webDavDirectoryCache[path]!;
        _isLoading = false;
        _error = null;
      });
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

  List<MusicFile> _getAudioFiles() {
    final scanner = ref.read(scannerServiceProvider);
    return _items
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
    await audioService.playPlaylist(playlist);
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
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isAudioPlaying = ref.watch(audioIsPlayingProvider);
    final audioCount = _items.where((i) => i.isAudio).length;
    final isMacOS = Platform.isMacOS;
    final bool showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final bottomOffset = MiniPlayerUiTuning.getListBottomPadding(
      context,
      hasPlayingMusic: currentMusic != null,
    );

    Widget content = PopScope(
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
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                snap: false,
                pinned: false,
                forceElevated: innerBoxIsScrolled,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Exit',
                  onPressed: () {
                    ref.read(activeRemoteSessionProvider.notifier).clear();
                  },
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
                  if (audioCount > 0) ...[
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill_rounded),
                      tooltip: 'Play All',
                      onPressed: () => _playFolder(shuffle: false),
                    ),
                    IconButton(
                      icon: const Icon(Icons.shuffle_rounded),
                      tooltip: 'Shuffle',
                      onPressed: () => _playFolder(shuffle: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_for_offline_outlined),
                      tooltip: 'Download All Audio',
                      onPressed: _downloadAllAudio,
                    ),
                  ],
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
                  preferredSize: const Size.fromHeight(49.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBreadcrumbs(theme),
                      const Divider(height: 1),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
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
                              onPressed: () => _loadDirectory(
                                  _currentPath,
                                  forceRefresh: true),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _items.isEmpty
                      ? const Center(child: Text('Folder is empty'))
                      : RefreshIndicator(
                          onRefresh: () =>
                              _loadDirectory(_currentPath, forceRefresh: true),
                          child: ListView.builder(
                            padding:
                                EdgeInsets.fromLTRB(0, 0, 0, bottomOffset),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              if (item.isDirectory) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onSecondaryTapDown: (details) {
                                    showWebDavFolderContextMenu(
                                      context: context,
                                      globalPosition:
                                          details.globalPosition,
                                      ref: ref,
                                      server: widget.server,
                                      password: widget.password,
                                      folder: item,
                                      onOpen: () =>
                                          _loadDirectory(item.path),
                                    );
                                  },
                                  onLongPressStart: (details) {
                                    showWebDavFolderContextMenu(
                                      context: context,
                                      globalPosition:
                                          details.globalPosition,
                                      ref: ref,
                                      server: widget.server,
                                      password: widget.password,
                                      folder: item,
                                      onOpen: () =>
                                          _loadDirectory(item.path),
                                    );
                                  },
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.folder_rounded,
                                      color: Colors.amber,
                                      size: 28,
                                    ),
                                    title: Text(
                                      item.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Builder(
                                          builder: (btnContext) {
                                            return IconButton(
                                              icon: const Icon(
                                                  Icons.more_vert_rounded,
                                                  size: 20),
                                              tooltip: 'More',
                                              onPressed: () {
                                                final box = btnContext
                                                        .findRenderObject()
                                                    as RenderBox?;
                                                final pos = box != null
                                                    ? box.localToGlobal(
                                                        Offset(
                                                            box.size
                                                                    .width /
                                                                2,
                                                            box.size
                                                                    .height /
                                                                2))
                                                    : Offset.zero;
                                                showWebDavFolderContextMenu(
                                                  context: context,
                                                  globalPosition: pos,
                                                  ref: ref,
                                                  server: widget.server,
                                                  password:
                                                      widget.password,
                                                  folder: item,
                                                  onOpen: () =>
                                                      _loadDirectory(
                                                          item.path),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        const Icon(
                                            Icons.chevron_right_rounded),
                                      ],
                                    ),
                                    onTap: () {
                                      _loadDirectory(item.path);
                                    },
                                  ),
                                );
                              }

                              // Only emphasize audio files
                              final isAudio = item.isAudio;
                              final remoteUri =
                                  RemoteMediaResolver.buildWebDavUri(
                                widget.server.id,
                                item.path,
                              );
                              final isCurrent =
                                  currentMusic?.path == remoteUri;

                              final metadata = _metadataMap[remoteUri] ??
                                  ref.watch(scannerServiceProvider
                                      .select((s) => s.metadataMap[remoteUri]));

                              final titleText = (metadata != null &&
                                      metadata.title.isNotEmpty)
                                  ? metadata.title
                                  : item.name;

                              final hasArtist = metadata != null &&
                                  metadata.artist.isNotEmpty &&
                                  metadata.artist != 'Unknown';
                              final hasAlbum = metadata != null &&
                                  metadata.album.isNotEmpty &&
                                  metadata.album != 'Unknown';
                              String? artistAlbumStr;
                              if (hasArtist && hasAlbum) {
                                artistAlbumStr =
                                    '${metadata.artist} - ${metadata.album}';
                              } else if (hasArtist) {
                                artistAlbumStr = metadata.artist;
                              } else if (hasAlbum) {
                                artistAlbumStr = metadata.album;
                              }

                              final durationStr = metadata?.duration != null
                                  ? _formatDuration(metadata!.duration!)
                                  : null;
                              final ext = p
                                  .extension(item.name)
                                  .replaceAll('.', '')
                                  .toUpperCase();
                              final sizeStr =
                                  _formatFileSize(item.contentLength);

                              final List<String> techParts = [];
                              if (durationStr != null) techParts.add(durationStr);
                              if (ext.isNotEmpty) techParts.add(ext);
                              if (sizeStr.isNotEmpty) techParts.add(sizeStr);
                              final techInfoStr = techParts.join(' | ');

                              void showFileMenu(Offset pos) {
                                final audioFiles = _getAudioFiles();
                                showWebDavFileContextMenu(
                                  context: context,
                                  globalPosition: pos,
                                  ref: ref,
                                  server: widget.server,
                                  password: widget.password,
                                  file: item,
                                  currentAudioFiles: audioFiles,
                                  onPlay: isAudio
                                      ? () async {
                                          final target =
                                              RemoteMediaResolver
                                                  .buildMusicFileFromWebDav(
                                            item,
                                            widget.server,
                                            metadata: metadata,
                                          );
                                          final initialIndex = audioFiles
                                              .indexWhere((s) =>
                                                  s.path == target.path);
                                          final audioService = ref.read(
                                              audioServiceProvider);
                                          await audioService.playPlaylist(
                                            audioFiles.isNotEmpty
                                                ? audioFiles
                                                : [target],
                                            initialIndex:
                                                initialIndex >= 0
                                                    ? initialIndex
                                                    : 0,
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
                                    width: 48,
                                    height: 48,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        SongThumbnail(
                                          path: remoteUri,
                                          thumbnailPath:
                                              metadata?.thumbnailPath,
                                          size: 48.0,
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
                                leadingWidget = Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                  size: 28,
                                );
                              }

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onSecondaryTapDown: (details) =>
                                    showFileMenu(
                                        details.globalPosition),
                                onLongPressStart: (details) =>
                                    showFileMenu(
                                        details.globalPosition),
                                child: ListTile(
                                  leading: leadingWidget,
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          titleText,
                                          style: TextStyle(
                                            color: isCurrent
                                                ? theme
                                                    .colorScheme.primary
                                                : (isAudio
                                                    ? null
                                                    : theme
                                                        .colorScheme
                                                        .onSurfaceVariant
                                                        .withValues(
                                                            alpha: 0.6)),
                                            fontWeight: isCurrent
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: isAudio
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (artistAlbumStr != null) ...[
                                              Text(
                                                artistAlbumStr,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isCurrent
                                                      ? theme.colorScheme
                                                          .primary
                                                          .withValues(
                                                              alpha: 0.85)
                                                      : theme.colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 1),
                                            ],
                                            Text(
                                              techInfoStr,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isCurrent
                                                    ? theme.colorScheme
                                                        .primary
                                                        .withValues(
                                                            alpha: 0.7)
                                                    : theme.colorScheme
                                                        .onSurfaceVariant
                                                        .withValues(
                                                            alpha: 0.75),
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )
                                      : Text(
                                          sizeStr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme
                                                .onSurfaceVariant,
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
                                            color: isCurrent
                                                ? theme
                                                    .colorScheme.primary
                                                : null,
                                          ),
                                          tooltip: 'Download',
                                          onPressed: () =>
                                              _downloadSingleAudio(item),
                                        ),
                                      Builder(
                                        builder: (btnContext) {
                                          return IconButton(
                                            icon: Icon(
                                              Icons.more_vert_rounded,
                                              size: 20,
                                              color: isCurrent
                                                ? theme
                                                    .colorScheme.primary
                                                : null,
                                            ),
                                            tooltip: 'More',
                                            onPressed: () {
                                              final box = btnContext
                                                      .findRenderObject()
                                                  as RenderBox?;
                                              final pos = box != null
                                                  ? box.localToGlobal(
                                                      Offset(
                                                          box.size
                                                                  .width /
                                                              2,
                                                          box.size
                                                                  .height /
                                                              2))
                                                  : Offset.zero;
                                              showFileMenu(pos);
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: isAudio
                                      ? () async {
                                          final audioFiles =
                                              _getAudioFiles();
                                          final target =
                                              RemoteMediaResolver
                                                  .buildMusicFileFromWebDav(
                                            item,
                                            widget.server,
                                            metadata: metadata,
                                          );
                                          final initialIndex = audioFiles
                                              .indexWhere((s) =>
                                                  s.path == target.path);
                                          final audioService = ref.read(
                                              audioServiceProvider);
                                          await audioService.playPlaylist(
                                            audioFiles.isNotEmpty
                                                ? audioFiles
                                                : [target],
                                            initialIndex:
                                                initialIndex >= 0
                                                    ? initialIndex
                                                    : 0,
                                          );
                                        }
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ),
    );

    if (showCustomTitleBar || isMacOS) {
      content = Material(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            if (showCustomTitleBar)
              DesktopWindowTitleBar(brightness: theme.brightness)
            else
              const DragToMoveArea(child: SizedBox(height: 32)),
            Expanded(child: content),
          ],
        ),
      );
    }

    if (widget.wrapWithMiniPlayer) {
      return MiniPlayerWrapper(child: content);
    }
    return content;
  }

  Widget _buildBreadcrumbs(ThemeData theme) {
    final segments = _currentPath
        .split('/')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward_rounded, size: 20),
            tooltip: 'Up to parent folder',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: _isAtRoot ? null : _navigateToParent,
          ),
          const SizedBox(width: 4),
          const SizedBox(
            height: 16,
            child: VerticalDivider(width: 8, thickness: 1),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _loadDirectory(_rootPath),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_queue_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          const Text('Root', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  for (int i = 0; i < segments.length; i++) ...[
                    const Icon(Icons.chevron_right_rounded, size: 16),
                    InkWell(
                      onTap: () {
                        final targetPath = '/${segments.sublist(0, i + 1).join('/')}';
                        _loadDirectory(targetPath);
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
}
