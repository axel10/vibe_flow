import 'package:audio_core/audio_core.dart';
import 'package:flutter/material.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/transcode/transcode_models.dart';
import '../widgets/settings_dropdown_tile.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class TranscodeSection extends StatelessWidget {
  final SettingsService settings;

  const TranscodeSection({
    super.key,
    required this.settings,
  });

  String _transcodeQualityLabel(
    BuildContext context,
    TranscodeQualityTier tier,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return switch (tier) {
      TranscodeQualityTier.low => l10n.transcodeQualityLow,
      TranscodeQualityTier.medium => l10n.transcodeQualityMedium,
      TranscodeQualityTier.high => l10n.transcodeQualityHigh,
      TranscodeQualityTier.extreme => l10n.transcodeQualityExtreme,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SettingsSectionHeader(
          title: l10n.transcodeSectionTitle,
          description: l10n.transcodeSectionDescription,
        ),
        SettingsGroupCard(
          title: l10n.transcodeSectionTitle,
          icon: Icons.swap_horiz_rounded,
          children: [
            SettingsDropdownTile<AudioFormat>(
              title: l10n.transcodeDefaultFormat,
              value: settings.transcodeDefaultFormat,
              options: AudioFormat.values
                  .map(
                    (format) => SettingsDropdownOption<AudioFormat>(
                      value: format,
                      label: format.displayName,
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                settings.transcodeDefaultFormat = value;
              },
            ),
            SettingsDropdownTile<TranscodeQualityTier>(
              title: l10n.transcodeDefaultQuality,
              value: settings.transcodeDefaultQualityTier,
              options: TranscodeQualityTier.values
                  .map(
                    (tier) => SettingsDropdownOption<TranscodeQualityTier>(
                      value: tier,
                      label: _transcodeQualityLabel(context, tier),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                settings.transcodeDefaultQualityTier = value;
              },
            ),
          ],
        ),
      ],
    );
  }
}
