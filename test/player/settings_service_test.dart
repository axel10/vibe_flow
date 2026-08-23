import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/player/audio/equalizer_presets.dart';
import 'package:vynody/player/settings/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService - API Key Cleared Cleanup', () {
    late SettingsService settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'gemini_api_key': 'test-gemini-key',
        'openrouter_api_key': 'test-openrouter-key',
        'lyrics_generation_primary_provider': 'google_ai_studio',
        'lyrics_generation_primary_model_id': 'gemini-1.5-flash',
        'lyrics_generation_fallback_provider': 'openrouter',
        'lyrics_generation_fallback_model_id': 'google/gemini-2.5-flash',
      });
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
    });

    test('clearing geminiApiKey resets matching generationPrimaryModel to empty model ID and fallback provider', () {
      expect(settingsService.generationPrimaryModel.provider, LyricsAiProvider.googleAiStudio);
      expect(settingsService.generationPrimaryModel.modelId, 'gemini-1.5-flash');

      // Clear geminiApiKey
      settingsService.geminiApiKey = '';

      // The provider should fallback to the remaining valid provider (openRouter)
      // and model ID should be cleared to empty string.
      expect(settingsService.generationPrimaryModel.provider, LyricsAiProvider.openRouter);
      expect(settingsService.generationPrimaryModel.modelId, '');
    });

    test('clearing openRouterApiKey resets matching generationFallbackModel to empty model ID and fallback provider', () {
      expect(settingsService.generationFallbackModel.provider, LyricsAiProvider.openRouter);
      expect(settingsService.generationFallbackModel.modelId, 'google/gemini-2.5-flash');

      // Clear openRouterApiKey
      settingsService.openRouterApiKey = '';

      // Since the only remaining valid provider is googleAiStudio (gemini), it should fallback to googleAiStudio.
      expect(settingsService.generationFallbackModel.provider, LyricsAiProvider.googleAiStudio);
      expect(settingsService.generationFallbackModel.modelId, '');
    });
  });

  group('SettingsService - Auto Set Default Models on Adding API Keys', () {
    late SettingsService settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'lyrics_generation_primary_model_id': '',
        'lyrics_translation_primary_model_id': '',
      });
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
    });

    test('setting non-empty geminiApiKey sets missing primary models to gemini defaults', () {
      expect(settingsService.hasApiKeyForProvider(settingsService.generationPrimaryModel.provider), false);
      expect(settingsService.hasApiKeyForProvider(settingsService.translationPrimaryModel.provider), false);

      settingsService.geminiApiKey = 'new-gemini-key';

      expect(settingsService.generationPrimaryModel.provider, LyricsAiProvider.googleAiStudio);
      expect(settingsService.generationPrimaryModel.modelId, SettingsService.defaultGenerationPrimaryModelId);
      expect(settingsService.translationPrimaryModel.provider, LyricsAiProvider.googleAiStudio);
      expect(settingsService.translationPrimaryModel.modelId, SettingsService.defaultTranslationPrimaryModelId);
    });

    test('setting non-empty openRouterApiKey sets missing primary models to openrouter defaults', () {
      expect(settingsService.hasApiKeyForProvider(settingsService.generationPrimaryModel.provider), false);
      expect(settingsService.hasApiKeyForProvider(settingsService.translationPrimaryModel.provider), false);

      settingsService.openRouterApiKey = 'new-openrouter-key';

      expect(settingsService.generationPrimaryModel.provider, LyricsAiProvider.openRouter);
      expect(settingsService.generationPrimaryModel.modelId, SettingsService.defaultOpenRouterGenerationModelId);
      expect(settingsService.translationPrimaryModel.provider, LyricsAiProvider.openRouter);
      expect(settingsService.translationPrimaryModel.modelId, SettingsService.defaultOpenRouterTranslationModelId);
    });

    test('setting non-empty API key does not overwrite already set primary models', () {
      // Start with openRouter key
      settingsService.openRouterApiKey = 'new-openrouter-key';
      expect(settingsService.generationPrimaryModel.provider, LyricsAiProvider.openRouter);
      expect(settingsService.translationPrimaryModel.provider, LyricsAiProvider.openRouter);

      // Now set gemini API key. It should NOT overwrite the openRouter models since they are already set.
      settingsService.geminiApiKey = 'new-gemini-key';

      expect(settingsService.generationPrimaryModel.provider, LyricsAiProvider.openRouter);
      expect(settingsService.translationPrimaryModel.provider, LyricsAiProvider.openRouter);
    });
  });

  group('SettingsService - LAN sharing directory state', () {
    test('reports whether a receive directory has been selected', () async {
      SharedPreferences.setMockInitialValues({
        'lan_sharing_folder_path': '   ',
      });
      final prefs = await SharedPreferences.getInstance();
      final settingsService = SettingsService(prefs);

      expect(settingsService.lanSharingFolderPath, '   ');
      expect(settingsService.hasLanSharingFolderPath, isFalse);

      settingsService.lanSharingFolderPath = '/tmp/vynody-share';

      expect(settingsService.hasLanSharingFolderPath, isTrue);
    });
  });

  group('SettingsService - Regular Window Size Persistence', () {
    test('default value is 1280x720', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settingsService = SettingsService(prefs);

      expect(settingsService.savedRegularWindowSize.width, 1280.0);
      expect(settingsService.savedRegularWindowSize.height, 720.0);
    });

    test('saves and restores size with clamping', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settingsService = SettingsService(prefs);

      settingsService.savedRegularWindowSize = const Size(1024, 768);
      expect(settingsService.savedRegularWindowSize.width, 1024.0);
      expect(settingsService.savedRegularWindowSize.height, 768.0);

      // Verify clamping limits (minimum width 400, height 650)
      settingsService.savedRegularWindowSize = const Size(300, 500);
      expect(settingsService.savedRegularWindowSize.width, 400.0);
      expect(settingsService.savedRegularWindowSize.height, 650.0);
    });
  });

  group('SettingsService - Button Layout Settings', () {
    late SettingsService settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
    });

    test('default button layout settings are correctly initialized', () {
      expect(settingsService.topButtonsOrder, SettingsService.defaultTopButtonsOrder);
      expect(settingsService.mainControlsLeftButton, SettingsService.defaultMainControlsLeftButton);
      expect(settingsService.mainControlsRightButton, SettingsService.defaultMainControlsRightButton);
      expect(settingsService.lyricsHeaderRightButton, SettingsService.defaultLyricsHeaderRightButton);
    });

    test('updating and resetting button layout settings works as expected', () {
      final customOrder = ['equalizer', 'sleep_timer', 'tag_completion', 'shuffle', 'playlist_mode', 'favorite', 'more'];
      settingsService.topButtonsOrder = customOrder;
      settingsService.mainControlsLeftButton = 'equalizer';
      settingsService.mainControlsRightButton = 'shuffle';
      settingsService.lyricsHeaderRightButton = 'more';

      expect(settingsService.topButtonsOrder, customOrder);
      expect(settingsService.mainControlsLeftButton, 'equalizer');
      expect(settingsService.mainControlsRightButton, 'shuffle');
      expect(settingsService.lyricsHeaderRightButton, 'more');

      settingsService.resetPlaybackButtonsToDefault();

      expect(settingsService.topButtonsOrder, SettingsService.defaultTopButtonsOrder);
      expect(settingsService.mainControlsLeftButton, SettingsService.defaultMainControlsLeftButton);
      expect(settingsService.mainControlsRightButton, SettingsService.defaultMainControlsRightButton);
      expect(settingsService.lyricsHeaderRightButton, SettingsService.defaultLyricsHeaderRightButton);
    });
  });

  group('SettingsService - Immersive Tab Bar Default Setting', () {
    test('defaults to false on Android and iOS', () async {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        debugDefaultTargetPlatformOverride = platform;
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final settings = SettingsService(prefs);
        expect(settings.isImmersiveTabBarEnabled, isFalse,
            reason: 'Should default to false on $platform');
      }
      debugDefaultTargetPlatformOverride = null;
    });

    test('defaults to true on Desktop (macOS, Windows, Linux)', () async {
      for (final platform in [TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.linux]) {
        debugDefaultTargetPlatformOverride = platform;
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final settings = SettingsService(prefs);
        expect(settings.isImmersiveTabBarEnabled, isTrue,
            reason: 'Should default to true on $platform');
      }
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('SettingsService - Secure API Key Storage & Migration', () {
    test('migrates legacy SharedPreferences API keys to secure storage on init', () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({
        'gemini_api_key': 'legacy-gemini-key',
        'openrouter_api_key': 'legacy-openrouter-key',
      });

      final settings = await SettingsService.init();

      expect(settings.geminiApiKey, 'legacy-gemini-key');
      expect(settings.openRouterApiKey, 'legacy-openrouter-key');
      expect(settings.hasCustomGoogleAiStudioApiKey, isTrue);
      expect(settings.hasCustomOpenRouterApiKey, isTrue);

      // Verify that legacy keys are removed from SharedPreferences
      expect(settings.prefs.containsKey('gemini_api_key'), isFalse);
      expect(settings.prefs.containsKey('openrouter_api_key'), isFalse);

      // Verify secure storage contains the values
      const secureStorage = FlutterSecureStorage();
      expect(await secureStorage.read(key: 'gemini_api_key'), 'legacy-gemini-key');
      expect(await secureStorage.read(key: 'openrouter_api_key'), 'legacy-openrouter-key');
    });

    test('updating and clearing API keys updates secure storage', () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});

      final settings = await SettingsService.init();

      expect(settings.doubaoApiKey, '');
      expect(settings.hasCustomDoubaoApiKey, isFalse);

      settings.doubaoApiKey = 'new-doubao-key';
      expect(settings.doubaoApiKey, 'new-doubao-key');
      expect(settings.hasCustomDoubaoApiKey, isTrue);

      const secureStorage = FlutterSecureStorage();
      expect(await secureStorage.read(key: 'doubao_api_key'), 'new-doubao-key');

      settings.doubaoApiKey = '';
      expect(settings.doubaoApiKey, '');
      expect(settings.hasCustomDoubaoApiKey, isFalse);
      expect(await secureStorage.read(key: 'doubao_api_key'), isNull);
    });

    test('openPlaybackOnDirectorySongTap defaults to false', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsService(prefs);
      expect(settings.openPlaybackOnDirectorySongTap, isFalse);
    });

    test('themeColor defaults to defaultAppThemeColor and updates correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsService(prefs);

      expect(settings.themeColor, SettingsService.defaultAppThemeColor);

      var notified = false;
      settings.addListener(() {
        notified = true;
      });

      const newColor = Color(0xFF2196F3);
      settings.themeColor = newColor;
      expect(settings.themeColor, newColor);
      expect(notified, isTrue);

      // Verify loaded from stored preferences
      final restoredSettings = SettingsService(prefs);
      expect(restoredSettings.themeColor, newColor);
    });

    test('customEqPresets persists, saves, and deletes correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsService(prefs);

      expect(settings.customEqPresets, isEmpty);

      final preset1 = EqualizerPresets.createCustomPreset(
        name: 'Preset 1',
        currentGains: [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0],
        targetFreqs: EqualizerPresets.standard10Frequencies,
        bassBoost: 20,
        preamp: 2.5,
      );

      final preset2 = EqualizerPresets.createCustomPreset(
        name: 'Preset 2',
        currentGains: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        targetFreqs: EqualizerPresets.standard10Frequencies,
      );

      settings.saveCustomEqPreset(preset1);
      settings.saveCustomEqPreset(preset2);

      expect(settings.customEqPresets.length, 2);
      expect(settings.customEqPresets.first.customName, 'Preset 2');
      expect(settings.customEqPresets.last.customName, 'Preset 1');

      // Verify restored from prefs
      final restoredSettings = SettingsService(prefs);
      expect(restoredSettings.customEqPresets.length, 2);
      expect(restoredSettings.customEqPresets.last.bassBoost, 20);
      expect(restoredSettings.customEqPresets.last.preamp, 2.5);

      // Delete preset
      restoredSettings.deleteCustomEqPreset(preset1.id);
      expect(restoredSettings.customEqPresets.length, 1);
      expect(restoredSettings.customEqPresets.first.id, preset2.id);
    });

    test('equalizer state (enabled, gains, preamp, bassBoost) persists correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsService(prefs);

      // Default values
      expect(settings.equalizerEnabled, isFalse);
      expect(settings.equalizerGains, isEmpty);
      expect(settings.equalizerPreamp, 0.0);
      expect(settings.equalizerBassBoost, 0.0);

      // Modify values
      settings.equalizerEnabled = true;
      settings.equalizerGains = [1.5, -2.0, 3.2, 0.0, 4.0];
      settings.equalizerPreamp = -3.0;
      settings.equalizerBassBoost = 5.0;

      expect(settings.equalizerEnabled, isTrue);
      expect(settings.equalizerGains, [1.5, -2.0, 3.2, 0.0, 4.0]);
      expect(settings.equalizerPreamp, -3.0);
      expect(settings.equalizerBassBoost, 5.0);

      // Verify restored from prefs
      final restoredSettings = SettingsService(prefs);
      expect(restoredSettings.equalizerEnabled, isTrue);
      expect(restoredSettings.equalizerGains, [1.5, -2.0, 3.2, 0.0, 4.0]);
      expect(restoredSettings.equalizerPreamp, -3.0);
      expect(restoredSettings.equalizerBassBoost, 5.0);
    });
  });
}
