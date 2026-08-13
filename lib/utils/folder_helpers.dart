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
