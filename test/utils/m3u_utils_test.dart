import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/utils/m3u_utils.dart';

void main() {
  group('M3uUtils Tests', () {
    test('generate M3U with EXTINF and playlist name', () {
      final songs = [
        const MusicFile(
          path: '/music/Jay Chou/晴天.flac',
          name: '晴天.flac',
          title: '晴天',
          artist: '周杰伦',
          durationMillis: 245000,
        ),
        const MusicFile(
          path: '/music/Taylor Swift/Cruel Summer.mp3',
          name: 'Cruel Summer.mp3',
          title: 'Cruel Summer',
          artist: 'Taylor Swift',
          durationMillis: 198000,
        ),
      ];

      final m3u = M3uUtils.generate(songs, playlistName: 'My Favorites');

      expect(m3u.contains('#EXTM3U'), isTrue);
      expect(m3u.contains('#PLAYLIST:My Favorites'), isTrue);
      expect(m3u.contains('#EXTINF:245,周杰伦 - 晴天'), isTrue);
      expect(m3u.contains('/music/Jay Chou/晴天.flac'), isTrue);
      expect(m3u.contains('#EXTINF:198,Taylor Swift - Cruel Summer'), isTrue);
      expect(m3u.contains('/music/Taylor Swift/Cruel Summer.mp3'), isTrue);
    });

    test('parse standard Extended M3U content', () {
      const content = '''#EXTM3U
#PLAYLIST:Rock Classics
#EXTINF:250,Queen - Bohemian Rhapsody
/songs/queen_bohemian.mp3
#EXTINF:180,Led Zeppelin - Immigrant Song
/songs/led_zeppelin.flac
''';

      final data = M3uUtils.parse(content);
      expect(data.playlistName, equals('Rock Classics'));
      expect(data.entries.length, equals(2));

      expect(data.entries[0].artist, equals('Queen'));
      expect(data.entries[0].title, equals('Bohemian Rhapsody'));
      expect(data.entries[0].durationMillis, equals(250000));
      expect(data.entries[0].path, equals('/songs/queen_bohemian.mp3'));

      expect(data.entries[1].artist, equals('Led Zeppelin'));
      expect(data.entries[1].title, equals('Immigrant Song'));
      expect(data.entries[1].durationMillis, equals(180000));
      expect(data.entries[1].path, equals('/songs/led_zeppelin.flac'));
    });

    test('parse relative paths with baseDir', () {
      const content = '''#EXTM3U
#EXTINF:120,Artist - Song 1
track1.mp3
#EXTINF:150,Song 2
subdir/track2.flac
''';

      final data = M3uUtils.parse(content, baseDir: '/home/user/music/playlists');
      expect(data.entries.length, equals(2));
      expect(data.entries[0].path, equals('/home/user/music/playlists/track1.mp3'));
      expect(data.entries[1].path, equals('/home/user/music/playlists/subdir/track2.flac'));
    });

    test('parse file:// URI', () {
      const content = '''#EXTM3U
file:///music/song.mp3
''';

      final data = M3uUtils.parse(content);
      expect(data.entries.length, equals(1));
      expect(data.entries[0].path, equals('/music/song.mp3'));
    });
  });
}
