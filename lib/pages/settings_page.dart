import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import '../utils/file_selector_helper.dart';
import '../utils/app_log.dart';
import 'package:vynody/player/lyrics/lyrics_cache_models.dart';
import 'package:vynody/player/lyrics/lyrics_cache_repository.dart';
import 'package:vynody/player/lyrics/lyrics_import_export_service.dart';

import 'package:audio_core/audio_core.dart' hide AppLog;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../dialogs/acoustid_api_key_dialog.dart';
import '../dialogs/ai_guide_dialog.dart';
import '../dialogs/shortcut_settings_dialog.dart';
import '../dialogs/playback_button_layout_dialog.dart';
import '../l10n/app_localizations.dart';
import 'package:vynody/player/ai/lyrics_model_catalog_service.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/settings_service.dart';
import '../transcode/transcode_models.dart';
import 'package:vynody/player/settings/windows_association_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../widgets/desktop_window_title_bar.dart';
import 'package:vynody/utils/language_code_utils.dart';
import 'package:vynody/widgets/lyrics_provider_icon.dart';

enum _SettingsSection {
  home,
  general,
  audio,
  scanning,
  tags,
  transcode,
  lyrics,
  acoustid,
  shortcuts,
  windows,
  about,
}

class _DropdownOption<T> {
  final T value;
  final String label;
  final Widget? leading;
  final bool enabled;

  const _DropdownOption({
    required this.value,
    required this.label,
    this.leading,
    this.enabled = true,
  });
}

Widget _buildDropdownTile<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  IconData? icon,
  required T value,
  required List<_DropdownOption<T>> options,
  required ValueChanged<T?>? onChanged,
  bool enabled = true,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isEffectiveEnabled = enabled && onChanged != null;

  _DropdownOption<T>? selectedOption;
  for (final opt in options) {
    if (opt.value == value) {
      selectedOption = opt;
      break;
    }
  }
  selectedOption ??= options.isNotEmpty ? options.first : null;

  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: icon != null ? Icon(icon) : null,
    title: Text(
      title,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    ),
    subtitle: subtitle != null && subtitle.isNotEmpty
        ? Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        : null,
    trailing: PopupMenuButton<T>(
      enabled: isEffectiveEnabled,
      onSelected: isEffectiveEnabled ? onChanged : null,
      itemBuilder: (context) => options.map((opt) {
        final isSelected = opt.value == value;
        return PopupMenuItem<T>(
          value: opt.value,
          enabled: opt.enabled,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (opt.leading != null) ...[
                opt.leading!,
                const SizedBox(width: 8),
              ],
              Text(
                opt.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? colorScheme.primary : null,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ],
            ],
          ),
        );
      }).toList(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEffectiveEnabled
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedOption?.leading != null) ...[
              selectedOption!.leading!,
              const SizedBox(width: 6),
            ],
            Text(
              selectedOption?.label ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isEffectiveEnabled
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.38),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.unfold_more_rounded,
              size: 18,
              color: isEffectiveEnabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ],
        ),
      ),
    ),
  );
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _appVersion = '';
  bool _isAssociated = false;
  bool _isCheckingUpdates = false;
  bool _isExportingLogs = false;
  _SettingsSection _currentSection = _SettingsSection.home;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _checkAssociationStatus();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (_) {}
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

  List<int> _parseVersionParts(String version) {
    final cleaned = version.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final core = cleaned.split('+').first.split('-').first;
    final parts = core.split('.');
    return List<int>.generate(3, (index) {
      if (index >= parts.length) return 0;
      return int.tryParse(parts[index]) ?? 0;
    });
  }

  int _compareVersions(String current, String latest) {
    final currentParts = _parseVersionParts(current);
    final latestParts = _parseVersionParts(latest);
    for (var i = 0; i < 3; i++) {
      final diff = currentParts[i].compareTo(latestParts[i]);
      if (diff != 0) return diff;
    }
    return 0;
  }

  static const bool _isStoreBuild = bool.fromEnvironment(
    'STORE_BUILD',
    defaultValue: false,
  );

  static const bool _isAppStoreBuild = bool.fromEnvironment(
    'APP_STORE_BUILD',
    defaultValue: false,
  );

  static const String _appStoreId = String.fromEnvironment(
    'APP_STORE_ID',
    defaultValue: '6799339894',
  );

  Future<void> _checkForUpdates() async {
    final bool isAppleStore =
        Platform.isIOS || _isAppStoreBuild || (Platform.isMacOS && _isStoreBuild);
    if (isAppleStore) {
      final l10n = AppLocalizations.of(context)!;
      final storeUri = Uri.parse('https://apps.apple.com/app/id$_appStoreId');
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.checkForUpdates),
            content: Text(l10n.appStoreUpdateNotice),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  if (await canLaunchUrl(storeUri)) {
                    await launchUrl(storeUri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(l10n.openAppStore),
              ),
            ],
          );
        },
      );
      return;
    }

    if (Platform.isWindows && _isStoreBuild) {
      final l10n = AppLocalizations.of(context)!;
      final storeUri = Uri.parse('ms-windows-store://pdp/?productid=9NMZRZZ6RSD3');
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.checkForUpdates),
            content: Text(l10n.storeUpdateNotice),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  if (await canLaunchUrl(storeUri)) {
                    await launchUrl(storeUri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(l10n.openMicrosoftStore),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_isCheckingUpdates) return;

    setState(() {
      _isCheckingUpdates = true;
    });

    try {
      final client = HttpClient();
      client.userAgent = 'Vynody';

      final request = await client.getUrl(
        Uri.parse('https://github.com/axel10/vynody/releases/latest'),
      );
      request.followRedirects = false;
      request.headers.set(HttpHeaders.acceptHeader, 'text/html');

      final response = await request.close();
      final location = response.headers.value(HttpHeaders.locationHeader) ?? '';
      final latestTag = location.isNotEmpty
          ? Uri.parse(location).pathSegments.isNotEmpty
                ? Uri.parse(location).pathSegments.last
                : ''
          : '';
      final latestVersion = latestTag.replaceFirst(RegExp(r'^[vV]'), '');
      final releaseUrl = location.isNotEmpty
          ? location.startsWith('http')
                ? location
                : 'https://github.com$location'
          : 'https://github.com/axel10/vynody/releases/latest';

      final socket = await response.detachSocket();
      socket.destroy();
      client.close(force: true);

      if (latestVersion.isEmpty) {
        throw StateError('Missing latest release version');
      }

      final currentVersion = _appVersion.isEmpty
          ? (await PackageInfo.fromPlatform()).version
          : _appVersion;

      if (!mounted) return;

      if (_compareVersions(currentVersion, latestVersion) >= 0) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.alreadyLatestVersion)),
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final l10n = AppLocalizations.of(dialogContext)!;
          return AlertDialog(
            title: Text(l10n.updateAvailable),
            content: Text(l10n.newVersionAvailable(latestVersion)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  final uri = Uri.parse(releaseUrl);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Text(l10n.openRelease),
              ),
            ],
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.checkUpdateFailedNetwork)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdates = false;
        });
      }
    }
  }

  Future<void> _exportLogs() async {
    if (_isExportingLogs) return;

    final logPath = AppLog.logFilePath;
    if (logPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noLogFileFound)),
        );
      }
      return;
    }

    final logFile = File(logPath);
    if (!await logFile.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noLogFileFound)),
        );
      }
      return;
    }

    setState(() {
      _isExportingLogs = true;
    });

    try {
      await AppLog.logDeviceInfo();
      await AppLog.flush();

      final bytes = await logFile.readAsBytes();
      final suggestedName = 'vynody_${DateTime.now().millisecondsSinceEpoch}.log';
      final path = await FileSelectorHelper.saveFile(
        suggestedName: suggestedName,
        label: 'Log',
        extensions: const ['log'],
        dialogTitle: 'Export Logs',
        bytes: bytes,
      );

      if (path != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.exportLogsSuccess),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.exportLogsFailed}: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExportingLogs = false;
        });
      }
    }
  }

  void _openSection(_SettingsSection section) {
    setState(() {
      _currentSection = section;
    });
  }

  void _goHome() {
    setState(() {
      _currentSection = _SettingsSection.home;
    });
  }

  String _sectionTitle(BuildContext context, _SettingsSection section) {
    final l10n = AppLocalizations.of(context)!;
    return switch (section) {
      _SettingsSection.home => l10n.settings,
      _SettingsSection.general => l10n.generalSectionTitle,
      _SettingsSection.audio => l10n.audioSettings,
      _SettingsSection.scanning => l10n.scanSectionTitle,
      _SettingsSection.tags => l10n.tags,
      _SettingsSection.transcode => l10n.transcodeSectionTitle,
      _SettingsSection.lyrics => l10n.lyricsSectionTitle,
      _SettingsSection.acoustid => l10n.acoustidSectionTitle,
      _SettingsSection.shortcuts => l10n.shortcutSettingsTitle,
      _SettingsSection.windows => l10n.windowsSettingsTitle,
      _SettingsSection.about => l10n.about,
    };
  }

  List<_SettingsSection> get _sidebarSections => [
        _SettingsSection.general,
        _SettingsSection.audio,
        _SettingsSection.scanning,
        _SettingsSection.tags,
        _SettingsSection.transcode,
        _SettingsSection.lyrics,
        _SettingsSection.acoustid,
        _SettingsSection.shortcuts,
        if (Platform.isWindows) _SettingsSection.windows,
        _SettingsSection.about,
      ];

  IconData _sectionIcon(_SettingsSection section) {
    return switch (section) {
      _SettingsSection.home => Icons.settings,
      _SettingsSection.general => Icons.tune_rounded,
      _SettingsSection.audio => Icons.graphic_eq_rounded,
      _SettingsSection.scanning => Icons.search_rounded,
      _SettingsSection.tags => Icons.label_outline_rounded,
      _SettingsSection.transcode => Icons.swap_horiz_rounded,
      _SettingsSection.lyrics => Icons.auto_awesome_rounded,
      _SettingsSection.acoustid => Icons.radar_rounded,
      _SettingsSection.shortcuts => Icons.keyboard_rounded,
      _SettingsSection.windows => Icons.open_in_new_rounded,
      _SettingsSection.about => Icons.info_outline_rounded,
    };
  }

  Widget _buildWindowsSection(BuildContext context) {
    if (!Platform.isWindows) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsServiceProvider);
    final isPackaged = Platform.resolvedExecutable.contains(r'\WindowsApps\');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          const Divider(),
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
    );
  }

  Future<void> _selectLyricsModel({
    required SettingsService settings,
    required LyricsAiModelPurpose purpose,
    required LyricsAiModelSlot slot,
  }) async {
    if (!settings.hasAnyLyricsModelProvider) {
      return;
    }
    final currentSelection = _selectionFor(settings, purpose, slot);
    final selected = await showDialog<LyricsAiModelSelection>(
      context: context,
      builder: (dialogContext) {
        return _LyricsModelPickerDialog(
          ref: ref,
          purpose: purpose,
          slot: slot,
          initialSelection: currentSelection,
        );
      },
    );
    if (selected == null) {
      return;
    }
    _saveSelection(settings, purpose, slot, selected);
  }

  LyricsAiModelSelection _selectionFor(
    SettingsService settings,
    LyricsAiModelPurpose purpose,
    LyricsAiModelSlot slot,
  ) {
    return switch ((purpose, slot)) {
      (LyricsAiModelPurpose.generation, LyricsAiModelSlot.primary) =>
        settings.generationPrimaryModel,
      (LyricsAiModelPurpose.generation, LyricsAiModelSlot.fallback) =>
        settings.generationFallbackModel,
      (LyricsAiModelPurpose.translation, LyricsAiModelSlot.primary) =>
        settings.translationPrimaryModel,
      (LyricsAiModelPurpose.translation, LyricsAiModelSlot.fallback) =>
        settings.translationFallbackModel,
    };
  }

  void _saveSelection(
    SettingsService settings,
    LyricsAiModelPurpose purpose,
    LyricsAiModelSlot slot,
    LyricsAiModelSelection selection,
  ) {
    switch ((purpose, slot)) {
      case (LyricsAiModelPurpose.generation, LyricsAiModelSlot.primary):
        settings.generationPrimaryModel = selection;
      case (LyricsAiModelPurpose.generation, LyricsAiModelSlot.fallback):
        settings.generationFallbackModel = selection;
      case (LyricsAiModelPurpose.translation, LyricsAiModelSlot.primary):
        settings.translationPrimaryModel = selection;
      case (LyricsAiModelPurpose.translation, LyricsAiModelSlot.fallback):
        settings.translationFallbackModel = selection;
    }
  }

  Widget _buildProviderIcon(LyricsAiProvider provider) {
    return LyricsProviderIcon(provider: provider, size: 36);
  }

  Widget _buildSectionHeader(String title, [String? description]) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context, {
    required String title,
    IconData? icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

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



  Widget _buildThemeModeSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return _buildDropdownTile<ThemeMode>(
      context: context,
      title: l10n.themeMode,
      value: settings.themeMode,
      options: [
        _DropdownOption(
          value: ThemeMode.system,
          label: l10n.themeModeSystem,
        ),
        _DropdownOption(
          value: ThemeMode.light,
          label: l10n.themeModeLight,
        ),
        _DropdownOption(
          value: ThemeMode.dark,
          label: l10n.themeModeDark,
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        settings.themeMode = value;
      },
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return _buildDropdownTile<String>(
      context: context,
      title: l10n.interfaceLanguage,
      subtitle: l10n.interfaceLanguageDescription,
      value: settings.appLocale,
      options: [
        _DropdownOption(
          value: 'system',
          label: l10n.followSystemLanguage,
        ),
        _DropdownOption(
          value: 'zh',
          label: l10n.nativeLanguageZh,
        ),
        _DropdownOption(
          value: 'zh_Hant',
          label: l10n.nativeLanguageZhHant,
        ),
        _DropdownOption(
          value: 'ja',
          label: l10n.nativeLanguageJa,
        ),
        _DropdownOption(
          value: 'ko',
          label: l10n.nativeLanguageKo,
        ),
        _DropdownOption(
          value: 'es',
          label: l10n.nativeLanguageEs,
        ),
        _DropdownOption(
          value: 'fr',
          label: l10n.nativeLanguageFr,
        ),
        _DropdownOption(
          value: 'de',
          label: l10n.nativeLanguageDe,
        ),
        _DropdownOption(
          value: 'en',
          label: l10n.nativeLanguageEn,
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        settings.appLocale = value;
      },
    );
  }

  Widget _buildUiScaleSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currentPercent = (settings.uiScale * 100).round();

    return ListTile(
      leading: const Icon(Icons.aspect_ratio_rounded),
      title: Text(l10n.uiDisplayScale),
      subtitle: Text(l10n.uiDisplayScaleDescription),
      trailing: FilledButton.tonal(
        onPressed: () => _showUiScaleDialog(context, settings),
        child: Text('$currentPercent%'),
      ),
      onTap: () => _showUiScaleDialog(context, settings),
    );
  }

  Future<void> _showUiScaleDialog(
    BuildContext context,
    SettingsService settings,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    double tempScale = settings.uiScale;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final percent = (tempScale * 100).round();
            return AlertDialog(
              title: Text(l10n.uiDisplayScaleDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.uiDisplayScaleCurrent(percent),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('80%'),
                        Expanded(
                          child: Slider(
                            value: tempScale.clamp(
                              SettingsService.minUiScale,
                              SettingsService.maxUiScale,
                            ),
                            min: SettingsService.minUiScale,
                            max: SettingsService.maxUiScale,
                            divisions: 14,
                            label: '$percent%',
                            onChanged: (value) {
                              setDialogState(() {
                                tempScale = (value * 20).round() / 20.0;
                              });
                              settings.uiScale = tempScale;
                            },
                          ),
                        ),
                        const Text('150%'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '快捷预设 / Presets',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ChoiceChip(
                          label: const Text('100% 标准'),
                          selected: (tempScale - 1.0).abs() < 0.01,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => tempScale = 1.0);
                              settings.uiScale = 1.0;
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('125% 适中'),
                          selected: (tempScale - 1.25).abs() < 0.01,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => tempScale = 1.25);
                              settings.uiScale = 1.25;
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('135% 车机推荐'),
                          selected: (tempScale - 1.35).abs() < 0.01,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => tempScale = 1.35);
                              settings.uiScale = 1.35;
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('150% 大号'),
                          selected: (tempScale - 1.50).abs() < 0.01,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => tempScale = 1.50);
                              settings.uiScale = 1.50;
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() => tempScale = SettingsService.defaultUiScale);
                    settings.uiScale = SettingsService.defaultUiScale;
                  },
                  child: Text(l10n.reset),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildScanSection(BuildContext context, SettingsService settings) {
    final l10n = AppLocalizations.of(context)!;
    const minSeconds = 5;
    const maxSeconds = 300;
    const stepSeconds = 5;
    final enabled = settings.skipShortAudioScanEnabled;
    final currentSeconds = settings.skipShortAudioScanMinimumDurationSeconds;

    return Column(
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
        const Divider(height: 1),
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
    );
  }

  Widget _buildLyricsModelSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModelGroupCard(
            context,
            title: l10n.lyricsGenerationModel,
            description: l10n.lyricsGenerationModelDescription,
            primarySelection: settings.generationPrimaryModel,
            fallbackSelection: settings.generationFallbackModel,
            enabled: settings.hasAnyLyricsModelProvider,
            onPrimaryTap: () => _selectLyricsModel(
              settings: settings,
              purpose: LyricsAiModelPurpose.generation,
              slot: LyricsAiModelSlot.primary,
            ),
            onFallbackTap: () => _selectLyricsModel(
              settings: settings,
              purpose: LyricsAiModelPurpose.generation,
              slot: LyricsAiModelSlot.fallback,
            ),
          ),
          const SizedBox(height: 16),
          _buildModelGroupCard(
            context,
            title: l10n.lyricsTranslationModel,
            description: l10n.lyricsTranslationModelDescription,
            primarySelection: settings.translationPrimaryModel,
            fallbackSelection: settings.translationFallbackModel,
            enabled: settings.hasAnyLyricsModelProvider,
            onPrimaryTap: () => _selectLyricsModel(
              settings: settings,
              purpose: LyricsAiModelPurpose.translation,
              slot: LyricsAiModelSlot.primary,
            ),
            onFallbackTap: () => _selectLyricsModel(
              settings: settings,
              purpose: LyricsAiModelPurpose.translation,
              slot: LyricsAiModelSlot.fallback,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelGroupCard(
    BuildContext context, {
    required String title,
    required String description,
    required LyricsAiModelSelection primarySelection,
    required LyricsAiModelSelection fallbackSelection,
    required bool enabled,
    required VoidCallback onPrimaryTap,
    required VoidCallback onFallbackTap,
  }) {
    final theme = Theme.of(context);
    final content = Opacity(
      opacity: enabled ? 1 : 0.45,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(description, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            _buildModelTile(
              context,
              title: AppLocalizations.of(context)!.primaryModelLabel,
              selection: primarySelection,
              onTap: onPrimaryTap,
            ),
            const SizedBox(height: 12),
            _buildModelTile(
              context,
              title: AppLocalizations.of(context)!.backupModelLabel,
              selection: fallbackSelection,
              onTap: onFallbackTap,
            ),
          ],
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: content,
    );
  }

  Widget _buildModelTile(
    BuildContext context, {
    required String title,
    required LyricsAiModelSelection selection,
    required VoidCallback onTap,
  }) {
    final modelLabel = SettingsService.lyricsModelSelectionLabel(selection);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    modelLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  String _translationLanguageLabel(BuildContext context, String languageCode) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = LanguageCodeUtils.normalizeLanguageCode(languageCode);
    if (normalized.isEmpty) {
      return l10n.followSystemLanguage;
    }
    return LanguageCodeUtils.languageDisplayName(normalized);
  }

  List<DropdownMenuItem<String>> _translationLanguageItems(
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return [
      DropdownMenuItem<String>(
        value: '',
        child: Text(l10n.followSystemLanguage),
      ),
      ...LanguageCodeUtils.supportedTranslationLanguageCodes.map(
        (languageCode) => DropdownMenuItem<String>(
          value: languageCode,
          child: Text(_translationLanguageLabel(context, languageCode)),
        ),
      ),
    ];
  }

  Widget _buildLyricsTranslationLanguageSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final value = settings.lyricsTranslationTargetLanguageCode;
    final targetValue = value.isEmpty ? '' : value;

    final options = <_DropdownOption<String>>[
      _DropdownOption<String>(
        value: '',
        label: l10n.followSystemLanguage,
      ),
      ...LanguageCodeUtils.supportedTranslationLanguageCodes.map(
        (languageCode) => _DropdownOption<String>(
          value: languageCode,
          label: _translationLanguageLabel(context, languageCode),
        ),
      ),
    ];

    return _buildDropdownTile<String>(
      context: context,
      title: l10n.lyricsTranslationTargetLanguageLabel,
      subtitle: l10n.lyricsTranslationTargetLanguageDescription,
      value: targetValue,
      options: options,
      onChanged: (newValue) {
        if (newValue == null) return;
        settings.lyricsTranslationTargetLanguageCode = newValue;
      },
    );
  }

  Widget _buildLyricsSaveMethodSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _buildDropdownTile<LyricsSaveMethod>(
      context: context,
      title: l10n.lyricsSaveMethodLabel,
      subtitle: l10n.lyricsSaveMethodDescription,
      value: settings.lyricsSaveMethod,
      options: [
        _DropdownOption<LyricsSaveMethod>(
          value: LyricsSaveMethod.original,
          label: l10n.lyricsSaveMethodOriginal,
        ),
        _DropdownOption<LyricsSaveMethod>(
          value: LyricsSaveMethod.embedded,
          label: l10n.lyricsSaveMethodEmbedded,
        ),
        _DropdownOption<LyricsSaveMethod>(
          value: LyricsSaveMethod.lrcFile,
          label: l10n.lyricsSaveMethodLrcFile,
        ),
      ],
      onChanged: (newValue) {
        if (newValue == null) return;
        settings.lyricsSaveMethod = newValue;
      },
    );
  }

  Widget _buildLyricsStyleSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _buildDropdownTile<LyricsStyle>(
      context: context,
      title: l10n.lyricsStyleLabel,
      subtitle: l10n.lyricsStyleDescription,
      value: settings.lyricsStyle,
      options: [
        _DropdownOption<LyricsStyle>(
          value: LyricsStyle.traditional,
          label: l10n.lyricsStyleTraditional,
        ),
        _DropdownOption<LyricsStyle>(
          value: LyricsStyle.apple,
          label: l10n.lyricsStyleApple,
        ),
      ],
      onChanged: (newValue) {
        if (newValue == null) return;
        settings.lyricsStyle = newValue;
      },
    );
  }

  Widget _buildLyricsImportExportSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.download_rounded),
          title: Text(l10n.importLyricsLabel),
          subtitle: Text(l10n.importLyricsDescription),
          trailing: FilledButton.tonal(
            onPressed: () => _importLyrics(context),
            child: Text(l10n.importAction),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.upload_rounded),
          title: Text(l10n.exportLyricsLabel),
          subtitle: Text(l10n.exportLyricsDescription),
          trailing: FilledButton.tonal(
            onPressed: () => _exportLyrics(context),
            child: Text(l10n.exportAction),
          ),
        ),
      ],
    );
  }

  Future<String?> _pickOpenJsonPath() async {
    return FileSelectorHelper.pickFile(
      label: 'JSON',
      extensions: const ['json'],
      fileType: FileType.custom,
    );
  }

  Future<void> _exportLyrics(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final service = const LyricsImportExportService();
      final repository = LyricsCacheRepository();

      final jsonStr = await service.exportLyrics(repository);
      final bytes = Uint8List.fromList(utf8.encode(jsonStr));

      final path = await FileSelectorHelper.saveFile(
        suggestedName: 'vynody_lyrics_backup.json',
        label: 'JSON',
        extensions: const ['json'],
        dialogTitle: 'Export Lyrics',
        bytes: bytes,
      );
      if (path == null) return;

      final count = (jsonDecode(jsonStr)['lyricsCaches'] as List).length;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportSuccess(count))),
      );
    } catch (e) {
      debugPrint('Export error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportFailed(e.toString()))),
      );
    }
  }

  Future<void> _importLyrics(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final path = await _pickOpenJsonPath();
      if (path == null) return;

      final file = File(path);
      final jsonStr = await file.readAsString();

      // Basic validation
      final parsed = jsonDecode(jsonStr);
      if (parsed is! Map || !parsed.containsKey('lyricsCaches')) {
        throw Exception(l10n.invalidBackupFile);
      }

      final service = const LyricsImportExportService();
      final repository = LyricsCacheRepository();

      // Show a loading indicator dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final result = await service.scanBackup(jsonStr, repository);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Dismiss loading indicator

      if (result.conflicts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importSuccess(result.autoImportedCount))),
        );
        return;
      }

      // We have conflicts! Show dialog
      await _resolveConflicts(context, result.conflicts, repository);
    } catch (e) {
      debugPrint('Import error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importFailed(e.toString()))),
      );
    }
  }

  Future<void> _resolveConflicts(
    BuildContext context,
    List<LyricsConflict> conflicts,
    LyricsCacheRepository repository,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.importConflictsTitle),
          content: Text(l10n.importConflictsMessage(conflicts.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'skip'),
              child: Text(l10n.skipAllConflicts),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'one_by_one'),
              child: Text(l10n.decideOneByOne),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, 'overwrite'),
              child: Text(l10n.overwriteAll),
            ),
          ],
        );
      },
    );

    if (choice == null) return;

    final service = const LyricsImportExportService();

    if (choice == 'overwrite') {
      for (final conflict in conflicts) {
        await service.importRecord(
          conflict.imported,
          conflict.importedTranslations,
          repository,
        );
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importSuccess(conflicts.length))),
      );
    } else if (choice == 'one_by_one') {
      int importedCount = 0;
      bool overwriteRemaining = false;
      bool skipRemaining = false;

      for (int i = 0; i < conflicts.length; i++) {
        if (overwriteRemaining) {
          final conflict = conflicts[i];
          await service.importRecord(
            conflict.imported,
            conflict.importedTranslations,
            repository,
          );
          importedCount++;
          continue;
        }

        if (skipRemaining) {
          continue;
        }

        final conflict = conflicts[i];
        final resolution = await _showConflictCompareDialog(
          context,
          conflict,
          i + 1,
          conflicts.length,
        );

        if (resolution == 'overwrite') {
          await service.importRecord(
            conflict.imported,
            conflict.importedTranslations,
            repository,
          );
          importedCount++;
        } else if (resolution == 'overwrite_remaining') {
          overwriteRemaining = true;
          await service.importRecord(
            conflict.imported,
            conflict.importedTranslations,
            repository,
          );
          importedCount++;
        } else if (resolution == 'skip_remaining') {
          skipRemaining = true;
        } else if (resolution == 'cancel') {
          break; // Abort rest of import
        }
        // If resolution is 'skip', do nothing
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importSuccess(importedCount))),
      );
    }
  }

  String _getLyricsPreview(LyricsCacheRecord record) {
    if (record.syncedLines.isEmpty) {
      return record.syncedLyrics ?? '';
    }
    return record.syncedLines
        .take(4)
        .map((line) => line.text)
        .join('\n');
  }

  Future<String?> _showConflictCompareDialog(
    BuildContext context,
    LyricsConflict conflict,
    int current,
    int total,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final meta = LyricsImportExportService.parseCacheKey(conflict.imported.cacheKey);
    final title = meta['title'] ?? 'Unknown';
    final artist = meta['artist'] ?? 'Unknown';

    final existingPreview = _getLyricsPreview(conflict.existing);
    final importedPreview = _getLyricsPreview(conflict.imported);

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.conflictResolutionTitle(current, total)),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$title - $artist',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Existing column
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.conflictExistingLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.conflictSourceLabel(conflict.existing.source.name),
                                style: theme.textTheme.bodySmall,
                              ),
                              const Divider(),
                              Text(
                                existingPreview.isEmpty ? '(Empty)' : existingPreview,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Imported column
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.conflictImportedLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.conflictSourceLabel(conflict.imported.source.name),
                                style: theme.textTheme.bodySmall,
                              ),
                              const Divider(),
                              Text(
                                importedPreview.isEmpty ? '(Empty)' : importedPreview,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'cancel'),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'skip'),
                  child: Text(l10n.skipThis),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'skip_remaining'),
                  child: Text(l10n.skipRemaining),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'overwrite'),
                  child: Text(l10n.overwriteThis),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, 'overwrite_remaining'),
                  child: Text(l10n.overwriteRemaining),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTranscodeSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildDropdownTile<AudioFormat>(
          context: context,
          title: l10n.transcodeDefaultFormat,
          value: settings.transcodeDefaultFormat,
          options: AudioFormat.values
              .map(
                (format) => _DropdownOption<AudioFormat>(
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
        _buildDropdownTile<TranscodeQualityTier>(
          context: context,
          title: l10n.transcodeDefaultQuality,
          value: settings.transcodeDefaultQualityTier,
          options: TranscodeQualityTier.values
              .map(
                (tier) => _DropdownOption<TranscodeQualityTier>(
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildHomeSectionTile(
          context,
          icon: Icons.tune_rounded,
          title: l10n.generalSectionTitle,
          onTap: () => _openSection(_SettingsSection.general),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.graphic_eq_rounded,
          title: l10n.audioSettings,
          onTap: () => _openSection(_SettingsSection.audio),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.search_rounded,
          title: l10n.scanSectionTitle,
          onTap: () => _openSection(_SettingsSection.scanning),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.label_outline_rounded,
          title: l10n.tags,
          onTap: () => _openSection(_SettingsSection.tags),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.swap_horiz_rounded,
          title: l10n.transcodeSectionTitle,
          onTap: () => _openSection(_SettingsSection.transcode),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.auto_awesome_rounded,
          title: l10n.lyricsSectionTitle,
          onTap: () => _openSection(_SettingsSection.lyrics),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.graphic_eq_rounded,
          title: l10n.acoustidSectionTitle,
          onTap: () => _openSection(_SettingsSection.acoustid),
        ),
        _buildHomeSectionTile(
          context,
          icon: Icons.keyboard_rounded,
          title: l10n.shortcutSettingsTitle,
          onTap: () => _openSection(_SettingsSection.shortcuts),
        ),
        if (Platform.isWindows)
          _buildHomeSectionTile(
            context,
            icon: Icons.open_in_new_rounded,
            title: l10n.windowsSettingsTitle,
            onTap: () => _openSection(_SettingsSection.windows),
          ),
        _buildHomeSectionTile(
          context,
          icon: Icons.info_outline_rounded,
          title: l10n.about,
          onTap: () => _openSection(_SettingsSection.about),
        ),
      ],
    );
  }

  Widget _buildGeneralPage(BuildContext context, SettingsService settings) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSectionHeader(
          l10n.generalSectionTitle,
          l10n.generalSectionDescription,
        ),
        _buildGroupCard(
          context,
          title: l10n.uiAppearanceGroup,
          icon: Icons.palette_outlined,
          children: [
            _buildThemeModeSection(context, settings),
            _buildLanguageSection(context, settings),
            _buildUiScaleSection(context, settings),
            SwitchListTile(
              title: Text(l10n.collapseButtonsInLandscapeLyrics),
              subtitle: Text(l10n.collapseButtonsInLandscapeLyricsDescription),
              value: settings.collapseButtonsInLandscapeLyrics,
              onChanged: (value) {
                settings.collapseButtonsInLandscapeLyrics = value;
              },
            ),
            ListTile(
              title: Text(l10n.playbackButtonLayoutTitle),
              subtitle: Text(l10n.playbackButtonLayoutDescription),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showPlaybackButtonLayoutDialog(context, settings),
            ),
            SwitchListTile(
              title: Text(l10n.showDeveloperOptions),
              subtitle: Text(l10n.showDeveloperOptionsDescription),
              value: settings.showDeveloperOptions,
              onChanged: (value) {
                settings.showDeveloperOptions = value;
              },
            ),
          ],
        ),
        _buildGroupCard(
          context,
          title: l10n.playbackBehaviorGroup,
          icon: Icons.touch_app_outlined,
          children: [
            SwitchListTile(
              title: Text(l10n.immersiveTabBar),
              subtitle: Text(l10n.immersiveTabBarDescription),
              value: settings.isImmersiveTabBarEnabled,
              onChanged: (value) {
                settings.isImmersiveTabBarEnabled = value;
              },
            ),
            SwitchListTile(
              title: Text(l10n.openPlaybackOnDirectorySongTap),
              subtitle: Text(l10n.openPlaybackOnDirectorySongTapDescription),
              value: settings.openPlaybackOnDirectorySongTap,
              onChanged: (value) {
                settings.openPlaybackOnDirectorySongTap = value;
              },
            ),
            SwitchListTile(
              title: Text(l10n.defaultToLyricsModeOnPlaybackOpen),
              subtitle: Text(l10n.defaultToLyricsModeOnPlaybackOpenDescription),
              value: settings.defaultToLyricsModeOnPlaybackOpen,
              onChanged: (value) {
                settings.defaultToLyricsModeOnPlaybackOpen = value;
              },
            ),
            SwitchListTile(
              title: Text(l10n.enableWaveformProgressBar),
              subtitle: Text(l10n.enableWaveformProgressBarDescription),
              value: settings.isWaveformProgressBarEnabled,
              onChanged: (value) {
                settings.isWaveformProgressBarEnabled = value;
              },
            ),
            if (settings.isWaveformProgressBarEnabled)
              SwitchListTile(
                title: Text(l10n.enableWaveformLongPressSeek),
                subtitle: Text(l10n.enableWaveformLongPressSeekDescription),
                value: settings.enableWaveformLongPressSeek,
                onChanged: (value) {
                  settings.enableWaveformLongPressSeek = value;
                },
              ),
            if (settings.isWaveformProgressBarEnabled)
              ListTile(
                title: Text(l10n.waveformLongPressSeekSpeed),
                subtitle: Text(l10n.waveformLongPressSeekSpeedDescription),
                trailing: SizedBox(
                  width: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: settings.waveformLongPressSeekSpeed.clamp(
                            SettingsService.minWaveformLongPressSeekSpeed,
                            SettingsService.maxWaveformLongPressSeekSpeed,
                          ),
                          min: SettingsService.minWaveformLongPressSeekSpeed,
                          max: SettingsService.maxWaveformLongPressSeekSpeed,
                          divisions: ((SettingsService.maxWaveformLongPressSeekSpeed -
                                      SettingsService.minWaveformLongPressSeekSpeed) /
                                  0.1)
                              .round(),
                          onChanged: (value) {
                            settings.waveformLongPressSeekSpeed = value;
                          },
                        ),
                      ),
                      Text(
                        '${settings.waveformLongPressSeekSpeed.toStringAsFixed(1)}×',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        _buildGroupCard(
          context,
          title: l10n.systemWindowBehaviorGroup,
          icon: Icons.desktop_windows_outlined,
          children: [
            SwitchListTile(
              title: Text(l10n.showScanProgressToastSetting),
              subtitle: Text(l10n.showScanProgressToastSettingDescription),
              value: settings.showScanProgressToast,
              onChanged: (value) {
                settings.showScanProgressToast = value;
              },
            ),
            if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) ...[
              SwitchListTile(
                title: Text(l10n.enableSystemTray),
                subtitle: Text(l10n.enableSystemTrayDescription),
                value: settings.enableSystemTray,
                onChanged: (value) {
                  settings.enableSystemTray = value;
                },
              ),
              _buildDropdownTile<CloseWindowAction>(
                context: context,
                title: l10n.closeWindowActionTitle,
                subtitle: !settings.enableSystemTray
                    ? '${l10n.closeWindowActionDescription} ${l10n.closeWindowActionTrayDisabledTip}'
                    : l10n.closeWindowActionDescription,
                value: !settings.enableSystemTray
                    ? CloseWindowAction.exit
                    : settings.closeWindowAction,
                enabled: settings.enableSystemTray,
                options: [
                  _DropdownOption(
                    value: CloseWindowAction.ask,
                    label: l10n.closeWindowActionAsk,
                  ),
                  _DropdownOption(
                    value: CloseWindowAction.minimize,
                    label: l10n.closeWindowActionMinimize,
                    enabled: settings.enableSystemTray,
                  ),
                  _DropdownOption(
                    value: CloseWindowAction.exit,
                    label: l10n.closeWindowActionExit,
                  ),
                ],
                onChanged: !settings.enableSystemTray
                    ? null
                    : (value) {
                        if (value != null) {
                          settings.closeWindowAction = value;
                        }
                      },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(l10n.resetOnboarding),
              subtitle: Text(l10n.resetOnboardingDesc),
              trailing: FilledButton.tonal(
                onPressed: () {
                  settings.hasShownOnboarding = false;
                  settings.hasShownCoverTapLyricTip = false;
                  settings.hasShownLyricsMenuTip = false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.onboardingReset)),
                  );
                },
                child: Text(l10n.reset),
              ),
            ),
          ],
        ),
        if (settings.showDeveloperOptions) ...[
          const SizedBox(height: 8),
          _buildSectionHeader(
            l10n.advanced,
            l10n.advancedOptionsDescription,
          ),
          ListTile(
            title: Text(l10n.waveformSegments),
            subtitle: Text(l10n.waveformSegmentsDescription),
            trailing: SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: settings.waveformChunks > 20
                        ? () => settings.waveformChunks -= 10
                        : null,
                  ),
                  Text('${settings.waveformChunks}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: settings.waveformChunks < 200
                        ? () => settings.waveformChunks += 10
                        : null,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(l10n.sampleStride),
            subtitle: Text(l10n.sampleStrideDescription),
            trailing: SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: settings.sampleStride > 1
                        ? () => settings.sampleStride -= 1
                        : null,
                  ),
                  Text('${settings.sampleStride}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: settings.sampleStride < 16
                        ? () => settings.sampleStride += 1
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScanningPage(BuildContext context, SettingsService settings) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSectionHeader(l10n.scanSectionTitle, l10n.scanSectionDescription),
        _buildScanSection(context, settings),
      ],
    );
  }

  Widget _buildTagsPage(BuildContext context, SettingsService settings) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSectionHeader(
          l10n.tags,
          l10n.tagsSectionDescription,
        ),
        SwitchListTile(
          title: Text(l10n.autoSaveToSourceFile),
          subtitle: Text(l10n.autoSaveToSourceFileDescription),
          value: settings.tagCompletionSaveToSourceFile,
          onChanged: (value) {
            settings.tagCompletionSaveToSourceFile = value;
          },
        ),
      ],
    );
  }

  Widget _buildTranscodePage(BuildContext context, SettingsService settings) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSectionHeader(
          l10n.transcodeSectionTitle,
          l10n.transcodeSectionDescription,
        ),
        _buildTranscodeSection(context, settings),
      ],
    );
  }

  Widget _buildLyricsPage(BuildContext context, SettingsService settings) {
    final l10n = AppLocalizations.of(context)!;
    final hasAnyProvider = settings.hasAnyLyricsModelProvider;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSectionHeader(
          l10n.lyricsSectionTitle,
          l10n.lyricsSectionDescription,
        ),
        _buildLyricsTranslationLanguageSection(context, settings),
        const SizedBox(height: 16),
        _buildLyricsSaveMethodSection(context, settings),
        const SizedBox(height: 16),
        _buildLyricsStyleSection(context, settings),
        const SizedBox(height: 16),
        _buildSectionHeader(l10n.lyricsImportExportHeader),
        _buildLyricsImportExportSection(context, settings),
        _buildSectionHeader(l10n.platformApiKeysSectionTitle),
        ListTile(
          leading: _buildProviderIcon(LyricsAiProvider.googleAiStudio),
          title: Text(l10n.googleAiStudioApiKey),
          subtitle: Text(
            settings.geminiApiKey.trim().isEmpty
                ? l10n.apiKeyMissingStatus
                : l10n.apiKeySavedStatus,
          ),
          trailing: FilledButton.tonal(
            onPressed: () async {
              final enteredApiKey = await showGoogleAiStudioApiKeyDialog(
                context,
                ref: ref,
                initialApiKey: settings.geminiApiKey,
              );
              if (enteredApiKey == null) {
                return;
              }
              settings.geminiApiKey = enteredApiKey;

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    enteredApiKey.trim().isEmpty
                        ? l10n.clearedGoogleAiStudioApiKey
                        : l10n.apiKeySaved('Google AI Studio'),
                  ),
                ),
              );
            },
            child: Text(
              settings.geminiApiKey.trim().isEmpty ? l10n.fill : l10n.modify,
            ),
          ),
        ),
        ListTile(
          leading: _buildProviderIcon(LyricsAiProvider.openRouter),
          title: Text(l10n.openRouterApiKey),
          subtitle: Text(
            settings.openRouterApiKey.trim().isEmpty
                ? l10n.apiKeyMissingStatus
                : l10n.apiKeySavedStatus,
          ),
          trailing: FilledButton.tonal(
            onPressed: () async {
              final enteredApiKey = await showOpenRouterApiKeyDialog(
                context,
                ref: ref,
                initialApiKey: settings.openRouterApiKey,
              );
              if (enteredApiKey == null) {
                return;
              }
              settings.openRouterApiKey = enteredApiKey;
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    enteredApiKey.trim().isEmpty
                        ? l10n.clearedOpenRouterApiKey
                        : l10n.apiKeySaved('OpenRouter'),
                  ),
                ),
              );
            },
            child: Text(
              settings.openRouterApiKey.trim().isEmpty
                  ? l10n.fill
                  : l10n.modify,
            ),
          ),
        ),
        ListTile(
          leading: _buildProviderIcon(LyricsAiProvider.doubao),
          title: Text(l10n.doubaoApiKey),
          subtitle: Text(
            settings.doubaoApiKey.trim().isEmpty
                ? l10n.apiKeyMissingStatus
                : l10n.apiKeySavedStatus,
          ),
          trailing: FilledButton.tonal(
            onPressed: () async {
              final enteredApiKey = await showDoubaoApiKeyDialog(
                context,
                ref: ref,
                initialApiKey: settings.doubaoApiKey,
              );
              if (enteredApiKey == null) {
                return;
              }
              settings.doubaoApiKey = enteredApiKey;
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    enteredApiKey.trim().isEmpty
                        ? l10n.clearedDoubaoApiKey
                        : l10n.savedDoubaoApiKey,
                  ),
                ),
              );
            },
            child: Text(
              settings.doubaoApiKey.trim().isEmpty ? l10n.fill : l10n.modify,
            ),
          ),
        ),
        ListTile(
          leading: _buildProviderIcon(LyricsAiProvider.deepseek),
          title: Text(l10n.deepseekApiKey),
          subtitle: Text(
            '${settings.deepseekApiKey.trim().isEmpty ? l10n.apiKeyMissingStatus : l10n.apiKeySavedStatus}  ·  ${l10n.onlyForLyricTranslation}',
          ),
          trailing: FilledButton.tonal(
            onPressed: () async {
              final enteredApiKey = await showDeepSeekApiKeyDialog(
                context,
                ref: ref,
                initialApiKey: settings.deepseekApiKey,
              );
              if (enteredApiKey == null) {
                return;
              }
              settings.deepseekApiKey = enteredApiKey;
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    enteredApiKey.trim().isEmpty
                        ? l10n.clearedDeepseekApiKey
                        : l10n.savedDeepseekApiKey,
                  ),
                ),
              );
            },
            child: Text(
              settings.deepseekApiKey.trim().isEmpty ? l10n.fill : l10n.modify,
            ),
          ),
        ),
        ListTile(
          leading: _buildProviderIcon(LyricsAiProvider.custom),
          title: Text(settings.customProviderName.trim().isEmpty
              ? l10n.customApiProvider
              : settings.customProviderName.trim()),
          subtitle: Text(
            '${settings.customProviderApiKey.trim().isEmpty ? l10n.apiKeyMissingStatus : l10n.apiKeySavedStatus}  ·  ${l10n.onlyForLyricTranslation}',
          ),
          trailing: FilledButton.tonal(
            onPressed: () async {
              final result = await showCustomProviderDialog(
                context,
                initialBaseUrl: settings.customProviderBaseUrl,
                initialApiKey: settings.customProviderApiKey,
                initialName: settings.customProviderName,
              );
              if (result == null) {
                return;
              }
              settings.customProviderBaseUrl = result.baseUrl;
              settings.customProviderApiKey = result.apiKey;
              settings.customProviderName = result.name;
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.apiKey.trim().isEmpty
                        ? l10n.clearedCustomProviderConfig
                        : l10n.savedCustomProviderConfig,
                  ),
                ),
              );
            },
            child: Text(
              settings.customProviderApiKey.trim().isEmpty
                  ? l10n.fill
                  : l10n.modify,
            ),
          ),
        ),
        _buildSectionHeader(l10n.geminiModelsSectionTitle),
        if (!hasAnyProvider)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              l10n.fillApiKeyFirstEnablesModels,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
        _buildLyricsModelSection(context, settings),
      ],
    );
  }

  Widget _buildAcoustidPage(BuildContext context, SettingsService settings) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSectionHeader(l10n.acoustidSectionTitle, l10n.acoustidApiKeyHelp),
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
                  style: TextStyle(
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
    );
  }

  Widget _buildShortcutsPage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSectionHeader(
          l10n.shortcutSettingsTitle,
          l10n.shortcutSettingsDescription,
        ),
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
    );
  }

  Widget _buildWindowsPage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSectionHeader(
          l10n.windowsSettingsTitle,
          l10n.fileAssociationDescription,
        ),
        _buildWindowsSection(context),
      ],
    );
  }

  Widget _buildAboutPage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSectionHeader(
          l10n.about,
          l10n.aboutSectionDescription,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vynody ${_appVersion.isEmpty ? "" : "v$_appVersion"}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse('https://github.com/axel10/vynody');
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      'https://github.com/axel10/vynody',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: _isCheckingUpdates ? null : _checkForUpdates,
                  icon: _isCheckingUpdates
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.system_update_alt_rounded),
                  label: Text(l10n.checkForUpdates),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _isExportingLogs ? null : _exportLogs,
                  icon: _isExportingLogs
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.description_rounded),
                  label: Text(l10n.exportLogs),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPage(BuildContext context, SettingsService settings) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildSectionHeader(
          l10n.audioSettings,
          l10n.audioSettingsDescription,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.equalizerBandCount,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
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
        const Divider(height: 32),
        SwitchListTile(
          title: Text(l10n.enableFadeEffect),
          subtitle: Text(l10n.enableFadeEffectDescription),
          value: settings.enableFadeEffect,
          onChanged: (value) {
            settings.enableFadeEffect = value;
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, SettingsService settings) {
    final currentBody = switch (_currentSection) {
      _SettingsSection.home => _buildHomeBody(context),
      _SettingsSection.general => _buildGeneralPage(context, settings),
      _SettingsSection.audio => _buildAudioPage(context, settings),
      _SettingsSection.scanning => _buildScanningPage(context, settings),
      _SettingsSection.tags => _buildTagsPage(context, settings),
      _SettingsSection.transcode => _buildTranscodePage(context, settings),
      _SettingsSection.lyrics => _buildLyricsPage(context, settings),
      _SettingsSection.acoustid => _buildAcoustidPage(context, settings),
      _SettingsSection.shortcuts => _buildShortcutsPage(context),
      _SettingsSection.windows => _buildWindowsPage(context),
      _SettingsSection.about => _buildAboutPage(context),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: KeyedSubtree(key: ValueKey(_currentSection), child: currentBody),
    );
  }

  Widget _buildSidebar(BuildContext context, _SettingsSection activeSection) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _sidebarSections.length,
            itemBuilder: (context, index) {
              final section = _sidebarSections[index];
              final isSelected = section == activeSection;
              final icon = _sectionIcon(section);
              final title = _sectionTitle(context, section);

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
    _SettingsSection activeSection,
  ) {
    final currentBody = switch (activeSection) {
      _SettingsSection.home => _buildGeneralPage(context, settings),
      _SettingsSection.general => _buildGeneralPage(context, settings),
      _SettingsSection.audio => _buildAudioPage(context, settings),
      _SettingsSection.scanning => _buildScanningPage(context, settings),
      _SettingsSection.tags => _buildTagsPage(context, settings),
      _SettingsSection.transcode => _buildTranscodePage(context, settings),
      _SettingsSection.lyrics => _buildLyricsPage(context, settings),
      _SettingsSection.acoustid => _buildAcoustidPage(context, settings),
      _SettingsSection.shortcuts => _buildShortcutsPage(context),
      _SettingsSection.windows => _buildWindowsPage(context),
      _SettingsSection.about => _buildAboutPage(context),
    };

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

  Widget _buildRootScaffold(BuildContext context, SettingsService settings) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      final activeSection = _currentSection == _SettingsSection.home
          ? _SettingsSection.general
          : _currentSection;

      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 280,
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
      final title = _sectionTitle(context, _currentSection);

      return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          notificationPredicate: (_) => false,
          title: Text(title),
          leading: _currentSection == _SettingsSection.home
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goHome,
                ),
        ),
        body: _buildBody(context, settings),
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
    final canPop = isLandscape || _currentSection == _SettingsSection.home;

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

final class _CustomProviderConfig {
  const _CustomProviderConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.name,
  });

  final String baseUrl;
  final String apiKey;
  final String name;
}

Future<_CustomProviderConfig?> showCustomProviderDialog(
  BuildContext context, {
  required String initialBaseUrl,
  required String initialApiKey,
  required String initialName,
}) async {
  return showDialog<_CustomProviderConfig>(
    context: context,
    builder: (dialogContext) {
      return _CustomProviderConfigDialog(
        initialBaseUrl: initialBaseUrl,
        initialApiKey: initialApiKey,
        initialName: initialName,
      );
    },
  );
}

class _CustomProviderConfigDialog extends StatefulWidget {
  const _CustomProviderConfigDialog({
    required this.initialBaseUrl,
    required this.initialApiKey,
    required this.initialName,
  });

  final String initialBaseUrl;
  final String initialApiKey;
  final String initialName;

  @override
  State<_CustomProviderConfigDialog> createState() =>
      _CustomProviderConfigDialogState();
}

class _CustomProviderConfigDialogState
    extends State<_CustomProviderConfigDialog> {
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _nameController;
  bool _isTesting = false;
  String _statusText = '';
  bool _statusSuccess = false;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(
      text: widget.initialBaseUrl,
    );
    _apiKeyController = TextEditingController(
      text: widget.initialApiKey,
    );
    _nameController = TextEditingController(
      text: widget.initialName,
    );
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (baseUrl.isEmpty || apiKey.isEmpty) {
      setState(() {
        _statusText = l10n.pleaseEnterApiKey;
        _statusSuccess = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _statusText = l10n.testingConnectionProgress;
      _statusSuccess = false;
    });

    try {
      final modelsUrl = baseUrl.endsWith('/')
          ? '${baseUrl}models'
          : '$baseUrl/models';
      final response = await Dio().get(
        modelsUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $apiKey',
        }),
      );
      if (response.data is Map) {
        final data = response.data as Map;
        final models = data['data'];
        if (models is List) {
          setState(() {
            _isTesting = false;
            _statusSuccess = true;
            _statusText = l10n.connectionSuccessDetectedModels(models.length);
          });
          return;
        }
      }
      setState(() {
        _isTesting = false;
        _statusSuccess = false;
        _statusText = l10n.unexpectedResponseFormat;
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _statusSuccess = false;
        _statusText = l10n.connectionTestException(e);
      });
    }
  }

  void _clearAndSave() {
    Navigator.of(context).pop(
      const _CustomProviderConfig(baseUrl: '', apiKey: '', name: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.customApiProvider),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18,
                      color: Theme.of(context).hintColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.customProviderOnlyTranslation,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.providerLabel,
                hintText: 'My Provider',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _baseUrlController,
              decoration: InputDecoration(
                labelText: l10n.baseUrl,
                hintText: 'https://api.openai.com/v1',
                border: const OutlineInputBorder(),
                helperText: l10n.openaiCompatibleEndpoint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: l10n.apiKey,
                hintText: l10n.pleaseEnterApiKeyHint,
                border: const OutlineInputBorder(),
              ),
            ),
            if (_statusText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _statusSuccess
                        ? Icons.check_circle_outline_rounded
                        : Icons.error_outline_rounded,
                    size: 18,
                    color: _statusSuccess ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 13,
                        color: _statusSuccess ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isTesting
              ? null
              : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _isTesting ? null : _clearAndSave,
          child: Text(l10n.clear),
        ),
        TextButton(
          onPressed: _isTesting ? null : _testConnection,
          child: Text(_isTesting ? l10n.testingConnection : l10n.testConnection),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _CustomProviderConfig(
                baseUrl: _baseUrlController.text.trim(),
                apiKey: _apiKeyController.text.trim(),
                name: _nameController.text.trim(),
              ),
            );
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _LyricsModelPickerDialog extends ConsumerStatefulWidget {
  const _LyricsModelPickerDialog({
    required this.ref,
    required this.purpose,
    required this.slot,
    required this.initialSelection,
  });

  final WidgetRef ref;
  final LyricsAiModelPurpose purpose;
  final LyricsAiModelSlot slot;
  final LyricsAiModelSelection initialSelection;

  @override
  ConsumerState<_LyricsModelPickerDialog> createState() =>
      _LyricsModelPickerDialogState();
}

class _LyricsModelPickerDialogState
    extends ConsumerState<_LyricsModelPickerDialog> {
  late LyricsAiProvider _provider;
  late LyricsAiModelSelection _selection;
  final TextEditingController _searchController = TextEditingController();
  final Map<LyricsAiProvider, List<LyricsModelInfo>> _modelsByProvider = {};
  final Map<LyricsAiProvider, String> _statusTextByProvider = {};
  final Set<LyricsAiProvider> _loadedProviders = {};
  final Set<LyricsAiProvider> _loadingProviders = {};
  String _statusText = '';
  String _searchQuery = '';
  bool _showRecommendedOnly = true;

  bool get _isLoading => _loadingProviders.contains(_provider);

  Widget _buildProviderIcon(LyricsAiProvider provider) {
    return LyricsProviderIcon(provider: provider, size: 24);
  }

  @override
  void initState() {
    super.initState();
    _provider = widget.initialSelection.provider;
    _selection = widget.initialSelection;
    _fetchModels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchModels() async {
    final targetProvider = _provider;
    if (_loadedProviders.contains(targetProvider)) {
      setState(() {
        _statusText = _statusTextByProvider[targetProvider] ?? '';
      });
      return;
    }
    if (_loadingProviders.contains(targetProvider)) {
      return;
    }

    final settings = ref.read(settingsServiceProvider);
    setState(() {
      _loadingProviders.add(targetProvider);
      if (_provider == targetProvider) {
        _statusText = '';
      }
    });

    try {
      final result = await ref
          .read(lyricsModelCatalogServiceProvider)
          .fetchModels(
            provider: targetProvider,
            purpose: widget.purpose,
            apiKey: settings.apiKeyForProvider(targetProvider),
            baseUrl: targetProvider == LyricsAiProvider.custom
                ? settings.customProviderBaseUrl
                : '',
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingProviders.remove(targetProvider);
        _modelsByProvider[targetProvider] = result.models;
        _statusTextByProvider[targetProvider] = result.message;
        _loadedProviders.add(targetProvider);

        if (_provider == targetProvider) {
          _statusText = result.message;
          final hasCurrent = result.models.any(
            (item) => item.id == _selection.modelId,
          );
          if (!hasCurrent) {
            _selection = _selection.copyWith(modelId: '');
          }
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingProviders.remove(targetProvider);
        _statusTextByProvider[targetProvider] = e.toString();
        if (_provider == targetProvider) {
          _statusText = e.toString();
        }
      });
    }
  }

  bool _isModelRecommended(LyricsModelInfo model) {
    if (model.id == _selection.modelId) {
      return true;
    }
    return LyricsModelRecommendation.isRecommended(model.id, model.provider);
  }

  List<LyricsModelInfo> get _filteredModels {
    final models = _modelsByProvider[_provider] ?? const [];
    final baseModels = _showRecommendedOnly
        ? models.where(_isModelRecommended).toList()
        : models;
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return baseModels;
    }

    return baseModels
        .where((model) {
          final label = model.label.toLowerCase();
          final id = model.id.toLowerCase();
          return label.contains(query) || id.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsServiceProvider);
    final availableProviders = settings.availableLyricsModelProviders;
    final availableTabs = [
      LyricsAiProvider.googleAiStudio,
      LyricsAiProvider.openRouter,
      LyricsAiProvider.doubao,
      if (widget.purpose == LyricsAiModelPurpose.translation) ...[
        LyricsAiProvider.deepseek,
        LyricsAiProvider.custom,
      ],
    ].where(availableProviders.contains).toList(growable: false);
    final canSave =
        widget.slot == LyricsAiModelSlot.fallback ||
        _selection.modelId.trim().isNotEmpty;
    final effectiveProvider = availableTabs.contains(_provider)
        ? _provider
        : (availableTabs.isNotEmpty ? availableTabs.first : _provider);
    return AlertDialog(
      title: Text(
        widget.purpose == LyricsAiModelPurpose.generation
            ? l10n.lyricsGenerationModel
            : l10n.lyricsTranslationModel,
      ),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (availableTabs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(l10n.fillApiKeyFirstEnablesModels),
              )
            else
              _buildDropdownTile<LyricsAiProvider>(
                context: context,
                title: l10n.platform,
                value: effectiveProvider,
                options: availableTabs
                    .map(
                      (provider) => _DropdownOption<LyricsAiProvider>(
                        value: provider,
                        label: provider.displayName,
                        leading: _buildProviderIcon(provider),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (provider) {
                  if (provider == null) return;
                  setState(() {
                    _provider = provider;
                    _selection = LyricsAiModelSelection(
                      provider: provider,
                      modelId: '',
                    );
                    _searchQuery = '';
                    _searchController.clear();
                    _statusText = _statusTextByProvider[provider] ?? '';
                  });
                  _fetchModels();
                },
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: l10n.search,
                hintText: l10n.modelSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.clearSearch,
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_statusText.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _statusText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (_provider != LyricsAiProvider.deepseek &&
                      _provider != LyricsAiProvider.custom)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _showRecommendedOnly,
                            onChanged: (value) {
                              setState(() {
                                _showRecommendedOnly = value ?? true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showRecommendedOnly = !_showRecommendedOnly;
                            });
                          },
                          child: Text(l10n.showRecommendedOnly),
                        ),
                      ],
                    ),
                ],
              ),
            const SizedBox(height: 8),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 360),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: availableTabs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(l10n.noAvailableChannels),
                        ),
                      )
                    : _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _filteredModels.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(l10n.noMatchingModels),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          if (widget.slot == LyricsAiModelSlot.fallback)
                            RadioListTile<String>(
                              value: '',
                              groupValue: _selection.modelId,
                              title: Text(l10n.leaveEmpty),
                              subtitle: Text(l10n.leaveEmptyFallbackDescription),
                              onChanged: (value) {
                                setState(() {
                                  _selection = LyricsAiModelSelection(
                                    provider: _provider,
                                    modelId: value ?? '',
                                  );
                                });
                              },
                            ),
                          for (final model in _filteredModels)
                            RadioListTile<String>(
                              value: model.id,
                              groupValue: _selection.modelId,
                              title: Text(model.label),
                              subtitle: Text(
                                model.pricingLabel == null
                                    ? model.id
                                    : '${model.id}\n${model.pricingLabel}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selection = LyricsAiModelSelection(
                                    provider: _provider,
                                    modelId: value ?? '',
                                  );
                                });
                              },
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: canSave
              ? () => Navigator.of(context).pop(_selection)
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
