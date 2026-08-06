import 'package:vynody/models/lyric_line.dart';

class ParsedLyricsResult {
  final List<LyricLine> syncedLines;
  final List<String>? translatedLines;

  const ParsedLyricsResult({
    required this.syncedLines,
    this.translatedLines,
  });

  bool get hasTranslation =>
      translatedLines != null &&
      translatedLines!.any((line) => line.trim().isNotEmpty);
}

class LrcUtils {
  static final RegExp _timestampLinePattern = RegExp(
    r'[\[<\(]\s*\d{1,3}:\d{2}(?:[.:]\d{1,3})?\s*[\]>\)]',
  );

  static final RegExp _timestampTokenPattern = RegExp(
    r'^(\d{1,3}):(\d{2})(?:[.:](\d{1,3}))?$',
  );

  static final RegExp _inlineTranslationDelimiterPattern = RegExp(
    r'\s+[/／]\s+|\s*//\s*',
  );

  static List<LyricLine> parseTimedLyrics(String? lyrics) {
    return parseLyricsWithTranslation(lyrics).syncedLines;
  }

  static ParsedLyricsResult parseLyricsWithTranslation(String? lyrics) {
    if (lyrics == null || lyrics.trim().isEmpty) {
      return const ParsedLyricsResult(syncedLines: []);
    }

    final rawLines = lyrics.split(RegExp(r'\r?\n'));
    final blocks = <List<String>>[];
    var currentBlock = <String>[];

    for (final rawLine in rawLines) {
      final line = normalizeLrcLine(rawLine);
      if (line == null || line.isEmpty) {
        if (currentBlock.isNotEmpty) {
          blocks.add(currentBlock);
          currentBlock = <String>[];
        }
        continue;
      }
      currentBlock.add(line);
    }
    if (currentBlock.isNotEmpty) {
      blocks.add(currentBlock);
    }

    final allParsedLines = <LyricLine>[];

    for (final block in blocks) {
      final blockLines = <LyricLine>[];
      for (final line in block) {
        _parseSingleNormalizedLine(line, blockLines);
      }

      if (blockLines.isEmpty) continue;

      allParsedLines.addAll(_groupWordPerLineIfNeeded(blockLines));
    }

    if (allParsedLines.isEmpty) {
      return const ParsedLyricsResult(syncedLines: []);
    }

    // Check Format ①: Inline translation delimiter ("原文 / 译文")
    int inlineDelimiterCount = 0;
    for (final line in allParsedLines) {
      if (_hasInlineTranslationDelimiter(line.text)) {
        inlineDelimiterCount++;
      }
    }

    final isFormat1 = inlineDelimiterCount >= 2 ||
        (inlineDelimiterCount == 1 && allParsedLines.length <= 2);

    if (isFormat1) {
      final syncedLines = <LyricLine>[];
      final translatedLines = <String>[];

      for (final line in allParsedLines) {
        final split = _splitInlineTranslation(line.text);
        if (split != null) {
          syncedLines.add(line.copyWith(text: split.$1));
          translatedLines.add(split.$2);
        } else {
          syncedLines.add(line);
          translatedLines.add('');
        }
      }

      syncedLines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return ParsedLyricsResult(
        syncedLines: syncedLines,
        translatedLines: translatedLines,
      );
    }

    // Check Format ② & ③: Duplicate timestamps for main lyric vs translation
    // Group lines by exact timestamp, preserving file order in each bucket
    final timestampBuckets = <Duration, List<LyricLine>>{};
    for (final line in allParsedLines) {
      timestampBuckets.putIfAbsent(line.timestamp, () => []).add(line);
    }

    final hasTranslationDuplicates = timestampBuckets.values.any((bucket) {
      if (bucket.length <= 1) return false;
      final firstText = bucket.first.text.trim();
      return bucket.sublist(1).any((line) => line.text.trim() != firstText);
    });

    if (hasTranslationDuplicates) {
      final sortedTimestamps = timestampBuckets.keys.toList()
        ..sort((a, b) => a.compareTo(b));

      final syncedLines = <LyricLine>[];
      final translatedLines = <String>[];

      for (final ts in sortedTimestamps) {
        final bucket = timestampBuckets[ts]!;
        // 1st line in bucket is main lyric
        syncedLines.add(bucket.first);
        // 2nd (and subsequent) lines in bucket with different text are translation
        final firstText = bucket.first.text.trim();
        final translationBucket = bucket
            .sublist(1)
            .where((l) => l.text.trim() != firstText)
            .toList();

        if (translationBucket.isNotEmpty) {
          final translationText =
              translationBucket.map((l) => l.text.trim()).join(' / ');
          translatedLines.add(translationText);
        } else {
          translatedLines.add('');
        }
      }

      return ParsedLyricsResult(
        syncedLines: syncedLines,
        translatedLines: translatedLines,
      );
    }

    allParsedLines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return ParsedLyricsResult(syncedLines: allParsedLines);
  }

  static bool _hasInlineTranslationDelimiter(String text) {
    if (text.isEmpty) return false;
    if (_inlineTranslationDelimiterPattern.hasMatch(text)) return true;
    final cjkSlashMatch = RegExp(r'^(.*?)\s*[/／]\s*(.*?)$').firstMatch(text);
    if (cjkSlashMatch != null) {
      final part1 = cjkSlashMatch.group(1) ?? '';
      final part2 = cjkSlashMatch.group(2) ?? '';
      if (part1.isNotEmpty && part2.isNotEmpty && (_hasCJK(part1) || _hasCJK(part2))) {
        return true;
      }
    }
    return false;
  }

  static (String, String)? _splitInlineTranslation(String text) {
    final match = _inlineTranslationDelimiterPattern.firstMatch(text);
    if (match != null) {
      final orig = text.substring(0, match.start).trim();
      final trans = text.substring(match.end).trim();
      if (orig.isNotEmpty || trans.isNotEmpty) {
        return (orig, trans);
      }
    }

    final cjkSlashMatch = RegExp(r'^(.*?)\s*[/／]\s*(.*?)$').firstMatch(text);
    if (cjkSlashMatch != null) {
      final part1 = cjkSlashMatch.group(1)?.trim() ?? '';
      final part2 = cjkSlashMatch.group(2)?.trim() ?? '';
      if (part1.isNotEmpty && part2.isNotEmpty && (_hasCJK(part1) || _hasCJK(part2))) {
        return (part1, part2);
      }
    }

    return null;
  }

  static bool _hasCJK(String text) {
    for (final unit in text.codeUnits) {
      if (_isCJKCodeUnit(unit)) return true;
    }
    return false;
  }

  static void _parseSingleNormalizedLine(String line, List<LyricLine> targetList) {
    final lineTimestamps = <Duration>[];
    var index = 0;
    while (index < line.length) {
      final startChar = line[index];
      if (startChar != '[' && startChar != '<' && startChar != '(') {
        break;
      }
      final closingChar = startChar == '['
          ? ']'
          : (startChar == '<' ? '>' : ')');
      final end = line.indexOf(closingChar, index);
      if (end == -1) {
        break;
      }
      final token = line.substring(index + 1, end);
      final parsed = parseTimestampToken(token);
      if (parsed == null) {
        break;
      }
      lineTimestamps.add(parsed);
      index = end + 1;
    }

    if (lineTimestamps.isEmpty) {
      return;
    }

    final remainingContent = line.substring(index);
    final wordMatches = _timestampLinePattern.allMatches(remainingContent).toList();

    if (wordMatches.isEmpty) {
      final text = remainingContent.trim();
      for (final timestamp in lineTimestamps) {
        targetList.add(LyricLine(timestamp: timestamp, text: text, isTimed: true));
      }
    } else {
      // Parse word-by-word lyrics
      final baseTimestamp = lineTimestamps.first;
      final wordTokens = <_ParsedWordToken>[];

      final firstWordEnd = wordMatches.first.start;
      final firstWordText = remainingContent.substring(0, firstWordEnd);
      if (firstWordText.isNotEmpty) {
        wordTokens.add(_ParsedWordToken(baseTimestamp, firstWordText));
      }

      Duration? trailingTimestamp;
      for (int i = 0; i < wordMatches.length; i++) {
        final match = wordMatches[i];
        final token = match.group(0)!;
        final timestamp = parseTimestampToken(token);
        if (timestamp == null) continue;

        final startIdx = match.end;
        final endIdx = (i + 1 < wordMatches.length) ? wordMatches[i + 1].start : remainingContent.length;
        final wordText = remainingContent.substring(startIdx, endIdx);

        if (wordText.isNotEmpty) {
          wordTokens.add(_ParsedWordToken(timestamp, wordText));
        } else if (i == wordMatches.length - 1) {
          trailingTimestamp = timestamp;
        }
      }

      if (wordTokens.isNotEmpty) {
        final relativeWords = <_RelativeWord>[];
        final cleanTextBuffer = StringBuffer();

        for (int i = 0; i < wordTokens.length; i++) {
          final token = wordTokens[i];
          final Duration duration;
          if (i + 1 < wordTokens.length) {
            duration = wordTokens[i + 1].timestamp - token.timestamp;
          } else if (trailingTimestamp != null && trailingTimestamp > token.timestamp) {
            duration = trailingTimestamp - token.timestamp;
          } else {
            duration = const Duration(milliseconds: 1000);
          }

          final relativeOffset = token.timestamp - baseTimestamp;
          relativeWords.add(_RelativeWord(
            offset: relativeOffset,
            durationMs: duration.inMilliseconds,
            text: token.text,
          ));
          cleanTextBuffer.write(token.text);
        }

        final cleanText = cleanTextBuffer.toString().trim();
        if (cleanText.isNotEmpty) {
          for (final t in lineTimestamps) {
            final wordsList = relativeWords.map((rw) {
              return LyricWord(
                timestamp: t + rw.offset,
                durationMs: rw.durationMs,
                text: rw.text,
              );
            }).toList();

            targetList.add(LyricLine(
              timestamp: t,
              text: cleanText,
              isTimed: true,
              words: wordsList,
            ));
          }
        }
      }
    }
  }

  static List<LyricLine> _groupWordPerLineIfNeeded(List<LyricLine> initialLines) {
    if (initialLines.length <= 1) return initialLines;

    final result = <LyricLine>[];
    int i = 0;

    while (i < initialLines.length) {
      final current = initialLines[i];

      if (current.text.trim().isEmpty) {
        i++;
        continue;
      }

      final isCandidate = current.isTimed &&
          (current.words == null || current.words!.isEmpty || current.words!.length == 1) &&
          current.text.trim().length <= 4 &&
          !current.text.contains('\n');

      if (!isCandidate) {
        result.add(current);
        i++;
        continue;
      }

      final group = <LyricLine>[current];
      Duration? trailingTimestamp;
      int j = i + 1;
      while (j < initialLines.length) {
        final next = initialLines[j];
        final prev = group.last;

        if (next.isTimed && next.text.trim().isEmpty) {
          if (next.timestamp > prev.timestamp) {
            trailingTimestamp = next.timestamp;
          }
          j++;
          break;
        }

        final isNextCandidate = next.isTimed &&
            (next.words == null || next.words!.isEmpty || next.words!.length == 1) &&
            next.text.trim().length <= 4 &&
            !next.text.contains('\n') &&
            next.text.trim() != prev.text.trim();

        if (!isNextCandidate) break;

        final gap = next.timestamp - prev.timestamp;
        if (gap <= Duration.zero || gap > const Duration(milliseconds: 3000)) {
          break;
        }

        group.add(next);
        j++;
      }

      if (group.length >= 2) {
        final baseTimestamp = group.first.timestamp;
        final mergedWords = <LyricWord>[];
        final sb = StringBuffer();

        for (int k = 0; k < group.length; k++) {
          final gLine = group[k];
          final String wordText = gLine.text;

          final int durationMs;
          if (k + 1 < group.length) {
            durationMs = (group[k + 1].timestamp - gLine.timestamp).inMilliseconds;
          } else if (trailingTimestamp != null && trailingTimestamp > gLine.timestamp) {
            durationMs = (trailingTimestamp - gLine.timestamp).inMilliseconds;
          } else {
            durationMs = 1000;
          }

          if (k > 0 && _needsSpace(group[k - 1].text, wordText)) {
            sb.write(' ');
            mergedWords.add(LyricWord(
              timestamp: gLine.timestamp,
              durationMs: durationMs,
              text: ' $wordText',
            ));
          } else {
            mergedWords.add(LyricWord(
              timestamp: gLine.timestamp,
              durationMs: durationMs,
              text: wordText,
            ));
          }
          sb.write(wordText);
        }

        result.add(LyricLine(
          timestamp: baseTimestamp,
          text: sb.toString().trim(),
          isTimed: true,
          words: mergedWords,
        ));

        i = j;
      } else {
        result.add(current);
        i++;
      }
    }

    return result;
  }

  static bool _needsSpace(String text1, String text2) {
    if (text1.isEmpty || text2.isEmpty) return false;
    final lastChar = text1.trimRight().codeUnitAt(text1.trimRight().length - 1);
    final firstChar = text2.trimLeft().codeUnitAt(0);

    final isCJK1 = _isCJKCodeUnit(lastChar);
    final isCJK2 = _isCJKCodeUnit(firstChar);

    if (isCJK1 || isCJK2) return false;
    return true;
  }

  static bool _isCJKCodeUnit(int codeUnit) {
    return (codeUnit >= 0x4e00 && codeUnit <= 0x9fa5) ||
        (codeUnit >= 0x3040 && codeUnit <= 0x30ff) ||
        (codeUnit >= 0x31f0 && codeUnit <= 0x31ff) ||
        (codeUnit >= 0x1100 && codeUnit <= 0x11ff) ||
        (codeUnit >= 0xac00 && codeUnit <= 0xd7af);
  }

  static String? normalizeLrcLine(String rawLine) {
    var line = rawLine.trim();
    if (line.isEmpty) return null;

    line = line.replaceFirst(RegExp(r'^\uFEFF'), '');
    line = line.replaceFirst(RegExp(r'^(?:[-*•]+|\d+[.)])\s*'), '');

    final timestampMatch = _timestampLinePattern.firstMatch(line);
    if (timestampMatch == null) return null;

    return line.substring(timestampMatch.start).trimLeft();
  }

  static Duration? parseTimestampToken(String rawToken) {
    var token = rawToken.trim();
    if (token.startsWith('[') || token.startsWith('<') || token.startsWith('(')) {
      token = token.substring(1);
    }
    if (token.endsWith(']') || token.endsWith('>') || token.endsWith(')')) {
      token = token.substring(0, token.length - 1);
    }
    token = token.trim();

    final match = _timestampTokenPattern.firstMatch(token);
    if (match == null) return null;

    final minutes = int.tryParse(match.group(1)!);
    final seconds = int.tryParse(match.group(2)!);
    final fractionText = match.group(3) ?? '0';
    if (minutes == null || seconds == null) return null;

    final fraction = int.tryParse(
      fractionText.padRight(3, '0').substring(0, 3),
    );
    if (fraction == null) return null;

    return Duration(minutes: minutes, seconds: seconds, milliseconds: fraction);
  }

  static String stripTimestamps(String lyrics) {
    final lines = lyrics.split(RegExp(r'\r?\n'));
    final stripped = lines.map((line) {
      final withoutTimestamps = line.replaceAll(_timestampLinePattern, '');
      return withoutTimestamps.trimRight();
    }).toList();
    return stripped.join('\n').trim();
  }

  static String cleanGeneratedLyricsText(String? text) {
    final trimmed = text?.trim();
    if (trimmed == null || trimmed.isEmpty) return '';

    final fenceMatch = RegExp(
      r'```(?:lrc|lyrics)?\s*([\s\S]*?)```',
      caseSensitive: false,
    ).firstMatch(trimmed);
    final unwrapped = fenceMatch?.group(1)?.trim() ?? trimmed;

    final lines = unwrapped.split(RegExp(r'\r?\n'));
    final lrcLikeLines = <String>[];
    for (final rawLine in lines) {
      final normalized = normalizeLrcLine(rawLine);
      if (normalized != null) {
        lrcLikeLines.add(normalized);
      }
    }

    if (lrcLikeLines.isNotEmpty) {
      return lrcLikeLines.join('\n').trim();
    }

    return unwrapped.trim();
  }

  static String normalizeGeneratedLyricsText(String? text) {
    final cleaned = cleanGeneratedLyricsText(text);
    if (cleaned.isEmpty) return '';
    if (!_timestampLinePattern.hasMatch(cleaned)) return cleaned;

    final normalizedLines = <String>[];
    for (final rawLine in cleaned.split(RegExp(r'\r?\n'))) {
      final expandedLines = _expandPackedTimestampLine(rawLine);
      if (expandedLines.isEmpty) {
        final line = rawLine.trim();
        if (line.isNotEmpty) {
          normalizedLines.add(line);
        }
        continue;
      }

      normalizedLines.addAll(expandedLines);
    }

    return normalizedLines.join('\n').trim();
  }

  static List<String> _expandPackedTimestampLine(String rawLine) {
    final line = rawLine.trim();
    if (line.isEmpty) return const [];

    final normalized = normalizeLrcLine(line);
    if (normalized == null || normalized.isEmpty) return const [];

    final matches = _timestampLinePattern
        .allMatches(normalized)
        .toList(growable: false);
    if (matches.isEmpty) return const [];

    final expandedLines = <String>[];
    final timestampGroup = <String>[];
    var lastTimestampEnd = matches.first.end;

    String timestampText(int index) {
      return matches[index].group(0)!.trim();
    }

    void emitGroup(String text) {
      final normalizedText = text.trim();
      if (normalizedText.isEmpty || timestampGroup.isEmpty) {
        timestampGroup.clear();
        return;
      }

      for (final timestamp in timestampGroup) {
        expandedLines.add('$timestamp $normalizedText'.trim());
      }
      timestampGroup.clear();
    }

    timestampGroup.add(timestampText(0));

    for (var i = 1; i < matches.length; i++) {
      final match = matches[i];
      final betweenText = normalized
          .substring(lastTimestampEnd, match.start)
          .trim();
      if (betweenText.isEmpty) {
        timestampGroup.add(timestampText(i));
      } else {
        emitGroup(betweenText);
        timestampGroup.add(timestampText(i));
      }
      lastTimestampEnd = match.end;
    }

    emitGroup(normalized.substring(lastTimestampEnd));
    return expandedLines;
  }
}

class _ParsedWordToken {
  final Duration timestamp;
  final String text;
  _ParsedWordToken(this.timestamp, this.text);
}

class _RelativeWord {
  final Duration offset;
  final int durationMs;
  final String text;
  _RelativeWord({
    required this.offset,
    required this.durationMs,
    required this.text,
  });
}
