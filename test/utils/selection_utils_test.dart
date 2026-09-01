import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/utils/selection_utils.dart';

void main() {
  group('ModifierKeyUtils Tests', () {
    test('getIndexRange returns correct range in ascending order', () {
      final range = ModifierKeyUtils.getIndexRange(2, 5).toList();
      expect(range, equals([2, 3, 4, 5]));
    });

    test('getIndexRange returns correct range in descending order', () {
      final range = ModifierKeyUtils.getIndexRange(5, 2).toList();
      expect(range, equals([2, 3, 4, 5]));
    });

    test('getIndexRange returns single item when anchor equals current', () {
      final range = ModifierKeyUtils.getIndexRange(3, 3).toList();
      expect(range, equals([3]));
    });
  });
}
