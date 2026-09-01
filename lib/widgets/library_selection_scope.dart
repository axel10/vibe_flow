import 'package:flutter/material.dart';
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
  navidrome,
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

/// Mixin for managing generic selection state in [ConsumerStatefulWidget]s
/// and automatically synchronizing with [librarySelectionScopeProvider].
mixin SelectionStateMixin<T extends ConsumerStatefulWidget, K>
    on ConsumerState<T> {
  LibrarySelectionScope get selectionScope => LibrarySelectionScope.navidrome;

  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;

  final Set<K> _selectedKeys = {};
  Set<K> get selectedKeys => _selectedKeys;
  int get selectedCount => _selectedKeys.length;

  bool isSelected(K key) => _selectedKeys.contains(key);

  void updateSelectionScope(bool active) {
    if (active) {
      ref.read(librarySelectionScopeProvider.notifier).setScope(selectionScope);
    } else {
      ref.read(librarySelectionScopeProvider.notifier).clear();
    }
  }

  void enterSelectionMode([K? initialKey]) {
    setState(() {
      _isSelectionMode = true;
      _selectedKeys.clear();
      if (initialKey != null) {
        _selectedKeys.add(initialKey);
      }
    });
    updateSelectionScope(true);
  }

  void toggleSelection(K key) {
    bool nextActive = _isSelectionMode;
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
        if (_selectedKeys.isEmpty) {
          _isSelectionMode = false;
          nextActive = false;
        }
      } else {
        _selectedKeys.add(key);
        _isSelectionMode = true;
        nextActive = true;
      }
    });
    updateSelectionScope(nextActive);
  }

  void toggleSelectAll(Iterable<K> allKeys) {
    final allSet = allKeys.toSet();
    bool nextActive = false;
    setState(() {
      if (_selectedKeys.length == allSet.length && allSet.isNotEmpty) {
        _selectedKeys.clear();
        _isSelectionMode = false;
        nextActive = false;
      } else {
        _selectedKeys.clear();
        _selectedKeys.addAll(allSet);
        _isSelectionMode = true;
        nextActive = true;
      }
    });
    updateSelectionScope(nextActive);
  }

  void cancelSelection() {
    if (!_isSelectionMode && _selectedKeys.isEmpty) return;
    setState(() {
      _selectedKeys.clear();
      _isSelectionMode = false;
    });
    updateSelectionScope(false);
  }

  @override
  void dispose() {
    if (_isSelectionMode) {
      Future.microtask(() {
        try {
          ref.read(librarySelectionScopeProvider.notifier).clear();
        } catch (_) {}
      });
    }
    super.dispose();
  }
}

/// Mixin for managing song-path selection in [ConsumerStatefulWidget]s
/// and automatically synchronizing with [librarySelectionScopeProvider].
mixin SongSelectionMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  LibrarySelectionScope get selectionScope => LibrarySelectionScope.navidrome;

  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;

  final Set<String> _selectedSongPaths = {};
  Set<String> get selectedSongPaths => _selectedSongPaths;
  int get selectedCount => _selectedSongPaths.length;

  bool isSongSelected(String path) => _selectedSongPaths.contains(path);

  List<MusicFile> getSelectedSongs(List<MusicFile> allSongs) {
    return allSongs.where((s) => _selectedSongPaths.contains(s.path)).toList();
  }

  void updateSelectionScope(bool active) {
    if (active) {
      ref.read(librarySelectionScopeProvider.notifier).setScope(selectionScope);
    } else {
      ref.read(librarySelectionScopeProvider.notifier).clear();
    }
  }

  void enterSongSelectionMode([String? initialPath]) {
    setState(() {
      _isSelectionMode = true;
      _selectedSongPaths.clear();
      if (initialPath != null) {
        _selectedSongPaths.add(initialPath);
      }
    });
    updateSelectionScope(true);
  }

  void toggleSongSelection(String path) {
    bool nextActive = _isSelectionMode;
    setState(() {
      if (_selectedSongPaths.contains(path)) {
        _selectedSongPaths.remove(path);
        if (_selectedSongPaths.isEmpty) {
          _isSelectionMode = false;
          nextActive = false;
        }
      } else {
        _selectedSongPaths.add(path);
        _isSelectionMode = true;
        nextActive = true;
      }
    });
    updateSelectionScope(nextActive);
  }

  void toggleSelectAllSongs(List<MusicFile> allSongs) {
    final isAll = _selectedSongPaths.length == allSongs.length && allSongs.isNotEmpty;
    bool nextActive = false;
    setState(() {
      if (isAll) {
        _selectedSongPaths.clear();
        _isSelectionMode = false;
        nextActive = false;
      } else {
        _selectedSongPaths.clear();
        _selectedSongPaths.addAll(allSongs.map((s) => s.path));
        _isSelectionMode = true;
        nextActive = true;
      }
    });
    updateSelectionScope(nextActive);
  }

  void cancelSongSelection() {
    if (!_isSelectionMode && _selectedSongPaths.isEmpty) return;
    setState(() {
      _selectedSongPaths.clear();
      _isSelectionMode = false;
    });
    updateSelectionScope(false);
  }

  @override
  void dispose() {
    if (_isSelectionMode) {
      Future.microtask(() {
        try {
          ref.read(librarySelectionScopeProvider.notifier).clear();
        } catch (_) {}
      });
    }
    super.dispose();
  }
}

/// Reusable slide-up animation container for bottom selection panels.
class AnimatedSelectionPanel extends StatelessWidget {
  const AnimatedSelectionPanel({
    super.key,
    required this.isVisible,
    required this.child,
    this.bottomOffset = 0.0,
  });

  final bool isVisible;
  final Widget child;
  final double bottomOffset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomOffset,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 1.0),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        child: isVisible ? child : const SizedBox.shrink(),
      ),
    );
  }
}

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
