import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import '../utils/file_selector_helper.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';
import '../l10n/app_localizations.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/scanner/scanner_path_utils.dart';
import 'package:vynody/player/scanner/scanner_service.dart';
import '../widgets/library_selection_scope.dart';
import 'package:vynody/utils/app_snack_bar.dart';
import 'package:vynody/transcode/transcode_riverpod.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:audio_core/audio_core.dart';
import '../widgets/scan_progress_toast.dart';
import '../widgets/folder_bottom_sheet.dart';
import 'folder_root_view.dart';
import 'folder_detail_view.dart';
import 'package:linux_directory_access/linux_directory_access.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/remote_server_riverpod.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/remote/clients/subsonic_client.dart';
import 'package:vynody/player/remote/navidrome_navigation.dart';
import 'remote/navidrome_library_page.dart';
import 'remote/navidrome_album_detail_page.dart';
import 'remote/navidrome_artist_detail_page.dart';
import 'remote/navidrome_playlist_detail_page.dart';
import 'remote/webdav_browser_page.dart';

class FoldersPage extends ConsumerStatefulWidget {
  final Future<void> Function()? onOpenPlayback;

  const FoldersPage({super.key, this.onOpenPlayback});

  @override
  ConsumerState<FoldersPage> createState() => FoldersPageState();
}

class FoldersPageState extends ConsumerState<FoldersPage> {
  bool _isSelectionMode = false;
  bool _isRootSortMode = false;
  final Set<String> _selectedSongPaths = {};
  final Set<String> _selectedFolderPaths = {};
  final Set<String> _selectedRootPaths = {};
  StreamSubscription<ScanProgress>? _scanProgressSubscription;
  ToastFuture? _scanToast;
  bool _wasScanning = false;
  Timer? _scanToastUpdateTimer;
  Timer? _scanToastAutoDismissTimer;
  ScanProgress? _pendingScanProgress;
  DateTime? _lastScanToastUpdateAt;
  AppLocalizations? _l10n;
  ScannerService? _scanner;
  late final LibrarySelectionScopeController _librarySelectionScopeController;
  final ValueNotifier<ScanToastState?> _scanToastState =
      ValueNotifier<ScanToastState?>(null);
  String? _highlightedSongPath;
  Timer? _highlightTimer;
  late final HeroController _heroController;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool handleBackPressed() {
    if (_isRootSortMode) {
      setState(() {
        _isRootSortMode = false;
      });
      return true;
    }
    if (_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState?.maybePop();
      return true;
    }
    final session = ref.read(activeRemoteSessionProvider);
    if (session != null) {
      if (session.navidromeDetailStack.isNotEmpty) {
        ref.read(activeRemoteSessionProvider.notifier).popNavidromeDetail();
        return true;
      }
      if (session.webDavPathStack.isNotEmpty) {
        ref.read(activeRemoteSessionProvider.notifier).popWebDavPath();
        return true;
      }
      ref.read(activeRemoteSessionProvider.notifier).clear();
      return true;
    }
    final scanner = _scanner;
    if (scanner == null) return false;
    if (scanner.navigationCurrentFolder != null) {
      _goBack(scanner);
      return true;
    }
    return false;
  }

  void _setFolderSelectionMode(bool enabled) {
    _librarySelectionScopeController.setScope(
      enabled ? LibrarySelectionScope.folder : LibrarySelectionScope.none,
    );
  }

  bool _isUserRootSelectionContext(
    ScannerService scanner,
    MusicFolder? currentFolder,
    List<MusicFolder> navigationHistory,
  ) {
    if (currentFolder == null) return false;

    final rootPaths = scanner.rootFolders.map((folder) => folder.path).toSet();
    rootPaths.add('system');
    if (rootPaths.contains(currentFolder.path)) {
      return true;
    }

    if (navigationHistory.isNotEmpty) {
      final rootFolder = navigationHistory.first;
      if (rootPaths.contains(rootFolder.path)) {
        return true;
      }
    }

    return false;
  }

  List<MusicFolder>? _findFolderHistoryByFolderPath(
    MusicFolder root,
    String targetFolderPath,
  ) {
    List<MusicFolder>? recurse(MusicFolder folder) {
      if (ScannerPathUtils.pathsEqual(folder.path, targetFolderPath)) {
        return [folder];
      }
      for (final sub in folder.subFolders) {
        final res = recurse(sub);
        if (res != null) {
          return [folder, ...res];
        }
      }
      return null;
    }

    return recurse(root);
  }

  Future<void> _navigateTo(MusicFolder folder, ScannerService scanner) async {
    final rootPath = scanner.rootPaths.firstWhereOrNull(
      (root) => ScannerPathUtils.pathContains(root, folder.path),
    );

    if (rootPath != null) {
      await scanner.loadRootFolderSongs(rootPath);
      final rootFolder = scanner.rootFolders.firstWhereOrNull(
        (r) => ScannerPathUtils.pathsEqual(r.path, rootPath),
      );
      if (rootFolder != null) {
        final foundHistory = _findFolderHistoryByFolderPath(
          rootFolder,
          folder.path,
        );
        if (foundHistory != null && foundHistory.isNotEmpty) {
          final targetFolder = foundHistory.last;
          final history = foundHistory.sublist(0, foundHistory.length - 1);
          scanner.setNavigationState(targetFolder, history);
          _clearAllSelection();
          _setFolderSelectionMode(false);
          return;
        }
      }
    } else if (folder.path == 'system' ||
        ScannerPathUtils.pathContains('system', folder.path)) {
      if (scanner.systemMediaFolder != null) {
        final foundHistory = _findFolderHistoryByFolderPath(
          scanner.systemMediaFolder!,
          folder.path,
        );
        if (foundHistory != null && foundHistory.isNotEmpty) {
          final targetFolder = foundHistory.last;
          final history = foundHistory.sublist(0, foundHistory.length - 1);
          scanner.setNavigationState(targetFolder, history);
          _clearAllSelection();
          _setFolderSelectionMode(false);
          return;
        }
      }
    }

    final history = List<MusicFolder>.from(scanner.navigationHistory);
    if (scanner.navigationCurrentFolder != null) {
      history.add(scanner.navigationCurrentFolder!);
    }
    scanner.setNavigationState(folder, history);
    _clearAllSelection();
    _setFolderSelectionMode(false);
  }

  void _goBack(ScannerService scanner) {
    if (scanner.navigationHistory.isEmpty) {
      scanner.setNavigationState(null, []);
    } else {
      final history = List<MusicFolder>.from(scanner.navigationHistory);
      final folder = history.removeLast();
      scanner.setNavigationState(folder, history);
    }
    _clearAllSelection();
    _setFolderSelectionMode(false);
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedSongPaths.clear();
        _selectedFolderPaths.clear();
        _librarySelectionScopeController.clear();
      } else {
        _librarySelectionScopeController.setScope(LibrarySelectionScope.folder);
      }
    });

    final scanner = _scanner;
    if (scanner == null) return;

    _setFolderSelectionMode(
      _isSelectionMode &&
          _isUserRootSelectionContext(
            scanner,
            scanner.navigationCurrentFolder,
            scanner.navigationHistory,
          ),
    );
  }

  void _toggleRootSortMode() {
    setState(() {
      _isRootSortMode = !_isRootSortMode;
      if (_isRootSortMode) {
        _isSelectionMode = false;
        _selectedSongPaths.clear();
        _selectedFolderPaths.clear();
        _selectedRootPaths.clear();
        _setFolderSelectionMode(false);
        _librarySelectionScopeController.clear();
      }
    });
  }

  void _toggleRootSelectionMode() {
    if (_isRootSortMode) {
      setState(() {
        _isRootSortMode = false;
      });
    }
    final enabled =
        ref.read(librarySelectionScopeProvider) !=
        LibrarySelectionScope.folderRoot;
    _librarySelectionScopeController.setScope(
      enabled ? LibrarySelectionScope.folderRoot : LibrarySelectionScope.none,
    );
    if (!enabled) {
      setState(() {
        _selectedRootPaths.clear();
      });
    }
  }

  void _clearAllSelection({bool clearSortMode = true}) {
    final shouldClearSongSelection =
        _isSelectionMode ||
        _selectedSongPaths.isNotEmpty ||
        _selectedFolderPaths.isNotEmpty;
    final isRootSelectionMode =
        ref.read(librarySelectionScopeProvider) ==
        LibrarySelectionScope.folderRoot;
    final shouldClearRootSelection =
        isRootSelectionMode || _selectedRootPaths.isNotEmpty;
    if (!shouldClearSongSelection &&
        !shouldClearRootSelection &&
        (!clearSortMode || !_isRootSortMode)) return;

    setState(() {
      _isSelectionMode = false;
      _selectedSongPaths.clear();
      _selectedFolderPaths.clear();
      _selectedRootPaths.clear();
      if (clearSortMode) {
        _isRootSortMode = false;
      }
    });
    _setFolderSelectionMode(false);
    _librarySelectionScopeController.clear();
  }

  List<MusicFolder>? _findFolderHistory(MusicFolder root, String songPath) {
    List<MusicFolder>? recurse(MusicFolder folder) {
      for (final file in folder.files) {
        if (p.equals(file.path, songPath)) {
          return [folder];
        }
      }
      for (final sub in folder.subFolders) {
        final res = recurse(sub);
        if (res != null) {
          return [folder, ...res];
        }
      }
      return null;
    }

    return recurse(root);
  }

  Future<void> _locateCurrentSong() async {
    final currentMusic = ref.read(audioCurrentMusicProvider);
    if (currentMusic == null) return;
    final l10n = AppLocalizations.of(context)!;
    final songPath = currentMusic.path;

    final remoteInfo = RemoteMediaResolver.parseUri(songPath);
    if (remoteInfo != null) {
      final servers = ref.read(remoteServersProvider).asData?.value ?? [];
      final server = servers.firstWhereOrNull((s) => s.id == remoteInfo.serverId);
      if (server == null) {
        showToast(l10n.songNotInScannedFolders);
        return;
      }
      final password = await ref.read(remoteServersProvider.notifier).getPassword(server.id) ?? '';

      if (remoteInfo.type == RemoteServerType.webdav) {
        final targetDir = p.posix.dirname(remoteInfo.trackIdOrPath);
        final rootPath = server.customPath?.trim().isNotEmpty == true
            ? server.customPath!
            : '/';
        final stack =
            ActiveRemoteSession.buildWebDavPathStack(rootPath, targetDir);
        final activeSession = ref.read(activeRemoteSessionProvider);
        if (activeSession == null || activeSession.server.id != server.id) {
          ref.read(activeRemoteSessionProvider.notifier).setSession(
                ActiveRemoteSession(
                  server: server,
                  password: password,
                  rootPath: rootPath,
                  initialPath: targetDir,
                  webDavPathStack: stack,
                  webDavHighlightedSongPath: songPath,
                ),
              );
        } else {
          ref.read(activeRemoteSessionProvider.notifier).setWebDavLocation(
                pathStack: stack,
                highlightedSongPath: songPath,
              );
        }
        return;
      } else if (remoteInfo.type == RemoteServerType.subsonic) {
        try {
          final client = SubsonicClient(server: server, password: password);
          final songData = await client.getSong(remoteInfo.trackIdOrPath);
          if (songData != null && mounted) {
            final albumId =
                songData['albumId'] as String? ?? songData['parent'] as String?;
            final albumName = songData['album'] as String? ?? 'Album';
            final artistName = songData['artist'] as String?;
            final coverArtId = songData['coverArt'] as String?;
            if (albumId != null) {
              final activeSession = ref.read(activeRemoteSessionProvider);
              if (activeSession == null ||
                  activeSession.server.id != server.id) {
                ref.read(activeRemoteSessionProvider.notifier).setSession(
                      ActiveRemoteSession(
                        server: server,
                        password: password,
                        navidromeDetailStack: [
                          NavidromeAlbumRoute(
                            albumId: albumId,
                            albumName: albumName,
                            artistName: artistName,
                            coverArtId: coverArtId,
                            highlightedSongPath: songPath,
                          ),
                        ],
                      ),
                    );
              } else {
                NavidromeNavUtils.openAlbum(
                  context,
                  ref,
                  server: server,
                  password: password,
                  albumId: albumId,
                  albumName: albumName,
                  artistName: artistName,
                  coverArtId: coverArtId,
                  highlightedSongPath: songPath,
                );
              }
              return;
            }
          }
        } catch (_) {}
        showToast(l10n.songNotInScannedFolders);
        return;
      }
    }

    final scanner = ref.read(scannerServiceProvider);
    List<MusicFolder>? foundHistory;

    for (final root in scanner.rootFolders) {
      foundHistory = _findFolderHistory(root, songPath);
      if (foundHistory != null) {
        break;
      }
    }

    if (foundHistory == null && scanner.systemMediaFolder != null) {
      foundHistory = _findFolderHistory(
        scanner.systemMediaFolder!,
        songPath,
      );
    }

    if (foundHistory == null) {
      final songMeta = await scanner.getSongMetadata(songPath);
      final isSystemMedia = songMeta != null &&
          ((songMeta.sourceFlags ?? 0) & SongSourceFlags.systemMedia) != 0;

      if (!isSystemMedia) {
        final matchingRootPath = scanner.rootPaths.firstWhereOrNull(
          (root) => ScannerPathUtils.pathContains(root, songPath),
        );
        if (matchingRootPath != null) {
          await scanner.loadRootFolderSongs(matchingRootPath);
        } else {
          for (final rootPath in scanner.rootPaths) {
            await scanner.loadRootFolderSongs(rootPath);
          }
        }
      }

      for (final root in scanner.rootFolders) {
        foundHistory = _findFolderHistory(root, songPath);
        if (foundHistory != null) {
          break;
        }
      }

      if (foundHistory == null && scanner.systemMediaFolder != null) {
        foundHistory = _findFolderHistory(
          scanner.systemMediaFolder!,
          songPath,
        );
      }
    }

    if (!mounted) return;

    if (foundHistory != null && foundHistory.isNotEmpty) {
      final targetFolder = foundHistory.last;
      final history = foundHistory.sublist(0, foundHistory.length - 1);
      final alreadyInFolder =
          scanner.navigationCurrentFolder?.path == targetFolder.path;

      if (!alreadyInFolder) {
        scanner.setNavigationState(targetFolder, history);
      }

      setState(() {
        _highlightedSongPath = currentMusic.path;
      });

      _highlightTimer?.cancel();
      _highlightTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _highlightedSongPath = null;
          });
        }
      });
    } else {
      showToast(AppLocalizations.of(context)!.songNotInScannedFolders);
    }
  }

  void _ensureScanToastVisible() {
    if (!ref.read(settingsServiceProvider).showScanProgressToast) return;
    if (_scanToast?.mounted == true) return;

    final l10n = _l10n;
    if (l10n == null) return;
    _scanToastState.value = const ScanToastState(
      fileName: '',
      discoveredLabelText: '',
      preprocessedLabelText: '',
      completedLabelText: '',
    );
    _scanToast = showToastWidget(
      ScanProgressToast(
        stateListenable: _scanToastState,
        label: l10n.scanningDirectory,
        onClose: () {
          _dismissScanToast();
          ref.read(settingsServiceProvider).showScanProgressToast = false;
          final currentL10n = AppLocalizations.of(context);
          if (currentL10n != null) {
            AppSnackBar.show(
              context,
              ref,
              SnackBar(content: Text(currentL10n.scanToastHiddenHint)),
            );
          }
        },
      ),
      position: ToastPosition.top.copyWith(offset: 28),
      duration: const Duration(days: 1),
      dismissOtherToast: true,
      animationDuration: const Duration(milliseconds: 180),
      handleTouch: true,
    );
  }

  void _dismissScanToast({bool notifyListeners = true}) {
    _scanToastUpdateTimer?.cancel();
    _scanToastUpdateTimer = null;
    _scanToastAutoDismissTimer?.cancel();
    _scanToastAutoDismissTimer = null;
    _pendingScanProgress = null;
    _lastScanToastUpdateAt = null;
    _scanToast?.dismiss(showAnim: false);
    _scanToast = null;
    if (notifyListeners) {
      _scanToastState.value = null;
    }
  }

  void _handleScannerChanged() {
    final scanner = _scanner;
    if (scanner == null) return;
    final isScanning = scanner.isScanning;
    if (_wasScanning && !isScanning) {
      _dismissScanToast();
    }
    _wasScanning = isScanning;
  }

  void _showScanProgressToast(ScanProgress progress) {
    if (!mounted) return;
    if (!ref.read(settingsServiceProvider).showScanProgressToast) return;

    _pendingScanProgress = progress;

    final now = DateTime.now();
    final lastUpdate = _lastScanToastUpdateAt;
    final elapsed = lastUpdate == null ? null : now.difference(lastUpdate);

    if (_scanToastUpdateTimer?.isActive ?? false) {
      return;
    }

    if (elapsed == null || elapsed >= const Duration(seconds: 1)) {
      _flushPendingScanProgress();
      return;
    }

    _scanToastUpdateTimer = Timer(const Duration(seconds: 1) - elapsed, () {
      _scanToastUpdateTimer = null;
      if (!mounted) return;
      _flushPendingScanProgress();
    });
  }

  void _flushPendingScanProgress() {
    final progress = _pendingScanProgress;
    final l10n = _l10n;
    if (progress == null || l10n == null) return;

    _pendingScanProgress = null;
    _ensureScanToastVisible();
    _scanToastState.value = ScanToastState(
      fileName: p.basename(progress.filePath),
      discoveredLabelText: l10n.filesDiscovered(progress.discoveredCount),
      preprocessedLabelText: l10n.filesPreprocessed(progress.preprocessedCount),
      completedLabelText: l10n.filesFullyProcessed(progress.completedCount),
    );
    _lastScanToastUpdateAt = DateTime.now();
    _scheduleScanToastAutoDismiss();
  }

  void _scheduleScanToastAutoDismiss() {
    _scanToastAutoDismissTimer?.cancel();
    _scanToastAutoDismissTimer = Timer(const Duration(seconds: 2), () {
      _scanToastAutoDismissTimer = null;
      if (!mounted) return;

      final scanner = _scanner;
      if (scanner != null && scanner.isScanning) {
        _scheduleScanToastAutoDismiss();
        return;
      }

      _dismissScanToast();
    });
  }

  void _toggleSelection(String path) {
    setState(() {
      if (_selectedSongPaths.contains(path)) {
        _selectedSongPaths.remove(path);
      } else {
        _selectedSongPaths.add(path);
      }
      if (_selectedSongPaths.isEmpty && _selectedFolderPaths.isEmpty) {
        _isSelectionMode = false;
        _librarySelectionScopeController.clear();
      } else {
        _librarySelectionScopeController.setScope(LibrarySelectionScope.folder);
      }
    });
  }

  void _toggleFolderSelection(String path) {
    setState(() {
      if (_selectedFolderPaths.contains(path)) {
        _selectedFolderPaths.remove(path);
      } else {
        _selectedFolderPaths.add(path);
      }
      if (_selectedSongPaths.isEmpty && _selectedFolderPaths.isEmpty) {
        _isSelectionMode = false;
        _librarySelectionScopeController.clear();
      } else {
        _librarySelectionScopeController.setScope(LibrarySelectionScope.folder);
      }
    });
  }

  void _selectAllVisible(MusicFolder currentFolder) {
    _librarySelectionScopeController.setScope(LibrarySelectionScope.folder);
    setState(() {
      _selectedSongPaths
        ..clear()
        ..addAll(currentFolder.files.map((file) => file.path));
      _selectedFolderPaths
        ..clear()
        ..addAll(currentFolder.subFolders.map((folder) => folder.path));
      _isSelectionMode = true;
    });

    final scanner = _scanner;
    if (scanner == null) return;

    _setFolderSelectionMode(
      _isUserRootSelectionContext(
        scanner,
        scanner.navigationCurrentFolder,
        scanner.navigationHistory,
      ),
    );
  }

  void _toggleRootSelection(String path) {
    setState(() {
      if (_selectedRootPaths.contains(path)) {
        _selectedRootPaths.remove(path);
      } else {
        _selectedRootPaths.add(path);
      }
    });
  }

  Future<void> _deleteSelectedRootFolders(ScannerService scanner) async {
    if (_selectedRootPaths.isEmpty) return;

    final selectedCount = _selectedRootPaths.length;
    final l10n = AppLocalizations.of(context)!;
    final paths = _selectedRootPaths.toList(growable: false);
    await scanner.removeRootPaths(paths);
    if (!mounted) return;

    setState(() {
      _selectedRootPaths.clear();
    });
    _librarySelectionScopeController.clear();

    AppSnackBar.show(
      context,
      ref,
      SnackBar(content: Text(l10n.foldersDeleted(selectedCount))),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context);
  }

  @override
  void initState() {
    super.initState();
    _heroController = HeroController();
    _librarySelectionScopeController = ref.read(
      librarySelectionScopeProvider.notifier,
    );
    _scanner = ref.read(scannerServiceProvider);
    _wasScanning = _scanner!.isScanning;
    _scanner!.addListener(_handleScannerChanged);
    _scanProgressSubscription = _scanner!.scanProgressStream.listen(
      _showScanProgressToast,
    );
  }

  @override
  void dispose() {
    Future.microtask(() {
      if (!mounted) return;
      _setFolderSelectionMode(false);
      _librarySelectionScopeController.clear();
    });
    _scanToastUpdateTimer?.cancel();
    _scanToastAutoDismissTimer?.cancel();
    _highlightTimer?.cancel();
    _scanProgressSubscription?.cancel();
    _scanner?.removeListener(_handleScannerChanged);
    _dismissScanToast(notifyListeners: false);
    _scanToastState.dispose();
    super.dispose();
  }

  Future<String?> _getDirectoryPath() {
    return FileSelectorHelper.pickDirectory();
  }

  Future<void> _pickFolder(ScannerService scanner) async {
    Directory? cwd;
    try {
      cwd = Directory.current;
    } catch (_) {}

    String? selectedDirectory;
    String? persistentDocumentId;
    AndroidOutputDirectory? androidOutputDirectory;

    if (Platform.isAndroid) {
      androidOutputDirectory = await ref
          .read(transcodeServiceProvider)
          .pickAndroidOutputDirectory();
      selectedDirectory = androidOutputDirectory?.displayPath;
    } else if (Platform.isLinux && await LinuxDirectoryAccess().isFlatpak) {
      final grant = await LinuxDirectoryAccess().pickDirectory();
      selectedDirectory = grant?.path;
      persistentDocumentId = grant?.documentId;
    } else {
      selectedDirectory = await _getDirectoryPath();
    }

    debugPrint(
      '[FoldersPage] directory picker returned '
      'hasSelection=${selectedDirectory != null}',
    );

    if (cwd != null) {
      try {
        Directory.current = cwd;
      } catch (_) {}
    }

    if (selectedDirectory != null) {
      if (!mounted) return;

      if (Platform.isWindows) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (Platform.isAndroid && androidOutputDirectory != null) {
        await AndroidSafStorageHelper.saveMapping(
          androidOutputDirectory.displayPath,
          androidOutputDirectory.treeUri,
        );
      }

      debugPrint('[FoldersPage] adding selected root path=$selectedDirectory');
      final result = await scanner.addRootPath(
        selectedDirectory,
        persistentDocumentId: persistentDocumentId,
      );
      debugPrint(
        '[FoldersPage] add root path completed status=${result.status}',
      );

      if (!mounted) return;
      String message;
      switch (result.status) {
        case RootPathAddStatus.added:
        case RootPathAddStatus.alreadyAdded:
          if (Platform.isAndroid && !scanner.hasPermission) {
            message = '${AppLocalizations.of(context)!.directoryAddedSuccess}${AppLocalizations.of(context)!.safFallbackScanningNotice}';
          } else {
            message = AppLocalizations.of(context)!.directoryAddedSuccess;
          }
          break;
        case RootPathAddStatus.noMusic:
          message = AppLocalizations.of(context)!.directoryAddedNoMusic;
          break;
        case RootPathAddStatus.persistentAccessDenied:
          message = AppLocalizations.of(context)!.persistentAccessDenied;
          break;
        case RootPathAddStatus.failed:
          message = AppLocalizations.of(context)!.folderAddFailed;
          break;
      }
      AppSnackBar.show(context, ref, SnackBar(content: Text(message)));
    }
  }

  Page<dynamic> _buildPage({
    required LocalKey key,
    required Widget child,
  }) {
    if (Platform.isIOS || Platform.isMacOS) {
      return CupertinoPage<dynamic>(
        key: key,
        child: child,
      );
    }
    return MaterialPage<dynamic>(
      key: key,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanner = ref.read(scannerServiceProvider);
    final navigationHistory = ref.watch(
      scannerServiceProvider.select((scanner) => scanner.navigationHistory),
    );
    final currentFolder = ref.watch(
      scannerServiceProvider.select(
        (scanner) => scanner.navigationCurrentFolder,
      ),
    );

    if (Platform.isAndroid &&
        currentFolder?.path == 'system' &&
        scanner.systemMediaFolder != null &&
        currentFolder != scanner.systemMediaFolder) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          scanner.setNavigationState(
            scanner.systemMediaFolder!,
            List.from(navigationHistory),
          );
        }
      });
    }

    final seenPaths = <String>{};
    final pages = <Page<dynamic>>[
      _buildPage(
        key: const ValueKey('folder-root-page'),
        child: FolderRootView(
          onOpenPlayback: widget.onOpenPlayback,
          isSelectionMode: _isSelectionMode,
          isSortMode: _isRootSortMode,
          selectedRootPaths: _selectedRootPaths,
          onPickFolder: () => _pickFolder(scanner),
          onToggleRootSelection: _toggleRootSelection,
          onToggleRootSelectionMode: _toggleRootSelectionMode,
          onToggleSortMode: _toggleRootSortMode,
          onDeleteSelectedRootFolders: () =>
              _deleteSelectedRootFolders(scanner),
          onNavigateTo: (folder) => _navigateTo(folder, scanner),
          onLocateCurrentSong: _locateCurrentSong,
          onShowFolderBottomSheet: (folder, {required isRoot}) =>
              showFolderBottomSheet(
                context,
                ref,
                folder,
                isRoot: isRoot,
                onMultiSelect: (path) {
                  setState(() {
                    _selectedRootPaths.add(path);
                  });
                },
              ),
          onShowFolderContextMenu: (folder, position, {required isRoot}) =>
              showFolderContextMenu(
                context: context,
                globalPosition: position,
                ref: ref,
                folder: folder,
                isRoot: isRoot,
                onMultiSelect: (path) {
                  setState(() {
                    _selectedRootPaths.add(path);
                  });
                },
              ),
        ),
      ),
    ];

    for (int i = 0; i < navigationHistory.length; i++) {
      final folder = navigationHistory[i];
      if (seenPaths.add(folder.path)) {
        pages.add(
          _buildPage(
            key: ValueKey('folder-page-${folder.path}'),
            child: FolderDetailView(
              folder: folder,
              onOpenPlayback: widget.onOpenPlayback,
              isSelectionMode: _isSelectionMode,
              selectedSongPaths: _selectedSongPaths,
              selectedFolderPaths: _selectedFolderPaths,
              onNavigateTo: (folder) => _navigateTo(folder, scanner),
              onGoBack: () => _goBack(scanner),
              onToggleSelectionMode: _toggleSelectionMode,
              onToggleFolderSelection: _toggleFolderSelection,
              onToggleSelection: _toggleSelection,
              onSelectAllVisible: () => _selectAllVisible(folder),
              onClearAllSelection: _clearAllSelection,
              onLocateCurrentSong: _locateCurrentSong,
              onShowFolderBottomSheet: (folder, {required isRoot}) =>
                  showFolderBottomSheet(
                    context,
                    ref,
                    folder,
                    isRoot: isRoot,
                    onMultiSelect: (path) {
                      setState(() {
                        _selectedRootPaths.add(path);
                      });
                    },
                  ),
              onShowFolderContextMenu: (folder, position, {required isRoot}) =>
                  showFolderContextMenu(
                    context: context,
                    globalPosition: position,
                    ref: ref,
                    folder: folder,
                    isRoot: isRoot,
                    onMultiSelect: (path) {
                      setState(() {
                        _selectedRootPaths.add(path);
                      });
                    },
                  ),
              highlightedSongPath: _highlightedSongPath,
            ),
          ),
        );
      }
    }

    if (currentFolder != null && seenPaths.add(currentFolder.path)) {
      pages.add(
        _buildPage(
          key: ValueKey('folder-page-${currentFolder.path}'),
          child: FolderDetailView(
            folder: currentFolder,
            onOpenPlayback: widget.onOpenPlayback,
            isSelectionMode: _isSelectionMode,
            selectedSongPaths: _selectedSongPaths,
            selectedFolderPaths: _selectedFolderPaths,
            onNavigateTo: (folder) => _navigateTo(folder, scanner),
            onGoBack: () => _goBack(scanner),
            onToggleSelectionMode: _toggleSelectionMode,
            onToggleFolderSelection: _toggleFolderSelection,
            onToggleSelection: _toggleSelection,
            onSelectAllVisible: () => _selectAllVisible(currentFolder),
            onClearAllSelection: _clearAllSelection,
            onLocateCurrentSong: _locateCurrentSong,
            onShowFolderBottomSheet: (folder, {required isRoot}) =>
                showFolderBottomSheet(
                  context,
                  ref,
                  folder,
                  isRoot: isRoot,
                  onMultiSelect: (path) {
                    setState(() {
                      _selectedRootPaths.add(path);
                    });
                  },
                ),
            onShowFolderContextMenu: (folder, position, {required isRoot}) =>
                showFolderContextMenu(
                  context: context,
                  globalPosition: position,
                  ref: ref,
                  folder: folder,
                  isRoot: isRoot,
                  onMultiSelect: (path) {
                    setState(() {
                      _selectedRootPaths.add(path);
                    });
                  },
                ),
            highlightedSongPath: _highlightedSongPath,
          ),
        ),
      );
    }

    final activeRemoteSessionId = ref.watch(
      activeRemoteSessionProvider.select(
        (s) => s != null ? '${s.server.id}_${s.server.type}' : null,
      ),
    );
    final activeRemoteSession = ref.read(activeRemoteSessionProvider);
    final navidromeDetailStack = ref.watch(
      activeRemoteSessionProvider.select(
        (s) => s?.navidromeDetailStack ?? const [],
      ),
    );
    final webDavPathStack = ref.watch(
      activeRemoteSessionProvider.select(
        (s) => s?.webDavPathStack ?? const [],
      ),
    );

    if (activeRemoteSessionId != null && activeRemoteSession != null) {
      if (activeRemoteSession.server.type == RemoteServerType.subsonic) {
        pages.add(
          _buildPage(
            key: ValueKey('remote-page-${activeRemoteSession.server.id}'),
            child: NavidromeLibraryPage(
              server: activeRemoteSession.server,
              password: activeRemoteSession.password,
              initialTabIndex: activeRemoteSession.initialTabIndex,
            ),
          ),
        );

        for (int i = 0; i < navidromeDetailStack.length; i++) {
          final route = navidromeDetailStack[i];
          if (route is NavidromeAlbumRoute) {
            pages.add(
              _buildPage(
                key: ValueKey('remote-album-${route.albumId}-$i'),
                child: NavidromeAlbumDetailPage(
                  server: activeRemoteSession.server,
                  password: activeRemoteSession.password,
                  albumId: route.albumId,
                  albumName: route.albumName,
                  artistName: route.artistName,
                  coverArtId: route.coverArtId,
                  highlightedSongPath: route.highlightedSongPath,
                ),
              ),
            );
          } else if (route is NavidromeArtistRoute) {
            pages.add(
              _buildPage(
                key: ValueKey(
                    'remote-artist-${route.artistId}_${route.artistName}-$i'),
                child: NavidromeArtistDetailPage(
                  server: activeRemoteSession.server,
                  password: activeRemoteSession.password,
                  artistId: route.artistId,
                  artistName: route.artistName,
                  coverArtId: route.coverArtId,
                  albumCount: route.albumCount,
                ),
              ),
            );
          } else if (route is NavidromePlaylistRoute) {
            pages.add(
              _buildPage(
                key: ValueKey('remote-playlist-${route.playlistId}-$i'),
                child: NavidromePlaylistDetailPage(
                  server: activeRemoteSession.server,
                  password: activeRemoteSession.password,
                  playlistId: route.playlistId,
                  playlistName: route.playlistName,
                  coverArtId: route.coverArtId,
                  songCount: route.songCount,
                  duration: route.duration,
                  isStarred: route.isStarred,
                  highlightedSongPath: route.highlightedSongPath,
                ),
              ),
            );
          }
        }
      } else {
        final rootPath = activeRemoteSession.rootPath ??
            (activeRemoteSession.server.customPath?.trim().isNotEmpty == true
                ? activeRemoteSession.server.customPath!
                : '/');

        pages.add(
          _buildPage(
            key: ValueKey('webdav-root-${activeRemoteSession.server.id}'),
            child: WebDavBrowserPage(
              server: activeRemoteSession.server,
              password: activeRemoteSession.password,
              initialPath: rootPath,
              rootPath: rootPath,
              highlightedSongPath: webDavPathStack.isEmpty
                  ? activeRemoteSession.webDavHighlightedSongPath
                  : null,
            ),
          ),
        );

        for (int i = 0; i < webDavPathStack.length; i++) {
          final currentPath = webDavPathStack[i];
          final isTopPage = i == webDavPathStack.length - 1;
          pages.add(
            _buildPage(
              key: ValueKey(
                  'webdav-page-${activeRemoteSession.server.id}-$currentPath-$i'),
              child: WebDavBrowserPage(
                server: activeRemoteSession.server,
                password: activeRemoteSession.password,
                initialPath: currentPath,
                rootPath: rootPath,
                highlightedSongPath: isTopPage
                    ? activeRemoteSession.webDavHighlightedSongPath
                    : null,
              ),
            ),
          );
        }
      }
    }

    return Navigator(
      key: _navigatorKey,
      pages: pages,
      observers: [_heroController],
      onDidRemovePage: (page) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final pageKeyStr = page.key?.toString() ?? '';
          if (pageKeyStr.contains('webdav-page-')) {
            ref.read(activeRemoteSessionProvider.notifier).popWebDavPath();
          } else if (pageKeyStr.contains('webdav-root-') ||
              pageKeyStr.contains('remote-page-')) {
            ref.read(activeRemoteSessionProvider.notifier).clear();
          } else if (pageKeyStr.contains('remote-album-') ||
              pageKeyStr.contains('remote-artist-') ||
              pageKeyStr.contains('remote-playlist-')) {
            ref.read(activeRemoteSessionProvider.notifier).popNavidromeDetail();
          } else if (pageKeyStr.contains('folder-page-')) {
            _goBack(scanner);
          }
        });
      },
    );
  }
}
