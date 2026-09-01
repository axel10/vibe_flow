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
import 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
import 'package:vynody/dialogs/remote_pair_dialogs.dart';
import 'package:vynody/pages/remote_control_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vynody/dialogs/upgrade_to_pro_dialog.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/pro/pro_models.dart';
import 'package:vynody/widgets/pro/pro_badge.dart';
import 'package:vynody/l10n/app_localizations.dart';
import '../utils/song_context_menu_utils.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/remote_server_riverpod.dart';
import 'package:vynody/dialogs/add_edit_remote_server_dialog.dart';
import 'package:vynody/pages/main_layout.dart';
import 'remote/remote_download_manager_page.dart';
import 'package:vynody/player/remote/services/remote_download_service.dart';

class SharingPage extends ConsumerStatefulWidget {
  const SharingPage({super.key});

  @override
  ConsumerState<SharingPage> createState() => _SharingPageState();
}

class _SharingPageState extends ConsumerState<SharingPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final SharingServerStateNotifier _sharingServerNotifier;
  bool _didSyncInitialSharingState = false;
  final Set<String> _shownDialogSessionIds = {};
  bool _isFolderWritable = true;
  String _lastCheckedFolderPath = '';

  Future<void> _verifyFolderPermission() async {
    if (!mounted) return;
    final service = ref.read(sharingServiceProvider);
    final settings = ref.read(settingsServiceProvider);
    final currentPath = settings.lanSharingFolderPath.isNotEmpty
        ? settings.lanSharingFolderPath
        : service.sharingFolderPath;

    _lastCheckedFolderPath = currentPath;
    final writable = await service.checkSharingFolderWritable(currentPath);
    if (mounted && _lastCheckedFolderPath == currentPath) {
      if (_isFolderWritable != writable) {
        setState(() {
          _isFolderWritable = writable;
        });
      }
    }
  }

  Future<String?> _getDirectoryPath() {
    return FileSelectorHelper.pickDirectory(lockParentWindow: false);
  }

  Future<void> _showDirectoryOptionsDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final service = ref.read(sharingServiceProvider);
    final defaultPath = await service.getDefaultSharingFolderPath();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.receiveDirectoryTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.restart_alt_rounded, color: theme.colorScheme.primary),
                  ),
                  title: Text(l10n.restoreDefaultDirectory),
                  subtitle: Text(
                    defaultPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await service.resetSharingFolderPathToDefault();
                    if (mounted) {
                      showToast(l10n.receiveDirectoryRestoredDefault);
                      await _verifyFolderPermission();
                      setState(() {});
                    }
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.folder_open_rounded, color: theme.colorScheme.secondary),
                  ),
                  title: Text(l10n.chooseOtherDirectory),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final dirPath = await _getDirectoryPath();
                    if (dirPath != null && mounted) {
                      await service.updateSharingFolderPath(dirPath);
                      showToast(l10n.receiveDirectoryUpdated(dirPath));
                      await _verifyFolderPermission();
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleReceiveDirectoryTap() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(settingsServiceProvider);
    final service = ref.read(sharingServiceProvider);

    if (Platform.isAndroid) {
      final androidOutputDirectory = await ref
          .read(transcodeServiceProvider)
          .pickAndroidOutputDirectory();
      if (androidOutputDirectory != null) {
        await AndroidSafStorageHelper.saveMapping(
          androidOutputDirectory.displayPath,
          androidOutputDirectory.treeUri,
        );
        await service.updateSharingFolderPath(
          androidOutputDirectory.displayPath,
        );
        if (mounted) {
          showToast(
            l10n.receiveDirectoryUpdated(
              androidOutputDirectory.displayPath,
            ),
          );
          await _verifyFolderPermission();
          setState(() {});
        }
      }
      return;
    }

    if (!_isFolderWritable || settings.lanSharingFolderPath.isNotEmpty) {
      await _showDirectoryOptionsDialog();
    } else {
      final dirPath = await _getDirectoryPath();
      if (dirPath != null && mounted) {
        await service.updateSharingFolderPath(dirPath);
        showToast(l10n.receiveDirectoryUpdated(dirPath));
        await _verifyFolderPermission();
        setState(() {});
      }
    }
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
    _tabController = TabController(length: 2, vsync: this);
    _sharingServerNotifier = ref.read(sharingServerStateProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyFolderPermission();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSendFiles(LanDevice device) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final filePaths = await FileSelectorHelper.pickFiles(
        label: l10n.audioFiles,
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
          if (mounted) {
            showTransferProgressDialog(context, newSendSession.id);
          }
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
      showToast(l10n.sendFilesFailed(e.toString()));
    }
  }

  Future<void> _handleSendFolder(LanDevice device) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final dirPath = await _getDirectoryPath();

      if (dirPath == null) {
        return;
      }

      showToast(l10n.scanningFolderMusic);

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
        showToast(l10n.scanFolderFailed(e.toString()));
        return;
      }

      if (musicFiles.isEmpty) {
        showToast(l10n.noMusicFilesFound);
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
          if (mounted) {
            showTransferProgressDialog(context, newSendSession.id);
          }
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
      showToast(l10n.sendFolderFailed(e.toString()));
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

  Future<void> _handleRemoteControl(LanDevice device) async {
    final l10n = AppLocalizations.of(context)!;
    final serverState = ref.read(sharingServerStateProvider);
    if (!serverState.isRunning) {
      showToast(l10n.startSharingToFindDevices);
      return;
    }

    final sharingService = ref.read(sharingServiceProvider);
    final remoteService = ref.read(remoteControlServiceProvider);

    try {
      final sessionToken = await remoteService.initiatePairing(
        targetDevice: device,
        senderId: sharingService.deviceId,
        senderName: sharingService.deviceName,
        deviceType: sharingService.deviceType,
      );

      if (sessionToken != null) {
        if (!mounted) return;
        final result = await showRemotePinInputDialog(
          context,
          deviceName: device.name,
          onVerify: (pin) async {
            return await remoteService.verifyPinAndGetToken(
              targetDevice: device,
              sessionToken: sessionToken,
              pin: pin,
            );
          },
          onCancel: () {
            remoteService.cancelPairing(
              targetDevice: device,
              sessionToken: sessionToken,
            );
          },
        );

        if (result == RemotePinDialogResult.rejected) {
          if (mounted) {
            showToast(l10n.remoteRequestRejected);
          }
          return;
        } else if (result == RemotePinDialogResult.invalidated) {
          if (mounted) {
            showToast(l10n.remotePinTooManyAttempts);
          }
          return;
        } else if (result != RemotePinDialogResult.success) {
          return;
        }
      }

      if (!mounted) return;
      final connected = await remoteService.connectWebSocket(
        targetDevice: device,
        senderName: sharingService.deviceName,
      );

      if (connected && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RemoteControlPage(device: device),
          ),
        );
      } else if (mounted) {
        showToast(l10n.remoteConnectFailed);
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        if (errorStr.contains('remote_control_disabled') ||
            errorStr.contains('Remote control is disabled')) {
          showToast(l10n.remoteControlDisabledOnHost);
        } else {
          showToast('${l10n.remoteConnectFailed}: $e');
        }
      }
    }
  }

  Future<void> _setSharingEnabled(bool enabled) async {
    final settings = ref.read(settingsServiceProvider);
    final previousEnabled = settings.lanSharingEnabled;

    if (enabled) {
      final allowed = await checkProGate(
        context,
        ref,
        feature: ProFeature.lanSharing,
      );
      if (!allowed) return;
    }

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
    final l10n = AppLocalizations.of(context)!;
    try {
      showToast(l10n.syncingLyricsToDevice(device.name));
      final service = ref.read(sharingServiceProvider);
      final stats = await service.syncLyricsToDevice(device);
      showToast(
        l10n.syncLyricsSuccess(
          '${stats['matched']}',
          '${stats['overwritten']}',
          '${stats['skipped']}',
        ),
      );
    } catch (e) {
      final errorMsg = e.toString().contains('rejected')
          ? l10n.lyricsRequestRejected
          : e.toString();
      showToast(l10n.syncLyricsFailed(errorMsg));
    }
  }

  Future<void> _handleSyncLyricsFromDevice(LanDevice device) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      showToast(l10n.syncingLyricsFromDevice(device.name));
      final service = ref.read(sharingServiceProvider);
      final stats = await service.pullLyricsFromDevice(device);
      showToast(
        l10n.syncLyricsSuccess(
          '${stats['matched']}',
          '${stats['overwritten']}',
          '${stats['skipped']}',
        ),
      );
    } catch (e) {
      final errorMsg = e.toString().contains('rejected')
          ? l10n.lyricsRequestRejected
          : e.toString();
      showToast(l10n.syncLyricsFailed(errorMsg));
    }
  }

  Future<void> _handleSendPlaylistsToDevice(LanDevice device) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final playlistService = ref.read(playlistServiceProvider);
      final playlists = playlistService.playlists;
      if (playlists.isEmpty || !playlists.any((p) => p.songs.isNotEmpty)) {
        showToast(l10n.noPlaylistsAvailable);
        return;
      }

      final selectedPlaylists = await showSelectPlaylistsDialog(
        context,
        playlists,
      );
      if (selectedPlaylists == null || selectedPlaylists.isEmpty) return;

      showToast(l10n.syncingPlaylistsToDevice(device.name));
      final service = ref.read(sharingServiceProvider);
      final stats = await service.sendPlaylistsToDevice(
        device,
        selectedPlaylists,
      );
      final importedCount =
          stats['imported_playlists'] ?? selectedPlaylists.length;
      showToast(l10n.sendPlaylistsSuccess(importedCount));
    } catch (e) {
      final errorMsg = e.toString().contains('rejected')
          ? l10n.playlistRequestRejected
          : e.toString();
      showToast(l10n.sendPlaylistsFailed(errorMsg));
    }
  }

  Future<void> _handlePullPlaylistsFromDevice(LanDevice device) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      showToast(l10n.syncingPlaylistsFromDevice(device.name));
      final service = ref.read(sharingServiceProvider);
      final stats = await service.pullPlaylistsFromDevice(device);
      final importedCount = stats['imported_playlists'] ?? 0;
      showToast(l10n.pullPlaylistsSuccess(importedCount));
    } catch (e) {
      final errorMsg = e.toString().contains('rejected')
          ? l10n.playlistRequestRejected
          : e.toString();
      showToast(l10n.pullPlaylistsFailed(errorMsg));
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
    final theme = Theme.of(context);
    final settings = ref.watch(settingsServiceProvider);
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final double bottomOffset = (currentMusic != null
            ? (isLandscape ? 96.0 : 160.0)
            : (isLandscape ? 24.0 : 96.0)) +
        bottomPadding;

    final isProUnlocked = ref.watch(isProUnlockedProvider);
    final currentFolderPath = settings.lanSharingFolderPath.isNotEmpty
        ? settings.lanSharingFolderPath
        : ref.watch(sharingServiceProvider).sharingFolderPath;

    if (currentFolderPath != _lastCheckedFolderPath) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyFolderPermission();
      });
    }

    if (!_didSyncInitialSharingState) {
      _didSyncInitialSharingState = true;
      if (isProUnlocked) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (settings.lanSharingEnabled && !serverState.isRunning) {
            _sharingServerNotifier.start();
          }
        });
      }
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
          centerTitle: true,
          title: TabBar(
            controller: _tabController,
            isScrollable: isLandscape ? false : true,
            tabAlignment: isLandscape ? TabAlignment.fill : TabAlignment.center,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(l10n.tabLanSharing),
                    const SizedBox(width: 6),
                    const ProBadge(),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(l10n.tabCloudServers),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            !isProUnlocked
                ? _buildProLockedView(context, theme, l10n, bottomOffset)
                : _buildLanSharingContent(context, theme, l10n, bottomOffset),
            _buildCloudServersView(context, theme, l10n, bottomOffset),
          ],
        ),
      ),
    );
  }

  Widget _buildLanSharingContent(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    double bottomOffset,
  ) {
    final serverState = ref.watch(sharingServerStateProvider);
    final devicesAsync = ref.watch(discoveredDevicesProvider);
    final settings = ref.watch(settingsServiceProvider);
    final currentFolderPath = settings.lanSharingFolderPath.isNotEmpty
        ? settings.lanSharingFolderPath
        : ref.watch(sharingServiceProvider).sharingFolderPath;
    final isInternalDir = Platform.isAndroid &&
        (!settings.hasLanSharingFolderPath ||
            currentFolderPath.startsWith('/data/user/') ||
            currentFolderPath.startsWith('/data/data/'));
    final isReceiveDirWarning = !_isFolderWritable || isInternalDir;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // 0. Host Remote Control Active Banner (if any)
              Builder(
                builder: (context) {
                  final hostClients = ref.watch(hostConnectedClientsProvider);
                  if (hostClients.isEmpty) return const SizedBox.shrink();

                  final fullText = l10n.controlledByRemoteDevices('__CLIENTS__');
                  final parts = fullText.split('__CLIENTS__');
                  final prefix = parts[0];
                  final suffix = parts.length > 1 ? parts[1] : '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sensors_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(text: prefix),
                                for (int i = 0; i < hostClients.length; i++) ...[
                                  if (i > 0) const TextSpan(text: ', '),
                                  TextSpan(
                                    text: hostClients[i].name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (hostClients[i].isTrusted) ...[
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 3.0),
                                        child: Tooltip(
                                          message: l10n.trustedDevicesTitle,
                                          child: InkWell(
                                            onTap: () => showTrustedDevicesDialog(context),
                                            borderRadius: BorderRadius.circular(10),
                                            child: Icon(
                                              Icons.verified_rounded,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                                if (suffix.isNotEmpty) TextSpan(text: suffix),
                              ],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(remoteControlServiceProvider)
                                .disconnectAllHostClients();
                          },
                          child: Text(l10n.remoteDisconnect),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // 1. Unified File Sharing & Receive Directory Card
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isReceiveDirWarning
                        ? theme.colorScheme.error.withValues(alpha: 0.6)
                        : theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.45,
                          ),
                    width: isReceiveDirWarning ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top part: Server Switch
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (serverState.isRunning
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
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  serverState.isRunning
                                      ? l10n.lanSharingEnabledStatus
                                      : l10n.lanSharingDisabledStatus,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  serverState.isRunning
                                      ? l10n.lanSharingRunningStatus(
                                          serverState.localIp ?? '',
                                          '${serverState.httpPort}',
                                        )
                                      : l10n.lanSharingDefaultOffHint,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
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
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.25,
                      ),
                    ),
                    // Bottom part: Receive Directory Picker
                    InkWell(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      onTap: _handleReceiveDirectoryTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isReceiveDirWarning
                              ? theme.colorScheme.errorContainer
                                  .withValues(alpha: 0.15)
                              : null,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isReceiveDirWarning
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.primary)
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isReceiveDirWarning
                                    ? Icons.folder_off_rounded
                                    : Icons.folder_open,
                                color: isReceiveDirWarning
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.receiveDirectoryTitle,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isReceiveDirWarning
                                          ? theme.colorScheme.error
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentFolderPath,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (!_isFolderWritable) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 14,
                                          color: theme.colorScheme.error,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            l10n.receiveDirectoryNoWritePermission,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else if (isInternalDir) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 14,
                                          color: theme.colorScheme.error,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            l10n.receiveDirectoryNotSetWarning,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: theme.colorScheme.error
                                                  .withValues(alpha: 0.8),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (Platform.isWindows ||
                                Platform.isMacOS ||
                                Platform.isLinux) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.folder_open_outlined,
                                  size: 20,
                                ),
                                tooltip: l10n.openFolderLocation,
                                onPressed: _handleOpenReceiveDirectory,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: isReceiveDirWarning
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.4,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Remote Control Toggle Card
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.settings_remote_rounded,
                              color: theme.colorScheme.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.allowRemoteControlTitle,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.allowRemoteControlSubtitle,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: settings.allowRemoteControl,
                            onChanged: (value) {
                              settings.allowRemoteControl = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final trustedDevices = ref.watch(trustedDevicesProvider);
                        return InkWell(
                          onTap: () => showTrustedDevicesDialog(context),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.manageTrustedDevicesTitle,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                if (trustedDevices.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer
                                          .withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${trustedDevices.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
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
                        child: Padding(
                          padding: EdgeInsets.only(bottom: bottomOffset * 0.5),
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
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: bottomOffset),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                                Flexible(
                                  child: Text(
                                    device.ip,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                      fontSize: 11,
                                    ),
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
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.settings_remote_rounded,
                                          size: 20,
                                        ),
                                        tooltip: l10n.remoteControlAction,
                                        color: theme.colorScheme.primary,
                                        onPressed: () =>
                                            _handleRemoteControl(device),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: theme.colorScheme.primary,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'remote_control') {
                                            _handleRemoteControl(device);
                                          } else if (value == 'file') {
                                            _handleSendFiles(device);
                                          } else if (value == 'folder') {
                                            _handleSendFolder(device);
                                          } else if (value == 'send_playlist') {
                                            _handleSendPlaylistsToDevice(device);
                                          } else if (value == 'pull_playlist') {
                                            _handlePullPlaylistsFromDevice(device);
                                          } else if (value == 'sync_to') {
                                            _handleSyncLyricsToDevice(device);
                                          } else if (value == 'sync_from') {
                                            _handleSyncLyricsFromDevice(device);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                              PopupMenuItem<String>(
                                                value: 'remote_control',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.settings_remote_rounded,
                                                      size: 18,
                                                      color:
                                                          theme.colorScheme.primary,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(l10n.remoteControlAction),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuDivider(),
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
                                                value: 'send_playlist',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.playlist_add_check_rounded,
                                                      size: 18,
                                                      color:
                                                          theme.colorScheme.primary,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      l10n.sendPlaylistsToDeviceAction,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'pull_playlist',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.playlist_play_rounded,
                                                      size: 18,
                                                      color:
                                                          theme.colorScheme.primary,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      l10n.pullPlaylistsFromDeviceAction,
                                                    ),
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

  Widget _buildCloudServersView(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    double bottomOffset,
  ) {
    final serversAsync = ref.watch(remoteServersProvider);

    return serversAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading servers: $err')),
      data: (servers) {
        if (servers.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomOffset, left: 24, right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_outlined,
                    size: 72,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRemoteServers,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noRemoteServersDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: () => AddEditRemoteServerDialog.show(context),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.addRemoteServer),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const RemoteDownloadManagerPage(),
                            ),
                          );
                        },
                        icon: Badge(
                          isLabelVisible:
                              ref.watch(activeDownloadsCountProvider) > 0,
                          label: Text(
                            '${ref.watch(activeDownloadsCountProvider)}',
                          ),
                          child: const Icon(Icons.download_rounded),
                        ),
                        label: Text(l10n.downloadManager),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomOffset + 20),
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 380;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${servers.length} ${l10n.tabCloudServers}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Badge(
                                isLabelVisible:
                                    ref.watch(activeDownloadsCountProvider) > 0,
                                label: Text(
                                  '${ref.watch(activeDownloadsCountProvider)}',
                                ),
                                child: const Icon(Icons.download_rounded),
                              ),
                              tooltip: l10n.downloadManager,
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RemoteDownloadManagerPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            if (isNarrow)
                              IconButton.filledTonal(
                                onPressed: () =>
                                    AddEditRemoteServerDialog.show(context),
                                icon: const Icon(Icons.add_rounded, size: 20),
                                tooltip: l10n.addRemoteServer,
                              )
                            else
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    AddEditRemoteServerDialog.show(context),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: Text(l10n.addRemoteServer),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                for (final server in servers)
                  _buildServerCard(context, theme, l10n, server),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServerCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    RemoteServer server,
  ) {
    final isSubsonic = server.type == RemoteServerType.subsonic;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSubsonic
                        ? Colors.orange.withValues(alpha: 0.12)
                        : Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSubsonic
                        ? Icons.library_music_rounded
                        : Icons.folder_copy_outlined,
                    color: isSubsonic ? Colors.orange : Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              server.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSubsonic
                                  ? Colors.orange.withValues(alpha: 0.15)
                                  : Colors.blue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              server.type.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSubsonic ? Colors.orange : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        server.url,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (val) async {
                    if (val == 'edit') {
                      AddEditRemoteServerDialog.show(context, server: server);
                    } else if (val == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.deleteServerConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref
                            .read(remoteServersProvider.notifier)
                            .deleteServer(server.id);
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const SizedBox(width: 10),
                          Text(l10n.editRemoteServer),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: const Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 380;
                final userText = Text(
                  'User: ${server.username.isNotEmpty ? server.username : "Anonymous"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );

                final testBtn = TextButton.icon(
                  onPressed: () async {
                    showToast('Testing ${server.name}...');
                    final pwd = await ref
                        .read(remoteServersProvider.notifier)
                        .getPassword(server.id);
                    final res = await ref
                        .read(remoteServersProvider.notifier)
                        .testConnection(server, pwd ?? '');
                    if (res.isSuccess) {
                      showToast('✅ ${res.message}');
                    } else {
                      showToast('❌ ${res.message}');
                    }
                  },
                  icon: const Icon(Icons.network_ping_rounded, size: 16),
                  label: Text(l10n.testConnection),
                );

                final browseBtn = FilledButton.icon(
                  onPressed: () async {
                    final pwd = await ref
                        .read(remoteServersProvider.notifier)
                        .getPassword(server.id);
                    if (!context.mounted) return;

                    ref.read(activeRemoteSessionProvider.notifier).setSession(
                      ActiveRemoteSession(
                        server: server,
                        password: pwd ?? '',
                      ),
                    );
                    await navigateToMainTab(context, index: 0, fromIndex: 4);
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(l10n.browseServer),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      userText,
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          testBtn,
                          browseBtn,
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: userText),
                    const SizedBox(width: 8),
                    Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        testBtn,
                        browseBtn,
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProLockedView(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    double bottomOffset,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    final featureHighlights = [
      (
        icon: Icons.speed_rounded,
        title: l10n.sharingHighlightSpeedTitle,
        desc: l10n.sharingHighlightSpeedDesc,
      ),
      (
        icon: Icons.sync_rounded,
        title: l10n.sharingHighlightSyncTitle,
        desc: l10n.sharingHighlightSyncDesc,
      ),
      (
        icon: Icons.phonelink_rounded,
        title: l10n.sharingHighlightRemoteTitle,
        desc: l10n.sharingHighlightRemoteDesc,
      ),
      (
        icon: Icons.security_rounded,
        title: l10n.sharingHighlightSecurityTitle,
        desc: l10n.sharingHighlightSecurityDesc,
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 16, 24, bottomOffset + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Hero Icon with gradient background & glow
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.tertiaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.hub_rounded,
                    size: 38,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.lanSharingTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ProBadge(),
                ],
              ),
              const SizedBox(height: 8),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Text(
                  l10n.sharingProDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Feature Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final useGrid = constraints.maxWidth > 580;
                  if (useGrid) {
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final item in featureHighlights)
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: _buildProFeatureCard(theme, isDark, item),
                          ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      for (final item in featureHighlights) ...[
                        _buildProFeatureCard(theme, isDark, item),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // CTA Button
              FilledButton.icon(
                onPressed: () {
                  showUpgradeToProDialog(context, initialFeature: ProFeature.lanSharing);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.auto_awesome, size: 20),
                label: Text(
                  l10n.upgradeToProToUnlock,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                (Platform.isIOS || Platform.isMacOS)
                    ? l10n.proOneTimePurchaseNoticeApple
                    : l10n.proOneTimePurchaseNotice,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProFeatureCard(
    ThemeData theme,
    bool isDark,
    ({IconData icon, String title, String desc}) item,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 22, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

