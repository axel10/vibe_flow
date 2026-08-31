import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_core/audio_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/audio/playback_source.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';

class RandomPlaybackData {
  const RandomPlaybackData({
    required this.enabled,
    required this.history,
    required this.historyCursor,
    required this.deck,
    required this.deckCursor,
    required this.deckSignature,
    required this.stashedNextTrackId,
    required this.stashedForTrackId,
  });

  final bool enabled;
  final List<RandomHistoryEntry> history;
  final int? historyCursor;
  final List<String> deck;
  final int? deckCursor;
  final String? deckSignature;
  final String? stashedNextTrackId;
  final String? stashedForTrackId;
}

class PlaybackSessionData {
  const PlaybackSessionData({
    required this.queue,
    required this.currentIndex,
    required this.positionMs,
    required this.playbackMode,
    required this.randomPlayback,
    this.source,
  });

  final List<MusicFile> queue;
  final int currentIndex;
  final int positionMs;
  final AppPlaybackMode playbackMode;
  final PlaybackSource? source;
  final RandomPlaybackData randomPlayback;
}

class PlaybackSessionManager {
  static const _storageKey = 'playback_session_v1';
  static const _autoSaveInterval = Duration(seconds: 2);

  Timer? _autoSaveTimer;
  bool _disposed = false;

  Future<PlaybackSessionData?> loadFromPrefs(SharedPreferences prefs) async {
    final rawSession = prefs.getString(_storageKey);
    if (rawSession == null || rawSession.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawSession);
    if (decoded is! Map) {
      await prefs.remove(_storageKey);
      return null;
    }

    final session = _SessionState.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
    if (session.version != 1 || session.queue.isEmpty) {
      await prefs.remove(_storageKey);
      return null;
    }

    return session.toData();
  }

  Future<void> saveToPrefs(
    SharedPreferences prefs,
    PlaybackSessionData data,
  ) async {
    final session = _SessionState.fromData(data);
    await prefs.setString(_storageKey, jsonEncode(session.toJson()));
  }

  Future<void> clearFromPrefs(SharedPreferences prefs) async {
    await prefs.remove(_storageKey);
  }

  void ensureAutoSaveTimer(VoidCallback onSave) {
    if (_disposed) return;
    _autoSaveTimer ??= Timer.periodic(_autoSaveInterval, (_) => onSave());
  }

  void stopAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  void dispose() {
    _disposed = true;
    stopAutoSaveTimer();
  }

  static Future<bool> songExists(String path) async {
    if (path.trim().isEmpty) return false;
    if (RemoteMediaResolver.isRemoteUri(path)) return true;
    if (path.startsWith('content://')) return true;
    return File(path).exists();
  }

  static Future<int> resolveRestoredQueueIndex(
    PlaybackSessionData session,
  ) async {
    if (session.queue.isEmpty) return -1;

    final preferredIndex = session.currentIndex.clamp(
      0,
      session.queue.length - 1,
    );
    if (await songExists(session.queue[preferredIndex].path)) {
      return preferredIndex;
    }

    for (var i = preferredIndex + 1; i < session.queue.length; i++) {
      if (await songExists(session.queue[i].path)) {
        return i;
      }
    }
    for (var i = 0; i < preferredIndex; i++) {
      if (await songExists(session.queue[i].path)) {
        return i;
      }
    }

    return -1;
  }
}

int _version = 1;

class _SessionState {
  const _SessionState({
    required this.version,
    required this.queue,
    required this.currentIndex,
    required this.positionMs,
    required this.playbackMode,
    required this.randomPlayback,
    this.source,
  });

  final int version;
  final List<MusicFile> queue;
  final int currentIndex;
  final int positionMs;
  final AppPlaybackMode playbackMode;
  final _RandomPlaybackState randomPlayback;
  final PlaybackSource? source;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': version,
      'queue': queue.map(_musicFileToSessionJson).toList(growable: false),
      'currentIndex': currentIndex,
      'positionMs': positionMs,
      'playbackMode': playbackMode.name,
      'randomPlayback': randomPlayback.toJson(),
      'source': source?.toJson(),
    };
  }

  factory _SessionState.fromJson(Map<String, dynamic> json) {
    final rawQueue = json['queue'];
    final queue = <MusicFile>[];
    if (rawQueue is List) {
      for (final item in rawQueue) {
        if (item is Map<String, dynamic>) {
          queue.add(_musicFileFromSessionJson(item));
        } else if (item is Map) {
          queue.add(
            _musicFileFromSessionJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        }
      }
    }

    final sourceJson = json['source'];
    final source = sourceJson != null
        ? PlaybackSource.fromJson(sourceJson as Map<String, dynamic>)
        : null;

    return _SessionState(
      version: (json['version'] as num?)?.toInt() ?? 1,
      queue: queue,
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? -1,
      positionMs: (json['positionMs'] as num?)?.toInt() ?? 0,
      playbackMode: _playbackModeFromStorage(json['playbackMode'] as String?),
      randomPlayback: _RandomPlaybackState.fromJson(
        (json['randomPlayback'] as Map? ?? const {}).map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      ),
      source: source,
    );
  }

  factory _SessionState.fromData(PlaybackSessionData data) {
    return _SessionState(
      version: _version,
      queue: List<MusicFile>.unmodifiable(data.queue),
      currentIndex: data.currentIndex,
      positionMs: data.positionMs,
      playbackMode: data.playbackMode,
      randomPlayback: _RandomPlaybackState(
        enabled: data.randomPlayback.enabled,
        history: data.randomPlayback.history
            .map(
              (entry) => _RandomHistoryEntryState(
                trackId: entry.trackId,
                playlistId: entry.playlistId,
                trackIndex: entry.trackIndex,
                generatedAtMillis: entry.generatedAt.millisecondsSinceEpoch,
                policyKey: entry.policyKey,
              ),
            )
            .toList(growable: false),
        historyCursor: data.randomPlayback.historyCursor,
        deck: List<String>.unmodifiable(data.randomPlayback.deck),
        deckCursor: data.randomPlayback.deckCursor,
        deckSignature: data.randomPlayback.deckSignature,
        stashedNextTrackId: data.randomPlayback.stashedNextTrackId,
        stashedForTrackId: data.randomPlayback.stashedForTrackId,
      ),
      source: data.source,
    );
  }

  PlaybackSessionData toData() {
    return PlaybackSessionData(
      queue: queue,
      currentIndex: currentIndex,
      positionMs: positionMs,
      playbackMode: playbackMode,
      source: source,
      randomPlayback: RandomPlaybackData(
        enabled: randomPlayback.enabled,
        history: randomPlayback.history
            .map((entry) => entry.toDomain())
            .toList(growable: false),
        historyCursor: randomPlayback.historyCursor,
        deck: randomPlayback.deck,
        deckCursor: randomPlayback.deckCursor,
        deckSignature: randomPlayback.deckSignature,
        stashedNextTrackId: randomPlayback.stashedNextTrackId,
        stashedForTrackId: randomPlayback.stashedForTrackId,
      ),
    );
  }
}

Map<String, Object?> _musicFileToSessionJson(MusicFile song) {
  return <String, Object?>{
    'path': song.path,
    'name': song.name,
    'title': song.title,
    'artist': song.artist,
    'album': song.album,
    'trackNumber': song.trackNumber,
    'id': song.id,
    'mediaUri': song.mediaUri,
    'thumbnailPath': song.thumbnailPath,
    'artworkPath': song.artworkPath,
    'artworkWidth': song.artworkWidth,
    'artworkHeight': song.artworkHeight,
    'durationMillis': song.durationMillis,
    'themeColorsBlob': song.themeColorsBlob == null
        ? null
        : base64Encode(song.themeColorsBlob!),
    'lastModifiedTime': song.lastModifiedTime,
    'isMissing': song.isMissing,
  };
}

MusicFile _musicFileFromSessionJson(Map<String, dynamic> json) {
  Uint8List? themeColorsBlob;
  final rawThemeColorsBlob = json['themeColorsBlob'];
  if (rawThemeColorsBlob is String && rawThemeColorsBlob.isNotEmpty) {
    themeColorsBlob = base64Decode(rawThemeColorsBlob);
  }

  return MusicFile(
    path: json['path'] as String? ?? '',
    name: json['name'] as String? ?? '',
    title: json['title'] as String?,
    artist: json['artist'] as String?,
    album: json['album'] as String?,
    trackNumber: (json['trackNumber'] as num?)?.toInt(),
    id: (json['id'] as num?)?.toInt(),
    mediaUri: json['mediaUri'] as String?,
    thumbnailPath: json['thumbnailPath'] as String?,
    artworkPath: json['artworkPath'] as String?,
    artworkWidth: (json['artworkWidth'] as num?)?.toInt(),
    artworkHeight: (json['artworkHeight'] as num?)?.toInt(),
    durationMillis: (json['durationMillis'] as num?)?.toInt(),
    themeColorsBlob: themeColorsBlob,
    lastModifiedTime: (json['lastModifiedTime'] as num?)?.toInt(),
    isMissing: json['isMissing'] as bool? ?? false,
  );
}

AppPlaybackMode _playbackModeFromStorage(String? value) {
  switch (value) {
    case 'single':
      return AppPlaybackMode.single;
    case 'singleLoop':
      return AppPlaybackMode.singleLoop;
    case 'queueLoop':
      return AppPlaybackMode.queueLoop;
    case 'autoQueueLoop':
      return AppPlaybackMode.autoQueueLoop;
    case 'queue':
    default:
      return AppPlaybackMode.queue;
  }
}

class _RandomHistoryEntryState {
  const _RandomHistoryEntryState({
    required this.trackId,
    required this.playlistId,
    required this.trackIndex,
    required this.generatedAtMillis,
    required this.policyKey,
  });

  final String trackId;
  final String? playlistId;
  final int trackIndex;
  final int generatedAtMillis;
  final String policyKey;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'trackId': trackId,
      'playlistId': playlistId,
      'trackIndex': trackIndex,
      'generatedAtMillis': generatedAtMillis,
      'policyKey': policyKey,
    };
  }

  factory _RandomHistoryEntryState.fromJson(Map<String, dynamic> json) {
    return _RandomHistoryEntryState(
      trackId: json['trackId'] as String? ?? '',
      playlistId: json['playlistId'] as String?,
      trackIndex: (json['trackIndex'] as num?)?.toInt() ?? -1,
      generatedAtMillis: (json['generatedAtMillis'] as num?)?.toInt() ?? 0,
      policyKey: json['policyKey'] as String? ?? '',
    );
  }

  RandomHistoryEntry toDomain() {
    return RandomHistoryEntry(
      trackId: trackId,
      playlistId: playlistId,
      trackIndex: trackIndex,
      generatedAt: DateTime.fromMillisecondsSinceEpoch(generatedAtMillis),
      policyKey: policyKey,
    );
  }
}

class _RandomPlaybackState {
  const _RandomPlaybackState({
    required this.enabled,
    required this.history,
    required this.historyCursor,
    required this.deck,
    required this.deckCursor,
    required this.deckSignature,
    required this.stashedNextTrackId,
    required this.stashedForTrackId,
  });

  final bool enabled;
  final List<_RandomHistoryEntryState> history;
  final int? historyCursor;
  final List<String> deck;
  final int? deckCursor;
  final String? deckSignature;
  final String? stashedNextTrackId;
  final String? stashedForTrackId;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'enabled': enabled,
      'history': history.map((entry) => entry.toJson()).toList(growable: false),
      'historyCursor': historyCursor,
      'deck': deck,
      'deckCursor': deckCursor,
      'deckSignature': deckSignature,
      'stashedNextTrackId': stashedNextTrackId,
      'stashedForTrackId': stashedForTrackId,
    };
  }

  factory _RandomPlaybackState.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'];
    final history = <_RandomHistoryEntryState>[];
    if (rawHistory is List) {
      for (final item in rawHistory) {
        if (item is Map<String, dynamic>) {
          history.add(_RandomHistoryEntryState.fromJson(item));
        } else if (item is Map) {
          history.add(
            _RandomHistoryEntryState.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        }
      }
    }

    final rawDeck = json['deck'];
    final deck = <String>[];
    if (rawDeck is List) {
      for (final item in rawDeck) {
        if (item is String && item.isNotEmpty) {
          deck.add(item);
        }
      }
    }

    return _RandomPlaybackState(
      enabled: json['enabled'] as bool? ?? false,
      history: history,
      historyCursor: (json['historyCursor'] as num?)?.toInt(),
      deck: deck,
      deckCursor: (json['deckCursor'] as num?)?.toInt(),
      deckSignature: json['deckSignature'] as String?,
      stashedNextTrackId: json['stashedNextTrackId'] as String?,
      stashedForTrackId: json['stashedForTrackId'] as String?,
    );
  }
}
