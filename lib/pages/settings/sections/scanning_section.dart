import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/settings_service.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class ScanningSection extends ConsumerWidget {
  final SettingsService settings;

  const ScanningSection({
    super.key,
    required this.settings,
  });

  Widget _buildScanSection(
    BuildContext context,
    WidgetRef ref,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    const minSeconds = 5;
    const maxSeconds = 300;
    const stepSeconds = 5;
    final enabled = settings.skipShortAudioScanEnabled;
    final currentSeconds = settings.skipShortAudioScanMinimumDurationSeconds;

    return Column(
      children: [
        SettingsGroupCard(
          title: l10n.scanSectionTitle,
          icon: Icons.filter_list_rounded,
          children: [
            SwitchListTile(
              title: Text(l10n.skipShortAudioDuringScan),
              subtitle: Text(l10n.skipShortAudioDuringScanDescription),
              value: enabled,
              onChanged: (value) {
                settings.skipShortAudioScanEnabled = value;
              },
            ),
            ListTile(
              enabled: enabled,
              title: Text(l10n.shortAudioScanThreshold),
              subtitle: Text(l10n.shortAudioScanThresholdDescription),
              trailing: SizedBox(
                width: 156,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: enabled && currentSeconds > minSeconds
                          ? () {
                              settings.skipShortAudioScanMinimumDurationSeconds =
                                  currentSeconds - stepSeconds;
                            }
                          : null,
                    ),
                    Text(l10n.shortAudioScanThresholdValue(currentSeconds)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: enabled && currentSeconds < maxSeconds
                          ? () {
                              settings.skipShortAudioScanMinimumDurationSeconds =
                                  currentSeconds + stepSeconds;
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SettingsGroupCard(
          title: l10n.rebuildIndex,
          icon: Icons.build_circle_outlined,
          children: [
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: Text(l10n.rebuildIndex),
              subtitle: Text(l10n.rebuildIndexDescription),
              trailing: FilledButton.tonal(
                onPressed: () async {
                  final content = l10n.rebuildIndexConfirmation;
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.rebuildIndex),
                      content: Text(content),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(l10n.confirm),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    final scanner = ref.read(scannerServiceProvider);
                    unawaited(scanner.rebuildIndex());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.rebuildIndexStarted)),
                      );
                    }
                  }
                },
                child: Text(l10n.rebuild),
              ),
            ),
          ],
        ),
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
          title: l10n.scanSectionTitle,
          description: l10n.scanSectionDescription,
        ),
        _buildScanSection(context, ref, settings),
      ],
    );
  }
}
