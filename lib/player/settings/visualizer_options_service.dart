/// 可视化优化选项服务
///
/// 负责处理频谱分析器的各种优化参数，包括不同屏幕方向下的配置、手动设置的保存与加载，以及自动调整逻辑。
library;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_core/audio_core.dart';
import 'package:vynody/player/settings/settings_service.dart';

class VisualizerOptionsService extends ChangeNotifier {
  final AudioCoreController controller;
  final SettingsService settingsService;
  static const String _visualizerOptionsKey = 'visualizer_optimization_options';

  VisualizerOptionsService({
    required this.controller,
    required this.settingsService,
  });

  VisualizerOptimizationOptions get options => controller.visualizer.options;

  Future<void> loadOptions({VisualizerStyle? style, Orientation? orientation}) async {
    final targetStyle = style ?? settingsService.visualizerStyle;
    try {
      final prefs = await SharedPreferences.getInstance();
      final styleKey = '${_visualizerOptionsKey}_${targetStyle.name}';
      final jsonStr = prefs.getString(styleKey) ??
          (targetStyle == VisualizerStyle.bars
              ? prefs.getString(_visualizerOptionsKey)
              : null);
      if (jsonStr != null) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        final options = VisualizerOptimizationOptions(
          frequencyGroups: map['frequencyGroups'] ??
              (targetStyle == VisualizerStyle.radial ? 200 : 172),
          smoothingCoefficient:
              map['smoothingCoefficient']?.toDouble() ?? 0.8,
          gravityCoefficient: map['gravityCoefficient']?.toDouble() ?? 1.5,
          overallMultiplier: map['overallMultiplier']?.toDouble() ?? 1.5,
          logarithmicScale: map['logarithmicScale']?.toDouble() ?? 2.0,
          groupContrastExponent:
              map['groupContrastExponent']?.toDouble() ?? 0.5,
          skipHighFrequencyGroups: map['skipHighFrequencyGroups'] ?? 0,
          normalizationFloorDb:
              map['normalizationFloorDb']?.toDouble() ?? -70.0,
          aggregationMode: FftAggregationMode.values.firstWhere(
            (e) => e.name == (map['aggregationMode'] ?? 'peak'),
            orElse: () => FftAggregationMode.peak,
          ),
        );
        controller.visualizer.updateOptions(options);
      } else {
        // Apply default values if no saved settings
        resetOptions(style: targetStyle);
      }

      // If auto mode is enabled for this style, apply the auto settings using current orientation
      if (settingsService.getIsAutoModeForStyle(targetStyle)) {
        final Orientation effectiveOrientation;
        if (orientation != null) {
          effectiveOrientation = orientation;
        } else {
          final dispatcher = WidgetsBinding.instance.platformDispatcher;
          final view =
              dispatcher.views.isEmpty ? null : dispatcher.views.first;
          if (view != null) {
            final size = view.physicalSize;
            effectiveOrientation = size.width > size.height
                ? Orientation.landscape
                : Orientation.portrait;
          } else {
            effectiveOrientation = Orientation.portrait;
          }
        }
        applySettings(orientation: effectiveOrientation);
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading visualizer options for $targetStyle: $e');
    }
  }

  Future<void> saveOptions({VisualizerStyle? style}) async {
    final targetStyle = style ?? settingsService.visualizerStyle;
    try {
      final prefs = await SharedPreferences.getInstance();
      final options = controller.visualizer.options;
      final map = {
        'frequencyGroups': options.frequencyGroups,
        'smoothingCoefficient': options.smoothingCoefficient,
        'gravityCoefficient': options.gravityCoefficient,
        'overallMultiplier': options.overallMultiplier,
        'logarithmicScale': options.logarithmicScale,
        'groupContrastExponent': options.groupContrastExponent,
        'skipHighFrequencyGroups': options.skipHighFrequencyGroups,
        'normalizationFloorDb': options.normalizationFloorDb,
        'aggregationMode': options.aggregationMode.name,
      };
      final styleKey = '${_visualizerOptionsKey}_${targetStyle.name}';
      await prefs.setString(styleKey, jsonEncode(map));
    } catch (e) {
      debugPrint('Error saving visualizer options for $targetStyle: $e');
    }
  }

  void updateOptions(VisualizerOptimizationOptions options) {
    controller.visualizer.updateOptions(options);
    notifyListeners();
  }

  void resetOptions({VisualizerStyle? style}) {
    final targetStyle = style ?? settingsService.visualizerStyle;
    final defaultGroups = targetStyle == VisualizerStyle.radial ? 200 : 172;
    final options = VisualizerOptimizationOptions(
      frequencyGroups: defaultGroups,
      smoothingCoefficient: 0.8,
      gravityCoefficient: 1.5,
      overallMultiplier: 1.5,
      logarithmicScale: 2.0,
      groupContrastExponent: 0.5,
      skipHighFrequencyGroups: 0,
      normalizationFloorDb: -70.0,
      aggregationMode: FftAggregationMode.peak,
    );
    updateOptions(options);
    saveOptions(style: targetStyle);
  }

  VisualizerOptimizationOptions _getAutoOptions({required Orientation orientation}) {
    final isLandscape = orientation == Orientation.landscape;
    int freqGroups = isLandscape
        ? settingsService.landscapeFrequencyGroups
        : settingsService.portraitFrequencyGroups;
    int skipHigh = 0;

    // Automatic Mode Logic
    if (settingsService.visualizerStyle == VisualizerStyle.radial) {
      switch (settingsService.autoSpectrumQuantity) {
        case 'high':
          freqGroups = 200;
          skipHigh = 12;
          break;
        case 'medium':
          freqGroups = 150;
          skipHigh = 8;
          break;
        case 'low':
          freqGroups = 100;
          skipHigh = 6;
          break;
      }
    } else if (isLandscape) {
      switch (settingsService.autoSpectrumQuantity) {
        case 'high':
          freqGroups = 172;
          skipHigh = 11;
          break;
        case 'medium':
          freqGroups = 100;
          skipHigh = 6;
          break;
        case 'low':
          freqGroups = 42;
          skipHigh = 2;
          break;
      }
    } else {
      switch (settingsService.autoSpectrumQuantity) {
        case 'high':
          freqGroups = 100;
          skipHigh = 6;
          break;
        case 'medium':
          freqGroups = 50;
          skipHigh = 4;
          break;
        case 'low':
          freqGroups = 20;
          skipHigh = 1;
          break;
      }
    }

    double smoothing = 1.0;
    double gravity = 1.0;

    switch (settingsService.autoSpeed) {
      case 'slow':
        smoothing = 0.7;
        gravity = 0.7;
        break;
      case 'medium':
        smoothing = 0.4;
        gravity = 1.0;
        break;
      case 'fast':
        smoothing = 0.25;
        gravity = 1.5;
        break;
    }

    return controller.visualizer.options.copyWith(
      frequencyGroups: freqGroups,
      skipHighFrequencyGroups: skipHigh,
      smoothingCoefficient: smoothing,
      gravityCoefficient: gravity,
      groupContrastExponent: 0.5,
      normalizationFloorDb: -70.0,
      overallMultiplier: 1.5,
      aggregationMode: FftAggregationMode.peak,
    );
  }

  void resetToAutoSettings({required Orientation orientation}) {
    final options = _getAutoOptions(orientation: orientation).copyWith(
      logarithmicScale: 2.0,
    );
    updateOptions(options);
    saveOptions();
  }

  void applySettings({required Orientation orientation}) {
    if (!settingsService.isAutoMode) {
      // Manual mode uses saved options already applied to player
      return;
    }

    final options = _getAutoOptions(orientation: orientation);
    controller.visualizer.updateOptions(options);
    notifyListeners();
  }
}
