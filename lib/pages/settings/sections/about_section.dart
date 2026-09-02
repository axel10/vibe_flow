import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vynody/dialogs/upgrade_to_pro_dialog.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/pro/app_channel.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/utils/app_log.dart';
import 'package:vynody/utils/file_selector_helper.dart';
import 'package:vynody/widgets/pro/pro_badge.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_section_header.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  String _appVersion = '';
  bool _isCheckingUpdates = false;
  bool _isExportingLogs = false;

  static const String _appStoreId = String.fromEnvironment(
    'APP_STORE_ID',
    defaultValue: '6799339894',
  );

  @override
  void initState() {
    super.initState();
    _loadVersion();
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

  Future<void> _checkForUpdates() async {
    final bool isAppleStore =
        Platform.isIOS || (Platform.isMacOS && AppChannel.isStoreRelease);
    if (isAppleStore) {
      final storeUri = Uri.parse('https://apps.apple.com/app/id$_appStoreId');
      try {
        if (await canLaunchUrl(storeUri)) {
          await launchUrl(storeUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Failed to open App Store: $e');
      }
      return;
    }

    if (Platform.isWindows && AppChannel.isStoreRelease) {
      final storeUri = Uri.parse(
        'ms-windows-store://pdp/?productid=${ProConfig.msStoreProductId}',
      );
      try {
        if (await canLaunchUrl(storeUri)) {
          await launchUrl(storeUri, mode: LaunchMode.externalApplication);
        } else {
          final webUri = Uri.parse(
            'https://apps.microsoft.com/detail/${ProConfig.msStoreProductId}',
          );
          if (await canLaunchUrl(webUri)) {
            await launchUrl(webUri, mode: LaunchMode.externalApplication);
          }
        }
      } catch (e) {
        debugPrint('Failed to open Microsoft Store: $e');
      }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SettingsSectionHeader(
          title: l10n.about,
          description: l10n.aboutSectionDescription,
        ),
        SettingsGroupCard(
          title: l10n.about,
          icon: Icons.info_outline_rounded,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Vynody ${_appVersion.isEmpty ? "" : "v$_appVersion"}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (!AppChannel.isGitHubRelease) ...[
                        const SizedBox(width: 8),
                        const ProBadge(),
                      ],
                    ],
                  ),
                  if (!AppChannel.isGitHubRelease) ...[
                    const SizedBox(height: 12),
                    Consumer(
                      builder: (context, ref, _) {
                        final license = ref.watch(licenseStateProvider);
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                size: 22,
                                color: Color(0xFFFFB300),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      license.isInTrial
                                          ? l10n.proStatusTrialTitle(license.trialTotalDays)
                                          : (license.isTrialExpired
                                              ? l10n.proStatusTrialExpiredTitle
                                              : l10n.proStatusActivatedTitle),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      license.isInTrial
                                          ? l10n.proSettingsTrialRemaining(license.trialDaysRemaining)
                                          : (license.isTrialExpired
                                              ? l10n.proSettingsUpgradePrompt
                                              : l10n.proSettingsLifetimeNotice),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => showUpgradeToProDialog(context),
                                icon: const Icon(Icons.info_outline, size: 16),
                                label: Text(
                                  license.isTrialExpired ? l10n.proSettingsUpgrade : l10n.proSettingsView,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (AppChannel.isGitHubRelease) ...[
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
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
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
                      TextButton.icon(
                        onPressed: _isExportingLogs ? null : _exportLogs,
                        icon: _isExportingLogs
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.description_outlined, size: 18),
                        label: Text(l10n.exportLogs),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
