import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/clients/subsonic_client.dart';
import 'package:vynody/player/remote/clients/webdav_client.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/metadata/metadata_database.dart';

void main() {
  group('RemoteServer Model Tests', () {
    test('serializes and deserializes correctly', () {
      final now = DateTime.now();
      final server = RemoteServer(
        id: 'test-1',
        name: 'My Navidrome',
        type: RemoteServerType.subsonic,
        url: 'http://192.168.1.100:4533',
        username: 'admin',
        maxBitRate: 320,
        ignoreSsl: true,
        createdAt: now,
      );

      final json = server.toJson();
      final restored = RemoteServer.fromJson(json);

      expect(restored.id, 'test-1');
      expect(restored.name, 'My Navidrome');
      expect(restored.type, RemoteServerType.subsonic);
      expect(restored.url, 'http://192.168.1.100:4533');
      expect(restored.username, 'admin');
      expect(restored.maxBitRate, 320);
      expect(restored.ignoreSsl, true);
    });

    test('encodes and decodes list of servers', () {
      final servers = [
        RemoteServer(
          id: '1',
          name: 'Navi',
          type: RemoteServerType.subsonic,
          url: 'http://navi.local',
          username: 'user1',
          createdAt: DateTime.now(),
        ),
        RemoteServer(
          id: '2',
          name: 'WebDAV NAS',
          type: RemoteServerType.webdav,
          url: 'https://nas.local/dav',
          username: 'user2',
          customPath: '/Music',
          createdAt: DateTime.now(),
        ),
      ];

      final encoded = RemoteServer.encodeList(servers);
      final decoded = RemoteServer.decodeList(encoded);

      expect(decoded.length, 2);
      expect(decoded[0].type, RemoteServerType.subsonic);
      expect(decoded[1].type, RemoteServerType.webdav);
      expect(decoded[1].customPath, '/Music');
    });
  });

  group('SubsonicClient Tests', () {
    final server = RemoteServer(
      id: 'test-subsonic',
      name: 'Navi Test',
      type: RemoteServerType.subsonic,
      url: 'https://music.example.com/subsonic',
      username: 'alice',
      maxBitRate: 256,
      createdAt: DateTime.now(),
    );

    test('buildUrl generates valid Subsonic auth query params', () {
      final client = SubsonicClient(server: server, password: 'secretpassword');
      final pingUrl = client.buildUrl('ping.view');

      final uri = Uri.parse(pingUrl);
      expect(uri.scheme, 'https');
      expect(uri.host, 'music.example.com');
      expect(uri.path, '/subsonic/rest/ping.view');
      expect(uri.queryParameters['u'], 'alice');
      expect(uri.queryParameters['v'], SubsonicClient.apiVersion);
      expect(uri.queryParameters['c'], SubsonicClient.clientName);
      expect(uri.queryParameters['f'], 'json');
      expect(uri.queryParameters['s'], isNotEmpty);
      expect(uri.queryParameters['t'], isNotEmpty);
    });

    test('buildStreamUrl and buildCoverArtUrl construct expected endpoints', () {
      final client = SubsonicClient(server: server, password: 'secretpassword');
      final streamUrl = client.buildStreamUrl('track-123');
      final coverUrl = client.buildCoverArtUrl('al-456', size: 500);

      final streamUri = Uri.parse(streamUrl);
      expect(streamUri.path, '/subsonic/rest/stream');
      expect(streamUri.queryParameters['id'], 'track-123');
      expect(streamUri.queryParameters['maxBitRate'], '256');

      final coverUri = Uri.parse(coverUrl);
      expect(coverUri.path, '/subsonic/rest/getCoverArt');
      expect(coverUri.queryParameters['id'], 'al-456');
      expect(coverUri.queryParameters['size'], '500');
    });

    test('getAlbumList throws SubsonicException when server returns failed status', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'subsonic-response': {
                    'status': 'failed',
                    'version': '1.16.1',
                    'error': {
                      'code': 40,
                      'message': 'Wrong username or password',
                    },
                  },
                },
              ),
            );
          },
        ),
      );

      final client = SubsonicClient(
        server: server,
        password: 'wrongpassword',
        customDio: dio,
      );

      expect(
        () => client.getAlbumList(),
        throwsA(
          isA<SubsonicException>().having(
            (e) => e.message,
            'message',
            'Wrong username or password',
          ),
        ),
      );
    });
  });

  group('WebDavClient Tests', () {
    final server = RemoteServer(
      id: 'test-dav',
      name: 'WebDAV Test',
      type: RemoteServerType.webdav,
      url: 'https://dav.example.com/remote.php/webdav',
      username: 'bob',
      createdAt: DateTime.now(),
    );

    test('auth headers and URLs generated correctly', () {
      final client = WebDavClient(server: server, password: 'password123');
      expect(client.authHeaders['Authorization'], startsWith('Basic '));
      expect(client.buildFullUrl('/Music/Song.flac'),
          'https://dav.example.com/remote.php/webdav/Music/Song.flac');
      expect(client.buildFullUrl('/Music/that girl.mp3'),
          'https://dav.example.com/remote.php/webdav/Music/that%20girl.mp3');
      expect(client.buildFullUrl('/Music/影山ヒロノブ - HEATS.mp3'),
          Uri.encodeFull('https://dav.example.com/remote.php/webdav/Music/影山ヒロノブ - HEATS.mp3'));
    });

    test('parsePropfindXml parses directories and audio files correctly', () {
      const sampleXml = '''<?xml version="1.0" encoding="utf-8"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/remote.php/webdav/Music/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype><d:collection/></d:resourcetype>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/remote.php/webdav/Music/Rock/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype><d:collection/></d:resourcetype>
        <d:getlastmodified>Sun, 24 Aug 2025 08:00:00 GMT</d:getlastmodified>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/remote.php/webdav/Music/01.Track.flac</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype/>
        <d:getcontentlength>35241000</d:getcontentlength>
        <d:getcontenttype>audio/flac</d:getcontenttype>
        <d:getlastmodified>Sun, 24 Aug 2025 08:05:00 GMT</d:getlastmodified>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/remote.php/webdav/Music/cover.jpg</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype/>
        <d:getcontentlength>245000</d:getcontentlength>
        <d:getcontenttype>image/jpeg</d:getcontenttype>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
</d:multistatus>''';

      final files = WebDavClient.parsePropfindXml(
        sampleXml,
        requestPath: '/remote.php/webdav/Music/',
      );

      expect(files.length, 3);

      final dir = files[0];
      expect(dir.name, 'Rock');
      expect(dir.isDirectory, true);
      expect(dir.isAudio, false);

      final audio = files[1];
      expect(audio.name, '01.Track.flac');
      expect(audio.isDirectory, false);
      expect(audio.isAudio, true);
      expect(audio.contentLength, 35241000);

      final image = files[2];
      expect(image.name, 'cover.jpg');
      expect(image.isImage, true);
      expect(image.isAudio, false);
    });
  });

  group('RemoteMediaResolver WebDAV metadata tests', () {
    final server = RemoteServer(
      id: 'test-dav',
      name: 'WebDAV Test',
      type: RemoteServerType.webdav,
      url: 'https://dav.example.com/dav',
      username: 'user',
      createdAt: DateTime.now(),
    );

    final file = const WebDavFile(
      path: '/Music/Rock/01.Hotel California.flac',
      name: '01.Hotel California.flac',
      isDirectory: false,
      contentLength: 35000000,
    );

    test('buildMusicFileFromWebDav without metadata uses filename fallback', () {
      final musicFile = RemoteMediaResolver.buildMusicFileFromWebDav(file, server);
      expect(musicFile.path, 'webdav://test-dav/Music/Rock/01.Hotel California.flac');
      expect(musicFile.name, '01.Hotel California.flac');
      expect(musicFile.title, '01.Hotel California');
      expect(musicFile.artist, isNull);
      expect(musicFile.album, isNull);
    });

    test('buildMusicFileFromWebDav with metadata injects full metadata fields', () {
      final metadata = SongMetadata(
        path: 'webdav://test-dav/Music/Rock/01.Hotel California.flac',
        title: 'Hotel California',
        artist: 'Eagles',
        album: 'Hotel California',
        duration: 391000,
        trackNumber: 1,
        thumbnailPath: '/path/to/thumb.jpg',
      );

      final musicFile = RemoteMediaResolver.buildMusicFileFromWebDav(
        file,
        server,
        metadata: metadata,
      );

      expect(musicFile.path, 'webdav://test-dav/Music/Rock/01.Hotel California.flac');
      expect(musicFile.name, '01.Hotel California.flac');
      expect(musicFile.title, 'Hotel California');
      expect(musicFile.artist, 'Eagles');
      expect(musicFile.album, 'Hotel California');
      expect(musicFile.durationMillis, 391000);
      expect(musicFile.trackNumber, 1);
      expect(musicFile.thumbnailPath, '/path/to/thumb.jpg');
    });
  });
}
