import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/widgets/library_selection_scope.dart';

void main() {
  group('LibrarySelectionState & LibrarySelectionController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is inactive with none scope and empty keys', () {
      final state = container.read(librarySelectionStateProvider);
      expect(state.isActive, isFalse);
      expect(state.scope, LibrarySelectionScope.none);
      expect(state.selectedKeys, isEmpty);

      final scope = container.read(librarySelectionScopeProvider);
      expect(scope, LibrarySelectionScope.none);

      final isActive = container.read(isLibrarySelectionActiveProvider);
      expect(isActive, isFalse);
    });

    test('enter creates active state with initial key and updates scope', () {
      final controller = container.read(librarySelectionStateProvider.notifier);
      controller.enter(LibrarySelectionScope.album, initialKey: 'album-1');

      final state = container.read(librarySelectionStateProvider);
      expect(state.isActive, isTrue);
      expect(state.scope, LibrarySelectionScope.album);
      expect(state.selectedKeys, {'album-1'});

      expect(container.read(librarySelectionScopeProvider), LibrarySelectionScope.album);
      expect(container.read(isLibrarySelectionActiveProvider), isTrue);
    });

    test('toggle adds and removes keys and auto-clears when empty', () {
      final controller = container.read(librarySelectionStateProvider.notifier);
      controller.enter(LibrarySelectionScope.library, initialKey: '/path/song1.mp3');

      // Add song2
      controller.toggle('/path/song2.mp3', scope: LibrarySelectionScope.library);
      var state = container.read(librarySelectionStateProvider);
      expect(state.selectedKeys, {'/path/song1.mp3', '/path/song2.mp3'});

      // Remove song1
      controller.toggle('/path/song1.mp3', scope: LibrarySelectionScope.library);
      state = container.read(librarySelectionStateProvider);
      expect(state.selectedKeys, {'/path/song2.mp3'});
      expect(state.isActive, isTrue);

      // Remove song2 -> becomes empty -> auto clears state & scope
      controller.toggle('/path/song2.mp3', scope: LibrarySelectionScope.library);
      state = container.read(librarySelectionStateProvider);
      expect(state.isActive, isFalse);
      expect(state.scope, LibrarySelectionScope.none);
      expect(state.selectedKeys, isEmpty);
      expect(container.read(librarySelectionScopeProvider), LibrarySelectionScope.none);
    });

    test('toggleSelectAll selects all keys or deselects all', () {
      final controller = container.read(librarySelectionStateProvider.notifier);
      final allKeys = ['key1', 'key2', 'key3'];

      controller.toggleSelectAll(allKeys, scope: LibrarySelectionScope.playlist);
      var state = container.read(librarySelectionStateProvider);
      expect(state.isActive, isTrue);
      expect(state.scope, LibrarySelectionScope.playlist);
      expect(state.selectedKeys, {'key1', 'key2', 'key3'});

      // Toggle select all again should deselect all
      controller.toggleSelectAll(allKeys, scope: LibrarySelectionScope.playlist);
      state = container.read(librarySelectionStateProvider);
      expect(state.isActive, isFalse);
      expect(state.scope, LibrarySelectionScope.none);
      expect(state.selectedKeys, isEmpty);
    });

    test('setSelection sets specific keys and auto-clears on empty set', () {
      final controller = container.read(librarySelectionStateProvider.notifier);
      controller.setSelection({'s1', 's2'}, scope: LibrarySelectionScope.artist);

      var state = container.read(librarySelectionStateProvider);
      expect(state.scope, LibrarySelectionScope.artist);
      expect(state.selectedKeys, {'s1', 's2'});

      controller.setSelection(<String>{}, scope: LibrarySelectionScope.artist);
      state = container.read(librarySelectionStateProvider);
      expect(state.isActive, isFalse);
      expect(state.scope, LibrarySelectionScope.none);
    });

    test('clear resets state and scope synchronously', () {
      final controller = container.read(librarySelectionStateProvider.notifier);
      controller.enter(LibrarySelectionScope.queue, initialKey: 0);

      expect(container.read(librarySelectionScopeProvider), LibrarySelectionScope.queue);

      controller.clear();
      expect(container.read(librarySelectionStateProvider).isActive, isFalse);
      expect(container.read(librarySelectionScopeProvider), LibrarySelectionScope.none);
    });
  });
}
