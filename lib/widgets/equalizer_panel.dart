import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_core/audio_core.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/audio/equalizer_presets.dart';
import 'package:vynody/player/settings/settings_service.dart';
import '../l10n/app_localizations.dart';

class EqualizerPanel extends ConsumerStatefulWidget {
  const EqualizerPanel({super.key});

  @override
  ConsumerState<EqualizerPanel> createState() => _EqualizerPanelState();
}

class _EqualizerPanelState extends ConsumerState<EqualizerPanel> {
  String? _selectedPresetId;
  final ScrollController _eqScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bandCount = ref.read(settingsServiceProvider).equalizerBandCount;
      ref.read(audioServiceProvider).ensureEqualizerBandCount(bandCount);
    });
  }

  @override
  void dispose() {
    _eqScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      settingsServiceProvider.select((s) => s.equalizerBandCount),
      (previous, next) {
        ref.read(audioServiceProvider).ensureEqualizerBandCount(next);
      },
    );

    final settings = ref.watch(settingsServiceProvider);
    final bandCount = settings.equalizerBandCount;

    final audio = ref.read(audioServiceProvider);
    final snapshot = ref.watch(audioSnapshotProvider);
    final config = snapshot.equalizerConfig;
    final playbackSpeed = snapshot.playbackSpeed;
    final frequencies = audio.getEqualizerBandCenters(bandCount: bandCount);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.75)
                      : theme.colorScheme.surface.withValues(alpha: 0.95),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(audio, config, l10n),
                    const SizedBox(height: 14),
                    _buildPresetBar(
                      audio,
                      config,
                      accentColor,
                      bandCount,
                      frequencies,
                      l10n,
                    ),
                    const SizedBox(height: 18),
                    _buildEqSliders(
                      audio,
                      config,
                      accentColor,
                      bandCount,
                      frequencies,
                    ),
                    const SizedBox(height: 28),
                    _buildBottomControls(audio, config, accentColor, l10n),
                    const SizedBox(height: 24),
                    Divider(
                      height: 1,
                      color: isDark
                          ? Colors.white10
                          : theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    _buildSpeedControl(audio, playbackSpeed, accentColor, l10n),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedControl(
    AudioService audio,
    double playbackSpeed,
    Color accentColor,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final SettingsService settings = ref.watch(settingsServiceProvider);
    final limit5x = settings.playbackSpeedLimit5x;
    final maxLimit = limit5x ? 5.0 : 2.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.playbackSpeed,
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                '${playbackSpeed.toStringAsFixed(2)}x',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  value: playbackSpeed.clamp(0.5, maxLimit),
                  min: 0.5,
                  max: maxLimit,
                  divisions: limit5x ? 90 : 30,
                  activeColor: accentColor,
                  inactiveColor: isDark
                    ? Colors.white12
                    : theme.colorScheme.outlineVariant,
                  onChanged: (val) => audio.setPlaybackSpeed(val),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: playbackSpeed == 1.0
                  ? null
                  : () => audio.setPlaybackSpeed(1.0),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.reset,
                style: TextStyle(
                  fontSize: 12,
                  color: playbackSpeed == 1.0
                      ? (isDark ? Colors.white30 : Colors.black26)
                      : accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 5.0]
                  .where((speed) => speed <= maxLimit)
                  .map((speed) {
                final isSelected = (playbackSpeed - speed).abs() < 0.01;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      speed == 1.0 ? '1.0x (${l10n.normal})' : '${speed}x',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        audio.setPlaybackSpeed(speed);
                      }
                    },
                    showCheckmark: false,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: accentColor,
                    backgroundColor: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.playbackSpeedLimit5x,
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                height: 24,
                child: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: limit5x,
                    activeThumbColor: accentColor,
                    activeTrackColor: accentColor.withValues(alpha: 0.5),
                    onChanged: (val) {
                      settings.playbackSpeedLimit5x = val;
                      final nextMax = val ? 5.0 : 2.0;
                      if (playbackSpeed > nextMax) {
                        audio.setPlaybackSpeed(nextMax);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(
    AudioService audio,
    EqualizerConfig config,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.equalizer,
              style: TextStyle(
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              config.enabled
                  ? l10n.equalizerEnabledStatus
                  : l10n.equalizerDisabledStatus,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Switch(
          value: config.enabled,
          activeThumbColor: accentColor,
          activeTrackColor: accentColor.withValues(alpha: 0.5),
          onChanged: (val) => audio.setEqualizerEnabled(val),
        ),
      ],
    );
  }

  Widget _buildPresetBar(
    AudioService audio,
    EqualizerConfig config,
    Color accentColor,
    int bandCount,
    List<double> frequencies,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsServiceProvider);

    final currentGains = config.bandGainsDb.length >= bandCount
        ? config.bandGainsDb.sublist(0, bandCount)
        : config.bandGainsDb.toList();
    final matchedPreset = EqualizerPresets.findMatchingPreset(
      currentGains,
      frequencies,
      customPresets: settings.customEqPresets,
    );

    if (matchedPreset != null) {
      _selectedPresetId = matchedPreset.id;
    }

    EqPreset? activePreset;
    if (_selectedPresetId != null) {
      final allPresets = [...settings.customEqPresets, ...EqualizerPresets.all];
      activePreset =
          allPresets.where((p) => p.id == _selectedPresetId).firstOrNull;
    }

    final bool isModified = matchedPreset == null && activePreset != null;
    final bool isCustomPreset =
        (matchedPreset?.isCustom ?? activePreset?.isCustom) ?? false;
    final displayPreset = matchedPreset ?? activePreset;

    final String presetName;
    if (matchedPreset != null) {
      presetName = matchedPreset.getLocalizedName(l10n);
    } else if (activePreset != null) {
      presetName = '${activePreset.getLocalizedName(l10n)} (${l10n.modified})';
    } else {
      presetName = l10n.custom;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Preset selector trigger button
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showPresetPickerModal(
                  context,
                  audio,
                  config,
                  frequencies,
                  bandCount,
                  l10n,
                ),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        matchedPreset != null
                            ? (isCustomPreset
                                ? Icons.person_pin_circle_outlined
                                : Icons.graphic_eq_rounded)
                            : (isModified
                                ? Icons.tune_rounded
                                : Icons.tune_rounded),
                        size: 18,
                        color: accentColor,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          presetName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (displayPreset != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.bandsCountOption(displayPreset.bandCount),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark
                            ? Colors.white54
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (activePreset != null && activePreset.isCustom && isModified) ...[
            // Update current custom preset
            IconButton(
              onPressed: () => _updateCurrentCustomPreset(
                context,
                activePreset!,
                currentGains,
                frequencies,
                bandCount,
                config.bassBoostDb,
                config.preampDb,
                l10n,
              ),
              icon: const Icon(Icons.save_rounded, size: 18),
              color: accentColor,
              style: IconButton.styleFrom(
                backgroundColor: accentColor.withValues(alpha: 0.12),
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              tooltip: l10n.updatePreset,
            ),
            const SizedBox(width: 6),
            // Save as new preset option
            IconButton(
              onPressed: () => _showSavePresetDialog(
                context,
                currentGains,
                frequencies,
                bandCount,
                config.bassBoostDb,
                config.preampDb,
                l10n,
              ),
              icon: const Icon(Icons.bookmark_add_outlined, size: 18),
              color: accentColor,
              style: IconButton.styleFrom(
                backgroundColor: accentColor.withValues(alpha: 0.12),
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              tooltip: l10n.saveAsNewPreset,
            ),
          ] else ...[
            // Save as preset action button
            IconButton(
              onPressed: () => _showSavePresetDialog(
                context,
                currentGains,
                frequencies,
                bandCount,
                config.bassBoostDb,
                config.preampDb,
                l10n,
              ),
              icon: const Icon(Icons.bookmark_add_outlined, size: 18),
              color: accentColor,
              style: IconButton.styleFrom(
                backgroundColor: accentColor.withValues(alpha: 0.12),
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              tooltip: l10n.saveAsPreset,
            ),
          ],
        ],
      ),
    );
  }

  void _updateCurrentCustomPreset(
    BuildContext context,
    EqPreset preset,
    List<double> currentGains,
    List<double> frequencies,
    int bandCount,
    double bassBoost,
    double preamp,
    AppLocalizations l10n,
  ) {
    final updated = EqualizerPresets.updateCustomPreset(
      existing: preset,
      currentGains: currentGains,
      targetFreqs: frequencies,
      sourceBandCount: bandCount,
      bassBoost: bassBoost,
      preamp: preamp,
    );
    ref.read(settingsServiceProvider).saveCustomEqPreset(updated);
    setState(() {
      _selectedPresetId = updated.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l10n.presetUpdated}: ${updated.getLocalizedName(l10n)} (${l10n.bandsCountOption(updated.bandCount)})',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPresetPickerModal(
    BuildContext context,
    AudioService audio,
    EqualizerConfig config,
    List<double> frequencies,
    int bandCount,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _PresetPickerDialog(
        audio: audio,
        config: config,
        frequencies: frequencies,
        bandCount: bandCount,
        onPresetSelected: (preset) {
          setState(() {
            _selectedPresetId = preset.id;
          });
        },
        onSaveNewPresetTap: () {
          Navigator.of(dialogContext).pop();
          final currentGains = config.bandGainsDb.length >= bandCount
              ? config.bandGainsDb.sublist(0, bandCount)
              : config.bandGainsDb.toList();
          _showSavePresetDialog(
            context,
            currentGains,
            frequencies,
            bandCount,
            config.bassBoostDb,
            config.preampDb,
            l10n,
          );
        },
        onRenamePresetTap: (preset) {
          _showRenamePresetDialog(context, preset, l10n);
        },
        onUpdatePresetTap: (preset) {
          final currentGains = config.bandGainsDb.length >= bandCount
              ? config.bandGainsDb.sublist(0, bandCount)
              : config.bandGainsDb.toList();
          _updateCurrentCustomPreset(
            context,
            preset,
            currentGains,
            frequencies,
            bandCount,
            config.bassBoostDb,
            config.preampDb,
            l10n,
          );
        },
      ),
    );
  }

  bool _isPresetNameDuplicate({
    required String name,
    required AppLocalizations l10n,
    String? excludeId,
  }) {
    final trimmed = name.trim().toLowerCase();
    if (trimmed.isEmpty) return false;

    // Check built-in preset localized names & ids
    for (final p in EqualizerPresets.all) {
      if (p.getLocalizedName(l10n).trim().toLowerCase() == trimmed ||
          p.id.trim().toLowerCase() == trimmed) {
        return true;
      }
    }

    // Check custom presets
    final customPresets = ref.read(settingsServiceProvider).customEqPresets;
    for (final p in customPresets) {
      if (excludeId != null && p.id == excludeId) continue;
      if (p.getLocalizedName(l10n).trim().toLowerCase() == trimmed) {
        return true;
      }
    }

    return false;
  }

  Future<void> _showRenamePresetDialog(
    BuildContext context,
    EqPreset preset,
    AppLocalizations l10n,
  ) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    final initialName = preset.getLocalizedName(l10n);
    final controller = TextEditingController(text: initialName);
    final messenger = ScaffoldMessenger.of(context);
    String? errorText;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          void validate(String val) {
            final trimmed = val.trim();
            if (trimmed.isEmpty) {
              setDialogState(() {
                errorText = null;
              });
              return;
            }
            if (_isPresetNameDuplicate(
              name: trimmed,
              l10n: l10n,
              excludeId: preset.id,
            )) {
              setDialogState(() {
                errorText = l10n.presetNameAlreadyExists;
              });
            } else {
              setDialogState(() {
                errorText = null;
              });
            }
          }

          final trimmed = controller.text.trim();
          final isDuplicate = _isPresetNameDuplicate(
            name: trimmed,
            l10n: l10n,
            excludeId: preset.id,
          );
          final canSubmit =
              trimmed.isNotEmpty && !isDuplicate && trimmed != initialName;

          return AlertDialog(
            backgroundColor:
                isDark ? const Color(0xFF1E1E1E) : theme.colorScheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.edit_rounded, color: accentColor),
                const SizedBox(width: 10),
                Text(
                  l10n.renamePreset,
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: l10n.enterPresetName,
                    labelText: l10n.presetName,
                    errorText: errorText,
                    counterText: '',
                    prefixIcon: const Icon(Icons.edit_outlined, size: 20),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white12
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                  onChanged: (val) {
                    validate(val);
                  },
                  onSubmitted: (val) {
                    final text = val.trim();
                    if (text.isEmpty) {
                      setDialogState(() {
                        errorText = l10n.presetNameCannotBeEmpty;
                      });
                      return;
                    }
                    if (_isPresetNameDuplicate(
                      name: text,
                      l10n: l10n,
                      excludeId: preset.id,
                    )) {
                      setDialogState(() {
                        errorText = l10n.presetNameAlreadyExists;
                      });
                      return;
                    }
                    Navigator.of(dialogCtx).pop(text);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  MaterialLocalizations.of(dialogCtx).cancelButtonLabel,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white60
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              FilledButton(
                onPressed: canSubmit
                    ? () {
                        final text = controller.text.trim();
                        if (text.isEmpty) {
                          setDialogState(() {
                            errorText = l10n.presetNameCannotBeEmpty;
                          });
                          return;
                        }
                        if (_isPresetNameDuplicate(
                          name: text,
                          l10n: l10n,
                          excludeId: preset.id,
                        )) {
                          setDialogState(() {
                            errorText = l10n.presetNameAlreadyExists;
                          });
                          return;
                        }
                        Navigator.of(dialogCtx).pop(text);
                      }
                    : null,
                child: Text(MaterialLocalizations.of(dialogCtx).okButtonLabel),
              ),
            ],
          );
        },
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      ref.read(settingsServiceProvider).renameCustomEqPreset(preset.id, result);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.presetRenamed}: $result'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showSavePresetDialog(
    BuildContext context,
    List<double> currentGains,
    List<double> frequencies,
    int bandCount,
    double bassBoost,
    double preamp,
    AppLocalizations l10n,
  ) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    String? errorText;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          void validate(String val) {
            final trimmed = val.trim();
            if (trimmed.isEmpty) {
              setDialogState(() {
                errorText = null;
              });
              return;
            }
            if (_isPresetNameDuplicate(name: trimmed, l10n: l10n)) {
              setDialogState(() {
                errorText = l10n.presetNameAlreadyExists;
              });
            } else {
              setDialogState(() {
                errorText = null;
              });
            }
          }

          final trimmed = controller.text.trim();
          final isDuplicate = _isPresetNameDuplicate(name: trimmed, l10n: l10n);
          final canSubmit = trimmed.isNotEmpty && !isDuplicate;

          return AlertDialog(
            backgroundColor:
                isDark ? const Color(0xFF1E1E1E) : theme.colorScheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.bookmark_add_rounded, color: accentColor),
                const SizedBox(width: 10),
                Text(
                  l10n.saveAsPreset,
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.savePresetPrompt} (${l10n.bandsCountOption(bandCount)})',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white60
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: l10n.enterPresetName,
                    labelText: l10n.presetName,
                    errorText: errorText,
                    counterText: '',
                    prefixIcon: const Icon(Icons.edit_outlined, size: 20),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white12
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                  onChanged: (val) {
                    validate(val);
                  },
                  onSubmitted: (val) {
                    final text = val.trim();
                    if (text.isEmpty) {
                      setDialogState(() {
                        errorText = l10n.presetNameCannotBeEmpty;
                      });
                      return;
                    }
                    if (_isPresetNameDuplicate(name: text, l10n: l10n)) {
                      setDialogState(() {
                        errorText = l10n.presetNameAlreadyExists;
                      });
                      return;
                    }
                    Navigator.of(dialogCtx).pop(text);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  MaterialLocalizations.of(dialogCtx).cancelButtonLabel,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white60
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              FilledButton(
                onPressed: canSubmit
                    ? () {
                        final text = controller.text.trim();
                        if (text.isEmpty) {
                          setDialogState(() {
                            errorText = l10n.presetNameCannotBeEmpty;
                          });
                          return;
                        }
                        if (_isPresetNameDuplicate(name: text, l10n: l10n)) {
                          setDialogState(() {
                            errorText = l10n.presetNameAlreadyExists;
                          });
                          return;
                        }
                        Navigator.of(dialogCtx).pop(text);
                      }
                    : null,
                child: Text(MaterialLocalizations.of(dialogCtx).okButtonLabel),
              ),
            ],
          );
        },
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      final newPreset = EqualizerPresets.createCustomPreset(
        name: result,
        currentGains: currentGains,
        targetFreqs: frequencies,
        sourceBandCount: bandCount,
        bassBoost: bassBoost,
        preamp: preamp,
      );
      ref.read(settingsServiceProvider).saveCustomEqPreset(newPreset);
      setState(() {
        _selectedPresetId = newPreset.id;
      });

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('${l10n.presetSaved}: $result'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildEqSliders(
    AudioService audio,
    EqualizerConfig config,
    Color accentColor,
    int bandCount,
    List<double> frequencies,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const double minItemWidth = 48.0;

    return SizedBox(
      height: 236,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidthNeeded = minItemWidth * bandCount;
          final needsScroll = totalWidthNeeded > constraints.maxWidth;

          final sliders = List.generate(bandCount, (index) {
            final gain = index < config.bandGainsDb.length
                ? config.bandGainsDb[index]
                : 0.0;

            final sliderItem = Column(
              children: [
                SizedBox(
                  height: 18,
                  child: Center(
                    child: InkWell(
                      onTap: () => audio.setEqualizerBandGain(index, 0.0),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatGain(gain),
                            style: TextStyle(
                              color: gain.abs() < 0.05
                                  ? (isDark
                                      ? Colors.white.withValues(alpha: 0.4)
                                      : theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.5))
                                  : (isDark
                                      ? Colors.white
                                      : theme.colorScheme.onSurface),
                              fontSize: 10,
                              fontWeight: gain.abs() < 0.05
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _VerticalEqSlider(
                    value: gain,
                    min: -12.0,
                    max: 12.0,
                    activeColor: accentColor,
                    onChanged: (val) => audio.setEqualizerBandGain(index, val),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    frequencies.length > index
                        ? _formatFreq(frequencies[index])
                        : '',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (needsScroll) const SizedBox(height: 6),
              ],
            );

            if (needsScroll) {
              return SizedBox(
                width: minItemWidth,
                child: sliderItem,
              );
            } else {
              return Expanded(child: sliderItem);
            }
          });

          if (needsScroll) {
            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: RawScrollbar(
                controller: _eqScrollController,
                thumbVisibility: true,
                interactive: true,
                thickness: 4.0,
                radius: const Radius.circular(2),
                thumbColor: accentColor.withValues(alpha: isDark ? 0.45 : 0.4),
                trackVisibility: true,
                trackColor: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
                trackRadius: const Radius.circular(2),
                padding: const EdgeInsets.only(bottom: 0),
                child: SingleChildScrollView(
                  controller: _eqScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: sliders,
                  ),
                ),
              ),
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: sliders,
            );
          }
        },
      ),
    );
  }

  Widget _buildBottomControls(
    AudioService audio,
    EqualizerConfig config,
    Color accentColor,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        _buildKnobControl(
          label: l10n.bassBoost,
          value: config.bassBoostDb,
          min: 0,
          max: 100,
          accentColor: accentColor,
          onChanged: (val) => audio.setBassBoost(val),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.preampGain,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${config.preampDb.toStringAsFixed(1)} dB',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  value: config.preampDb.clamp(-12.0, 12.0),
                  min: -12.0,
                  max: 12.0,
                  activeColor: accentColor,
                  inactiveColor: isDark
                      ? Colors.white12
                      : theme.colorScheme.outlineVariant,
                  onChanged: (val) => audio.setEqualizerPreamp(val),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () => audio.resetEqualizerDefaults(),
          icon: Icon(
            Icons.refresh,
            color: isDark ? Colors.white54 : theme.colorScheme.onSurfaceVariant,
          ),
          tooltip: l10n.reset,
        ),
      ],
    );
  }

  Widget _buildKnobControl({
    required String label,
    required double value,
    required double min,
    required double max,
    required Color accentColor,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        _Knob(
          value: value,
          min: min,
          max: max,
          size: 64,
          themeColor: accentColor,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toInt()}%',
          style: TextStyle(
            color: accentColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatFreq(double hz) {
    if (hz >= 1000) {
      final khz = hz / 1000.0;
      if (khz == khz.roundToDouble()) {
        return '${khz.toInt()}k';
      } else if ((khz * 10) == (khz * 10).roundToDouble()) {
        return '${khz.toStringAsFixed(1)}k';
      } else {
        return '${khz.toStringAsFixed(2)}k';
      }
    }
    if (hz == hz.roundToDouble()) {
      return hz.toInt().toString();
    }
    return hz.toStringAsFixed(1);
  }

  String _formatGain(double gain) {
    if (gain.abs() < 0.05) {
      return '0 dB';
    }
    final prefix = gain > 0 ? '+' : '';
    return '$prefix${gain.toStringAsFixed(1)} dB';
  }
}

/// Dialog for choosing and managing EQ presets.
class _PresetPickerDialog extends ConsumerWidget {
  final AudioService audio;
  final EqualizerConfig config;
  final List<double> frequencies;
  final int bandCount;
  final ValueChanged<EqPreset> onPresetSelected;
  final VoidCallback onSaveNewPresetTap;
  final ValueChanged<EqPreset> onRenamePresetTap;
  final ValueChanged<EqPreset> onUpdatePresetTap;

  const _PresetPickerDialog({
    required this.audio,
    required this.config,
    required this.frequencies,
    required this.bandCount,
    required this.onPresetSelected,
    required this.onSaveNewPresetTap,
    required this.onRenamePresetTap,
    required this.onUpdatePresetTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;
    final settings = ref.watch(settingsServiceProvider);

    final currentGains = config.bandGainsDb.length >= bandCount
        ? config.bandGainsDb.sublist(0, bandCount)
        : config.bandGainsDb.toList();
    final matchedPreset = EqualizerPresets.findMatchingPreset(
      currentGains,
      frequencies,
      customPresets: settings.customEqPresets,
    );

    final customPresets = settings.customEqPresets;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 560),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF18181B).withValues(alpha: 0.95)
                : theme.colorScheme.surface.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.equalizer_rounded,
                        color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.eqPresets,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onSaveNewPresetTap,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      l10n.saveAsPreset,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(6),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white10
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),

              // Presets list scrollable content
              Flexible(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // 1. Custom Presets Section
                      if (customPresets.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 4, top: 4, bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                l10n.customPresets,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${customPresets.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildPresetGrid(
                          context: context,
                          ref: ref,
                          presets: customPresets,
                          matchedPreset: matchedPreset,
                          accentColor: accentColor,
                          isDark: isDark,
                          l10n: l10n,
                          isCustomSection: true,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 2. Built-in Presets Section
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 4, top: 4, bottom: 8),
                        child: Text(
                          l10n.builtInPresets,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white70
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      _buildPresetGrid(
                        context: context,
                        ref: ref,
                        presets: EqualizerPresets.all,
                        matchedPreset: matchedPreset,
                        accentColor: accentColor,
                        isDark: isDark,
                        l10n: l10n,
                        isCustomSection: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetGrid({
    required BuildContext context,
    required WidgetRef ref,
    required List<EqPreset> presets,
    required EqPreset? matchedPreset,
    required Color accentColor,
    required bool isDark,
    required AppLocalizations l10n,
    bool isCustomSection = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 10) / crossAxisCount;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: presets.map((preset) {
            final isSelected = matchedPreset?.id == preset.id;
            return SizedBox(
              width: itemWidth,
              child: _buildPresetCard(
                context: context,
                ref: ref,
                preset: preset,
                isSelected: isSelected,
                accentColor: accentColor,
                isDark: isDark,
                l10n: l10n,
                isCustom: isCustomSection,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPresetCard({
    required BuildContext context,
    required WidgetRef ref,
    required EqPreset preset,
    required bool isSelected,
    required Color accentColor,
    required bool isDark,
    required AppLocalizations l10n,
    required bool isCustom,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (!config.enabled) {
            await audio.setEqualizerEnabled(true);
          }
          final gains = EqualizerPresets.calculateGainsForBands(
            preset,
            frequencies,
          );
          await audio.setEqualizerBandGains(gains);
          if (preset.bassBoost != null) {
            await audio.setBassBoost(preset.bassBoost!);
          }
          if (preset.preamp != null) {
            await audio.setEqualizerPreamp(preset.preamp!);
          }
          onPresetSelected(preset);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.15)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.3)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            preset.getLocalizedName(l10n),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? accentColor
                                  : (isDark
                                      ? Colors.white
                                      : theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accentColor.withValues(alpha: 0.22)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.7)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.bandsCountOption(preset.bandCount),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? accentColor
                                  : (isDark
                                      ? Colors.white60
                                      : theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.check_circle_rounded,
                              size: 14, color: accentColor),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    _MiniEqPreview(
                      referenceGains: preset.referenceGains,
                      color: isSelected
                          ? accentColor
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ],
                ),
              ),
              if (isCustom)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isDark
                      ? const Color(0xFF27272A)
                      : theme.colorScheme.surface,
                  tooltip: '',
                  onSelected: (value) {
                    if (value == 'rename') {
                      onRenamePresetTap(preset);
                    } else if (value == 'update') {
                      onUpdatePresetTap(preset);
                    } else if (value == 'delete') {
                      _confirmDeletePreset(context, ref, preset, l10n);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem<String>(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 16,
                              color: isDark ? Colors.white70 : Colors.black87),
                          const SizedBox(width: 10),
                          Text(l10n.renamePreset,
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'update',
                      child: Row(
                        children: [
                          Icon(Icons.sync_rounded,
                              size: 16, color: accentColor),
                          const SizedBox(width: 10),
                          Text(
                            l10n.updateWithCurrentSettings,
                            style:
                                TextStyle(fontSize: 13, color: accentColor),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded,
                              size: 16, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Text(
                            l10n.deletePreset,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeletePreset(
    BuildContext context,
    WidgetRef ref,
    EqPreset preset,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deletePreset,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${l10n.deletePresetConfirm}\n"${preset.getLocalizedName(l10n)}"',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? Colors.white70
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              MaterialLocalizations.of(dialogCtx).cancelButtonLabel,
              style: TextStyle(
                color: isDark
                    ? Colors.white60
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ref.read(settingsServiceProvider).deleteCustomEqPreset(preset.id);
            },
            child: Text(MaterialLocalizations.of(dialogCtx).deleteButtonTooltip),
          ),
        ],
      ),
    );
  }
}

/// Miniature EQ curve painter for visual preset preview.
class _MiniEqPreview extends StatelessWidget {
  final List<double> referenceGains;
  final Color color;

  const _MiniEqPreview({
    required this.referenceGains,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 18,
      child: CustomPaint(
        painter: _MiniEqCurvePainter(
          gains: referenceGains,
          color: color,
        ),
      ),
    );
  }
}

class _MiniEqCurvePainter extends CustomPainter {
  final List<double> gains;
  final Color color;

  _MiniEqCurvePainter({required this.gains, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (gains.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final midY = size.height / 2;
    // Draw subtle zero baseline
    canvas.drawLine(
      Offset(0, midY),
      Offset(size.width, midY),
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..strokeWidth = 0.8,
    );

    final stepX = size.width / (gains.length - 1);
    for (int i = 0; i < gains.length; i++) {
      final x = i * stepX;
      // gain is -12 to +12 dB. Map to height: +12 -> 2, -12 -> height-2
      final normalized = (-gains[i].clamp(-12.0, 12.0) + 12.0) / 24.0;
      final y = 2.0 + normalized * (size.height - 4.0);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, midY);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, midY);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniEqCurvePainter oldDelegate) =>
      oldDelegate.gains != gains || oldDelegate.color != color;
}

class _VerticalEqSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const _VerticalEqSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SizedBox(
        width: 32,
        child: RotatedBox(
          quarterTurns: 3,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: _CustomThumbShape(color: activeColor),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
              activeTrackColor: activeColor,
              inactiveTrackColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final Color color;

  const _CustomThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(12, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 6, height: 24),
      const Radius.circular(3),
    );

    // Subtle glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 10, height: 28),
        const Radius.circular(4),
      ),
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawRRect(rrect, paint);

    // Middle line indicator
    canvas.drawLine(
      Offset(center.dx - 2, center.dy),
      Offset(center.dx + 2, center.dy),
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
  }
}

class _Knob extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final double size;
  final Color themeColor;
  final ValueChanged<double> onChanged;

  const _Knob({
    required this.value,
    this.min = 0,
    this.max = 100,
    required this.size,
    required this.themeColor,
    required this.onChanged,
  });

  @override
  State<_Knob> createState() => _KnobState();
}

class _KnobState extends State<_Knob> {
  double _dragValue = 0;

  @override
  void initState() {
    super.initState();
    _dragValue = widget.value;
  }

  @override
  void didUpdateWidget(_Knob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _dragValue) {
      _dragValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final delta = details.primaryDelta! / widget.size;
        setState(() {
          _dragValue = (_dragValue - delta * (widget.max - widget.min)).clamp(
            widget.min,
            widget.max,
          );
        });
        widget.onChanged(_dragValue);
      },
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _KnobPainter(
          context: context,
          value: _dragValue,
          min: widget.min,
          max: widget.max,
          themeColor: widget.themeColor,
        ),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}

class _KnobPainter extends CustomPainter {
  final BuildContext context;
  final double value;
  final double min;
  final double max;
  final Color themeColor;

  _KnobPainter({
    required this.context,
    required this.value,
    required this.min,
    required this.max,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 6.0;

    // Background circle
    canvas.drawCircle(
      center,
      radius - strokeWidth / 2,
      Paint()
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.05)
            : theme.colorScheme.onSurface.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill,
    );

    // Track
    final trackPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : theme.colorScheme.onSurface.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = 0.75 * math.pi;
    const sweepAngleTotal = 1.5 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngleTotal,
      false,
      trackPaint,
    );

    // Active track
    final normalized = (value - min) / (max - min);
    final activePaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngleTotal * normalized,
      false,
      activePaint,
    );

    // Dot indicator
    final angle = startAngle + sweepAngleTotal * normalized;
    final dotPos = Offset(
      center.dx + (radius - 12) * math.cos(angle),
      center.dy + (radius - 12) * math.sin(angle),
    );

    canvas.drawCircle(
      dotPos,
      4,
      Paint()..color = isDark ? Colors.white : theme.colorScheme.onSurface,
    );

    // Inner hub
    canvas.drawCircle(
      center,
      radius - 18,
      Paint()
        ..color = isDark
            ? Colors.white10
            : theme.colorScheme.onSurface.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _KnobPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.themeColor != themeColor ||
      oldDelegate.context != context;
}
