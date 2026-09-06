import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/audio/equalizer_presets.dart';

void main() {
  group('EqualizerPresets Tests', () {
    test('standard presets are populated and well-formed', () {
      expect(EqualizerPresets.all, isNotEmpty);
      expect(EqualizerPresets.all.length, 11);

      for (final preset in EqualizerPresets.all) {
        expect(preset.id, isNotEmpty);
        expect(preset.referenceGains.length, 10);
        for (final gain in preset.referenceGains) {
          expect(gain, inInclusiveRange(-12.0, 12.0));
        }
      }

      expect(EqualizerPresets.hifi.id, 'hifi');
      expect(
        EqualizerPresets.hifi.referenceGains,
        const [5.0, 3.0, 0.0, -1.0, 0.0, 0.0, 0.0, -1.0, 1.0, 5.0],
      );
    });

    test('flat preset has all zero gains across any band counts', () {
      final freqs5 = [60.0, 250.0, 1000.0, 4000.0, 16000.0];
      final gains5 = EqualizerPresets.calculateGainsForBands(
        EqualizerPresets.flat,
        freqs5,
      );
      expect(gains5, [0.0, 0.0, 0.0, 0.0, 0.0]);

      final freqs20 = List.generate(20, (i) => 30.0 + i * 800.0);
      final gains20 = EqualizerPresets.calculateGainsForBands(
        EqualizerPresets.flat,
        freqs20,
      );
      expect(gains20.every((g) => g == 0.0), isTrue);
    });

    test(
        'calculateGainsForBands interpolates smoothly for 5, 10, 15, 20 bands',
        () {
      final rock = EqualizerPresets.rock;

      // 10 bands exactly match reference
      final freqs10 = EqualizerPresets.standard10Frequencies;
      final gains10 = EqualizerPresets.calculateGainsForBands(rock, freqs10);
      expect(gains10, rock.referenceGains);

      // 5 bands
      final freqs5 = [31.25, 125.0, 500.0, 2000.0, 16000.0];
      final gains5 = EqualizerPresets.calculateGainsForBands(rock, freqs5);
      expect(gains5.length, 5);
      expect(gains5.first, rock.referenceGains.first);
      expect(gains5.last, rock.referenceGains.last);

      // Clamping limits
      for (final g in gains5) {
        expect(g, inInclusiveRange(-12.0, 12.0));
      }
    });

    test(
        'findMatchingPreset recognizes active preset and distinguishes custom values',
        () {
      final freqs10 = EqualizerPresets.standard10Frequencies;
      final popGains = EqualizerPresets.calculateGainsForBands(
        EqualizerPresets.pop,
        freqs10,
      );

      final matched = EqualizerPresets.findMatchingPreset(popGains, freqs10);
      expect(matched?.id, 'pop');

      // Modifying one band should cause matching to fail (custom)
      final modifiedGains = List<double>.from(popGains);
      modifiedGains[3] += 3.0; // modified

      final customMatch = EqualizerPresets.findMatchingPreset(
        modifiedGains,
        freqs10,
      );
      expect(customMatch, isNull);
    });

    test('custom preset creation, serialization, and matching', () {
      final freqs = [31.25, 62.5, 125.0, 250.0, 500.0, 1000.0, 2000.0, 4000.0, 8000.0, 16000.0];
      final customGains = [3.0, 2.0, 1.0, 0.0, -1.0, -2.0, 1.0, 2.0, 3.0, 4.0];

      final customPreset = EqualizerPresets.createCustomPreset(
        name: 'My Custom EQ',
        currentGains: customGains,
        targetFreqs: freqs,
        bassBoost: 25.0,
        preamp: 1.5,
      );

      expect(customPreset.customName, 'My Custom EQ');
      expect(customPreset.isCustom, isTrue);
      expect(customPreset.bassBoost, 25.0);
      expect(customPreset.preamp, 1.5);
      expect(customPreset.referenceGains, customGains);

      // JSON serialization & deserialization
      final json = customPreset.toJson();
      final revived = EqPreset.fromJson(json);
      expect(revived.id, customPreset.id);
      expect(revived.customName, 'My Custom EQ');
      expect(revived.isCustom, isTrue);
      expect(revived.bassBoost, 25.0);
      expect(revived.preamp, 1.5);
      expect(revived.referenceGains, customGains);

      // Matching with customPresets
      final matched = EqualizerPresets.findMatchingPreset(
        customGains,
        freqs,
        customPresets: [customPreset],
      );
      expect(matched?.id, customPreset.id);
      expect(matched?.customName, 'My Custom EQ');
    });

    test('reverse interpolation from 5 bands to 10 standard bands', () {
      final freqs5 = [31.25, 125.0, 500.0, 2000.0, 16000.0];
      final gains5 = [6.0, 4.0, 0.0, -2.0, -6.0];

      final ref10 = EqualizerPresets.interpolateToStandard10Bands(gains5, freqs5);
      expect(ref10.length, 10);
      expect(ref10.first, 6.0);
      expect(ref10.last, -6.0);
    });

    test('31-band ISO 266 calculation and reverse interpolation', () {
      final freqs31 = EqualizerPresets.standard31Frequencies;
      expect(freqs31.length, 31);
      expect(freqs31.first, 20.0);
      expect(freqs31.last, 20000.0);

      final rock = EqualizerPresets.rock;
      final gains31 = EqualizerPresets.calculateGainsForBands(rock, freqs31);
      expect(gains31.length, 31);
      for (final g in gains31) {
        expect(g, inInclusiveRange(-12.0, 12.0));
      }

      // Preserves matching
      final matched = EqualizerPresets.findMatchingPreset(gains31, freqs31);
      expect(matched?.id, 'rock');
    });
  });
}
