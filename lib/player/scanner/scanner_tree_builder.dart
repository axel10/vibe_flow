import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:audio_core/audio_core.dart';

import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/utils/localized_text.dart';

AppLocalizations _l10n() => currentAppL10n;

class ScannerTreeBuilder {
  ScannerTreeBuilder({
    required String Function(String path) normalizePath,
    required bool Function(String left, String right) pathsEqual,
  }) : _normalizePath = normalizePath,
       _pathsEqual = pathsEqual;

  final String Function(String path) _normalizePath;
  final bool Function(String left, String right) _pathsEqual;

  MusicFolder buildAndroidMediaLibrary(
    List<AndroidMediaLibraryEntry> entries,
    Map<String, SongMetadata> metadataByPath,
    int Function(String a, String b) compareNaturally,
  ) {
    final items = <_FolderItem>[];
    for (final entry in entries) {
      final filePath = _androidEntryFilePath(entry);
      if (filePath == null) continue;
      items.add(
        _FolderItem(
          file: musicFileFromAndroidEntry(
            entry,
            path: filePath,
            metadata: metadataByPath[filePath],
          ),
          folderPath: _normalizeAndroidFolderPath(entry.folderPath),
        ),
      );
    }

    return _buildFolderTree(
      items,
      compareNaturally,
      rootPath: 'system',
      rootName: _l10n().systemMediaLibrary,
    );
  }

  MusicFolder buildFolderTreeFromMetadata(
    Iterable<SongMetadata> songs,
    int Function(String a, String b) compareNaturally, {
    required String rootPath,
    required String rootName,
    bool skipSort = false,
  }) {
    final items = _folderItemsFromMetadata(songs, rootPath: rootPath);
    return _buildFolderTree(
      items,
      compareNaturally,
      rootPath: rootPath,
      rootName: rootName,
      skipSort: skipSort,
    );
  }

  /// Incremental insert or update a list of [songs] into an existing [root] tree.
  /// Returns the set of [MusicFolder] nodes that were modified.
  Set<MusicFolder> insertSongsToFolderTree(
    MusicFolder root,
    Iterable<SongMetadata> songs, {
    required String rootPath,
  }) {
    final modifiedFolders = <MusicFolder>{};
    final isSystem = rootPath == 'system';

    final folderMap = <String, MusicFolder>{'': root};

    void populateFolderMap(MusicFolder folder, String relativePath) {
      folderMap[relativePath] = folder;
      for (final sub in folder.subFolders) {
        final subRel = relativePath.isEmpty
            ? sub.name
            : '$relativePath/${sub.name}';
        populateFolderMap(sub, subRel);
      }
    }

    populateFolderMap(root, '');

    for (final song in songs) {
      final normalizedPath = _normalizePath(song.path);
      if (normalizedPath.isEmpty) continue;

      final folderPath = _folderPathFromMetadataPath(
        normalizedPath,
        rootPath: rootPath,
        isSystem: isSystem,
      );

      final musicFile = musicFileFromSongMetadata(
        song.copyWith(path: normalizedPath),
      );

      if (folderPath.isEmpty) {
        _upsertFileInList(root.files, musicFile);
        modifiedFolders.add(root);
        continue;
      }

      var currentRelativePath = '';
      var currentFolder = root;
      for (final segment in folderPath.split('/').where((s) => s.isNotEmpty)) {
        currentRelativePath = currentRelativePath.isEmpty
            ? segment
            : '$currentRelativePath/$segment';
        final nextFolder = folderMap.putIfAbsent(currentRelativePath, () {
          final fullPath = isSystem
              ? 'system/$currentRelativePath'
              : p.join(
                  rootPath,
                  currentRelativePath.replaceAll('/', p.separator),
                );
          final created = MusicFolder(path: fullPath, name: segment);
          currentFolder.subFolders.add(created);
          modifiedFolders.add(currentFolder);
          return created;
        });
        if (!currentFolder.subFolders.contains(nextFolder)) {
          currentFolder.subFolders.add(nextFolder);
          modifiedFolders.add(currentFolder);
        }
        currentFolder = nextFolder;
      }

      _upsertFileInList(currentFolder.files, musicFile);
      modifiedFolders.add(currentFolder);
    }

    return modifiedFolders;
  }

  void _upsertFileInList(List<MusicFile> files, MusicFile newFile) {
    final existingIndex = files.indexWhere(
      (f) => _pathsEqual(f.path, newFile.path),
    );
    if (existingIndex >= 0) {
      files[existingIndex] = newFile;
    } else {
      files.add(newFile);
    }
  }

  MusicFolder buildFolderTreeFromFilePaths(
    Iterable<String> filePaths,
    int Function(String a, String b) compareNaturally, {
    required String rootPath,
    required String rootName,
    SongMetadata? Function(String path)? metadataForPath,
  }) {
    final items = <_FolderItem>[];
    for (final filePath in filePaths) {
      final normalizedPath = _normalizePath(filePath);
      if (normalizedPath.isEmpty) continue;

      final metadata = metadataForPath?.call(normalizedPath);
      final folderPath = _folderPathFromMetadataPath(
        normalizedPath,
        rootPath: rootPath,
        isSystem: rootPath == 'system',
      );
      items.add(
        _FolderItem(
          file: _musicFileFromPath(normalizedPath, metadata: metadata),
          folderPath: folderPath,
        ),
      );
    }

    return _buildFolderTree(
      items,
      compareNaturally,
      rootPath: rootPath,
      rootName: rootName,
    );
  }

  void collectFilePaths(MusicFolder folder, Set<String> out) {
    for (final file in folder.files) {
      out.add(_normalizePath(file.path));
    }
    for (final subFolder in folder.subFolders) {
      collectFilePaths(subFolder, out);
    }
  }

  bool removeSongFromFolder(MusicFolder folder, String path) {
    folder.files.removeWhere((file) => _pathsEqual(file.path, path));

    folder.subFolders.removeWhere((subFolder) {
      final shouldRemove = removeSongFromFolder(subFolder, path);
      return shouldRemove;
    });

    return folder.isEmpty;
  }

  MusicFolder? resolveFolderForPath(
    String path,
    Iterable<MusicFolder> scannedRootFolders,
    MusicFolder? systemMediaFolder,
  ) {
    final normalizedPath = _normalizePath(path);

    for (final root in scannedRootFolders) {
      final resolved = _findFolderInTree(root, normalizedPath);
      if (resolved != null) return resolved;
    }

    if (systemMediaFolder != null) {
      final resolved = _findFolderInTree(systemMediaFolder, normalizedPath);
      if (resolved != null) return resolved;
    }

    return null;
  }

  List<_FolderItem> _folderItemsFromMetadata(
    Iterable<SongMetadata> songs, {
    required String rootPath,
  }) {
    final items = <_FolderItem>[];
    final isSystem = rootPath == 'system';

    for (final song in songs) {
      final normalizedPath = _normalizePath(song.path);
      if (normalizedPath.isEmpty) continue;

      final folderPath = _folderPathFromMetadataPath(
        normalizedPath,
        rootPath: rootPath,
        isSystem: isSystem,
      );

      items.add(
        _FolderItem(
          file: musicFileFromSongMetadata(song.copyWith(path: normalizedPath)),
          folderPath: folderPath,
        ),
      );
    }

    return items;
  }

  static final RegExp _androidStorageRootRegExp = RegExp(
    r'^/(storage/emulated/\d+|sdcard|mnt/sdcard|storage/[^/]+)(/|$)',
    caseSensitive: false,
  );

  String _folderPathFromMetadataPath(
    String normalizedPath, {
    required String rootPath,
    required bool isSystem,
  }) {
    final dir = p.dirname(normalizedPath);
    if (isSystem) {
      final normalizedDir = dir.replaceAll('\\', '/');
      var cleaned = normalizedDir.replaceFirst(_androidStorageRootRegExp, '');
      if (cleaned.startsWith('/')) {
        cleaned = cleaned.substring(1);
      }
      return cleaned;
    }

    if (_pathsEqual(dir, rootPath)) {
      return '';
    }

    if (dir.length > rootPath.length) {
      final sep = dir.codeUnitAt(rootPath.length);
      if (sep == 47 /* / */ || sep == 92 /* \ */) {
        final prefix = dir.substring(0, rootPath.length);
        final isMatch = Platform.isWindows
            ? prefix.toLowerCase() == rootPath.toLowerCase()
            : prefix == rootPath;
        if (isMatch) {
          final rel = dir.substring(rootPath.length + 1).replaceAll('\\', '/');
          return (rel == '.' || rel.isEmpty) ? '' : rel;
        }
      }
    }

    try {
      final relative = p.relative(dir, from: rootPath);
      return (relative == '.' || relative.isEmpty)
          ? ''
          : relative.replaceAll('\\', '/');
    } catch (_) {
      return dir.replaceAll('\\', '/');
    }
  }

  MusicFile musicFileFromSongMetadata(SongMetadata song) {
    return MusicFile(
      path: song.path,
      name: p.basename(song.path),
      title: _cleanText(song.title),
      artist: _cleanText(song.artist),
      album: _cleanText(song.album),
      trackNumber: song.trackNumber,
      durationMillis: song.duration,
      id: song.mediaId ?? song.id,
      thumbnailPath: song.thumbnailPath,
      artworkPath: song.artworkPath,
      artworkWidth: song.artworkWidth,
      artworkHeight: song.artworkHeight,
      themeColorsBlob: song.themeColorsBlob,
      waveformBlob: song.waveformBlob,
      lastModifiedTime: song.lastModifiedTime,
    );
  }

  MusicFile _musicFileFromPath(String path, {SongMetadata? metadata}) {
    return MusicFile(
      path: path,
      name: p.basename(path),
      title: _cleanText(metadata?.title),
      artist: _cleanText(metadata?.artist),
      album: _cleanText(metadata?.album),
      trackNumber: metadata?.trackNumber,
      durationMillis: metadata?.duration,
      thumbnailPath: metadata?.thumbnailPath,
      artworkPath: metadata?.artworkPath,
      artworkWidth: metadata?.artworkWidth,
      artworkHeight: metadata?.artworkHeight,
      themeColorsBlob: metadata?.themeColorsBlob,
      waveformBlob: metadata?.waveformBlob,
      lastModifiedTime: metadata?.lastModifiedTime,
    );
  }

  MusicFolder _buildFolderTree(
    List<_FolderItem> items,
    int Function(String a, String b) compareNaturally, {
    required String rootPath,
    required String rootName,
    bool skipSort = false,
  }) {
    final root = MusicFolder(path: rootPath, name: rootName);
    final nodes = <String, MusicFolder>{'': root};
    final isSystem = rootPath == 'system';

    for (final item in items) {
      final folderPath = item.folderPath;
      if (folderPath.isEmpty) {
        root.files.add(item.file);
        continue;
      }

      var currentRelativePath = '';
      var currentFolder = root;
      for (final segment in folderPath.split('/').where((s) => s.isNotEmpty)) {
        currentRelativePath = currentRelativePath.isEmpty
            ? segment
            : '$currentRelativePath/$segment';
        var created = false;
        final nextFolder = nodes.putIfAbsent(currentRelativePath, () {
          created = true;
          final fullPath = isSystem
              ? 'system/$currentRelativePath'
              : p.join(
                  rootPath,
                  currentRelativePath.replaceAll('/', p.separator),
                );
          return MusicFolder(path: fullPath, name: segment);
        });
        if (created) {
          currentFolder.subFolders.add(nextFolder);
        }
        currentFolder = nextFolder;
      }

      currentFolder.files.add(item.file);
    }

    if (!skipSort) {
      _sortFolderRecursive(root, compareNaturally);
    }
    return root;
  }

  MusicFolder? _findFolderInTree(MusicFolder folder, String path) {
    if (_pathsEqual(folder.path, path)) return folder;

    for (final subFolder in folder.subFolders) {
      final resolved = _findFolderInTree(subFolder, path);
      if (resolved != null) return resolved;
    }

    return null;
  }

  void _sortFolderRecursive(
    MusicFolder folder,
    int Function(String a, String b) compareNaturally,
  ) {
    folder.subFolders.sort((a, b) => compareNaturally(a.name, b.name));
    folder.files.sort((a, b) => compareNaturally(a.name, b.name));
    for (final sub in folder.subFolders) {
      _sortFolderRecursive(sub, compareNaturally);
    }
  }

  String? _androidEntryFilePath(AndroidMediaLibraryEntry entry) {
    final path = entry.filePath?.trim();
    if (path != null && path.isNotEmpty) return _normalizePath(path);
    final uri = entry.uri.trim();
    if (uri.isNotEmpty) return uri;
    return null;
  }

  String _normalizeAndroidFolderPath(String path) {
    final cleaned = path.replaceAll('\\', '/').trim();
    if (cleaned.isEmpty) return '';
    return cleaned.endsWith('/')
        ? cleaned.substring(0, cleaned.length - 1)
        : cleaned;
  }

  MusicFile musicFileFromAndroidEntry(
    AndroidMediaLibraryEntry entry, {
    required String path,
    SongMetadata? metadata,
  }) {
    final parsedId = int.tryParse(entry.id);
    final displayName = entry.displayName?.trim();
    final resolvedMetadata = metadata;
    return MusicFile(
      path: path,
      name: displayName != null && displayName.isNotEmpty
          ? displayName
          : p.basename(path),
      title: _cleanText(resolvedMetadata?.title ?? entry.title),
      artist: _cleanText(resolvedMetadata?.artist ?? entry.artist),
      album: _cleanText(resolvedMetadata?.album ?? entry.album),
      trackNumber: resolvedMetadata?.trackNumber,
      durationMillis:
          resolvedMetadata?.duration ?? entry.duration.inMilliseconds,
      id: parsedId ?? resolvedMetadata?.mediaId ?? resolvedMetadata?.id,
      mediaUri: entry.uri,
      thumbnailPath: resolvedMetadata?.thumbnailPath,
      artworkPath: resolvedMetadata?.artworkPath,
      artworkWidth: resolvedMetadata?.artworkWidth,
      artworkHeight: resolvedMetadata?.artworkHeight,
      themeColorsBlob: resolvedMetadata?.themeColorsBlob,
      lastModifiedTime: resolvedMetadata?.lastModifiedTime,
    );
  }

  String? _cleanText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

class _FolderItem {
  final MusicFile file;
  final String folderPath;

  const _FolderItem({required this.file, required this.folderPath});
}
