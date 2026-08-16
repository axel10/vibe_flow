import 'package:vynody/player/audio/app_playback_mode.dart';

class RemoteQueueItem {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String path;

  const RemoteQueueItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.path,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'durationMs': durationMs,
    'path': path,
  };

  factory RemoteQueueItem.fromJson(Map<String, dynamic> json) {
    return RemoteQueueItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String? ?? '',
      durationMs: json['durationMs'] as int? ?? 0,
      path: json['path'] as String? ?? '',
    );
  }
}

class RemotePlaybackState {
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final int positionMs;
  final bool isPlaying;
  final bool isFavorite;
  final AppPlaybackMode playbackMode;
  final bool isRandomMode;
  final String? hostDeviceName;
  final List<RemoteQueueItem> queue;
  final int currentIndex;
  final double volume;
  final DateTime? syncedAt;

  const RemotePlaybackState({
    this.title = '',
    this.artist = '',
    this.album = '',
    this.durationMs = 0,
    this.positionMs = 0,
    this.isPlaying = false,
    this.isFavorite = false,
    this.playbackMode = AppPlaybackMode.queueLoop,
    this.isRandomMode = false,
    this.hostDeviceName,
    this.queue = const [],
    this.currentIndex = -1,
    this.volume = 100.0,
    this.syncedAt,
  });

  int get estimatedPositionMs {
    if (!isPlaying || durationMs <= 0) return positionMs;
    final timestamp = syncedAt;
    if (timestamp == null) return positionMs;
    final elapsedMs = DateTime.now().difference(timestamp).inMilliseconds;
    if (elapsedMs <= 0) return positionMs;
    final est = positionMs + elapsedMs;
    return est.clamp(0, durationMs);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'durationMs': durationMs,
      'positionMs': positionMs,
      'isPlaying': isPlaying,
      'isFavorite': isFavorite,
      'playbackMode': playbackMode.name,
      'isRandomMode': isRandomMode,
      if (hostDeviceName != null) 'hostDeviceName': hostDeviceName,
      'queue': queue.map((q) => q.toJson()).toList(),
      'currentIndex': currentIndex,
      'volume': volume,
    };
  }

  factory RemotePlaybackState.fromJson(Map<String, dynamic> json) {
    AppPlaybackMode mode = AppPlaybackMode.queueLoop;
    final modeStr = json['playbackMode'] as String?;
    if (modeStr != null) {
      for (final m in AppPlaybackMode.values) {
        if (m.name == modeStr) {
          mode = m;
          break;
        }
      }
    }

    final rawQueue = json['queue'] as List<dynamic>? ?? const [];
    final queue = rawQueue
        .whereType<Map<String, dynamic>>()
        .map(RemoteQueueItem.fromJson)
        .toList();

    return RemotePlaybackState(
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String? ?? '',
      durationMs: json['durationMs'] as int? ?? 0,
      positionMs: json['positionMs'] as int? ?? 0,
      isPlaying: json['isPlaying'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      playbackMode: mode,
      isRandomMode: json['isRandomMode'] as bool? ?? false,
      hostDeviceName: json['hostDeviceName'] as String?,
      queue: queue,
      currentIndex: json['currentIndex'] as int? ?? -1,
      volume: (json['volume'] as num?)?.toDouble() ?? 100.0,
      syncedAt: DateTime.now(),
    );
  }

  RemotePlaybackState copyWith({
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    int? positionMs,
    bool? isPlaying,
    bool? isFavorite,
    AppPlaybackMode? playbackMode,
    bool? isRandomMode,
    String? hostDeviceName,
    List<RemoteQueueItem>? queue,
    int? currentIndex,
    double? volume,
    DateTime? syncedAt,
  }) {
    return RemotePlaybackState(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      positionMs: positionMs ?? this.positionMs,
      isPlaying: isPlaying ?? this.isPlaying,
      isFavorite: isFavorite ?? this.isFavorite,
      playbackMode: playbackMode ?? this.playbackMode,
      isRandomMode: isRandomMode ?? this.isRandomMode,
      hostDeviceName: hostDeviceName ?? this.hostDeviceName,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      volume: volume ?? this.volume,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

class RemoteCommand {
  final String action;
  final Map<String, dynamic> params;

  const RemoteCommand({
    required this.action,
    this.params = const {},
  });

  Map<String, dynamic> toJson() => {
    'type': 'command',
    'action': action,
    'params': params,
  };

  factory RemoteCommand.fromJson(Map<String, dynamic> json) {
    return RemoteCommand(
      action: json['action'] as String? ?? '',
      params: (json['params'] as Map<String, dynamic>?) ?? {},
    );
  }

  static RemoteCommand play() => const RemoteCommand(action: 'play');
  static RemoteCommand pause() => const RemoteCommand(action: 'pause');
  static RemoteCommand togglePlay() => const RemoteCommand(action: 'togglePlay');
  static RemoteCommand next() => const RemoteCommand(action: 'next');
  static RemoteCommand previous() => const RemoteCommand(action: 'previous');
  static RemoteCommand toggleFavorite() => const RemoteCommand(action: 'toggleFavorite');
  static RemoteCommand toggleRandomMode() => const RemoteCommand(action: 'toggleRandomMode');
  static RemoteCommand setPlaybackMode(AppPlaybackMode mode) => RemoteCommand(
    action: 'setPlaybackMode',
    params: {'mode': mode.name},
  );
  static RemoteCommand seek(int positionMs) => RemoteCommand(
    action: 'seek',
    params: {'positionMs': positionMs},
  );
  static RemoteCommand playQueueIndex(int index) => RemoteCommand(
    action: 'playQueueIndex',
    params: {'index': index},
  );
  static RemoteCommand removeFromQueue(int index) => RemoteCommand(
    action: 'removeFromQueue',
    params: {'index': index},
  );
  static RemoteCommand reorderQueue(int oldIndex, int newIndex) => RemoteCommand(
    action: 'reorderQueue',
    params: {'oldIndex': oldIndex, 'newIndex': newIndex},
  );
  static RemoteCommand clearQueue() => const RemoteCommand(action: 'clearQueue');
  static RemoteCommand setVolume(double volume) => RemoteCommand(
    action: 'setVolume',
    params: {'volume': volume},
  );
}

class TrustedRemoteDevice {
  final String id;
  final String name;
  final String deviceType;
  final String token;
  final DateTime pairedAt;
  final String? certFingerprint;

  TrustedRemoteDevice({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.token,
    required this.pairedAt,
    this.certFingerprint,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'deviceType': deviceType,
    'token': token,
    'pairedAt': pairedAt.toIso8601String(),
    if (certFingerprint != null) 'certFingerprint': certFingerprint,
  };

  factory TrustedRemoteDevice.fromJson(Map<String, dynamic> json) {
    return TrustedRemoteDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      deviceType: json['deviceType'] as String? ?? 'unknown',
      token: json['token'] as String? ?? '',
      pairedAt: DateTime.tryParse(json['pairedAt'] as String? ?? '') ?? DateTime.now(),
      certFingerprint: json['certFingerprint'] as String?,
    );
  }
}

class ConnectedHostClient {
  final String name;
  final bool isTrusted;
  final String deviceType;
  final String? token;

  const ConnectedHostClient({
    required this.name,
    this.isTrusted = false,
    this.deviceType = 'unknown',
    this.token,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectedHostClient &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          isTrusted == other.isTrusted &&
          deviceType == other.deviceType &&
          token == other.token;

  @override
  int get hashCode =>
      name.hashCode ^ isTrusted.hashCode ^ deviceType.hashCode ^ token.hashCode;
}
