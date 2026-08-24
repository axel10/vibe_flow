import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/remote/proxy/local_stream_cache_proxy.dart';
import 'package:vynody/player/remote/remote_server_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Remote Cover & URI resolution tests', () {
    late RemoteServer subsonicServer;
    late RemoteServerStorage storage;
    late LocalStreamCacheProxy proxy;
    late RemoteMediaResolver resolver;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = RemoteServerStorage(prefs: prefs);
      proxy = LocalStreamCacheProxy();

      subsonicServer = RemoteServer(
        id: 'navidrome_server',
        name: 'My Navidrome',
        type: RemoteServerType.subsonic,
        url: 'http://192.168.1.100:4533',
        username: 'admin',
        createdAt: DateTime.now(),
      );

      await storage.saveServers([subsonicServer]);
      await storage.savePassword('navidrome_server', 'secret123');
      resolver = RemoteMediaResolver(storage: storage, proxy: proxy);
    });

    test('buildMusicFileFromSubsonic formats artworkPath with serverId', () {
      final music = RemoteMediaResolver.buildMusicFileFromSubsonic({
        'id': 'track_99',
        'title': 'Starlight',
        'artist': 'Muse',
        'album': 'Black Holes and Revelations',
        'coverArt': 'al-55',
        'duration': 240,
        'suffix': 'mp3',
      }, subsonicServer);

      expect(music.path, 'subsonic://navidrome_server/track_99');
      expect(music.artworkPath, 'subsonic-cover://navidrome_server/al-55');
    });

    test('getArtworkUrl generates valid Subsonic getCoverArt URL', () async {
      final music = RemoteMediaResolver.buildMusicFileFromSubsonic({
        'id': 'track_99',
        'title': 'Starlight',
        'artist': 'Muse',
        'album': 'Black Holes and Revelations',
        'coverArt': 'al-55',
        'duration': 240,
        'suffix': 'mp3',
      }, subsonicServer);

      final url = await resolver.getArtworkUrl(music, size: 600);
      expect(url, isNotNull);
      expect(url, contains('/rest/getCoverArt'));
      expect(url, contains('id=al-55'));
      expect(url, contains('size=600'));
      expect(url, contains('u=admin'));
    });
  });
}
