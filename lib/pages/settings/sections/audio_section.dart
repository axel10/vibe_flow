import 'dart:async';
import 'dart:io';
import 'package:audio_core/audio_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/dialogs/shortcut_settings_dialog.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/pro/pro_models.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/player/settings/shortcut_bindings.dart';
import 'package:vynody/widgets/pro/pro_badge.dart';
import '../widgets/settings_dropdown_tile.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class AudioSection extends ConsumerWidget {
  final SettingsService settings;

  const AudioSection({
    super.key,
    required this.settings,
  });

  Widget _buildWindowsAudioOutputCard(
    BuildContext context,
    WidgetRef ref,
  ) {
    if (!Platform.isWindows) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final audioService = ref.read(audioServiceProvider);
    final isProUnlocked = ref.watch(isProUnlockedProvider);
    final isExclusive =
        settings.windowsAudioOutputMode == 'wasapi_exclusive' && isProUnlocked;

    return SettingsGroupCard(
      title: l10n.windowsAudioOutputTitle,
      icon: Icons.speaker_group_rounded,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            l10n.windowsAudioOutputDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SettingsDropdownTile<String>(
          title: l10n.windowsAudioOutputTitle,
          icon: Icons.audio_file_rounded,
          value: isExclusive ? 'wasapi_exclusive' : 'shared',
          options: [
            SettingsDropdownOption(
              value: 'shared',
              label: l10n.audioOutputModeShared,
            ),
            SettingsDropdownOption(
              value: 'wasapi_exclusive',
              label: l10n.audioOutputModeExclusive,
              trailing: !isProUnlocked ? const ProBadge(size: 9.5) : null,
            ),
          ],
          onChanged: (newMode) async {
            if (newMode == 'wasapi_exclusive') {
              final allowed = await checkProGate(
                context,
                ref,
                feature: ProFeature.wasapiExclusive,
              );
              if (!allowed) return;
            }
            if (newMode != null) {
              unawaited(audioService.updateWindowsAudioOutput(mode: newMode));
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.keyboard_rounded),
          title: Text(l10n.wasapiExclusiveShortcutTitle),
          subtitle: Text(l10n.wasapiExclusiveShortcutDescription),
          trailing: OutlinedButton.icon(
            onPressed: () {
              showSingleShortcutEditDialog(
                context,
                action: AppShortcutAction.toggleWasapiExclusive,
              );
            },
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: Text(
              settings
                  .shortcutBinding(AppShortcutAction.toggleWasapiExclusive)
                  .displayLabel,
            ),
          ),
        ),
        if (isExclusive) ...[
          FutureBuilder<List<AudioDeviceDesc>>(
            future: audioService.getAudioOutputDevices(),
            builder: (context, snapshot) {
              final devices = snapshot.data ?? const <AudioDeviceDesc>[];
              final currentId = settings.windowsAudioDeviceId.trim();

              final options = <SettingsDropdownOption<String>>[
                SettingsDropdownOption(
                  value: '',
                  label: l10n.audioOutputDeviceDefault,
                ),
                for (final dev in devices)
                  SettingsDropdownOption(
                    value: dev.id,
                    label: dev.name + (dev.isDefault ? ' (*)' : ''),
                  ),
              ];

              return SettingsDropdownTile<String>(
                title: l10n.audioOutputDeviceTitle,
                icon: Icons.speaker_rounded,
                value: options.any((opt) => opt.value == currentId) ? currentId : '',
                options: options,
                onChanged: (newDeviceId) {
                  if (newDeviceId != null) {
                    unawaited(
                      audioService.updateWindowsAudioOutput(
                        mode: settings.windowsAudioOutputMode,
                        deviceId: newDeviceId,
                      ),
                    );
                  }
                },
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_fix_high_rounded),
            title: Text(l10n.wasapiBitPerfectTitle),
            subtitle: Text(l10n.wasapiBitPerfectDescription),
            value: settings.wasapiBitPerfect,
            onChanged: (val) {
              unawaited(
                audioService.updateWindowsAudioOutput(
                  mode: settings.windowsAudioOutputMode,
                  bitPerfect: val,
                ),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.pause_circle_outline_rounded),
            title: Text(l10n.wasapiReleaseOnPauseTitle),
            subtitle: Text(l10n.wasapiReleaseOnPauseDescription),
            value: settings.wasapiReleaseOnPause,
            onChanged: (val) {
              unawaited(
                audioService.updateWindowsAudioOutput(
                  mode: settings.windowsAudioOutputMode,
                  releaseOnPause: val,
                ),
              );
            },
          ),
          FutureBuilder<ActiveAudioHardwareFormat?>(
            future: audioService.getActiveAudioHardwareFormat(),
            builder: (context, snapshot) {
              final fmt = snapshot.data;
              if (fmt == null) return const SizedBox.shrink();

              final sampleRateFormatted =
                  '${(fmt.sampleRate / 1000).toStringAsFixed(fmt.sampleRate % 1000 == 0 ? 0 : 1)} kHz';
              final channelDesc =
                  fmt.channels == 2 ? 'Stereo (2.0)' : '${fmt.channels} Channels';
              final formatStr =
                  '$sampleRateFormatted / ${fmt.bitDepth}-bit / $channelDesc';

              return Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                l10n.activeHardwareFormatTitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              if (fmt.isBitPerfect)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    l10n.activeHardwareBitPerfectBadge,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${fmt.deviceName} • $formatStr',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SettingsSectionHeader(
          title: l10n.audioSettings,
          description: l10n.audioSettingsDescription,
        ),
        if (Platform.isWindows) _buildWindowsAudioOutputCard(context, ref),
        SettingsGroupCard(
          title: l10n.equalizerBandCount,
          icon: Icons.equalizer_rounded,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.equalizerBandCountDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<int>(
                      segments: [
                        ButtonSegment<int>(value: 5, label: Text(l10n.bandsCountOption(5))),
                        ButtonSegment<int>(value: 10, label: Text(l10n.bandsCountOption(10))),
                        ButtonSegment<int>(value: 15, label: Text(l10n.bandsCountOption(15))),
                        ButtonSegment<int>(value: 20, label: Text(l10n.bandsCountOption(20))),
                      ],
                      selected: {settings.equalizerBandCount},
                      onSelectionChanged: (Set<int> selected) {
                        if (selected.isNotEmpty) {
                          settings.equalizerBandCount = selected.first;
                        }
                      },
                      showSelectedIcon: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SettingsGroupCard(
          title: l10n.playbackBehaviorGroup,
          icon: Icons.graphic_eq_rounded,
          children: [
            SwitchListTile(
              title: Text(l10n.enableFadeEffect),
              subtitle: Text(l10n.enableFadeEffectDescription),
              value: settings.enableFadeEffect,
              onChanged: (value) {
                settings.enableFadeEffect = value;
              },
            ),
          ],
        ),
      ],
    );
  }
}
