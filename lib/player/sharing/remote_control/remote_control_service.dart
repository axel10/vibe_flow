import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/audio/audio_snapshot.dart';
import 'package:vynody/player/sharing/lan_device.dart';
import 'package:vynody/player/sharing/sharing_service.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';
import 'remote_playback_model.dart';

class IncomingRemotePairRequest {
  final String senderId;
  final String senderName;
  final String deviceType;
  final String pinCode;
  final void Function(bool accepted) onDecision;

  IncomingRemotePairRequest({
    required this.senderId,
    required this.senderName,
    required this.deviceType,
    required this.pinCode,
    required this.onDecision,
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

class HostConnectedClientsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];
  void addClient(String name) => state = [...state, name];
  void removeClient(String name) => state = state.where((n) => n != name).toList();
  void clear() => state = [];
}

final hostConnectedClientsProvider =
    NotifierProvider<HostConnectedClientsNotifier, List<String>>(
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

  _PendingPairSession({
    required this.senderId,
    required this.senderName,
    required this.deviceType,
    required this.pinCode,
    required this.sessionToken,
    required this.completer,
    required this.createdAt,
  });
}

class RemoteControlService {
  final Ref _ref;

  // Host state
  final Map<String, _PendingPairSession> _pendingPairSessions = {};
  final Map<WebSocket, String> _hostClientSockets = {};
  final List<TrustedRemoteDevice> _trustedDevices = [];
  ProviderSubscription<AudioSnapshot>? _audioSubscription;

  // Client state
  WebSocket? _clientSocket;
  LanDevice? _controllingDevice;
  String? _clientAuthToken;
  Timer? _pingTimer;

  RemoteControlService(this._ref);

  List<TrustedRemoteDevice> get trustedDevices => List.unmodifiable(_trustedDevices);
  LanDevice? get controllingDevice => _controllingDevice;
  bool get isControllingRemote => _clientSocket != null && _controllingDevice != null;
  bool get hasActiveHostClients => _hostClientSockets.isNotEmpty;

  Future<void> init() async {
    await _loadTrustedDevices();
    _listenLocalAudioState();
  }

  void dispose() {
    _audioSubscription?.close();
    _audioSubscription = null;
    disconnectClient();
    _closeAllHostSockets();
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
          _trustedDevices.add(TrustedRemoteDevice.fromJson(map));
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
      final name = _hostClientSockets.remove(dead);
      if (name != null) {
        _ref.read(hostConnectedClientsProvider.notifier).removeClient(name);
      }
      try {
        dead.close();
      } catch (_) {}
    }
  }

  Future<void> handlePairRequest(HttpRequest request) async {
    try {
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
      );

      _pendingPairSessions[sessionToken] = session;

      // Trigger UI dialog on host
      _ref.read(incomingRemotePairProvider.notifier).setRequest(
        IncomingRemotePairRequest(
          senderId: senderId,
          senderName: senderName,
          deviceType: deviceType,
          pinCode: pin,
          onDecision: (accepted) {
            if (!completer.isCompleted) {
              completer.complete(accepted);
            }
            _ref.read(incomingRemotePairProvider.notifier).setRequest(null);
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
      final inputPin = json['pin'] as String? ?? '';

      final session = _pendingPairSessions[sessionToken];
      if (session == null) {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write(jsonEncode({
          'success': false,
          'reason': 'Session expired or not found',
        }));
        await request.response.close();
        return;
      }

      bool verified = false;
      if (session.completer.isCompleted) {
        // Already accepted via host dialog directly
        verified = await session.completer.future;
      } else {
        // Verify PIN
        if (session.pinCode == inputPin.trim()) {
          verified = true;
          session.completer.complete(true);
          _ref.read(incomingRemotePairProvider.notifier).setRequest(null);
        }
      }

      if (verified) {
        _pendingPairSessions.remove(sessionToken);

        final token = 'auth_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}';
        
        // Add to trusted devices
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

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({
          'success': true,
          'token': token,
        }));
      } else {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.write(jsonEncode({
          'success': false,
          'reason': 'Invalid PIN',
        }));
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

  Future<void> handleWebSocketUpgrade(HttpRequest request) async {
    final token = request.uri.queryParameters['token'] ?? '';
    final senderName = request.uri.queryParameters['senderName'] ?? 'Remote Device';

    final isTrusted = _trustedDevices.any((d) => d.token == token);
    if (!isTrusted) {
      request.response.statusCode = HttpStatus.unauthorized;
      await request.response.close();
      return;
    }

    try {
      final socket = await WebSocketTransformer.upgrade(request);
      _hostClientSockets[socket] = senderName;
      _ref.read(hostConnectedClientsProvider.notifier).addClient(senderName);

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
          final name = _hostClientSockets.remove(socket);
          if (name != null) {
            _ref.read(hostConnectedClientsProvider.notifier).removeClient(name);
          }
        },
        onError: (err) {
          final name = _hostClientSockets.remove(socket);
          if (name != null) {
            _ref.read(hostConnectedClientsProvider.notifier).removeClient(name);
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
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      // Find existing token if trusted
      final existing = _trustedDevices.firstWhere(
        (d) => d.id == targetDevice.id,
        orElse: () => TrustedRemoteDevice(
          id: '',
          name: '',
          deviceType: '',
          token: '',
          pairedAt: DateTime.now(),
        ),
      );

      final uri = Uri.parse(
        'http://${formatHostForUrl(targetDevice.ip)}:${targetDevice.httpPort}/api/remote/pair',
      );
      final req = await client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({
        'sender_id': senderId,
        'sender_name': senderName,
        'device_type': deviceType,
        'auth_token': existing.token,
      }));

      final res = await req.close();
      final body = await utf8.decoder.bind(res).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (json['trusted'] == true && json['token'] != null) {
        _clientAuthToken = json['token'] as String;
        return null; // Ready to connect without PIN
      }

      if (json['require_pin'] == true && json['session_token'] != null) {
        return json['session_token'] as String; // Needs PIN input
      }

      return null;
    } catch (e) {
      debugPrint('[RemoteControlService] Error initiating pairing: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<bool> verifyPinAndGetToken({
    required LanDevice targetDevice,
    required String sessionToken,
    required String pin,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      final uri = Uri.parse(
        'http://${formatHostForUrl(targetDevice.ip)}:${targetDevice.httpPort}/api/remote/pair/verify',
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
        // Save to trusted devices on client side as well
        _trustedDevices.removeWhere((d) => d.id == targetDevice.id);
        _trustedDevices.add(
          TrustedRemoteDevice(
            id: targetDevice.id,
            name: targetDevice.name,
            deviceType: targetDevice.deviceType,
            token: _clientAuthToken!,
            pairedAt: DateTime.now(),
          ),
        );
        await _saveTrustedDevices();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[RemoteControlService] Error verifying PIN: $e');
      return false;
    } finally {
      client.close();
    }
  }

  Future<bool> connectWebSocket({
    required LanDevice targetDevice,
    required String senderName,
  }) async {
    if (_clientAuthToken == null) return false;

    try {
      disconnectClient();

      final wsUrl =
          'ws://${formatHostForUrl(targetDevice.ip)}:${targetDevice.httpPort}/api/remote/ws?token=$_clientAuthToken&senderName=${Uri.encodeComponent(senderName)}';
      
      final socket = await WebSocket.connect(wsUrl).timeout(
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
              final state = RemotePlaybackState.fromJson(stateMap);
              _ref.read(remotePlaybackStateProvider.notifier).setState(state);
            }
          } catch (e) {
            debugPrint('[RemoteControlService] Error receiving state sync: $e');
          }
        },
        onDone: () {
          debugPrint('[RemoteControlService] Remote connection closed.');
          disconnectClient();
        },
        onError: (err) {
          debugPrint('[RemoteControlService] Remote connection error: $err');
          disconnectClient();
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
      disconnectClient();
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
  void seek(Duration position) => sendCommand(RemoteCommand.seek(position.inMilliseconds));

  void disconnectClient() {
    _pingTimer?.cancel();
    _pingTimer = null;
    try {
      _clientSocket?.close();
    } catch (_) {}
    _clientSocket = null;
    _controllingDevice = null;
    _ref.read(activeControllingDeviceProvider.notifier).setDevice(null);
    _ref.read(remotePlaybackStateProvider.notifier).setState(null);
  }
}
