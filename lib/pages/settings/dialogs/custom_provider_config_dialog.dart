import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vynody/l10n/app_localizations.dart';

final class CustomProviderConfig {
  const CustomProviderConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.name,
  });

  final String baseUrl;
  final String apiKey;
  final String name;
}

Future<CustomProviderConfig?> showCustomProviderDialog(
  BuildContext context, {
  required String initialBaseUrl,
  required String initialApiKey,
  required String initialName,
}) async {
  return showDialog<CustomProviderConfig>(
    context: context,
    builder: (dialogContext) {
      return CustomProviderConfigDialog(
        initialBaseUrl: initialBaseUrl,
        initialApiKey: initialApiKey,
        initialName: initialName,
      );
    },
  );
}

class CustomProviderConfigDialog extends StatefulWidget {
  const CustomProviderConfigDialog({
    super.key,
    required this.initialBaseUrl,
    required this.initialApiKey,
    required this.initialName,
  });

  final String initialBaseUrl;
  final String initialApiKey;
  final String initialName;

  @override
  State<CustomProviderConfigDialog> createState() =>
      _CustomProviderConfigDialogState();
}

class _CustomProviderConfigDialogState
    extends State<CustomProviderConfigDialog> {
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _nameController;
  bool _isTesting = false;
  String _statusText = '';
  bool _statusSuccess = false;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(
      text: widget.initialBaseUrl,
    );
    _apiKeyController = TextEditingController(
      text: widget.initialApiKey,
    );
    _nameController = TextEditingController(
      text: widget.initialName,
    );
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (baseUrl.isEmpty || apiKey.isEmpty) {
      setState(() {
        _statusText = l10n.pleaseEnterApiKey;
        _statusSuccess = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _statusText = l10n.testingConnectionProgress;
      _statusSuccess = false;
    });

    try {
      final modelsUrl = baseUrl.endsWith('/')
          ? '${baseUrl}models'
          : '$baseUrl/models';
      final response = await Dio().get(
        modelsUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $apiKey',
        }),
      );
      if (response.data is Map) {
        final data = response.data as Map;
        final models = data['data'];
        if (models is List) {
          setState(() {
            _isTesting = false;
            _statusSuccess = true;
            _statusText = l10n.connectionSuccessDetectedModels(models.length);
          });
          return;
        }
      }
      setState(() {
        _isTesting = false;
        _statusSuccess = false;
        _statusText = l10n.unexpectedResponseFormat;
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _statusSuccess = false;
        _statusText = l10n.connectionTestException(e);
      });
    }
  }

  void _clearAndSave() {
    Navigator.of(context).pop(
      const CustomProviderConfig(baseUrl: '', apiKey: '', name: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.customApiProvider),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18,
                      color: Theme.of(context).hintColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.customProviderOnlyTranslation,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.providerLabel,
                hintText: 'My Provider',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _baseUrlController,
              decoration: InputDecoration(
                labelText: l10n.baseUrl,
                hintText: 'https://api.openai.com/v1',
                border: const OutlineInputBorder(),
                helperText: l10n.openaiCompatibleEndpoint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: l10n.apiKey,
                hintText: l10n.pleaseEnterApiKeyHint,
                border: const OutlineInputBorder(),
              ),
            ),
            if (_statusText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _statusSuccess
                        ? Icons.check_circle_outline_rounded
                        : Icons.error_outline_rounded,
                    size: 18,
                    color: _statusSuccess ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 13,
                        color: _statusSuccess ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isTesting
              ? null
              : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _isTesting ? null : _clearAndSave,
          child: Text(l10n.clear),
        ),
        TextButton(
          onPressed: _isTesting ? null : _testConnection,
          child: Text(_isTesting ? l10n.testingConnection : l10n.testConnection),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              CustomProviderConfig(
                baseUrl: _baseUrlController.text.trim(),
                apiKey: _apiKeyController.text.trim(),
                name: _nameController.text.trim(),
              ),
            );
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
