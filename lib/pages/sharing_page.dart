import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import '../utils/file_selector_helper.dart';
import 'package:path/path.dart' as p;
import 'package:vynody/player/library/music_file_utils.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/player/sharing/sharing_service.dart';
import 'package:vynody/player/sharing/lan_device.dart';
import 'package:vynody/dialogs/transfer_dialogs.dart';
import 'package:vynody/transcode/transcode_riverpod.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vynody/l10n/app_localizations.dart';
import '../utils/song_context_menu_utils.dart';

class SharingPage extends ConsumerStatefulWidget {
  const SharingPage({super.key});

  @override
  ConsumerState<SharingPage> createState() => _SharingPageState();
}

class _SharingPageState extends ConsumerState<SharingPage> {
  late final SharingServerStateNotifier _sharingServerNotifier;
  bool _didSyncInitialSharingState = false;
  final Set<String> _shownDialogSessionIds = {};

  Future<String?> _getDirectoryPath() {
    return FileSelectorHelper.pickDirectory(lockParentWindow: false);
  }

  Future<void> _handleOpenReceiveDirectory() async {
    final settings = ref.read(settingsServiceProvider);
    final folderPath = settings.lanSharingFolderPath.isNotEmpty
        ? settings.lanSharingFolderPath
        : ref.read(sharingServiceProvider).sharingFolderPath;

    if (folderPath.isNotEmpty) {
      final dir = Directory(folderPath);
      if (!dir.existsSync()) {
        try {
          await dir.create(recursive: true);
        } catch (e) {
          debugPrint('[SharingPage] Could not create receive folder: $e');
        }
      }
      await openFolderLocation(folderPath);
    }
  }

  @override
  void initState() {
    super.initState();
    _sharingServerNotifier = ref.read(sharingServerStateProvider.notifier);
  }

  @override
  void dispose() {
    // Auto-stop server when page is closed/destroyed
    // Since this is a tab page, we want it to stop when user navigates away or it's unmounted.
    // However, if we want it to run only during this page session:
    // To ensure the server stops when we exit, we stop it in dispose.
    Future.microtask(() {
      _sharingServerNotifier.stop();
    });
    super.dispose();
  }

  Future<void> _handleSendFiles(LanDevice device) async {
    try {
      final filePaths = await FileSelectorHelper.pickFiles(
        label: 'Audio Files',
        extensions: const ['mp3', 'wav', 'flac', 'm4a', 'aac', 'ogg'],
        fileType: FileType.audio,
      );

      if (filePaths == null || filePaths.isEmpty) {
        return;
      }

      // We need to trigger the progress dialog on our screen
      // Final upload token/session ID will be created inside the sending function
      // In sharing_service, sendFiles generates a session ID starting with 'send_'.
      // We can compute the expected session ID or let sharing_service notify us.
      // Better yet, we can listen for new active transfer sessions in state
      // and show the progress dialog. Let's start the file transfer:
      final service = ref.read(sharingServiceProvider);

      // Let's launch transfer in background, and show progress dialog
      // To show the progress dialog immediately, we can listen to activeTransfersProvider.
      // But we need the sessionId. Since the sessionId is derived from timestamp inside sendFiles,
      // let's modify sendFiles slightly or just search for the latest session in activeTransfersProvider.

      // Let's create a listener to catch the session ID as soon as it's added.
      late ProviderSubscription subscription;
      subscription = ref.listenManual(activeTransfersProvider, (
        previous,
        next,
      ) {
        final newSendSession = next.firstWhere(
          (s) =>
              s.isSending &&
              s.deviceName == device.name &&
              s.status == TransferStatus.pending,
          orElse: () => TransferSession(
            id: '',
            fileName: '',
            totalBytes: 0,
            bytesTransferred: 0,
            isSending: true,
            deviceName: '',
            status: TransferStatus.failed,
            filesCount: 0,
            completedFilesCount: 0,
          ),
        );
        if (newSendSession.id.isNotEmpty) {
          subscription.close();
          showTransferProgressDialog(context, newSendSession.id);
        }
      });

      final success = await service.sendFiles(
        targetDevice: device,
        filePaths: filePaths,
      );
      if (!success) {
        // In case preflight fails immediately
        subscription.close();
      }
    } catch (e) {
      showToast(AppLocalizations.of(context)!.sendFilesFailed(e.toString()));
    }
  }

  Future<void> _handleSendFolder(LanDevice device) async {
    try {
      final dirPath = await _getDirectoryPath();

      if (dirPath == null) {
        return;
      }

      showToast(AppLocalizations.of(context)!.scanningFolderMusic);

      final dir = Directory(dirPath);
      final List<String> musicFiles = [];

      try {
        final entries = dir.listSync(recursive: true);
        for (final entry in entries) {
          if (entry is File && MusicFileUtils.isMusicFilePath(entry.path)) {
            musicFiles.add(entry.path);
          }
        }
      } catch (e) {
        showToast(AppLocalizations.of(context)!.scanFolderFailed(e.toString()));
        return;
      }

      if (musicFiles.isEmpty) {
        showToast(AppLocalizations.of(context)!.noMusicFilesFound);
        return;
      }

      final parentPath = p.dirname(dirPath);
      final service = ref.read(sharingServiceProvider);

      late ProviderSubscription subscription;
      subscription = ref.listenManual(activeTransfersProvider, (
        previous,
        next,
      ) {
        final newSendSession = next.firstWhere(
          (s) =>
              s.isSending &&
              s.deviceName == device.name &&
              s.status == TransferStatus.pending,
          orElse: () => TransferSession(
            id: '',
            fileName: '',
            totalBytes: 0,
            bytesTransferred: 0,
            isSending: true,
            deviceName: '',
            status: TransferStatus.failed,
            filesCount: 0,
            completedFilesCount: 0,
          ),
        );
        if (newSendSession.id.isNotEmpty) {
          subscription.close();
          showTransferProgressDialog(context, newSendSession.id);
        }
      });

      final success = await service.sendFiles(
        targetDevice: device,
        filePaths: musicFiles,
        baseSourcePath: parentPath,
      );

      if (!success) {
        subscription.close();
      }
    } catch (e) {
      showToast(AppLocalizations.of(context)!.sendFolderFailed(e.toString()));
    }
  }

  Future<void> _showLocalNetworkPermissionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final isApple = Platform.isIOS || Platform.isMacOS;
    final title = l10n.localNetworkPermissionDeniedTitle;
    final message = isApple
        ? l10n.localNetworkPermissionDeniedMessage
        : l10n.localNetworkPermissionWindowsMessage;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.network_locked_rounded,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.closeButton),
            ),
            if (Platform.isIOS)
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await openAppSettings();
                },
                child: Text(l10n.openSettingsButton),
              ),
          ],
        );
      },
    );
  }

  Future<void> _setSharingEnabled(bool enabled) async {
    final settings = ref.read(settingsServiceProvider);
    final previousEnabled = settings.lanSharingEnabled;

    if (enabled && (Platform.isIOS || Platform.isMacOS || Platform.isWindows)) {
      final hasPermission = await ref
          .read(sharingServiceProvider)
          .checkLocalNetworkPermission();
      if (!hasPermission) {
        if (mounted) {
          await _showLocalNetworkPermissionDialog();
        }
        return;
      }
    }

    settings.lanSharingEnabled = enabled;

    if (enabled) {
      await _sharingServerNotifier.start();
      if (!mounted) return;
      final serverState = ref.read(sharingServerStateProvider);
      if (!serverState.isRunning) {
        settings.lanSharingEnabled = previousEnabled;
        showToast(AppLocalizations.of(context)!.lanSharingStartFailed);
      }
    } else {
      await _sharingServerNotifier.stop();
    }
  }

  Future<void> _handleSyncLyricsToDevice(LanDevice device) async {
    try {
      showToast(
        AppLocalizations.of(context)!.syncingLyricsToDevice(device.name),
      );
      final service = ref.read(sharingServiceProvider);
      final stats = await service.syncLyricsToDevice(device);
      showToast(
        AppLocalizations.of(context)!.syncLyricsSuccess(
          '${stats['matched']}',
          '${stats['overwritten']}',
          '${stats['skipped']}',
        ),
      );
    } catch (e) {
      final errorMsg = e.toString().contains('rejected')
          ? AppLocalizations.of(context)!.lyricsRequestRejected
          : e.toString();
      showToast(AppLocalizations.of(context)!.syncLyricsFailed(errorMsg));
    }
  }

  Future<void> _handleSyncLyricsFromDevice(LanDevice device) async {
    try {
      showToast(
        AppLocalizations.of(context)!.syncingLyricsFromDevice(device.name),
      );
      final service = ref.read(sharingServiceProvider);
      final stats = await service.pullLyricsFromDevice(device);
      showToast(
        AppLocalizations.of(context)!.syncLyricsSuccess(
          '${stats['matched']}',
          '${stats['overwritten']}',
          '${stats['skipped']}',
        ),
      );
    } catch (e) {
      final errorMsg = e.toString().contains('rejected')
          ? AppLocalizations.of(context)!.lyricsRequestRejected
          : e.toString();
      showToast(AppLocalizations.of(context)!.syncLyricsFailed(errorMsg));
    }
  }

  IconData _getPlatformIcon(String type) {
    switch (type.toLowerCase()) {
      case 'macos':
      case 'ios':
        return Icons.apple;
      case 'windows':
        return Icons.laptop_windows;
      case 'android':
        return Icons.phone_android;
      case 'linux':
        return Icons.terminal;
      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serverState = ref.watch(sharingServerStateProvider);
    final devicesAsync = ref.watch(discoveredDevicesProvider);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsServiceProvider);

    if (!_didSyncInitialSharingState) {
      _didSyncInitialSharingState = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (settings.lanSharingEnabled && !serverState.isRunning) {
          _sharingServerNotifier.start();
        }
      });
    }

    ref.listen(activeTransfersProvider, (previous, next) {
      for (final session in next) {
        if (!session.isSending &&
            (session.status == TransferStatus.transferring ||
                session.status == TransferStatus.pending)) {
          if (!_shownDialogSessionIds.contains(session.id)) {
            _shownDialogSessionIds.add(session.id);
            showTransferProgressDialog(context, session.id);
          }
        }
      }
    });

    final sessions = ref.watch(activeTransfersProvider);
    final hasActiveTransfers = sessions.any(
      (s) =>
          s.status == TransferStatus.transferring ||
          s.status == TransferStatus.pending,
    );

    return PopScope(
      canPop: !hasActiveTransfers,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showToast(l10n.transferInProgressDoNotLeave);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.lanSharingTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // 1. Local Device Status Card
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              (serverState.isRunning
                                      ? Colors.green
                                      : Colors.red)
                                  .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          serverState.isRunning
                              ? Icons.wifi_tethering
                              : Icons.portable_wifi_off,
                          color: serverState.isRunning
                              ? Colors.green
                              : Colors.red,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serverState.isRunning
                                  ? l10n.lanSharingEnabledStatus
                                  : l10n.lanSharingDisabledStatus,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              serverState.isRunning
                                  ? l10n.lanSharingRunningStatus(
                                      serverState.localIp ?? '',
                                      '${serverState.httpPort}',
                                    )
                                  : l10n.lanSharingDefaultOffHint,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 13,
                              ),
                            ),
                            if (Platform.isAndroid &&
                                !settings.hasLanSharingFolderPath) ...[
                              const SizedBox(height: 4),
                              Text(
                                l10n.receiveDirectoryNotSetWarning,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.55,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Switch(
                        value: settings.lanSharingEnabled,
                        onChanged: _setSharingEnabled,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Receive Directory Configuration Card
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    if (Platform.isAndroid) {
                      final androidOutputDirectory = await ref
                          .read(transcodeServiceProvider)
                          .pickAndroidOutputDirectory();
                      if (androidOutputDirectory != null) {
                        await AndroidSafStorageHelper.saveMapping(
                          androidOutputDirectory.displayPath,
                          androidOutputDirectory.treeUri,
                        );
                        await ref
                            .read(sharingServiceProvider)
                            .updateSharingFolderPath(
                              androidOutputDirectory.displayPath,
                            );
                        showToast(
                          l10n.receiveDirectoryUpdated(
                            androidOutputDirectory.displayPath,
                          ),
                        );
                        setState(() {});
                      }
                    } else {
                      final dirPath = await _getDirectoryPath();
                      if (dirPath != null) {
                        await ref
                            .read(sharingServiceProvider)
                            .updateSharingFolderPath(dirPath);
                        showToast(l10n.receiveDirectoryUpdated(dirPath));
                        setState(() {});
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.folder_open,
                            color: theme.colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.receiveDirectoryTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                settings.lanSharingFolderPath.isNotEmpty
                                    ? settings.lanSharingFolderPath
                                    : ref
                                          .watch(sharingServiceProvider)
                                          .sharingFolderPath,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (Platform.isWindows ||
                            Platform.isMacOS ||
                            Platform.isLinux) ...[
                          IconButton(
                            icon: const Icon(Icons.folder_open_outlined),
                            tooltip: l10n.openFolderLocation,
                            onPressed: _handleOpenReceiveDirectory,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Discovered Devices Section
              Text(
                l10n.nearbyDevices,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: devicesAsync.when(
                  data: (devices) {
                    // Filter out local device if any
                    final remoteDevices = devices;
                    if (remoteDevices.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi,
                              size: 48,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              serverState.isRunning
                                  ? l10n.searchingDevices
                                  : l10n.startSharingToFindDevices,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: remoteDevices.length,
                      itemBuilder: (context, index) {
                        final device = remoteDevices[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0,
                          color: theme.colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: device.isOnline
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.3,
                                    )
                                  : theme.colorScheme.outlineVariant.withValues(
                                      alpha: 0.2,
                                    ),
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getPlatformIcon(device.deviceType),
                                color: device.isOnline
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                              ),
                            ),
                            title: Text(
                              device.name,
                              style: TextStyle(
                                color: device.isOnline
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  device.ip,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: device.isOnline
                                        ? Colors.green
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  device.isOnline
                                      ? l10n.deviceOnline
                                      : l10n.deviceOffline,
                                  style: TextStyle(
                                    color: device.isOnline
                                        ? Colors.green
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            trailing: device.isOnline
                                ? PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onSelected: (value) {
                                      if (value == 'file') {
                                        _handleSendFiles(device);
                                      } else if (value == 'folder') {
                                        _handleSendFolder(device);
                                      } else if (value == 'sync_to') {
                                        _handleSyncLyricsToDevice(device);
                                      } else if (value == 'sync_from') {
                                        _handleSyncLyricsFromDevice(device);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                          PopupMenuItem<String>(
                                            value: 'file',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.insert_drive_file,
                                                  size: 18,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(l10n.sendMusicFiles),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'folder',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.folder,
                                                  size: 18,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(l10n.sendFolder),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuDivider(),
                                          PopupMenuItem<String>(
                                            value: 'sync_to',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.cloud_upload_rounded,
                                                  size: 18,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  l10n.syncLyricsToDeviceAction,
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'sync_from',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.cloud_download_rounded,
                                                  size: 18,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  l10n.syncLyricsFromDeviceAction,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      l10n.loadDevicesError(e.toString()),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
