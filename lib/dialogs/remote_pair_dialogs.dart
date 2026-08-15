import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';

void showIncomingRemotePairDialog(
  BuildContext context,
  IncomingRemotePairRequest request,
) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return _IncomingRemotePairDialogContent(
        request: request,
        theme: theme,
        l10n: l10n,
      );
    },
  );
}

class _IncomingRemotePairDialogContent extends ConsumerStatefulWidget {
  final IncomingRemotePairRequest request;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _IncomingRemotePairDialogContent({
    required this.request,
    required this.theme,
    required this.l10n,
  });

  @override
  ConsumerState<_IncomingRemotePairDialogContent> createState() =>
      _IncomingRemotePairDialogContentState();
}

class _IncomingRemotePairDialogContentState
    extends ConsumerState<_IncomingRemotePairDialogContent> {
  int _countdown = 60;
  Timer? _timer;
  bool _rememberDevice = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown <= 1) {
        t.cancel();
        Navigator.of(context, rootNavigator: true).pop();
        widget.request.onDecision(false, false);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<IncomingRemotePairRequest?>(incomingRemotePairProvider, (
      previous,
      next,
    ) {
      if (next == null || next != widget.request) {
        if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    });

    final theme = widget.theme;
    final l10n = widget.l10n;
    final request = widget.request;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.settings_remote_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.remoteControlRequestTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l10n.remoteControlRequestFrom(request.senderName),
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.remotePinPairHint,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  request.pinCode,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() => _rememberDevice = !_rememberDevice);
                widget.request.onRememberChanged(_rememberDevice);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _rememberDevice,
                      onChanged: (val) {
                        final v = val ?? false;
                        setState(() => _rememberDevice = v);
                        widget.request.onRememberChanged(v);
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l10n.trustThisDevice,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.remotePinExpiresIn} $_countdown s',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              widget.request.onDecision(false, _rememberDevice);
            },
            child: Text(l10n.reject),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              widget.request.onDecision(true, _rememberDevice);
            },
            child: Text(l10n.allowDirectly),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showRemotePinInputDialog(
  BuildContext context, {
  required String deviceName,
  required Future<({bool success, bool rejected})> Function(String pin) onVerify,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _RemotePinInputDialogContent(
      deviceName: deviceName,
      onVerify: onVerify,
    ),
  );
}

class _RemotePinInputDialogContent extends StatefulWidget {
  final String deviceName;
  final Future<({bool success, bool rejected})> Function(String pin) onVerify;

  const _RemotePinInputDialogContent({
    required this.deviceName,
    required this.onVerify,
  });

  @override
  State<_RemotePinInputDialogContent> createState() =>
      _RemotePinInputDialogContentState();
}

class _RemotePinInputDialogContentState
    extends State<_RemotePinInputDialogContent> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isVerifying = false;
  String? _errorMessage;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    // Poll to check if host clicked Direct Allow or Reject
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) async {
      if (!mounted || _isVerifying) return;
      final result = await widget.onVerify('');
      if (!mounted) return;
      if (result.success) {
        _pollTimer?.cancel();
        Navigator.of(context).pop(true);
      } else if (result.rejected) {
        _pollTimer?.cancel();
        Navigator.of(context).pop(false);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitPin(String pin) async {
    if (pin.length != 4 || _isVerifying) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final result = await widget.onVerify(pin);
    if (!mounted) return;

    if (result.success) {
      _pollTimer?.cancel();
      Navigator.of(context).pop(true);
    } else if (result.rejected) {
      _pollTimer?.cancel();
      Navigator.of(context).pop(false);
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = AppLocalizations.of(context)!.remotePinInvalid;
        _controller.clear();
      });
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.pin_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.enterRemotePinTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l10n.enterRemotePinPrompt(widget.deviceName),
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Hidden text field + 4 Box digit view
            Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.0,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      enableInteractiveSelection: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      onChanged: (val) {
                        setState(() {});
                        if (val.length == 4) {
                          _submitPin(val);
                        }
                      },
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _focusNode.requestFocus(),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final char = index < _controller.text.length
                            ? _controller.text[index]
                            : '';
                        final isCurrent = index == _controller.text.length;

                        return Container(
                          width: 44,
                          height: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : (_errorMessage != null
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.6)),
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            char,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ],
            if (_isVerifying) ...[
              const SizedBox(height: 16),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}

void showTrustedDevicesDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => const _TrustedDevicesDialogContent(),
  );
}

class _TrustedDevicesDialogContent extends ConsumerWidget {
  const _TrustedDevicesDialogContent();

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

  String _formatDate(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final trustedDevices = ref.watch(trustedDevicesProvider);
    final remoteService = ref.read(remoteControlServiceProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.trustedDevicesTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '已信任 ${trustedDevices.length} 台设备',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        content: SizedBox(
          width: 440,
          child: trustedDevices.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.devices_other_rounded,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '暂无已信任的设备',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '在接受配对时勾选“记住该设备”后将在此显示',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: trustedDevices.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final d = trustedDevices[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getPlatformIcon(d.deviceType),
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          d.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '配对时间: ${_formatDate(d.pairedAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: theme.colorScheme.error,
                          ),
                          tooltip: l10n.removeTrustedDevice,
                          onPressed: () {
                            remoteService.removeTrustedDevice(d.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actions: [
          if (trustedDevices.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.delete_sweep_rounded, size: 18),
              label: Text(l10n.clear),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () {
                for (final d in trustedDevices.toList()) {
                  remoteService.removeTrustedDevice(d.id);
                }
              },
            ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
