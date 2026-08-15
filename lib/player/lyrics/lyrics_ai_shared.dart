import 'package:vynody/utils/localized_text.dart';
import 'package:vynody/utils/lrc_utils.dart';

final class LyricsAiPromptBuilder {
  const LyricsAiPromptBuilder._();

  static String buildGenerateLyricsPrompt({String? songTitle}) {
    final normalizedTitle = songTitle?.trim();
    final titleHint = normalizedTitle == null || normalizedTitle.isEmpty
        ? ''
        : '这首歌的标题是《$normalizedTitle》。';
    return '$titleHint'
        '输出这首歌的完整的带时间轴的标准LRC格式歌词,每一行歌词前面都带有一个方括号包裹的时间点，格式通常为：[mm:ss.ms]歌词内容。mm: 分钟（00-99）ss: 秒（00-59）ms: 毫秒（通常为 3 位）。'
        '合理组织每一行歌词长度，不要太长也不要太短。'
        '仅输出结果不输出其他内容。';
  }

  static String buildGenerateTimelinePrompt({
    required String lyrics,
  }) {
    final cleanLyrics = LrcUtils.stripTimestamps(lyrics);
    const prompt = '这是这首歌的歌词和原文件，帮我把这些歌词打上时间轴。格式为[mm:ss.ms]歌词内容。mm: 分钟（00-99）ss: 秒（00-59）ms: 毫秒（通常为 3 位）。仅输出结果不输出其他内容（我拿来当api用的）';
    return '$prompt\n```text\n$cleanLyrics\n```';
  }

  static String buildTranslateLyricsPrompt({
    required String lyrics,
    required String targetLanguageCode,
  }) {
    final targetLanguageName = LyricsAiTranslationTextHelper.targetLanguageName(
      targetLanguageCode,
    );
    return '将以下歌词翻译成$targetLanguageName，仅输出目标译文不输出其他内容。不要输出原文。'
        '请保留完整时间轴和原有分行顺序，不要删减、合并、重排任何一行，也不要自行补充空行、编号或解释。'
        '如果输入中带有时间轴，请在输出中原样保留对应时间轴，程序会在后处理去掉时间轴。'
        '总结整首歌的意境并结合上下文尽量意译。如果无标题不要自行生成标题。\n'
        '${lyrics.trim()}';
  }
}

final class LyricsAiTranslationPreparation {
  const LyricsAiTranslationPreparation({
    required this.sourceLines,
    required this.blankLineIndexes,
    required this.compactSourceLines,
  });

  final List<String> sourceLines;
  final List<int> blankLineIndexes;
  final List<String> compactSourceLines;

  int get targetLineCount => compactSourceLines.length;
}

final class LyricsAiTranslationProgressSnapshot {
  const LyricsAiTranslationProgressSnapshot({
    required this.visibleLines,
    required this.visibleText,
  });

  final List<String> visibleLines;
  final String visibleText;
}

final class LyricsAiTranslationStreamProcessor {
  LyricsAiTranslationStreamProcessor({
    required LyricsAiTranslationPreparation preparation,
    this.emitPartialLineForStreaming = true,
  }) : _preparation = preparation;

  final LyricsAiTranslationPreparation _preparation;
  final bool emitPartialLineForStreaming;
  final StringBuffer _translatedBuffer = StringBuffer();
  String _lastSnapshot = '';
  int _lastPrintedLength = -1;
  bool _receivedAnyChunk = false;

  bool get hasReceivedAnyChunk => _receivedAnyChunk;

  void addChunk(String chunk) {
    if (chunk.isEmpty) return;
    _receivedAnyChunk = true;
    _translatedBuffer.write(chunk);
  }

  LyricsAiTranslationProgressSnapshot? buildProgressSnapshot({
    bool force = false,
    bool dedupeByLength = false,
  }) {
    final rawCurrent = _translatedBuffer.toString();
    final cleanedCurrent = LyricsAiTranslationTextHelper.stripTimestamps(
      rawCurrent,
    );
    final current = emitPartialLineForStreaming
        ? cleanedCurrent
        : LyricsAiTranslationTextHelper.visibleTranslationText(
            cleanedCurrent,
            rawCurrent,
            force: force,
          );
    if (current.isEmpty) {
      return null;
    }
    if (dedupeByLength && !force && current.length == _lastPrintedLength) {
      return null;
    }
    _lastPrintedLength = current.length;

    final lines = LyricsAiTranslationTextHelper.normalizeTranslationLines(
      current,
      _preparation.targetLineCount,
    );
    final restoredLines = LyricsAiTranslationTextHelper.restoreBlankLines(
      lines,
      _preparation.blankLineIndexes,
      _preparation.sourceLines.length,
    );
    final visibleLines = restoredLines
        .map(
          (line) => LyricsAiTranslationTextHelper.stripTimestampPrefix(
            line,
          ).trimRight(),
        )
        .toList(growable: false);
    final snapshot = visibleLines.join('\n');
    if (!force && snapshot == _lastSnapshot) {
      return null;
    }
    _lastSnapshot = snapshot;
    return LyricsAiTranslationProgressSnapshot(
      visibleLines: visibleLines,
      visibleText: snapshot,
    );
  }

  String get finalVisibleText => LyricsAiTranslationTextHelper.stripTimestamps(
    _translatedBuffer.toString(),
  ).trim();
}

final class LyricsAiTranslationTextHelper {
  LyricsAiTranslationTextHelper._();

  static final RegExp _lineSplitPattern = RegExp(r'\r?\n');
  static final RegExp _timestampLinePattern = RegExp(
    r'[\[<\(]\s*\d{1,3}:\d{2}(?:[.:]\d{1,3})?\s*[\]>\)]',
  );

  static LyricsAiTranslationPreparation prepareSourceLyrics(String lyrics) {
    final sourceLines = splitLines(lyrics);
    final blankLineIndexes = <int>[];
    final compactSourceLines = <String>[];
    for (var i = 0; i < sourceLines.length; i++) {
      final line = stripTimestampPrefix(sourceLines[i]).trim();
      if (line.isEmpty) {
        blankLineIndexes.add(i);
      } else {
        compactSourceLines.add(line);
      }
    }
    return LyricsAiTranslationPreparation(
      sourceLines: sourceLines,
      blankLineIndexes: blankLineIndexes,
      compactSourceLines: compactSourceLines,
    );
  }

  static List<String> splitLines(String text) {
    return text.split(_lineSplitPattern);
  }

  static String normalizeSourceLyrics(String lyrics) {
    return splitLines(lyrics).join('\n').trim();
  }

  static String stripTimestamps(String lyrics) {
    final normalized = LrcUtils.normalizeGeneratedLyricsText(lyrics);
    return LrcUtils.stripTimestamps(normalized);
  }

  static String stripTimestampPrefix(String line) {
    return line.replaceAll(_timestampLinePattern, '');
  }

  static List<String> normalizeTranslationLines(
    String text,
    int targetLineCount,
  ) {
    final lines = splitLines(text)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (targetLineCount <= 0) return lines;
    if (lines.length <= targetLineCount) return lines;
    return lines.take(targetLineCount).toList(growable: false);
  }

  static List<String> restoreBlankLines(
    List<String> translatedLines,
    List<int> blankLineIndexes,
    int originalLineCount,
  ) {
    if (originalLineCount <= 0) return const [];
    if (translatedLines.isEmpty && blankLineIndexes.isEmpty) {
      return List<String>.filled(originalLineCount, '', growable: false);
    }

    final blankLineIndexSet = blankLineIndexes.toSet();
    final restoredLines = List<String>.filled(
      originalLineCount,
      '',
      growable: false,
    );
    var translatedIndex = 0;

    for (var i = 0; i < originalLineCount; i++) {
      if (blankLineIndexSet.contains(i)) continue;
      if (translatedIndex >= translatedLines.length) break;
      restoredLines[i] = translatedLines[translatedIndex++];
    }

    return restoredLines;
  }

  static String visibleTranslationText(
    String cleanedText,
    String rawText, {
    required bool force,
  }) {
    if (cleanedText.isEmpty) return '';
    if (force || rawText.endsWith('\n') || rawText.endsWith('\r')) {
      return cleanedText;
    }

    final lines = splitLines(cleanedText);
    if (lines.length <= 1) return '';
    return lines.take(lines.length - 1).join('\n').trim();
  }

  static String targetLanguageName(String languageCode) {
    switch (languageCode.toLowerCase().trim()) {
      case 'zh':
      case 'zh-cn':
      case 'zh-hans':
        return _l10n().chineseLanguage;
      case 'zh-tw':
      case 'zh-hant':
        return _l10n().traditionalChinese;
      case 'en':
        return _l10n().englishLanguage;
      case 'ja':
        return _l10n().japaneseLanguage;
      case 'ko':
        return _l10n().koreanLanguage;
      case 'fr':
        return _l10n().frenchLanguage;
      case 'de':
        return _l10n().germanLanguage;
      case 'es':
        return _l10n().spanishLanguage;
      case 'pt':
        return _l10n().portugueseLanguage;
      case 'ru':
        return _l10n().russianLanguage;
      case 'tr':
        return _l10n().turkishLanguage;
      default:
        return languageCode.trim().isEmpty
            ? _l10n().targetLanguage
            : languageCode;
    }
  }

}

AppLocalizations _l10n() => currentAppL10n;
