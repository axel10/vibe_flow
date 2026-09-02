import 'dart:async';
import 'dart:io';
import 'package:audio_core/audio_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/settings_service.dart';
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
    final isExclusive = settings.windowsAudioOutputMode == 'wasapi_exclusive';

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
          value: settings.windowsAudioOutputMode,
          options: [
            SettingsDropdownOption(
              value: 'shared',
              label: l10n.audioOutputModeShared,
            ),
            SettingsDropdownOption(
              value: 'wasapi_exclusive',
              label: l10n.audioOutputModeExclusive,
            ),
          ],
          onChanged: (newMode) {
            if (newMode != null) {
              unawaited(audioService.updateWindowsAudioOutput(mode: newMode));
            }
          },
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
