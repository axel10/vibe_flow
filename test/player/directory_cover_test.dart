import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vynody/player/metadata/metadata_helper.dart';

void main() {
  group('MetadataHelper.findDirectoryCover', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('vynody_cover_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('finds cover.jpg in directory', () async {
      final songFile = File(p.join(tempDir.path, 'song.mp3'));
      await songFile.writeAsString('fake audio');

      final coverFile = File(p.join(tempDir.path, 'cover.jpg'));
      await coverFile.writeAsString('fake image');

      final result = MetadataHelper.findDirectoryCover(songFile.path);
      expect(result, equals(coverFile.path));
    });

    test('finds cover image with uppercase extension (COVER.PNG)', () async {
      final songFile = File(p.join(tempDir.path, 'song.flac'));
      await songFile.writeAsString('fake audio');

      final coverFile = File(p.join(tempDir.path, 'COVER.PNG'));
      await coverFile.writeAsString('fake image');

      final result = MetadataHelper.findDirectoryCover(songFile.path);
      expect(result?.toLowerCase(), equals(coverFile.path.toLowerCase()));
    });

    test('finds cover image with mixed case filename (Cover.jpeg)', () async {
      final songFile = File(p.join(tempDir.path, 'song.wav'));
      await songFile.writeAsString('fake audio');

      final coverFile = File(p.join(tempDir.path, 'Cover.jpeg'));
      await coverFile.writeAsString('fake image');

      final result = MetadataHelper.findDirectoryCover(songFile.path);
      expect(result?.toLowerCase(), equals(coverFile.path.toLowerCase()));
    });

    test('finds cover.webp format', () async {
      final songFile = File(p.join(tempDir.path, 'track.m4a'));
      await songFile.writeAsString('fake audio');

      final coverFile = File(p.join(tempDir.path, 'cover.webp'));
      await coverFile.writeAsString('fake image');

      final result = MetadataHelper.findDirectoryCover(songFile.path);
      expect(result, equals(coverFile.path));
    });

    test('returns null when no cover.xxx exists', () async {
      final songFile = File(p.join(tempDir.path, 'track.mp3'));
      await songFile.writeAsString('fake audio');

      final otherImage = File(p.join(tempDir.path, 'back_cover.jpg'));
      await otherImage.writeAsString('fake image');

      final result = MetadataHelper.findDirectoryCover(songFile.path);
      expect(result, isNull);
    });

    test('uses dirCache when provided', () async {
      final songFile = File(p.join(tempDir.path, 'track.mp3'));
      final coverFile = File(p.join(tempDir.path, 'cover.png'));
      await coverFile.writeAsString('fake image');

      final dirCache = <String, String?>{};
      final result1 = MetadataHelper.findDirectoryCover(songFile.path, dirCache: dirCache);
      expect(result1, equals(coverFile.path));
      expect(dirCache[tempDir.path], equals(coverFile.path));

      // Second call uses cached result
      final result2 = MetadataHelper.findDirectoryCover(songFile.path, dirCache: dirCache);
      expect(result2, equals(coverFile.path));
    });
  });
}
