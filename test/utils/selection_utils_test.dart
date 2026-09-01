import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/utils/selection_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('computeRangeKeys', () {
    final items = ['itemA', 'itemB', 'itemC', 'itemD', 'itemE'];

    test('computes forward range correctly', () {
      final keys = ModifierKeyUtils.computeRangeKeys(
        anchorIndex: 1,
        currentIndex: 3,
        items: items,
        keySelector: (s) => s,
      );
      expect(keys, {'itemB', 'itemC', 'itemD'});
    });

    test('computes backward range correctly', () {
      final keys = ModifierKeyUtils.computeRangeKeys(
        anchorIndex: 4,
        currentIndex: 2,
        items: items,
        keySelector: (s) => s,
      );
      expect(keys, {'itemC', 'itemD', 'itemE'});
    });

    test('computes range with existing keys', () {
      final keys = ModifierKeyUtils.computeRangeKeys(
        anchorIndex: 1,
        currentIndex: 2,
        items: items,
        keySelector: (s) => s,
        existingKeys: {'item0'},
      );
      expect(keys, {'item0', 'itemB', 'itemC'});
    });
  });

  group('SelectionActionHelper', () {
    final items = ['id0', 'id1', 'id2', 'id3', 'id4'];

    test('normal click when not in selection mode triggers onNormalTap and onUpdateAnchor', () {
      int? updatedAnchor;
      bool normalTapped = false;

      SelectionActionHelper.handleItemTap(
        index: 2,
        itemKey: 'id2',
        items: items,
        keySelector: (s) => s,
        isSelectionMode: false,
        selectedKeys: {},
        lastAnchorIndex: null,
        onUpdateAnchor: (a) => updatedAnchor = a,
        onSetSelection: (_) {},
        onToggleSelection: (_) {},
        onNormalTap: () => normalTapped = true,
      );

      expect(normalTapped, isTrue);
      expect(updatedAnchor, 2);
    });

    test('normal click when in selection mode toggles selection', () {
      int? updatedAnchor;
      String? toggledKey;

      SelectionActionHelper.handleItemTap(
        index: 2,
        itemKey: 'id2',
        items: items,
        keySelector: (s) => s,
        isSelectionMode: true,
        selectedKeys: {'id1'},
        lastAnchorIndex: 1,
        onUpdateAnchor: (a) => updatedAnchor = a,
        onSetSelection: (_) {},
        onToggleSelection: (k) => toggledKey = k,
      );

      expect(toggledKey, 'id2');
      expect(updatedAnchor, 2);
    });
  });
}
