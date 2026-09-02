import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vynody/l10n/app_localizations.dart';

enum SettingsSection {
  home,
  general,
  audio,
  scanning,
  tags,
  transcode,
  lyrics,
  acoustid,
  storage,
  shortcuts,
  windows,
  about;

  String title(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      SettingsSection.home => l10n.settings,
      SettingsSection.general => l10n.generalSectionTitle,
      SettingsSection.audio => l10n.audioSettings,
      SettingsSection.scanning => l10n.scanSectionTitle,
      SettingsSection.tags => l10n.tags,
      SettingsSection.transcode => l10n.transcodeSectionTitle,
      SettingsSection.lyrics => l10n.lyricsSectionTitle,
      SettingsSection.acoustid => l10n.acoustidSectionTitle,
      SettingsSection.storage => l10n.storageAndCache,
      SettingsSection.shortcuts => l10n.shortcutSettingsTitle,
      SettingsSection.windows => l10n.windowsSettingsTitle,
      SettingsSection.about => l10n.about,
    };
  }

  IconData get icon {
    return switch (this) {
      SettingsSection.home => Icons.settings,
      SettingsSection.general => Icons.tune_rounded,
      SettingsSection.audio => Icons.graphic_eq_rounded,
      SettingsSection.scanning => Icons.search_rounded,
      SettingsSection.tags => Icons.label_outline_rounded,
      SettingsSection.transcode => Icons.swap_horiz_rounded,
      SettingsSection.lyrics => Icons.auto_awesome_rounded,
      SettingsSection.acoustid => Icons.radar_rounded,
      SettingsSection.storage => Icons.storage_rounded,
      SettingsSection.shortcuts => Icons.keyboard_rounded,
      SettingsSection.windows => Icons.open_in_new_rounded,
      SettingsSection.about => Icons.info_outline_rounded,
    };
  }

  static List<SettingsSection> get sidebarSections => [
        SettingsSection.general,
        SettingsSection.audio,
        SettingsSection.scanning,
        SettingsSection.tags,
        SettingsSection.transcode,
        SettingsSection.lyrics,
        SettingsSection.acoustid,
        SettingsSection.storage,
        SettingsSection.shortcuts,
        if (Platform.isWindows) SettingsSection.windows,
        SettingsSection.about,
      ];
}
