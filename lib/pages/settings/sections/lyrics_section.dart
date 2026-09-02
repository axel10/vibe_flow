import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/dialogs/ai_guide_dialog.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/lyrics/lyrics_cache_models.dart';
import 'package:vynody/player/lyrics/lyrics_cache_repository.dart';
import 'package:vynody/player/lyrics/lyrics_import_export_service.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/utils/file_selector_helper.dart';
import 'package:vynody/utils/language_code_utils.dart';
import 'package:vynody/widgets/lyrics_provider_icon.dart';
import '../dialogs/custom_provider_config_dialog.dart';
import '../dialogs/lyrics_model_picker_dialog.dart';
import '../widgets/settings_dropdown_tile.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class LyricsSection extends ConsumerWidget {
  final SettingsService settings;

  const LyricsSection({
    super.key,
    required this.settings,
  });

  Widget _buildProviderIcon(LyricsAiProvider provider) {
    return LyricsProviderIcon(provider: provider, size: 24);
  }

  String _translationLanguageLabel(BuildContext context, String languageCode) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = LanguageCodeUtils.normalizeLanguageCode(languageCode);
    if (normalized.isEmpty) {
      return l10n.followSystemLanguage;
    }
    return LanguageCodeUtils.languageDisplayName(normalized);
  }

  Widget _buildLyricsTranslationLanguageSection(
    BuildContext context,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final value = settings.lyricsTranslationTargetLanguageCode;
    final targetValue = value.isEmpty ? '' : value;

    final options = <SettingsDropdownOption<String>>[
      SettingsDropdownOption<String>(
        value: '',
        label: l10n.followSystemLanguage,
      ),
      ...LanguageCodeUtils.supportedTranslationLanguageCodes.map(
        (languageCode) => SettingsDropdownOption<String>(
          value: languageCode,
          label: _translationLanguageLabel(context, languageCode),
        ),
      ),
    ];

    return SettingsDropdownTile<String>(
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
    return SettingsDropdownTile<LyricsSaveMethod>(
      title: l10n.lyricsSaveMethodLabel,
      subtitle: l10n.lyricsSaveMethodDescription,
      value: settings.lyricsSaveMethod,
      options: [
        SettingsDropdownOption<LyricsSaveMethod>(
          value: LyricsSaveMethod.original,
          label: l10n.lyricsSaveMethodOriginal,
        ),
        SettingsDropdownOption<LyricsSaveMethod>(
          value: LyricsSaveMethod.embedded,
          label: l10n.lyricsSaveMethodEmbedded,
        ),
        SettingsDropdownOption<LyricsSaveMethod>(
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
    return SettingsDropdownTile<LyricsStyle>(
      title: l10n.lyricsStyleLabel,
      subtitle: l10n.lyricsStyleDescription,
      value: settings.lyricsStyle,
      options: [
        SettingsDropdownOption<LyricsStyle>(
          value: LyricsStyle.traditional,
          label: l10n.lyricsStyleTraditional,
        ),
        SettingsDropdownOption<LyricsStyle>(
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

      final parsed = jsonDecode(jsonStr);
      if (parsed is! Map || !parsed.containsKey('lyricsCaches')) {
        throw Exception(l10n.invalidBackupFile);
      }

      final service = const LyricsImportExportService();
      final repository = LyricsCacheRepository();

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
      Navigator.of(context).pop();

      if (result.conflicts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importSuccess(result.autoImportedCount))),
        );
        return;
      }

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

        if (!context.mounted) return;
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
          break;
        }
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

  Future<void> _selectLyricsModel({
    required BuildContext context,
    required WidgetRef ref,
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
        return LyricsModelPickerDialog(
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

  Widget _buildLyricsModelSection(
    BuildContext context,
    WidgetRef ref,
    SettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
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
            context: context,
            ref: ref,
            settings: settings,
            purpose: LyricsAiModelPurpose.generation,
            slot: LyricsAiModelSlot.primary,
          ),
          onFallbackTap: () => _selectLyricsModel(
            context: context,
            ref: ref,
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
            context: context,
            ref: ref,
            settings: settings,
            purpose: LyricsAiModelPurpose.translation,
            slot: LyricsAiModelSlot.primary,
          ),
          onFallbackTap: () => _selectLyricsModel(
            context: context,
            ref: ref,
            settings: settings,
            purpose: LyricsAiModelPurpose.translation,
            slot: LyricsAiModelSlot.fallback,
          ),
        ),
      ],
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
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final hasAnyProvider = settings.hasAnyLyricsModelProvider;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SettingsSectionHeader(
          title: l10n.lyricsSectionTitle,
          description: l10n.lyricsSectionDescription,
        ),
        SettingsGroupCard(
          title: l10n.lyricsSectionTitle,
          icon: Icons.tune_rounded,
          children: [
            _buildLyricsTranslationLanguageSection(context, settings),
            _buildLyricsSaveMethodSection(context, settings),
            _buildLyricsStyleSection(context, settings),
          ],
        ),
        SettingsGroupCard(
          title: l10n.lyricsImportExportHeader,
          icon: Icons.import_export_rounded,
          children: [
            _buildLyricsImportExportSection(context, settings),
          ],
        ),
        SettingsGroupCard(
          title: l10n.platformApiKeysSectionTitle,
          icon: Icons.key_rounded,
          children: [
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
          ],
        ),
        SettingsGroupCard(
          title: l10n.geminiModelsSectionTitle,
          icon: Icons.psychology_outlined,
          children: [
            if (!hasAnyProvider)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Text(
                  l10n.fillApiKeyFirstEnablesModels,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: _buildLyricsModelSection(context, ref, settings),
              ),
          ],
        ),
      ],
    );
  }
}
