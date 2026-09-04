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
import 'settings/settings_search_registry.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _portraitSearchFocusNode = FocusNode();
  final FocusNode _landscapeSearchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _portraitSearchFocusNode.dispose();
    _landscapeSearchFocusNode.dispose();
    super.dispose();
  }

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

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  Widget _buildSearchField(
    BuildContext context, {
    Key? key,
    FocusNode? focusNode,
    EdgeInsetsGeometry? margin,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: key,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: focusNode,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: l10n.search,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 40,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildSearchResultsView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final results = settingsSearchRegistry.where((item) {
      return item.matches(_searchQuery, l10n, context);
    }).toList(growable: false);

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noMatchingResults,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = results[index];
        final title = item.title(l10n);
        final desc = item.description?.call(l10n);
        final sectionTitle = item.section.title(context);

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(
              item.icon ?? item.section.icon,
              color: colorScheme.primary,
            ),
            title: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: desc != null
                ? Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sectionTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
            onTap: () {
              final targetSection = item.section;
              _clearSearch();
              _openSection(targetSection);
            },
          ),
        );
      },
    );
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
    final isSearching = _searchQuery.trim().isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _buildSearchField(
            context,
            key: const ValueKey('portrait_settings_search_field'),
            focusNode: _portraitSearchFocusNode,
            margin: EdgeInsets.zero,
          ),
        ),
        Expanded(
          child: isSearching
              ? _buildSearchResultsView(context)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                ),
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
          padding: const EdgeInsets.fromLTRB(16, 20, 24, 12),
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
        _buildSearchField(
          context,
          key: const ValueKey('landscape_settings_search_field'),
          focusNode: _landscapeSearchFocusNode,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: sidebarSections.length,
            itemBuilder: (context, index) {
              final section = sidebarSections[index];
              final isSelected = section == activeSection && _searchQuery.trim().isEmpty;
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
                  onTap: () {
                    _clearSearch();
                    _openSection(section);
                  },
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
    final Widget currentBody;
    final Key switcherKey;

    if (_searchQuery.trim().isNotEmpty) {
      currentBody = _buildSearchResultsView(context);
      switcherKey = const ValueKey('settings-search-results');
    } else {
      currentBody = _buildSectionContent(context, settings, activeSection);
      switcherKey = ValueKey(activeSection);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: KeyedSubtree(
        key: switcherKey,
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
    final canPop = isLandscape ||
        (_currentSection == SettingsSection.home && _searchQuery.isEmpty);

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_searchQuery.isNotEmpty) {
          _clearSearch();
          return;
        }
        _goHome();
      },
      child: content,
    );
  }
}
