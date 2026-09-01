import 'dart:math' as math;
import 'package:flutter/services.dart';

/// Utility class for checking desktop keyboard modifier keys (Shift, Ctrl, Cmd).
class ModifierKeyUtils {
  const ModifierKeyUtils._();

  /// Returns true if Shift key is currently pressed (used for range selection).
  static bool get isRangeSelectPressed =>
      HardwareKeyboard.instance.isShiftPressed;

  /// Returns true if Control (Windows/Linux) or Meta/Command (macOS) key is currently pressed (used for discrete multi-selection).
  static bool get isDiscreteSelectPressed =>
      HardwareKeyboard.instance.isControlPressed ||
      HardwareKeyboard.instance.isMetaPressed;

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
}
