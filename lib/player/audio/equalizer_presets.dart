import 'dart:math' as math;
import '../../l10n/app_localizations.dart';

/// Represents an Equalizer preset with standard 10-band reference gains.
class EqPreset {
  final String id;
  final String? customName;
  final String Function(AppLocalizations l10n)? nameBuilder;
  final List<double> referenceGains;
  final double? bassBoost;
  final double? preamp;
  final bool isCustom;
  final int? createdAt;

  const EqPreset({
    required this.id,
    this.customName,
    this.nameBuilder,
    required this.referenceGains,
    this.bassBoost,
    this.preamp,
    this.isCustom = false,
    this.createdAt,
  });

  String getLocalizedName(AppLocalizations l10n) {
    if (isCustom && customName != null && customName!.isNotEmpty) {
      return customName!;
    }
    return nameBuilder?.call(l10n) ?? customName ?? id;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customName': customName,
        'referenceGains': referenceGains,
        if (bassBoost != null) 'bassBoost': bassBoost,
        if (preamp != null) 'preamp': preamp,
        'isCustom': isCustom,
        'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
      };

  EqPreset copyWith({
    String? id,
    String? customName,
    String Function(AppLocalizations l10n)? nameBuilder,
    List<double>? referenceGains,
    double? bassBoost,
    double? preamp,
    bool? isCustom,
    int? createdAt,
  }) =>
      EqPreset(
        id: id ?? this.id,
        customName: customName ?? this.customName,
        nameBuilder: nameBuilder ?? this.nameBuilder,
        referenceGains: referenceGains ?? this.referenceGains,
        bassBoost: bassBoost ?? this.bassBoost,
        preamp: preamp ?? this.preamp,
        isCustom: isCustom ?? this.isCustom,
        createdAt: createdAt ?? this.createdAt,
      );

  factory EqPreset.fromJson(Map<String, dynamic> json) => EqPreset(
        id: json['id'] as String? ??
            'custom_${DateTime.now().millisecondsSinceEpoch}',
        customName: json['customName'] as String? ??
            json['name'] as String? ??
            'Custom Preset',
        referenceGains: (json['referenceGains'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        bassBoost: (json['bassBoost'] as num?)?.toDouble(),
        preamp: (json['preamp'] as num?)?.toDouble(),
        isCustom: true,
        createdAt: json['createdAt'] as int?,
      );
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

  // 11. Hi-Fi
  static final EqPreset hifi = EqPreset(
    id: 'hifi',
    nameBuilder: (l10n) => l10n.eqPresetHifi,
    referenceGains: const [5.0, 5.0, 0.0, -1.0, 0.0, 0.0, 0.0, -1.0, 2.0, 5.0],
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
    hifi,
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
          final interpolated =
              refGains[i] + t * (refGains[i + 1] - refGains[i]);
          final rounded = (interpolated * 10).roundToDouble() / 10.0;
          return rounded.clamp(-12.0, 12.0);
        }
      }
      return 0.0;
    }).toList(growable: false);
  }

  /// Interpolates arbitrary frequency-gain pairs into standard 10-band reference gains.
  static List<double> interpolateToStandard10Bands(
    List<double> sourceGains,
    List<double> sourceFreqs,
  ) {
    if (sourceGains.isEmpty || sourceFreqs.isEmpty) {
      return const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    }
    final count = math.min(sourceGains.length, sourceFreqs.length);
    if (count == 1) {
      return List.filled(10, sourceGains[0].clamp(-12.0, 12.0));
    }

    final targetFreqs = standard10Frequencies;
    return targetFreqs.map((f) {
      if (f <= sourceFreqs.first) {
        return sourceGains.first.clamp(-12.0, 12.0);
      }
      if (f >= sourceFreqs[count - 1]) {
        return sourceGains[count - 1].clamp(-12.0, 12.0);
      }

      final logF = math.log(f);
      for (int i = 0; i < count - 1; i++) {
        final f0 = sourceFreqs[i];
        final f1 = sourceFreqs[i + 1];
        if (f >= f0 && f <= f1) {
          final logF0 = math.log(f0);
          final logF1 = math.log(f1);
          final t = (logF - logF0) / (logF1 - logF0);
          final interpolated =
              sourceGains[i] + t * (sourceGains[i + 1] - sourceGains[i]);
          final rounded = (interpolated * 10).roundToDouble() / 10.0;
          return rounded.clamp(-12.0, 12.0);
        }
      }
      return 0.0;
    }).toList(growable: false);
  }

  static int _customPresetCounter = 0;

  /// Creates a custom EqPreset from current gains and frequencies.
  static EqPreset createCustomPreset({
    required String name,
    required List<double> currentGains,
    required List<double> targetFreqs,
    String? id,
    double? bassBoost,
    double? preamp,
  }) {
    final refGains = interpolateToStandard10Bands(currentGains, targetFreqs);
    final count = ++_customPresetCounter;
    return EqPreset(
      id: id ?? 'custom_${DateTime.now().microsecondsSinceEpoch}_$count',
      customName: name.trim(),
      referenceGains: refGains,
      bassBoost: bassBoost,
      preamp: preamp,
      isCustom: true,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Updates an existing custom EqPreset with current gains, target frequencies, and other parameters.
  static EqPreset updateCustomPreset({
    required EqPreset existing,
    required List<double> currentGains,
    required List<double> targetFreqs,
    double? bassBoost,
    double? preamp,
    String? newName,
  }) {
    final refGains = interpolateToStandard10Bands(currentGains, targetFreqs);
    return existing.copyWith(
      customName: (newName != null && newName.trim().isNotEmpty)
          ? newName.trim()
          : existing.customName,
      referenceGains: refGains,
      bassBoost: bassBoost,
      preamp: preamp,
    );
  }

  /// Checks if the currently configured gains match any predefined or custom preset.
  static EqPreset? findMatchingPreset(
    List<double> currentGains,
    List<double> targetFreqs, {
    List<EqPreset>? customPresets,
    double tolerance = 0.2,
  }) {
    if (currentGains.isEmpty || targetFreqs.isEmpty) return null;
    final count = math.min(currentGains.length, targetFreqs.length);

    final allPresets = [
      ...?customPresets,
      ...all,
    ];

    for (final preset in allPresets) {
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
