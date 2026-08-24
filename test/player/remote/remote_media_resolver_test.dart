import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/remote_server_storage.dart';
import 'package:vynody/player/remote/proxy/local_stream_cache_proxy.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/remote/clients/webdav_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late RemoteServerStorage storage;
  late LocalStreamCacheProxy proxy;
  late RemoteMediaResolver resolver;

  final subsonicServer = RemoteServer(
    id: 'subsonic_test',
    name: 'My Navidrome',
    type: RemoteServerType.subsonic,
    url: 'http://example.com:4533',
    username: 'alice',
    createdAt: DateTime.now(),
  );

  final webdavServer = RemoteServer(
    id: 'webdav_test',
    name: 'My WebDAV',
    type: RemoteServerType.webdav,
    url: 'http://example.com/dav',
    username: 'bob',
    createdAt: DateTime.now(),
  );

  setUp(() async {
    HttpOverrides.global = null;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = RemoteServerStorage(prefs: prefs);
    await storage.saveServers([subsonicServer, webdavServer]);
    await storage.savePassword(subsonicServer.id, 'alice_pwd');
    await storage.savePassword(webdavServer.id, 'bob_pwd');

    proxy = LocalStreamCacheProxy();
    await proxy.start();

    resolver = RemoteMediaResolver(storage: storage, proxy: proxy);
  });


  tearDown(() async {
    await proxy.stop();
  });

  test('RemoteMediaResolver parses virtual URIs correctly', () {
    expect(RemoteMediaResolver.isRemoteUri('subsonic://subsonic_test/track_123'), isTrue);
    expect(RemoteMediaResolver.isRemoteUri('webdav://webdav_test/Music/Song.flac'), isTrue);
    expect(RemoteMediaResolver.isRemoteUri('/local/path/song.mp3'), isFalse);

    final subInfo = RemoteMediaResolver.parseUri('subsonic://subsonic_test/track_123');
    expect(subInfo?.type, RemoteServerType.subsonic);
    expect(subInfo?.serverId, 'subsonic_test');
    expect(subInfo?.trackIdOrPath, 'track_123');

    final davInfo = RemoteMediaResolver.parseUri('webdav://webdav_test/Music/Song.flac');
    expect(davInfo?.type, RemoteServerType.webdav);
    expect(davInfo?.serverId, 'webdav_test');
    expect(davInfo?.trackIdOrPath, '/Music/Song.flac');
  });

  test('RemoteMediaResolver creates MusicFiles from Subsonic and WebDAV responses', () {
    final subSong = RemoteMediaResolver.buildMusicFileFromSubsonic({
      'id': 'tr_01',
      'title': 'Test Song',
      'artist': 'Test Artist',
      'album': 'Test Album',
      'duration': 180,
      'suffix': 'flac',
      'coverArt': 'cover_01',
    }, subsonicServer);

    expect(subSong.path, 'subsonic://subsonic_test/tr_01');
    expect(subSong.title, 'Test Song');
    expect(subSong.artist, 'Test Artist');
    expect(subSong.album, 'Test Album');
    expect(subSong.durationMillis, 180000);
    expect(subSong.artworkPath, 'subsonic-cover://subsonic_test/cover_01');

    final davFile = WebDavFile(
      path: '/Music/TestTrack.mp3',
      name: 'TestTrack.mp3',
      isDirectory: false,
      contentLength: 5000000,
    );
    final davSong = RemoteMediaResolver.buildMusicFileFromWebDav(davFile, webdavServer);
    expect(davSong.path, 'webdav://webdav_test/Music/TestTrack.mp3');
    expect(davSong.name, 'TestTrack.mp3');
    expect(davSong.title, 'TestTrack');
  });

  test('RemoteMediaResolver resolves playable proxy URLs', () async {
    final subPlayableUrl = await resolver.resolvePlayableUrl('subsonic://subsonic_test/track_123');
    final decodedSub = Uri.decodeFull(subPlayableUrl);
    expect(subPlayableUrl, startsWith('http://127.0.0.1:${proxy.port}/stream?url='));
    expect(decodedSub, contains('u=alice'));
    expect(decodedSub, contains('id=track_123'));

    final davPlayableUrl = await resolver.resolvePlayableUrl('webdav://webdav_test/Music/Song.flac');
    final decodedDav = Uri.decodeFull(davPlayableUrl);
    expect(davPlayableUrl, startsWith('http://127.0.0.1:${proxy.port}/stream?url='));
    expect(decodedDav, contains('example.com/dav/Music/Song.flac'));
  });

}
