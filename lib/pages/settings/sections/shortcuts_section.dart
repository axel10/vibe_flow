import 'package:flutter/material.dart';
import 'package:vynody/dialogs/shortcut_settings_dialog.dart';
import 'package:vynody/l10n/app_localizations.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class ShortcutsSection extends StatelessWidget {
  const ShortcutsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SettingsSectionHeader(
          title: l10n.shortcutSettingsTitle,
          description: l10n.shortcutSettingsDescription,
        ),
        SettingsGroupCard(
          title: l10n.shortcutSettingsTitle,
          icon: Icons.keyboard_rounded,
          children: [
            ListTile(
              leading: const Icon(Icons.keyboard),
              title: Text(l10n.shortcutSettingsTitle),
              subtitle: Text(l10n.shortcutSettingsDescription),
              trailing: FilledButton.tonal(
                onPressed: () {
                  showShortcutSettingsDialog(context);
                },
                child: Text(l10n.edit),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
