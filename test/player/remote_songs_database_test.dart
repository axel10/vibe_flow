import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vynody/player/metadata/metadata_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory supportDirectory;
  final db = MetadataDatabase();

  setUpAll(() async {
    supportDirectory = await Directory.systemTemp.createTemp(
      'remote_songs_test_',
    );
    PathProviderPlatform.instance = _TestPathProviderPlatform(
      supportPath: supportDirectory.path,
    );
    await db.ensureOpen();
  });

  tearDownAll(() async {
    try {
      if (await supportDirectory.exists()) {
        await supportDirectory.delete(recursive: true);
      }
    } catch (_) {}
  });

  group('RemoteSongs Table and Database Routing Tests', () {
    test('inserts and retrieves remote song metadata', () async {
      final remoteUri = 'subsonic://srv_test_123/track_456';
      final song = SongMetadata(
        path: remoteUri,
        title: 'Test Remote Song',
        artist: 'Remote Artist',
        album: 'Remote Album',
        duration: 210000,
        trackNumber: 3,
        thumbnailPath: '/path/to/thumb.jpg',
        themeColorsBlob: Uint8List.fromList([1, 2, 3, 4]),
        waveformBlob: Uint8List.fromList([10, 20, 30, 40]),
      );

      // Insert via insertOrUpdateSong which routes to remote_songs
      await db.insertOrUpdateSong(song);

      // Query via getSongMetadata
      final fetched = await db.getSongMetadata(remoteUri);
      expect(fetched, isNotNull);
      expect(fetched!.path, remoteUri);
      expect(fetched.title, 'Test Remote Song');
      expect(fetched.artist, 'Remote Artist');
      expect(fetched.album, 'Remote Album');
      expect(fetched.duration, 210000);
      expect(fetched.trackNumber, 3);
      expect(fetched.thumbnailPath, '/path/to/thumb.jpg');
      expect(fetched.themeColorsBlob, Uint8List.fromList([1, 2, 3, 4]));
      expect(fetched.waveformBlob, Uint8List.fromList([10, 20, 30, 40]));

      // Verify that local songs table did not get polluted
      final localSongs = await db.getAllSongMetadata();
      expect(localSongs.where((s) => s.path == remoteUri).isEmpty, isTrue);

      // Query by serverId
      final serverSongs = await db.getRemoteSongsByServerId('srv_test_123');
      expect(serverSongs.length, 1);
      expect(serverSongs.first.path, remoteUri);
    });

    test('updates remote song thumbnail and waveform blob incrementally', () async {
      final remoteUri = 'subsonic://srv_test_123/track_789';
      final song = SongMetadata(
        path: remoteUri,
        title: 'Song 789',
        artist: 'Artist 789',
        album: 'Album 789',
      );

      await db.insertOrUpdateSong(song);

      // Update with thumbnail and theme colors
      final updatedWithThumb = (await db.getSongMetadata(remoteUri))!.copyWith(
        thumbnailPath: '/cache/thumb_789.jpg',
        themeColorsBlob: Uint8List.fromList([55, 66, 77]),
      );
      await db.insertOrUpdateSong(updatedWithThumb);

      var fetched = await db.getSongMetadata(remoteUri);
      expect(fetched!.thumbnailPath, '/cache/thumb_789.jpg');
      expect(fetched.themeColorsBlob, Uint8List.fromList([55, 66, 77]));
      expect(fetched.waveformBlob, isNull);

      // Update with waveform
      final updatedWithWave = fetched.copyWith(
        waveformBlob: Uint8List.fromList([99, 88, 77, 66]),
      );
      await db.insertOrUpdateSong(updatedWithWave);

      fetched = await db.getSongMetadata(remoteUri);
      expect(fetched!.thumbnailPath, '/cache/thumb_789.jpg');
      expect(fetched.waveformBlob, Uint8List.fromList([99, 88, 77, 66]));
    });

    test('batch query getSongMetadataByPaths returns both local and remote songs', () async {
      final localPath = '/local/music/song1.mp3';
      final remotePath = 'webdav://srv_nas/music/song2.flac';

      await db.insertOrUpdateSong(SongMetadata(
        path: localPath,
        title: 'Local Track',
        artist: 'Local Artist',
        album: 'Local Album',
      ));

      await db.insertOrUpdateSong(SongMetadata(
        path: remotePath,
        title: 'Remote Track',
        artist: 'Remote Artist',
        album: 'Remote Album',
      ));

      final batch = await db.getSongMetadataByPaths([localPath, remotePath]);
      expect(batch.length, 2);
      expect(batch[localPath]?.title, 'Local Track');
      expect(batch[remotePath]?.title, 'Remote Track');
    });

    test('deletes all remote songs for a server when server is removed', () async {
      final srv1Track1 = 'subsonic://srv_A/1';
      final srv1Track2 = 'subsonic://srv_A/2';
      final srv2Track1 = 'subsonic://srv_B/1';

      await db.insertOrUpdateSong(SongMetadata(path: srv1Track1, title: 'A1', artist: 'A', album: 'A'));
      await db.insertOrUpdateSong(SongMetadata(path: srv1Track2, title: 'A2', artist: 'A', album: 'A'));
      await db.insertOrUpdateSong(SongMetadata(path: srv2Track1, title: 'B1', artist: 'B', album: 'B'));

      expect((await db.getRemoteSongsByServerId('srv_A')).length, 2);
      expect((await db.getRemoteSongsByServerId('srv_B')).length, 1);

      await db.deleteRemoteSongsByServerId('srv_A');

      expect((await db.getRemoteSongsByServerId('srv_A')).length, 0);
      expect((await db.getRemoteSongsByServerId('srv_B')).length, 1);
      expect(await db.getSongMetadata(srv1Track1), isNull);
      expect(await db.getSongMetadata(srv2Track1), isNotNull);
    });
  });
}

class _TestPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _TestPathProviderPlatform({required this.supportPath});

  final String supportPath;

  @override
  Future<String?> getApplicationSupportPath() async => supportPath;
}
