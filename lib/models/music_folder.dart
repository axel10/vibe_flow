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

  int? _songCountCache;
  int get songCount {
    if (_songCountCache != null) return _songCountCache!;
    int count = files.length;
    for (final sub in subFolders) {
      count += sub.songCount;
    }
    _songCountCache = count;
    return count;
  }

  int? _totalDurationMsCache;
  int get totalDurationMs {
    if (_totalDurationMsCache != null) return _totalDurationMsCache!;
    int total = 0;
    for (final f in files) {
      total += f.durationMillis ?? 0;
    }
    for (final sub in subFolders) {
      total += sub.totalDurationMs;
    }
    _totalDurationMsCache = total;
    return total;
  }

  List<MusicFile>? _allSongsCache;
  List<MusicFile> get allSongs {
    if (_allSongsCache != null) return _allSongsCache!;
    final list = <MusicFile>[];
    list.addAll(files);
    for (final sub in subFolders) {
      list.addAll(sub.allSongs);
    }
    _allSongsCache = list;
    return list;
  }

  MusicFile? representativeSongCache;

  void invalidateCache() {
    _songCountCache = null;
    _totalDurationMsCache = null;
    _allSongsCache = null;
    representativeSongCache = null;
    for (final sub in subFolders) {
      sub.invalidateCache();
    }
  }
}
