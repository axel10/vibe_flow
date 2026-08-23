import 'dart:math' as math;
import '../../l10n/app_localizations.dart';

/// Represents an Equalizer preset with standard 10-band reference gains.
class EqPreset {
  final String id;
  final String Function(AppLocalizations l10n) nameBuilder;
  final List<double> referenceGains;

  const EqPreset({
    required this.id,
    required this.nameBuilder,
    required this.referenceGains,
  });

  String getLocalizedName(AppLocalizations l10n) => nameBuilder(l10n);
}

/// Collection of standard EQ presets and log-frequency interpolation algorithm.
class EqualizerPresets {
  const EqualizerPresets._();

  /// Standard ISO 10-band center frequencies (Hz) used as reference anchor points.
  static const List<double> standard10Frequencies = [
    31.25,
    62.5,
    125.0,
    250.0,
    500.0,
    1000.0,
    2000.0,
    4000.0,
    8000.0,
    16000.0,
  ];

  // 1. Flat / Default
  static final EqPreset flat = EqPreset(
    id: 'flat',
    nameBuilder: (l10n) => l10n.eqPresetFlat,
    referenceGains: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  );

  // 2. Pop
  static final EqPreset pop = EqPreset(
    id: 'pop',
    nameBuilder: (l10n) => l10n.eqPresetPop,
    referenceGains: const [-1.0, 1.5, 3.5, 4.0, 2.0, -0.5, 1.5, 3.0, 2.0, 0.0],
  );

  // 3. Rock
  static final EqPreset rock = EqPreset(
    id: 'rock',
    nameBuilder: (l10n) => l10n.eqPresetRock,
    referenceGains: const [4.5, 3.5, 2.0, -1.0, -2.0, -0.5, 2.0, 3.5, 4.5, 4.0],
  );

  // 4. Vocal / Clear
  static final EqPreset vocal = EqPreset(
    id: 'vocal',
    nameBuilder: (l10n) => l10n.eqPresetVocal,
    referenceGains: const [-3.0, -2.0, -1.0, 1.0, 3.0, 4.5, 3.5, 1.5, 0.0, -1.5],
  );

  // 5. Bass Boost
  static final EqPreset bassBoost = EqPreset(
    id: 'bass_boost',
    nameBuilder: (l10n) => l10n.eqPresetBassBoost,
    referenceGains: const [6.0, 5.0, 4.0, 2.5, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  );

  // 6. Electronic
  static final EqPreset electronic = EqPreset(
    id: 'electronic',
    nameBuilder: (l10n) => l10n.eqPresetElectronic,
    referenceGains: const [4.0, 3.5, 1.5, 0.0, -1.5, 2.0, 1.0, 2.5, 4.0, 4.5],
  );

  // 7. Jazz
  static final EqPreset jazz = EqPreset(
    id: 'jazz',
    nameBuilder: (l10n) => l10n.eqPresetJazz,
    referenceGains: const [3.0, 2.0, 1.0, 1.5, -1.5, -1.5, 0.0, 1.5, 2.5, 3.0],
  );

  // 8. Classical
  static final EqPreset classical = EqPreset(
    id: 'classical',
    nameBuilder: (l10n) => l10n.eqPresetClassical,
    referenceGains: const [4.0, 3.0, 2.0, 1.5, -1.0, -1.0, 0.0, 2.0, 3.0, 3.5],
  );

  // 9. Acoustic / Soft
  static final EqPreset acoustic = EqPreset(
    id: 'acoustic',
    nameBuilder: (l10n) => l10n.eqPresetAcoustic,
    referenceGains: const [2.5, 2.0, 1.5, 0.5, 1.0, 1.0, 2.0, 2.5, 2.0, 1.0],
  );

  // 10. Dance
  static final EqPreset dance = EqPreset(
    id: 'dance',
    nameBuilder: (l10n) => l10n.eqPresetDance,
    referenceGains: const [5.0, 4.5, 2.5, 0.0, 2.0, 3.0, 4.0, 3.5, 2.5, 0.0],
  );

  /// All predefined presets in display order.
  static final List<EqPreset> all = [
    flat,
    pop,
    rock,
    vocal,
    bassBoost,
    electronic,
    jazz,
    classical,
    acoustic,
    dance,
  ];

  /// Interpolates the 10-band reference gains to arbitrary target frequencies
  /// using log-frequency linear interpolation (Log-Linear Interpolation).
  static List<double> calculateGainsForBands(
    EqPreset preset,
    List<double> targetFreqs,
  ) {
    if (targetFreqs.isEmpty) return const [];
    final refFreqs = standard10Frequencies;
    final refGains = preset.referenceGains;

    return targetFreqs.map((f) {
      if (f <= refFreqs.first) {
        return refGains.first.clamp(-12.0, 12.0);
      }
      if (f >= refFreqs.last) {
        return refGains.last.clamp(-12.0, 12.0);
      }

      final logF = math.log(f);
      for (int i = 0; i < refFreqs.length - 1; i++) {
        final f0 = refFreqs[i];
        final f1 = refFreqs[i + 1];
        if (f >= f0 && f <= f1) {
          final logF0 = math.log(f0);
          final logF1 = math.log(f1);
          final t = (logF - logF0) / (logF1 - logF0);
          final interpolated = refGains[i] + t * (refGains[i + 1] - refGains[i]);
          final rounded = (interpolated * 10).roundToDouble() / 10.0;
          return rounded.clamp(-12.0, 12.0);
        }
      }
      return 0.0;
    }).toList(growable: false);
  }

  /// Checks if the currently configured gains match any predefined preset.
  static EqPreset? findMatchingPreset(
    List<double> currentGains,
    List<double> targetFreqs, {
    double tolerance = 0.2,
  }) {
    if (currentGains.isEmpty || targetFreqs.isEmpty) return null;
    final count = math.min(currentGains.length, targetFreqs.length);

    for (final preset in all) {
      final expected = calculateGainsForBands(preset, targetFreqs);
      if (expected.length < count) continue;

      bool matched = true;
      for (int i = 0; i < count; i++) {
        if ((currentGains[i] - expected[i]).abs() > tolerance) {
          matched = false;
          break;
        }
      }
      if (matched) return preset;
    }
    return null;
  }
}
