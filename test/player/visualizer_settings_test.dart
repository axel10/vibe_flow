import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/widgets/visualizer_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VisualizerStyle Default Opacities', () {
    test('verifies default opacity values per visualizer style', () {
      expect(VisualizerStyle.matrix.defaultOpacity, 0.25);
      expect(VisualizerStyle.smoothWave.defaultOpacity, 0.06);
      expect(VisualizerStyle.mirroredWave.defaultOpacity, 0.06);
      expect(VisualizerStyle.bars.defaultOpacity, 0.20);
      expect(VisualizerStyle.floatingBars.defaultOpacity, 0.20);
      expect(VisualizerStyle.radial.defaultOpacity, 0.20);
    });
  });

  group('SettingsService Visualizer Style & Opacity Persistence', () {
    late SettingsService settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
    });

    test('default visualizer style is bars and retrieves default opacity', () {
      expect(settingsService.visualizerStyle, VisualizerStyle.bars);
      expect(settingsService.visualizerOpacity, 0.20);
    });

    test('switching style changes current visualizerOpacity accordingly', () {
      settingsService.visualizerStyle = VisualizerStyle.matrix;
      expect(settingsService.visualizerOpacity, 0.25);

      settingsService.visualizerStyle = VisualizerStyle.smoothWave;
      expect(settingsService.visualizerOpacity, 0.06);

      settingsService.visualizerStyle = VisualizerStyle.mirroredWave;
      expect(settingsService.visualizerOpacity, 0.06);
    });

    test('custom opacity persists per style independently', () {
      settingsService.visualizerStyle = VisualizerStyle.matrix;
      settingsService.visualizerOpacity = 0.40;

      settingsService.visualizerStyle = VisualizerStyle.smoothWave;
      settingsService.visualizerOpacity = 0.12;

      // Switch back to matrix and verify it retained 0.40
      settingsService.visualizerStyle = VisualizerStyle.matrix;
      expect(settingsService.visualizerOpacity, 0.40);

      // Switch back to smoothWave and verify it retained 0.12
      settingsService.visualizerStyle = VisualizerStyle.smoothWave;
      expect(settingsService.visualizerOpacity, 0.12);

      // Verify un-customized style retains its default
      settingsService.visualizerStyle = VisualizerStyle.mirroredWave;
      expect(settingsService.visualizerOpacity, 0.06);
    });

    test('visualizerCapDropSpeed defaults to 0.20 and persists custom value', () {
      expect(settingsService.visualizerCapDropSpeed, 0.20);

      settingsService.visualizerCapDropSpeed = 0.15;
      expect(settingsService.visualizerCapDropSpeed, 0.15);
    });

    test('autoSpeed defaults to fast for radial and medium for bars', () {
      expect(settingsService.visualizerStyle, VisualizerStyle.bars);
      expect(settingsService.autoSpeed, 'medium');

      settingsService.visualizerStyle = VisualizerStyle.radial;
      expect(settingsService.autoSpeed, 'fast');

      settingsService.visualizerStyle = VisualizerStyle.smoothWave;
      expect(settingsService.autoSpeed, 'medium');
    });

    test('autoSpectrumQuantity defaults to high for all styles', () {
      expect(settingsService.autoSpectrumQuantity, 'high');
      settingsService.visualizerStyle = VisualizerStyle.radial;
      expect(settingsService.autoSpectrumQuantity, 'high');
    });

    test('isAutoMode defaults to true and remembers advanced setting mode per style', () {
      // Default is auto mode
      expect(settingsService.isAutoMode, isTrue);

      // Turn off auto mode for bars
      settingsService.visualizerStyle = VisualizerStyle.bars;
      settingsService.isAutoMode = false;
      expect(settingsService.isAutoMode, isFalse);

      // Switch to radial - should be its default auto mode (true)
      settingsService.visualizerStyle = VisualizerStyle.radial;
      expect(settingsService.isAutoMode, isTrue);

      // Switch back to bars - should restore false
      settingsService.visualizerStyle = VisualizerStyle.bars;
      expect(settingsService.isAutoMode, isFalse);
    });

    test('resetVisualizerAppearance resets style opacities, isAutoMode and cap drop speed', () {
      settingsService.visualizerStyle = VisualizerStyle.matrix;
      settingsService.visualizerOpacity = 0.50;
      settingsService.visualizerCapDropSpeed = 0.40;
      settingsService.autoSpeed = 'slow';
      settingsService.isAutoMode = false;

      settingsService.resetVisualizerAppearance();

      expect(settingsService.visualizerStyle, VisualizerStyle.bars);
      expect(settingsService.visualizerOpacity, 0.20);
      expect(settingsService.visualizerCapDropSpeed, 0.20);
      expect(settingsService.isAutoMode, isTrue);
      expect(settingsService.getVisualizerOpacityForStyle(VisualizerStyle.matrix), 0.25);
      expect(settingsService.getAutoSpeedForStyle(VisualizerStyle.radial), 'fast');
      expect(settingsService.getIsAutoModeForStyle(VisualizerStyle.matrix), isTrue);
    });
  });

  group('FftPainter Radial & Floating Caps physics', () {
    test('radial halo paints without error on portrait and landscape dimensions', () {
      final values = List.generate(64, (i) => 0.8);

      final painterPortrait = FftPainter(
        values: values,
        style: VisualizerStyle.radial,
        color: Colors.blue,
        opacity: 0.2,
      );

      final recorderPortrait = PictureRecorder();
      final canvasPortrait = Canvas(recorderPortrait);
      // Portrait canvas 390x844
      painterPortrait.paint(canvasPortrait, const Size(390, 844));
      final picturePortrait = recorderPortrait.endRecording();
      expect(picturePortrait, isNotNull);

      final painterLandscape = FftPainter(
        values: values,
        style: VisualizerStyle.radial,
        color: Colors.blue,
        opacity: 0.2,
      );

      final recorderLandscape = PictureRecorder();
      final canvasLandscape = Canvas(recorderLandscape);
      // Landscape canvas 844x390
      painterLandscape.paint(canvasLandscape, const Size(844, 390));
      final pictureLandscape = recorderLandscape.endRecording();
      expect(pictureLandscape, isNotNull);
    });

    test('floating bars painter paints with custom capDropSpeed', () {
      final values = List.generate(32, (i) => 0.5);

      final painter = FftPainter(
        values: values,
        style: VisualizerStyle.floatingBars,
        color: Colors.white,
        capDropSpeed: 0.18,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(400, 600));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });
}
