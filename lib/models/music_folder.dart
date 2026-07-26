import 'music_file.dart';

class MusicFolder {
  final String path;
  final String name;
  final List<MusicFolder> subFolders;
  final List<MusicFile> files;

  MusicFolder({
    required this.path,
    required this.name,
    List<MusicFolder> subFolders = const [],
    List<MusicFile> files = const [],
  }) : subFolders = List.from(subFolders),
       files = List.from(files);

  bool get isEmpty => subFolders.isEmpty && files.isEmpty;

  int get songCount {
    int count = files.length;
    for (final sub in subFolders) {
      count += sub.songCount;
    }
    return count;
  }

  int get totalDurationMs {
    int total = 0;
    for (final f in files) {
      total += f.durationMillis ?? 0;
    }
    for (final sub in subFolders) {
      total += sub.totalDurationMs;
    }
    return total;
  }

  List<MusicFile> get allSongs {
    final list = <MusicFile>[];
    list.addAll(files);
    for (final sub in subFolders) {
      list.addAll(sub.allSongs);
    }
    return list;
  }
}
