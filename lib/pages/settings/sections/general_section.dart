import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/dialogs/playback_button_layout_dialog.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/pro/pro_models.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/widgets/pro/pro_badge.dart';
import '../widgets/settings_dropdown_tile.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class GeneralSection extends ConsumerWidget {
  final SettingsService settings;

  const GeneralSection({
    super.key,
    required this.settings,
  });

  Widget _buildThemeModeSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsDropdownTile<ThemeMode>(
      title: l10n.themeMode,
      value: settings.themeMode,
      options: [
        SettingsDropdownOption(
          value: ThemeMode.system,
          label: l10n.themeModeSystem,
        ),
        SettingsDropdownOption(
          value: ThemeMode.light,
          label: l10n.themeModeLight,
        ),
        SettingsDropdownOption(
          value: ThemeMode.dark,
          label: l10n.themeModeDark,
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        settings.themeMode = value;
      },
    );
  }

  void _pickCustomThemeColor(
    BuildContext context,
    SettingsService settings,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    Color selectedColor = settings.themeColor;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : theme.colorScheme.surface,
          title: Text(
            l10n.customThemeColor,
            style: TextStyle(
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: settings.themeColor,
              onColorChanged: (c) => selectedColor = c,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                settings.themeColor = selectedColor;
                Navigator.pop(dialogCtx);
              },
              child: Text(
                l10n.confirm,
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getPresetThemeColorName(BuildContext context, Color color) {
    final l10n = AppLocalizations.of(context)!;
    return switch (color.toARGB32()) {
      0xFF39C5BB => l10n.themeColorMikuTeal,
      0xFF2196F3 => l10n.themeColorClassicBlue,
      0xFF6750A4 => l10n.themeColorIrisPurple,
      0xFF7E57C2 => l10n.themeColorViolet,
      0xFFEC407A => l10n.themeColorSakuraPink,
      0xFFFF7043 => l10n.themeColorCoralOrange,
      0xFFFFA000 => l10n.themeColorAmberGold,
      0xFF4CAF50 => l10n.themeColorForestGreen,
      0xFF00ACC1 => l10n.themeColorAuroraCyan,
      0xFFE53935 => l10n.themeColorCrimsonRed,
      0xFF607D8B => l10n.themeColorSlateGrey,
      _ =>
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
    };
  }

  Widget _buildThemeColorSection(
    BuildContext context,
    WidgetRef ref,
    SettingsService settings,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currentColor = settings.themeColor;
    final isPresetSelected = SettingsService.presetThemeColors.any(
      (c) => c.toARGB32() == currentColor.toARGB32(),
    );
    final isProUnlocked = ref.watch(isProUnlockedProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.themeColor,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (currentColor.toARGB32() !=
                  SettingsService.defaultAppThemeColor.toARGB32())
                TextButton.icon(
                  onPressed: () {
                    settings.themeColor = SettingsService.defaultAppThemeColor;
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    l10n.restoreDefault,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...SettingsService.presetThemeColors.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                final isSelected = color.toARGB32() == currentColor.toARGB32();
                final isProColor = index >= 8;
                final showLock = isProColor && !isProUnlocked && !isSelected;

                return Tooltip(
                  message: _getPresetThemeColorName(context, color),
                  child: InkWell(
                    onTap: () async {
                      if (isProColor) {
                        final allowed = await checkProGate(
                          context,
                          ref,
                          feature: ProFeature.customThemeColor,
                        );
                        if (!allowed) return;
                      }
                      settings.themeColor = color;
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: ThemeData.estimateBrightnessForColor(color) ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            )
                          : (showLock
                              ? Icon(
                                  Icons.lock_rounded,
                                  size: 14,
                                  color: ThemeData.estimateBrightnessForColor(color) ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.black54,
                                )
                              : null),
                    ),
                  ),
                );
              }),
              Tooltip(
                message: l10n.customThemeColor,
                child: InkWell(
                  onTap: () async {
                    final allowed = await checkProGate(
                      context,
                      ref,
                      feature: ProFeature.customThemeColor,
                    );
                    if (!allowed) return;
                    if (!context.mounted) return;
                    _pickCustomThemeColor(context, settings);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: !isPresetSelected
                          ? currentColor
                          : (isDark ? Colors.white12 : Colors.black12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: !isPresetSelected
                            ? (isDark ? Colors.white : Colors.black87)
                            : (isDark ? Colors.white38 : Colors.black26),
                        width: !isPresetSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: !isPresetSelected
                          ? [
                              BoxShadow(
                                color: currentColor.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      !isPresetSelected
                          ? Icons.colorize_rounded
                          : (!isProUnlocked
                              ? Icons.lock_outline_rounded
                              : Icons.add_rounded),
                      size: 18,
                      color: !isPresetSelected
                          ? (ThemeData.estimateBrightnessForColor(currentColor) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black87)
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsDropdownTile<String>(
      title: l10n.interfaceLanguage,
      subtitle: l10n.interfaceLanguageDescription,
      value: settings.appLocale,
      options: [
        SettingsDropdownOption(
          value: 'system',
          label: l10n.followSystemLanguage,
        ),
        SettingsDropdownOption(
          value: 'zh',
          label: l10n.nativeLanguageZh,
        ),
        SettingsDropdownOption(
          value: 'zh_Hant',
          label: l10n.nativeLanguageZhHant,
        ),
        SettingsDropdownOption(
          value: 'ja',
          label: l10n.nativeLanguageJa,
        ),
        SettingsDropdownOption(
          value: 'ko',
          label: l10n.nativeLanguageKo,
        ),
        SettingsDropdownOption(
          value: 'es',
          label: l10n.nativeLanguageEs,
        ),
        SettingsDropdownOption(
          value: 'fr',
          label: l10n.nativeLanguageFr,
        ),
        SettingsDropdownOption(
          value: 'de',
          label: l10n.nativeLanguageDe,
        ),
        SettingsDropdownOption(
          value: 'tr',
          label: l10n.nativeLanguageTr,
        ),
        SettingsDropdownOption(
          value: 'en',
          label: l10n.nativeLanguageEn,
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        settings.appLocale = value;
      },
    );
  }

  Widget _buildUiScaleSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currentPercent = (settings.uiScale * 100).round();

    return ListTile(
      leading: const Icon(Icons.aspect_ratio_rounded),
      title: Text(l10n.uiDisplayScale),
      subtitle: Text(l10n.uiDisplayScaleDescription),
      trailing: FilledButton.tonal(
        onPressed: () => _showUiScaleDialog(context, settings),
        child: Text('$currentPercent%'),
      ),
      onTap: () => _showUiScaleDialog(context, settings),
    );
  }

  Future<void> _showUiScaleDialog(
    BuildContext context,
    SettingsService settings,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    double tempScale = settings.uiScale;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final percent = (tempScale * 100).round();
            return AlertDialog(
              title: Text(l10n.uiDisplayScaleDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.uiDisplayScaleCurrent(percent),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('80%'),
                        Expanded(
                          child: Slider(
                            value: tempScale.clamp(
                              SettingsService.minUiScale,
                              SettingsService.maxUiScale,
                            ),
                            min: SettingsService.minUiScale,
                            max: SettingsService.maxUiScale,
                            divisions: 14,
                            label: '$percent%',
                            onChanged: (value) {
                              setDialogState(() {
                                tempScale = (value * 20).round() / 20.0;
                              });
                              settings.uiScale = tempScale;
                            },
                          ),
                        ),
                        const Text('150%'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.quickPresets,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.presetStandard),
                          selected: (tempScale - 1.0).abs() < 0.01,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => tempScale = 1.0);
                              settings.uiScale = 1.0;
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text(l10n.presetModerate),
                          selected: (tempScale - 1.25).abs() < 0.01,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => tempScale = 1.25);
                              settings.uiScale = 1.25;
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text(l10n.presetCarRecommended),
                          selected: (tempScale - 1.35).abs() < 0.01,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => tempScale = 1.35);
                              settings.uiScale = 1.35;
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text(l10n.presetLarge),
                          selected: (tempScale - 1.50).abs() < 0.01,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => tempScale = 1.50);
                              settings.uiScale = 1.50;
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() => tempScale = SettingsService.defaultUiScale);
                    settings.uiScale = SettingsService.defaultUiScale;
                  },
                  child: Text(l10n.reset),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isProUnlocked = ref.watch(isProUnlockedProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SettingsSectionHeader(
          title: l10n.generalSectionTitle,
          description: l10n.generalSectionDescription,
        ),
        SettingsGroupCard(
          title: l10n.uiAppearanceGroup,
          icon: Icons.palette_outlined,
          children: [
            _buildThemeModeSection(context, settings),
            _buildThemeColorSection(context, ref, settings),
            _buildLanguageSection(context, settings),
            _buildUiScaleSection(context, settings),
            SwitchListTile(
              title: Text(l10n.collapseButtonsInLandscapeLyrics),
              subtitle: Text(l10n.collapseButtonsInLandscapeLyricsDescription),
              value: settings.collapseButtonsInLandscapeLyrics,
              onChanged: (value) {
                settings.collapseButtonsInLandscapeLyrics = value;
              },
            ),
            ListTile(
              title: Text(l10n.playbackButtonLayoutTitle),
              subtitle: Text(l10n.playbackButtonLayoutDescription),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showPlaybackButtonLayoutDialog(context, settings),
            ),
            SwitchListTile(
              title: Text(l10n.showDeveloperOptions),
              subtitle: Text(l10n.showDeveloperOptionsDescription),
              value: settings.showDeveloperOptions,
              onChanged: (value) {
                settings.showDeveloperOptions = value;
              },
            ),
          ],
        ),
        SettingsGroupCard(
          title: l10n.playbackBehaviorGroup,
          icon: Icons.touch_app_outlined,
          children: [
            SwitchListTile(
              title: Text(l10n.immersiveTabBar),
              subtitle: Text(l10n.immersiveTabBarDescription),
              value: settings.isImmersiveTabBarEnabled,
              onChanged: (value) {
                settings.isImmersiveTabBarEnabled = value;
              },
            ),
            SwitchListTile(
              title: Text(l10n.openPlaybackOnDirectorySongTap),
              subtitle: Text(l10n.openPlaybackOnDirectorySongTapDescription),
              value: settings.openPlaybackOnDirectorySongTap,
              onChanged: (value) {
                settings.openPlaybackOnDirectorySongTap = value;
              },
            ),
            SwitchListTile(
              title: Text(l10n.defaultToLyricsModeOnPlaybackOpen),
              subtitle: Text(l10n.defaultToLyricsModeOnPlaybackOpenDescription),
              value: settings.defaultToLyricsModeOnPlaybackOpen,
              onChanged: (value) {
                settings.defaultToLyricsModeOnPlaybackOpen = value;
              },
            ),
            SwitchListTile(
              title: Row(
                children: [
                  Text(l10n.enableWaveformProgressBar),
                  const SizedBox(width: 8),
                  const ProBadge(),
                ],
              ),
              subtitle: Text(l10n.enableWaveformProgressBarDescription),
              value: settings.isWaveformProgressBarEnabled && isProUnlocked,
              onChanged: (value) async {
                if (value) {
                  final allowed = await checkProGate(
                    context,
                    ref,
                    feature: ProFeature.waveformBar,
                  );
                  if (!allowed) return;
                }
                settings.isWaveformProgressBarEnabled = value;
              },
            ),
            if (settings.isWaveformProgressBarEnabled && isProUnlocked) ...[
              SwitchListTile(
                title: Text(l10n.enableWaveformLongPressSeek),
                subtitle: Text(l10n.enableWaveformLongPressSeekDescription),
                value: settings.enableWaveformLongPressSeek,
                onChanged: (value) {
                  settings.enableWaveformLongPressSeek = value;
                },
              ),
              ListTile(
                title: Text(l10n.waveformLongPressSeekSpeed),
                subtitle: Text(l10n.waveformLongPressSeekSpeedDescription),
                trailing: SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: settings.waveformLongPressSeekSpeed.clamp(
                            SettingsService.minWaveformLongPressSeekSpeed,
                            SettingsService.maxWaveformLongPressSeekSpeed,
                          ),
                          min: SettingsService.minWaveformLongPressSeekSpeed,
                          max: SettingsService.maxWaveformLongPressSeekSpeed,
                          divisions: ((SettingsService.maxWaveformLongPressSeekSpeed -
                                      SettingsService.minWaveformLongPressSeekSpeed) /
                                  0.1)
                              .round(),
                          onChanged: (value) {
                            settings.waveformLongPressSeekSpeed = value;
                          },
                        ),
                      ),
                      Text(
                        '${settings.waveformLongPressSeekSpeed.toStringAsFixed(1)}×',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        SettingsGroupCard(
          title: l10n.systemWindowBehaviorGroup,
          icon: Icons.desktop_windows_outlined,
          children: [
            SwitchListTile(
              title: Text(l10n.showScanProgressToastSetting),
              subtitle: Text(l10n.showScanProgressToastSettingDescription),
              value: settings.showScanProgressToast,
              onChanged: (value) {
                settings.showScanProgressToast = value;
              },
            ),
            if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) ...[
              SwitchListTile(
                title: Text(l10n.enableSystemTray),
                subtitle: Text(l10n.enableSystemTrayDescription),
                value: settings.enableSystemTray,
                onChanged: (value) {
                  settings.enableSystemTray = value;
                },
              ),
              SettingsDropdownTile<CloseWindowAction>(
                title: l10n.closeWindowActionTitle,
                subtitle: !settings.enableSystemTray
                    ? '${l10n.closeWindowActionDescription} ${l10n.closeWindowActionTrayDisabledTip}'
                    : l10n.closeWindowActionDescription,
                value: !settings.enableSystemTray
                    ? CloseWindowAction.exit
                    : settings.closeWindowAction,
                enabled: settings.enableSystemTray,
                options: [
                  SettingsDropdownOption(
                    value: CloseWindowAction.ask,
                    label: l10n.closeWindowActionAsk,
                  ),
                  SettingsDropdownOption(
                    value: CloseWindowAction.minimize,
                    label: l10n.closeWindowActionMinimize,
                    enabled: settings.enableSystemTray,
                  ),
                  SettingsDropdownOption(
                    value: CloseWindowAction.exit,
                    label: l10n.closeWindowActionExit,
                  ),
                ],
                onChanged: !settings.enableSystemTray
                    ? null
                    : (value) {
                        if (value != null) {
                          settings.closeWindowAction = value;
                        }
                      },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(l10n.resetOnboarding),
              subtitle: Text(l10n.resetOnboardingDesc),
              trailing: FilledButton.tonal(
                onPressed: () {
                  settings.hasShownOnboarding = false;
                  settings.hasShownCoverTapLyricTip = false;
                  settings.hasShownLyricsMenuTip = false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.onboardingReset)),
                  );
                },
                child: Text(l10n.reset),
              ),
            ),
          ],
        ),
        if (settings.showDeveloperOptions) ...[
          const SizedBox(height: 8),
          SettingsSectionHeader(
            title: l10n.advanced,
            description: l10n.advancedOptionsDescription,
          ),
          ListTile(
            title: Text(l10n.waveformSegments),
            subtitle: Text(l10n.waveformSegmentsDescription),
            trailing: SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: settings.waveformChunks > 20
                        ? () => settings.waveformChunks -= 10
                        : null,
                  ),
                  Text('${settings.waveformChunks}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: settings.waveformChunks < 200
                        ? () => settings.waveformChunks += 10
                        : null,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(l10n.sampleStride),
            subtitle: Text(l10n.sampleStrideDescription),
            trailing: SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: settings.sampleStride > 1
                        ? () => settings.sampleStride -= 1
                        : null,
                  ),
                  Text('${settings.sampleStride}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: settings.sampleStride < 16
                        ? () => settings.sampleStride += 1
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
