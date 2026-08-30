import 'package:collection/collection.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/scanner/scanner_service.dart';

const double folderPageMaxWidth = 1700.0;

MusicFile? findRepresentativeSong(MusicFolder folder) {
  if (folder.representativeSongCache != null) return folder.representativeSongCache;
  if (folder.isEmpty) return null;

  final fileWithArtwork = folder.files.firstWhereOrNull(
    (s) =>
        (s.artworkPath != null && s.artworkPath!.isNotEmpty) ||
        (s.thumbnailPath != null && s.thumbnailPath!.isNotEmpty) ||
        (s.artworkBytes != null && s.artworkBytes!.isNotEmpty),
  );
  if (fileWithArtwork != null) {
    folder.representativeSongCache = fileWithArtwork;
    return fileWithArtwork;
  }

  final allSongWithArtwork = folder.allSongs.firstWhereOrNull(
    (s) =>
        (s.artworkPath != null && s.artworkPath!.isNotEmpty) ||
        (s.thumbnailPath != null && s.thumbnailPath!.isNotEmpty) ||
        (s.artworkBytes != null && s.artworkBytes!.isNotEmpty),
  );
  if (allSongWithArtwork != null) {
    folder.representativeSongCache = allSongWithArtwork;
    return allSongWithArtwork;
  }

  if (folder.files.isNotEmpty) {
    final rep = folder.files.first;
    folder.representativeSongCache = rep;
    return rep;
  }
  if (folder.allSongs.isNotEmpty) {
    final rep = folder.allSongs.first;
    folder.representativeSongCache = rep;
    return rep;
  }
  return null;
}


bool isUserRootSelectionContext(
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

String formatDurationMs(int? durationMs) {
  if (durationMs == null || durationMs <= 0) return '0:00';
  final duration = Duration(milliseconds: durationMs);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String formatFileSize(int? bytes) {
  if (bytes == null || bytes <= 0) return '0 B';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

