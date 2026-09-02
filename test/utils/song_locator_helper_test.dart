import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/utils/song_locator_helper.dart';

void main() {
  group('SongLocatorHelper', () {
    final songA = const MusicFile(path: '/root/a.mp3', name: 'a.mp3');
    final songB = const MusicFile(path: '/root/sub/b.mp3', name: 'b.mp3');
    final songC =
        const MusicFile(path: '/root/sub/deep/c.mp3', name: 'c.mp3');

    final deepFolder = MusicFolder(
      path: '/root/sub/deep',
      name: 'deep',
      files: [songC],
    );
    final subFolder = MusicFolder(
      path: '/root/sub',
      name: 'sub',
      files: [songB],
      subFolders: [deepFolder],
    );
    final rootFolder = MusicFolder(
      path: '/root',
      name: 'root',
      files: [songA],
      subFolders: [subFolder],
    );

    test('findFolderHistory finds top-level song', () {
      final history = SongLocatorHelper.findFolderHistory(rootFolder, '/root/a.mp3');
      expect(history, isNotNull);
      expect(history!.length, equals(1));
      expect(history.first.path, equals('/root'));
    });

    test('findFolderHistory finds nested song and returns full path hierarchy', () {
      final history =
          SongLocatorHelper.findFolderHistory(rootFolder, '/root/sub/deep/c.mp3');
      expect(history, isNotNull);
      expect(history!.length, equals(3));
      expect(history.map((f) => f.path).toList(),
          equals(['/root', '/root/sub', '/root/sub/deep']));
    });

    test('findFolderHistory returns null for nonexistent song', () {
      final history =
          SongLocatorHelper.findFolderHistory(rootFolder, '/root/other/unknown.mp3');
      expect(history, isNull);
    });

    test('findFolderHistoryByFolderPath finds target folder history', () {
      final history =
          SongLocatorHelper.findFolderHistoryByFolderPath(rootFolder, '/root/sub/deep');
      expect(history, isNotNull);
      expect(history!.length, equals(3));
      expect(history.map((f) => f.path).toList(),
          equals(['/root', '/root/sub', '/root/sub/deep']));
    });
  });

  group('SongHighlightNotifier', () {
    test('sets and clears highlighted path', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(songHighlightProvider), isNull);

      container
          .read(songHighlightProvider.notifier)
          .highlight('/music/song.mp3');
      expect(
        container.read(songHighlightProvider),
        equals('/music/song.mp3'),
      );

      container.read(songHighlightProvider.notifier).clear();
      expect(container.read(songHighlightProvider), isNull);
    });
  });
}
