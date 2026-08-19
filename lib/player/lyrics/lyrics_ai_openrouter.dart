import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart'
    show
        CancelToken,
        DioException,
        DioExceptionType,
        Headers,
        Options,
        RequestOptions,
        ResponseType;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'package:vynody/utils/lrc_utils.dart';
import 'package:vynody/utils/network_client.dart';
import 'package:vynody/utils/localized_text.dart';
import 'package:vynody/player/lyrics/lyrics_ai_shared.dart';
import 'package:vynody/player/lyrics/lyrics_ai_stream_parser.dart';
import 'package:vynody/player/lyrics/lyrics_generation_result.dart';
import 'package:vynody/player/settings/settings_service.dart';

class LyricsAiOpenRouterClient {
  LyricsAiOpenRouterClient({
    NetworkClient? client,
    LyricsAiStreamTextParser? streamParser,
  }) : _client = client ?? NetworkClient.instance,
       _streamParser = streamParser ?? LyricsAiStreamTextParser();

  final NetworkClient _client;
  final LyricsAiStreamTextParser _streamParser;

  static const String audioModelId = 'google/gemini-3.1-flash-lite';
  static const String textModelId = 'google/gemini-3.1-flash-lite';
  static const String textModelDisplayName = 'Gemini 3.1 Flash Lite';

  Future<LyricsGenerationResult> generateLyricsFromFile({
    required String apiKey,
    required String filePath,
    required String modelId,
    String? songTitle,
    void Function(double progress)? onUploadProgress,
    void Function(String stage)? onStageChanged,
    void Function(String partialText, bool isFinal)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      debugPrint('[OpenRouterLyrics] file not found for generation: $filePath');
      return LyricsGenerationResult.failure(
        _l10n().localSongFileNotFoundForGeneration,
      );
    }

    final prompt = LyricsAiPromptBuilder.buildGenerateLyricsPrompt(
      songTitle: songTitle,
    );

    try {
      onStageChanged?.call('requesting');
      onUploadProgress?.call(1.0);
      final fileBytes = await file.readAsBytes();
      final audioFormat = _audioFormatForFilePath(filePath);
      final requestData = _buildAudioRequestData(
        modelId: modelId,
        prompt: prompt,
        audioBase64: base64Encode(fileBytes),
        audioFormat: audioFormat,
        stream: true,
      );
      _logRequest(
        action: 'generate_lyrics',
        requestData: requestData,
        prompt: prompt,
        extra: {
          'filePath': filePath,
          'fileSizeBytes': fileBytes.length,
          'audioFormat': audioFormat,
          'songTitle': songTitle?.trim() ?? '',
        },
      );

      final generatedBuffer = StringBuffer();
      String lastEmitted = '';
      var sawRefusalLikeText = false;
      await _streamTextResponse(
        apiKey: apiKey,
        requestData: requestData,
        onStageChanged: onStageChanged,
        cancelToken: cancelToken,
        onChunk: (chunk) {
          if (_streamParser.looksLikeRefusalText(chunk)) {
            sawRefusalLikeText = true;
          }
          generatedBuffer.write(chunk);
          final current = _currentLyricsSnapshot(generatedBuffer.toString());
          if (_looksLikeRefusalResponse(current)) {
            sawRefusalLikeText = true;
            return;
          }
          if (current.isEmpty || current == lastEmitted) {
            return;
          }
          lastEmitted = current;
          onProgress?.call(current, false);
        },
      );

      final generatedText = _streamParser.extractText(
        generatedBuffer.toString(),
      );
      final cleanedText = LrcUtils.cleanGeneratedLyricsText(
        generatedText ?? generatedBuffer.toString(),
      );
      final normalizedText = LrcUtils.normalizeGeneratedLyricsText(cleanedText);
      if (sawRefusalLikeText || _looksLikeRefusalResponse(normalizedText)) {
        return LyricsGenerationResult.failure(
          _l10n().modelRefusedToGenerateLyrics,
        );
      }
      if (normalizedText.trim().isEmpty) {
        return LyricsGenerationResult.failure(
          _l10n().openRouterEmptyResponse,
        );
      }

      debugPrint('[OpenRouterLyrics] final generated lyrics:');
      debugPrint(normalizedText);
      onProgress?.call(normalizedText, true);
      return LyricsGenerationResult.success(normalizedText);
    } catch (e) {
      return LyricsGenerationResult.failure(
        _formatGenerationErrorMessage(
          e,
          modelId: modelId,
          fallback: _l10n().unknownGenerationError,
        ),
      );
    }
  }

  Future<LyricsGenerationResult> generateTimelineFromLyrics({
    required String apiKey,
    required String filePath,
    required String lyrics,
    required String modelId,
    void Function(double progress)? onUploadProgress,
    void Function(String stage)? onStageChanged,
    void Function(String partialText, bool isFinal)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      debugPrint('[OpenRouterLyrics] file not found for timeline: $filePath');
      return LyricsGenerationResult.failure(
        _l10n().localSongFileNotFoundForTimeline,
      );
    }

    final normalizedLyrics = lyrics.trim();
    if (normalizedLyrics.isEmpty) {
      debugPrint(
        '[OpenRouterLyrics] no usable lyrics for timeline generation.',
      );
      return LyricsGenerationResult.failure(
        _l10n().noLyricsForTimelineGeneration,
      );
    }

    final prompt = LyricsAiPromptBuilder.buildGenerateTimelinePrompt(
      lyrics: normalizedLyrics,
    );

    try {
      onStageChanged?.call('requesting');
      onUploadProgress?.call(1.0);
      final fileBytes = await file.readAsBytes();
      final audioFormat = _audioFormatForFilePath(filePath);
      final requestData = {
        ..._buildAudioRequestData(
          modelId: modelId,
          prompt: prompt,
          audioBase64: base64Encode(fileBytes),
          audioFormat: audioFormat,
          stream: true,
        ),
      };
      _logRequest(
        action: 'generate_timeline',
        requestData: requestData,
        prompt: prompt,
        extra: {
          'filePath': filePath,
          'fileSizeBytes': fileBytes.length,
          'audioFormat': audioFormat,
          'sourceLength': normalizedLyrics.length,
        },
      );

      final generatedBuffer = StringBuffer();
      String lastEmitted = '';
      var sawRefusalLikeText = false;
      await _streamTextResponse(
        apiKey: apiKey,
        requestData: requestData,
        onStageChanged: onStageChanged,
        cancelToken: cancelToken,
        onChunk: (chunk) {
          _logChunk('generate_timeline', chunk);
          if (_streamParser.looksLikeRefusalText(chunk)) {
            sawRefusalLikeText = true;
          }
          generatedBuffer.write(chunk);
          final current = _currentLyricsSnapshot(generatedBuffer.toString());
          if (_looksLikeRefusalResponse(current)) {
            sawRefusalLikeText = true;
            return;
          }
          if (current.isEmpty || current == lastEmitted) {
            return;
          }
          lastEmitted = current;
          onProgress?.call(current, false);
        },
      );

      final generatedText = _streamParser.extractText(
        generatedBuffer.toString(),
      );
      final cleanedText = LrcUtils.cleanGeneratedLyricsText(
        generatedText ?? generatedBuffer.toString(),
      );
      final normalizedText = LrcUtils.normalizeGeneratedLyricsText(cleanedText);
      if (sawRefusalLikeText || _looksLikeRefusalResponse(normalizedText)) {
        return LyricsGenerationResult.failure(
          _l10n().modelRefusedToGenerateTimeline,
        );
      }
      debugPrint(
        '[OpenRouterLyrics] timeline completed -> '
        'rawLength=${generatedBuffer.length} cleanedLength=${normalizedText.length}',
      );
      if (normalizedText.trim().isEmpty) {
        return LyricsGenerationResult.failure(
          _l10n().openRouterEmptyResponse,
        );
      }

      onProgress?.call(normalizedText, true);
      return LyricsGenerationResult.success(normalizedText);
    } catch (e) {
      return LyricsGenerationResult.failure(
        _formatGenerationErrorMessage(
          e,
          modelId: modelId,
          fallback: _l10n().unknownTimelineGenerationError,
        ),
      );
    }
  }

  Map<String, dynamic> _buildAudioRequestData({
    required String modelId,
    required String prompt,
    required String audioBase64,
    required String audioFormat,
    required bool stream,
    bool enableReasoning = true,
  }) {
    return {
      'model': modelId,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'input_audio',
              'input_audio': {'data': audioBase64, 'format': audioFormat},
            },
          ],
        },
      ],
      'stream': stream,
      if (enableReasoning) 'reasoning': {'enabled': true},
    };
  }

  Future<void> _streamTextResponse({
    required String apiKey,
    required Map<String, dynamic> requestData,
    void Function(String stage)? onStageChanged,
    required void Function(String chunk) onChunk,
    CancelToken? cancelToken,
  }) async {
    debugPrint(
      '[OpenRouterLyrics] request dispatch -> '
      'model=${requestData['model']} '
      'messageCount=${(requestData['messages'] as List?)?.length ?? 0} '
      'stream=${requestData['stream']}',
    );
    final response = await _client.post(
      'https://openrouter.ai/api/v1/chat/completions',
      data: requestData,
      options: Options(
        responseType: ResponseType.stream,
        contentType: Headers.jsonContentType,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      cancelToken: cancelToken,
    );

    onStageChanged?.call('generating');
    debugPrint(
      '[OpenRouterLyrics] response metadata -> '
      'status=${response.statusCode} '
      'contentType=${response.headers.value('content-type') ?? 'n/a'}',
    );

    final body = response.data;
    if (body == null || body.stream == null) {
      throw Exception(
        _l10n().openRouterEmptyStreamingResponse,
      );
    }

    final textStream = body.stream.cast<List<int>>().transform(utf8.decoder);
    await for (final line in textStream.transform(const LineSplitter())) {
      if (cancelToken?.isCancelled == true) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.cancel,
        );
      }
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith(':')) {
        debugPrint('[OpenRouterLyrics] sse comment -> $trimmed');
        continue;
      }

      final data = trimmed.startsWith('data:')
          ? trimmed.substring(5).trim()
          : trimmed;
      if (data.isEmpty || data == '[DONE]') {
        if (data == '[DONE]') break;
        continue;
      }

      debugPrint('[OpenRouterLyrics] sse raw -> ${_truncateForLog(data)}');
      final chunk = _streamParser.extractText(data);
      if (chunk == null || chunk.isEmpty) continue;
      onChunk(chunk);
    }
    debugPrint('[OpenRouterLyrics] stream completed');
  }

  void _logRequest({
    required String action,
    required Map<String, dynamic> requestData,
    required String prompt,
    required Map<String, Object?> extra,
  }) {
    debugPrint(
      '[OpenRouterLyrics] $action start -> model=${requestData['model']} '
      'promptLength=${prompt.length} extra=${jsonEncode(extra)}',
    );
    debugPrint(
      '[OpenRouterLyrics] $action prompt preview -> '
      '${_truncateForLog(prompt, maxLength: 800)}',
    );
    debugPrint(
      '[OpenRouterLyrics] $action request payload -> '
      '${jsonEncode(_sanitizeRequestData(requestData))}',
    );
  }

  void _logChunk(String action, String chunk) {
    debugPrint(
      '[OpenRouterLyrics] $action chunk -> '
      'length=${chunk.length} preview=${_truncateForLog(chunk, maxLength: 200)}',
    );
  }

  String _truncateForLog(String value, {int maxLength = 300}) {
    final text = value.trim();
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _currentLyricsSnapshot(String rawText) {
    final cleaned = LrcUtils.cleanGeneratedLyricsText(rawText);
    if (cleaned.isEmpty) {
      return '';
    }
    if (!_containsTimestampedLyrics(cleaned) &&
        !_streamParser.looksLikeRefusalText(cleaned)) {
      return '';
    }
    return LrcUtils.normalizeGeneratedLyricsText(cleaned);
  }

  bool _containsTimestampedLyrics(String text) {
    return RegExp(r'\[\s*\d{1,3}:\d{2}(?:[.:]\d{1,3})?\s*\]').hasMatch(text);
  }

  bool _looksLikeRefusalResponse(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return false;
    }

    if (_streamParser.looksLikeRefusalText(normalized)) {
      return true;
    }

    final refusalMarkers = <String>[
      '版权',
      'copyright',
      'cannot provide',
      'can’t provide',
      "can't provide",
      'unable to provide',
      'refuse',
      'decline',
      '抱歉',
      '无法提供',
      '不提供',
      '不能提供',
      '不能帮助',
      '无法帮助',
    ];
    final lower = normalized.toLowerCase();
    return refusalMarkers.any((marker) => lower.contains(marker));
  }

  Map<String, dynamic> _sanitizeRequestData(Map<String, dynamic> requestData) {
    return requestData.map((key, value) {
      if (key != 'messages' || value is! List) {
        return MapEntry(key, value);
      }

      final sanitizedMessages = value
          .map((message) {
            if (message is! Map) return message;

            final sanitizedMessage = Map<String, dynamic>.from(message);
            final content = sanitizedMessage['content'];
            if (content is! List) return sanitizedMessage;

            sanitizedMessage['content'] = content
                .map((part) {
                  if (part is! Map) return part;

                  final sanitizedPart = Map<String, dynamic>.from(part);
                  if (sanitizedPart['type'] == 'input_audio') {
                    final inputAudio = sanitizedPart['input_audio'];
                    if (inputAudio is Map) {
                      final sanitizedAudio = Map<String, dynamic>.from(
                        inputAudio,
                      );
                      final data = sanitizedAudio['data'];
                      sanitizedAudio['data'] = data is String
                          ? '<base64 omitted, length=${data.length}>'
                          : '<base64 omitted>';
                      sanitizedPart['input_audio'] = sanitizedAudio;
                    }
                  }
                  return sanitizedPart;
                })
                .toList(growable: false);

            return sanitizedMessage;
          })
          .toList(growable: false);

      return MapEntry(key, sanitizedMessages);
    });
  }

  String _audioFormatForFilePath(String filePath) {
    switch (p.extension(filePath).toLowerCase()) {
      case '.mp3':
        return 'mp3';
      case '.m4a':
      case '.mp4':
      case '.m4b':
        return 'm4a';
      case '.flac':
        return 'flac';
      case '.wav':
        return 'wav';
      case '.aac':
        return 'aac';
      case '.ogg':
        return 'ogg';
      case '.opus':
        return 'opus';
      case '.aif':
      case '.aiff':
        return 'aiff';
      default:
        return 'wav';
    }
  }

  static bool isOpenRouter403Forbidden(Object error) {
    if (error is DioException) {
      if (error.response?.statusCode == 403) {
        return true;
      }
      final responseData = error.response?.data;
      if (responseData is Map) {
        final errorMap = responseData['error'];
        if (errorMap is Map) {
          final code = errorMap['code'];
          if (code == 403 || code == '403') {
            return true;
          }
        }
        final code = responseData['code'];
        if (code == 403 || code == '403') {
          return true;
        }
      }
      final message = error.message;
      if (message != null && message.contains('403')) {
        return true;
      }
    }
    final text = error.toString();
    return text.contains('403');
  }

  String _formatGenerationErrorMessage(
    Object error, {
    String? modelId,
    String? fallback,
  }) {
    if (isOpenRouter403Forbidden(error)) {
      final modelName = modelId != null && modelId.trim().isNotEmpty
          ? SettingsService.lyricsModelDisplayName(modelId.trim())
          : '';
      final displayName = modelName.isNotEmpty ? modelName : (modelId?.trim() ?? '');
      if (displayName.isNotEmpty) {
        return _l10n().locationNotSupportedForModel(displayName);
      }
    }

    if (error is DioException) {
      if (_isNetworkUnavailableError(error)) {
        return _networkUnavailableMessage;
      }

      final response = error.response;
      final statusCode = response?.statusCode;
      final responseData = response?.data;

      if (responseData is Map) {
        final errorMap = responseData['error'];
        if (errorMap is Map) {
          final message = errorMap['message']?.toString().trim();
          if (message != null && message.isNotEmpty) {
            if (statusCode == null) {
              return message;
            }
            return '($statusCode) $message';
          }
        }
      }

      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) {
        if (statusCode == null) {
          return message;
        }
        return '($statusCode) $message';
      }
    }

    final text = error.toString().trim();
    if (text.isNotEmpty) {
      return text;
    }

    return fallback ?? _l10n().unknownError;
  }

  bool _isNetworkUnavailableError(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return true;
    }

    if (error.error is SocketException) {
      return true;
    }

    final text = [
      error.message,
      error.error?.toString(),
    ].whereType<String>().join(' ').toLowerCase();

    return text.contains('connection failed') ||
        text.contains('network is unreachable') ||
        text.contains('failed host lookup') ||
        text.contains('no address associated with hostname') ||
        text.contains('software caused connection abort') ||
        text.contains('connection refused') ||
        text.contains('os error: 101') ||
        text.contains('os error: 113');
  }

  String get _networkUnavailableMessage =>
      _l10n().networkRequestFailedCheckProxy;
}

AppLocalizations _l10n() => currentAppL10n;
