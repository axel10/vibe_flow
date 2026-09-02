import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/remote/remote_service_providers.dart';
import 'package:vynody/player/settings/settings_service.dart';
import '../widgets/settings_dropdown_tile.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class StorageSection extends ConsumerStatefulWidget {
  final SettingsService settings;

  const StorageSection({
    super.key,
    required this.settings,
  });

  @override
  ConsumerState<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends ConsumerState<StorageSection> {
  int? _remoteCacheSizeBytes;
  bool _isLoadingCacheSize = false;
  bool _isClearingRemoteCache = false;
  bool _isClearingWaveformCache = false;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    if (!mounted) return;
    setState(() {
      _isLoadingCacheSize = true;
    });
    try {
      final streamManager = ref.read(audioStreamCacheManagerProvider);
      final int size = await streamManager.getTotalCacheSize();
      if (mounted) {
        setState(() {
          _remoteCacheSizeBytes = size;
          _isLoadingCacheSize = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingCacheSize = false;
        });
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = widget.settings;

    final sizeStr = _isLoadingCacheSize
        ? '...'
        : _formatBytes(_remoteCacheSizeBytes ?? 0);

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SettingsSectionHeader(title: l10n.storageAndCache),
        SettingsGroupCard(
          title: l10n.remoteAudioCache,
          icon: Icons.cloud_download_outlined,
          children: [
            ListTile(
              title: Text(l10n.remoteAudioCache),
              subtitle: Text(
                '${l10n.remoteAudioCacheDescription}\n${l10n.remoteAudioCache}: $sizeStr',
              ),
              isThreeLine: true,
              trailing: FilledButton.tonal(
                onPressed: _isClearingRemoteCache
                    ? null
                    : () async {
                        setState(() {
                          _isClearingRemoteCache = true;
                        });
                        try {
                          final streamManager =
                              ref.read(audioStreamCacheManagerProvider);
                          await streamManager.clearCache();
                          await _loadCacheSize();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.remoteCacheCleared)),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isClearingRemoteCache = false;
                            });
                          }
                        }
                      },
                child: _isClearingRemoteCache
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.clear),
              ),
            ),
            SettingsDropdownTile<int>(
              title: l10n.remoteCacheLimit,
              value: settings.remoteCacheMaxSizeBytes,
              options: [
                SettingsDropdownOption(
                  value: 0,
                  label: l10n.unlimited,
                ),
                const SettingsDropdownOption(
                  value: 500 * 1024 * 1024,
                  label: '500 MB',
                ),
                const SettingsDropdownOption(
                  value: 1024 * 1024 * 1024,
                  label: '1 GB',
                ),
                const SettingsDropdownOption(
                  value: 2 * 1024 * 1024 * 1024,
                  label: '2 GB',
                ),
                const SettingsDropdownOption(
                  value: 5 * 1024 * 1024 * 1024,
                  label: '5 GB',
                ),
                const SettingsDropdownOption(
                  value: 10 * 1024 * 1024 * 1024,
                  label: '10 GB',
                ),
              ],
              onChanged: (value) async {
                if (value != null) {
                  settings.remoteCacheMaxSizeBytes = value;
                  final cacheManager =
                      ref.read(audioStreamCacheManagerProvider);
                  await cacheManager.pruneCacheIfNeeded(limitBytes: value);
                  await _loadCacheSize();
                }
              },
            ),
            SettingsDropdownTile<int>(
              title: l10n.remotePrefetchCount,
              subtitle: l10n.remotePrefetchCountDescription,
              value: settings.remotePrefetchCount,
              options: [
                SettingsDropdownOption(
                  value: 0,
                  label: l10n.off,
                ),
                const SettingsDropdownOption(
                  value: 1,
                  label: '1',
                ),
                const SettingsDropdownOption(
                  value: 2,
                  label: '2',
                ),
                const SettingsDropdownOption(
                  value: 3,
                  label: '3',
                ),
                const SettingsDropdownOption(
                  value: 5,
                  label: '5',
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settings.remotePrefetchCount = value;
                }
              },
            ),
          ],
        ),
        SettingsGroupCard(
          title: l10n.clearWaveformCache,
          icon: Icons.graphic_eq_rounded,
          children: [
            ListTile(
              title: Text(l10n.clearWaveformCache),
              subtitle: Text(l10n.clearWaveformCacheDescription),
              trailing: FilledButton.tonal(
                onPressed: _isClearingWaveformCache
                    ? null
                    : () async {
                        setState(() {
                          _isClearingWaveformCache = true;
                        });
                        try {
                          final audio = ref.read(audioServiceProvider);
                          await audio.clearWaveformCache();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l10n.waveformCacheCleared)),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isClearingWaveformCache = false;
                            });
                          }
                        }
                      },
                child: _isClearingWaveformCache
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.clear),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
