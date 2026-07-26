import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/scanner/scanner_tree_builder.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScannerTreeBuilder system media folder tree', () {
    late ScannerTreeBuilder treeBuilder;

    setUp(() {
      treeBuilder = ScannerTreeBuilder(
        normalizePath: (path) => p.normalize(path.trim()),
        pathsEqual: (left, right) => p.normalize(left) == p.normalize(right),
      );
    });

    test('buildFolderTreeFromMetadata strips Android storage root for system media', () {
      final songs = [
        const SongMetadata(
          path: '/storage/emulated/0/Music/song1.mp3',
          title: 'Song 1',
          artist: 'Artist 1',
          album: 'Album 1',
        ),
        const SongMetadata(
          path: '/storage/emulated/0/Download/Pop/song2.mp3',
          title: 'Song 2',
          artist: 'Artist 2',
          album: 'Album 2',
        ),
        const SongMetadata(
          path: '/storage/emulated/0/root_song.mp3',
          title: 'Root Song',
          artist: 'Artist 3',
          album: 'Album 3',
        ),
      ];

      final tree = treeBuilder.buildFolderTreeFromMetadata(
        songs,
        (a, b) => a.compareTo(b),
        rootPath: 'system',
        rootName: 'System Media',
      );

      expect(tree.path, equals('system'));
      // Direct root files
      expect(tree.files.map((f) => f.title), contains('Root Song'));

      // Direct subfolders under system (should be Music and Download, not storage)
      final subFolderNames = tree.subFolders.map((f) => f.name).toList();
      expect(subFolderNames, containsAll(['Download', 'Music']));
      expect(subFolderNames, isNot(contains('storage')));

      // Check Download/Pop nested structure
      final downloadFolder = tree.subFolders.firstWhere((f) => f.name == 'Download');
      expect(downloadFolder.subFolders.map((f) => f.name), contains('Pop'));
    });

    test('insertSongsToFolderTree incrementally updates folder tree', () {
      final initialSongs = [
        const SongMetadata(
          path: 'C:/Music/Rock/song1.mp3',
          title: 'Song 1',
          artist: 'Artist 1',
          album: 'Album 1',
        ),
      ];

      final tree = treeBuilder.buildFolderTreeFromMetadata(
        initialSongs,
        (a, b) => a.compareTo(b),
        rootPath: 'C:/Music',
        rootName: 'Music',
      );

      expect(tree.subFolders.map((f) => f.name), contains('Rock'));
      final rockFolder = tree.subFolders.firstWhere((f) => f.name == 'Rock');
      expect(rockFolder.files.length, equals(1));

      final newSongs = [
        const SongMetadata(
          path: 'C:/Music/Rock/song2.mp3',
          title: 'Song 2',
          artist: 'Artist 2',
          album: 'Album 2',
        ),
        const SongMetadata(
          path: 'C:/Music/Jazz/song3.mp3',
          title: 'Song 3',
          artist: 'Artist 3',
          album: 'Album 3',
        ),
        const SongMetadata(
          path: 'C:/Music/root_song.mp3',
          title: 'Root Song',
          artist: 'Artist Root',
          album: 'Album Root',
        ),
      ];

      final modifiedFolders = treeBuilder.insertSongsToFolderTree(
        tree,
        newSongs,
        rootPath: 'C:/Music',
      );

      expect(modifiedFolders, isNotEmpty);
      expect(rockFolder.files.length, equals(2));
      expect(rockFolder.files.map((f) => f.title), containsAll(['Song 1', 'Song 2']));

      expect(tree.files.map((f) => f.title), contains('Root Song'));
      expect(tree.subFolders.map((f) => f.name), containsAll(['Rock', 'Jazz']));

      final jazzFolder = tree.subFolders.firstWhere((f) => f.name == 'Jazz');
      expect(jazzFolder.files.map((f) => f.title), contains('Song 3'));
    });
  });
}
