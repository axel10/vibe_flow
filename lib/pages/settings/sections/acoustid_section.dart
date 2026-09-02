import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vynody/dialogs/acoustid_api_key_dialog.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/settings/settings_service.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class AcoustidSection extends StatelessWidget {
  final SettingsService settings;

  const AcoustidSection({
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
          title: l10n.acoustidSectionTitle,
          description: l10n.acoustidApiKeyHelp,
        ),
        SettingsGroupCard(
          title: l10n.acoustidSectionTitle,
          icon: Icons.radar_rounded,
          children: [
            ListTile(
              isThreeLine: true,
              leading: const Icon(Icons.graphic_eq_rounded),
              title: Text(l10n.acoustidApiKeyTitle),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.hasCustomAcoustidApiKey
                        ? l10n.acoustidApiKeySaved
                        : l10n.acoustidApiKeyDefault,
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse('https://acoustid.org/new-application');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      l10n.applyForApiKey,
                      style: const TextStyle(
                        color: Colors.lightBlueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: FilledButton.tonal(
                onPressed: () async {
                  final enteredApiKey = await showAcoustidApiKeyDialog(
                    context,
                    initialApiKey: settings.hasCustomAcoustidApiKey
                        ? settings.acoustidApiKey
                        : '',
                  );
                  if (enteredApiKey == null) {
                    return;
                  }

                  settings.acoustidApiKey = enteredApiKey;
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.acoustidApiKeySaved)));
                },
                child: Text(
                  settings.hasCustomAcoustidApiKey ? l10n.modify : l10n.fill,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
