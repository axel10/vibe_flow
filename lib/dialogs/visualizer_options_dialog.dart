import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:audio_core/audio_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/file_selector_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/settings/settings_service.dart';

import 'playback_button_layout_dialog.dart';

class VisualizerOptionsDialog extends ConsumerWidget {
  const VisualizerOptionsDialog({
    super.key,
    required this.audio,
    required this.settings,
  });

  final AudioService audio;
  final SettingsService settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          final screenWidth = MediaQuery.of(context).size.width;
          final double horizontalInset = (screenWidth * 0.05).clamp(12.0, 40.0);

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF101114) : theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: horizontalInset, vertical: 24.0),
            titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.visualizerSettings,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                TabBar(
                  tabs: [
                    Tab(text: l10n.algorithm),
                    Tab(text: l10n.appearance),
                    Tab(text: l10n.buttonLayoutSettings),
                  ],
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                  indicatorColor: theme.colorScheme.primary,
                  dividerColor: Colors.transparent,
                ),
              ],
            ),
            content: SizedBox(
              width: 660,
              height: 520,
              child: TabBarView(
                children: [
                  _buildAlgorithmTab(context, ref, setDialogState),
                  _buildAppearanceTab(context, settings, setDialogState),
                  PlaybackButtonLayoutView(
                    settings: settings,
                    onChanged: () => setDialogState(() {}),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.confirm,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlgorithmTab(
    BuildContext context,
    WidgetRef ref,
    StateSetter setDialogState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isAuto = settings.isAutoMode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            context: context,
            child: SwitchListTile.adaptive(
              contentPadding: isPortrait ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 12),
              shape: isPortrait ? null : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                l10n.autoMode,
                style: TextStyle(
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
              value: isAuto,
              activeThumbColor: theme.colorScheme.primary,
              activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
              onChanged: (val) {
                settings.isAutoMode = val;
                if (val) {
                  final Orientation orientation = MediaQuery.of(
                    context,
                  ).orientation;
                  audio.applyVisualizerSettings(orientation: orientation);
                } else {
                  audio.visualizerOptions.loadOptions();
                }
                setDialogState(() {});
              },
            ),
          ),
          const SizedBox(height: 16),
          if (isAuto) ...[
            _buildAutoModeControls(context, setDialogState),
          ] else ...[
            _buildSectionHeader(
              context,
              l10n.spectrumAdvancedOptions,
              resetLabel: l10n.resetAlgorithm,
              onReset: () {
                audio.resetVisualizerOptions(
                  orientation: MediaQuery.of(context).orientation,
                );
                setDialogState(() {});
              },
            ),
            const SizedBox(height: 12),
            _buildSpectrumAdvancedControls(context, ref, setDialogState),
          ],
          const SizedBox(height: 16),
          _buildSpectrumAppearanceControls(context, setDialogState),
        ],
      ),
    );
  }

  Widget _buildAutoModeControls(
    BuildContext context,
    StateSetter setDialogState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return _buildSectionCard(
      context: context,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.spectrumQuantity,
              style: TextStyle(
                color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            _buildSegmentedControl<String>(
              context,
              value: settings.autoSpectrumQuantity,
              items: {
                'low': l10n.quantityLow,
                'medium': l10n.quantityMedium,
                'high': l10n.quantityHigh,
              },
              onChanged: (val) {
                settings.autoSpectrumQuantity = val;
                audio.applyVisualizerSettings(
                  orientation: MediaQuery.of(context).orientation,
                );
                setDialogState(() {});
              },
            ),
            const SizedBox(height: 24),
            Text(
              l10n.speed,
              style: TextStyle(
                color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            _buildSegmentedControl<String>(
              context,
              value: settings.autoSpeed,
              items: {
                'slow': l10n.speedSlow,
                'medium': l10n.speedMedium,
                'fast': l10n.speedFast,
              },
              onChanged: (val) {
                settings.autoSpeed = val;
                audio.applyVisualizerSettings(
                  orientation: MediaQuery.of(context).orientation,
                );
                setDialogState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpectrumAdvancedControls(
    BuildContext context,
    WidgetRef ref,
    StateSetter setDialogState,
  ) {
    final options = ref.watch(audioCurrentVisualizerOptionsProvider);
    final isZh = Localizations.localeOf(context).languageCode == 'zh';

    return _buildSectionCard(
      context: context,
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        children: [
          _buildOptionSlider(
            context,
            label: AppLocalizations.of(context)!.smoothing,
            value: options.smoothingCoefficient,
            min: 0.0,
            max: 1.0,
            onChanged: (val) {
              audio.updateVisualOptions(
                options.copyWith(smoothingCoefficient: val),
              );
              setDialogState(() {});
            },
            onChangeEnd: () => audio.saveVisualizerOptions(),
          ),
          _buildOptionSlider(
            context,
            label: AppLocalizations.of(context)!.gravity,
            value: options.gravityCoefficient,
            min: 0.1,
            max: 5.0,
            onChanged: (val) {
              audio.updateVisualOptions(
                options.copyWith(gravityCoefficient: val),
              );
              setDialogState(() {});
            },
            onChangeEnd: () => audio.saveVisualizerOptions(),
          ),
          if (settings.visualizerStyle == VisualizerStyle.floatingBars)
            _buildOptionSlider(
              context,
              label: isZh ? '浮帽下落速度 (Cap Speed)' : 'Cap Fall Speed',
              value: settings.visualizerCapDropSpeed,
              min: 0.05,
              max: 1.0,
              onChanged: (val) {
                settings.visualizerCapDropSpeed = val;
                setDialogState(() {});
              },
            ),
          _buildOptionSlider(
            context,
            label: AppLocalizations.of(context)!.logScale,
            value: options.logarithmicScale,
            min: 1.0,
            max: 5.0,
            onChanged: (val) {
              audio.updateVisualOptions(
                options.copyWith(logarithmicScale: val),
              );
              setDialogState(() {});
            },
            onChangeEnd: () => audio.saveVisualizerOptions(),
          ),
          _buildOptionSlider(
            context,
            label: AppLocalizations.of(context)!.contrast,
            value: options.groupContrastExponent,
            min: 0.1,
            max: 3.0,
            onChanged: (val) {
              audio.updateVisualOptions(
                options.copyWith(groupContrastExponent: val),
              );
              setDialogState(() {});
            },
            onChangeEnd: () => audio.saveVisualizerOptions(),
          ),
          _buildOptionSlider(
            context,
            label: AppLocalizations.of(context)!.normalization,
            value: options.normalizationFloorDb,
            min: -100.0,
            max: 0.0,
            onChanged: (val) {
              audio.updateVisualOptions(
                options.copyWith(normalizationFloorDb: val),
              );
              setDialogState(() {});
            },
            onChangeEnd: () => audio.saveVisualizerOptions(),
          ),
          _buildOptionSlider(
            context,
            label: AppLocalizations.of(context)!.multiplier,
            value: options.overallMultiplier,
            min: 0.5,
            max: 5.0,
            onChanged: (val) {
              audio.updateVisualOptions(
                options.copyWith(overallMultiplier: val),
              );
              setDialogState(() {});
            },
            onChangeEnd: () => audio.saveVisualizerOptions(),
          ),
          _buildOptionSlider(
            context,
            label: AppLocalizations.of(context)!.skipHighFrequency,
            value: options.skipHighFrequencyGroups.toDouble(),
            min: 0,
            max: 50,
            onChanged: (val) {
              audio.updateVisualOptions(
                options.copyWith(skipHighFrequencyGroups: val.toInt()),
              );
              setDialogState(() {});
            },
            onChangeEnd: () => audio.saveVisualizerOptions(),
          ),
          if (settings.visualizerStyle == VisualizerStyle.radial) ...[
            _buildOptionSlider(
              context,
              label: AppLocalizations.of(context)!.spectrumQuantity,
              value: (MediaQuery.of(context).orientation == Orientation.landscape
                      ? settings.landscapeFrequencyGroups
                      : settings.portraitFrequencyGroups)
                  .toDouble(),
              min: 8,
              max: 512,
              onChanged: (val) {
                final count = val.toInt();
                settings.landscapeFrequencyGroups = count;
                settings.portraitFrequencyGroups = count;
                audio.updateVisualOptions(
                  options.copyWith(frequencyGroups: count),
                );
                setDialogState(() {});
              },
              onChangeEnd: () => audio.saveVisualizerOptions(),
            ),
          ] else ...[
            _buildOptionSlider(
              context,
              label: AppLocalizations.of(context)!.landscapeFrequencyGroups,
              value: settings.landscapeFrequencyGroups.toDouble(),
              min: 8,
              max: 512,
              onChanged: (val) {
                settings.landscapeFrequencyGroups = val.toInt();
                if (MediaQuery.of(context).orientation == Orientation.landscape) {
                  audio.updateVisualOptions(
                    options.copyWith(frequencyGroups: val.toInt()),
                  );
                }
                setDialogState(() {});
              },
              onChangeEnd: () => audio.saveVisualizerOptions(),
            ),
            _buildOptionSlider(
              context,
              label: AppLocalizations.of(context)!.portraitFrequencyGroups,
              value: settings.portraitFrequencyGroups.toDouble(),
              min: 8,
              max: 512,
              onChanged: (val) {
                settings.portraitFrequencyGroups = val.toInt();
                if (MediaQuery.of(context).orientation == Orientation.portrait) {
                  audio.updateVisualOptions(
                    options.copyWith(frequencyGroups: val.toInt()),
                  );
                }
                setDialogState(() {});
              },
              onChangeEnd: () => audio.saveVisualizerOptions(),
            ),
            _buildOptionSlider(
              context,
              label: AppLocalizations.of(context)!.landscapeGap,
              value: settings.landscapeGap,
              min: 0.0,
              max: 10.0,
              onChanged: (val) {
                settings.landscapeGap = val;
                setDialogState(() {});
              },
            ),
            _buildOptionSlider(
              context,
              label: AppLocalizations.of(context)!.portraitGap,
              value: settings.portraitGap,
              min: 0.0,
              max: 10.0,
              onChanged: (val) {
                settings.portraitGap = val;
                setDialogState(() {});
              },
            ),
          ],
          _buildAggregationModeDropdown(context, options, setDialogState),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl<T>(
    BuildContext context, {
    required T value,
    required Map<T, String> items,
    required ValueChanged<T> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SegmentedButton<T>(
      segments: items.entries.map((e) {
        return ButtonSegment<T>(
          value: e.key,
          label: Text(e.value, style: const TextStyle(fontSize: 13)),
        );
      }).toList(),
      selected: {value},
      onSelectionChanged: (Set<T> selection) {
        onChanged(selection.first);
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
        selectedBackgroundColor: theme.colorScheme.primary,
        selectedForegroundColor: theme.colorScheme.onPrimary,
        foregroundColor: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
        side: BorderSide(
          color: isDark ? Colors.white12 : theme.colorScheme.outlineVariant,
        ),
      ),
    );
  }

  Widget _buildAggregationModeDropdown(
    BuildContext context,
    VisualizerOptimizationOptions options,
    StateSetter setDialogState,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
      child: SizedBox(
        width: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                AppLocalizations.of(context)!.aggregationMode,
                style: TextStyle(
                  color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            DropdownButtonFormField<FftAggregationMode>(
              initialValue: options.aggregationMode,
              dropdownColor: isDark ? Colors.grey[900] : theme.colorScheme.surfaceContainer,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
              items: FftAggregationMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(_aggregationModeLabel(context, mode)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  audio.updateVisualOptions(
                    options.copyWith(aggregationMode: val),
                  );
                  setDialogState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceTab(
    BuildContext context,
    SettingsService settings,
    StateSetter setDialogState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDynamicMeshBackground = settings.playbackBackgroundType == 1;
    final isSolidColorBackground = settings.playbackBackgroundType == 2;
    final isCustomImageBackground = settings.playbackBackgroundType == 3;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackgroundTypeDropdown(context, settings, setDialogState),
                if (settings.playbackBackgroundType == 0) ...[
                  const SizedBox(height: 20),
                  _buildOpacitySettings(context, settings, setDialogState),
                ],
                if (isDynamicMeshBackground) ...[
                  const SizedBox(height: 20),
                  _buildOptionSlider(
                    context,
                    label: l10n.speed,
                    value: settings.playbackMeshBackgroundSpeed,
                    min: 0.02,
                    max: 2.0,
                    onChanged: (val) {
                      settings.playbackMeshBackgroundSpeed = val;
                      setDialogState(() {});
                    },
                  ),
                ],
                if (isSolidColorBackground)
                  _buildSolidColorControls(context, settings, setDialogState),
                if (isCustomImageBackground)
                  _buildCustomImageControls(context, settings, setDialogState),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: isPortrait ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 12),
                  shape: isPortrait ? null : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    l10n.playbackRadialGradient,
                    style: TextStyle(
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                  value: settings.playbackRadialGradientEnabled,
                  activeThumbColor: theme.colorScheme.primary,
                  activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                  onChanged: (val) {
                    settings.playbackRadialGradientEnabled = val;
                    setDialogState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectrumAppearanceControls(
    BuildContext context,
    StateSetter setDialogState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          l10n.spectrumAppearanceGroup,
          resetLabel: l10n.resetAppearance,
          onReset: () {
            settings.resetVisualizerAppearance();
            final Orientation orientation = MediaQuery.of(
              context,
            ).orientation;
            audio.applyVisualizerSettings(orientation: orientation);
            setDialogState(() {});
          },
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVisualStyleDropdown(context, settings, setDialogState),
              const SizedBox(height: 12),
              _buildOptionSlider(
                context,
                label: l10n.opacity,
                value: settings.visualizerOpacity,
                min: 0.0,
                max: 1.0,
                onChanged: (val) {
                  settings.visualizerOpacity = val;
                  setDialogState(() {});
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: isPortrait ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 12),
                shape: isPortrait ? null : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  l10n.enableGradient,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    fontSize: 13,
                  ),
                ),
                value: settings.isVisualizerGradientEnabled,
                activeThumbColor: theme.colorScheme.primary,
                activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                onChanged: (val) {
                  settings.isVisualizerGradientEnabled = val;
                  setDialogState(() {});
                },
              ),
              const SizedBox(height: 4),
              if (settings.isVisualizerGradientEnabled) ...[
                _buildColorPickerRow(
                  context,
                  label: l10n.startColor,
                  color: settings.visualizerStartColor,
                  isDynamic: settings.isVisualizerDynamicStartColor,
                  onDynamicChanged: (val) {
                    settings.isVisualizerDynamicStartColor = val;
                    if (val) {
                      audio.updateDynamicColors();
                    }
                    setDialogState(() {});
                  },
                  onColorChanged: (c) {
                    settings.visualizerStartColor = c;
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 16),
                _buildColorPickerRow(
                  context,
                  label: l10n.endColor,
                  color: settings.visualizerEndColor,
                  isDynamic: settings.isVisualizerDynamicEndColor,
                  onDynamicChanged: (val) {
                    settings.isVisualizerDynamicEndColor = val;
                    if (val) {
                      audio.updateDynamicColors();
                    }
                    setDialogState(() {});
                  },
                  onColorChanged: (c) {
                    settings.visualizerEndColor = c;
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 16),
                _buildOptionSlider(
                  context,
                  label: l10n.gradientRangeStop1,
                  value: settings.visualizerGradientStop1,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (val) {
                    settings.visualizerGradientStop1 = val;
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 16),
                _buildOptionSlider(
                  context,
                  label: l10n.gradientRangeStop2,
                  value: settings.visualizerGradientStop2,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (val) {
                    settings.visualizerGradientStop2 = val;
                    setDialogState(() {});
                  },
                ),
              ] else ...[
                _buildColorPickerRow(
                  context,
                  label: l10n.color,
                  color: settings.visualizerColor,
                  isDynamic: settings.isVisualizerDynamicColor,
                  onDynamicChanged: (val) {
                    settings.isVisualizerDynamicColor = val;
                    if (val) {
                      audio.updateDynamicColors();
                    }
                    setDialogState(() {});
                  },
                  onColorChanged: (c) {
                    settings.visualizerColor = c;
                    setDialogState(() {});
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    VoidCallback? onChangeEnd,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
      child: SizedBox(
        width: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                '$label: ${value.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: theme.colorScheme.primary,
                inactiveTrackColor: isDark ? Colors.white12 : theme.colorScheme.primary.withValues(alpha: 0.12),
                thumbColor: theme.colorScheme.primary,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
                onChangeEnd: (val) => onChangeEnd?.call(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpacitySettings(
    BuildContext context,
    SettingsService settings,
    StateSetter setDialogState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOptionSlider(
          context,
          label: l10n.normalOpacity,
          value: settings.playbackBackgroundNormalOpacity,
          min: 0.0,
          max: 1.0,
          onChanged: (val) {
            settings.playbackBackgroundNormalOpacity = val;
            setDialogState(() {});
          },
        ),
        const SizedBox(height: 12),
        _buildOptionSlider(
          context,
          label: l10n.lyricsOpacity,
          value: settings.playbackBackgroundLyricsOpacity,
          min: 0.0,
          max: 1.0,
          onChanged: (val) {
            settings.playbackBackgroundLyricsOpacity = val;
            setDialogState(() {});
          },
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
          child: TextButton.icon(
            onPressed: () {
              settings.playbackBackgroundNormalOpacity =
                  SettingsService.defaultPlaybackBackgroundNormalOpacity;
              settings.playbackBackgroundLyricsOpacity =
                  SettingsService.defaultPlaybackBackgroundLyricsOpacity;
              settings.playbackBlurredArtworkBlurSigma =
                  SettingsService.defaultPlaybackBlurredArtworkBlurSigma;
              settings.playbackCustomImageBlurSigma =
                  SettingsService.defaultPlaybackCustomImageBlurSigma;
              setDialogState(() {});
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              l10n.reset,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPickerRow(
    BuildContext context, {
    required String label,
    required Color color,
    required ValueChanged<Color> onColorChanged,
    bool isDynamic = false,
    ValueChanged<bool>? onDynamicChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 16),
              if (!isDynamic)
                InkWell(
                  onTap: () => _pickColor(context, color, onColorChanged),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isDark ? Colors.white70 : theme.colorScheme.outlineVariant,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
          if (onDynamicChanged != null)
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.followCoverColor,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                Switch(
                  value: isDynamic,
                  activeThumbColor: theme.colorScheme.primary,
                  activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                  onChanged: onDynamicChanged,
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _pickColor(
    BuildContext context,
    Color initialColor,
    ValueChanged<Color> onColorChanged,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color selectedColor = initialColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : theme.colorScheme.surface,
          title: Text(
            AppLocalizations.of(context)!.selectColor,
            style: TextStyle(color: isDark ? Colors.white : theme.colorScheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (c) => selectedColor = c,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                onColorChanged(selectedColor);
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.confirm,
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundTypeDropdown(
    BuildContext context,
    SettingsService settings,
    StateSetter setDialogState,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.playbackBackground,
            style: TextStyle(
              color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        DropdownButtonFormField<int>(
          initialValue: settings.playbackBackgroundType,
          dropdownColor: isDark ? Colors.grey[900] : theme.colorScheme.surfaceContainer,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : theme.colorScheme.outlineVariant,
              ),
            ),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
            fontSize: 14,
          ),
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text(AppLocalizations.of(context)!.blurredArtwork),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text(AppLocalizations.of(context)!.dynamicMesh),
            ),
            DropdownMenuItem(
              value: 2,
              child: Text(AppLocalizations.of(context)!.solidColor),
            ),
            DropdownMenuItem(
              value: 3,
              child: Text(AppLocalizations.of(context)!.customImage),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              settings.playbackBackgroundType = val;
              setDialogState(() {});
            }
          },
        ),
      ],
    ),
  );
}

  Widget _buildSolidColorControls(
    BuildContext context,
    SettingsService settings,
    StateSetter setDialogState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final presetColors = isDark
        ? [
            0xFF121212, // Classic Dark
            0xFF1A1F2C, // Midnight Blue
            0xFF2D1B4E, // Deep Purple
            0xFF0D2D20, // Dark Emerald
            0xFF3A1A22, // Velvet Burgundy
            0xFF202225, // Slate Gray
          ]
        : [
            0xFFF5F5F7, // Classic Light
            0xFFE8ECEF, // Soft Blue
            0xFFF0EBF4, // Soft Purple
            0xFFE2EBE5, // Soft Emerald
            0xFFF5EBF0, // Soft Burgundy
            0xFFECEFF1, // Soft Gray
          ];
    final activeColor = settings.playbackBackgroundColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
          child: Text(
            l10n.presetColors,
            style: TextStyle(
              color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...presetColors.map((colorValue) {
              final color = Color(colorValue);
              final isSelected = activeColor == colorValue;
              return GestureDetector(
                onTap: () {
                  settings.playbackBackgroundColor = colorValue;
                  setDialogState(() {});
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.white24 : theme.colorScheme.outlineVariant),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              );
            }),
            GestureDetector(
              onTap: () {
                _pickColor(
                  context,
                  Color(settings.playbackBackgroundColor),
                  (c) {
                    settings.playbackBackgroundColor = c.toARGB32();
                    setDialogState(() {});
                  },
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: !presetColors.contains(activeColor)
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white24 : theme.colorScheme.outlineVariant),
                    width: !presetColors.contains(activeColor) ? 3 : 1,
                  ),
                ),
                child: Icon(
                  Icons.color_lens_outlined,
                  color: !presetColors.contains(activeColor)
                      ? theme.colorScheme.primary
                      : (isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
        const SizedBox(height: 20),
        _buildOpacitySettings(context, settings, setDialogState),
      ],
    );
  }

  Widget _buildCustomImageControls(
    BuildContext context,
    SettingsService settings,
    StateSetter setDialogState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final path = settings.playbackBackgroundCustomImagePath;
    final hasImage = path.isNotEmpty && File(path).existsSync();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
          child: Text(
            l10n.customImage,
            style: TextStyle(
              color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(path),
                    width: 90,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 60,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: isDark ? Colors.white38 : Colors.black38,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _pickCustomImage(context, settings, setDialogState),
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: Text(l10n.uploadImage),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildOpacitySettings(context, settings, setDialogState),
      ],
    );
  }

  Future<void> _pickCustomImage(
    BuildContext context,
    SettingsService settings,
    StateSetter setDialogState,
  ) async {
    try {
      final originalPath = await FileSelectorHelper.pickFile(
        label: 'Images',
        extensions: const ['jpg', 'jpeg', 'png', 'webp', 'bmp'],
        fileType: FileType.image,
      );

      if (originalPath != null) {
        final appSupportDir = await getApplicationSupportDirectory();
        
        // Create custom_backgrounds directory under Application Support
        final targetDir = Directory(p.join(appSupportDir.path, 'custom_backgrounds'));
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        
        // Delete the previous custom background image if it was also in this directory
        final oldPath = settings.playbackBackgroundCustomImagePath;
        if (oldPath.isNotEmpty) {
          final oldFile = File(oldPath);
          if (p.isWithin(targetDir.path, oldPath) && await oldFile.exists()) {
            try {
              await oldFile.delete();
            } catch (e) {
              debugPrint('Error deleting old custom background image: $e');
            }
          }
        }
        
        // Copy selected file to our custom_backgrounds directory
        final extension = p.extension(originalPath);
        final newFileName = 'custom_bg_${DateTime.now().millisecondsSinceEpoch}$extension';
        final newPath = p.join(targetDir.path, newFileName);
        
        final originalFile = File(originalPath);
        await originalFile.copy(newPath);
        
        settings.playbackBackgroundCustomImagePath = newPath;
        setDialogState(() {});
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? resetLabel,
    VoidCallback? onReset,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (onReset != null)
          TextButton.icon(
            onPressed: onReset,
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: Text(resetLabel ?? AppLocalizations.of(context)!.reset),
          ),
      ],
    );
  }

  String _visualizerStyleLabel(BuildContext context, VisualizerStyle style) {
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    return switch (style) {
      VisualizerStyle.bars => isZh ? '经典柱状 (Classic Bars)' : 'Classic Bars',
      VisualizerStyle.smoothWave => isZh ? '平滑波浪 (Smooth Wave)' : 'Smooth Wave',
      VisualizerStyle.floatingBars => isZh ? '浮动顶帽 (Floating Caps)' : 'Floating Caps',
      VisualizerStyle.radial => isZh ? '环形光晕 (Radial Halo)' : 'Radial Halo',
      VisualizerStyle.matrix => isZh ? '点阵矩阵 (Neon Matrix)' : 'Neon Matrix',
      VisualizerStyle.mirroredWave => isZh ? '对称镜像波 (Mirrored Wave)' : 'Mirrored Wave',
    };
  }

  Widget _buildVisualStyleDropdown(
    BuildContext context,
    SettingsService settings,
    StateSetter setDialogState,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final isZh = Localizations.localeOf(context).languageCode == 'zh';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isPortrait ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              isZh ? '频谱样式' : 'Spectrum Style',
              style: TextStyle(
                color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          DropdownButtonFormField<VisualizerStyle>(
            initialValue: settings.visualizerStyle,
            dropdownColor: isDark ? Colors.grey[900] : theme.colorScheme.surfaceContainer,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 14,
            ),
            items: VisualizerStyle.values.map((style) {
              return DropdownMenuItem<VisualizerStyle>(
                value: style,
                child: Text(_visualizerStyleLabel(context, style)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                settings.visualizerStyle = val;
                final orientation = MediaQuery.of(context).orientation;
                if (settings.isAutoMode) {
                  audio.applyVisualizerSettings(
                    orientation: orientation,
                  );
                } else {
                  audio.visualizerOptions.loadOptions(
                    style: val,
                    orientation: orientation,
                  );
                }
                setDialogState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  String _aggregationModeLabel(BuildContext context, FftAggregationMode mode) {
    final l10n = AppLocalizations.of(context)!;
    return switch (mode) {
      FftAggregationMode.peak => l10n.aggregationPeak,
      FftAggregationMode.mean => l10n.aggregationMean,
      FftAggregationMode.rms => l10n.aggregationRms,
    };
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }
}

void showVisualizerOptionsDialog(
  BuildContext context,
  AudioService audio,
  SettingsService settings,
) {
  showDialog(
    context: context,
    builder: (context) =>
        VisualizerOptionsDialog(audio: audio, settings: settings),
  );
}
