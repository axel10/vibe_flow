import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/audio/audio_snapshot.dart';
import 'package:vynody/player/sharing/lan_device.dart';
import 'package:vynody/player/sharing/sharing_service.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'package:vynody/player/sharing/security/tls_certificate_service.dart';
import 'package:vynody/utils/localized_text.dart';
import 'remote_playback_model.dart';

class IncomingRemotePairRequest {
  final String senderId;
  final String senderName;
  final String deviceType;
  final String pinCode;
  final void Function(bool accepted, bool rememberDevice) onDecision;
  final void Function(bool rememberDevice) onRememberChanged;

  IncomingRemotePairRequest({
    required this.senderId,
    required this.senderName,
    required this.deviceType,
    required this.pinCode,
    required this.onDecision,
    required this.onRememberChanged,
  });
}

class IncomingRemotePairNotifier extends Notifier<IncomingRemotePairRequest?> {
  @override
  IncomingRemotePairRequest? build() => null;
  void setRequest(IncomingRemotePairRequest? request) => state = request;
}

final incomingRemotePairProvider =
    NotifierProvider<IncomingRemotePairNotifier, IncomingRemotePairRequest?>(
  IncomingRemotePairNotifier.new,
);

class RemotePlaybackStateNotifier extends Notifier<RemotePlaybackState?> {
  @override
  RemotePlaybackState? build() => null;
  void setState(RemotePlaybackState? state) => this.state = state;
}

final remotePlaybackStateProvider =
    NotifierProvider<RemotePlaybackStateNotifier, RemotePlaybackState?>(
  RemotePlaybackStateNotifier.new,
);

class ConnectedRemoteDeviceNotifier extends Notifier<LanDevice?> {
  @override
  LanDevice? build() => null;
  void setDevice(LanDevice? device) => state = device;
}

final activeControllingDeviceProvider =
    NotifierProvider<ConnectedRemoteDeviceNotifier, LanDevice?>(
  ConnectedRemoteDeviceNotifier.new,
);

class HostConnectedClientsNotifier extends Notifier<List<ConnectedHostClient>> {
  @override
  List<ConnectedHostClient> build() => [];
  void addClient(ConnectedHostClient client) => state = [...state, client];
  void removeClient(ConnectedHostClient client) =>
      state = state.where((c) => c != client).toList();
  void clear() => state = [];
}

final hostConnectedClientsProvider =
    NotifierProvider<HostConnectedClientsNotifier, List<ConnectedHostClient>>(
  HostConnectedClientsNotifier.new,
);

class TrustedDevicesNotifier extends Notifier<List<TrustedRemoteDevice>> {
  @override
  List<TrustedRemoteDevice> build() => [];
  void setDevices(List<TrustedRemoteDevice> devices) => state = devices;
}

final trustedDevicesProvider =
    NotifierProvider<TrustedDevicesNotifier, List<TrustedRemoteDevice>>(
  TrustedDevicesNotifier.new,
);

class _PendingPairSession {
  final String senderId;
  final String senderName;
  final String deviceType;
  final String pinCode;
  final String sessionToken;
  final Completer<bool> completer;
  final DateTime createdAt;
  bool rememberDevice;
  int failedAttempts = 0;
  DateTime? lastFailedAt;

  _PendingPairSession({
    required this.senderId,
    required this.senderName,
    required this.deviceType,
    required this.pinCode,
    required this.sessionToken,
    required this.completer,
    required this.createdAt,
    this.rememberDevice = false,
  });
}

class RemoteControlService {
  final Ref _ref;

  // Host state
  final Map<String, _PendingPairSession> _pendingPairSessions = {};
  final Map<WebSocket, ConnectedHostClient> _hostClientSockets = {};
  final List<TrustedRemoteDevice> _trustedDevices = [];
  final Map<String, String> _temporaryAuthTokens = {};
  ProviderSubscription<AudioSnapshot>? _audioSubscription;

  // Client state
  WebSocket? _clientSocket;
  LanDevice? _controllingDevice;
  String? _clientAuthToken;
  Timer? _pingTimer;
  DateTime? _lastSeekTime;
  int? _lastSeekPositionMs;
  String? _lastSeekTrackTitle;

  RemoteControlService(this._ref);

  List<TrustedRemoteDevice> get trustedDevices => List.unmodifiable(_trustedDevices);
  LanDevice? get controllingDevice => _controllingDevice;
  String? get clientAuthToken => _clientAuthToken;
  bool get isControllingRemote => _clientSocket != null && _controllingDevice != null;
  bool get hasActiveHostClients => _hostClientSockets.isNotEmpty;

  bool isValidToken(String token) {
    if (token.isEmpty) return false;
    final isTrusted = _trustedDevices.any((d) => d.token == token);
    final isTemporary = _temporaryAuthTokens.containsKey(token);
    final isActiveClient = _hostClientSockets.values.any((c) => c.token == token);
    return isTrusted || isTemporary || isActiveClient;
  }

  Future<void> init() async {
    await _loadTrustedDevices();
    _listenLocalAudioState();
  }

  void dispose() {
    _audioSubscription?.close();
    _audioSubscription = null;
    _temporaryAuthTokens.clear();
    disconnectClient();
    _closeAllHostSockets();
  }

  String? getTrustedTokenForDevice(String deviceId) {
    try {
      return _trustedDevices.firstWhere((d) => d.id == deviceId).token;
    } catch (_) {
      return null;
    }
  }

  // --- Trusted Devices Storage ---

  Future<void> _loadTrustedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList('remote_trusted_devices') ?? [];
      _trustedDevices.clear();
      for (final item in jsonList) {
        try {
          final map = jsonDecode(item) as Map<String, dynamic>;
          final device = TrustedRemoteDevice.fromJson(map);
          _trustedDevices.add(device);
          if (device.certFingerprint != null && device.certFingerprint!.isNotEmpty) {
            TlsCertificateService.registerDeviceFingerprint(device.id, device.certFingerprint);
          }
        } catch (_) {}
      }
      _ref.read(trustedDevicesProvider.notifier).setDevices(List.from(_trustedDevices));
    } catch (e) {
      debugPrint('[RemoteControlService] Error loading trusted devices: $e');
    }
  }

  Future<void> _saveTrustedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _trustedDevices.map((d) => jsonEncode(d.toJson())).toList();
      await prefs.setStringList('remote_trusted_devices', jsonList);
      _ref.read(trustedDevicesProvider.notifier).setDevices(List.from(_trustedDevices));
    } catch (e) {
      debugPrint('[RemoteControlService] Error saving trusted devices: $e');
    }
  }

  Future<void> removeTrustedDevice(String id) async {
    _trustedDevices.removeWhere((d) => d.id == id);
    await _saveTrustedDevices();
  }

  Future<void> clearAllTrustedDevices() async {
    _trustedDevices.clear();
    await _saveTrustedDevices();
  }

  // --- Host Implementation ---

  void _listenLocalAudioState() {
    _audioSubscription?.close();
    _audioSubscription = _ref.listen<AudioSnapshot>(
      audioSnapshotProvider,
      (previous, next) {
        if (_hostClientSockets.isNotEmpty) {
          _broadcastCurrentStateToClients(next);
        }
      },
      fireImmediately: false,
    );
  }

  RemotePlaybackState buildCurrentPlaybackState([AudioSnapshot? snapshot]) {
    final AudioSnapshot snap = snapshot ?? _ref.read(audioSnapshotProvider);
    final playlistService = _ref.read(playlistServiceProvider);
    final currentMusic = snap.currentMusic;
    final isFav = currentMusic != null && playlistService.isFavoriteSong(currentMusic);
    final sharingService = _ref.read(sharingServiceProvider);

    final queueItems = snap.playbackQueue.map((m) {
      return RemoteQueueItem(
        id: (m.id ?? m.path).toString(),
        title: m.title ?? m.name,
        artist: m.artist ?? '',
        album: m.album ?? '',
        durationMs: m.durationMillis ?? 0,
        path: m.path,
      );
    }).toList();

    return RemotePlaybackState(
      title: currentMusic?.title ?? '',
      artist: currentMusic?.artist ?? '',
      album: currentMusic?.album ?? '',
      durationMs: snap.duration.inMilliseconds,
      positionMs: snap.position.inMilliseconds,
      isPlaying: snap.isPlaying,
      isFavorite: isFav,
      playbackMode: snap.playbackMode,
      isRandomMode: snap.isRandomMode,
      hostDeviceName: sharingService.deviceName,
      queue: queueItems,
      currentIndex: snap.currentIndex,
      volume: snap.volume,
    );
  }

  void _broadcastCurrentStateToClients([AudioSnapshot? snapshot]) {
    if (_hostClientSockets.isEmpty) return;
    final state = buildCurrentPlaybackState(snapshot);
    final payload = jsonEncode({
      'type': 'state_sync',
      'state': state.toJson(),
    });

    final deadSockets = <WebSocket>[];
    for (final socket in _hostClientSockets.keys) {
      try {
        socket.add(payload);
      } catch (e) {
        deadSockets.add(socket);
      }
    }
    for (final dead in deadSockets) {
      final client = _hostClientSockets.remove(dead);
      if (client != null) {
        _ref.read(hostConnectedClientsProvider.notifier).removeClient(client);
      }
      try {
        dead.close();
      } catch (_) {}
    }
  }

  Future<void> handlePairRequest(HttpRequest request) async {
    try {
      final settings = _ref.read(settingsServiceProvider);
      if (!settings.allowRemoteControl) {
        request.response.statusCode = HttpStatus.forbidden;
        request.response.write(jsonEncode({
          'success': false,
          'reason': 'remote_control_disabled',
        }));
        await request.response.close();
        return;
      }

      final content = await utf8.decoder.bind(request).join();
      final json = jsonDecode(content) as Map<String, dynamic>;

      final senderId = json['sender_id'] as String? ?? 'unknown';
      final senderName = json['sender_name'] as String? ?? 'Unknown';
      final deviceType = json['device_type'] as String? ?? 'unknown';
      final authToken = json['auth_token'] as String?;

      // Check if client is already trusted
      if (authToken != null && authToken.isNotEmpty) {
        final matched = _trustedDevices.any((d) => d.id == senderId && d.token == authToken);
        if (matched) {
          request.response.statusCode = HttpStatus.ok;
          request.response.write(jsonEncode({
            'success': true,
            'trusted': true,
            'token': authToken,
          }));
          await request.response.close();
          return;
        }
      }

      // Generate 4-digit PIN Code
      final pin = (1000 + Random().nextInt(9000)).toString();
      final sessionToken = 'pair_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';
      final completer = Completer<bool>();

      final session = _PendingPairSession(
        senderId: senderId,
        senderName: senderName,
        deviceType: deviceType,
        pinCode: pin,
        sessionToken: sessionToken,
        completer: completer,
        createdAt: DateTime.now(),
        rememberDevice: false,
      );

      _pendingPairSessions[sessionToken] = session;

      // Trigger UI dialog on host
      _ref.read(incomingRemotePairProvider.notifier).setRequest(
        IncomingRemotePairRequest(
          senderId: senderId,
          senderName: senderName,
          deviceType: deviceType,
          pinCode: pin,
          onDecision: (accepted, remember) {
            session.rememberDevice = remember;
            if (!completer.isCompleted) {
              completer.complete(accepted);
            }
            if (!accepted) {
              removeTrustedDevice(senderId);
            }
            _ref.read(incomingRemotePairProvider.notifier).setRequest(null);
          },
          onRememberChanged: (remember) {
            session.rememberDevice = remember;
          },
        ),
      );

      // Return session token to client, client will submit PIN for verification
      request.response.statusCode = HttpStatus.ok;
      request.response.write(jsonEncode({
        'success': true,
        'trusted': false,
        'session_token': sessionToken,
        'require_pin': true,
      }));
      await request.response.close();
    } catch (e) {
      debugPrint('[RemoteControlService] Error handling pair request: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      try {
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> handlePairVerify(HttpRequest request) async {
    try {
      final content = await utf8.decoder.bind(request).join();
      final json = jsonDecode(content) as Map<String, dynamic>;

      final sessionToken = json['session_token'] as String? ?? '';
      final inputPin = (json['pin'] as String? ?? '').trim();

      final session = _pendingPairSessions[sessionToken];
      if (session == null) {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write(jsonEncode({
          'success': false,
          'invalidated': true,
          'reason': 'Session expired or not found',
        }));
        await request.response.close();
        return;
      }

      // Check session TTL (90 seconds timeout)
      if (DateTime.now().difference(session.createdAt).inSeconds > 90) {
        _pendingPairSessions.remove(sessionToken);
        if (!session.completer.isCompleted) {
          session.completer.complete(false);
        }
        _ref.read(incomingRemotePairProvider.notifier).setRequest(null);

        request.response.statusCode = HttpStatus.badRequest;
        request.response.write(jsonEncode({
          'success': false,
          'invalidated': true,
          'reason': 'Session timed out',
        }));
        await request.response.close();
        return;
      }

      // 1. Host already decided directly via dialog button
      if (session.completer.isCompleted) {
        final decision = await session.completer.future;
        if (decision) {
          _pendingPairSessions.remove(sessionToken);
          final token = 'auth_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}';
          
          if (session.rememberDevice) {
            _trustedDevices.removeWhere((d) => d.id == session.senderId);
            _trustedDevices.add(
              TrustedRemoteDevice(
                id: session.senderId,
                name: session.senderName,
                deviceType: session.deviceType,
                token: token,
                pairedAt: DateTime.now(),
              ),
            );
            await _saveTrustedDevices();
          } else {
            _temporaryAuthTokens[token] = session.senderId;
          }

          request.response.statusCode = HttpStatus.ok;
          request.response.write(jsonEncode({
            'success': true,
            'token': token,
            'is_trusted': session.rememberDevice,
          }));
        } else {
          _pendingPairSessions.remove(sessionToken);
          request.response.statusCode = HttpStatus.forbidden;
          request.response.write(jsonEncode({
            'success': false,
            'rejected': true,
            'reason': 'rejected_by_host',
          }));
        }
        await request.response.close();
        return;
      }

      // 2. Polling check (empty PIN) -> Still waiting for host decision
      if (inputPin.isEmpty) {
        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({
          'success': false,
          'pending': true,
          'reason': 'waiting_host_decision',
        }));
        await request.response.close();
        return;
      }

      // 3. Rate limiting / Cooldown check (2 seconds from last failed attempt)
      if (session.lastFailedAt != null) {
        final elapsedMs = DateTime.now().difference(session.lastFailedAt!).inMilliseconds;
        if (elapsedMs < 2000) {
          final remainingSec = ((2000 - elapsedMs) / 1000.0).ceil();
          request.response.statusCode = HttpStatus.tooManyRequests;
          request.response.write(jsonEncode({
            'success': false,
            'cooldown': true,
            'cooldown_seconds': remainingSec > 0 ? remainingSec : 1,
            'remaining_attempts': 5 - session.failedAttempts,
            'reason': 'Rate limited, please wait',
          }));
          await request.response.close();
          return;
        }
      }

      // 4. Verify PIN
      if (session.pinCode == inputPin) {
        _pendingPairSessions.remove(sessionToken);
        session.completer.complete(true);
        _ref.read(incomingRemotePairProvider.notifier).setRequest(null);

        final token = 'auth_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}';
        
        if (session.rememberDevice) {
          _trustedDevices.removeWhere((d) => d.id == session.senderId);
          _trustedDevices.add(
            TrustedRemoteDevice(
              id: session.senderId,
              name: session.senderName,
              deviceType: session.deviceType,
              token: token,
              pairedAt: DateTime.now(),
            ),
          );
          await _saveTrustedDevices();
        } else {
          _temporaryAuthTokens[token] = session.senderId;
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({
          'success': true,
          'token': token,
          'is_trusted': session.rememberDevice,
        }));
      } else {
        // Failed attempt
        session.failedAttempts += 1;
        session.lastFailedAt = DateTime.now();

        const maxAttempts = 5;
        final remainingAttempts = maxAttempts - session.failedAttempts;

        if (remainingAttempts <= 0) {
          // Max attempts exceeded -> invalidate session and dismiss host dialog
          _pendingPairSessions.remove(sessionToken);
          if (!session.completer.isCompleted) {
            session.completer.complete(false);
          }
          _ref.read(incomingRemotePairProvider.notifier).setRequest(null);

          request.response.statusCode = HttpStatus.forbidden;
          request.response.write(jsonEncode({
            'success': false,
            'invalidated': true,
            'remaining_attempts': 0,
            'reason': 'too_many_attempts',
          }));
        } else {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.write(jsonEncode({
            'success': false,
            'cooldown': true,
            'cooldown_seconds': 2,
            'remaining_attempts': remainingAttempts,
            'reason': 'Invalid PIN',
          }));
        }
      }
      await request.response.close();
    } catch (e) {
      debugPrint('[RemoteControlService] Error in pair verify: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      try {
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> handlePairCancel(HttpRequest request) async {
    try {
      final content = await utf8.decoder.bind(request).join();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final sessionToken = json['session_token'] as String? ?? '';

      final session = _pendingPairSessions.remove(sessionToken);
      if (session != null) {
        if (!session.completer.isCompleted) {
          session.completer.complete(false);
        }
        final currentReq = _ref.read(incomingRemotePairProvider);
        if (currentReq?.pinCode == session.pinCode) {
          _ref.read(incomingRemotePairProvider.notifier).setRequest(null);
        }
        showToast(currentAppL10n.remotePairCancelledByClient);
      }

      request.response.statusCode = HttpStatus.ok;
      request.response.write(jsonEncode({'success': true}));
      await request.response.close();
    } catch (e) {
      debugPrint('[RemoteControlService] Error handling pair cancel: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      try {
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> handleWebSocketUpgrade(HttpRequest request) async {
    final settings = _ref.read(settingsServiceProvider);
    if (!settings.allowRemoteControl) {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
      return;
    }

    final token = request.uri.queryParameters['token'] ?? '';
    final senderName = request.uri.queryParameters['senderName'] ?? 'Remote Device';
    final deviceType = request.uri.queryParameters['deviceType'] ?? 'unknown';

    final isTrusted = _trustedDevices.any((d) => d.token == token);
    final isTemporary = _temporaryAuthTokens.containsKey(token);
    if (!isTrusted && !isTemporary) {
      request.response.statusCode = HttpStatus.unauthorized;
      await request.response.close();
      return;
    }

    try {
      final socket = await WebSocketTransformer.upgrade(request);
      final clientInfo = ConnectedHostClient(
        name: senderName,
        isTrusted: isTrusted,
        deviceType: deviceType,
        token: token,
      );
      _hostClientSockets[socket] = clientInfo;
      _ref.read(hostConnectedClientsProvider.notifier).addClient(clientInfo);
      if (isTemporary) {
        _temporaryAuthTokens.remove(token);
      }

      // Send initial playback state immediately
      final initialSnapshot = _ref.read(audioSnapshotProvider);
      final initialState = buildCurrentPlaybackState(initialSnapshot);
      socket.add(jsonEncode({
        'type': 'state_sync',
        'state': initialState.toJson(),
      }));

      socket.listen(
        (data) {
          try {
            final json = jsonDecode(data.toString()) as Map<String, dynamic>;
            final type = json['type'] as String? ?? '';
            if (type == 'command') {
              final cmd = RemoteCommand.fromJson(json);
              _executeRemoteCommand(cmd);
            }
          } catch (e) {
            debugPrint('[RemoteControlService] Error parsing remote command: $e');
          }
        },
        onDone: () {
          final client = _hostClientSockets.remove(socket);
          if (client != null) {
            _ref.read(hostConnectedClientsProvider.notifier).removeClient(client);
          }
        },
        onError: (err) {
          final client = _hostClientSockets.remove(socket);
          if (client != null) {
            _ref.read(hostConnectedClientsProvider.notifier).removeClient(client);
          }
        },
      );
    } catch (e) {
      debugPrint('[RemoteControlService] Failed to upgrade WebSocket: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      try {
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> handleCoverRequest(HttpRequest request) async {
    try {
      final settings = _ref.read(settingsServiceProvider);
      if (!settings.allowRemoteControl) {
        request.response.statusCode = HttpStatus.forbidden;
        await request.response.close();
        return;
      }

      final token = request.uri.queryParameters['token'] ?? '';
      if (!isValidToken(token)) {
        request.response.statusCode = HttpStatus.unauthorized;
        await request.response.close();
        return;
      }

      final snap = _ref.read(audioSnapshotProvider);
      final currentMusic = snap.currentMusic;

      if (currentMusic == null) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      Uint8List? artworkBytes = currentMusic.artworkBytes;
      if (artworkBytes == null || artworkBytes.isEmpty) {
        artworkBytes = _ref.read(audioServiceProvider).getCachedArtwork(currentMusic.path);
      }

      if ((artworkBytes == null || artworkBytes.isEmpty) && currentMusic.thumbnailPath != null) {
        final file = File(currentMusic.thumbnailPath!);
        if (file.existsSync()) {
          artworkBytes = await file.readAsBytes();
        }
      }

      if ((artworkBytes == null || artworkBytes.isEmpty) && currentMusic.artworkPath != null) {
        final file = File(currentMusic.artworkPath!);
        if (file.existsSync()) {
          artworkBytes = await file.readAsBytes();
        }
      }

      if (artworkBytes != null && artworkBytes.isNotEmpty) {
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType('image', 'jpeg');
        request.response.headers.add('Cache-Control', 'no-cache');
        request.response.add(artworkBytes);
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
      await request.response.close();
    } catch (e) {
      debugPrint('[RemoteControlService] Error serving cover: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      try {
        await request.response.close();
      } catch (_) {}
    }
  }

  void _executeRemoteCommand(RemoteCommand cmd) {
    final audio = _ref.read(audioServiceProvider);
    final playlist = _ref.read(playlistServiceProvider);
    final snapshot = _ref.read(audioSnapshotProvider);
    final isPlaying = snapshot.isPlaying;
    final currentMusic = snapshot.currentMusic;

    switch (cmd.action) {
      case 'play':
        if (!isPlaying) {
          audio.togglePlay();
        }
        break;
      case 'pause':
        if (isPlaying) {
          audio.togglePlay();
        }
        break;
      case 'togglePlay':
        audio.togglePlay();
        break;
      case 'next':
        audio.next();
        break;
      case 'previous':
        audio.previous();
        break;

      case 'toggleFavorite':
        if (currentMusic != null) {
          playlist.toggleFavoriteSong(currentMusic);
          // Broadcast immediately with toggled state
          Future.microtask(() => _broadcastCurrentStateToClients());
        }
        break;
      case 'toggleRandomMode':
        audio.toggleRandomMode();
        break;
      case 'setPlaybackMode':
        final modeStr = cmd.params['mode'] as String?;
        if (modeStr != null) {
          for (final m in AppPlaybackMode.values) {
            if (m.name == modeStr) {
              audio.setPlaybackMode(m);
              break;
            }
          }
        }
        break;
      case 'seek':
        final posMs = cmd.params['positionMs'] as int?;
        if (posMs != null) {
          audio.seek(Duration(milliseconds: posMs));
        }
        break;
      case 'playQueueIndex':
        final index = cmd.params['index'] as int?;
        if (index != null) {
          audio.playAtIndex(index);
        }
        break;
      case 'removeFromQueue':
        final index = cmd.params['index'] as int?;
        if (index != null) {
          audio.removeFromPlaylist(index);
        }
        break;
      case 'reorderQueue':
        final oldIndex = cmd.params['oldIndex'] as int?;
        final newIndex = cmd.params['newIndex'] as int?;
        if (oldIndex != null && newIndex != null) {
          audio.moveQueueTrack(oldIndex, newIndex);
        }
        break;
      case 'clearQueue':
        audio.clearPlaylist();
        break;
      case 'setVolume':
        final vol = (cmd.params['volume'] as num?)?.toDouble();
        if (vol != null) {
          audio.setVolume(vol, showVolumeHud: false);
        }
        break;
      case 'toggleMute':
        audio.toggleMute();
        break;
    }
  }

  void disconnectAllHostClients() {
    _closeAllHostSockets();
  }

  void _closeAllHostSockets() {
    for (final socket in _hostClientSockets.keys) {
      try {
        socket.close();
      } catch (_) {}
    }
    _hostClientSockets.clear();
    _ref.read(hostConnectedClientsProvider.notifier).clear();
  }

  // --- Client Implementation ---

  Future<String?> initiatePairing({
    required LanDevice targetDevice,
    required String senderId,
    required String senderName,
    required String deviceType,
  }) async {
    final fingerprint = targetDevice.certFingerprint ??
        _trustedDevices.where((d) => d.id == targetDevice.id).firstOrNull?.certFingerprint;
    if (fingerprint != null && fingerprint.isNotEmpty) {
      TlsCertificateService.registerDeviceFingerprint(targetDevice.id, fingerprint);
      TlsCertificateService.registerDeviceFingerprint(targetDevice.ip, fingerprint);
    }

    final client = TlsCertificateService.createPinnedHttpClient(
      expectedFingerprint: fingerprint,
    );
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      // Find existing token if trusted
      final existingIndex = _trustedDevices.indexWhere((d) => d.id == targetDevice.id);
      String? existingToken;
      if (existingIndex != -1) {
        final existing = _trustedDevices[existingIndex];
        // Security check:
        // 1. If existing record has no certFingerprint (legacy token from older unpinned version),
        //    we MUST NOT send the auth token to an unauthenticated TLS host (prevents token leakage to spoofed mDNS services).
        // 2. If both records have fingerprints but they don't match, target device's identity has changed.
        // In either case, invalidate legacy/mismatched trust and require fresh PIN verification.
        if (existing.certFingerprint == null ||
            (targetDevice.certFingerprint != null &&
                existing.certFingerprint != targetDevice.certFingerprint)) {
          debugPrint(
            '[RemoteControlService] Security notice: Fingerprint missing or mismatch for trusted device ${targetDevice.name} '
            '(Saved: ${existing.certFingerprint}, Discovered: ${targetDevice.certFingerprint}). '
            'Requiring fresh PIN re-pairing before re-authorizing.',
          );
          _trustedDevices.removeAt(existingIndex);
          await _saveTrustedDevices();
        } else {
          existingToken = existing.token;
        }
      }

      final uri = Uri.parse(
        'https://${formatHostForUrl(targetDevice.ip)}:${targetDevice.httpPort}/api/remote/pair',
      );
      final req = await client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({
        'sender_id': senderId,
        'sender_name': senderName,
        'device_type': deviceType,
        'auth_token': existingToken ?? '',
      }));

      final res = await req.close();
      final body = await utf8.decoder.bind(res).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (res.statusCode == HttpStatus.forbidden || json['success'] == false) {
        final reason = json['reason'] as String? ?? 'remote_control_disabled';
        throw Exception(reason);
      }

      if (json['trusted'] == true && json['token'] != null) {
        _clientAuthToken = json['token'] as String;
        return null; // Ready to connect without PIN
      }

      if (json['require_pin'] == true && json['session_token'] != null) {
        return json['session_token'] as String; // Needs PIN input
      }

      throw Exception(json['reason'] as String? ?? 'Pairing initialization failed');
    } catch (e) {
      debugPrint('[RemoteControlService] Error initiating pairing: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<({
    bool success,
    bool rejected,
    bool invalidated,
    int cooldownSeconds,
    int? remainingAttempts,
  })> verifyPinAndGetToken({
    required LanDevice targetDevice,
    required String sessionToken,
    required String pin,
  }) async {
    final fingerprint = targetDevice.certFingerprint ??
        _trustedDevices.where((d) => d.id == targetDevice.id).firstOrNull?.certFingerprint;
    if (fingerprint != null && fingerprint.isNotEmpty) {
      TlsCertificateService.registerDeviceFingerprint(targetDevice.id, fingerprint);
      TlsCertificateService.registerDeviceFingerprint(targetDevice.ip, fingerprint);
    }

    final client = TlsCertificateService.createPinnedHttpClient(
      expectedFingerprint: fingerprint,
    );
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      final uri = Uri.parse(
        'https://${formatHostForUrl(targetDevice.ip)}:${targetDevice.httpPort}/api/remote/pair/verify',
      );
      final req = await client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({
        'session_token': sessionToken,
        'pin': pin.trim(),
      }));

      final res = await req.close();
      final body = await utf8.decoder.bind(res).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (json['success'] == true && json['token'] != null) {
        _clientAuthToken = json['token'] as String;
        final isTrusted = json['is_trusted'] == true;
        if (isTrusted) {
          // Save to trusted devices on client side
          _trustedDevices.removeWhere((d) => d.id == targetDevice.id);
          _trustedDevices.add(
            TrustedRemoteDevice(
              id: targetDevice.id,
              name: targetDevice.name,
              deviceType: targetDevice.deviceType,
              token: _clientAuthToken!,
              pairedAt: DateTime.now(),
              certFingerprint: targetDevice.certFingerprint ?? fingerprint,
            ),
          );
          await _saveTrustedDevices();
        } else {
          // If not trusted by host, remove from client trusted list as well
          _trustedDevices.removeWhere((d) => d.id == targetDevice.id);
          await _saveTrustedDevices();
        }
        return (
          success: true,
          rejected: false,
          invalidated: false,
          cooldownSeconds: 0,
          remainingAttempts: null,
        );
      }
      final rejected = json['rejected'] == true || json['reason'] == 'rejected_by_host';
      final invalidated = json['invalidated'] == true ||
          json['reason'] == 'too_many_attempts' ||
          json['reason'] == 'Session expired or not found' ||
          json['reason'] == 'Session timed out';
      final cooldownSeconds = (json['cooldown_seconds'] as num?)?.toInt() ?? (json['cooldown'] == true ? 2 : 0);
      final remainingAttempts = (json['remaining_attempts'] as num?)?.toInt();

      return (
        success: false,
        rejected: rejected,
        invalidated: invalidated,
        cooldownSeconds: cooldownSeconds,
        remainingAttempts: remainingAttempts,
      );
    } catch (e) {
      debugPrint('[RemoteControlService] Error verifying PIN: $e');
      return (
        success: false,
        rejected: false,
        invalidated: false,
        cooldownSeconds: 0,
        remainingAttempts: null,
      );
    } finally {
      client.close();
    }
  }

  Future<void> cancelPairing({
    required LanDevice targetDevice,
    required String sessionToken,
  }) async {
    final fingerprint = targetDevice.certFingerprint ??
        _trustedDevices.where((d) => d.id == targetDevice.id).firstOrNull?.certFingerprint;
    final client = TlsCertificateService.createPinnedHttpClient(
      expectedFingerprint: fingerprint,
    );
    client.connectionTimeout = const Duration(seconds: 3);

    try {
      final uri = Uri.parse(
        'https://${formatHostForUrl(targetDevice.ip)}:${targetDevice.httpPort}/api/remote/pair/cancel',
      );
      final req = await client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({
        'session_token': sessionToken,
      }));
      final res = await req.close();
      await res.drain();
    } catch (e) {
      debugPrint('[RemoteControlService] Error cancelling pairing: $e');
    } finally {
      client.close();
    }
  }

  Future<bool> connectWebSocket({
    required LanDevice targetDevice,
    required String senderName,
  }) async {
    final token = _clientAuthToken ?? getTrustedTokenForDevice(targetDevice.id);
    if (token == null || token.isEmpty) return false;
    _clientAuthToken = token;

    try {
      disconnectClient(clearToken: false);

      final fingerprint = targetDevice.certFingerprint ??
          _trustedDevices.where((d) => d.id == targetDevice.id).firstOrNull?.certFingerprint;
      if (fingerprint != null && fingerprint.isNotEmpty) {
        TlsCertificateService.registerDeviceFingerprint(targetDevice.id, fingerprint);
        TlsCertificateService.registerDeviceFingerprint(targetDevice.ip, fingerprint);
      }

      final pinnedClient = TlsCertificateService.createPinnedHttpClient(
        expectedFingerprint: fingerprint,
      );
      pinnedClient.connectionTimeout = const Duration(seconds: 6);

      final wsUrl =
          'wss://${formatHostForUrl(targetDevice.ip)}:${targetDevice.httpPort}/api/remote/ws?token=${Uri.encodeComponent(token)}&senderName=${Uri.encodeComponent(senderName)}&deviceType=${Uri.encodeComponent(Platform.operatingSystem)}';
      
      final socket = await WebSocket.connect(
        wsUrl,
        customClient: pinnedClient,
      ).timeout(
        const Duration(seconds: 6),
      );

      _clientSocket = socket;
      _controllingDevice = targetDevice;
      _ref.read(activeControllingDeviceProvider.notifier).setDevice(targetDevice);

      socket.listen(
        (data) {
          try {
            final json = jsonDecode(data.toString()) as Map<String, dynamic>;
            final type = json['type'] as String? ?? '';
            if (type == 'state_sync') {
              final stateMap = json['state'] as Map<String, dynamic>? ?? {};
              var state = RemotePlaybackState.fromJson(stateMap);

              // Check if we recently performed an optimistic seek
              if (_lastSeekTime != null && _lastSeekPositionMs != null) {
                final elapsed = DateTime.now().difference(_lastSeekTime!).inMilliseconds;
                final isSameTrack = _lastSeekTrackTitle == null || _lastSeekTrackTitle == state.title;

                if (isSameTrack && elapsed < 1500) {
                  final diff = (state.positionMs - _lastSeekPositionMs!).abs();
                  if (diff > 1500) {
                    // Host has not applied seek yet, retain optimistic progress
                    final optimisticPos = state.isPlaying
                        ? (_lastSeekPositionMs! + elapsed).clamp(0, state.durationMs)
                        : _lastSeekPositionMs!;
                    state = state.copyWith(
                      positionMs: optimisticPos,
                      syncedAt: DateTime.now(),
                    );
                  } else {
                    // Host has caught up to the sought position, release seek lock
                    _lastSeekTime = null;
                    _lastSeekPositionMs = null;
                    _lastSeekTrackTitle = null;
                  }
                } else {
                  _lastSeekTime = null;
                  _lastSeekPositionMs = null;
                  _lastSeekTrackTitle = null;
                }
              }

              _ref.read(remotePlaybackStateProvider.notifier).setState(state);
            }
          } catch (e) {
            debugPrint('[RemoteControlService] Error receiving state sync: $e');
          }
        },
        onDone: () {
          debugPrint('[RemoteControlService] Remote connection closed.');
          disconnectClient(clearToken: false);
        },
        onError: (err) {
          debugPrint('[RemoteControlService] Remote connection error: $err');
          disconnectClient(clearToken: false);
        },
      );

      // Setup ping timer
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        try {
          _clientSocket?.add(jsonEncode({'type': 'ping'}));
        } catch (_) {}
      });

      return true;
    } catch (e) {
      debugPrint('[RemoteControlService] Error connecting WebSocket: $e');
      disconnectClient(clearToken: false);
      return false;
    }
  }

  void sendCommand(RemoteCommand cmd) {
    if (_clientSocket != null) {
      try {
        _clientSocket!.add(jsonEncode(cmd.toJson()));
      } catch (e) {
        debugPrint('[RemoteControlService] Error sending command: $e');
      }
    }
  }

  void togglePlayPause() => sendCommand(RemoteCommand.togglePlay());
  void play() => sendCommand(RemoteCommand.play());
  void pause() => sendCommand(RemoteCommand.pause());

  void next() => sendCommand(RemoteCommand.next());
  void previous() => sendCommand(RemoteCommand.previous());

  void toggleFavorite() => sendCommand(RemoteCommand.toggleFavorite());
  void toggleRandomMode() => sendCommand(RemoteCommand.toggleRandomMode());
  void setPlaybackMode(AppPlaybackMode mode) => sendCommand(RemoteCommand.setPlaybackMode(mode));

  void seek(Duration position) {
    final currentState = _ref.read(remotePlaybackStateProvider);
    if (currentState != null) {
      _lastSeekTime = DateTime.now();
      _lastSeekPositionMs = position.inMilliseconds;
      _lastSeekTrackTitle = currentState.title;
      _ref.read(remotePlaybackStateProvider.notifier).setState(
        currentState.copyWith(
          positionMs: position.inMilliseconds,
          syncedAt: DateTime.now(),
        ),
      );
    }
    sendCommand(RemoteCommand.seek(position.inMilliseconds));
  }

  void playQueueIndex(int index) => sendCommand(RemoteCommand.playQueueIndex(index));
  void removeFromQueue(int index) => sendCommand(RemoteCommand.removeFromQueue(index));
  void reorderQueue(int oldIndex, int newIndex) => sendCommand(RemoteCommand.reorderQueue(oldIndex, newIndex));
  void clearQueue() => sendCommand(RemoteCommand.clearQueue());

  void setVolume(double volume) => sendCommand(RemoteCommand.setVolume(volume));

  void toggleMute() => sendCommand(RemoteCommand.toggleMute());

  void disconnectClient({bool clearToken = false}) {
    _pingTimer?.cancel();
    _pingTimer = null;
    _lastSeekTime = null;
    _lastSeekPositionMs = null;
    _lastSeekTrackTitle = null;
    try {
      _clientSocket?.close();
    } catch (_) {}
    _clientSocket = null;
    _controllingDevice = null;
    if (clearToken) {
      _clientAuthToken = null;
    }
    _ref.read(activeControllingDeviceProvider.notifier).setDevice(null);
    _ref.read(remotePlaybackStateProvider.notifier).setState(null);
  }
}
