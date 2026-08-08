import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:vynody/utils/network_client.dart';
import 'package:vynody/player/settings/settings_service.dart';

import 'package:vynody/utils/localized_text.dart';

AppLocalizations _l10n() => currentAppL10n;

class AIApiKeyService {
  AIApiKeyService({NetworkClient? client, FlutterSecureStorage? storage})
    : _client = client ?? NetworkClient.instance,
      _storage = storage ?? const FlutterSecureStorage();

  final NetworkClient _client;
  final FlutterSecureStorage _storage;

  Future<String?> loadApiKey() async {
    try {
      final storedKey = await _storage.read(
        key: SettingsService.geminiApiKeyStorageKey,
      );
      final normalizedStoredKey = storedKey?.trim();
      if (normalizedStoredKey != null && normalizedStoredKey.isNotEmpty) {
        return normalizedStoredKey;
      }
    } catch (_) {}

    return null;
  }

  Future<GeminiApiKeyTestResult> testConnection(String apiKey) async {
    final normalizedKey = apiKey.trim();
    if (normalizedKey.isEmpty) {
      return GeminiApiKeyTestResult(
        success: false,
        message: _l10n().pleaseEnterApiKey,
      );
    }

    try {
      final response = await _client.get(
        'https://generativelanguage.googleapis.com/v1beta/models',
        queryParameters: {'key': normalizedKey},
      );

      final models = _extractModels(response.data);
      return GeminiApiKeyTestResult(
        success: true,
        message: models.isEmpty
            ? _l10n().connectionSuccessVerificationPassed
            : _l10n().connectionSuccessDetectedModels(models.length),
        models: models,
      );
    } catch (e) {
      return GeminiApiKeyTestResult(
        success: false,
        message: _formatErrorMessage(e),
      );
    }
  }

  List<GeminiModelInfo> _extractModels(dynamic data) {
    if (data is! Map) return const [];
    final models = data['models'];
    if (models is! List) return const [];

    return models
        .map((item) {
          if (item is Map) {
            final rawName = item['name']?.toString().trim() ?? '';
            final modelId = rawName.isEmpty
                ? ''
                : rawName.contains('/')
                ? rawName.split('/').last.trim()
                : rawName;
            final displayName =
                item['displayName']?.toString().trim() ?? modelId;
            return GeminiModelInfo(id: modelId, displayName: displayName);
          }
          final fallbackId = item?.toString().trim() ?? '';
          return GeminiModelInfo(id: fallbackId, displayName: fallbackId);
        })
        .where((value) => value.id.isNotEmpty)
        .toList(growable: false);
  }

  String _formatErrorMessage(Object error) {
    if (error is DioException) {
      final response = error.response;
      final statusCode = response?.statusCode;
      final responseData = response?.data;

      if (responseData is Map) {
        final errorMap = responseData['error'];
        if (errorMap is Map) {
          final message = errorMap['message']?.toString().trim();
          if (message != null && message.isNotEmpty) {
            return statusCode == null
                ? message
                : _l10n().testFailedWithStatus(message, statusCode);
          }
        }
      }

      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) {
        return statusCode == null
            ? message
            : _l10n().testFailedWithStatus(message, statusCode);
      }

      return statusCode == null
          ? _l10n().testFailedCheckNetworkOrApiKey
          : _l10n().testFailedStatusCheckApiKey(statusCode);
    }

    return _l10n().testFailedCheckNetworkOrApiKey;
  }
}

class GeminiApiKeyTestResult {
  const GeminiApiKeyTestResult({
    required this.success,
    required this.message,
    this.models = const [],
  });

  final bool success;
  final String message;
  final List<GeminiModelInfo> models;
}

class GeminiModelInfo {
  const GeminiModelInfo({required this.id, required this.displayName});

  final String id;
  final String displayName;

  String get label => displayName.trim().isNotEmpty ? displayName : id;
}
