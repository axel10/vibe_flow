import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/player/sharing/sharing_service.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/utils/app_snack_bar.dart';
import 'package:vynody/l10n/app_localizations.dart';

void showIncomingTransferDialog(BuildContext context, IncomingTransferRequest request) {
  final theme = Theme.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final totalSize = request.files.fold<int>(0, (sum, f) => sum + f.size);
      final sizeMb = (totalSize / (1024 * 1024)).toStringAsFixed(1);
      
      String fileNames;
      if (request.files.length > 2) {
        fileNames = l10n.incomingFilesFormat(request.files[0].name, request.files[1].name, '${request.files.length}');
      } else {
        fileNames = request.files.map((f) => f.name).join(', ');
      }

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45)),
          ),
          title: Row(
            children: [
              Icon(Icons.share, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                l10n.incomingTransferRequestTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.incomingTransferFrom(request.senderName),
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileNames,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.fileSizeMb(sizeMb),
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.receiveFileHint,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 11),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                request.onDecision(false);
              },
              child: Text(l10n.reject),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                request.onDecision(true);
              },
              child: Text(l10n.accept, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    },
  );
}

void showIncomingLyricsDialog(BuildContext context, IncomingLyricsRequest request) {
  final theme = Theme.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final isExport = request.type == IncomingLyricsRequestType.exportLyrics;
      final title = isExport
          ? l10n.incomingLyricsExportTitle
          : l10n.incomingLyricsImportTitle;
      final message = isExport
          ? l10n.incomingLyricsExportFrom(request.senderName)
          : l10n.incomingLyricsImportFrom(
              request.senderName,
              '${request.lyricsCount}',
            );

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.lyrics, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                request.onDecision(false);
              },
              child: Text(l10n.reject),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                request.onDecision(true);
              },
              child: Text(l10n.accept, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    },
  );
}

void showTransferProgressDialog(BuildContext context, String sessionId) {
  final theme = Theme.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Consumer(
          builder: (context, ref, child) {
            final sessions = ref.watch(activeTransfersProvider);
            final session = sessions.firstWhere(
              (s) => s.id == sessionId,
              orElse: () => TransferSession(
                id: sessionId,
                fileName: 'Unknown',
                totalBytes: 0,
                bytesTransferred: 0,
                isSending: false,
                deviceName: 'Device',
                status: TransferStatus.failed,
                filesCount: 0,
                completedFilesCount: 0,
              ),
            );

            // Auto close on completion/failure/cancellation
            if (session.status == TransferStatus.success ||
                session.status == TransferStatus.failed ||
                session.status == TransferStatus.cancelled) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  
                  // Show quick status toast or SnackBar
                  final isSuccess = session.status == TransferStatus.success;
                  final isCancelled = session.status == TransferStatus.cancelled;
                  final direction = session.isSending ? l10n.sendDirection : l10n.receiveDirection;
                  final text = isSuccess
                      ? (session.isSending 
                          ? l10n.sendCompleted(session.fileName) 
                          : l10n.receiveCompleted(session.completedFilesCount ?? session.filesCount ?? 1))
                      : (isCancelled
                          ? (session.cancelReason != null && session.cancelReason!.isNotEmpty
                              ? l10n.transferCancelledWithReason(direction, session.cancelReason!)
                              : l10n.transferCancelled(direction))
                          : l10n.transferFailedFormat(direction, session.fileName));

                  
                  AppSnackBar.show(
                    context,
                    ref,
                    SnackBar(
                      content: Text(text),
                    ),
                  );
                }
              });
            }

            final speed = (session.bytesTransferred / (1024 * 1024)).toStringAsFixed(1);
            final total = (session.totalBytes / (1024 * 1024)).toStringAsFixed(1);
            final title = session.isSending ? l10n.sendingToDevice(session.deviceName) : l10n.receivingFromDevice(session.deviceName);

            final completedCount = session.completedFilesCount ?? 0;
            final filesCount = session.filesCount ?? 0;
            final activeCount = session.activeFiles.length;
            final hasMoreFiles = filesCount > (completedCount + activeCount);
            final double? containerHeight = hasMoreFiles ? 156 : null;

            return PopScope(
              canPop: session.status == TransferStatus.success ||
                  session.status == TransferStatus.failed ||
                  session.status == TransferStatus.cancelled,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45)),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                content: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.fileName,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: session.progress,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        color: theme.colorScheme.primary,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.progressFormat((session.progress * 100).toStringAsFixed(0)),
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                          ),
                          Text(
                            '$speed / $total MB',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                      if (session.activeFiles.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 6),
                        Text(
                          l10n.currentlyTransferring,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: containerHeight,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 156),
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                children: session.activeFiles.map((activeFile) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(10),
                                    width: double.maxFinite,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.audiotrack_rounded,
                                              size: 14,
                                              color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                activeFile.fileName,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${(activeFile.progress * 100).toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        LinearProgressIndicator(
                                          value: activeFile.progress,
                                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                          color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                          minHeight: 4,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                actions: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      ref.read(sharingServiceProvider).cancelTransfer(sessionId);
                    },
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Future<String?> showConflictDialog(BuildContext context, String fileName) {
  final theme = Theme.of(context);
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Text(
                l10n.fileConflictTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.fileConflictMessage,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                fileName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.fileConflictChooseAction,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop('skip'),
                      child: Text(l10n.skipAction),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop('overwrite'),
                      child: Text(l10n.overwriteAction),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop('skip_all'),
                      child: Text(l10n.skipAllAction),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop('overwrite_all'),
                      child: Text(l10n.overwriteAllAction),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
