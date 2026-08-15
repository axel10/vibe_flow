import 'dart:ui';

import 'package:vynody/utils/localized_text.dart';

AppLocalizations _l10n() => currentAppL10n;

class LanguageCodeUtils {
  static const String fallbackLanguageCode = 'en';
  static const List<String> supportedTranslationLanguageCodes = <String>[
    'zh-cn',
    'zh-tw',
    'en',
    'ja',
    'ko',
    'fr',
    'de',
    'es',
    'pt',
    'ru',
    'tr',
  ];

  static String currentSystemLanguageCode() {
    final locale = PlatformDispatcher.instance.locale;
    final normalized = normalizeLanguageCode(_localeToRawCode(locale));
    return normalized.isEmpty ? fallbackLanguageCode : normalized;
  }

  static String currentAppLanguageCode() {
    final code = LocalizedText.overrideLanguageCode;
    final normalized = normalizeLanguageCode(
      (code != null && code != 'system' && code.isNotEmpty)
          ? code
          : _localeToRawCode(PlatformDispatcher.instance.locale),
    );
    return normalized.isEmpty ? fallbackLanguageCode : normalized;
  }

  static String normalizeLanguageCode(String? languageCode) {
    final text = languageCode?.trim().replaceAll('_', '-').toLowerCase() ?? '';
    if (text.isEmpty) return '';

    final parts = text.split('-').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '';

    final base = parts.first;
    if (base != 'zh') {
      return base;
    }

    final hasTraditionalMarker = parts.any(
      (part) => part == 'hant' || part == 'tw' || part == 'hk' || part == 'mo',
    );
    return hasTraditionalMarker ? 'zh-tw' : 'zh-cn';
  }

  static String languageDisplayName(String languageCode) {
    final normalized = normalizeLanguageCode(languageCode);

    switch (normalized) {
      case 'zh-cn':
        return _l10n().simplifiedChinese;
      case 'zh-tw':
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
        return normalized.isEmpty
            ? _l10n().systemLanguage
            : languageCode;
    }
  }

  static String _localeToRawCode(Locale locale) {
    final languageCode = locale.languageCode.trim();
    final scriptCode = locale.scriptCode?.trim();
    final countryCode = locale.countryCode?.trim();

    final parts = <String>[
      if (languageCode.isNotEmpty) languageCode,
      if (scriptCode != null && scriptCode.isNotEmpty) scriptCode,
      if (countryCode != null && countryCode.isNotEmpty) countryCode,
    ];
    return parts.join('-');
  }
}
