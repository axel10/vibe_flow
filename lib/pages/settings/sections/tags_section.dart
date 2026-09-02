import 'package:flutter/material.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/settings/settings_service.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class TagsSection extends StatelessWidget {
  final SettingsService settings;

  const TagsSection({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SettingsSectionHeader(
          title: l10n.tags,
          description: l10n.tagsSectionDescription,
        ),
        SettingsGroupCard(
          title: l10n.tags,
          icon: Icons.label_outline_rounded,
          children: [
            SwitchListTile(
              title: Text(l10n.autoSaveToSourceFile),
              subtitle: Text(l10n.autoSaveToSourceFileDescription),
              value: settings.tagCompletionSaveToSourceFile,
              onChanged: (value) {
                settings.tagCompletionSaveToSourceFile = value;
              },
            ),
          ],
        ),
      ],
    );
  }
}
