import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/settings_service.dart';
import '../widgets/desktop_window_title_bar.dart';
import 'settings/sections/about_section.dart';
import 'settings/sections/acoustid_section.dart';
import 'settings/sections/audio_section.dart';
import 'settings/sections/general_section.dart';
import 'settings/sections/lyrics_section.dart';
import 'settings/sections/scanning_section.dart';
import 'settings/sections/shortcuts_section.dart';
import 'settings/sections/storage_section.dart';
import 'settings/sections/tags_section.dart';
import 'settings/sections/transcode_section.dart';
import 'settings/sections/windows_section.dart';
import 'settings/settings_section.dart';

export 'settings/settings_section.dart';
export 'settings/dialogs/custom_provider_config_dialog.dart';
export 'settings/dialogs/lyrics_model_picker_dialog.dart';

class SettingsPage extends ConsumerStatefulWidget {
  final SettingsSection initialSection;

  const SettingsPage({
    super.key,
    this.initialSection = SettingsSection.home,
  });

  @override
  ConsumerState<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends ConsumerState<SettingsPage> {
  late SettingsSection _currentSection = widget.initialSection;

  void openSection(SettingsSection section) {
    _openSection(section);
  }

  void _openSection(SettingsSection section) {
    setState(() {
      _currentSection = section;
    });
  }

  void _goHome() {
    setState(() {
      _currentSection = SettingsSection.home;
    });
  }

  Widget _buildHomeSectionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      minTileHeight: 60,
      leading: Icon(icon),
      title: Text(title, style: theme.textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildHomeSectionTile(
          context,
          icon: Icons.tune_rounded,
          title: l10n.generalSectionTitle,
          onTap: () => _openSection(SettingsSection.general),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.graphic_eq_rounded,
          title: l10n.audioSettings,
          onTap: () => _openSection(SettingsSection.audio),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.search_rounded,
          title: l10n.scanSectionTitle,
          onTap: () => _openSection(SettingsSection.scanning),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.label_outline_rounded,
          title: l10n.tags,
          onTap: () => _openSection(SettingsSection.tags),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.swap_horiz_rounded,
          title: l10n.transcodeSectionTitle,
          onTap: () => _openSection(SettingsSection.transcode),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.auto_awesome_rounded,
          title: l10n.lyricsSectionTitle,
          onTap: () => _openSection(SettingsSection.lyrics),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.radar_rounded,
          title: l10n.acoustidSectionTitle,
          onTap: () => _openSection(SettingsSection.acoustid),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.storage_rounded,
          title: l10n.storageAndCache,
          onTap: () => _openSection(SettingsSection.storage),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.keyboard_rounded,
          title: l10n.shortcutSettingsTitle,
          onTap: () => _openSection(SettingsSection.shortcuts),
        ),
        if (Platform.isWindows)
          _buildHomeSectionTile(
            context,
            icon: Icons.open_in_new_rounded,
            title: l10n.windowsSettingsTitle,
            onTap: () => _openSection(SettingsSection.windows),
          ),
        _buildHomeSectionTile(
          context,
          icon: Icons.info_outline_rounded,
          title: l10n.about,
          onTap: () => _openSection(SettingsSection.about),
        ),
      ],
    );
  }

  Widget _buildSectionContent(
    BuildContext context,
    SettingsService settings,
    SettingsSection section,
  ) {
    return switch (section) {
      SettingsSection.home => _buildHomeBody(context),
      SettingsSection.general => GeneralSection(settings: settings),
      SettingsSection.audio => AudioSection(settings: settings),
      SettingsSection.scanning => ScanningSection(settings: settings),
      SettingsSection.tags => TagsSection(settings: settings),
      SettingsSection.transcode => TranscodeSection(settings: settings),
      SettingsSection.lyrics => LyricsSection(settings: settings),
      SettingsSection.acoustid => AcoustidSection(settings: settings),
      SettingsSection.storage => StorageSection(settings: settings),
      SettingsSection.shortcuts => const ShortcutsSection(),
      SettingsSection.windows => const WindowsSection(),
      SettingsSection.about => const AboutSection(),
    };
  }

  double _calculateSidebarWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return (screenWidth * 0.35).clamp(220.0, 300.0);
  }

  Widget _buildSidebar(BuildContext context, SettingsSection activeSection) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sidebarSections = SettingsSection.sidebarSections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 24, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.settings,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: sidebarSections.length,
            itemBuilder: (context, index) {
              final section = sidebarSections[index];
              final isSelected = section == activeSection;
              final icon = section.icon;
              final title = section.title(context);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: ListTile(
                  horizontalTitleGap: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  selectedColor: theme.colorScheme.primary,
                  textColor: theme.colorScheme.onSurfaceVariant,
                  iconColor: theme.colorScheme.onSurfaceVariant,
                  leading: Icon(icon, size: 20),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () => _openSection(section),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPane(
    BuildContext context,
    SettingsService settings,
    SettingsSection activeSection,
  ) {
    final currentBody = _buildSectionContent(context, settings, activeSection);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: KeyedSubtree(
        key: ValueKey(activeSection),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: currentBody,
          ),
        ),
      ),
    );
  }

  Page<dynamic> _buildPage({
    required LocalKey key,
    required Widget child,
  }) {
    if (Platform.isIOS || Platform.isMacOS) {
      return CupertinoPage<dynamic>(
        key: key,
        child: child,
      );
    }
    return MaterialPage<dynamic>(
      key: key,
      child: child,
    );
  }

  Widget _buildRootScaffold(BuildContext context, SettingsService settings) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final l10n = AppLocalizations.of(context)!;

    if (isLandscape) {
      final activeSection = _currentSection == SettingsSection.home
          ? SettingsSection.general
          : _currentSection;
      final sidebarWidth = _calculateSidebarWidth(context);

      return Scaffold(
        body: Row(
          children: [
            Container(
              width: sidebarWidth,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: _buildSidebar(context, activeSection),
            ),
            Expanded(
              child: _buildDetailPane(context, settings, activeSection),
            ),
          ],
        ),
      );
    } else {
      final pages = <Page<dynamic>>[
        _buildPage(
          key: const ValueKey('settings-home'),
          child: Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              notificationPredicate: (_) => false,
              title: Text(l10n.settings),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: _buildHomeBody(context),
          ),
        ),
        if (_currentSection != SettingsSection.home)
          _buildPage(
            key: ValueKey('settings-detail-${_currentSection.name}'),
            child: Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                notificationPredicate: (_) => false,
                title: Text(_currentSection.title(context)),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goHome,
                ),
              ),
              body: _buildSectionContent(context, settings, _currentSection),
            ),
          ),
      ];

      return Navigator(
        pages: pages,
        onDidRemovePage: (page) {
          _goHome();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsServiceProvider);
    final theme = Theme.of(context);
    final isMacOS = Platform.isMacOS;
    final showCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    Widget content = _buildRootScaffold(context, settings);

    if (showCustomTitleBar || isMacOS) {
      content = Material(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            if (showCustomTitleBar)
              DesktopWindowTitleBar(brightness: theme.brightness)
            else
              const DragToMoveArea(child: SizedBox(height: 32)),
            Expanded(child: content),
          ],
        ),
      );
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final canPop = isLandscape || _currentSection == SettingsSection.home;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goHome();
      },
      child: content,
    );
  }
}
