import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/ai/lyrics_model_catalog_service.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/widgets/lyrics_provider_icon.dart';
import '../widgets/settings_dropdown_tile.dart';

class LyricsModelPickerDialog extends ConsumerStatefulWidget {
  const LyricsModelPickerDialog({
    super.key,
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
  ConsumerState<LyricsModelPickerDialog> createState() =>
      _LyricsModelPickerDialogState();
}

class _LyricsModelPickerDialogState
    extends ConsumerState<LyricsModelPickerDialog> {
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
              SettingsDropdownTile<LyricsAiProvider>(
                title: l10n.platform,
                value: effectiveProvider,
                options: availableTabs
                    .map(
                      (provider) => SettingsDropdownOption<LyricsAiProvider>(
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
