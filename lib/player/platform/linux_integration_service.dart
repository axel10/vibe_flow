// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service_platform_interface/audio_service_platform_interface.dart';
import 'package:audio_service_mpris/mpris.dart';
import 'package:audio_service_mpris/metadata.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:vynody/player/audio/audio_service.dart' as app; // To distinguish from package:audio_service
import 'package:vynody/player/audio/audio_handler.dart';
import 'package:vynody/models/music_file.dart';

class CustomMprisObject extends OrgMprisMediaPlayer2 {
  CustomMprisObject({
    super.path = const DBusObjectPath.unchecked('/org/mpris/MediaPlayer2'),
    required super.identity,
  });

  @override
  DBusString getDesktopEntry() {
    return const DBusString('io.github.axel10.vynody');
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('org.mpris.MediaPlayer2', methods: [
        DBusIntrospectMethod('Raise'),
        DBusIntrospectMethod('Quit')
      ], properties: [
        DBusIntrospectProperty('CanQuit', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('CanRaise', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('HasTrackList', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Identity', DBusSignature('s'), access: DBusPropertyAccess.read),
        // Expose DesktopEntry to DBus introspection
        DBusIntrospectProperty('DesktopEntry', DBusSignature('s'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('SupportedUriSchemes', DBusSignature('as'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('SupportedMimeTypes', DBusSignature('as'),
            access: DBusPropertyAccess.read)
      ]),
      super.introspect()[1],
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'org.mpris.MediaPlayer2') {
      if (methodCall.name == 'Raise') {
        try {
          await windowManager.show();
          await windowManager.focus();
        } catch (e) {
          debugPrint('Error raising window from MPRIS: $e');
        }
        return DBusMethodSuccessResponse();
      } else if (methodCall.name == 'Quit') {
        exit(0);
      }
    }
    return super.handleMethodCall(methodCall);
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    if (interface == 'org.mpris.MediaPlayer2') {
      return DBusMethodSuccessResponse([
        DBusDict.stringVariant({
          'CanQuit': getCanQuit(),
          'CanRaise': getCanRaise(),
          'HasTrackList': getHasTrackList(),
          'Identity': getIdentity(),
          'DesktopEntry': getDesktopEntry(),
          'SupportedUriSchemes': getSupportedUriSchemes(),
          'SupportedMimeTypes': getSupportedMimeTypes(),
        })
      ]);
    }
    return super.getAllProperties(interface);
  }
}

class CustomAudioServiceMpris extends AudioServicePlatform {
  late final DBusClient _dBusClient;
  late final CustomMprisObject _mpris;
  AudioHandlerCallbacks? _handlerCallbacks;
  bool _isPlaying = false;

  void _listenToOpenUriStream() {
    _mpris.openUriStream.listen((uri) {
      if (_handlerCallbacks == null) return;
      _handlerCallbacks!.playFromUri(PlayFromUriRequest(uri: uri));
    });
  }

  void _listenToSeekStream() {
    _mpris.positionStream.listen((position) {
      if (_handlerCallbacks == null) return;
      _handlerCallbacks!.seek(SeekRequest(position: position));
    });
  }

  void _listenToControlStream() {
    _mpris.controlStream.listen((event) {
      log('Requested from DBus: $event', name: 'audio_service_mpris');
      if (_handlerCallbacks == null) return;
      switch (event) {
        case 'play':
          _handlerCallbacks!.play(const PlayRequest());
          break;
        case 'pause':
          _handlerCallbacks!.pause(const PauseRequest());
          break;
        case 'next':
          _handlerCallbacks!.skipToNext(const SkipToNextRequest());
          break;
        case 'previous':
          _handlerCallbacks!.skipToPrevious(const SkipToPreviousRequest());
          break;
        case 'playPause':
          _isPlaying
              ? _handlerCallbacks!.pause(const PauseRequest())
              : _handlerCallbacks!.play(const PlayRequest());
          break;
      }
    });
  }

  void _listenToVolumeStream() {
    _mpris.volumeStream.listen((value) {
      if (_handlerCallbacks == null) return;
      final req = CustomActionRequest(name: 'dbusVolume', extras: {'value': value});
      _handlerCallbacks!.customAction(req);
    });
  }

  @override
  Future<void> configure(ConfigureRequest request) async {
    log('Configure AudioServiceLinux with Custom MPRIS.', name: 'audio_service_mpris');
    assert(
        request.config.androidNotificationChannelId != null,
        "androidNotificationChannelId is required for registering DBus object.");

    _dBusClient = DBusClient.session();
    _mpris = CustomMprisObject(
        identity: request.config.androidNotificationChannelName);

    _listenToControlStream();
    _listenToSeekStream();
    _listenToOpenUriStream();
    _listenToVolumeStream();

    await _dBusClient.registerObject(_mpris);
    await _dBusClient.requestName(
        'org.mpris.MediaPlayer2.io.github.axel10.vynody.instance$pid',
        flags: {DBusRequestNameFlag.doNotQueue});
  }

  @override
  Future<void> setState(SetStateRequest request) async {
    _mpris.position = request.state.updatePosition;
    _isPlaying = request.state.playing;
    _mpris.playbackState = _isPlaying ? 'Playing' : 'Paused';
  }

  @override
  Future<void> setQueue(SetQueueRequest request) async {
    log('setQueue() has not been implemented.', name: 'audio_service_mpris');
  }

  @override
  Future<void> setMediaItem(SetMediaItemRequest request) async {
    List<String>? artist;
    if (request.mediaItem.artist != null) artist = [request.mediaItem.artist!];

    List<String>? genre;
    if (request.mediaItem.genre != null) genre = [request.mediaItem.genre!];

    _mpris.metadata = Metadata(
        title: request.mediaItem.title,
        length: request.mediaItem.duration,
        artist: artist,
        artUrl: request.mediaItem.artUri.toString(),
        album: request.mediaItem.album,
        genre: genre);
  }

  @override
  Future<void> stopService(StopServiceRequest request) async {
    _mpris.playbackState = 'Stopped';
  }

  @override
  Future<void> notifyChildrenChanged(NotifyChildrenChangedRequest request) async {
    throw UnimplementedError('notifyChildrenChanged() has not been implemented.');
  }

  @override
  void setHandlerCallbacks(AudioHandlerCallbacks callbacks) {
    _handlerCallbacks = callbacks;
  }
}

class LinuxIntegrationService {
  final app.AudioService audioService;
  late MyAudioHandler _handler;
  bool _initialized = false;
  String? _lastMetadataKey;
  Duration _lastTimelineDuration = Duration.zero;

  LinuxIntegrationService(this.audioService) {
    if (!Platform.isLinux) return;
    // Register our custom AudioServicePlatform implementation for Linux
    AudioServicePlatform.instance = CustomAudioServiceMpris();
    _init();
  }

  Future<void> _init() async {
    try {
      _handler = await AudioService.init(
        builder: () => MyAudioHandler(audioService),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'app.vynody.player.channel.audio',
          androidNotificationChannelName: 'Vynody', // Used as MPRIS Identity
          androidNotificationIcon: 'mipmap/launcher_icon',
        ),
      );
      _initialized = true;
      _updateInitialState();
    } catch (e, st) {
      debugPrint('Linux audio service init failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  void _updateInitialState() {
    if (!_initialized) return;
    updatePlaybackStatus(audioService.isPlaying);
    updateMetadata(null);
  }

  void updateMetadata(MusicFile? song) {
    if (!Platform.isLinux || !_initialized) return;

    final metadataKey = [
      song?.path ?? audioService.currentMusic?.path,
      audioService.currentMusic?.displayName,
      audioService.currentMusic?.artist,
      audioService.currentMusic?.album,
      audioService.currentMusic?.artworkPath ??
          audioService.currentMusic?.thumbnailPath,
      audioService.duration.inMilliseconds.toString(),
    ].join('|');
    if (_lastMetadataKey == metadataKey) return;
    _lastMetadataKey = metadataKey;

    _handler.onMetadataChanged();
  }

  bool? _lastIsPlaying;

  void updatePlaybackStatus(bool isPlaying) {
    if (!Platform.isLinux || !_initialized) return;
    if (_lastIsPlaying == isPlaying) return;
    _lastIsPlaying = isPlaying;

    _handler.onPlaybackStatusChanged(isPlaying);
  }

  void updateTimeline(Duration position, Duration duration) {
    if (!Platform.isLinux || !_initialized) return;

    final durationChanged = duration != _lastTimelineDuration;
    if (durationChanged) {
      _lastTimelineDuration = duration;
      updateMetadata(null);
    }

    _handler.onPositionChanged(position, duration);
  }

  void dispose() {
    // AudioService handlers usually live for the duration of the app
  }
}
