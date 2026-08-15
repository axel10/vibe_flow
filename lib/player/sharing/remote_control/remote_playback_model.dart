import 'package:vynody/player/audio/app_playback_mode.dart';

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
  });

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
}

class TrustedRemoteDevice {
  final String id;
  final String name;
  final String deviceType;
  final String token;
  final DateTime pairedAt;

  TrustedRemoteDevice({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.token,
    required this.pairedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'deviceType': deviceType,
    'token': token,
    'pairedAt': pairedAt.toIso8601String(),
  };

  factory TrustedRemoteDevice.fromJson(Map<String, dynamic> json) {
    return TrustedRemoteDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      deviceType: json['deviceType'] as String? ?? 'unknown',
      token: json['token'] as String? ?? '',
      pairedAt: DateTime.tryParse(json['pairedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
