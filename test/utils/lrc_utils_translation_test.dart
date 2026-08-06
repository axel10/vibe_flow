import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/utils/lrc_utils.dart';

void main() {
  group('LrcUtils.parseLyricsWithTranslation', () {
    test('Format ①: parses single line original / translation with space-slash-space', () {
      const lrc = '''
[00:10.00] First line original / 第一句译文
[00:15.00] Second line original / 第二句译文
[00:20.00] Third line original / 第三句译文
''';

      final result = LrcUtils.parseLyricsWithTranslation(lrc);

      expect(result.hasTranslation, isTrue);
      expect(result.syncedLines.length, 3);
      expect(result.translatedLines, isNotNull);
      expect(result.translatedLines!.length, 3);

      expect(result.syncedLines[0].text, 'First line original');
      expect(result.translatedLines![0], '第一句译文');

      expect(result.syncedLines[1].text, 'Second line original');
      expect(result.translatedLines![1], '第二句译文');

      expect(result.syncedLines[2].text, 'Third line original');
      expect(result.translatedLines![2], '第三句译文');
    });

    test('Format ①: parses single line original / translation with full-width slash', () {
      const lrc = '''
[00:10.00]First line original／第一句译文
[00:15.00]Second line original／第二句译文
''';

      final result = LrcUtils.parseLyricsWithTranslation(lrc);

      expect(result.hasTranslation, isTrue);
      expect(result.syncedLines.length, 2);
      expect(result.syncedLines[0].text, 'First line original');
      expect(result.translatedLines![0], '第一句译文');
    });

    test('Format ②: parses line-by-line interleaved original and translation with identical timestamps', () {
      const lrc = '''
[00:10.00]First line original
[00:10.00]第一句译文
[00:15.00]Second line original
[00:15.00]第二句译文
[00:20.00]Third line without translation
''';

      final result = LrcUtils.parseLyricsWithTranslation(lrc);

      expect(result.hasTranslation, isTrue);
      expect(result.syncedLines.length, 3);
      expect(result.translatedLines!.length, 3);

      expect(result.syncedLines[0].timestamp, const Duration(seconds: 10));
      expect(result.syncedLines[0].text, 'First line original');
      expect(result.translatedLines![0], '第一句译文');

      expect(result.syncedLines[1].timestamp, const Duration(seconds: 15));
      expect(result.syncedLines[1].text, 'Second line original');
      expect(result.translatedLines![1], '第二句译文');

      expect(result.syncedLines[2].timestamp, const Duration(seconds: 20));
      expect(result.syncedLines[2].text, 'Third line without translation');
      expect(result.translatedLines![2], '');
    });

    test('Format ③: parses separate original block and translation block with matching timestamps', () {
      const lrc = '''
[00:10.00]First line original
[00:15.00]Second line original
[00:20.00]Third line original

[00:10.00]第一句译文
[00:15.00]第二句译文
[00:20.00]第三句译文
''';

      final result = LrcUtils.parseLyricsWithTranslation(lrc);

      expect(result.hasTranslation, isTrue);
      expect(result.syncedLines.length, 3);
      expect(result.translatedLines!.length, 3);

      expect(result.syncedLines[0].timestamp, const Duration(seconds: 10));
      expect(result.syncedLines[0].text, 'First line original');
      expect(result.translatedLines![0], '第一句译文');

      expect(result.syncedLines[1].timestamp, const Duration(seconds: 15));
      expect(result.syncedLines[1].text, 'Second line original');
      expect(result.translatedLines![1], '第二句译文');

      expect(result.syncedLines[2].timestamp, const Duration(seconds: 20));
      expect(result.syncedLines[2].text, 'Third line original');
      expect(result.translatedLines![2], '第三句译文');
    });

    test('Normal LRC without translation returns hasTranslation = false', () {
      const lrc = '''
[00:10.00]Line one
[00:15.00]Line two
[00:20.00]Line three
''';

      final result = LrcUtils.parseLyricsWithTranslation(lrc);

      expect(result.hasTranslation, isFalse);
      expect(result.syncedLines.length, 3);
      expect(result.translatedLines, isNull);
    });
  });
}
