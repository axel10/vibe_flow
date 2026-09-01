import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/library/playlist_service.dart';
import 'package:vynody/utils/m3u_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Playlist Sharing Serialization & Parsing', () {
    test('generate and parse M3U for playlist sharing payload', () {
      final songs = <MusicFile>[
        const MusicFile(
          path: '/music/nightglow.mp3',
          name: 'nightglow.mp3',
          title: 'Nightglow',
          artist: 'Tanya Chua',
          album: 'Honkai',
          durationMillis: 210000,
        ),
        const MusicFile(
          path: '/music/rubia.flac',
          name: 'rubia.flac',
          title: 'Rubia',
          artist: 'Zhou Shen',
          album: 'Honkai',
          durationMillis: 185000,
        ),
      ];

      final m3uContent = M3uUtils.generate(songs, playlistName: 'Anime Soundtracks');
      expect(m3uContent, contains('#EXTM3U'));
      expect(m3uContent, contains('#PLAYLIST:Anime Soundtracks'));
      expect(m3uContent, contains('Nightglow'));
      expect(m3uContent, contains('Rubia'));

      final parsed = M3uUtils.parse(m3uContent);
      expect(parsed.playlistName, equals('Anime Soundtracks'));
      expect(parsed.entries.length, equals(2));
      expect(parsed.entries[0].title, equals('Nightglow'));
      expect(parsed.entries[0].artist, equals('Tanya Chua'));
      expect(parsed.entries[1].title, equals('Rubia'));
      expect(parsed.entries[1].artist, equals('Zhou Shen'));
    });

    test('PlaylistService addPlaylist preserves songs and updates state', () async {
      final service = PlaylistService();
      final playlist = Playlist(
        id: 'pl-shared-1',
        name: 'Shared Rock Hits',
        songs: const [
          MusicFile(
            path: '/music/rock.mp3',
            name: 'rock.mp3',
            title: 'Rock Song',
            artist: 'Band',
            album: 'Rock Album',
            durationMillis: 200000,
          ),
        ],
      );

      await service.addPlaylist(playlist);
      expect(service.playlists.any((p) => p.id == 'pl-shared-1'), isTrue);
      final found = service.playlists.firstWhere((p) => p.id == 'pl-shared-1');
      expect(found.name, equals('Shared Rock Hits'));
      expect(found.songs.length, equals(1));
    });

    test('PlaylistService deletePlaylists batch deletes playlists and ignores favorites', () async {
      final service = PlaylistService();
      final pl1 = Playlist(id: 'pl-batch-1', name: 'Batch 1');
      final pl2 = Playlist(id: 'pl-batch-2', name: 'Batch 2');
      final pl3 = Playlist(id: 'pl-batch-3', name: 'Batch 3');

      await service.addPlaylist(pl1);
      await service.addPlaylist(pl2);
      await service.addPlaylist(pl3);

      expect(service.playlists.any((p) => p.id == 'pl-batch-1'), isTrue);
      expect(service.playlists.any((p) => p.id == 'pl-batch-2'), isTrue);
      expect(service.playlists.any((p) => p.id == 'pl-batch-3'), isTrue);

      await service.deletePlaylists(['pl-batch-1', 'pl-batch-2', PlaylistService.favoritePlaylistId]);

      expect(service.playlists.any((p) => p.id == 'pl-batch-1'), isFalse);
      expect(service.playlists.any((p) => p.id == 'pl-batch-2'), isFalse);
      expect(service.playlists.any((p) => p.id == 'pl-batch-3'), isTrue);
      expect(service.playlists.any((p) => p.id == PlaylistService.favoritePlaylistId), isTrue);
    });
  });
}
