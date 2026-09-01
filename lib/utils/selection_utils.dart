import 'dart:math' as math;
import 'package:flutter/services.dart';

/// Utility class for checking desktop keyboard modifier keys (Shift, Ctrl, Cmd, Alt).
class ModifierKeyUtils {
  const ModifierKeyUtils._();

  /// Returns true if Shift key is currently pressed (used for range selection).
  static bool get isRangeSelectPressed =>
      HardwareKeyboard.instance.isShiftPressed;

  /// Returns true if Control (Windows/Linux) or Meta/Command (macOS) key is currently pressed (used for discrete multi-selection).
  static bool get isDiscreteSelectPressed =>
      HardwareKeyboard.instance.isControlPressed ||
      HardwareKeyboard.instance.isMetaPressed;

  /// Returns true if Alt / Option key is currently pressed.
  static bool get isAltPressed => HardwareKeyboard.instance.isAltPressed;

  /// Returns true if either Shift or Ctrl/Cmd is pressed.
  static bool get hasModifierPressed =>
      isRangeSelectPressed || isDiscreteSelectPressed;

  /// Calculates a closed index range [min(anchor, current), max(anchor, current)].
  static Iterable<int> getIndexRange(int anchor, int current) sync* {
    final start = math.min(anchor, current);
    final end = math.max(anchor, current);
    for (int i = start; i <= end; i++) {
      yield i;
    }
  }

  /// Helper to compute range keys for a list of items given an anchor and current index.
  static Set<K> computeRangeKeys<T, K>({
    required List<T> items,
    required int anchorIndex,
    required int currentIndex,
    required K Function(T item) keySelector,
    Set<K>? existingKeys,
  }) {
    final result = existingKeys != null ? Set<K>.from(existingKeys) : <K>{};
    final range = getIndexRange(anchorIndex, currentIndex);
    for (final i in range) {
      if (i >= 0 && i < items.length) {
        result.add(keySelector(items[i]));
      }
    }
    return result;
  }
}

/// Generic interaction helper that centralizes Shift/Ctrl/Normal tap logic for multi-selection.
class SelectionActionHelper {
  const SelectionActionHelper._();

  /// Handles an item tap event with keyboard modifier shortcuts (Shift range selection, Ctrl/Cmd toggle selection).
  ///
  /// Returns `true` if the event was handled as a selection operation, or `false` if `onNormalTap` was executed.
  static bool handleItemTap<T, K>({
    required int index,
    required K itemKey,
    required List<T> items,
    required K Function(T item) keySelector,
    required bool isSelectionMode,
    required Set<K> selectedKeys,
    required int? lastAnchorIndex,
    required void Function(int newAnchor) onUpdateAnchor,
    required void Function(Set<K> newKeys) onSetSelection,
    required void Function(K key) onToggleSelection,
    void Function()? onNormalTap,
    void Function()? onEnterSelectionMode,
  }) {
    final isShift = ModifierKeyUtils.isRangeSelectPressed;
    final isCtrl = ModifierKeyUtils.isDiscreteSelectPressed;

    if (isShift) {
      if (!isSelectionMode) {
        onEnterSelectionMode?.call();
      }
      final anchor = lastAnchorIndex ?? index;
      final newKeys = ModifierKeyUtils.computeRangeKeys(
        items: items,
        anchorIndex: anchor,
        currentIndex: index,
        keySelector: keySelector,
        existingKeys: selectedKeys,
      );
      onSetSelection(newKeys);
      return true;
    } else if (isCtrl) {
      if (!isSelectionMode) {
        onEnterSelectionMode?.call();
      }
      onToggleSelection(itemKey);
      onUpdateAnchor(index);
      return true;
    } else {
      if (isSelectionMode) {
        onToggleSelection(itemKey);
        onUpdateAnchor(index);
        return true;
      } else {
        onUpdateAnchor(index);
        onNormalTap?.call();
        return false;
      }
    }
  }
}
