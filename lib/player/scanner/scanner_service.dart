import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:audio_core/audio_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_storage_listener/mobile_storage_event.dart';
import 'package:mobile_storage_listener/mobile_storage_listener.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/scanner/scanner_navigation_state.dart';
import 'package:vynody/player/scanner/scanner_path_utils.dart';
import 'package:vynody/player/scanner/scanner_sorting.dart';
import 'package:vynody/player/scanner/scanner_scan_pipeline.dart';
import 'package:vynody/player/scanner/scanner_scan_coordinator.dart';
import 'package:vynody/player/scanner/scanner_directory_scanner.dart';
import 'package:vynody/player/scanner/scanner_metadata_store.dart';
import 'package:vynody/player/scanner/scanner_repository.dart';
import 'package:vynody/player/scanner/scanner_state.dart';
import 'package:vynody/player/scanner/scanner_tree_builder.dart';
import 'package:vynody/player/scanner/scanner_service_roots.dart';
import 'package:vynody/player/scanner/scanner_scan_support.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:vynody/player/metadata/artwork_constants.dart';
import 'package:vynody/player/library/music_file_utils.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/player/settings/track_artwork_theme_service.dart';
import 'package:vynody/utils/localized_text.dart';
import 'package:vynody/utils/linux_mount_helper.dart';
import 'package:vynody/utils/folder_helpers.dart';
import 'package:linux_directory_access/linux_directory_access.dart';

export 'package:vynody/player/scanner/scanner_scan_support.dart';

AppLocalizations _l10n() => currentAppL10n;

enum _DirectoryRescanMode { nonRecursive, recursive }

class ScannerService extends ChangeNotifier with WidgetsBindingObserver {
  final ScannerFolderSorter _folderSorter = const ScannerFolderSorter();
  final Duration _directoryRescanBatchWindow;
  final Completer<void> _readyCompleter = Completer<void>();
  AudioCoreController? _playerController;
  void Function(String path, bool isMissing)? _songMissingStateHandler;
  StreamSubscription? _mediaObserverSubscription;
  bool _mediaObserverPaused = false;
  final MobileStorageListener _mobileStorageListener = MobileStorageListener();
  final LinuxDirectoryAccess _linuxDirectoryAccess = LinuxDirectoryAccess();
  StreamSubscription<MobileStorageEvent>? _mobileStorageSubscription;
  final StreamController<ScanProgress> _scanProgressController =
      StreamController<ScanProgress>.broadcast();
  final ScannerNavigationState _navigationState = ScannerNavigationState();
  final List<MusicFolder> _scannedRootFolders = [];
  final List<MusicFolder> _rootFolders = [];
  final Map<String, bool> _rootAvailability = {};
  final List<SongMetadata> _pendingStage3IncrementalMetadata = [];
  Timer? _metadataNotifyTimer;
  Timer? _scanNotifyTimer;
  Timer? _rootAvailabilityRefreshTimer;
  Timer? _rootAvailabilityTimer;
  Timer? _directoryRescanTimer;
  bool _scanNotifyPending = false;
  bool _lastNotifiedScanningState = false;
  bool _pendingRootAvailabilityRescan = false;
  bool _directoryRescanInProgress = false;
  bool _isDisposed = false;
  final Set<String> _activeScopedRootPaths = <String>{};
  final Map<String, _DirectoryRescanMode> _pendingDirectoryRescanPaths = {};
  final Set<String> _failedThumbnailPaths = <String>{};
  final Map<String, int> _watchedFileMtimes = {};

  MusicFolder? _systemMediaFolder;
  bool _hasPermission = false;
  late final ScannerServiceRoots _roots;
  late final ScannerMetadataStore _metadataStore;
  late final ScannerScanPipeline _scanPipeline;
  late final ScannerRepository _repository;
  late final ScannerScanCoordinator _scanCoordinator;
  late final ScannerTreeBuilder _treeBuilder;
  late final ScannerDirectoryScanner _directoryScanner;
  int _metadataRevision = 0;
  int _albumLibraryRevision = 0;
  bool _skipShortAudioScanEnabled = false;
  int _skipShortAudioScanThresholdSeconds = _defaultShortAudioThresholdSeconds;
  bool _linuxFlatpak = false;
  final Map<String, String> _linuxDocumentIds = {};
  final Map<String, int> _rootSongCounts = {};
  final Map<String, int> _rootSongDurations = {};
  final Map<String, SongMetadata?> _rootRepresentativeSongs = {};
  final Set<String> _loadedRootPaths = {};

  static const String _keyGlobalSortCriteria = 'folder_sort_global_criteria';
  static const String _keyGlobalSortOrder = 'folder_sort_global_order';
  static const String _keyFolderSortOverrides = 'folder_sort_overrides';
  static const int _defaultShortAudioThresholdSeconds = 30;
  static const bool _scanTimingEnabled = true;
  static const Duration _defaultDirectoryRescanBatchWindow = Duration(
    milliseconds: 900,
  );

  SortCriteria _globalSortCriteria = SortCriteria.filename;
  SortOrder _globalSortOrder = SortOrder.ascending;
  Map<String, FolderSortSettings> _folderSortOverrides = {};

  SortCriteria get sortCriteria => _currentSortSettings.criteria;
  SortOrder get sortOrder => _currentSortSettings.order;
  SortCriteria get globalSortCriteria => _globalSortCriteria;
  SortOrder get globalSortOrder => _globalSortOrder;
  bool get skipShortAudioScanEnabled => _skipShortAudioScanEnabled;
  int get skipShortAudioScanThresholdSeconds =>
      _skipShortAudioScanThresholdSeconds;
  bool get _supportsPersistentAccess =>
      Platform.isMacOS || Platform.isIOS || _linuxFlatpak;

  List<String> get rootPaths => _roots.rootPaths;
  List<MusicFolder> get rootFolders => List.unmodifiable(_rootFolders);
  bool get isScanning => _scanCoordinator.isScanning;
  bool get isBackgroundTaskPaused => _scanCoordinator.isBackgroundPaused;
  ScannerRuntimeState get runtimeState => _scanCoordinator.state;
  Stream<ScanProgress> get scanProgressStream => _scanProgressController.stream;

  // Navigation state for FoldersPage
  MusicFolder? get navigationCurrentFolder => _navigationState.currentFolder;

  List<MusicFolder> get navigationHistory => _navigationState.history;

  void setNavigationState(MusicFolder? current, List<MusicFolder> history) {
    if (kDebugMode) {
      debugPrint(
        '[ScannerService][timing] setNavigationState current=${current?.path ?? "null"} '
        'history=${history.length}',
      );
    }
    _navigationState.setState(current, history);

    if (current != null) {
      final normalizedPath = _normalizePath(current.path);
      if (normalizedPath != 'system') {
        final rootPath = _roots.rootPaths.firstWhereOrNull(
          (root) => _pathsEqual(root, normalizedPath) || _pathContains(root, normalizedPath),
        );
        if (rootPath != null) {
          unawaited(loadRootFolderSongs(rootPath));
        }
      }
    } else {
      unloadAllRootFolders();
    }
  }

  Future<void> loadRootFolderSongs(String rootPath) async {
    final normalized = _normalizePath(rootPath);
    if (_loadedRootPaths.contains(normalized)) return;

    final songs = await _repository.getSongsUnderPath(normalized);
    final cachedFolder = _buildCachedFolderTree(
      songs: songs,
      rootPath: normalized,
      rootName: _displayNameForPath(normalized),
    );
    if (cachedFolder != null) {
      _folderSorter.sortFolderRecursiveForTree(
        cachedFolder,
        resolveSettings: _resolveSortSettingsForFolder,
      );
      _upsertScannedRootFolder(cachedFolder);
      _seedMetadataCache(songs);
      _loadedRootPaths.add(normalized);
      _rebuildDisplayedRootFolders();
      _syncNavigationStateToLatestTree();
      notifyListeners();
    }
  }

  void unloadAllRootFolders() {
    // Keep scanned root folders in memory so root directory covers remain stable.
    return;
  }

  int getSongCountForFolder(MusicFolder folder) {
    if (folder.path == 'system') {
      return _systemMediaFolder?.allSongs.length ?? 0;
    }
    if (folder.allSongs.isNotEmpty) {
      return folder.allSongs.length;
    }
    final normalized = _normalizePath(folder.path);
    return _rootSongCounts[normalized] ?? 0;
  }

  int getSongDurationForFolder(MusicFolder folder) {
    if (folder.path == 'system') {
      return _systemMediaFolder?.allSongs.fold<int>(
        0,
        (sum, song) => sum + (song.durationMillis ?? 0),
      ) ?? 0;
    }
    if (folder.allSongs.isNotEmpty) {
      return folder.allSongs.fold<int>(
        0,
        (sum, song) => sum + (song.durationMillis ?? 0),
      );
    }
    final normalized = _normalizePath(folder.path);
    return _rootSongDurations[normalized] ?? 0;
  }

  final Set<String> _pendingRepresentativeSongFetches = {};

  MusicFile? getRepresentativeSongForFolder(MusicFolder folder) {
    final memoryRep = findRepresentativeSong(folder);
    final normalized = _normalizePath(folder.path);
    final cached = _rootRepresentativeSongs[normalized];

    bool hasArtwork(MusicFile file) =>
        (file.artworkPath != null && file.artworkPath!.isNotEmpty) ||
        (file.thumbnailPath != null && file.thumbnailPath!.isNotEmpty) ||
        (file.artworkBytes != null && file.artworkBytes!.isNotEmpty);

    if (memoryRep != null && hasArtwork(memoryRep)) {
      return memoryRep;
    }

    if (cached != null) {
      final cachedMusicFile = _treeBuilder.musicFileFromSongMetadata(cached);
      if (hasArtwork(cachedMusicFile) || memoryRep == null) {
        return cachedMusicFile;
      }
    }

    if (memoryRep != null) {
      return memoryRep;
    }

    if (!_pendingRepresentativeSongFetches.contains(normalized)) {
      _pendingRepresentativeSongFetches.add(normalized);
      unawaited(_loadRepresentativeSongForPath(normalized));
    }

    return null;
  }

  Future<void> _loadRepresentativeSongForPath(String normalizedPath) async {
    try {
      final sortSettings = _resolveSortSettingsForFolder(normalizedPath);
      final songMeta = await _repository.getRepresentativeSongUnderPath(
        normalizedPath,
        criteria: sortSettings.criteria,
        order: sortSettings.order,
      );
      _rootRepresentativeSongs[normalizedPath] = songMeta;
      if (songMeta != null) {
        _metadataStore.cacheMetadata(songMeta);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ScannerService] Failed to load representative song for $normalizedPath: $e');
    } finally {
      _pendingRepresentativeSongFetches.remove(normalizedPath);
    }
  }

  Future<void> updateSongThumbnailPath(String path, String thumbnailPath) async {
    final existingMeta = _metadataStore.getMetadata(path);
    if (existingMeta != null) {
      if (existingMeta.thumbnailPath != null &&
          existingMeta.thumbnailPath!.isNotEmpty &&
          File(existingMeta.thumbnailPath!).existsSync()) {
        return;
      }
      final updated = existingMeta.copyWith(thumbnailPath: thumbnailPath);
      _metadataStore.cacheMetadata(updated);
      await MetadataDatabase().insertOrUpdateSong(updated);
      notifyListeners();
    } else {
      final db = MetadataDatabase();
      final dbMetadata = await db.getSongMetadata(path);
      if (dbMetadata != null) {
        if (dbMetadata.thumbnailPath != null &&
            dbMetadata.thumbnailPath!.isNotEmpty &&
            File(dbMetadata.thumbnailPath!).existsSync()) {
          return;
        }
        final updated = dbMetadata.copyWith(thumbnailPath: thumbnailPath);
        _metadataStore.cacheMetadata(updated);
        await db.insertOrUpdateSong(updated);
        notifyListeners();
      }
    }
  }


  Future<List<MusicFile>> getAllRootSongs() async {
    final allSongs = <MusicFile>[];
    final seen = <String>{};
    // 1. Load and traverse root folder trees in natural directory order
    for (final root in _roots.rootPaths) {
      await loadRootFolderSongs(root);
    }
    for (final rootFolder in _rootFolders) {
      for (final song in rootFolder.allSongs) {
        if (seen.add(song.path)) {
          allSongs.add(song);
        }
      }
    }
    // 2. Get system media songs
    if (Platform.isAndroid) {
      if (_systemMediaFolder != null) {
        for (final song in _systemMediaFolder!.allSongs) {
          if (seen.add(song.path)) {
            allSongs.add(song);
          }
        }
      }
    }
    return allSongs;
  }

  MusicFolder? resolveFolderForPath(String path) {
    if (path == 'system') return _systemMediaFolder;
    return _treeBuilder.resolveFolderForPath(
      path,
      _scannedRootFolders,
      _systemMediaFolder,
    );
  }

  Future<List<MusicFile>> getSongsForFolder(MusicFolder folder) async {
    if (folder.path == 'system') {
      return _systemMediaFolder?.allSongs ?? const [];
    }

    if (folder.allSongs.isNotEmpty) {
      return folder.allSongs;
    }

    final normalizedPath = _normalizePath(folder.path);
    final rootPath = _roots.rootPaths.firstWhereOrNull(
      (root) => _pathsEqual(root, normalizedPath) || _pathContains(root, normalizedPath),
    );

    if (rootPath != null) {
      await loadRootFolderSongs(rootPath);
      final resolved = resolveFolderForPath(folder.path);
      if (resolved != null && resolved.allSongs.isNotEmpty) {
        return resolved.allSongs;
      }
    }

    final songsFromRepo = await _repository.getSongsUnderPath(normalizedPath);
    return songsFromRepo.map(_treeBuilder.musicFileFromSongMetadata).toList();
  }


  bool isPathInActiveRoots(String path) {
    final normalized = _normalizePath(path);
    if (normalized.isEmpty) return false;

    for (final rootPath in _roots.rootPaths) {
      if (_pathContains(rootPath, normalized)) {
        return true;
      }
    }

    if (_systemMediaFolder != null) {
      if (normalized == 'system' ||
          normalized.startsWith('system/') ||
          normalized.startsWith('system\\') ||
          _pathContains(_systemMediaFolder!.path, normalized)) {
        return true;
      }
      if (_systemMediaFolder!.allSongs.any(
        (s) => _pathsEqual(s.path, normalized),
      )) {
        return true;
      }
    }

    return false;
  }

  Future<List<MusicFile>> searchSongs(
    String query, {
    String? folderPath,
  }) async {
    final songs = await _repository.searchSongs(query, folderPath: folderPath);
    final musicFiles =
        songs.map(_treeBuilder.musicFileFromSongMetadata).toList();
    if (folderPath != null && folderPath.isNotEmpty) {
      return musicFiles;
    }
    return musicFiles.where((file) => isPathInActiveRoots(file.path)).toList();
  }

  Future<SongMetadata?> getSongMetadata(String path) =>
      _repository.getSongMetadata(path);

  Future<List<MusicFolder>> searchFolders(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final matchingPaths = await _repository.searchFolderPaths(trimmed);

    final results = <MusicFolder>[];
    final seenPaths = <String>{};

    final lowercaseQuery = trimmed.toLowerCase();
    for (final root in _rootFolders) {
      if (root.name.toLowerCase().contains(lowercaseQuery)) {
        if (seenPaths.add(root.path)) {
          results.add(root);
        }
      }
    }

    for (final path in matchingPaths) {
      if (!isPathInActiveRoots(path)) continue;
      if (seenPaths.add(path)) {
        final count = await _repository.getSongCountUnderPath(path);
        final sortSettings = _resolveSortSettingsForFolder(path);
        final repSongMeta = await _repository.getRepresentativeSongUnderPath(
          path,
          criteria: sortSettings.criteria,
          order: sortSettings.order,
        );

        final normalized = _normalizePath(path);
        _rootSongCounts[normalized] = count;
        if (repSongMeta != null) {
          _rootRepresentativeSongs[normalized] = repSongMeta;
        }

        results.add(
          MusicFolder(
            path: path,
            name: p.basename(path),
          ),
        );
      }
    }

    return results;
  }

  void pushNavigationHistory(MusicFolder folder) {
    _navigationState.pushHistory(folder);
  }

  MusicFolder? popNavigationHistory() {
    return _navigationState.popHistory();
  }

  double getFolderScrollOffset(String? path) {
    return _navigationState.getScrollOffset(path);
  }

  void setFolderScrollOffset(String? path, double offset) {
    _navigationState.setScrollOffset(path, offset);
  }

  void clearFolderScrollOffsets() {
    _navigationState.clearScrollOffsets();
  }

  MusicFolder? get systemMediaFolder => _systemMediaFolder;
  bool get hasPermission => _hasPermission;
  Map<String, SongMetadata> get metadataMap => _metadataStore.metadataMap;
  int get metadataRevision => _metadataRevision;
  int get albumLibraryRevision => _albumLibraryRevision;
  bool isRootPathAvailable(String path) {
    final normalizedPath = _normalizePath(path);
    if (normalizedPath.isEmpty) return true;
    return _rootAvailability[_pathLookupKey(normalizedPath)] ?? true;
  }

  Future<void> get ready => _readyCompleter.future;

  ScannerService({
    bool autoInitialize = true,
    Duration directoryRescanBatchWindow = _defaultDirectoryRescanBatchWindow,
  }) : _directoryRescanBatchWindow = directoryRescanBatchWindow {
    _roots = ScannerServiceRoots(
      isDisposed: () => _isDisposed,
      onPathChanged: _enqueueWatchedPath,
    );
    _metadataStore = ScannerMetadataStore(
      rootFolders: () => _scannedRootFolders,
      systemMediaFolder: () => _systemMediaFolder,
      notifyListeners: notifyListeners,
      scheduleMetadataNotify: _scheduleMetadataNotify,
      onMetadataMutated: _markMetadataMutated,
      notifySongMissingState: _notifySongMissingState,
      normalizePath: _normalizePath,
      pathsEqual: _pathsEqual,
      onAlbumMetadataMutated: _markAlbumLibraryMutated,
    );
    _scanPipeline = ScannerScanPipeline(
      normalizePath: _normalizePath,
      pathLookupKey: _pathLookupKey,
      metadataStore: _metadataStore,
    );
    _repository = ScannerRepository();
    _scanCoordinator = ScannerScanCoordinator()
      ..addListener(_handleScanStateChanged);
    _treeBuilder = ScannerTreeBuilder(
      normalizePath: _normalizePath,
      pathsEqual: _pathsEqual,
    );
    _directoryScanner = ScannerDirectoryScanner(
      emitScanProgress: _emitScanProgress,
    );
    _navigationState.addListener(_handleNavigationChanged);
    WidgetsBinding.instance.addObserver(this);
    if (autoInitialize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_runInit());
      });
    } else {
      _readyCompleter.complete();
    }
    _setupMediaObserver();
    _setupMobileStorageObserver();
  }

  Future<void> _runInit() async {
    try {
      await _init();
    } finally {
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
    }
  }

  void _markMetadataMutated() {
    _metadataRevision++;
  }

  void _markAlbumLibraryMutated() {
    _albumLibraryRevision++;
  }

  void _handleScanStateChanged() {
    if (_isDisposed) return;
    notifyListeners();
    if (!isScanning &&
        _pendingDirectoryRescanPaths.isNotEmpty &&
        _directoryRescanTimer == null &&
        !_directoryRescanInProgress) {
      _directoryRescanTimer = Timer(
        Duration.zero,
        () => unawaited(_flushPendingDirectoryRescans()),
      );
    }
  }

  void _logInitTiming(String label, Stopwatch stopwatch) {
    if (!kDebugMode) return;
    debugPrint(
      '[ScannerService][init] $label ${stopwatch.elapsedMilliseconds} ms',
    );
  }

  Future<void> _loadScanSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _skipShortAudioScanEnabled =
        prefs.getBool(SettingsService.skipShortAudioScanEnabledStorageKey) ??
        false;
    _skipShortAudioScanThresholdSeconds =
        prefs.getInt(
          SettingsService.skipShortAudioScanMinimumDurationSecondsStorageKey,
        ) ??
        _defaultShortAudioThresholdSeconds;
  }

  bool _shouldSkipShortAudioDuration(int? durationMillis) {
    if (!_skipShortAudioScanEnabled) {
      return false;
    }
    if (durationMillis == null) {
      return false;
    }
    return durationMillis <
        Duration(seconds: _skipShortAudioScanThresholdSeconds).inMilliseconds;
  }

  bool _shouldKeepSongMetadata(SongMetadata song) {
    return !_shouldSkipShortAudioDuration(song.duration);
  }

  Future<bool> _shouldRunArtworkScanForFile(
    String filePath, {
    required bool hasArtwork,
    required bool hasMetadataError,
  }) async {
    if (hasArtwork) {
      return true;
    }
    if (!hasMetadataError) {
      return false;
    }
    return MetadataHelper.hasEmbeddedArtwork(filePath);
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;

    if (isScanning != _lastNotifiedScanningState) {
      _lastNotifiedScanningState = isScanning;
      _scanNotifyTimer?.cancel();
      _scanNotifyTimer = null;
      _scanNotifyPending = false;
      super.notifyListeners();
      return;
    }

    if (!isScanning) {
      super.notifyListeners();
      return;
    }

    _scanNotifyPending = true;
    if (_scanNotifyTimer?.isActive ?? false) {
      return;
    }

    _scanNotifyTimer = Timer(const Duration(seconds: 1), () {
      _scanNotifyTimer = null;
      if (_isDisposed || !_scanNotifyPending) {
        return;
      }
      _scanNotifyPending = false;
      super.notifyListeners();
    });
  }

  void _flushScanNotifications() {
    _scanNotifyTimer?.cancel();
    _scanNotifyTimer = null;
    _scanNotifyPending = false;
  }

  void setPlayerController(AudioCoreController? controller) {
    final changed = !identical(_playerController, controller);
    _playerController = controller;
    if (!changed || controller == null) {
      return;
    }

    if (Platform.isAndroid) {
      unawaited(checkPermissionStatus());
    } else if (_supportsPersistentAccess && !Platform.isLinux) {
      unawaited(_syncAppleScopedAccessState());
    }
  }

  void setSongMissingStateHandler(
    void Function(String path, bool isMissing)? handler,
  ) {
    _songMissingStateHandler = handler;
  }

  void _notifySongMissingState(String path, bool isMissing) {
    final handler = _songMissingStateHandler;
    if (handler == null) return;
    final normalized = _normalizePath(path);
    if (normalized.isEmpty) return;
    handler(normalized, isMissing);
  }

  void setSortCriteria(
    SortCriteria criteria, {
    SortScope scope = SortScope.global,
    String? folderPath,
  }) {
    if (scope == SortScope.currentFolder &&
        _updateFolderSortSettings(folderPath: folderPath, criteria: criteria)) {
      _sortAndNotify();
      return;
    }

    if (_globalSortCriteria == criteria) {
      return;
    }

    _globalSortCriteria = criteria;
    unawaited(_saveGlobalSortSettings());
    _sortAndNotify();
  }

  void setSortOrder(
    SortOrder order, {
    SortScope scope = SortScope.global,
    String? folderPath,
  }) {
    if (scope == SortScope.currentFolder &&
        _updateFolderSortSettings(folderPath: folderPath, order: order)) {
      _sortAndNotify();
      return;
    }

    if (_globalSortOrder == order) {
      return;
    }

    _globalSortOrder = order;
    unawaited(_saveGlobalSortSettings());
    _sortAndNotify();
  }

  void _sortAndNotify() {
    final totalStopwatch = Stopwatch()..start();
    try {
      _timeScanStepSync('stage sortAndNotify sort scanned root folders', () {
        _folderSorter.sortFoldersForTree(
          _scannedRootFolders,
          resolveSettings: _resolveSortSettingsForFolder,
        );
      });
      if (_systemMediaFolder != null) {
        _timeScanStepSync('stage sortAndNotify sort system media tree', () {
          _folderSorter.sortFolderRecursiveForTree(
            _systemMediaFolder!,
            resolveSettings: _resolveSortSettingsForFolder,
          );
        });
      }
      _timeScanStepSync(
        'stage sortAndNotify rebuild displayed root folders',
        () {
          _rebuildDisplayedRootFolders();
        },
      );
      _timeScanStepSync('stage sortAndNotify sync navigation state', () {
        _syncNavigationStateToLatestTree();
      });
      unawaited(_refreshRootRepresentativeSongs());
      _timeScanStepSync('stage sortAndNotify notify listeners', () {
        notifyListeners();
      });
    } finally {
      totalStopwatch.stop();
      _logScanTiming('stage sortAndNotify total', totalStopwatch);
    }
  }

  Future<void> _refreshRootRepresentativeSongs() async {
    final nextCache = <String, SongMetadata?>{};

    if (_systemMediaFolder != null) {
      final repFile = findRepresentativeSong(_systemMediaFolder!);
      if (repFile != null) {
        final songMeta = await _repository.getSongMetadata(repFile.path);
        if (songMeta != null) {
          nextCache['system'] = songMeta;
        }
      }
    }

    for (final root in _roots.rootPaths) {
      final normalized = _normalizePath(root);
      final sortSettings = _resolveSortSettingsForFolder(normalized);

      final scanned = _scannedRootFolders.firstWhereOrNull(
        (f) => ScannerPathUtils.pathsEqual(f.path, normalized),
      );
      if (scanned != null) {
        final repFile = findRepresentativeSong(scanned);
        if (repFile != null) {
          final songMeta = await _repository.getSongMetadata(repFile.path);
          final hasArtwork = songMeta != null &&
              ((songMeta.artworkPath != null && songMeta.artworkPath!.isNotEmpty) ||
               (songMeta.thumbnailPath != null && songMeta.thumbnailPath!.isNotEmpty));
          if (hasArtwork) {
            nextCache[normalized] = songMeta;
            continue;
          }
        }
      }

      final repSong = await _repository.getRepresentativeSongUnderPath(
        normalized,
        criteria: sortSettings.criteria,
        order: sortSettings.order,
      );
      if (repSong != null) {
        nextCache[normalized] = repSong;
      }
    }

    _rootRepresentativeSongs
      ..clear()
      ..addAll(nextCache);
    notifyListeners();
  }

  Future<void> _init() async {
    final totalStopwatch = Stopwatch()..start();
    try {
      if (Platform.isLinux) {
        try {
          _linuxFlatpak = await _linuxDirectoryAccess.isFlatpak;
        } catch (e) {
          debugPrint('[ScannerService] Linux directory access unavailable: $e');
        }
      }
      // Force database open to run path migrations first (critical for iOS sandbox UUID changes)
      await _repository.ensureOpen();

      final canUsePersistentAccess =
          _supportsPersistentAccess &&
          (Platform.isLinux || _playerController != null);
      if (Platform.isLinux) {
        await _timeInitStep('resolve and mount linux roots', () async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final paths = prefs.getStringList('root_paths') ?? [];
            if (paths.isNotEmpty) {
              final updatedPaths = await _resolveAndMigrateLinuxRoots(paths);
              await prefs.setStringList('root_paths', updatedPaths);
            }
          } catch (e, st) {
            debugPrint('Error during pre-initialization linux mount: $e\n$st');
          }
        });
      }
      if (_linuxFlatpak) {
        await _timeInitStep(
          'restore Linux portal roots',
          _restoreLinuxPortalRoots,
        );
      }
      await _timeInitStep('load root paths', () {
        return _roots.loadRootPaths(
          hasPersistentAccess: canUsePersistentAccess
              ? _hasPersistentAccess
              : null,
          forgetPersistentAccess: canUsePersistentAccess
              ? _forgetPersistentAccess
              : null,
        );
      });
      if (canUsePersistentAccess) {
        await _timeInitStep(
          'sync active scoped root access',
          _syncActiveScopedRootAccess,
        );
      }
      await _timeInitStep(
        'sync root availability',
        () => _refreshRootAvailability(shouldNotifyListeners: false),
      );
      await _timeInitStep('load sort settings', _loadSortSettings);
      await _timeInitStep('load scan settings', _loadScanSettings);
      final cachedSongs = const <SongMetadata>[];
      await _timeInitStep(
        'load cached root folders from database',
        () => _loadCachedRootFoldersFromDatabase(cachedSongs: cachedSongs),
      );
      await _timeInitStep(
        'load cached system media folder from database',
        () =>
            _loadCachedSystemMediaFolderFromDatabase(cachedSongs: cachedSongs),
      );
      _timeInitStepSync('rebuild displayed root folders', () {
        _rebuildDisplayedRootFolders();
      });
      _timeInitStepSync('notify listeners after init', () {
        notifyListeners();
      });
      await _timeInitStep('check and request permissions', () {
        return checkPermissionStatus();
      });
      // Auto scan on startup
      await _timeInitStep('startup scan', scan);
      _rootAvailabilityTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        _pendingRootAvailabilityRescan = true;
        _scheduleRootAvailabilityRefresh();
      });
    } finally {
      totalStopwatch.stop();
      _logInitTiming('init total', totalStopwatch);
    }
  }

  void _setupMediaObserver() {
    if (Platform.isAndroid) {
      const mediaObserverChannel = EventChannel(
        'app.vynody.player/media_observer',
      );
      _mediaObserverSubscription = mediaObserverChannel
          .receiveBroadcastStream()
          .listen(
            (event) {
              if (event == 'media_changed' &&
                  !isScanning &&
                  !_mediaObserverPaused) {
                debugPrint(
                  'Media library change detected, re-scanning system media...',
                );
                scanSystemMedia();
              }
            },
            onError: (err) {
              debugPrint('Media observer error: $err');
            },
          );
    }
  }

  void pauseMediaObserver() {
    debugPrint('[ScannerService] Pausing media observer');
    _mediaObserverPaused = true;
  }

  void resumeMediaObserver({bool triggerScan = false}) {
    debugPrint(
      '[ScannerService] Resuming media observer (triggerScan=$triggerScan)',
    );
    _mediaObserverPaused = false;
    if (triggerScan) {
      unawaited(scan(clearScannedRoots: false));
    }
  }

  Future<void> checkAndRequestPermissions() async {
    debugPrint(
      '[ScannerService] checkAndRequestPermissions start '
      'hasPermission=$_hasPermission '
      'playerController=${_playerController != null}',
    );
    _hasPermission = await _checkPermissions(request: true);
    debugPrint(
      '[ScannerService] checkAndRequestPermissions result '
      'hasPermission=$_hasPermission',
    );
    notifyListeners();
    if (_hasPermission) {
      await scanSystemMedia();
    }
  }

  Future<void> checkPermissionStatus() async {
    debugPrint(
      '[ScannerService] checkPermissionStatus start '
      'hasPermission=$_hasPermission '
      'playerController=${_playerController != null}',
    );
    _hasPermission = await _checkPermissions(request: false);
    debugPrint(
      '[ScannerService] checkPermissionStatus result '
      'hasPermission=$_hasPermission',
    );
    notifyListeners();
    if (_hasPermission) {
      unawaited(scanSystemMedia());
    }
  }

  Future<List<String>> _resolveAndMigrateLinuxRoots(List<String> paths) async {
    if (!Platform.isLinux) return paths;
    final updatedPaths = await LinuxMountHelper.resolveAndMountRootPaths(paths);
    for (int i = 0; i < paths.length && i < updatedPaths.length; i++) {
      final oldPath = paths[i];
      final newPath = updatedPaths[i];
      if (oldPath != newPath) {
        await _repository.migrateLinuxRootPath(oldPath, newPath);
      }
    }
    return updatedPaths;
  }

  Future<RootPathAddResult> addRootPath(
    String path, {
    String? persistentDocumentId,
  }) async {
    final normalizedPath = _normalizePath(path);
    debugPrint('[ScannerService] addRootPath: path=$path, normalizedPath=$normalizedPath, persistentDocumentId=$persistentDocumentId, _linuxFlatpak=$_linuxFlatpak');
    if (Platform.isLinux && _linuxFlatpak && persistentDocumentId != null) {
      _linuxDocumentIds[normalizedPath] = persistentDocumentId;
      await _saveLinuxDocumentIds();
    }
    final existingRoot = _roots.rootPaths.firstWhereOrNull(
      (existing) => _pathsEqual(existing, normalizedPath),
    );

    if (_supportsPersistentAccess) {
      final registered = await _registerPersistentAccess(normalizedPath);
      if (!registered) {
        debugPrint(
          '[ScannerService] Failed to register persistent access for $normalizedPath',
        );
        return RootPathAddResult(
          RootPathAddStatus.persistentAccessDenied,
          path: normalizedPath,
        );
      }

      final scopedAccessReady = await _ensureScopedRootAccess(normalizedPath);
      if (!scopedAccessReady) {
        debugPrint(
          '[ScannerService] Failed to begin scoped access for $normalizedPath',
        );
        return RootPathAddResult(
          RootPathAddStatus.persistentAccessDenied,
          path: normalizedPath,
        );
      }
    }

    if (existingRoot != null) {
      final existingFolder = _rootFolders.firstWhereOrNull(
        (folder) => _pathsEqual(folder.path, existingRoot),
      );
      return RootPathAddResult(
        existingFolder != null && !existingFolder.isEmpty
            ? RootPathAddStatus.alreadyAdded
            : RootPathAddStatus.noMusic,
        path: existingRoot,
      );
    }

    var updatedRoots = [..._roots.rootPaths, normalizedPath];
    if (Platform.isLinux) {
      try {
        updatedRoots = await _resolveAndMigrateLinuxRoots(updatedRoots);
      } catch (e) {
        debugPrint('Error registering Linux root UUID: $e');
      }
    }
    await _roots.setRootPaths(updatedRoots);
    _rootAvailability[_pathLookupKey(normalizedPath)] = _isRootPathAvailable(
      normalizedPath,
    );
    if (_supportsPersistentAccess) {
      await _syncActiveScopedRootAccess();
    }
    await _loadCachedRootFoldersFromDatabase(rootPaths: updatedRoots);
    _rebuildDisplayedRootFolders();
    notifyListeners();

    if (Platform.isAndroid) {
      try {
        await MediaScanner.loadMedia(path: normalizedPath);
      } catch (e) {
        debugPrint('MediaScanner error: $e');
      }
    }

    _restartFullRootScan();
    return RootPathAddResult(RootPathAddStatus.added, path: normalizedPath);
  }

  Future<void> removeRootPath(String path) async {
    await removeRootPaths([path]);
  }

  Future<void> removeRootPaths(Iterable<String> paths) async {
    final normalizedTargets = _normalizeDeclaredRootPaths(paths);
    if (normalizedTargets.isEmpty) return;
    debugPrint(
      '[ScannerService] removeRootPaths requested=$normalizedTargets '
      'currentRoots=${_roots.rootPaths} isScanning=$isScanning',
    );

    if (_supportsPersistentAccess) {
      for (final path in normalizedTargets) {
        await _forgetPersistentAccess(path);
      }
    }

    var updatedRoots = [..._roots.rootPaths];
    updatedRoots.removeWhere(
      (existing) =>
          normalizedTargets.any((target) => _pathsEqual(existing, target)),
    );
    if (Platform.isLinux) {
      try {
        updatedRoots = await _resolveAndMigrateLinuxRoots(updatedRoots);
      } catch (e) {
        debugPrint('Error updating Linux root UUID mapping: $e');
      }
    }
    await _roots.setRootPaths(updatedRoots);
    for (final path in normalizedTargets) {
      _rootAvailability.remove(_pathLookupKey(path));
    }
    if (_supportsPersistentAccess) {
      await _syncActiveScopedRootAccess();
    }
    _removeRootsFromScannedTree(normalizedTargets);
    await _purgeRemovedRootsFromMetadataCache(normalizedTargets);
    _rebuildDisplayedRootFolders();
    _syncNavigationStateToLatestTree();
    notifyListeners();
    debugPrint(
      '[ScannerService] removeRootPaths applied '
      'remainingRoots=${_roots.rootPaths}',
    );

    _restartFullRootScan();
  }

  Future<void> moveRootPath(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _roots.rootPaths.length) return;
    if (newIndex < 0 || newIndex > _roots.rootPaths.length) return;
    if (oldIndex == newIndex) return;

    final updatedRoots = [..._roots.rootPaths];
    final movedPath = updatedRoots.removeAt(oldIndex);
    updatedRoots.insert(newIndex, movedPath);
    await _roots.setRootPaths(updatedRoots);
    _rebuildDisplayedRootFolders();
    notifyListeners();
    _restartFullRootScan();
  }

  Future<bool> _registerPersistentAccess(String path) async {
    debugPrint('[ScannerService] _registerPersistentAccess: path=$path, keys=${_linuxDocumentIds.keys.toList()}');
    if (Platform.isLinux && _linuxFlatpak) {
      return _linuxDocumentIds.containsKey(_normalizePath(path));
    }
    final controller = _playerController;
    if (controller == null) return true;
    try {
      return await controller.registerPersistentAccess(path: path);
    } catch (e) {
      debugPrint(
        '[ScannerService] registerPersistentAccess failed for $path: $e',
      );
      return false;
    }
  }

  Future<void> _forgetPersistentAccess(String path) async {
    if (Platform.isLinux && _linuxFlatpak) {
      final documentId = _linuxDocumentIds.remove(_normalizePath(path));
      await _saveLinuxDocumentIds();
      if (documentId != null) {
        try {
          await _linuxDirectoryAccess.revokeDirectory(documentId);
        } catch (e) {
          debugPrint('[ScannerService] revoke Linux portal access failed: $e');
        }
      }
      return;
    }
    final controller = _playerController;
    if (controller == null) return;
    try {
      await controller.forgetPersistentAccess(path: path);
    } catch (e) {
      debugPrint(
        '[ScannerService] forgetPersistentAccess failed for $path: $e',
      );
    }
  }

  void _setupMobileStorageObserver() {
    if (!(Platform.isAndroid ||
        Platform.isLinux ||
        Platform.isMacOS ||
        Platform.isWindows)) {
      return;
    }

    try {
      _mobileStorageSubscription = _mobileStorageListener.storageEvents.listen(
        (event) {
          if (_isDisposed) return;
          if (event.type == MobileStorageEventType.unknown) return;
          final affectedRoots = _rootsAffectedByStoragePath(event.path);
          if (affectedRoots.isNotEmpty) {
            debugPrint(
              '[ScannerService] mobile storage event=${event.typeName} '
              'path=${event.path ?? "unknown"} affectedRoots=$affectedRoots',
            );
            if (_supportsPersistentAccess) {
              final controller = _playerController;
              if (controller != null) {
                for (final path in affectedRoots) {
                  final normalized = _normalizePath(path);
                  _activeScopedRootPaths.remove(normalized);
                  if (event.type == MobileStorageEventType.unmounted ||
                      event.type == MobileStorageEventType.removed ||
                      event.type == MobileStorageEventType.eject ||
                      event.type == MobileStorageEventType.badRemoval) {
                    try {
                      unawaited(controller.endScopedAccess(path: normalized));
                    } catch (e) {
                      debugPrint(
                        '[ScannerService] endScopedAccess failed for $normalized: $e',
                      );
                    }
                  }
                }
              }
            }
          }
          _pendingRootAvailabilityRescan = true;
          _scheduleRootAvailabilityRefresh();
        },
        onError: (err) {
          debugPrint('Mobile storage observer error: $err');
        },
      );
    } catch (e) {
      debugPrint('Failed to setup mobile storage observer: $e');
    }
  }

  void _scheduleRootAvailabilityRefresh() {
    if (_isDisposed) return;
    if (_rootAvailabilityRefreshTimer?.isActive ?? false) {
      return;
    }

    _rootAvailabilityRefreshTimer = Timer(
      const Duration(milliseconds: 350),
      () {
        _rootAvailabilityRefreshTimer = null;
        if (_isDisposed) return;
        final shouldRescan = _pendingRootAvailabilityRescan;
        _pendingRootAvailabilityRescan = false;
        unawaited(
          _refreshRootAvailability(
            shouldNotifyListeners: true,
            rescanRestoredRoots: shouldRescan,
          ),
        );
      },
    );
  }

  Future<void> _refreshRootAvailability({
    required bool shouldNotifyListeners,
    bool rescanRestoredRoots = false,
  }) async {
    if (_supportsPersistentAccess && _playerController != null) {
      await _syncActiveScopedRootAccess();
    }

    final declaredRoots = _roots.rootPaths.toList(growable: false);
    final declaredKeys = declaredRoots.map(_pathLookupKey).toSet();
    final previousAvailability = Map<String, bool>.from(_rootAvailability);
    final nextAvailability = <String, bool>{};
    final missingRoots = <String>[];
    final restoredRoots = <String>[];

    for (final rootPath in declaredRoots) {
      final normalizedRoot = _normalizePath(rootPath);
      if (normalizedRoot.isEmpty) {
        continue;
      }

      final key = _pathLookupKey(normalizedRoot);
      final available = _isRootPathAvailable(normalizedRoot);
      nextAvailability[key] = available;

      final previous = previousAvailability[key];
      if (previous == null) {
        if (!available) {
          missingRoots.add(normalizedRoot);
        }
        continue;
      }

      if (previous == available) {
        continue;
      }

      if (available) {
        restoredRoots.add(normalizedRoot);
      } else {
        missingRoots.add(normalizedRoot);
      }
    }

    _rootAvailability
      ..clear()
      ..addAll(nextAvailability);
    _rootAvailability.removeWhere((key, _) => !declaredKeys.contains(key));

    final currentFolderPath = _navigationState.currentFolder?.path;
    final shouldReturnToRootList =
        currentFolderPath != null &&
        missingRoots.any((root) => _pathContains(root, currentFolderPath));
    if (shouldReturnToRootList) {
      _navigationState.setState(null, const []);
    }

    if (restoredRoots.isNotEmpty) {
      await _loadCachedRootFoldersFromDatabase(rootPaths: restoredRoots);
    }

    // Keep the last known tree for temporarily missing roots so a brief
    // unplug/replug cycle does not collapse the visible folder structure.
    if (missingRoots.isNotEmpty || restoredRoots.isNotEmpty) {
      _rebuildDisplayedRootFolders();
      _syncNavigationStateToLatestTree();
      if (shouldNotifyListeners) {
        notifyListeners();
      }
    }

    if (rescanRestoredRoots && restoredRoots.isNotEmpty) {
      _scanCoordinator.requestRescan();
      if (!_scanCoordinator.isScanning) {
        unawaited(
          _scanRootsWithFullFlow(restoredRoots, clearScannedRoots: false),
        );
      }
    }
  }

  bool _isRootPathAvailable(String path) {
    final normalizedPath = _normalizePath(path);
    if (normalizedPath.isEmpty) return false;

    if (Platform.isLinux &&
        (normalizedPath.startsWith('/run/media/') ||
            normalizedPath.startsWith('/media/'))) {
      return true;
    }

    try {
      return Directory(normalizedPath).existsSync();
    } catch (e, st) {
      debugPrint(
        '[ScannerService] root availability check failed path=$normalizedPath: $e\n$st',
      );
      return false;
    }
  }

  List<String> _rootsAffectedByStoragePath(String? storagePath) {
    final normalizedStoragePath = _normalizePath(storagePath ?? '');
    final declaredRoots = _roots.rootPaths.toList(growable: false);
    if (normalizedStoragePath.isEmpty) {
      return declaredRoots;
    }

    final matchingRoots = declaredRoots
        .where((rootPath) => _pathContains(normalizedStoragePath, rootPath))
        .toList(growable: false);
    return matchingRoots.isEmpty ? declaredRoots : matchingRoots;
  }

  Future<bool> _hasPersistentAccess(String path) async {
    if (Platform.isLinux && _linuxFlatpak) {
      return _linuxDocumentIds.containsKey(_normalizePath(path));
    }
    final controller = _playerController;
    if (controller == null) return true;
    try {
      return await controller.hasPersistentAccess(path: path);
    } catch (e) {
      debugPrint('[ScannerService] hasPersistentAccess failed for $path: $e');
      return false;
    }
  }

  Future<void> _saveLinuxDocumentIds() async {
    if (!_linuxFlatpak) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'linux_portal_document_ids',
      jsonEncode(_linuxDocumentIds),
    );
  }

  Future<void> _restoreLinuxPortalRoots() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('linux_portal_document_ids');
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return;
    _linuxDocumentIds
      ..clear()
      ..addAll(
        decoded.map((key, value) => MapEntry(key.toString(), value.toString())),
      );

    final savedRoots = prefs.getStringList('root_paths') ?? <String>[];
    final restoredRoots = <String>[];
    final restoredDocumentIds = <String, String>{};
    for (final savedRoot in savedRoots) {
      final documentId = _linuxDocumentIds[savedRoot];
      if (documentId == null) {
        restoredRoots.add(savedRoot);
        continue;
      }

      try {
        final grant = await _linuxDirectoryAccess.restoreDirectory(documentId);
        if (grant == null) continue;
        final restoredPath = _normalizePath(grant.path);
        if (restoredPath != savedRoot) {
          await _repository.migrateLinuxRootPath(savedRoot, restoredPath);
        }
        restoredRoots.add(restoredPath);
        restoredDocumentIds[restoredPath] = documentId;
      } catch (e) {
        debugPrint(
          '[ScannerService] failed to restore Linux portal root $savedRoot: $e',
        );
      }
    }

    _linuxDocumentIds
      ..clear()
      ..addAll(restoredDocumentIds);
    await prefs.setStringList('root_paths', restoredRoots);
    await _saveLinuxDocumentIds();
  }

  Future<void> _syncAppleScopedAccessState() async {
    if (!_supportsPersistentAccess) return;

    final currentRoots = List<String>.from(_roots.rootPaths);
    for (final path in currentRoots) {
      await _registerPersistentAccess(path);
    }

    await _roots.loadRootPaths(
      hasPersistentAccess: _hasPersistentAccess,
      forgetPersistentAccess: _forgetPersistentAccess,
    );
    await _syncActiveScopedRootAccess();
    _rebuildDisplayedRootFolders();
    notifyListeners();
  }

  Future<bool> _ensureScopedRootAccess(String path) async {
    if (Platform.isLinux && _linuxFlatpak) return true;
    if (!_supportsPersistentAccess) return true;

    final controller = _playerController;
    if (controller == null) return true;

    final normalizedPath = _normalizePath(path);
    if (normalizedPath.isEmpty) return false;
    if (_activeScopedRootPaths.contains(normalizedPath)) {
      return true;
    }

    try {
      final started = await controller.beginScopedAccess(path: normalizedPath);
      if (started) {
        _activeScopedRootPaths.add(normalizedPath);
      }
      return started;
    } catch (e) {
      debugPrint(
        '[ScannerService] beginScopedAccess failed for $normalizedPath: $e',
      );
      return false;
    }
  }

  Future<void> _syncActiveScopedRootAccess() async {
    if (Platform.isLinux && _linuxFlatpak) return;
    if (!_supportsPersistentAccess) return;

    final controller = _playerController;
    if (controller == null) return;

    final desiredRoots = _roots.rootPaths
        .map(_normalizePath)
        .where((path) => path.isNotEmpty)
        .toSet();

    final staleRoots = _activeScopedRootPaths
        .where((path) => !desiredRoots.contains(path))
        .toList(growable: false);
    for (final path in staleRoots) {
      try {
        await controller.endScopedAccess(path: path);
      } catch (e) {
        debugPrint('[ScannerService] endScopedAccess failed for $path: $e');
      } finally {
        _activeScopedRootPaths.remove(path);
      }
    }

    final missingRoots = desiredRoots
        .where((path) => !_activeScopedRootPaths.contains(path))
        .toList(growable: false);
    for (final path in missingRoots) {
      final started = await _ensureScopedRootAccess(path);
      if (!started) {
        debugPrint(
          '[ScannerService] beginScopedAccess returned false for $path',
        );
      }
    }
  }

  Future<bool> _checkPermissions({bool request = true}) async {
    if (Platform.isAndroid) {
      if (!request) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          final status = await Permission.audio.status;
          return status.isGranted;
        } else {
          final status = await Permission.storage.status;
          return status.isGranted;
        }
      }

      final controller = _playerController;
      if (controller != null) {
        debugPrint(
          '[ScannerService] _checkPermissions via AudioCoreController',
        );
        final granted = await controller.ensureAndroidMediaLibraryPermission();
        debugPrint(
          '[ScannerService] AudioCoreController permission result=$granted',
        );
        return granted;
      }

      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      debugPrint(
        '[ScannerService] _checkPermissions fallback '
        'sdkInt=${androidInfo.version.sdkInt}',
      );

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ requires Permission.audio
        var status = await Permission.audio.status;
        debugPrint('[ScannerService] Permission.audio initial status=$status');
        if (!status.isGranted) {
          status = await Permission.audio.request();
          debugPrint(
            '[ScannerService] Permission.audio requested status=$status',
          );
        }
        return status.isGranted;
      } else {
        // Legacy storage permission
        var status = await Permission.storage.status;
        debugPrint(
          '[ScannerService] Permission.storage initial status=$status',
        );
        if (!status.isGranted) {
          status = await Permission.storage.request();
          debugPrint(
            '[ScannerService] Permission.storage requested status=$status',
          );
        }
        return status.isGranted;
      }
    }
    return true; // Assume granted on other platforms for now
  }

  Future<void> scanSystemMedia() async {
    await _loadScanSettings();
    debugPrint(
      '[ScannerService] scanSystemMedia start '
      'platform=${Platform.operatingSystem} '
      'hasPermission=$_hasPermission '
      'playerController=${_playerController != null}',
    );
    if (!Platform.isAndroid) {
      debugPrint('[ScannerService] scanSystemMedia skipped: Android only');
      return;
    }
    if (!_hasPermission) {
      debugPrint('[ScannerService] scanSystemMedia aborted: no permission');
      return;
    }

    try {
      if (Platform.isAndroid) {
        final controller = _playerController;
        if (controller == null) {
          debugPrint(
            'scanSystemMedia skipped: AudioCoreController is not available yet.',
          );
          return;
        }

        final scanResult = await controller.scanAndroidMediaLibrary();
        debugPrint(
          '[ScannerService] Android media scan result '
          'permissionGranted=${scanResult.permissionGranted} '
          'entries=${scanResult.entries.length} '
          'success=${scanResult.isSuccessful} '
          'errorCode=${scanResult.errorCode ?? "-"} '
          'errorMessage=${scanResult.errorMessage ?? "-"}',
        );
        _hasPermission = scanResult.permissionGranted;
        if (!scanResult.permissionGranted) {
          debugPrint(
            '[ScannerService] Android media scan stopped because '
            'permissionGranted=false',
          );
          _systemMediaFolder = null;
          notifyListeners();
          return;
        }

        final keptEntries = scanResult.entries
            .where(
              (entry) =>
                  !_shouldSkipShortAudioDuration(entry.duration.inMilliseconds),
            )
            .toList(growable: false);
        final skippedEntryPaths = scanResult.entries
            .where(
              (entry) =>
                  _shouldSkipShortAudioDuration(entry.duration.inMilliseconds),
            )
            .map(_androidEntryFilePath)
            .whereType<String>()
            .toList(growable: false);
        if (skippedEntryPaths.isNotEmpty) {
          for (final path in skippedEntryPaths) {
            _metadataStore.removeMetadataForPath(path);
          }
        }
        if (keptEntries.isEmpty) {
          _systemMediaFolder = null;
          await MetadataDatabase().syncSongSourcePresence(
            sourceMask: SongSourceFlags.systemMedia,
            presentPaths: const [],
          );
          notifyListeners();
          return;
        }
        final filePaths = keptEntries
            .map(_androidEntryFilePath)
            .whereType<String>()
            .toList(growable: false);
        final metadataByPath = filePaths.isEmpty
            ? <String, SongMetadata>{}
            : await MetadataDatabase().getSongMetadataByPaths(filePaths);

        _systemMediaFolder = _treeBuilder.buildAndroidMediaLibrary(
          keptEntries,
          metadataByPath,
          _compareNaturally,
        );
        debugPrint(
          '[ScannerService] Android system media tree built '
          'hasTree=${_systemMediaFolder != null} '
          'rootFolders=${_systemMediaFolder?.subFolders.length ?? 0} '
          'files=${_systemMediaFolder?.files.length ?? 0}',
        );
        if (_systemMediaFolder != null) {
          _folderSorter.sortFolderRecursiveForTree(
            _systemMediaFolder!,
            resolveSettings: _resolveSortSettingsForFolder,
          );
        }
        await MetadataDatabase().syncSongSourcePresence(
          sourceMask: SongSourceFlags.systemMedia,
          presentPaths: filePaths,
        );
        notifyListeners();

        unawaited(_processAndSaveAndroidSongsBackground(keptEntries));
        return;
      }

      if (Platform.isIOS) {
        debugPrint('[ScannerService] iOS media scan start');
        final songs = await OnAudioQuery().querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );
        final keptSongs = songs
            .where((song) {
              return !_shouldSkipShortAudioDuration(song.duration) &&
                  !MusicFileUtils.isAppleDoubleFilePath(song.data);
            })
            .toList(growable: false);
        final skippedSongPaths = songs
            .where(
              (song) =>
                  _shouldSkipShortAudioDuration(song.duration) ||
                  MusicFileUtils.isAppleDoubleFilePath(song.data),
            )
            .map((song) => _normalizePath(song.data))
            .where((path) => path.isNotEmpty)
            .toList(growable: false);
        if (skippedSongPaths.isNotEmpty) {
          for (final path in skippedSongPaths) {
            _metadataStore.removeMetadataForPath(path);
          }
        }
        if (keptSongs.isEmpty) {
          _systemMediaFolder = null;
          await MetadataDatabase().syncSongSourcePresence(
            sourceMask: SongSourceFlags.systemMedia,
            presentPaths: const [],
          );
          notifyListeners();
          return;
        }
        debugPrint(
          '[ScannerService] iOS media scan result count=${songs.length} '
          'kept=${keptSongs.length}',
        );

        final metadataByPath = await _buildScannedMetadataMap(
          keptSongs,
          filePathOf: (song) => song.data,
          songIdOf: (song) => song.id,
          fallbackTitleOf: (song) => song.title,
          fallbackAlbumOf: (song) => song.album ?? '',
          fallbackArtistOf: (song) => song.artist ?? '',
          fallbackDurationOf: (song) => song.duration,
          fallbackTrackNumberOf: (song) => song.track,
          sourceFlags: SongSourceFlags.systemMedia,
        );

        _systemMediaFolder = _treeBuilder.buildFolderTreeFromMetadata(
          metadataByPath.values,
          _compareNaturally,
          rootPath: 'system',
          rootName: _l10n().systemMediaLibrary,
        );
        debugPrint(
          '[ScannerService] iOS system media tree built '
          'hasTree=${_systemMediaFolder != null} '
          'rootFolders=${_systemMediaFolder?.subFolders.length ?? 0} '
          'files=${_systemMediaFolder?.files.length ?? 0}',
        );
        if (_systemMediaFolder != null) {
          _folderSorter.sortFolderRecursiveForTree(
            _systemMediaFolder!,
            resolveSettings: _resolveSortSettingsForFolder,
          );
        }
        await MetadataDatabase().syncSongSourcePresence(
          sourceMask: SongSourceFlags.systemMedia,
          presentPaths: keptSongs.map((song) => song.data),
        );
        notifyListeners();

        unawaited(_processAndSaveIosSongsBackground(keptSongs));
      }
    } catch (e) {
      debugPrint('[ScannerService] Error scanning system media: $e');
    }
  }

  Future<void> _loadCachedRootFoldersFromDatabase({
    Iterable<String>? rootPaths,
    List<SongMetadata>? cachedSongs,
    bool seedMetadataCache = true,
  }) async {
    try {
      final declaredRoots = (rootPaths ?? _roots.rootPaths)
          .map(_normalizePath)
          .where((path) => path.isNotEmpty)
          .toList(growable: false);
      if (declaredRoots.isEmpty) return;
      final availableRoots = declaredRoots
          .where(_isRootPathAvailable)
          .toList(growable: false);
      if (availableRoots.isEmpty) return;

      for (final root in availableRoots) {
        await loadRootFolderSongs(root);
        final count = await _repository.getSongCountUnderPath(root);
        final duration = await _repository.getSongDurationUnderPath(root);
        final sortSettings = _resolveSortSettingsForFolder(root);
        final repSong = await _repository.getRepresentativeSongUnderPath(
          root,
          criteria: sortSettings.criteria,
          order: sortSettings.order,
        );

        _rootSongCounts[root] = count;
        _rootSongDurations[root] = duration;
        _rootRepresentativeSongs[root] = repSong;

        if (repSong != null && seedMetadataCache) {
          _metadataStore.cacheMetadata(repSong);
        }
      }
    } catch (e) {
      debugPrint('[ScannerService] Failed to load cached root folders: $e');
    }
  }

  Future<void> _loadCachedSystemMediaFolderFromDatabase({
    List<SongMetadata>? cachedSongs,
    bool seedMetadataCache = true,
  }) async {
    if (!Platform.isAndroid) return;

    try {
      final systemSongs = cachedSongs ?? await _repository.getSystemMediaSongs();
      if (systemSongs.isNotEmpty) {
        _systemMediaFolder = _treeBuilder.buildFolderTreeFromMetadata(
          systemSongs,
          _compareNaturally,
          rootPath: 'system',
          rootName: _l10n().systemMediaLibrary,
        );
        if (_systemMediaFolder != null) {
          _folderSorter.sortFolderRecursiveForTree(
            _systemMediaFolder!,
            resolveSettings: _resolveSortSettingsForFolder,
          );
        }
        if (seedMetadataCache) {
          for (final song in systemSongs) {
            _metadataStore.cacheMetadata(song);
          }
        }
        _loadedRootPaths.add('system');
      }
    } catch (e) {
      debugPrint(
        '[ScannerService] Failed to load cached system media folder: $e',
      );
    }
  }

  void _upsertScannedRootFolder(MusicFolder folder) {
    final index = _scannedRootFolders.indexWhere(
      (existing) => _pathsEqual(existing.path, folder.path),
    );
    if (index >= 0) {
      _scannedRootFolders[index] = folder;
    } else {
      _scannedRootFolders.add(folder);
    }
    final normalized = _normalizePath(folder.path);
    _rootSongCounts[normalized] = folder.allSongs.length;
  }

  MusicFolder? _buildCachedFolderTree({
    required Iterable<SongMetadata> songs,
    required String rootPath,
    required String rootName,
  }) {
    final songList = songs.toList(growable: false);
    if (songList.isEmpty) return null;

    return _treeBuilder.buildFolderTreeFromMetadata(
      songList,
      _compareNaturally,
      rootPath: rootPath,
      rootName: rootName,
    );
  }

  void _seedMetadataCache(Iterable<SongMetadata> songs) {
    for (final song in songs) {
      _metadataStore.cacheMetadata(song);
    }
  }

  bool _songMatchesSource(
    SongMetadata song,
    int sourceMask, {
    bool includeLegacy = false,
  }) {
    final flags = song.sourceFlags;
    if (flags == null) return includeLegacy;
    return (flags & sourceMask) != 0;
  }

  String? _androidEntryFilePath(AndroidMediaLibraryEntry entry) {
    final path = entry.filePath?.trim();
    if (path != null && path.isNotEmpty) return _normalizePath(path);
    final uri = entry.uri.trim();
    if (uri.isNotEmpty) return uri;
    return null;
  }

  void _handleNavigationChanged() {
    if (_isDisposed) return;

    // Navigation changes should feel immediate even while a scan is running.
    // The throttled notifyListeners() path is still used for metadata/scan
    // updates, but folder switches need to repaint right away.
    super.notifyListeners();
  }

  void _syncScannedRootUiFromCache(String rootPath) {
    if (_isDisposed) return;
    _rebuildScannedRootFolderFromCache(rootPath);
    _rebuildDisplayedRootFolders();
    _syncNavigationStateToLatestTree(affectedRootPath: rootPath);
    notifyListeners();
  }

  void _syncScannedRootUiIncrementally(String rootPath) {
    if (_isDisposed) return;
    if (_pendingStage3IncrementalMetadata.isEmpty) return;

    final pending = List<SongMetadata>.from(_pendingStage3IncrementalMetadata);
    _pendingStage3IncrementalMetadata.clear();

    final rootFolder = _scannedRootFolders.firstWhereOrNull(
      (f) => _pathsEqual(f.path, rootPath),
    );

    if (rootFolder == null) {
      _syncScannedRootUiFromCache(rootPath);
      return;
    }

    final modifiedFolders = _treeBuilder.insertSongsToFolderTree(
      rootFolder,
      pending,
      rootPath: rootPath,
    );

    if (modifiedFolders.isNotEmpty) {
      _folderSorter.sortSpecificFolders(
        modifiedFolders,
        resolveSettings: _resolveSortSettingsForFolder,
      );
      _rebuildDisplayedRootFolders();
      _syncNavigationStateToLatestTree(affectedRootPath: rootPath);
      notifyListeners();
    }
  }

  void pauseBackgroundTasks() {
    if (!_scanCoordinator.isBackgroundPaused) {
      _scanCoordinator.setBackgroundPaused(true);
      debugPrint('ScannerService: Background tasks paused.');
      notifyListeners();
    }
  }

  void resumeBackgroundTasks() {
    if (_scanCoordinator.isBackgroundPaused) {
      _scanCoordinator.setBackgroundPaused(false);
      debugPrint('ScannerService: Background tasks resumed.');
      notifyListeners();
    }
  }

  Future<void> _waitUntilResumed() async {
    while (_scanCoordinator.isBackgroundPaused) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _processAndSaveAndroidSongsBackground(
    List<AndroidMediaLibraryEntry> entries,
  ) async {
    await _processEntriesBackground(
      entries,
      filePathOf: _androidEntryFilePath,
      songIdOf: (entry) => int.tryParse(entry.id),
      sourceMask: SongSourceFlags.systemMedia,
    );
  }

  Future<void> _processAndSaveIosSongsBackground(List<SongModel> songs) async {
    await _processEntriesBackground(
      songs,
      filePathOf: (song) => song.data,
      songIdOf: (song) => song.id,
      sourceMask: SongSourceFlags.systemMedia,
    );
  }

  Future<Map<String, SongMetadata>> _buildScannedMetadataMap<T>(
    Iterable<T> entries, {
    required String? Function(T entry) filePathOf,
    required int? Function(T entry) songIdOf,
    required String Function(T entry) fallbackTitleOf,
    required String Function(T entry) fallbackAlbumOf,
    required String Function(T entry) fallbackArtistOf,
    required int? Function(T entry) fallbackDurationOf,
    required int? Function(T entry) fallbackTrackNumberOf,
    int? sourceFlags,
  }) async {
    final metadataByPath = <String, SongMetadata>{};

    final entryByPath = <String, T>{};
    final filePaths = <String>[];
    for (final entry in entries) {
      final filePath = filePathOf(entry);
      if (filePath == null) continue;
      entryByPath[filePath] = entry;
      filePaths.add(filePath);
    }

    final batchResults = await MetadataHelper.readMetadataBatch(
      filePaths,
      getImage: false,
    );
    final db = MetadataDatabase();

    for (final result in batchResults) {
      final filePath = result['path'] as String? ?? '';
      if (filePath.isEmpty) continue;

      final entry = entryByPath[filePath];
      if (entry == null) continue;

      final existing = await db.getSongMetadata(filePath);
      final metadata = _buildScannedMetadataFromBatchResult(
        filePath,
        result,
        existing: existing,
        mediaId: songIdOf(entry),
        fallbackTitle: fallbackTitleOf(entry),
        fallbackAlbum: fallbackAlbumOf(entry),
        fallbackArtist: fallbackArtistOf(entry),
        fallbackDuration: fallbackDurationOf(entry),
        fallbackTrackNumber: fallbackTrackNumberOf(entry),
        sourceFlags: sourceFlags,
      );

      metadataByPath[filePath] = metadata;
      _metadataStore.cacheMetadata(metadata.copyWith(waveformBlob: null));
    }

    return metadataByPath;
  }

  Future<void> _processEntriesBackground<T>(
    Iterable<T> entries, {
    required String? Function(T entry) filePathOf,
    required int? Function(T entry) songIdOf,
    required int sourceMask,
  }) async {
    final player = _playerController;
    if (player == null) {
      debugPrint('Player controller not set for background scanning');
      return;
    }

    try {
      await player.initialize();
    } catch (e) {
      debugPrint(
        'Failed to initialize shared player for background scanning: $e',
      );
      return;
    }

    final scanState = ScanProgressState(
      metadataConcurrency: 4,
      comparePaths: _compareNaturally,
    );

    for (final entry in entries) {
      final currentEntry = entry;
      final path = filePathOf(currentEntry);
      if (path == null) continue;

      scanState.pendingMetadataTasks.add(
        scanState.metadataRunner.run(path, () async {
          await _waitUntilResumed();
          try {
            final processed = await MetadataHelper.processMetadata(
              path,
              songId: songIdOf(currentEntry),
              generateThumbnail: false,
            );
            if (processed == null) return;
            final metadata = processed.$1.copyWith(sourceFlags: sourceMask);
            await MetadataDatabase().insertOrUpdateSong(metadata);
            _metadataStore.cacheMetadata(metadata);
          } catch (e) {
            debugPrint('Background processing error for $path: $e');
          }
        }),
      );
    }

    await Future.wait(scanState.pendingMetadataTasks);
  }

  Future<void> _rescanDirectory(String directoryPath) async {
    final normalizedDirectory = _normalizePath(directoryPath);
    if (normalizedDirectory.isEmpty) {
      return;
    }

    final affectedRoots = _rootPathsForDirectoryPath(normalizedDirectory);
    if (affectedRoots.isEmpty) {
      debugPrint(
        '[ScannerService] Skip rescan for directory outside active roots: '
        '$normalizedDirectory',
      );
      return;
    }

    if (_scanCoordinator.isScanning) {
      _scanCoordinator.requestRescan();
      return;
    }

    _scanCoordinator.beginIncrementalPhase();
    final scanState = ScanProgressState(
      metadataConcurrency: 2,
      comparePaths: _compareNaturally,
    );

    try {
      final directory = Directory(normalizedDirectory);
      if (!await directory.exists()) {
        await _removeDirectoryFromLibrary(normalizedDirectory);
        _refreshAffectedRootsFromCache(affectedRoots);
        notifyListeners();
        return;
      }

      final discoveredFiles = await _directoryScanner
          .discoverMusicFilesInDirectory(normalizedDirectory, scanState);
      final normalizedDiscoveredPaths = discoveredFiles
          .map((f) => _normalizePath(f.path))
          .where((path) => path.isNotEmpty)
          .toSet();

      final existingPathsInDirectory = _metadataStore.metadataMap.keys
          .where(
            (path) =>
                _isImmediateChildOfDirectory(normalizedDirectory, path) &&
                MusicFileUtils.isMusicFilePath(path),
          )
          .toList(growable: false);

      for (final existingPath in existingPathsInDirectory) {
        if (!normalizedDiscoveredPaths.contains(existingPath)) {
          await _metadataStore.purgeMissingSongPath(existingPath);
        }
      }

      for (final filePath in normalizedDiscoveredPaths) {
        await _upsertIncrementalSongPath(filePath, scanState: scanState);
      }

      _refreshAffectedRootsFromCache(affectedRoots);
      notifyListeners();
    } finally {
      _scanCoordinator.completeIncrementalPhase();
    }
  }

  Future<SongMetadata?> _upsertIncrementalSongPath(
    String filePath, {
    required ScanProgressState scanState,
  }) async {
    final normalizedPath = _normalizePath(filePath);
    if (normalizedPath.isEmpty) {
      return null;
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      await _metadataStore.purgeMissingSongPath(normalizedPath);
      return null;
    }

    final classification = await _classifyDiscoveredFiles([
      ScanDiscoveredFile(path: normalizedPath),
    ]);
    final existingMetadataByPath = Map<String, SongMetadata>.from(
      classification.existingMetadataByPath,
    );
    final existing = existingMetadataByPath[_pathLookupKey(normalizedPath)];
    if (_shouldSkipShortAudioDuration(existing?.duration)) {
      await _metadataStore.purgeMissingSongPath(normalizedPath);
      return null;
    }

    final preprocessResult = await _preprocessChangedFiles(
      classification.pathsFor(ScanFileStage.full),
      scanState,
      existingMetadataByPath: existingMetadataByPath,
    );
    final artworkPendingImageOnlyPaths =
        await _filterImageOnlyPathsNeedingArtwork(
          classification.pathsFor(ScanFileStage.imageOnly),
          scanState,
          existingMetadataByPath: existingMetadataByPath,
        );

    final artworkPendingPaths = [
      ...preprocessResult.artworkPendingPaths,
      ...artworkPendingImageOnlyPaths,
    ];
    if (artworkPendingPaths.isNotEmpty) {
      await _applyArtworkAndThemeToChangedFiles(artworkPendingPaths, scanState);
    }

    if (classification.pathsFor(ScanFileStage.unchanged).isNotEmpty &&
        !_metadataStore.containsPath(normalizedPath)) {
      final dbSong = await _repository.getSongMetadata(normalizedPath);
      if (dbSong != null) {
        _metadataStore.cacheMetadata(dbSong);
      }
    }

    return _metadataStore.getMetadata(normalizedPath) ??
        await _repository.getSongMetadata(normalizedPath);
  }

  Future<void> _removeDirectoryFromLibrary(String directoryPath) async {
    final normalizedPath = _normalizePath(directoryPath);
    if (normalizedPath.isEmpty) {
      return;
    }

    final affectedPaths = _metadataStore.metadataMap.keys
        .where((path) => _pathContains(normalizedPath, path))
        .toList(growable: false);
    for (final path in affectedPaths) {
      await _metadataStore.purgeMissingSongPath(path);
    }
  }

  void _enqueueWatchedPath(String path) {
    if (_isDisposed) return;

    final normalizedPath = _normalizePath(path);
    if (normalizedPath.isEmpty) {
      return;
    }

    final hasMatchingRoot = _roots.rootPaths.any(
      (root) =>
          _pathContains(root, normalizedPath) ||
          _pathsEqual(root, normalizedPath),
    );
    if (!hasMatchingRoot) {
      return;
    }

    try {
      final stat = FileStat.statSync(normalizedPath);
      if (stat.type == FileSystemEntityType.file ||
          stat.type == FileSystemEntityType.directory) {
        final mtime = stat.modified.millisecondsSinceEpoch;
        final cachedMtime = _watchedFileMtimes[normalizedPath];
        if (cachedMtime == mtime) {
          return;
        }
        _watchedFileMtimes[normalizedPath] = mtime;
      } else if (stat.type == FileSystemEntityType.notFound) {
        _watchedFileMtimes.remove(normalizedPath);
      }
    } catch (_) {
      // If we fail to read stats, let it proceed to rescan
    }

    final rescanMode = _determineRescanMode(normalizedPath);
    if (rescanMode == _DirectoryRescanMode.recursive) {
      _queueDirectoryRescan(normalizedPath, _DirectoryRescanMode.recursive);
      return;
    }

    _queueDirectoryRescan(
      _normalizePath(p.dirname(normalizedPath)),
      _DirectoryRescanMode.nonRecursive,
    );
  }

  Future<void> _populateWatchedMtimesFromLibrary() async {
    for (final entry in _metadataStore.metadataMap.entries) {
      final songPath = entry.key;
      final mtime = entry.value.lastModifiedTime;
      if (mtime != null) {
        _watchedFileMtimes[songPath] = mtime;
      }
    }

    final directoriesToStat = <String>{};
    for (final songPath in _metadataStore.metadataMap.keys) {
      directoriesToStat.add(_normalizePath(p.dirname(songPath)));
    }
    for (final root in _roots.rootPaths) {
      directoriesToStat.add(_normalizePath(root));
    }

    final pathList = directoriesToStat.toList(growable: false);
    const batchSize = 50;
    for (var i = 0; i < pathList.length; i += batchSize) {
      final end = i + batchSize < pathList.length ? i + batchSize : pathList.length;
      final chunk = pathList.sublist(i, end);
      await Future.wait(
        chunk.map((path) async {
          try {
            final stat = await FileStat.stat(path);
            if (stat.type != FileSystemEntityType.notFound) {
              _watchedFileMtimes[path] = stat.modified.millisecondsSinceEpoch;
            }
          } catch (_) {
            // ignore
          }
        }),
      );
    }
  }

  _DirectoryRescanMode _determineRescanMode(String path) {
    try {
      final entityType = FileSystemEntity.typeSync(path, followLinks: false);
      if (entityType == FileSystemEntityType.directory) {
        return _DirectoryRescanMode.recursive;
      }
      if (entityType == FileSystemEntityType.notFound &&
          _treeBuilder.resolveFolderForPath(
                path,
                _scannedRootFolders,
                _systemMediaFolder,
              ) !=
              null) {
        return _DirectoryRescanMode.recursive;
      }
    } catch (e, st) {
      debugPrint(
        '[ScannerService] directory type check failed path=$path: '
        '$e\n$st',
      );
    }

    return _DirectoryRescanMode.nonRecursive;
  }

  void _queueDirectoryRescan(String directoryPath, _DirectoryRescanMode mode) {
    if (_isDisposed) return;

    final normalizedPath = _normalizePath(directoryPath);
    if (normalizedPath.isEmpty) {
      return;
    }

    final existingMode = _pendingDirectoryRescanPaths[normalizedPath];
    if (existingMode == _DirectoryRescanMode.recursive ||
        mode == _DirectoryRescanMode.nonRecursive) {
      _pendingDirectoryRescanPaths.putIfAbsent(normalizedPath, () => mode);
    } else {
      _pendingDirectoryRescanPaths[normalizedPath] = mode;
    }
    _directoryRescanTimer?.cancel();
    _directoryRescanTimer = Timer(
      _directoryRescanBatchWindow,
      () => unawaited(_flushPendingDirectoryRescans()),
    );
  }

  Future<void> _flushPendingDirectoryRescans() async {
    _directoryRescanTimer = null;
    if (_isDisposed || _directoryRescanInProgress) {
      return;
    }
    if (_scanCoordinator.isScanning) {
      return;
    }
    if (_pendingDirectoryRescanPaths.isEmpty) {
      return;
    }

    _directoryRescanInProgress = true;
    final directoryPaths = _pendingDirectoryRescanPaths.entries.toList(
      growable: false,
    );
    _pendingDirectoryRescanPaths.clear();

    try {
      final recursiveRoots = <String>{};
      for (final entry in directoryPaths) {
        if (_isDisposed) {
          return;
        }
        if (entry.value == _DirectoryRescanMode.recursive) {
          recursiveRoots.addAll(_rootPathsForDirectoryPath(entry.key));
        }
      }

      if (recursiveRoots.isNotEmpty) {
        await _scanRootsWithFullFlow(recursiveRoots, clearScannedRoots: false);
      }

      for (final entry in directoryPaths) {
        if (_isDisposed) {
          return;
        }
        if (entry.value == _DirectoryRescanMode.nonRecursive) {
          if (recursiveRoots.any((root) => _pathContains(root, entry.key))) {
            continue;
          }
          await _rescanDirectory(entry.key);
        }
      }
    } finally {
      _directoryRescanInProgress = false;
      if (!_isDisposed &&
          _pendingDirectoryRescanPaths.isNotEmpty &&
          _directoryRescanTimer == null) {
        _directoryRescanTimer = Timer(
          Duration.zero,
          () => unawaited(_flushPendingDirectoryRescans()),
        );
      }
    }
  }

  void cancelScan() {
    _scanCoordinator.cancelActiveScan();
  }

  void _restartFullRootScan() {
    _scanCoordinator.requestRescan();
    if (_scanCoordinator.isScanning) {
      return;
    }
    unawaited(scan(clearScannedRoots: false));
  }

  bool _isScanTokenCurrent(int scanToken) {
    return _scanCoordinator.isSessionCurrent(scanToken);
  }

  Future<ScanFileClassification> _classifyDiscoveredFiles(
    List<ScanDiscoveredFile> discoveredFiles, {
    bool Function()? shouldCancel,
  }) async {
    return _scanPipeline.classifyDiscoveredFiles(
      discoveredFiles,
      shouldCancel: shouldCancel,
    );
  }

  void _seedMetadataFromDatabase(
    Map<String, SongMetadata> existingMetadataByPath,
  ) {
    _scanPipeline.seedMetadataFromDatabase(existingMetadataByPath);
  }

  Future<ScanPreprocessResult> _preprocessChangedFiles(
    List<String> fullPaths,
    ScanProgressState scanState, {
    required Map<String, SongMetadata> existingMetadataByPath,
    int? rootScanSessionId,
    bool Function()? shouldCancel,
  }) async {
    if (fullPaths.isEmpty) {
      return const ScanPreprocessResult(
        keptPaths: <String>[],
        artworkPendingPaths: <String>[],
      );
    }

    final db = MetadataDatabase();
    final sortedPaths = fullPaths.toList()..sort(_compareNaturally);
    final totalStopwatch = Stopwatch()..start();
    final keptPaths = <String>[];
    final artworkPendingPaths = <String>[];
    final skippedPaths = <String>[];

    void flushSkippedPaths() {
      if (skippedPaths.isEmpty) return;
      _metadataStore.deleteMissingFromCache(skippedPaths);
      skippedPaths.clear();
    }

    const batchSize = 200;
    for (var start = 0; start < sortedPaths.length; start += batchSize) {
      if (shouldCancel?.call() ?? false) {
        flushSkippedPaths();
        return ScanPreprocessResult(
          keptPaths: keptPaths,
          artworkPendingPaths: artworkPendingPaths,
        );
      }
      final end = start + batchSize < sortedPaths.length
          ? start + batchSize
          : sortedPaths.length;
      final chunk = sortedPaths.sublist(start, end);
      final batchStopwatch = Stopwatch()..start();

      final readStopwatch = Stopwatch()..start();
      final results = await MetadataHelper.readMetadataBatch(
        chunk,
        getImage: false,
      );
      if (shouldCancel?.call() ?? false) {
        flushSkippedPaths();
        return ScanPreprocessResult(
          keptPaths: keptPaths,
          artworkPendingPaths: artworkPendingPaths,
        );
      }
      readStopwatch.stop();
      _logScanTiming(
        'stage 3 batch ${start + 1}-$end readMetadataBatch',
        readStopwatch,
      );

      final writeStopwatch = Stopwatch()..start();
      final metadataBatch = <SongMetadata>[];
      for (final result in results) {
        if (shouldCancel?.call() ?? false) {
          flushSkippedPaths();
          return ScanPreprocessResult(
            keptPaths: keptPaths,
            artworkPendingPaths: artworkPendingPaths,
          );
        }
        final filePath = result['path'] as String? ?? '';
        if (filePath.isEmpty) continue;

        try {
          final existing =
              existingMetadataByPath[_pathLookupKey(filePath)] ??
              await db.getSongMetadata(filePath);
          var metadata = _buildScannedMetadataFromBatchResult(
            filePath,
            result,
            existing: existing,
            sourceFlags: SongSourceFlags.rootScan,
          );
          if (_shouldSkipShortAudioDuration(metadata.duration)) {
            skippedPaths.add(filePath);
            continue;
          }
          final hasArtwork = result['hasArtwork'] as bool? ?? false;
          final hasMetadataError = (result['error'] as String?) != null;
          final shouldRunArtworkScan = await _shouldRunArtworkScanForFile(
            filePath,
            hasArtwork: hasArtwork,
            hasMetadataError: hasMetadataError,
          );
          if (!shouldRunArtworkScan) {
            final processedAt =
                metadata.lastModifiedTime ??
                DateTime.now().millisecondsSinceEpoch;
            metadata = metadata.copyWith(
              artworkPath: null,
              thumbnailPath: null,
              artworkWidth: null,
              artworkHeight: null,
              themeColorsBlob: null,
              metadataImgScanned: processedAt,
            );
            scanState.completedCount++;
          } else {
            artworkPendingPaths.add(filePath);
          }
          metadataBatch.add(metadata);
          keptPaths.add(filePath);
          _metadataStore.cacheMetadata(metadata);
          _pendingStage3IncrementalMetadata.add(metadata);
          scanState.preprocessedCount++;
        } catch (e) {
          debugPrint('Metadata batch scan error for $filePath: $e');
        } finally {
          _emitScanProgress(scanState, filePath);
        }
      }
      if (metadataBatch.isNotEmpty) {
        await db.insertOrUpdateSongsMerged(
          metadataBatch,
          rootScanSessionId: rootScanSessionId,
        );
      }
      writeStopwatch.stop();
      _logScanTiming(
        'stage 3 batch ${start + 1}-$end db+cache update',
        writeStopwatch,
      );
      batchStopwatch.stop();
      _logScanTiming('stage 3 batch ${start + 1}-$end total', batchStopwatch);
    }

    flushSkippedPaths();
    totalStopwatch.stop();
    _logScanTiming('stage 3 preprocess text tags total', totalStopwatch);
    return ScanPreprocessResult(
      keptPaths: keptPaths,
      artworkPendingPaths: artworkPendingPaths,
    );
  }

  Future<List<String>> _filterImageOnlyPathsNeedingArtwork(
    List<String> imageOnlyPaths,
    ScanProgressState scanState, {
    required Map<String, SongMetadata> existingMetadataByPath,
    bool Function()? shouldCancel,
  }) async {
    if (imageOnlyPaths.isEmpty) return const <String>[];

    final db = MetadataDatabase();
    final sortedPaths = imageOnlyPaths.toList()..sort(_compareNaturally);
    final artworkPendingPaths = <String>[];
    const batchSize = 200;

    for (var start = 0; start < sortedPaths.length; start += batchSize) {
      if (shouldCancel?.call() ?? false) {
        return artworkPendingPaths;
      }
      final end = start + batchSize < sortedPaths.length
          ? start + batchSize
          : sortedPaths.length;
      final chunk = sortedPaths.sublist(start, end);
      final results = await MetadataHelper.readMetadataBatch(
        chunk,
        getImage: false,
      );
      if (shouldCancel?.call() ?? false) {
        return artworkPendingPaths;
      }

      final metadataBatch = <SongMetadata>[];
      for (final result in results) {
        if (shouldCancel?.call() ?? false) {
          return artworkPendingPaths;
        }
        final filePath = result['path'] as String? ?? '';
        if (filePath.isEmpty) continue;

        try {
          final existing =
              existingMetadataByPath[_pathLookupKey(filePath)] ??
              _metadataStore.getMetadata(filePath) ??
              await db.getSongMetadata(filePath);
          if (existing == null) {
            artworkPendingPaths.add(filePath);
            continue;
          }

          final hasArtwork = result['hasArtwork'] as bool? ?? false;
          final hasMetadataError = (result['error'] as String?) != null;
          final shouldRunArtworkScan = await _shouldRunArtworkScanForFile(
            filePath,
            hasArtwork: hasArtwork,
            hasMetadataError: hasMetadataError,
          );
          if (shouldRunArtworkScan) {
            artworkPendingPaths.add(filePath);
            continue;
          }

          final processedAt =
              existing.lastModifiedTime ??
              DateTime.now().millisecondsSinceEpoch;
          final updatedMetadata = existing.copyWith(
            artworkPath: null,
            thumbnailPath: null,
            artworkWidth: null,
            artworkHeight: null,
            themeColorsBlob: null,
            metadataImgScanned: processedAt,
          );
          metadataBatch.add(updatedMetadata);
          _metadataStore.cacheMetadata(updatedMetadata);
          existingMetadataByPath[_pathLookupKey(filePath)] = updatedMetadata;
          scanState.completedCount++;
        } catch (e) {
          debugPrint('Image-only artwork probe error for $filePath: $e');
          artworkPendingPaths.add(filePath);
        } finally {
          _emitScanProgress(scanState, filePath);
        }
      }

      if (metadataBatch.isNotEmpty) {
        await db.insertOrUpdateSongsMerged(metadataBatch);
      }
    }

    return artworkPendingPaths;
  }

  void _removeRootsFromScannedTree(Iterable<String> roots) {
    final normalizedRoots = _normalizeDeclaredRootPaths(roots);
    if (normalizedRoots.isEmpty) return;
    _scannedRootFolders.removeWhere(
      (folder) => normalizedRoots.any((root) => _pathsEqual(folder.path, root)),
    );
  }

  Future<void> _purgeRemovedRootsFromMetadataCache(Iterable<String> roots) async {
    final normalizedRoots = _normalizeDeclaredRootPaths(roots);
    if (normalizedRoots.isEmpty) return;

    await _repository.unbindRootPaths(normalizedRoots);

    final sweepResult = await _repository.sweepOrphanSongs();
    if (sweepResult.deletedPaths.isEmpty) return;

    _metadataStore.deleteMissingFromCache(
      sweepResult.deletedPaths,
      updateVisibleTrees: false,
    );
    for (final path in sweepResult.deletedPaths) {
      _notifySongMissingState(path, true);
    }
  }

  bool _isScanRootStillActive(String rootPath, {bool checkDisk = false}) {
    final currentScanRoots = _computeScanRoots(_roots.rootPaths);
    if (!currentScanRoots.any((current) => _pathsEqual(current, rootPath))) {
      return false;
    }
    if (!checkDisk) {
      return true;
    }
    try {
      final exists = Directory(rootPath).existsSync();
      if (!exists) {
        debugPrint(
          '[ScannerService] scan root inactive because path no longer exists '
          'path=$rootPath',
        );
      }
      return exists;
    } catch (e, st) {
      debugPrint(
        '[ScannerService] scan root inactive because existsSync failed '
        'path=$rootPath: $e\n$st',
      );
      return false;
    }
  }

  Future<List<ScanDiscoveredFile>> _discoverRootFilePaths(
    String rootPath,
    ScanProgressState scanState,
    int scanToken,
  ) async {
    if (!_isScanTokenCurrent(scanToken) || !_isScanRootStillActive(rootPath)) {
      debugPrint(
        '[ScannerService] skip directory traversal for stale root '
        'path=$rootPath',
      );
      return const <ScanDiscoveredFile>[];
    }
    debugPrint(
      '[ScannerService] begin directory traversal path=$rootPath '
      'scanToken=$scanToken',
    );
    final discoveredFiles = await _directoryScanner.discoverMusicFiles(
      rootPath,
      scanState,
      shouldCancel: () =>
          !_isScanTokenCurrent(scanToken) || !_isScanRootStillActive(rootPath),
    );
    debugPrint(
      '[ScannerService] directory traversal finished path=$rootPath '
      'count=${discoveredFiles.length}',
    );
    if (!_isScanTokenCurrent(scanToken) || !_isScanRootStillActive(rootPath)) {
      _scannedRootFolders.removeWhere(
        (existing) => _pathsEqual(existing.path, rootPath),
      );
      debugPrint(
        '[ScannerService] discard traversal result for stale root '
        'path=$rootPath',
      );
      return const <ScanDiscoveredFile>[];
    }
    if (discoveredFiles.isEmpty) {
      _scannedRootFolders.removeWhere(
        (existing) => _pathsEqual(existing.path, rootPath),
      );
      debugPrint(
        '[ScannerService] traversal found no music files path=$rootPath',
      );
      return const <ScanDiscoveredFile>[];
    }
    return discoveredFiles;
  }

  void _rebuildScannedRootFolderFromMetadata(
    String rootPath,
    Iterable<String> discoveredPaths,
  ) {
    final metadataByLookupKey = <String, SongMetadata>{};
    for (final path in discoveredPaths) {
      final normalizedPath = _normalizePath(path);
      if (normalizedPath.isEmpty) {
        continue;
      }
      final metadata =
          _metadataStore.getMetadata(normalizedPath) ??
          _metadataStore.getMetadata(path);
      if (metadata == null) {
        continue;
      }
      metadataByLookupKey[_pathLookupKey(normalizedPath)] = metadata;
    }

    if (metadataByLookupKey.isEmpty) {
      _scannedRootFolders.removeWhere(
        (existing) => _pathsEqual(existing.path, rootPath),
      );
      return;
    }

    final rootFolder = _timeScanStepSync(
      'stage 4.2 build metadata tree for $rootPath',
      () => _treeBuilder.buildFolderTreeFromMetadata(
        metadataByLookupKey.values,
        _compareNaturally,
        rootPath: rootPath,
        rootName: _displayNameForPath(rootPath),
      ),
    );
    _folderSorter.sortFolderRecursiveForTree(
      rootFolder,
      resolveSettings: _resolveSortSettingsForFolder,
    );
    _upsertScannedRootFolder(rootFolder);
  }

  void _rebuildScannedRootFolderFromCache(String rootPath) {
    final songs = _metadataStore.metadataMap.values.where(
      (song) =>
          _songMatchesSource(
            song,
            SongSourceFlags.rootScan,
            includeLegacy: true,
          ) &&
          _shouldKeepSongMetadata(song) &&
          _pathContains(rootPath, song.path),
    );
    final rootFolder = _buildCachedFolderTree(
      songs: songs,
      rootPath: rootPath,
      rootName: _displayNameForPath(rootPath),
    );
    if (rootFolder == null) {
      _scannedRootFolders.removeWhere(
        (existing) => _pathsEqual(existing.path, rootPath),
      );
      return;
    }
    _folderSorter.sortFolderRecursiveForTree(
      rootFolder,
      resolveSettings: _resolveSortSettingsForFolder,
    );
    _upsertScannedRootFolder(rootFolder);
  }

  void _refreshAffectedRootsFromCache(Iterable<String> affectedRoots) {
    for (final rootPath in affectedRoots) {
      _rebuildScannedRootFolderFromCache(rootPath);
    }
    if (affectedRoots.isNotEmpty) {
      _rebuildDisplayedRootFolders();
      _syncNavigationStateToLatestTree();
    }
  }

  Set<String> _rootPathsForDirectoryPath(String path) {
    final normalizedPath = _normalizePath(path);
    if (normalizedPath.isEmpty) {
      return <String>{};
    }
    return _roots.rootPaths
        .where(
          (rootPath) =>
              _pathContains(rootPath, normalizedPath) ||
              _pathContains(normalizedPath, rootPath),
        )
        .toSet();
  }

  Future<_RootArtworkScanJob?> _processDiscoveredPaths(
    List<ScanDiscoveredFile> discoveredFiles,
    ScanProgressState scanState,
    int scanToken, {
    required String rootPath,
  }) async {
    if (discoveredFiles.isEmpty) {
      return null;
    }
    if (!_isScanTokenCurrent(scanToken) || !_isScanRootStillActive(rootPath)) {
      return null;
    }

    final classification = await _timeScanStep(
      'stage 2 classify discovered files batch',
      () => _classifyDiscoveredFiles(
        discoveredFiles,
        shouldCancel: () =>
            !_isScanTokenCurrent(scanToken) ||
            !_isScanRootStillActive(rootPath),
      ),
    );
    if (!_isScanTokenCurrent(scanToken) || !_isScanRootStillActive(rootPath)) {
      return null;
    }
    final existingMetadataByPath = Map<String, SongMetadata>.from(
      classification.existingMetadataByPath,
    );
    existingMetadataByPath.removeWhere(
      (path, metadata) => _shouldSkipShortAudioDuration(metadata.duration),
    );
    _timeScanStepSync('stage 2.1 seed metadata from db batch', () {
      _seedMetadataFromDatabase(existingMetadataByPath);
    });

    final skippedKnownPaths = <String>[];
    final fullPaths = <String>[];
    final imageOnlyPaths = <String>[];
    final unchangedPaths = <String>[];

    for (final entry in classification.stageByPath.entries) {
      final path = entry.key;
      final stage = entry.value;
      final existing =
          classification.existingMetadataByPath[_pathLookupKey(path)];
      if (_shouldSkipShortAudioDuration(existing?.duration)) {
        skippedKnownPaths.add(path);
        continue;
      }
      switch (stage) {
        case ScanFileStage.full:
          fullPaths.add(path);
          break;
        case ScanFileStage.imageOnly:
          imageOnlyPaths.add(path);
          break;
        case ScanFileStage.unchanged:
          unchangedPaths.add(path);
          break;
      }
    }
    if (skippedKnownPaths.isNotEmpty) {
      for (final path in skippedKnownPaths) {
        _metadataStore.removeMetadataForPath(path);
      }
    }

    Timer? stage3UiSyncTimer;
    try {
      _pendingStage3IncrementalMetadata.clear();
      stage3UiSyncTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!_isScanTokenCurrent(scanToken) ||
            !_isScanRootStillActive(rootPath)) {
          return;
        }
        _syncScannedRootUiIncrementally(rootPath);
      });

      final preprocessResult = await _timeScanStep(
        'stage 3 preprocess text tags batch',
        () => _preprocessChangedFiles(
          fullPaths,
          scanState,
          existingMetadataByPath: existingMetadataByPath,
          shouldCancel: () =>
              !_isScanTokenCurrent(scanToken) ||
              !_isScanRootStillActive(rootPath),
        ),
      );
      if (!_isScanTokenCurrent(scanToken) ||
          !_isScanRootStillActive(rootPath)) {
        return null;
      }
      final keptFullPaths = preprocessResult.keptPaths;
      final artworkPendingImageOnlyPaths = await _timeScanStep(
        'stage 3.1 preprocess image-only artwork batch',
        () => _filterImageOnlyPathsNeedingArtwork(
          imageOnlyPaths,
          scanState,
          existingMetadataByPath: existingMetadataByPath,
          shouldCancel: () =>
              !_isScanTokenCurrent(scanToken) ||
              !_isScanRootStillActive(rootPath),
        ),
      );
      if (!_isScanTokenCurrent(scanToken) ||
          !_isScanRootStillActive(rootPath)) {
        return null;
      }

      final visiblePaths = <String>[
        ...unchangedPaths,
        ...keptFullPaths,
        ...imageOnlyPaths,
      ];

      await _timeScanStep(
        'stage 3.1 mark root scan token batch',
        () async {
          await MetadataDatabase().markRootScanSeenWithToken(
            visiblePaths,
            scanToken: scanToken,
            sourceMask: SongSourceFlags.rootScan,
          );
          await MetadataDatabase().bindSongsToRootBatch(
            visiblePaths,
            rootPath,
          );
        },
      );
      if (!_isScanTokenCurrent(scanToken) ||
          !_isScanRootStillActive(rootPath)) {
        return null;
      }

      await Future<void>.delayed(Duration.zero);
      _timeScanStepSync('stage 3.2 rebuild visible root tree', () {
        _rebuildScannedRootFolderFromMetadata(rootPath, visiblePaths);
        _rebuildDisplayedRootFolders();
        _syncNavigationStateToLatestTree(affectedRootPath: rootPath);
      });
      scanState.pendingMetadataPaths.addAll(visiblePaths);
      notifyListeners();

      return _RootArtworkScanJob(
        rootPath: rootPath,
        visiblePaths: visiblePaths,
        artworkPendingPaths: [
          ...preprocessResult.artworkPendingPaths,
          ...artworkPendingImageOnlyPaths,
        ],
      );
    } finally {
      stage3UiSyncTimer?.cancel();
      _pendingStage3IncrementalMetadata.clear();
    }
  }

  Future<void> _applyArtworkAndThemeToChangedFiles(
    List<String> imageOnlyPaths,
    ScanProgressState scanState, {
    bool Function()? shouldCancel,
  }) async {
    if (imageOnlyPaths.isEmpty) return;

    final sortedPaths = imageOnlyPaths.toList()..sort(_compareNaturally);
    final totalStopwatch = Stopwatch()..start();
    final supportDir = await getApplicationSupportDirectory();
    final controller = _playerController ?? AudioCoreController();
    if (!controller.isInitialized) {
      await controller.initialize();
    }

    final db = MetadataDatabase();
    final metadataBatch = <SongMetadata>[];
    final progressStopwatch = Stopwatch()..start();
    String? lastProcessedPath;

    Future<void> flushMetadataBatch() async {
      if (metadataBatch.isEmpty) return;
      final batchToFlush = List<SongMetadata>.from(metadataBatch);
      metadataBatch.clear();
      await db.insertOrUpdateSongsMerged(batchToFlush);
    }

    void tryEmitThrottledProgress(String filePath, {bool force = false}) {
      lastProcessedPath = filePath;
      if (force || progressStopwatch.elapsedMilliseconds >= 1000) {
        progressStopwatch.reset();
        _emitScanProgress(scanState, filePath);
      }
    }

    try {
      final batchSize = Platform.isWindows ? 4 : 6;
      for (var start = 0; start < sortedPaths.length; start += batchSize) {
        if (shouldCancel?.call() ?? false) {
          await flushMetadataBatch();
          return;
        }
        final end = start + batchSize < sortedPaths.length
            ? start + batchSize
            : sortedPaths.length;
        final batch = sortedPaths.sublist(start, end);
        final batchStopwatch = Stopwatch()..start();

        final results = await Future.wait(
          batch.map(
            (filePath) => _processArtworkAndThemeWithAudioCore(
              filePath: filePath,
              controller: controller,
              supportDirPath: supportDir.path,
              scanState: scanState,
              shouldCancel: shouldCancel,
            ),
          ),
        );

        for (final metadata in results) {
          if (metadata != null) {
            metadataBatch.add(metadata);
            tryEmitThrottledProgress(metadata.path);
          }
        }

        if (metadataBatch.length >= 100) {
          await flushMetadataBatch();
        }

        batchStopwatch.stop();
        _logScanTiming('stage 4 batch ${start + 1}-$end total', batchStopwatch);
      }

      await flushMetadataBatch();
      if (lastProcessedPath != null) {
        tryEmitThrottledProgress(lastProcessedPath!, force: true);
      }
    } catch (e) {
      debugPrint(
        'AudioCore artwork scan failed, falling back to serial mode: $e',
      );
      final fallbackStopwatch = Stopwatch()..start();
      for (final filePath in sortedPaths) {
        if (shouldCancel?.call() ?? false) {
          await flushMetadataBatch();
          return;
        }
        final metadata = await _processArtworkAndThemeWithAudioCore(
          filePath: filePath,
          controller: controller,
          supportDirPath: supportDir.path,
          scanState: scanState,
          shouldCancel: shouldCancel,
        );
        if (metadata != null) {
          metadataBatch.add(metadata);
          tryEmitThrottledProgress(metadata.path);
        }
        if (metadataBatch.length >= 100) {
          await flushMetadataBatch();
        }
      }
      await flushMetadataBatch();
      if (lastProcessedPath != null) {
        tryEmitThrottledProgress(lastProcessedPath!, force: true);
      }
      fallbackStopwatch.stop();
      _logScanTiming('stage 4 fallback serial total', fallbackStopwatch);
    }

    totalStopwatch.stop();
    _logScanTiming('stage 4 preprocess artwork/theme total', totalStopwatch);
  }

  Future<SongMetadata?> _processArtworkAndThemeWithAudioCore({
    required String filePath,
    required AudioCoreController controller,
    required String supportDirPath,
    required ScanProgressState scanState,
    bool Function()? shouldCancel,
  }) async {
    final db = MetadataDatabase();
    final artworkThemeService = TrackArtworkThemeService(db: db);
    final totalStopwatch = Stopwatch()..start();

    try {
      if (shouldCancel?.call() ?? false) {
        return null;
      }
      final baseMetadata =
          _metadataStore.getMetadata(filePath) ??
          await db.getSongMetadata(filePath);
      if (baseMetadata == null) {
        return null;
      }

      final nativeStopwatch = Stopwatch()..start();
      final processedAt =
          baseMetadata.lastModifiedTime ??
          DateTime.now().millisecondsSinceEpoch;

      final artwork = await artworkThemeService.getTrackArtworkTheme(
        filePath,
        controller: controller,
        cacheRootPath: supportDirPath,
        saveLargeArtwork: false,
        thumbnailSize: vynodyArtworkThumbnailSize,
        saveToDatabase: false,
      );
      nativeStopwatch.stop();
      _logScanTiming('stage 4 native artwork $filePath', nativeStopwatch);

      if (shouldCancel?.call() ?? false) {
        return null;
      }

      var updatedMetadata = baseMetadata.copyWith(
        artworkPath: artwork?.artworkPath ?? baseMetadata.artworkPath,
        thumbnailPath: artwork?.thumbnailPath ?? baseMetadata.thumbnailPath,
        artworkWidth: artwork?.artworkWidth ?? baseMetadata.artworkWidth,
        artworkHeight: artwork?.artworkHeight ?? baseMetadata.artworkHeight,
        themeColorsBlob:
            artwork?.themeColorsBlob ?? baseMetadata.themeColorsBlob,
        metadataImgScanned: processedAt,
      );

      _metadataStore.cacheMetadata(updatedMetadata);
      scanState.completedCount++;
      return updatedMetadata;
    } catch (e) {
      debugPrint('AudioCore artwork/theme scan error for $filePath: $e');
      return null;
    } finally {
      totalStopwatch.stop();
      _logScanTiming('stage 4 item $filePath total', totalStopwatch);
    }
  }

  SongMetadata _buildScannedMetadataFromBatchResult(
    String filePath,
    Map<String, dynamic> result, {
    SongMetadata? existing,
    int? sourceFlags,
    int? mediaId,
    String? fallbackTitle,
    String? fallbackAlbum,
    String? fallbackArtist,
    int? fallbackDuration,
    int? fallbackTrackNumber,
  }) {
    return _scanPipeline.buildScannedMetadataFromBatchResult(
      filePath,
      result,
      existing: existing,
      sourceFlags: sourceFlags,
      mediaId: mediaId,
      fallbackTitle: fallbackTitle,
      fallbackAlbum: fallbackAlbum,
      fallbackArtist: fallbackArtist,
      fallbackDuration: fallbackDuration,
      fallbackTrackNumber: fallbackTrackNumber,
    );
  }

  Future<void> scan({bool clearScannedRoots = false}) async {
    _failedThumbnailPaths.clear();
    _watchedFileMtimes.clear();
    await _scanRootsWithFullFlow(
      _roots.rootPaths,
      clearScannedRoots: clearScannedRoots,
    );
  }

  Future<void> rebuildIndex() async {
    final stopwatch = Stopwatch()..start();
    try {
      // 1. Clear songs in database except external
      await _repository.clearSongsExceptExternal();

      // 2. Clear matching in-memory metadata
      _metadataStore.metadataMap.removeWhere((path, metadata) {
        final flags = metadata.sourceFlags ?? 0;
        return (flags & SongSourceFlags.external) == 0;
      });
      _failedThumbnailPaths.clear();
      _watchedFileMtimes.clear();
      _markMetadataMutated();
      _markAlbumLibraryMutated();

      // 3. Clear current folder structure and notify UI
      _scannedRootFolders.clear();
      _rebuildDisplayedRootFolders();
      _syncNavigationStateToLatestTree();
      notifyListeners();

      // 4. Trigger rescan of all root paths
      await scan(clearScannedRoots: true);
    } finally {
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          '[ScannerService] rebuildIndex completed in ${stopwatch.elapsedMilliseconds} ms',
        );
      }
    }
  }

  Future<void> _scanRootsWithFullFlow(
    Iterable<String> rootsToScan, {
    required bool clearScannedRoots,
  }) async {
    await _loadScanSettings();
    final requestedRoots = _computeScanRoots(rootsToScan);
    if (requestedRoots.isEmpty) {
      if (clearScannedRoots) {
        _scannedRootFolders.clear();
        _rebuildDisplayedRootFolders();
        _syncNavigationStateToLatestTree();
        notifyListeners();
      }
      return;
    }

    await _scanCoordinator.runFullScan(
      (scanToken) => _runFullScanSession(
        scanToken,
        requestedRoots: requestedRoots,
        clearScannedRoots: clearScannedRoots,
      ),
    );
  }

  Future<void> _runFullScanSession(
    int scanToken, {
    required List<String> requestedRoots,
    required bool clearScannedRoots,
  }) async {
    final artworkJobs = <_RootArtworkScanJob>[];
    notifyListeners();

    final totalStopwatch = Stopwatch()..start();
    try {
      final permissionsStopwatch = Stopwatch()..start();
      final hasPermission = await _checkPermissions(request: false);
      permissionsStopwatch.stop();
      _logScanTiming('stage 0 permissions', permissionsStopwatch);

      if (Platform.isAndroid && hasPermission) {
        _hasPermission = true;
        if (_systemMediaFolder == null) {
          unawaited(scanSystemMedia());
        }
      }

      final scanState = ScanProgressState(
        metadataConcurrency: 4,
        comparePaths: _compareNaturally,
      );
      final scanRoots = _timeScanStepSync('stage 1 root discovery', () {
        final roots = requestedRoots.toList(growable: false);
        roots.sort(_compareNaturally);
        debugPrint(
          '[ScannerService] scan root discovery requested=$requestedRoots '
          'resolved=$roots currentRoots=${_roots.rootPaths}',
        );
        return roots;
      });

      if (clearScannedRoots) {
        _scannedRootFolders.clear();
        _loadedRootPaths.removeWhere((path) => path != 'system');
      }
      _rebuildDisplayedRootFolders();
      _syncNavigationStateToLatestTree();
      notifyListeners();

      for (final path in scanRoots) {
        if (!_isScanTokenCurrent(scanToken) || !_isScanRootStillActive(path)) {
          debugPrint(
            '[ScannerService] Skipping stale scan root after scan restart: $path',
          );
          continue;
        }
        _scanCoordinator.setActiveRootPath(path);
        debugPrint('Starting scan at: $path');

        final discoveredPaths = await _timeScanStep(
          'stage 1.1 directory traversal for $path',
          () => _discoverRootFilePaths(path, scanState, scanToken),
        );
        debugPrint(
          '[ScannerService] traversal stage returned path=$path '
          'count=${discoveredPaths.length}',
        );

        if (!_isScanTokenCurrent(scanToken) || !_isScanRootStillActive(path)) {
          debugPrint(
            '[ScannerService] Discarding stale scan result after scan restart: $path',
          );
          _scannedRootFolders.removeWhere(
            (existing) => _pathsEqual(existing.path, path),
          );
          continue;
        }

        final artworkJob = await _processDiscoveredPaths(
          discoveredPaths,
          scanState,
          scanToken,
          rootPath: path,
        );
        if (artworkJob != null) {
          artworkJobs.add(artworkJob);
        }

        if (!_isScanTokenCurrent(scanToken) || !_isScanRootStillActive(path)) {
          debugPrint(
            '[ScannerService] Root scan became stale before tree refresh: $path',
          );
          _scannedRootFolders.removeWhere(
            (existing) => _pathsEqual(existing.path, path),
          );
          continue;
        }
      }

      if (_isScanTokenCurrent(scanToken)) {
        _scanCoordinator.beginArtworkPhase(scanToken);
        for (final job in artworkJobs) {
          if (!_isScanTokenCurrent(scanToken) ||
              !_isScanRootStillActive(job.rootPath)) {
            continue;
          }

          _scanCoordinator.setActiveRootPath(job.rootPath);
          await _timeScanStep(
            'stage 4 preprocess artwork/theme batch for ${job.rootPath}',
            () => _applyArtworkAndThemeToChangedFiles(
              job.artworkPendingPaths,
              scanState,
              shouldCancel: () =>
                  !_isScanTokenCurrent(scanToken) ||
                  !_isScanRootStillActive(job.rootPath),
            ),
          );

          if (!_isScanTokenCurrent(scanToken) ||
              !_isScanRootStillActive(job.rootPath)) {
            continue;
          }

          _timeScanStepSync(
            'stage 4.2 rebuild root tree from metadata for ${job.rootPath}',
            () {
              _rebuildScannedRootFolderFromMetadata(
                job.rootPath,
                job.visiblePaths,
              );
            },
          );
        }
      }

      if (_isScanTokenCurrent(scanToken)) {
        final presentPaths = _timeScanStepSync(
          'stage 5 collect present paths',
          () {
            return scanState.pendingMetadataPaths
                .map(_normalizePath)
                .where((path) => path.isNotEmpty)
                .toSet();
          },
        );
        final sweepResult = await _timeScanStep(
          'stage 5.1 sweep root scan state',
          () => _repository.sweepRootScanState(
            scanToken: scanToken,
            sourceMask: SongSourceFlags.rootScan,
            activeRoots: scanRoots,
          ),
        );
        _timeScanStepSync('stage 5.4 notify missing states', () {
          for (final path in presentPaths) {
            _notifySongMissingState(path, false);
          }
          for (final path in sweepResult.deletedPaths) {
            _notifySongMissingState(path, true);
          }
          for (final path in sweepResult.softDeletedPaths) {
            _notifySongMissingState(path, true);
            _metadataStore.removeMetadataForPath(path);
          }
        });
      }
    } catch (e) {
      debugPrint('Scan error: $e');
    } finally {
      try {
        await _timeScanStep(
          'populate watched mtimes from library',
          () async => _populateWatchedMtimesFromLibrary(),
        );
      } catch (e) {
        debugPrint('[ScannerService] Failed to populate watched mtimes: $e');
      }
      _flushScanNotifications();
      _scanCoordinator.setActiveRootPath(null);
      await _timeScanStep(
        'stage 5.7 final sort and notify',
        () async => _sortAndNotify(),
      );
      totalStopwatch.stop();
      _logScanTiming('scan total', totalStopwatch);
    }
  }

  Future<void> rebuildMetadataDatabase() async {
    if (Platform.isWindows) {
      await MetadataDatabase().clearAll();
      await MetadataHelper.clearThumbnails();
      _metadataStore.clear();
      await scan();
    }
  }

  /// Loads metadata for a single path from the DB (or processes it fresh) and
  /// caches it in [metadataMap]. Safe to call multiple times.
  Future<void> loadMetadataForPath(String path) async {
    await _metadataStore.loadMetadataForPath(path);
  }

  /// Forces a full metadata re-read for the given paths and writes the
  /// refreshed records back into the database and in-memory cache.
  Future<void> refreshMetadataForPaths(Iterable<String> paths) async {
    for (final path in paths) {
      await refreshMetadataForPath(path);
    }
  }

  /// Forces a full metadata re-read for one path.
  Future<void> refreshMetadataForPath(String path) async {
    final normalizedPath = _normalizePath(path);
    if (normalizedPath.isEmpty) {
      return;
    }
    _failedThumbnailPaths.remove(normalizedPath);

    final file = File(normalizedPath);
    if (!await file.exists()) {
      debugPrint(
        '[ScannerService] refreshMetadataForPath skipped missing file '
        'path=$normalizedPath',
      );
      return;
    }

    try {
      final processed = await MetadataHelper.processMetadata(
        normalizedPath,
        generateThumbnail: true,
        forceRefresh: true,
      );
      if (processed == null) {
        debugPrint(
          '[ScannerService] refreshMetadataForPath failed to process '
          'path=$normalizedPath',
        );
        return;
      }

      final metadata = processed.$1;
      final artworkBytes = processed.$2;
      _metadataStore.updateMetadataForPath(
        metadata,
        artworkBytes: artworkBytes,
      );
    } catch (e) {
      debugPrint(
        '[ScannerService] refreshMetadataForPath error path=$normalizedPath: '
        '$e',
      );
    }
  }

  Future<void> loadThumbnailForPath(String path) async {
    if (_failedThumbnailPaths.contains(path)) {
      return;
    }
    await _metadataStore.loadThumbnailForPath(path);
    final cached =
        _metadataStore.getMetadata(path) ??
        await MetadataDatabase().getSongMetadata(path);
    if (cached != null && (cached.thumbnailPath?.trim().isNotEmpty ?? false)) {
      if (await File(cached.thumbnailPath!).exists()) {
        return;
      }
    }
    final updated = await _recoverThumbnailCacheWithAudioCore(
      path,
      existingMetadata: cached,
    );
    if (updated == null ||
        updated.thumbnailPath == null ||
        updated.thumbnailPath!.trim().isEmpty) {
      _failedThumbnailPaths.add(path);
    }
  }

  void updateMetadataForPath(SongMetadata metadata, {Uint8List? artworkBytes}) {
    _failedThumbnailPaths.remove(metadata.path);
    _metadataStore.updateMetadataForPath(metadata, artworkBytes: artworkBytes);
  }

  void _emitScanProgress(ScanProgressState scanState, String filePath) {
    _scanProgressController.add(
      ScanProgress(
        filePath: filePath,
        discoveredCount: scanState.discoveredCount,
        preprocessedCount: scanState.preprocessedCount,
        completedCount: scanState.completedCount,
      ),
    );
  }

  Future<SongMetadata?> _recoverThumbnailCacheWithAudioCore(
    String path, {
    SongMetadata? existingMetadata,
    bool notifyStore = true,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }

    final hasEmbeddedArtwork = await MetadataHelper.hasEmbeddedArtwork(path);
    if (!hasEmbeddedArtwork) {
      return null;
    }

    try {
      final controller = _playerController ?? AudioCoreController();
      final artwork = await TrackArtworkThemeService(db: MetadataDatabase())
          .getTrackArtworkTheme(
            path,
            controller: controller,
            saveLargeArtwork: false,
            thumbnailSize: vynodyArtworkThumbnailSize,
          );

      if (artwork == null || !artwork.hasThumbnailPath) {
        return null;
      }

      int? resolvedFlags = existingMetadata?.sourceFlags;
      final isInsideRoot = _roots.rootPaths.any(
        (root) => _pathContains(root, path),
      );
      if (isInsideRoot) {
        if (resolvedFlags == null) {
          resolvedFlags = SongSourceFlags.rootScan;
        } else {
          resolvedFlags =
              (resolvedFlags & ~SongSourceFlags.external) |
              SongSourceFlags.rootScan;
        }
      } else if (resolvedFlags == null) {
        resolvedFlags = SongSourceFlags.external;
      }

      final lastModified =
          existingMetadata?.lastModifiedTime ??
          (await file.lastModified()).millisecondsSinceEpoch;
      final now = DateTime.now().millisecondsSinceEpoch;
      final updated =
          (existingMetadata ??
                  SongMetadata(
                    path: path,
                    title: p.basenameWithoutExtension(path),
                    album: 'Unknown Album',
                    artist: 'Unknown Artist',
                    lastModifiedTime: lastModified,
                    metadataTextScanned: lastModified,
                    createdAt: now,
                    sourceFlags: resolvedFlags,
                  ))
              .copyWith(
                artworkPath:
                    artwork.artworkPath ?? existingMetadata?.artworkPath,
                thumbnailPath:
                    artwork.thumbnailPath ?? existingMetadata?.thumbnailPath,
                artworkWidth:
                    artwork.artworkWidth ?? existingMetadata?.artworkWidth,
                artworkHeight:
                    artwork.artworkHeight ?? existingMetadata?.artworkHeight,
                themeColorsBlob:
                    artwork.themeColorsBlob ??
                    existingMetadata?.themeColorsBlob,
                lastModifiedTime: lastModified,
                metadataImgScanned: lastModified,
                createdAt: existingMetadata?.createdAt ?? now,
                sourceFlags: resolvedFlags,
              );

      await MetadataDatabase().insertOrUpdateSong(updated);
      _metadataStore.updateMetadataForPath(updated, notify: notifyStore);
      return updated;
    } catch (e) {
      debugPrint('Thumbnail recovery with audio core failed for $path: $e');
      return null;
    }
  }

  int _compareNaturally(String a, String b) {
    if (identical(a, b) || a == b) return 0;
    return compareNatural(a.toLowerCase(), b.toLowerCase());
  }

  FolderSortSettings get _currentSortSettings {
    final currentFolder = _navigationState.currentFolder;
    if (currentFolder == null) {
      return FolderSortSettings(
        criteria: _globalSortCriteria,
        order: _globalSortOrder,
      );
    }
    return _resolveSortSettingsForFolder(currentFolder.path);
  }

  FolderSortSettings getGlobalSortSettings() {
    return FolderSortSettings(
      criteria: _globalSortCriteria,
      order: _globalSortOrder,
    );
  }

  FolderSortSettings getSortSettingsForFolder(String path) {
    return _resolveSortSettingsForFolder(path);
  }

  bool hasSortOverrideForFolder(String path) {
    return _folderSortOverrides.containsKey(_sortFolderKey(path));
  }

  SortScope get sortScopeForCurrentView {
    final currentFolder = _navigationState.currentFolder;
    if (currentFolder == null) {
      return SortScope.global;
    }
    return hasSortOverrideForFolder(currentFolder.path)
        ? SortScope.currentFolder
        : SortScope.global;
  }

  FolderSortSettings _resolveSortSettingsForFolder(String path) {
    final override = _folderSortOverrides[_sortFolderKey(path)];
    if (override != null) {
      return override;
    }
    return FolderSortSettings(
      criteria: _globalSortCriteria,
      order: _globalSortOrder,
    );
  }

  String _sortFolderKey(String path) {
    return _pathLookupKey(path);
  }

  bool _updateFolderSortSettings({
    String? folderPath,
    SortCriteria? criteria,
    SortOrder? order,
  }) {
    final targetPath = folderPath ?? _navigationState.currentFolder?.path;
    if (targetPath == null) {
      return false;
    }

    final key = _sortFolderKey(targetPath);
    final currentSettings =
        _folderSortOverrides[key] ??
        FolderSortSettings(
          criteria: _globalSortCriteria,
          order: _globalSortOrder,
        );
    final nextSettings = currentSettings.copyWith(
      criteria: criteria,
      order: order,
    );

    if (currentSettings.criteria == nextSettings.criteria &&
        currentSettings.order == nextSettings.order) {
      return true;
    }

    _folderSortOverrides = {..._folderSortOverrides, key: nextSettings};
    unawaited(_saveFolderSortOverrides());
    return true;
  }

  Future<void> _loadSortSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _globalSortCriteria = SortCriteriaX.fromStorageValue(
      prefs.getString(_keyGlobalSortCriteria),
    );
    _globalSortOrder = SortOrderX.fromStorageValue(
      prefs.getString(_keyGlobalSortOrder),
    );
    _folderSortOverrides = _decodeFolderSortOverrides(
      prefs.getString(_keyFolderSortOverrides),
    );
  }

  Map<String, FolderSortSettings> _decodeFolderSortOverrides(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return {};
      }

      final result = <String, FolderSortSettings>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is! Map<String, dynamic>) continue;
        result[entry.key] = FolderSortSettings.fromJson(value);
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveGlobalSortSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyGlobalSortCriteria,
      _globalSortCriteria.storageValue,
    );
    await prefs.setString(_keyGlobalSortOrder, _globalSortOrder.storageValue);
  }

  Future<void> _saveFolderSortOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      for (final entry in _folderSortOverrides.entries)
        entry.key: entry.value.toJson(),
    });
    await prefs.setString(_keyFolderSortOverrides, encoded);
  }

  String _normalizePath(String path) {
    return ScannerPathUtils.normalizePath(path);
  }

  String _pathLookupKey(String path) {
    return ScannerPathUtils.pathLookupKey(path);
  }

  List<String> _normalizeDeclaredRootPaths(Iterable<String> paths) {
    return ScannerPathUtils.normalizeDeclaredRootPaths(paths);
  }

  List<String> _computeScanRoots(Iterable<String> paths) {
    return ScannerPathUtils.computeScanRoots(paths);
  }

  void _rebuildDisplayedRootFolders() {
    final displayedRoots = <MusicFolder>[];
    for (final path in _roots.rootPaths) {
      final folder =
          _treeBuilder.resolveFolderForPath(
            path,
            _scannedRootFolders,
            _systemMediaFolder,
          ) ??
          MusicFolder(path: path, name: _displayNameForPath(path));
      displayedRoots.add(folder);
    }
    _rootFolders
      ..clear()
      ..addAll(displayedRoots);
  }

  void _syncNavigationStateToLatestTree({String? affectedRootPath}) {
    final currentFolder = _navigationState.currentFolder;
    if (currentFolder != null && affectedRootPath != null) {
      final normCurrent = _normalizePath(currentFolder.path);
      final normAffected = _normalizePath(affectedRootPath);
      final isAffected =
          normCurrent == normAffected ||
          _pathContains(normAffected, normCurrent) ||
          _pathContains(normCurrent, normAffected);
      if (!isAffected) {
        return;
      }
    }

    MusicFolder? resolveFolder(MusicFolder? folder) {
      if (folder == null) return null;
      if (folder.path == 'system') {
        return _systemMediaFolder;
      }
      return _treeBuilder.resolveFolderForPath(
        folder.path,
        _scannedRootFolders,
        _systemMediaFolder,
      );
    }

    final resolvedCurrentFolder = resolveFolder(currentFolder);

    final resolvedHistory = <MusicFolder>[];
    for (final folder in _navigationState.history) {
      final resolved = resolveFolder(folder);
      if (resolved != null) {
        resolvedHistory.add(resolved);
      }
    }

    if (resolvedCurrentFolder == null && currentFolder != null) {
      final isStillValid =
          currentFolder.path == 'system' ||
          _roots.rootPaths.any(
            (root) =>
                _pathsEqual(root, currentFolder.path) ||
                _pathContains(root, currentFolder.path),
          );
      if (!isStillValid) {
        _navigationState.setState(null, const []);
      }
      return;
    }

    final currentChanged =
        !identical(resolvedCurrentFolder, currentFolder) &&
        resolvedCurrentFolder != null;
    final historyChanged = !const ListEquality<MusicFolder>().equals(
      resolvedHistory,
      _navigationState.history,
    );

    if (currentChanged || historyChanged) {
      _navigationState.setState(resolvedCurrentFolder, resolvedHistory);
    }
  }

  bool _pathsEqual(String left, String right) {
    return ScannerPathUtils.pathsEqual(left, right);
  }

  /// Find the next folder containing music after [currentFolderPath].
  MusicFolder? findNextFolderWithMusic(String currentFolderPath) {
    final list = <MusicFolder>[];
    void traverse(MusicFolder folder) {
      if (folder.files.isNotEmpty) {
        list.add(folder);
      }
      for (final sub in folder.subFolders) {
        traverse(sub);
      }
    }

    if (_systemMediaFolder != null) {
      traverse(_systemMediaFolder!);
    }
    for (final root in _scannedRootFolders) {
      traverse(root);
    }

    if (list.isEmpty) return null;

    final index = list.indexWhere(
      (f) => _pathsEqual(f.path, currentFolderPath),
    );
    if (index == -1) {
      return list.first;
    }

    final nextIndex = (index + 1) % list.length;
    return list[nextIndex];
  }

  /// Find the previous folder containing music before [currentFolderPath].
  MusicFolder? findPreviousFolderWithMusic(String currentFolderPath) {
    final list = <MusicFolder>[];
    void traverse(MusicFolder folder) {
      if (folder.files.isNotEmpty) {
        list.add(folder);
      }
      for (final sub in folder.subFolders) {
        traverse(sub);
      }
    }

    if (_systemMediaFolder != null) {
      traverse(_systemMediaFolder!);
    }
    for (final root in _scannedRootFolders) {
      traverse(root);
    }

    if (list.isEmpty) return null;

    final index = list.indexWhere(
      (f) => _pathsEqual(f.path, currentFolderPath),
    );
    if (index == -1) {
      return list.last;
    }

    final prevIndex = (index - 1 + list.length) % list.length;
    return list[prevIndex];
  }

  bool _pathContains(String parent, String child) {
    return ScannerPathUtils.pathContains(parent, child);
  }

  bool _isImmediateChildOfDirectory(String parent, String child) {
    final normalizedParent = _normalizePath(parent);
    final normalizedChild = _normalizePath(child);
    if (normalizedParent.isEmpty || normalizedChild.isEmpty) {
      return false;
    }
    return _pathsEqual(p.dirname(normalizedChild), normalizedParent);
  }

  String _displayNameForPath(String path) {
    return ScannerPathUtils.displayNameForPath(path);
  }

  void _logScanTiming(String label, Stopwatch stopwatch) {
    if (!_scanTimingEnabled) return;
    debugPrint(
      '[ScannerService][scan] $label took ${stopwatch.elapsedMilliseconds} ms',
    );
  }

  Future<T> _timeInitStep<T>(String label, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      _logInitTiming(label, stopwatch);
    }
  }

  T _timeInitStepSync<T>(String label, T Function() action) {
    final stopwatch = Stopwatch()..start();
    try {
      return action();
    } finally {
      stopwatch.stop();
      _logInitTiming(label, stopwatch);
    }
  }

  Future<T> _timeScanStep<T>(String label, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      _logScanTiming(label, stopwatch);
    }
  }

  T _timeScanStepSync<T>(String label, T Function() action) {
    final stopwatch = Stopwatch()..start();
    try {
      return action();
    } finally {
      stopwatch.stop();
      _logScanTiming(label, stopwatch);
    }
  }

  void _scheduleMetadataNotify() {
    if (_metadataNotifyTimer?.isActive ?? false) {
      return;
    }

    _metadataNotifyTimer = Timer(const Duration(milliseconds: 150), () {
      _metadataNotifyTimer = null;
      if (!isScanning) {
        notifyListeners();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint(
        '[ScannerService] App resumed, triggering root availability check',
      );
      _pendingRootAvailabilityRescan = true;
      _scheduleRootAvailabilityRefresh();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _rootAvailabilityTimer?.cancel();
    _rootAvailabilityTimer = null;
    _navigationState.removeListener(_handleNavigationChanged);
    _navigationState.dispose();
    _roots.dispose();
    _mediaObserverSubscription?.cancel();
    _mobileStorageSubscription?.cancel();
    _metadataNotifyTimer?.cancel();
    _directoryRescanTimer?.cancel();
    _directoryRescanTimer = null;
    _pendingDirectoryRescanPaths.clear();
    _watchedFileMtimes.clear();
    _scanNotifyTimer?.cancel();
    _rootAvailabilityRefreshTimer?.cancel();
    _scanProgressController.close();
    _scanCoordinator.removeListener(_handleScanStateChanged);
    _scanCoordinator.dispose();
    if (_supportsPersistentAccess && _playerController != null) {
      for (final path in _activeScopedRootPaths.toList(growable: false)) {
        unawaited(_playerController!.endScopedAccess(path: path));
      }
      _activeScopedRootPaths.clear();
    }
    super.dispose();
  }
}

enum RootPathAddStatus {
  added,
  alreadyAdded,
  noMusic,
  persistentAccessDenied,
  failed,
}

class RootPathAddResult {
  const RootPathAddResult(this.status, {this.path});

  final RootPathAddStatus status;
  final String? path;

  bool get hasMusic =>
      status == RootPathAddStatus.added ||
      status == RootPathAddStatus.alreadyAdded;

  bool get accessDenied => status == RootPathAddStatus.persistentAccessDenied;
}

class _RootArtworkScanJob {
  const _RootArtworkScanJob({
    required this.rootPath,
    required this.visiblePaths,
    required this.artworkPendingPaths,
  });

  final String rootPath;
  final List<String> visiblePaths;
  final List<String> artworkPendingPaths;
}
