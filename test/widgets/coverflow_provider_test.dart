import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/pages/main_layout_riverpod.dart';

void main() {
  group('isCoverFlowImmersiveActiveProvider', () {
    test('returns true only when in library (2), albums tab (4), and 3D view is active', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state (mainIndex = 0, libIndex = 0, is3D = false)
      expect(container.read(isCoverFlowImmersiveActiveProvider), isFalse);

      // Set mainIndex = 2 (Library)
      container.read(mainTabIndexProvider.notifier).setIndex(2);
      expect(container.read(isCoverFlowImmersiveActiveProvider), isFalse);

      // Set libIndex = 4 (Albums)
      container.read(libraryActiveTabIndexProvider.notifier).set(4);
      expect(container.read(isCoverFlowImmersiveActiveProvider), isFalse);

      // Set is3D = true
      container.read(isAlbum3DViewActiveProvider.notifier).set(true);
      expect(container.read(isCoverFlowImmersiveActiveProvider), isTrue);

      // Switch away from Albums tab
      container.read(libraryActiveTabIndexProvider.notifier).set(0);
      expect(container.read(isCoverFlowImmersiveActiveProvider), isFalse);

      // Back to albums tab
      container.read(libraryActiveTabIndexProvider.notifier).set(4);
      expect(container.read(isCoverFlowImmersiveActiveProvider), isTrue);

      // Switch away from Library
      container.read(mainTabIndexProvider.notifier).setIndex(1);
      expect(container.read(isCoverFlowImmersiveActiveProvider), isFalse);
    });
  });
}
