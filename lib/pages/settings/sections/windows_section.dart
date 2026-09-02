import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/windows_association_service.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class WindowsSection extends ConsumerStatefulWidget {
  const WindowsSection({super.key});

  @override
  ConsumerState<WindowsSection> createState() => _WindowsSectionState();
}

class _WindowsSectionState extends ConsumerState<WindowsSection> {
  bool _isAssociated = false;

  @override
  void initState() {
    super.initState();
    _checkAssociationStatus();
  }

  Future<void> _checkAssociationStatus() async {
    if (Platform.isWindows) {
      final status = await WindowsAssociationService.isAssociated();
      if (mounted) {
        setState(() {
          _isAssociated = status;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsServiceProvider);
    final isPackaged = Platform.resolvedExecutable.contains(r'\WindowsApps\');

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SettingsSectionHeader(
          title: l10n.windowsSettingsTitle,
          description: l10n.fileAssociationDescription,
        ),
        SettingsGroupCard(
          title: l10n.fileAssociationTitle,
          icon: Icons.open_in_new_rounded,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded),
              title: Text(l10n.fileAssociationTitle),
              subtitle: Text(
                _isAssociated ? l10n.fileAssociationEnabled : l10n.fileAssociationDisabled,
                style: TextStyle(
                  color: _isAssociated ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () async {
                      try {
                        await WindowsAssociationService.associate();
                        await _checkAssociationStatus();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.associationSuccess)),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.associationFailed(e.toString()))),
                        );
                      }
                    },
                    child: Text(l10n.associateButton),
                  ),
                  if (_isAssociated)
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          await WindowsAssociationService.disassociate();
                          await _checkAssociationStatus();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.disassociationSuccess)),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.associationFailed(e.toString())),
                            ),
                          );
                        }
                      },
                      child: Text(l10n.disassociateButton),
                    ),
                ],
              ),
            ),
            if (!isPackaged) ...[
              SwitchListTile(
                secondary: const Icon(Icons.settings_suggest_rounded),
                title: Text(l10n.windowsAutoRepairShortcut),
                subtitle: Text(l10n.windowsAutoRepairShortcutDescription),
                value: settings.windowsAutoRepairShortcut,
                onChanged: (value) async {
                  if (!value) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        final l10n = AppLocalizations.of(dialogContext)!;
                        return AlertDialog(
                          title: Text(l10n.confirmDisableShortcutRepair),
                          content: Text(l10n.confirmDisableShortcutRepairContent),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              child: Text(l10n.confirmDisable),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true) {
                      settings.windowsAutoRepairShortcut = false;
                    }
                  } else {
                    settings.windowsAutoRepairShortcut = true;
                    try {
                      await const MethodChannel('vynody/single_instance')
                          .invokeMethod('registerShortcut');
                    } catch (e) {
                      debugPrint('Failed to trigger registerShortcut: $e');
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}
