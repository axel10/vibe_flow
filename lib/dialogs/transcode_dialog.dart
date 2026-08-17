import 'dart:async';
import 'dart:io';

import 'package:audio_core/audio_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';
import '../widgets/song_thumbnail.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import '../transcode/transcode_models.dart';
import '../transcode/transcode_preset.dart';
import '../transcode/transcode_riverpod.dart';
import '../transcode/transcode_service.dart';
import 'package:vynody/dialogs/upgrade_to_pro_dialog.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/pro/pro_models.dart';
import 'package:vynody/utils/app_snack_bar.dart';
import 'package:vynody/utils/song_context_menu_utils.dart';
import 'package:vynody/widgets/pro/pro_badge.dart';

class TranscodeSubmitSummary {
  const TranscodeSubmitSummary({
    required this.successCount,
    required this.failureCount,
    required this.outputPaths,
    this.firstOutputPath,
    this.lastErrorMessage,
  });

  final int successCount;
  final int failureCount;
  final List<String> outputPaths;
  final String? firstOutputPath;
  final String? lastErrorMessage;
}

Future<void> showTranscodeDialog(
  BuildContext context, {
  required List<MusicFile> songs,
}) async {
  if (songs.isEmpty) {
    return;
  }

  final container = ProviderScope.containerOf(context, listen: false);
  final isUnlocked = container.read(isProUnlockedProvider);
  if (!isUnlocked) {
    if (context.mounted) {
      await showUpgradeToProDialog(
        context,
        initialFeature: ProFeature.transcoder,
      );
    }
    return;
  }

  final summary = await showModalBottomSheet<TranscodeSubmitSummary>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TranscodeDialog(songs: songs),
  );

  if (summary == null || !context.mounted) {
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  final scanner = ProviderScope.containerOf(context, listen: false)
      .read(scannerServiceProvider);

  if (summary.successCount > 0 && summary.outputPaths.isNotEmpty) {
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      await scanner.refreshMetadataForPaths(summary.outputPaths);
    } catch (error) {
      debugPrint('[Transcode] Failed to refresh transcoded outputs: $error');
    }
  }

  if (!context.mounted) {
    return;
  }

  final total = summary.successCount + summary.failureCount;
  final message = summary.failureCount == 0
      ? l10n.transcodeCompletedCount(summary.successCount)
      : l10n.transcodeCompletedWithFailures(
          summary.successCount,
          total,
          summary.failureCount,
        );

  AppSnackBar.show(
    context,
    null,
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 4),
      persist: false,
      action:
          summary.firstOutputPath != null &&
              (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
          ? SnackBarAction(
              label: l10n.openFileLocation,
              onPressed: () {
                unawaited(openSongFileLocation(summary.firstOutputPath!));
              },
            )
          : null,
    ),
  );

  if (summary.failureCount > 0 && summary.lastErrorMessage != null) {
    AppSnackBar.show(
      context,
      null,
      SnackBar(
        content: Text(summary.lastErrorMessage!),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class TranscodeDialog extends ConsumerStatefulWidget {
  const TranscodeDialog({super.key, required this.songs});

  final List<MusicFile> songs;

  @override
  ConsumerState<TranscodeDialog> createState() => _TranscodeDialogState();
}

class _TranscodeDialogState extends ConsumerState<TranscodeDialog> {
  final TranscodePresetResolver _presetResolver =
      const TranscodePresetResolver();

  ConverterCapabilities? _capabilities;
  late TranscodeDraft _draft;
  bool _isLoadingCapabilities = true;
  bool _isSubmitting = false;
  double? _currentFileProgress;
  double? _overallProgress;
  String? _submitLabel;
  String? _currentFileLabel;
  String? _errorText;
  AndroidOutputDirectory? _androidOutputDirectory;

  bool get _supportsBitRateControls =>
      _draft.outputFormat.supportsBitRateControls;

  bool get _isLosslessPresetlessFormat => !_supportsBitRateControls;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    final preset = _presetResolver.resolve(
      outputFormat: settings.transcodeDefaultFormat,
      qualityTier: settings.transcodeDefaultQualityTier,
    );
    final defaultAacEncoder = (Platform.isWindows || Platform.isLinux)
        ? AacEncoder.fdkaac
        : AacEncoder.ffmpeg;
    _draft = TranscodeDraft(
      outputFormat: preset.outputFormat,
      qualityTier: preset.qualityTier,
      bitRate: preset.bitRate,
      bitRateMode: preset.bitRateMode,
      sampleRate: preset.sampleRate,
      channels: preset.channels,
      valueOrigin: TranscodeValueOrigin.presetDerived,
      outputDirectory: _initialOutputDirectory(),
      useSystemEncoder: false,
      aacEncoder: defaultAacEncoder,
    );
    unawaited(_loadCapabilities());
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _initialOutputDirectory() {
    return File(widget.songs.first.path).parent.path;
  }

  Future<void> _loadCapabilities() async {
    try {
      final capabilities = await ref
          .read(transcodeServiceProvider)
          .getCapabilities();
      if (!mounted) return;
      final supported = capabilities.supportedOutputFormats;
      setState(() {
        _capabilities = capabilities;
        _isLoadingCapabilities = false;
        if (supported.isNotEmpty && !supported.contains(_draft.outputFormat)) {
          _resetDraftForPreset(
            outputFormat: supported.first,
            qualityTier: _draft.qualityTier,
          );
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingCapabilities = false;
        _errorText = error.toString();
      });
    }
  }

  List<AudioFormat> get _formatOptions {
    final supported = _capabilities?.supportedOutputFormats;
    if (supported == null || supported.isEmpty) {
      return AudioFormat.values;
    }
    return supported;
  }

  void _resetDraftForPreset({
    AudioFormat? outputFormat,
    TranscodeQualityTier? qualityTier,
  }) {
    final nextFormat = outputFormat ?? _draft.outputFormat;
    final nextTier = qualityTier ?? _draft.qualityTier;
    final resolved = _presetResolver.resolve(
      outputFormat: nextFormat,
      qualityTier: nextTier,
    );
    final defaultAacEncoder = (Platform.isWindows || Platform.isLinux)
        ? AacEncoder.fdkaac
        : AacEncoder.ffmpeg;
    setState(() {
      _draft = _draft.copyWith(
        outputFormat: nextFormat,
        qualityTier: nextTier,
        bitRate: resolved.bitRate,
        bitRateMode: resolved.bitRateMode,
        sampleRate: resolved.sampleRate,
        channels: resolved.channels,
        valueOrigin: TranscodeValueOrigin.presetDerived,
        useSystemEncoder: false,
        aacEncoder: defaultAacEncoder,
      );
      _errorText = null;
    });
  }

  void _markCustomized({
    int? bitRate,
    BitRateMode? bitRateMode,
    bool? useSystemEncoder,
    AacEncoder? aacEncoder,
  }) {
    setState(() {
      _draft = _draft.copyWith(
        bitRate: bitRate,
        bitRateMode: bitRateMode,
        useSystemEncoder: useSystemEncoder,
        aacEncoder: aacEncoder,
        valueOrigin: TranscodeValueOrigin.customized,
      );
      _errorText = null;
    });
  }

  Future<void> _pickOutputDirectory() async {
    if (Platform.isAndroid) {
      final selected = await ref
          .read(transcodeServiceProvider)
          .pickAndroidOutputDirectory();
      if (selected == null || !mounted) return;
      setState(() {
        _androidOutputDirectory = selected;
        _draft = _draft.copyWith(outputDirectory: selected.displayPath);
      });
      return;
    }

    final selected = await ref
        .read(transcodeServiceProvider)
        .pickOutputDirectory();
    if (selected == null || !mounted) return;
    setState(() {
      _draft = _draft.copyWith(outputDirectory: selected);
    });
  }

  String _previewOutputPath() {
    if (Platform.isAndroid) {
      final selected = _androidOutputDirectory;
      if (selected == null) {
        return '';
      }
      final baseName = p.basenameWithoutExtension(widget.songs.first.path);
      return p.join(
        selected.displayPath,
        '$baseName.${_draft.outputFormat.value}',
      );
    }

    return ref
        .read(transcodeServiceProvider)
        .buildPreviewOutputPath(
          inputPath: widget.songs.first.path,
          outputFormat: _draft.outputFormat,
          outputDirectory: _draft.outputDirectory,
        );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final allowed = await checkProGate(
      context,
      ref,
      feature: ProFeature.transcoder,
    );
    if (!allowed) return;

    final l10n = AppLocalizations.of(context)!;
    if (Platform.isAndroid && _androidOutputDirectory == null) {
      setState(() {
        _errorText = l10n.chooseAndroidOutputDirectoryFirst;
      });
      return;
    }

    final service = ref.read(transcodeServiceProvider);
    final draft = _draft;

    setState(() {
      _isSubmitting = true;
      _currentFileProgress = 0;
      _overallProgress = 0;
      _submitLabel = l10n.transcodePreparing;
      _currentFileLabel = null;
      _errorText = null;
    });

    final songPaths = widget.songs.map((s) => s.path).toList();
    final metadataPaths = widget.songs
        .map((s) => TranscodeService.resolveMetadataSourcePath(s))
        .toList();

    var successCount = 0;
    var failureCount = 0;
    String? firstOutputPath;
    String? lastErrorMessage;
    final outputPaths = <String>[];

    try {
      final results = await service.convertMultipleToOutputDirectory(
        inputPaths: songPaths,
        draft: draft,
        androidOutputDirectory: _androidOutputDirectory,
        metadataSourcePaths: metadataPaths,
        onProgress: (progress) {
          if (!mounted) return;
          final currentNumber = (progress.completedFiles + 1).clamp(
            1,
            progress.totalFiles,
          );
          setState(() {
            _currentFileProgress = progress.currentFileProgress;
            _overallProgress = progress.overallProgress;
            _submitLabel =
                progress.message ??
                l10n.transcodeProgress(currentNumber, progress.totalFiles);
            _currentFileLabel = p.basename(progress.currentFilePath);
          });
        },
      );

      for (final executionResult in results) {
        if (executionResult.result.success) {
          successCount += 1;
          final outputPath =
              executionResult.result.outputPath ??
              executionResult.plannedOutputPath;
          firstOutputPath ??= outputPath;
          outputPaths.add(outputPath);
        } else {
          failureCount += 1;
          lastErrorMessage =
              executionResult.result.errorMessage ??
              l10n.transcodeFailedGeneric;
          debugPrint(lastErrorMessage);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorText = error.toString();
          _isSubmitting = false;
        });
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(
      TranscodeSubmitSummary(
        successCount: successCount,
        failureCount: failureCount,
        outputPaths: outputPaths,
        firstOutputPath: firstOutputPath,
        lastErrorMessage: lastErrorMessage,
      ),
    );
  }

  String _qualityLabel(AppLocalizations l10n, TranscodeQualityTier tier) {
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
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.transcodeTitle,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const ProBadge(),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.songs.length == 1
                                  ? p.basename(widget.songs.first.path)
                                  : l10n.transcodeSongCount(
                                      widget.songs.length,
                                    ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    children: [
                      _buildFilesList(l10n),
                      const SizedBox(height: 16),
                      _buildFormatSection(l10n),
                      const SizedBox(height: 16),
                      _buildQualitySection(l10n),
                      const SizedBox(height: 16),
                      _buildAdvancedSection(l10n),
                      const SizedBox(height: 16),
                      _buildOutputSection(l10n),
                      if (_errorText != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorText!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_isSubmitting)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _currentFileLabel == null
                              ? (_submitLabel ?? l10n.transcodePreparing)
                              : '${_submitLabel ?? l10n.transcodePreparing} · $_currentFileLabel',
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _currentFileProgress,
                          minHeight: 8,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currentFileProgress == null
                              ? l10n.transcodePreparing
                              : l10n.currentSongProgressPercent((( _currentFileProgress! * 100).clamp(0, 100)).toStringAsFixed(1)),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _overallProgress,
                          minHeight: 8,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _overallProgress == null
                              ? l10n.transcodePreparing
                              : l10n.overallProgressPercent((( _overallProgress! * 100).clamp(0, 100)).toStringAsFixed(1)),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: FilledButton.icon(
                    onPressed: _isLoadingCapabilities || _isSubmitting
                        ? null
                        : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_alt_rounded),
                    label: Text(
                      _isSubmitting ? l10n.transcoding : l10n.startTranscode,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilesList(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final titleText = l10n.filesToTranscode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleText,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 160),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: widget.songs.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 60,
                endIndent: 16,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final song = widget.songs[index];
                final ext = p
                    .extension(song.path)
                    .replaceAll('.', '')
                    .toUpperCase();
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: SongThumbnail(
                    path: song.path,
                    id: song.id,
                    size: 36,
                  ),
                  title: Text(
                    song.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    song.artist ?? l10n.unknownArtist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ext,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSection(AppLocalizations l10n) {
    return DropdownButtonFormField<AudioFormat>(
      initialValue: _draft.outputFormat,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.transcodeFormat,
        border: const OutlineInputBorder(),
      ),
      items: _formatOptions
          .map(
            (format) => DropdownMenuItem<AudioFormat>(
              value: format,
              child: Text(format.displayName),
            ),
          )
          .toList(growable: false),
      onChanged: _isSubmitting
          ? null
          : (value) {
              if (value == null) return;
              _resetDraftForPreset(
                outputFormat: value,
                qualityTier: _draft.qualityTier,
              );
            },
    );
  }

  Widget _buildQualitySection(AppLocalizations l10n) {
    if (_isLosslessPresetlessFormat) {
      return _buildDisabledQualitySection(l10n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.transcodeQualityPreset),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: TranscodeQualityTier.values
              .map((tier) {
                final selected = _draft.qualityTier == tier;
                return ChoiceChip(
                  label: Text(_qualityLabel(l10n, tier)),
                  selected: selected,
                  onSelected: _isSubmitting
                      ? null
                      : (_) {
                          _resetDraftForPreset(
                            outputFormat: _draft.outputFormat,
                            qualityTier: tier,
                          );
                        },
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }

  Widget _buildDisabledQualitySection(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.transcodeQualityPreset,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.transcodeLosslessPresetHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(AppLocalizations l10n) {
    final hasAacEncoder =
        _supportsBitRateControls &&
        !_draft.useSystemEncoder &&
        !(Platform.isIOS || Platform.isMacOS);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.transcodeAdvancedOptions),
          subtitle: Text(
            _isLosslessPresetlessFormat
                ? l10n.transcodeLosslessAdvancedHint
                : (_draft.isCustomized
                      ? l10n.transcodeAdvancedCustomized
                      : l10n.transcodeAdvancedFollowingPreset),
          ),
          value: _draft.showAdvancedOptions,
          onChanged: _isSubmitting
              ? null
              : (value) {
                  setState(() {
                    _draft = _draft.copyWith(showAdvancedOptions: value);
                  });
                },
        ),
        if (_draft.showAdvancedOptions) ...[
          if (_supportsBitRateControls) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              initialValue:
                  [128000, 192000, 256000, 320000].contains(_draft.bitRate)
                  ? _draft.bitRate
                  : 192000,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.transcodeBitRate,
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 128000, child: Text('128 kbps')),
                DropdownMenuItem(value: 192000, child: Text('192 kbps')),
                DropdownMenuItem(value: 256000, child: Text('256 kbps')),
                DropdownMenuItem(value: 320000, child: Text('320 kbps')),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value == null) return;
                      _markCustomized(bitRate: value);
                    },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BitRateMode>(
              initialValue: _draft.bitRateMode,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.transcodeBitRateMode,
                border: const OutlineInputBorder(),
              ),
              items: BitRateMode.values
                  .map(
                    (mode) => DropdownMenuItem<BitRateMode>(
                      value: mode,
                      child: Text(mode == BitRateMode.cbr ? 'CBR' : 'VBR'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value == null) return;
                      _markCustomized(bitRateMode: value);
                    },
            ),
            if (Platform.isAndroid &&
                _draft.outputFormat == AudioFormat.m4a) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<bool>(
                initialValue: _draft.useSystemEncoder,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.transcodeEncodingEngine,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: false,
                    child: Text(l10n.transcodeFfmpegRustEncoder),
                  ),
                  DropdownMenuItem(
                    value: true,
                    child: Text(l10n.transcodeSystemEncoder),
                  ),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        _markCustomized(useSystemEncoder: value);
                      },
              ),
            ],
            if (hasAacEncoder &&
                (_draft.outputFormat == AudioFormat.aac ||
                    _draft.outputFormat == AudioFormat.m4a ||
                    _draft.outputFormat == AudioFormat.m4b ||
                    _draft.outputFormat == AudioFormat.caf)) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<AacEncoder>(
                initialValue: _draft.aacEncoder,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.transcodeAacEncoder,
                  border: const OutlineInputBorder(),
                ),
                items: AacEncoder.values
                    .map(
                      (enc) => DropdownMenuItem<AacEncoder>(
                        value: enc,
                        child: Text(enc.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        _markCustomized(aacEncoder: value);
                      },
              ),
            ],
            const SizedBox(height: 12),
          ],

          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      _resetDraftForPreset();
                    },
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(
                _supportsBitRateControls
                    ? l10n.transcodeResetToPreset
                    : l10n.transcodeResetLosslessOptions,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOutputSection(AppLocalizations l10n) {
    final outputDirectory = Platform.isAndroid
        ? _androidOutputDirectory?.displayPath
        : (_draft.outputDirectory ?? _initialOutputDirectory());
    final preview = _previewOutputPath();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.transcodeOutputDirectory,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        SelectableText(
          outputDirectory ?? 'Not selected',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        Text(
          outputDirectory == null
              ? l10n.pleaseChooseOutputDirectory
              : '${l10n.transcodeOutputPreview}: $preview',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _pickOutputDirectory,
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(l10n.transcodeChooseDirectory),
            ),
            OutlinedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        if (Platform.isAndroid) {
                          _androidOutputDirectory = null;
                          _draft = _draft.copyWith(outputDirectory: null);
                        } else {
                          _draft = _draft.copyWith(
                            outputDirectory: _initialOutputDirectory(),
                          );
                        }
                      });
                    },
              icon: const Icon(Icons.undo_rounded),
              label: Text(l10n.transcodeUseSourceDirectory),
            ),
          ],
        ),
      ],
    );
  }
}
