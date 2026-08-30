import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/models/music_file.dart';

enum LibrarySelectionScope {
  none,
  library,
  playlist,
  queue,
  folder,
  folderRoot,
  artist,
  album,
  webdav,
  bottomSheet,
}

class LibrarySelectionScopeController extends Notifier<LibrarySelectionScope> {
  @override
  LibrarySelectionScope build() => LibrarySelectionScope.none;

  void setScope(LibrarySelectionScope scope) {
    state = scope;
  }

  void clear() {
    state = LibrarySelectionScope.none;
  }
}

final librarySelectionScopeProvider =
    NotifierProvider<LibrarySelectionScopeController, LibrarySelectionScope>(
      LibrarySelectionScopeController.new,
    );

class ArtistSongSelectionController extends ChangeNotifier {
  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;

  final Set<String> _selectedSongPaths = {};
  Set<String> get selectedSongPaths => _selectedSongPaths;

  List<MusicFile> _allSongs = [];
  List<MusicFile> get allSongs => _allSongs;

  void setAllSongs(List<MusicFile> songs) {
    _allSongs = songs;
  }

  void enterSelectionMode(String initialPath) {
    _isSelectionMode = true;
    _selectedSongPaths.clear();
    _selectedSongPaths.add(initialPath);
    notifyListeners();
  }

  void toggleSelection(String path) {
    if (_selectedSongPaths.contains(path)) {
      _selectedSongPaths.remove(path);
      if (_selectedSongPaths.isEmpty) {
        _isSelectionMode = false;
      }
    } else {
      _selectedSongPaths.add(path);
    }
    notifyListeners();
  }

  void toggleSelectAll() {
    if (_selectedSongPaths.length == _allSongs.length) {
      _selectedSongPaths.clear();
    } else {
      _selectedSongPaths.clear();
      _selectedSongPaths.addAll(_allSongs.map((s) => s.path));
    }
    notifyListeners();
  }

  void cancelSelection() {
    _isSelectionMode = false;
    _selectedSongPaths.clear();
    notifyListeners();
  }
}

