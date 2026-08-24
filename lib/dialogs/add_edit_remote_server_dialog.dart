import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/remote_server_riverpod.dart';

class AddEditRemoteServerDialog extends ConsumerStatefulWidget {
  final RemoteServer? server;

  const AddEditRemoteServerDialog({super.key, this.server});

  static Future<bool?> show(BuildContext context, {RemoteServer? server}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AddEditRemoteServerDialog(server: server),
    );
  }

  @override
  ConsumerState<AddEditRemoteServerDialog> createState() =>
      _AddEditRemoteServerDialogState();
}

class _AddEditRemoteServerDialogState
    extends ConsumerState<AddEditRemoteServerDialog> {
  final _formKey = GlobalKey<FormState>();
  late RemoteServerType _serverType;
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _customPathController;
  int? _maxBitRate;
  bool _ignoreSsl = false;
  bool _obscurePassword = true;

  bool _isTesting = false;
  ConnectionTestResult? _testResult;

  bool get _isEditing => widget.server != null;

  @override
  void initState() {
    super.initState();
    final s = widget.server;
    _serverType = s?.type ?? RemoteServerType.subsonic;
    _nameController = TextEditingController(text: s?.name ?? '');
    _urlController = TextEditingController(text: s?.url ?? '')
      ..addListener(_handleUrlChanged);
    _usernameController = TextEditingController(text: s?.username ?? '');
    _passwordController = TextEditingController();
    _customPathController = TextEditingController(text: s?.customPath ?? '');
    _maxBitRate = s?.maxBitRate;
    _ignoreSsl = s?.ignoreSsl ?? false;

    if (_isEditing) {
      _loadExistingPassword(s!.id);
    }
  }

  Future<void> _loadExistingPassword(String serverId) async {
    final pwd = await ref.read(remoteServersProvider.notifier).getPassword(serverId);
    if (mounted && pwd != null) {
      _passwordController.text = pwd;
    }
  }

  void _handleUrlChanged() {
    final text = _urlController.text.trim().toLowerCase();
    if (!_isEditing && text.isNotEmpty) {
      if (text.contains('/dav') || text.contains('/remote.php/webdav')) {
        if (_serverType != RemoteServerType.webdav) {
          setState(() {
            _serverType = RemoteServerType.webdav;
          });
        }
      } else if (text.contains(':4533') || text.contains('/subsonic') || text.contains('/rest')) {
        if (_serverType != RemoteServerType.subsonic) {
          setState(() {
            _serverType = RemoteServerType.subsonic;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _urlController.removeListener(_handleUrlChanged);
    _nameController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _customPathController.dispose();
    super.dispose();
  }

  RemoteServer _buildServerModel() {
    return RemoteServer(
      id: widget.server?.id ??
          'srv_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : (_serverType == RemoteServerType.subsonic ? 'Navidrome' : 'WebDAV'),
      type: _serverType,
      url: _urlController.text.trim(),
      username: _usernameController.text.trim(),
      customPath: _serverType == RemoteServerType.webdav &&
              _customPathController.text.trim().isNotEmpty
          ? _customPathController.text.trim()
          : null,
      maxBitRate: _serverType == RemoteServerType.subsonic ? _maxBitRate : null,
      ignoreSsl: _ignoreSsl,
      createdAt: widget.server?.createdAt ?? DateTime.now(),
      lastConnectedAt: widget.server?.lastConnectedAt,
    );
  }

  Future<void> _runTestConnection() async {
    if (_urlController.text.trim().isEmpty) {
      showToast('Please enter server URL first');
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final tempServer = _buildServerModel();
    final result = await ref.read(remoteServersProvider.notifier).testConnection(
          tempServer,
          _passwordController.text,
        );

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testResult = result;
      });
    }
  }

  Future<void> _saveServer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final server = _buildServerModel();
    final pwd = _passwordController.text;

    if (_isEditing) {
      await ref.read(remoteServersProvider.notifier).updateServer(
            server,
            newPassword: pwd.isNotEmpty ? pwd : null,
          );
    } else {
      await ref.read(remoteServersProvider.notifier).addServer(server, pwd);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      _serverType == RemoteServerType.subsonic
                          ? Icons.cloud_queue_rounded
                          : Icons.folder_shared_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isEditing ? l10n.editRemoteServer : l10n.addRemoteServer,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SegmentedButton<RemoteServerType>(
                  segments: const [
                    ButtonSegment(
                      value: RemoteServerType.subsonic,
                      icon: Icon(Icons.library_music_rounded),
                      label: Text('Navidrome'),
                    ),
                    ButtonSegment(
                      value: RemoteServerType.webdav,
                      icon: Icon(Icons.folder_copy_outlined),
                      label: Text('WebDAV'),
                    ),
                  ],
                  selected: {_serverType},
                  onSelectionChanged: (selected) {
                    setState(() {
                      _serverType = selected.first;
                      _testResult = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: l10n.serverName,
                            hintText: _serverType == RemoteServerType.subsonic
                                ? 'My Navidrome NAS'
                                : 'Nextcloud WebDAV',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            labelText: l10n.serverUrl,
                            hintText: _serverType == RemoteServerType.subsonic
                                ? 'http://192.168.1.100:4533'
                                : 'https://dav.example.com/remote.php/webdav',
                            prefixIcon: const Icon(Icons.link_rounded),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Server URL is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: l10n.serverUsername,
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: l10n.serverPassword,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_serverType == RemoteServerType.webdav) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _customPathController,
                            decoration: InputDecoration(
                              labelText: l10n.customPath,
                              hintText: '/Music',
                              prefixIcon: const Icon(Icons.folder_open_outlined),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                        if (_serverType == RemoteServerType.subsonic) ...[
                          const SizedBox(height: 14),
                          DropdownButtonFormField<int?>(
                            initialValue: _maxBitRate,
                            decoration: InputDecoration(
                              labelText: l10n.maxBitRate,
                              prefixIcon: const Icon(Icons.graphic_eq_rounded),
                              border: const OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Raw (No Transcoding)')),
                              DropdownMenuItem(value: 320, child: Text('320 kbps (High Quality)')),
                              DropdownMenuItem(value: 192, child: Text('192 kbps (Standard)')),
                              DropdownMenuItem(value: 128, child: Text('128 kbps (Low Bandwidth)')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _maxBitRate = val;
                              });
                            },
                          ),
                        ],
                        const SizedBox(height: 10),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.ignoreSsl),
                          subtitle: const Text('For self-signed or internal SSL certs'),
                          value: _ignoreSsl,
                          onChanged: (val) {
                            setState(() {
                              _ignoreSsl = val;
                            });
                          },
                        ),
                        if (_testResult != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _testResult!.isSuccess
                                  ? Colors.green.withValues(alpha: 0.12)
                                  : Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _testResult!.isSuccess
                                    ? Colors.green.withValues(alpha: 0.4)
                                    : Colors.red.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _testResult!.isSuccess
                                      ? Icons.check_circle_outline
                                      : Icons.error_outline,
                                  color: _testResult!.isSuccess
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _testResult!.isSuccess
                                            ? '${l10n.connectionSuccess} (${_testResult!.serverVersion ?? ""})'
                                            : l10n.connectionFailed,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _testResult!.isSuccess
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      if (_testResult!.songCount != null)
                                        Text('Songs found: ${_testResult!.songCount}'),
                                      if (!_testResult!.isSuccess)
                                        Text(
                                          _testResult!.message,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isTesting ? null : _runTestConnection,
                      icon: _isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.network_ping_rounded),
                      label: Text(_isTesting
                          ? l10n.testingConnection
                          : l10n.testConnection),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _saveServer,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
