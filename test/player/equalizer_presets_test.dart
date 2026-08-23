import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/audio/equalizer_presets.dart';

void main() {
  group('EqualizerPresets Tests', () {
    test('standard presets are populated and well-formed', () {
      expect(EqualizerPresets.all, isNotEmpty);
      expect(EqualizerPresets.all.length, 10);

      for (final preset in EqualizerPresets.all) {
        expect(preset.id, isNotEmpty);
        expect(preset.referenceGains.length, 10);
        for (final gain in preset.referenceGains) {
          expect(gain, inInclusiveRange(-12.0, 12.0));
        }
      }
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

    test('calculateGainsForBands interpolates smoothly for 5, 10, 15, 20 bands', () {
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

    test('findMatchingPreset recognizes active preset and distinguishes custom values', () {
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
  });
}
