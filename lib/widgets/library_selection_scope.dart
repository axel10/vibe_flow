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

@immutable
class LibrarySelectionState {
  final LibrarySelectionScope scope;
  final bool isActive;
  final Set<dynamic> selectedKeys;

  const LibrarySelectionState({
    this.scope = LibrarySelectionScope.none,
    this.isActive = false,
    this.selectedKeys = const {},
  });

  int get count => selectedKeys.length;
  bool isSelected(dynamic key) => selectedKeys.contains(key);
  bool get isEmpty => selectedKeys.isEmpty;
  bool get isNotEmpty => selectedKeys.isNotEmpty;

  Set<K> keysAs<K>() => selectedKeys.cast<K>().toSet();

  LibrarySelectionState copyWith({
    LibrarySelectionScope? scope,
    bool? isActive,
    Set<dynamic>? selectedKeys,
  }) {
    return LibrarySelectionState(
      scope: scope ?? this.scope,
      isActive: isActive ?? this.isActive,
      selectedKeys: selectedKeys ?? this.selectedKeys,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibrarySelectionState &&
          runtimeType == other.runtimeType &&
          scope == other.scope &&
          isActive == other.isActive &&
          _setEquals(selectedKeys, other.selectedKeys);

  @override
  int get hashCode =>
      Object.hash(scope, isActive, Object.hashAll(selectedKeys));

  static bool _setEquals(Set<dynamic> a, Set<dynamic> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}

class LibrarySelectionController extends Notifier<LibrarySelectionState> {
  @override
  LibrarySelectionState build() => const LibrarySelectionState();

  void enter(
    LibrarySelectionScope scope, {
    dynamic initialKey,
    Iterable<dynamic>? initialKeys,
  }) {
    final keys = <dynamic>{};
    if (initialKey != null) keys.add(initialKey);
    if (initialKeys != null) keys.addAll(initialKeys);
    state = LibrarySelectionState(
      scope: scope,
      isActive: true,
      selectedKeys: keys,
    );
  }

  void setScope(LibrarySelectionScope scope) {
    if (scope == LibrarySelectionScope.none) {
      clear();
    } else {
      state = state.copyWith(
        scope: scope,
        isActive: true,
      );
    }
  }

  void toggle(dynamic key, {LibrarySelectionScope? scope}) {
    final targetScope = scope ??
        (state.scope != LibrarySelectionScope.none
            ? state.scope
            : LibrarySelectionScope.library);
    final currentKeys = Set<dynamic>.from(state.selectedKeys);
    if (currentKeys.contains(key)) {
      currentKeys.remove(key);
      if (currentKeys.isEmpty) {
        state = const LibrarySelectionState();
        return;
      }
    } else {
      currentKeys.add(key);
    }
    state = LibrarySelectionState(
      scope: targetScope,
      isActive: true,
      selectedKeys: currentKeys,
    );
  }

  void toggleSelectAll(
    Iterable<dynamic> allKeys, {
    LibrarySelectionScope? scope,
  }) {
    final targetScope = scope ??
        (state.scope != LibrarySelectionScope.none
            ? state.scope
            : LibrarySelectionScope.library);
    final allSet = allKeys.toSet();
    if (state.selectedKeys.length == allSet.length && allSet.isNotEmpty) {
      state = const LibrarySelectionState();
    } else {
      state = LibrarySelectionState(
        scope: targetScope,
        isActive: true,
        selectedKeys: allSet,
      );
    }
  }

  void setSelection(
    Iterable<dynamic> keys, {
    LibrarySelectionScope? scope,
  }) {
    final keySet = keys.toSet();
    if (keySet.isEmpty) {
      state = const LibrarySelectionState();
    } else {
      state = LibrarySelectionState(
        scope: scope ??
            (state.scope != LibrarySelectionScope.none
                ? state.scope
                : LibrarySelectionScope.library),
        isActive: true,
        selectedKeys: keySet,
      );
    }
  }

  void clear() {
    if (state.isActive ||
        state.selectedKeys.isNotEmpty ||
        state.scope != LibrarySelectionScope.none) {
      state = const LibrarySelectionState();
    }
  }
}

final librarySelectionStateProvider =
    NotifierProvider<LibrarySelectionController, LibrarySelectionState>(
      LibrarySelectionController.new,
    );

final isLibrarySelectionActiveProvider = Provider<bool>((ref) {
  final selection = ref.watch(librarySelectionStateProvider);
  return selection.isActive && selection.scope != LibrarySelectionScope.none;
});

class LibrarySelectionScopeController extends Notifier<LibrarySelectionScope> {
  @override
  LibrarySelectionScope build() {
    final selection = ref.watch(librarySelectionStateProvider);
    return (selection.isActive &&
            selection.scope != LibrarySelectionScope.none)
        ? selection.scope
        : LibrarySelectionScope.none;
  }

  void setScope(LibrarySelectionScope scope) {
    ref.read(librarySelectionStateProvider.notifier).setScope(scope);
  }

  void clear() {
    ref.read(librarySelectionStateProvider.notifier).clear();
  }
}

final librarySelectionScopeProvider =
    NotifierProvider<LibrarySelectionScopeController, LibrarySelectionScope>(
      LibrarySelectionScopeController.new,
    );

/// Mixin for managing generic selection state in [ConsumerStatefulWidget]s
/// backed directly by [librarySelectionStateProvider] (Single Source of Truth).
mixin SelectionStateMixin<T extends ConsumerStatefulWidget, K>
    on ConsumerState<T> {
  LibrarySelectionScope get selectionScope => LibrarySelectionScope.library;

  bool get isSelectionMode {
    final state = ref.watch(librarySelectionStateProvider);
    return state.isActive && state.scope == selectionScope;
  }

  Set<K> get selectedKeys {
    final state = ref.watch(librarySelectionStateProvider);
    if (state.scope != selectionScope) return const {};
    return state.selectedKeys.cast<K>().toSet();
  }

  int get selectedCount => selectedKeys.length;

  bool isSelected(K key) => selectedKeys.contains(key);

  void updateSelectionScope(bool active) {
    if (active) {
      ref
          .read(librarySelectionStateProvider.notifier)
          .setScope(selectionScope);
    } else {
      ref.read(librarySelectionStateProvider.notifier).clear();
    }
  }

  void enterSelectionMode([K? initialKey]) {
    ref.read(librarySelectionStateProvider.notifier).enter(
      selectionScope,
      initialKey: initialKey,
    );
  }

  void toggleSelection(K key) {
    ref.read(librarySelectionStateProvider.notifier).toggle(
      key,
      scope: selectionScope,
    );
  }

  void toggleSelectAll(Iterable<K> allKeys) {
    ref.read(librarySelectionStateProvider.notifier).toggleSelectAll(
      allKeys,
      scope: selectionScope,
    );
  }

  void cancelSelection() {
    ref.read(librarySelectionStateProvider.notifier).clear();
  }

  @override
  void dispose() {
    final current = ref.read(librarySelectionStateProvider);
    if (current.scope == selectionScope) {
      Future.microtask(() {
        try {
          if (ref.read(librarySelectionStateProvider).scope == selectionScope) {
            ref.read(librarySelectionStateProvider.notifier).clear();
          }
        } catch (_) {}
      });
    }
    super.dispose();
  }
}

/// Mixin for managing song-path selection in [ConsumerStatefulWidget]s
/// backed directly by [librarySelectionStateProvider] (Single Source of Truth).
mixin SongSelectionMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  LibrarySelectionScope get selectionScope => LibrarySelectionScope.library;

  bool get isSelectionMode {
    final state = ref.watch(librarySelectionStateProvider);
    return state.isActive && state.scope == selectionScope;
  }

  Set<String> get selectedSongPaths {
    final state = ref.watch(librarySelectionStateProvider);
    if (state.scope != selectionScope) return const {};
    return state.selectedKeys.cast<String>().toSet();
  }

  int get selectedCount => selectedSongPaths.length;

  bool isSongSelected(String path) => selectedSongPaths.contains(path);

  List<MusicFile> getSelectedSongs(List<MusicFile> allSongs) {
    final paths = selectedSongPaths;
    return allSongs.where((s) => paths.contains(s.path)).toList();
  }

  void updateSelectionScope(bool active) {
    if (active) {
      ref
          .read(librarySelectionStateProvider.notifier)
          .setScope(selectionScope);
    } else {
      ref.read(librarySelectionStateProvider.notifier).clear();
    }
  }

  void enterSongSelectionMode([String? initialPath]) {
    ref.read(librarySelectionStateProvider.notifier).enter(
      selectionScope,
      initialKey: initialPath,
    );
  }

  void toggleSongSelection(String path) {
    ref.read(librarySelectionStateProvider.notifier).toggle(
      path,
      scope: selectionScope,
    );
  }

  void toggleSelectAllSongs(List<MusicFile> allSongs) {
    ref.read(librarySelectionStateProvider.notifier).toggleSelectAll(
      allSongs.map((s) => s.path),
      scope: selectionScope,
    );
  }

  void cancelSongSelection() {
    ref.read(librarySelectionStateProvider.notifier).clear();
  }

  @override
  void dispose() {
    final current = ref.read(librarySelectionStateProvider);
    if (current.scope == selectionScope) {
      Future.microtask(() {
        try {
          if (ref.read(librarySelectionStateProvider).scope == selectionScope) {
            ref.read(librarySelectionStateProvider.notifier).clear();
          }
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
