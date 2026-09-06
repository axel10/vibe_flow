import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/remote/clients/subsonic_client.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/services/remote_download_service.dart';
import 'package:vynody/models/music_file.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SubsonicClient Remote Actions & Download Tests', () {
    late RemoteServer server;
    late SubsonicClient client;

    setUp(() {
      server = RemoteServer(
        id: 'test_server',
        name: 'Navidrome Server',
        type: RemoteServerType.subsonic,
        url: 'http://192.168.1.100:4533',
        username: 'user1',
        createdAt: DateTime.now(),
      );
      client = SubsonicClient(server: server, password: 'mypassword');
    });

    test('buildDownloadUrl formats proper Subsonic download URL', () {
      final downloadUrl = client.buildDownloadUrl('song_123');
      final uri = Uri.parse(downloadUrl);

      expect(uri.path, contains('rest/download.view'));
      expect(uri.queryParameters['id'], 'song_123');
      expect(uri.queryParameters['u'], 'user1');
      expect(uri.queryParameters['v'], SubsonicClient.apiVersion);
      expect(uri.queryParameters['c'], SubsonicClient.clientName);
      expect(uri.queryParameters.containsKey('t'), isTrue);
      expect(uri.queryParameters.containsKey('s'), isTrue);
    });

    test('buildUrl supports iterable/multiple values for songId query params', () {
      final url = client.buildUrl('createPlaylist.view', {
        'name': 'My Remote Playlist',
        'songId': ['s1', 's2', 's3'],
      });

      expect(url, contains('rest/createPlaylist.view'));
      expect(url, contains('name=My+Remote+Playlist'));
      expect(url, contains('songId=s1&songId=s2&songId=s3'));
    });

    test('Remote track formatting creates valid MusicFile representation', () {
      final song = MusicFile(
        path: 'subsonic://test_server/track_456',
        name: 'Bohemian Rhapsody.mp3',
        title: 'Bohemian Rhapsody',
        artist: 'Queen',
        album: 'A Night at the Opera',
        trackNumber: 4,
        durationMillis: 354000,
        artworkPath: 'subsonic-cover://test_server/cover_789',
      );

      expect(song.title, 'Bohemian Rhapsody');
      expect(song.artist, 'Queen');
      expect(song.album, 'A Night at the Opera');
      expect(song.trackNumber, 4);
      expect(song.path, 'subsonic://test_server/track_456');
    });

    test('RemoteDownloadTask progress and state calculations', () {
      final song = MusicFile(
        path: 'subsonic://test_server/track_456',
        name: 'Track.mp3',
        title: 'Track',
      );

      final task = RemoteDownloadTask(
        id: 'task_1',
        server: server,
        song: song,
        downloadUrl: 'http://example.com/download',
        targetPath: '/path/to/Track.mp3',
        status: RemoteDownloadStatus.downloading,
        bytesDownloaded: 5000,
        totalBytes: 10000,
        speedBytesPerSec: 1024 * 1024,
      );

      expect(task.progress, 0.5);
      expect(task.isSubsonic, isTrue);
      expect(task.isWebDav, isFalse);

      final updated = task.copyWith(
        status: RemoteDownloadStatus.completed,
        bytesDownloaded: 10000,
      );
      expect(updated.status, RemoteDownloadStatus.completed);
      expect(updated.progress, 1.0);
    });

    test('RemoteMediaResolver.extractSubsonicTrackId correctly extracts track IDs', () {
      final song1 = MusicFile(
        path: 'subsonic://test_server/708892189382',
        name: 'Track.mp3',
        title: 'Track',
      );
      expect(RemoteMediaResolver.extractSubsonicTrackId(song1), '708892189382');

      final song2 = MusicFile(
        path: 'subsonic://test_server/al-1/tr-2',
        name: 'Track.mp3',
        title: 'Track',
      );
      expect(RemoteMediaResolver.extractSubsonicTrackId(song2), 'al-1/tr-2');

      final song3 = MusicFile(
        path: '/var/cache/track_998877',
        name: 'Track.mp3',
        title: 'Track',
      );
      expect(RemoteMediaResolver.extractSubsonicTrackId(song3), '998877');

      final song4 = MusicFile(
        id: 1234,
        path: '/local/path.mp3',
        name: 'Track.mp3',
        title: 'Track',
      );
      expect(RemoteMediaResolver.extractSubsonicTrackId(song4), '1234');
    });

    test('buildUrl formats search3.view with song offset and pagination', () {
      final url = client.buildUrl('search3.view', {
        'query': '',
        'artistCount': 0,
        'albumCount': 0,
        'songCount': 500,
        'songOffset': 1000,
      });

      expect(url, contains('rest/search3.view'));
      expect(url, contains('query='));
      expect(url, contains('artistCount=0'));
      expect(url, contains('albumCount=0'));
      expect(url, contains('songCount=500'));
      expect(url, contains('songOffset=1000'));
    });

    test('buildUrl formats getRandomSongs.view properly', () {
      final url = client.buildUrl('getRandomSongs.view', {
        'size': 500,
      });

      expect(url, contains('rest/getRandomSongs.view'));
      expect(url, contains('size=500'));
    });

    test('Song list sorting orders correctly by title, artist, duration', () {
      final s1 = MusicFile(
        path: 'subsonic://test_server/1',
        name: 'B.mp3',
        title: 'B Song',
        artist: 'Z Artist',
        album: 'Album 2',
        durationMillis: 120000,
      );
      final s2 = MusicFile(
        path: 'subsonic://test_server/2',
        name: 'A.mp3',
        title: 'A Song',
        artist: 'M Artist',
        album: 'Album 1',
        durationMillis: 240000,
      );
      final s3 = MusicFile(
        path: 'subsonic://test_server/3',
        name: 'C.mp3',
        title: 'C Song',
        artist: 'A Artist',
        album: 'Album 3',
        durationMillis: 60000,
      );

      final songs = [s1, s2, s3];

      // Sort by title asc
      final byTitleAsc = List<MusicFile>.from(songs)
        ..sort((a, b) => (a.title ?? '').toLowerCase().compareTo((b.title ?? '').toLowerCase()));
      expect(byTitleAsc.map((s) => s.title).toList(), ['A Song', 'B Song', 'C Song']);

      // Sort by artist asc
      final byArtistAsc = List<MusicFile>.from(songs)
        ..sort((a, b) => (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase()));
      expect(byArtistAsc.map((s) => s.artist).toList(), ['A Artist', 'M Artist', 'Z Artist']);

      // Sort by duration desc
      final byDurationDesc = List<MusicFile>.from(songs)
        ..sort((a, b) => (b.durationMillis ?? 0).compareTo(a.durationMillis ?? 0));
      expect(byDurationDesc.map((s) => s.durationMillis).toList(), [240000, 120000, 60000]);
    });
  });
}
