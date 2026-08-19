import 'dart:async';
import 'dart:convert';
import 'package:audio_core/audio_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vynody/player/settings/shortcut_bindings.dart';
import 'package:vynody/transcode/transcode_models.dart';
import 'package:vynody/utils/language_code_utils.dart';

import 'package:vynody/utils/localized_text.dart';

AppLocalizations _l10n() => currentAppL10n;

enum LyricsAiProvider { googleAiStudio, openRouter, doubao, deepseek, custom }

enum LyricsAiModelPurpose { generation, translation }

enum LyricsAiModelSlot { primary, fallback }

enum LyricsSaveMethod { original, embedded, lrcFile }

enum VisualizerStyle {
  bars,
  smoothWave,
  floatingBars,
  radial,
  matrix,
  mirroredWave,
}

extension VisualizerStyleX on VisualizerStyle {
  String get storageValue => name;
  static VisualizerStyle fromStorageValue(
    String? value,
    VisualizerStyle defaultValue,
  ) {
    if (value == null) return defaultValue;
    return VisualizerStyle.values.firstWhere(
      (e) => e.name == value,
      orElse: () => defaultValue,
    );
  }

  double get defaultOpacity => switch (this) {
    VisualizerStyle.bars => 0.20,
    VisualizerStyle.smoothWave => 0.06,
    VisualizerStyle.floatingBars => 0.20,
    VisualizerStyle.radial => 0.20,
    VisualizerStyle.matrix => 0.25,
    VisualizerStyle.mirroredWave => 0.06,
  };

  String get defaultAutoSpeed => switch (this) {
    VisualizerStyle.radial => 'fast',
    _ => 'medium',
  };
}

enum LyricsStyle { traditional, apple }

final class LyricsAiModelSelection {
  const LyricsAiModelSelection({required this.provider, required this.modelId});

  final LyricsAiProvider provider;
  final String modelId;

  bool get isEmpty => modelId.trim().isEmpty;

  LyricsAiModelSelection copyWith({
    LyricsAiProvider? provider,
    String? modelId,
  }) {
    return LyricsAiModelSelection(
      provider: provider ?? this.provider,
      modelId: modelId ?? this.modelId,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LyricsAiModelSelection &&
            other.provider == provider &&
            other.modelId == modelId;
  }

  @override
  int get hashCode => Object.hash(provider, modelId);
}

enum SmallWindowBottomPanelMode { collapsed, queue, lyrics }

enum CloseWindowAction { ask, minimize, exit }

extension CloseWindowActionX on CloseWindowAction {
  String get storageValue => name;
  static CloseWindowAction fromStorageValue(String? value) {
    if (value == 'minimize') return CloseWindowAction.minimize;
    if (value == 'exit') return CloseWindowAction.exit;
    return CloseWindowAction.ask;
  }
}

enum FolderViewMode { list, hybrid, grid }

extension FolderViewModeX on FolderViewMode {
  String get storageValue => switch (this) {
    FolderViewMode.list => 'list',
    FolderViewMode.hybrid => 'grid',
    FolderViewMode.grid => 'grid_all',
  };

  static FolderViewMode fromStorageValue(
    String? value,
    FolderViewMode defaultValue,
  ) {
    switch (value?.trim().toLowerCase()) {
      case 'grid':
        return FolderViewMode.hybrid;
      case 'grid_all':
        return FolderViewMode.grid;
      case 'list':
        return FolderViewMode.list;
      default:
        return defaultValue;
    }
  }
}

extension ThemeModeX on ThemeMode {
  String get storageValue => switch (this) {
    ThemeMode.system => 'system',
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
  };

  static ThemeMode fromStorageValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

extension LyricsAiProviderX on LyricsAiProvider {
  String get storageValue => switch (this) {
    LyricsAiProvider.googleAiStudio => 'google_ai_studio',
    LyricsAiProvider.openRouter => 'openrouter',
    LyricsAiProvider.doubao => 'doubao',
    LyricsAiProvider.deepseek => 'deepseek',
    LyricsAiProvider.custom => 'custom',
  };

  String get displayName {
    if (this == LyricsAiProvider.custom) {
      return SettingsService._lastKnownCustomProviderName.trim().isEmpty
          ? _l10n().custom
          : SettingsService._lastKnownCustomProviderName.trim();
    }
    return switch (this) {
      LyricsAiProvider.googleAiStudio => 'Google AI Studio',
      LyricsAiProvider.openRouter => 'OpenRouter',
      LyricsAiProvider.doubao => _l10n().doubao,
      LyricsAiProvider.deepseek => 'DeepSeek',
      LyricsAiProvider.custom => '',
    };
  }

  static LyricsAiProvider fromStorageValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'openrouter':
        return LyricsAiProvider.openRouter;
      case 'doubao':
        return LyricsAiProvider.doubao;
      case 'deepseek':
        return LyricsAiProvider.deepseek;
      case 'custom':
        return LyricsAiProvider.custom;
      case 'google_ai_studio':
      case 'google':
      case 'gemini':
      default:
        return LyricsAiProvider.googleAiStudio;
    }
  }
}

class SettingProperty<T> {
  final String key;
  final T defaultValue;
  final SharedPreferences prefs;
  final VoidCallback? onChanged;
  final T Function(SharedPreferences prefs, String key, T defaultValue)?
  customRead;
  final void Function(SharedPreferences prefs, String key, T value)?
  customWrite;

  T _value;

  SettingProperty({
    required this.key,
    required this.defaultValue,
    required this.prefs,
    this.onChanged,
    this.customRead,
    this.customWrite,
  }) : _value = _read(prefs, key, defaultValue, customRead);

  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    _write(prefs, key, newValue, customWrite);
    onChanged?.call();
  }

  static T _read<T>(
    SharedPreferences prefs,
    String key,
    T defaultValue,
    T Function(SharedPreferences prefs, String key, T defaultValue)? customRead,
  ) {
    if (customRead != null) {
      return customRead(prefs, key, defaultValue);
    }
    if (T == bool) {
      return (prefs.getBool(key) ?? defaultValue) as T;
    }
    if (T == int) {
      return (prefs.getInt(key) ?? defaultValue) as T;
    }
    if (T == double) {
      return (prefs.getDouble(key) ?? defaultValue) as T;
    }
    if (T == String) {
      return (prefs.getString(key) ?? defaultValue) as T;
    }
    return defaultValue;
  }

  static void _write<T>(
    SharedPreferences prefs,
    String key,
    T value,
    void Function(SharedPreferences prefs, String key, T value)? customWrite,
  ) {
    if (customWrite != null) {
      customWrite(prefs, key, value);
      return;
    }
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    }
  }

  void reset() {
    value = defaultValue;
  }
}

class SettingsService extends ChangeNotifier {
  static const String defaultGenerationPrimaryModelId =
      'gemini-flash-lite-latest';
  static const String defaultGenerationFallbackModelId = '';
  static const String defaultTranslationPrimaryModelId = 'gemma-4-31b-it';
  static const String defaultTranslationFallbackModelId = '';
  static const String defaultOpenRouterGenerationModelId =
      'google/gemini-3.1-flash-lite';
  static const String defaultOpenRouterTranslationModelId =
      'google/gemini-3.1-flash-lite';
  static const String defaultDoubaoGenerationModelId =
      'doubao-seed-2-0-lite-260428';
  static const String defaultDoubaoTranslationModelId =
      'doubao-seed-2-0-lite-260428';
  static const String defaultDeepSeekTranslationModelId = 'deepseek-v4-flash';
  static const Color defaultAppThemeColor = Color(0xFF39C5BB);
  static const String _keyThemeColor = 'custom_theme_color';
  static const List<Color> presetThemeColors = [
    Color(0xFF39C5BB), // 初音绿 (Default Miku Teal)
    Color(0xFF2196F3), // 经典蓝 (Classic Blue)
    Color(0xFF6750A4), // 鸢尾紫 (Material Deep Purple)
    Color(0xFF7E57C2), // 罗兰紫 (Violet)
    Color(0xFFEC407A), // 樱花粉 (Sakura Pink)
    Color(0xFFFF7043), // 珊瑚橙 (Coral Orange)
    Color(0xFFFFA000), // 琥珀黄 (Amber Gold)
    Color(0xFF4CAF50), // 森林绿 (Forest Green)
    Color(0xFF00ACC1), // 极光青 (Cyan)
    Color(0xFFE53935), // 热情红 (Crimson Red)
    Color(0xFF607D8B), // 典雅灰 (Slate Grey)
  ];
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLocale = 'app_locale';
  static const String _keyEnableFadeEffect = 'enable_fade_effect';
  static const String _keyWindowsAutoRepairShortcut =
      'windows_auto_repair_shortcut';
  static const String _keyEnableSystemTray = 'enable_system_tray';
  static const String _keyCloseToTray = 'close_to_tray';
  static const String _keyCloseWindowAction = 'close_window_action';
  static const String _keyImmersiveTabBar = 'immersive_tab_bar_enabled';
  static const List<String> defaultTopButtonsOrder = [
    'more',
    'favorite',
    'playlist_mode',
    'shuffle',
    'tag_completion',
    'sleep_timer',
    'equalizer',
  ];
  static const String defaultMainControlsLeftButton = 'visualizer';
  static const String defaultMainControlsRightButton = 'volume';
  static const String defaultLyricsHeaderRightButton = 'favorite';

  static const String _keyTopButtonsOrder = 'top_buttons_order';
  static const String _keyMainControlsLeftButton = 'main_controls_left_button';
  static const String _keyMainControlsRightButton =
      'main_controls_right_button';
  static const String _keyLyricsHeaderRightButton =
      'lyrics_header_right_button';

  static const String _keyCollapseButtonsInLandscapeLyrics =
      'collapse_buttons_in_landscape_lyrics';
  static const String _keyShowScanProgressToast = 'show_scan_progress_toast';
  static const String _keyOpenPlaybackOnDirectorySongTap =
      'open_playback_on_directory_song_tap';
  static const String _keyDefaultToLyricsModeOnPlaybackOpen =
      'default_to_lyrics_mode_on_playback_open';
  static const String _keySampleStride = 'sample_stride';
  static const String _keyWaveformChunks = 'waveform_chunks';
  static const String geminiApiKeyStorageKey = 'gemini_api_key';
  static const String openRouterApiKeyStorageKey = 'openrouter_api_key';
  static const String doubaoApiKeyStorageKey = 'doubao_api_key';
  static const String deepseekApiKeyStorageKey = 'deepseek_api_key';
  static const String customProviderApiKeyStorageKey =
      'custom_provider_api_key';
  static const List<String> _apiKeyStorageKeys = [
    geminiApiKeyStorageKey,
    openRouterApiKeyStorageKey,
    doubaoApiKeyStorageKey,
    deepseekApiKeyStorageKey,
    customProviderApiKeyStorageKey,
  ];
  static const String customProviderBaseUrlStorageKey =
      'custom_provider_base_url';
  static const String customProviderNameStorageKey = 'custom_provider_name';
  static String _lastKnownCustomProviderName = '';
  static const String _keyLyricsTranslationTargetLanguage =
      'lyrics_translation_target_language';
  static const String _keyLyricsSaveMethod = 'lyrics_save_method';
  static const String _keyLyricsStyle = 'lyrics_style';
  static const String _keyLyricsFontScale = 'lyrics_font_scale';
  static const String _keyLyricsFontScaleTraditional =
      'lyrics_font_scale_traditional';
  static const String _keyLyricsFontScaleApple = 'lyrics_font_scale_apple';
  static const String _keyGenerationPrimaryProvider =
      'lyrics_generation_primary_provider';
  static const String _keyGenerationPrimaryModelId =
      'lyrics_generation_primary_model_id';
  static const String _keyGenerationFallbackProvider =
      'lyrics_generation_fallback_provider';
  static const String _keyGenerationFallbackModelId =
      'lyrics_generation_fallback_model_id';
  static const String _keyTranslationPrimaryProvider =
      'lyrics_translation_primary_provider';
  static const String _keyTranslationPrimaryModelId =
      'lyrics_translation_primary_model_id';
  static const String _keyTranslationFallbackProvider =
      'lyrics_translation_fallback_provider';
  static const String _keyTranslationFallbackModelId =
      'lyrics_translation_fallback_model_id';
  static const String _legacyKeyLyricsAiProvider = 'lyrics_ai_provider';
  static const String _legacyKeyGeminiPrimaryModelId =
      'gemini_primary_model_id';
  static const String _legacyKeyGeminiFallbackModelId =
      'gemini_fallback_model_id';
  static const String _legacyKeyGeminiTranslationModelId =
      'gemini_translation_model_id';
  static const String acoustidApiKeyStorageKey = 'acoustid_api_key';
  static const String _keyShortcutBindings = 'shortcut_bindings';
  static const String _builtInAcoustidApiKey = 'raGXgwxqws';
  static const int defaultSampleStride = 1;
  static const double defaultLyricsFontScale = 1.0;
  static const double minLyricsFontScale = 0.5;
  static const double maxLyricsFontScale = 1.5;
  static const double lyricsFontScaleStep = 0.1;

  static const double defaultPlaybackBackgroundNormalOpacity = 0.20;
  static const double defaultPlaybackBackgroundLyricsOpacity = 0.30;
  static const double defaultPlaybackBlurredArtworkBlurSigma = 30.0;
  static const double defaultPlaybackCustomImageBlurSigma = 0.0;

  // Visualizer styling keys
  static const String _keyVisualizerStyle = 'visualizer_style';
  static const String _keyVisColor = 'visualizer_color';
  static const String _keyVisOpacity = 'visualizer_opacity';
  static const String _keyVisCapDropSpeed = 'visualizer_cap_drop_speed';
  static const String _keyVisGradient = 'visualizer_gradient_enabled';
  static const String _keyVisStartColor = 'visualizer_start_color';
  static const String _keyVisEndColor = 'visualizer_end_color';
  static const String _keyVisGradientStop1 = 'visualizer_gradient_stop_1';
  static const String _keyVisGradientStop2 = 'visualizer_gradient_stop_2';
  static const String _keyVisGradientTileMode = 'visualizer_gradient_tile_mode';
  static const String _keyVisualizerDynamicColor = 'visualizer_dynamic_color';
  static const String _keyVisualizerDynamicStartColor =
      'visualizer_dynamic_start_color';
  static const String _keyVisualizerDynamicEndColor =
      'visualizer_dynamic_end_color';
  static const String _keyPlaybackBackgroundType = 'playback_background_type';
  static const String _keyPlaybackRadialGradientEnabled =
      'playback_radial_gradient_enabled';
  static const String _keyPlaybackBackgroundColor = 'playback_background_color';
  static const String _keyPlaybackBackgroundCustomImagePath =
      'playback_background_custom_image_path';
  static const String _keyPlaybackBackgroundNormalOpacity =
      'playback_background_normal_opacity';
  static const String _keyPlaybackBackgroundLyricsOpacity =
      'playback_background_lyrics_opacity';
  static const String _keyPlaybackBlurredArtworkBlurSigma =
      'playback_blurred_artwork_blur_sigma';
  static const String _keyPlaybackCustomImageBlurSigma =
      'playback_custom_image_blur_sigma';
  static const String _keyPlaybackMeshBackgroundSpeed =
      'playback_mesh_background_speed';
  static const String _keyPortraitFrequencyGroups =
      'visualizer_portrait_frequency_groups';
  static const String _keyLandscapeFrequencyGroups =
      'visualizer_landscape_frequency_groups';
  static const String _keyPortraitGap = 'visualizer_portrait_gap';
  static const String _keyLandscapeGap = 'visualizer_landscape_gap';
  static const String _keyIsWaveformProgressBarEnabled =
      'waveform_progress_bar_enabled';
  static const String _keyWaveformLongPressSeekSpeed =
      'waveform_long_press_seek_speed';
  static const String _keyEnableWaveformLongPressSeek =
      'enable_waveform_long_press_seek';
  static const double defaultWaveformLongPressSeekSpeed = 2.0;
  static const double minWaveformLongPressSeekSpeed = 1.1;
  static const double maxWaveformLongPressSeekSpeed = 5.0;
  static const String _keyPlaybackSpeedLimit5x = 'playback_speed_limit_5x';
  static const String _keyEqualizerBandCount = 'equalizer_band_count';
  static const String _keyShowDeveloperOptions = 'show_developer_options';
  static const String skipShortAudioScanEnabledStorageKey =
      'scan_skip_short_audio_enabled';
  static const String skipShortAudioScanMinimumDurationSecondsStorageKey =
      'scan_skip_short_audio_min_duration_seconds';
  static const int defaultSkipShortAudioScanMinimumDurationSeconds = 30;
  static const String _keyRandomRange = 'random_range';
  static const String _keyRandomMethod = 'random_method';
  static const String _keyTranscodeDefaultFormat =
      'transcode_default_output_format';
  static const String _keyTranscodeDefaultQualityTier =
      'transcode_default_quality_tier';

  static const String _keyRegularWindowWidth = 'regular_window_width';
  static const String _keyRegularWindowHeight = 'regular_window_height';
  static const String _keySmallWindowWidth = 'small_window_width';
  static const String _keySmallWindowHeight = 'small_window_height';
  static const String _keySmallWindowBottomPanelMode =
      'small_window_bottom_panel_mode';
  static const String _keySmallWindowAlwaysOnTop = 'small_window_always_on_top';
  static const String _keySmallWindowQueueWidth = 'small_window_queue_width';
  static const String _keySmallWindowQueueHeight = 'small_window_queue_height';
  static const String _keyHasShownOnboarding = 'has_shown_onboarding';
  static const String _keyHasShownCoverTapLyricTip =
      'has_shown_cover_tap_lyric_tip';
  static const String _keyHasShownLyricsMenuTip = 'has_shown_lyrics_menu_tip';
  static const String _keyTagCompletionSaveToSourceFile =
      'tag_completion_save_to_source_file';
  static const String _keyLanSharingEnabled = 'lan_sharing_enabled';
  static const String _keyLanSharingFolderPath = 'lan_sharing_folder_path';
  static const String _keyAllowRemoteControl = 'allow_remote_control';
  static const String _keyFolderViewMode = 'folder_view_mode';
  static const String _keyUiScale = 'ui_scale';
  static const double defaultUiScale = 1.0;
  static const double minUiScale = 0.8;
  static const double maxUiScale = 1.5;

  final SharedPreferences _prefs;
  bool _isUserInactive = false;
  Timer? _inactivityTimer;
  Map<String, ShortcutBinding> _shortcutBindings;

  // SettingProperty definitions for all configuration options
  late final _regularWindowWidthProperty = SettingProperty<double>(
    key: _keyRegularWindowWidth,
    defaultValue: 1280.0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _regularWindowHeightProperty = SettingProperty<double>(
    key: _keyRegularWindowHeight,
    defaultValue: 720.0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _hasShownOnboardingProperty = SettingProperty<bool>(
    key: _keyHasShownOnboarding,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _hasShownCoverTapLyricTipProperty = SettingProperty<bool>(
    key: _keyHasShownCoverTapLyricTip,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _hasShownLyricsMenuTipProperty = SettingProperty<bool>(
    key: _keyHasShownLyricsMenuTip,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _tagCompletionSaveToSourceFileProperty = SettingProperty<bool>(
    key: _keyTagCompletionSaveToSourceFile,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _lanSharingEnabledProperty = SettingProperty<bool>(
    key: _keyLanSharingEnabled,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _lanSharingFolderPathProperty = SettingProperty<String>(
    key: _keyLanSharingFolderPath,
    defaultValue: '',
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _allowRemoteControlProperty = SettingProperty<bool>(
    key: _keyAllowRemoteControl,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _folderViewModeProperty = SettingProperty<FolderViewMode>(
    key: _keyFolderViewMode,
    defaultValue: FolderViewMode.grid,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) =>
        FolderViewModeX.fromStorageValue(prefs.getString(key), def),
    customWrite: (prefs, key, val) => prefs.setString(key, val.storageValue),
  );

  late final _uiScaleProperty = SettingProperty<double>(
    key: _keyUiScale,
    defaultValue: defaultUiScale,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) =>
        (prefs.getDouble(key) ?? def).clamp(minUiScale, maxUiScale),
    customWrite: (prefs, key, val) =>
        prefs.setDouble(key, val.clamp(minUiScale, maxUiScale)),
  );

  late final _themeModeProperty = SettingProperty<ThemeMode>(
    key: _keyThemeMode,
    defaultValue: ThemeMode.system,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) =>
        ThemeModeX.fromStorageValue(prefs.getString(key)),
    customWrite: (prefs, key, val) => prefs.setString(key, val.storageValue),
  );

  late final _themeColorProperty = SettingProperty<Color>(
    key: _keyThemeColor,
    defaultValue: defaultAppThemeColor,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) =>
        Color(prefs.getInt(key) ?? def.toARGB32()),
    customWrite: (prefs, key, val) => prefs.setInt(key, val.toARGB32()),
  );

  late final SettingProperty<String> _localeProperty = SettingProperty<String>(
    key: _keyLocale,
    defaultValue: 'system',
    prefs: _prefs,
    onChanged: () {
      LocalizedText.overrideLanguageCode = _localeProperty.value;
      notifyListeners();
    },
  );

  late final _isImmersiveTabBarEnabledProperty = SettingProperty<bool>(
    key: _keyImmersiveTabBar,
    defaultValue:
        !(defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS),
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _collapseButtonsInLandscapeLyricsProperty = SettingProperty<bool>(
    key: _keyCollapseButtonsInLandscapeLyrics,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _topButtonsOrderProperty = SettingProperty<List<String>>(
    key: _keyTopButtonsOrder,
    defaultValue: defaultTopButtonsOrder,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) {
      final raw = prefs.getString(key);
      if (raw == null || raw.trim().isEmpty) return def;
      try {
        final List<dynamic> list = jsonDecode(raw);
        final result = list.map((e) => e.toString()).toList();
        if (result.length == 7) return result;
      } catch (e) {
        debugPrint('Failed to parse top_buttons_order: $e');
      }
      return def;
    },
    customWrite: (prefs, key, value) {
      prefs.setString(key, jsonEncode(value));
    },
  );

  late final _mainControlsLeftButtonProperty = SettingProperty<String>(
    key: _keyMainControlsLeftButton,
    defaultValue: defaultMainControlsLeftButton,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _mainControlsRightButtonProperty = SettingProperty<String>(
    key: _keyMainControlsRightButton,
    defaultValue: defaultMainControlsRightButton,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _lyricsHeaderRightButtonProperty = SettingProperty<String>(
    key: _keyLyricsHeaderRightButton,
    defaultValue: defaultLyricsHeaderRightButton,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _showScanProgressToastProperty = SettingProperty<bool>(
    key: _keyShowScanProgressToast,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _openPlaybackOnDirectorySongTapProperty = SettingProperty<bool>(
    key: _keyOpenPlaybackOnDirectorySongTap,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _defaultToLyricsModeOnPlaybackOpenProperty = SettingProperty<bool>(
    key: _keyDefaultToLyricsModeOnPlaybackOpen,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _windowsAutoRepairShortcutProperty = SettingProperty<bool>(
    key: _keyWindowsAutoRepairShortcut,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _enableSystemTrayProperty = SettingProperty<bool>(
    key: _keyEnableSystemTray,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _closeToTrayProperty = SettingProperty<bool>(
    key: _keyCloseToTray,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _closeWindowActionProperty = SettingProperty<CloseWindowAction>(
    key: _keyCloseWindowAction,
    defaultValue: CloseWindowAction.ask,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) {
      final val = prefs.getString(key);
      if (val != null) {
        return CloseWindowActionX.fromStorageValue(val);
      }
      if (prefs.containsKey(_keyCloseToTray)) {
        final legacyCloseToTray = prefs.getBool(_keyCloseToTray);
        if (legacyCloseToTray == false) {
          return CloseWindowAction.exit;
        }
      }
      return def;
    },
    customWrite: (prefs, key, val) => prefs.setString(key, val.storageValue),
  );

  late final _waveformChunksProperty = SettingProperty<int>(
    key: _keyWaveformChunks,
    defaultValue: 120,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _sampleStrideProperty = SettingProperty<int>(
    key: _keySampleStride,
    defaultValue: defaultSampleStride,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _lyricsTranslationTargetLanguageProperty = SettingProperty<String>(
    key: _keyLyricsTranslationTargetLanguage,
    defaultValue: '',
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) {
      final value = LanguageCodeUtils.normalizeLanguageCode(
        prefs.getString(key),
      );
      return value.isEmpty ? def : value;
    },
    customWrite: (prefs, key, val) {
      final normalized = LanguageCodeUtils.normalizeLanguageCode(val);
      if (normalized.isEmpty) {
        prefs.remove(key);
      } else {
        prefs.setString(key, normalized);
      }
    },
  );

  late final _lyricsSaveMethodProperty = SettingProperty<String>(
    key: _keyLyricsSaveMethod,
    defaultValue: LyricsSaveMethod.original.name,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _lyricsStyleProperty = SettingProperty<String>(
    key: _keyLyricsStyle,
    defaultValue: LyricsStyle.apple.name,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _lyricsFontScaleTraditionalProperty = SettingProperty<double>(
    key: _keyLyricsFontScaleTraditional,
    defaultValue: defaultLyricsFontScale,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) {
      if (!prefs.containsKey(key) && prefs.containsKey(_keyLyricsFontScale)) {
        return _normalizeLyricsFontScale(
          prefs.getDouble(_keyLyricsFontScale) ?? def,
        );
      }
      return _normalizeLyricsFontScale(prefs.getDouble(key) ?? def);
    },
    customWrite: (prefs, key, val) =>
        prefs.setDouble(key, _normalizeLyricsFontScale(val)),
  );

  late final _lyricsFontScaleAppleProperty = SettingProperty<double>(
    key: _keyLyricsFontScaleApple,
    defaultValue: defaultLyricsFontScale,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) {
      if (!prefs.containsKey(key) && prefs.containsKey(_keyLyricsFontScale)) {
        return _normalizeLyricsFontScale(
          prefs.getDouble(_keyLyricsFontScale) ?? def,
        );
      }
      return _normalizeLyricsFontScale(prefs.getDouble(key) ?? def);
    },
    customWrite: (prefs, key, val) =>
        prefs.setDouble(key, _normalizeLyricsFontScale(val)),
  );

  late final _generationPrimaryProviderProperty =
      SettingProperty<LyricsAiProvider>(
        key: _keyGenerationPrimaryProvider,
        defaultValue: LyricsAiProvider.googleAiStudio,
        prefs: _prefs,
        onChanged: notifyListeners,
        customRead: (prefs, key, def) => _initialLyricsProvider(
          prefs,
          key: key,
          legacyKey: _legacyKeyLyricsAiProvider,
          defaultValue: def,
        ),
        customWrite: (prefs, key, val) =>
            prefs.setString(key, val.storageValue),
      );

  late final _generationPrimaryModelIdProperty = SettingProperty<String>(
    key: _keyGenerationPrimaryModelId,
    defaultValue: defaultGenerationPrimaryModelId,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => _initialModelId(
      prefs,
      key: key,
      legacyKey: _legacyKeyGeminiPrimaryModelId,
      defaultValue: def,
    ),
  );

  late final _generationFallbackProviderProperty =
      SettingProperty<LyricsAiProvider>(
        key: _keyGenerationFallbackProvider,
        defaultValue: LyricsAiProvider.googleAiStudio,
        prefs: _prefs,
        onChanged: notifyListeners,
        customRead: (prefs, key, def) => _initialLyricsProvider(
          prefs,
          key: key,
          legacyKey: _legacyKeyLyricsAiProvider,
          defaultValue: def,
        ),
        customWrite: (prefs, key, val) =>
            prefs.setString(key, val.storageValue),
      );

  late final _generationFallbackModelIdProperty = SettingProperty<String>(
    key: _keyGenerationFallbackModelId,
    defaultValue: defaultGenerationFallbackModelId,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => _initialModelId(
      prefs,
      key: key,
      legacyKey: _legacyKeyGeminiFallbackModelId,
      defaultValue: def,
    ),
  );

  late final _translationPrimaryProviderProperty =
      SettingProperty<LyricsAiProvider>(
        key: _keyTranslationPrimaryProvider,
        defaultValue: LyricsAiProvider.googleAiStudio,
        prefs: _prefs,
        onChanged: notifyListeners,
        customRead: (prefs, key, def) => _initialLyricsProvider(
          prefs,
          key: key,
          legacyKey: _legacyKeyLyricsAiProvider,
          defaultValue: def,
        ),
        customWrite: (prefs, key, val) =>
            prefs.setString(key, val.storageValue),
      );

  late final _translationPrimaryModelIdProperty = SettingProperty<String>(
    key: _keyTranslationPrimaryModelId,
    defaultValue: defaultTranslationPrimaryModelId,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => _initialModelId(
      prefs,
      key: key,
      legacyKey: _legacyKeyGeminiTranslationModelId,
      defaultValue: def,
    ),
  );

  late final _translationFallbackProviderProperty =
      SettingProperty<LyricsAiProvider>(
        key: _keyTranslationFallbackProvider,
        defaultValue: LyricsAiProvider.googleAiStudio,
        prefs: _prefs,
        onChanged: notifyListeners,
        customRead: (prefs, key, def) => _initialLyricsProvider(
          prefs,
          key: key,
          legacyKey: _legacyKeyLyricsAiProvider,
          defaultValue: def,
        ),
        customWrite: (prefs, key, val) =>
            prefs.setString(key, val.storageValue),
      );

  late final _translationFallbackModelIdProperty = SettingProperty<String>(
    key: _keyTranslationFallbackModelId,
    defaultValue: defaultTranslationFallbackModelId,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => _initialModelId(
      prefs,
      key: key,
      legacyKey: _legacyKeyGeminiTranslationModelId,
      defaultValue: def,
      emptyUsesDefault: false,
    ),
  );

  late final _geminiApiKeyProperty = SettingProperty<String>(
    key: geminiApiKeyStorageKey,
    defaultValue: '',
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => _readSecureApiKey(prefs, key, def),
    customWrite: _writeSecureApiKey,
  );

  late final _openRouterApiKeyProperty = SettingProperty<String>(
    key: openRouterApiKeyStorageKey,
    defaultValue: '',
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => _readSecureApiKey(prefs, key, def),
    customWrite: _writeSecureApiKey,
  );

  late final _doubaoApiKeyProperty = SettingProperty<String>(
    key: doubaoApiKeyStorageKey,
    defaultValue: '',
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => _readSecureApiKey(prefs, key, def),
    customWrite: _writeSecureApiKey,
  );

  late final _deepseekApiKeyProperty = SettingProperty<String>(
    key: deepseekApiKeyStorageKey,
    defaultValue: '',
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => _readSecureApiKey(prefs, key, def),
    customWrite: _writeSecureApiKey,
  );

  late final _customProviderApiKeyProperty = SettingProperty<String>(
    key: customProviderApiKeyStorageKey,
    defaultValue: '',
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => _readSecureApiKey(prefs, key, def),
    customWrite: _writeSecureApiKey,
  );

  late final _customProviderBaseUrlProperty = SettingProperty<String>(
    key: customProviderBaseUrlStorageKey,
    defaultValue: '',
    prefs: _prefs,
    onChanged: notifyListeners,
    customWrite: (prefs, key, val) {
      final normalized = val.trim();
      if (normalized.isEmpty) {
        prefs.remove(key);
      } else {
        prefs.setString(key, normalized);
      }
    },
  );

  late final _customProviderNameProperty = SettingProperty<String>(
    key: customProviderNameStorageKey,
    defaultValue: '',
    prefs: _prefs,
    onChanged: notifyListeners,
    customWrite: (prefs, key, val) {
      final normalized = val.trim();
      if (normalized.isEmpty) {
        prefs.remove(key);
      } else {
        prefs.setString(key, normalized);
      }
      _lastKnownCustomProviderName = normalized;
    },
  );

  late final _visualizerStyleProperty = SettingProperty<VisualizerStyle>(
    key: _keyVisualizerStyle,
    defaultValue: VisualizerStyle.bars,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) =>
        VisualizerStyleX.fromStorageValue(prefs.getString(key), def),
    customWrite: (prefs, key, val) => prefs.setString(key, val.storageValue),
  );

  late final _visualizerColorProperty = SettingProperty<Color>(
    key: _keyVisColor,
    defaultValue: Colors.white,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => Color(prefs.getInt(key) ?? def.toARGB32()),
    customWrite: (prefs, key, val) => prefs.setInt(key, val.toARGB32()),
  );

  late final _visualizerOpacityProperty = SettingProperty<double>(
    key: _keyVisOpacity,
    defaultValue: 0.2,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _visualizerCapDropSpeedProperty = SettingProperty<double>(
    key: _keyVisCapDropSpeed,
    defaultValue: 0.20,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _isVisualizerGradientEnabledProperty = SettingProperty<bool>(
    key: _keyVisGradient,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _visualizerStartColorProperty = SettingProperty<Color>(
    key: _keyVisStartColor,
    defaultValue: Colors.blue,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => Color(prefs.getInt(key) ?? def.toARGB32()),
    customWrite: (prefs, key, val) => prefs.setInt(key, val.toARGB32()),
  );

  late final _visualizerEndColorProperty = SettingProperty<Color>(
    key: _keyVisEndColor,
    defaultValue: Colors.purple,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) => Color(prefs.getInt(key) ?? def.toARGB32()),
    customWrite: (prefs, key, val) => prefs.setInt(key, val.toARGB32()),
  );

  late final _visualizerGradientStop1Property = SettingProperty<double>(
    key: _keyVisGradientStop1,
    defaultValue: 0.0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _visualizerGradientStop2Property = SettingProperty<double>(
    key: _keyVisGradientStop2,
    defaultValue: 1.0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _visualizerGradientTileModeProperty = SettingProperty<int>(
    key: _keyVisGradientTileMode,
    defaultValue: TileMode.clamp.index,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _isVisualizerDynamicColorProperty = SettingProperty<bool>(
    key: _keyVisualizerDynamicColor,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _isVisualizerDynamicStartColorProperty = SettingProperty<bool>(
    key: _keyVisualizerDynamicStartColor,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _isVisualizerDynamicEndColorProperty = SettingProperty<bool>(
    key: _keyVisualizerDynamicEndColor,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _playbackBackgroundTypeProperty = SettingProperty<int>(
    key: _keyPlaybackBackgroundType,
    defaultValue: 0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _playbackRadialGradientEnabledProperty = SettingProperty<bool>(
    key: _keyPlaybackRadialGradientEnabled,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _playbackBackgroundColorProperty = SettingProperty<int>(
    key: _keyPlaybackBackgroundColor,
    defaultValue: 0xFF1A1F2C,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _playbackBackgroundCustomImagePathProperty =
      SettingProperty<String>(
        key: _keyPlaybackBackgroundCustomImagePath,
        defaultValue: '',
        prefs: _prefs,
        onChanged: notifyListeners,
      );

  late final _playbackBackgroundNormalOpacityProperty = SettingProperty<double>(
    key: _keyPlaybackBackgroundNormalOpacity,
    defaultValue: defaultPlaybackBackgroundNormalOpacity,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _playbackBackgroundLyricsOpacityProperty = SettingProperty<double>(
    key: _keyPlaybackBackgroundLyricsOpacity,
    defaultValue: defaultPlaybackBackgroundLyricsOpacity,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _playbackBlurredArtworkBlurSigmaProperty = SettingProperty<double>(
    key: _keyPlaybackBlurredArtworkBlurSigma,
    defaultValue: defaultPlaybackBlurredArtworkBlurSigma,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _playbackCustomImageBlurSigmaProperty = SettingProperty<double>(
    key: _keyPlaybackCustomImageBlurSigma,
    defaultValue: defaultPlaybackCustomImageBlurSigma,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _playbackMeshBackgroundSpeedProperty = SettingProperty<double>(
    key: _keyPlaybackMeshBackgroundSpeed,
    defaultValue: 0.05,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _portraitFrequencyGroupsProperty = SettingProperty<int>(
    key: _keyPortraitFrequencyGroups,
    defaultValue: 100,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _landscapeFrequencyGroupsProperty = SettingProperty<int>(
    key: _keyLandscapeFrequencyGroups,
    defaultValue: 172,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _portraitGapProperty = SettingProperty<double>(
    key: _keyPortraitGap,
    defaultValue: 1.0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _landscapeGapProperty = SettingProperty<double>(
    key: _keyLandscapeGap,
    defaultValue: 2.0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _isWaveformProgressBarEnabledProperty = SettingProperty<bool>(
    key: _keyIsWaveformProgressBarEnabled,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _waveformLongPressSeekSpeedProperty = SettingProperty<double>(
    key: _keyWaveformLongPressSeekSpeed,
    defaultValue: defaultWaveformLongPressSeekSpeed,
    prefs: _prefs,
    onChanged: notifyListeners,
    customWrite: (prefs, key, val) {
      prefs.setDouble(
        key,
        val.clamp(minWaveformLongPressSeekSpeed, maxWaveformLongPressSeekSpeed),
      );
    },
  );

  late final _enableWaveformLongPressSeekProperty = SettingProperty<bool>(
    key: _keyEnableWaveformLongPressSeek,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _playbackSpeedLimit5xProperty = SettingProperty<bool>(
    key: _keyPlaybackSpeedLimit5x,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _enableFadeEffectProperty = SettingProperty<bool>(
    key: _keyEnableFadeEffect,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _equalizerBandCountProperty = SettingProperty<int>(
    key: _keyEqualizerBandCount,
    defaultValue: 10,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _showDeveloperOptionsProperty = SettingProperty<bool>(
    key: _keyShowDeveloperOptions,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _skipShortAudioScanEnabledProperty = SettingProperty<bool>(
    key: skipShortAudioScanEnabledStorageKey,
    defaultValue: false,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _skipShortAudioScanMinimumDurationSecondsProperty =
      SettingProperty<int>(
        key: skipShortAudioScanMinimumDurationSecondsStorageKey,
        defaultValue: defaultSkipShortAudioScanMinimumDurationSeconds,
        prefs: _prefs,
        onChanged: notifyListeners,
        customWrite: (prefs, key, val) {
          prefs.setInt(key, val.clamp(1, 3600).toInt());
        },
      );

  late final _randomRangeProperty = SettingProperty<int>(
    key: _keyRandomRange,
    defaultValue: 0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _randomMethodProperty = SettingProperty<int>(
    key: _keyRandomMethod,
    defaultValue: 1, // Default to shuffle
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _transcodeDefaultFormatProperty = SettingProperty<AudioFormat>(
    key: _keyTranscodeDefaultFormat,
    defaultValue: AudioFormat.m4a,
    prefs: _prefs,
    onChanged: notifyListeners,
    customRead: (prefs, key, def) =>
        _audioFormatFromStorageValue(prefs.getString(key)),
    customWrite: (prefs, key, val) => prefs.setString(key, val.value),
  );

  late final _transcodeDefaultQualityTierProperty =
      SettingProperty<TranscodeQualityTier>(
        key: _keyTranscodeDefaultQualityTier,
        defaultValue: TranscodeQualityTier.medium,
        prefs: _prefs,
        onChanged: notifyListeners,
        customRead: (prefs, key, def) =>
            TranscodeQualityTierX.fromStorageValue(prefs.getString(key)),
        customWrite: (prefs, key, val) =>
            prefs.setString(key, val.storageValue),
      );

  late final _smallWindowWidthProperty = SettingProperty<double>(
    key: _keySmallWindowWidth,
    defaultValue: 360.0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _smallWindowHeightProperty = SettingProperty<double>(
    key: _keySmallWindowHeight,
    defaultValue: 360.0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _smallWindowBottomPanelModeProperty = SettingProperty<String>(
    key: _keySmallWindowBottomPanelMode,
    defaultValue: SmallWindowBottomPanelMode.collapsed.name,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _smallWindowAlwaysOnTopProperty = SettingProperty<bool>(
    key: _keySmallWindowAlwaysOnTop,
    defaultValue: true,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _smallWindowQueueWidthProperty = SettingProperty<double>(
    key: _keySmallWindowQueueWidth,
    defaultValue: 360.0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  late final _smallWindowQueueHeightProperty = SettingProperty<double>(
    key: _keySmallWindowQueueHeight,
    defaultValue: 600.0,
    prefs: _prefs,
    onChanged: notifyListeners,
  );

  static LyricsAiProvider _initialLyricsProvider(
    SharedPreferences prefs, {
    required String key,
    required String legacyKey,
    required LyricsAiProvider defaultValue,
  }) {
    final stored = prefs.getString(key);
    if (stored != null && stored.trim().isNotEmpty) {
      return LyricsAiProviderX.fromStorageValue(stored);
    }
    return LyricsAiProviderX.fromStorageValue(prefs.getString(legacyKey));
  }

  static String _initialModelId(
    SharedPreferences prefs, {
    required String key,
    required String legacyKey,
    required String defaultValue,
    bool emptyUsesDefault = true,
  }) {
    final normalized = prefs.getString(key)?.trim();
    if (normalized != null) {
      if (normalized.isEmpty && !emptyUsesDefault) {
        return '';
      }
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    final legacy = prefs.getString(legacyKey)?.trim();
    if (legacy != null && legacy.isNotEmpty) {
      return legacy;
    }

    return emptyUsesDefault ? defaultValue : '';
  }

  String _readSecureApiKey(
    SharedPreferences prefs,
    String key,
    String defaultValue,
  ) {
    return _secureApiKeys[key] ?? prefs.getString(key) ?? defaultValue;
  }

  void _writeSecureApiKey(SharedPreferences prefs, String key, String value) {
    final normalized = value.trim();
    if (_secureStorage == null) {
      if (normalized.isEmpty) {
        unawaited(prefs.remove(key));
      } else {
        unawaited(prefs.setString(key, normalized));
      }
      return;
    }

    if (normalized.isEmpty) {
      _secureApiKeys.remove(key);
      unawaited(_secureStorage.delete(key: key).catchError((_) {}));
    } else {
      _secureApiKeys[key] = normalized;
      unawaited(
        _secureStorage.write(key: key, value: normalized).catchError((_) {}),
      );
    }
    unawaited(prefs.remove(key));
  }

  SettingsService(
    this._prefs, {
    FlutterSecureStorage? secureStorage,
    Map<String, String> secureApiKeys = const <String, String>{},
  }) : _secureStorage = secureStorage,
       _secureApiKeys = Map<String, String>.from(secureApiKeys),
       _shortcutBindings = _loadShortcutBindings(_prefs) {
    _lastKnownCustomProviderName =
        _prefs.getString(customProviderNameStorageKey)?.trim() ?? '';
    LocalizedText.overrideLanguageCode =
        _prefs.getString(_keyLocale) ?? 'system';
  }

  final FlutterSecureStorage? _secureStorage;
  final Map<String, String> _secureApiKeys;

  bool get hasShownOnboarding => _hasShownOnboardingProperty.value;
  set hasShownOnboarding(bool value) =>
      _hasShownOnboardingProperty.value = value;

  bool get hasShownCoverTapLyricTip => _hasShownCoverTapLyricTipProperty.value;
  set hasShownCoverTapLyricTip(bool value) =>
      _hasShownCoverTapLyricTipProperty.value = value;

  bool get hasShownLyricsMenuTip => _hasShownLyricsMenuTipProperty.value;
  set hasShownLyricsMenuTip(bool value) =>
      _hasShownLyricsMenuTipProperty.value = value;

  bool get tagCompletionSaveToSourceFile =>
      _tagCompletionSaveToSourceFileProperty.value;
  set tagCompletionSaveToSourceFile(bool value) =>
      _tagCompletionSaveToSourceFileProperty.value = value;

  bool get lanSharingEnabled => _lanSharingEnabledProperty.value;
  set lanSharingEnabled(bool value) => _lanSharingEnabledProperty.value = value;

  String get lanSharingFolderPath => _lanSharingFolderPathProperty.value;
  set lanSharingFolderPath(String value) =>
      _lanSharingFolderPathProperty.value = value;

  bool get hasLanSharingFolderPath => lanSharingFolderPath.trim().isNotEmpty;

  bool get allowRemoteControl => _allowRemoteControlProperty.value;
  set allowRemoteControl(bool value) =>
      _allowRemoteControlProperty.value = value;

  ThemeMode get themeMode => _themeModeProperty.value;
  set themeMode(ThemeMode value) => _themeModeProperty.value = value;

  Color get themeColor => _themeColorProperty.value;
  set themeColor(Color value) => _themeColorProperty.value = value;

  double get uiScale => _uiScaleProperty.value;
  set uiScale(double value) =>
      _uiScaleProperty.value = value.clamp(minUiScale, maxUiScale);

  String get appLocale => _localeProperty.value;
  set appLocale(String value) => _localeProperty.value = value;

  Locale? get effectiveLocale {
    final stored = appLocale;
    if (stored == 'system' || stored.isEmpty) {
      return null;
    }
    if (stored == 'zh_Hant') {
      return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }
    return Locale(stored);
  }

  bool get isImmersiveTabBarEnabled => _isImmersiveTabBarEnabledProperty.value;
  set isImmersiveTabBarEnabled(bool value) =>
      _isImmersiveTabBarEnabledProperty.value = value;

  bool get collapseButtonsInLandscapeLyrics =>
      _collapseButtonsInLandscapeLyricsProperty.value;
  set collapseButtonsInLandscapeLyrics(bool value) =>
      _collapseButtonsInLandscapeLyricsProperty.value = value;

  List<String> get topButtonsOrder => _topButtonsOrderProperty.value;
  set topButtonsOrder(List<String> value) {
    _topButtonsOrderProperty.value = value;
  }

  String get mainControlsLeftButton => _mainControlsLeftButtonProperty.value;
  set mainControlsLeftButton(String value) {
    _mainControlsLeftButtonProperty.value = value;
  }

  String get mainControlsRightButton => _mainControlsRightButtonProperty.value;
  set mainControlsRightButton(String value) {
    _mainControlsRightButtonProperty.value = value;
  }

  String get lyricsHeaderRightButton => _lyricsHeaderRightButtonProperty.value;
  set lyricsHeaderRightButton(String value) {
    _lyricsHeaderRightButtonProperty.value = value;
  }

  void resetPlaybackButtonsToDefault() {
    topButtonsOrder = List<String>.from(defaultTopButtonsOrder);
    mainControlsLeftButton = defaultMainControlsLeftButton;
    mainControlsRightButton = defaultMainControlsRightButton;
    lyricsHeaderRightButton = defaultLyricsHeaderRightButton;
  }

  bool get showScanProgressToast => _showScanProgressToastProperty.value;
  set showScanProgressToast(bool value) =>
      _showScanProgressToastProperty.value = value;

  bool get openPlaybackOnDirectorySongTap =>
      _openPlaybackOnDirectorySongTapProperty.value;
  set openPlaybackOnDirectorySongTap(bool value) =>
      _openPlaybackOnDirectorySongTapProperty.value = value;

  bool get defaultToLyricsModeOnPlaybackOpen =>
      _defaultToLyricsModeOnPlaybackOpenProperty.value;
  set defaultToLyricsModeOnPlaybackOpen(bool value) =>
      _defaultToLyricsModeOnPlaybackOpenProperty.value = value;

  bool get windowsAutoRepairShortcut =>
      _windowsAutoRepairShortcutProperty.value;
  set windowsAutoRepairShortcut(bool value) =>
      _windowsAutoRepairShortcutProperty.value = value;

  bool get enableSystemTray => _enableSystemTrayProperty.value;
  set enableSystemTray(bool value) => _enableSystemTrayProperty.value = value;

  CloseWindowAction get closeWindowAction => _closeWindowActionProperty.value;
  set closeWindowAction(CloseWindowAction value) {
    _closeWindowActionProperty.value = value;
    _closeToTrayProperty.value = (value == CloseWindowAction.minimize);
  }

  bool get closeToTray => closeWindowAction == CloseWindowAction.minimize;
  set closeToTray(bool value) {
    closeWindowAction = value
        ? CloseWindowAction.minimize
        : CloseWindowAction.exit;
  }

  int get sampleStride => _sampleStrideProperty.value;
  set sampleStride(int value) => _sampleStrideProperty.value = value;

  int get waveformChunks => _waveformChunksProperty.value;
  set waveformChunks(int value) => _waveformChunksProperty.value = value;

  bool get isUserInactive => _isUserInactive;
  set isUserInactive(bool value) {
    if (_isUserInactive != value) {
      _isUserInactive = value;
      notifyListeners();
    }
    if (!value) {
      startInactivityTimer();
    }
  }

  String get lyricsTranslationTargetLanguageCode =>
      _lyricsTranslationTargetLanguageProperty.value;
  set lyricsTranslationTargetLanguageCode(String value) =>
      _lyricsTranslationTargetLanguageProperty.value = value;

  String get effectiveLyricsTranslationTargetLanguageCode {
    final stored = lyricsTranslationTargetLanguageCode.trim();
    if (stored.isNotEmpty) {
      return stored;
    }
    return LanguageCodeUtils.currentAppLanguageCode();
  }

  LyricsSaveMethod get lyricsSaveMethod {
    return LyricsSaveMethod.values.firstWhere(
      (method) => method.name == _lyricsSaveMethodProperty.value,
      orElse: () => LyricsSaveMethod.original,
    );
  }

  set lyricsSaveMethod(LyricsSaveMethod value) {
    _lyricsSaveMethodProperty.value = value.name;
  }

  LyricsStyle get lyricsStyle {
    return LyricsStyle.values.firstWhere(
      (style) => style.name == _lyricsStyleProperty.value,
      orElse: () => LyricsStyle.apple,
    );
  }

  set lyricsStyle(LyricsStyle value) {
    _lyricsStyleProperty.value = value.name;
  }

  double get lyricsFontScale => lyricsFontScaleTraditional;
  set lyricsFontScale(double value) => lyricsFontScaleTraditional = value;

  double get lyricsFontScaleTraditional =>
      _lyricsFontScaleTraditionalProperty.value;
  set lyricsFontScaleTraditional(double value) =>
      _lyricsFontScaleTraditionalProperty.value = value;

  double get lyricsFontScaleApple => _lyricsFontScaleAppleProperty.value;
  set lyricsFontScaleApple(double value) =>
      _lyricsFontScaleAppleProperty.value = value;

  LyricsAiProvider get lyricsAiProvider => generationPrimaryModel.provider;
  set lyricsAiProvider(LyricsAiProvider value) {
    generationPrimaryModel = generationPrimaryModel.copyWith(provider: value);
  }

  bool get isLyricsAiAutoSwitchEnabled => false;
  set isLyricsAiAutoSwitchEnabled(bool value) {}

  LyricsAiModelSelection get generationPrimaryModel => LyricsAiModelSelection(
    provider: _generationPrimaryProviderProperty.value,
    modelId: _generationPrimaryModelIdProperty.value,
  );
  set generationPrimaryModel(LyricsAiModelSelection value) {
    _generationPrimaryProviderProperty.value = value.provider;
    _generationPrimaryModelIdProperty.value = value.modelId.trim();
  }

  LyricsAiModelSelection get generationFallbackModel => LyricsAiModelSelection(
    provider: _generationFallbackProviderProperty.value,
    modelId: _generationFallbackModelIdProperty.value,
  );
  set generationFallbackModel(LyricsAiModelSelection value) {
    _generationFallbackProviderProperty.value = value.provider;
    _generationFallbackModelIdProperty.value = value.modelId.trim();
  }

  LyricsAiModelSelection get translationPrimaryModel => LyricsAiModelSelection(
    provider: _translationPrimaryProviderProperty.value,
    modelId: _translationPrimaryModelIdProperty.value,
  );
  set translationPrimaryModel(LyricsAiModelSelection value) {
    _translationPrimaryProviderProperty.value = value.provider;
    _translationPrimaryModelIdProperty.value = value.modelId.trim();
  }

  LyricsAiModelSelection get translationFallbackModel => LyricsAiModelSelection(
    provider: _translationFallbackProviderProperty.value,
    modelId: _translationFallbackModelIdProperty.value,
  );
  set translationFallbackModel(LyricsAiModelSelection value) {
    _translationFallbackProviderProperty.value = value.provider;
    _translationFallbackModelIdProperty.value = value.modelId.trim();
  }

  String get geminiApiKey => _geminiApiKeyProperty.value;
  set geminiApiKey(String value) {
    _geminiApiKeyProperty.value = value;
    if (value.trim().isEmpty) {
      _cleanupModelSelectionsForProvider(LyricsAiProvider.googleAiStudio);
    } else {
      _setDefaultModelIfMissing(LyricsAiProvider.googleAiStudio);
    }
  }

  String get openRouterApiKey => _openRouterApiKeyProperty.value;
  set openRouterApiKey(String value) {
    _openRouterApiKeyProperty.value = value;
    if (value.trim().isEmpty) {
      _cleanupModelSelectionsForProvider(LyricsAiProvider.openRouter);
    } else {
      _setDefaultModelIfMissing(LyricsAiProvider.openRouter);
    }
  }

  String get doubaoApiKey => _doubaoApiKeyProperty.value;
  set doubaoApiKey(String value) {
    _doubaoApiKeyProperty.value = value;
    if (value.trim().isEmpty) {
      _cleanupModelSelectionsForProvider(LyricsAiProvider.doubao);
    } else {
      _setDefaultModelIfMissing(LyricsAiProvider.doubao);
    }
  }

  String get deepseekApiKey => _deepseekApiKeyProperty.value;
  set deepseekApiKey(String value) {
    _deepseekApiKeyProperty.value = value;
    if (value.trim().isEmpty) {
      _cleanupModelSelectionsForProvider(LyricsAiProvider.deepseek);
    } else {
      _setDefaultModelIfMissing(LyricsAiProvider.deepseek);
    }
  }

  String get customProviderApiKey => _customProviderApiKeyProperty.value;
  set customProviderApiKey(String value) {
    _customProviderApiKeyProperty.value = value;
    if (value.trim().isEmpty) {
      _cleanupModelSelectionsForProvider(LyricsAiProvider.custom);
    } else {
      _setDefaultModelIfMissing(LyricsAiProvider.custom);
    }
  }

  String get customProviderBaseUrl => _customProviderBaseUrlProperty.value;
  set customProviderBaseUrl(String value) {
    _customProviderBaseUrlProperty.value = value;
  }

  String get customProviderName => _customProviderNameProperty.value;
  set customProviderName(String value) {
    _customProviderNameProperty.value = value;
  }

  bool _isModelSelectionNotSet(LyricsAiModelSelection selection) {
    return selection.modelId.trim().isEmpty ||
        apiKeyForProvider(selection.provider).trim().isEmpty;
  }

  void _setDefaultModelIfMissing(LyricsAiProvider provider) {
    if (_isModelSelectionNotSet(generationPrimaryModel)) {
      final defaultModelId = switch (provider) {
        LyricsAiProvider.googleAiStudio => defaultGenerationPrimaryModelId,
        LyricsAiProvider.openRouter => defaultOpenRouterGenerationModelId,
        LyricsAiProvider.doubao => defaultDoubaoGenerationModelId,
        LyricsAiProvider.deepseek => '',
        LyricsAiProvider.custom => '',
      };
      if (defaultModelId.isNotEmpty) {
        generationPrimaryModel = LyricsAiModelSelection(
          provider: provider,
          modelId: defaultModelId,
        );
      }
    }

    if (_isModelSelectionNotSet(translationPrimaryModel)) {
      final defaultModelId = switch (provider) {
        LyricsAiProvider.googleAiStudio => defaultTranslationPrimaryModelId,
        LyricsAiProvider.openRouter => defaultOpenRouterTranslationModelId,
        LyricsAiProvider.doubao => defaultDoubaoTranslationModelId,
        LyricsAiProvider.deepseek => defaultDeepSeekTranslationModelId,
        LyricsAiProvider.custom => '',
      };
      if (defaultModelId.isNotEmpty) {
        translationPrimaryModel = LyricsAiModelSelection(
          provider: provider,
          modelId: defaultModelId,
        );
      }
    }
  }

  void _cleanupModelSelectionsForProvider(LyricsAiProvider provider) {
    final remainingProviders = LyricsAiProvider.values
        .where((p) => p != provider && apiKeyForProvider(p).trim().isNotEmpty)
        .toList();

    final fallbackProvider = remainingProviders.isNotEmpty
        ? remainingProviders.first
        : LyricsAiProvider.googleAiStudio;

    if (generationPrimaryModel.provider == provider) {
      generationPrimaryModel = LyricsAiModelSelection(
        provider: fallbackProvider,
        modelId: '',
      );
    }
    if (generationFallbackModel.provider == provider) {
      generationFallbackModel = LyricsAiModelSelection(
        provider: fallbackProvider,
        modelId: '',
      );
    }
    if (translationPrimaryModel.provider == provider) {
      translationPrimaryModel = LyricsAiModelSelection(
        provider: fallbackProvider,
        modelId: '',
      );
    }
    if (translationFallbackModel.provider == provider) {
      translationFallbackModel = LyricsAiModelSelection(
        provider: fallbackProvider,
        modelId: '',
      );
    }
  }

  bool get hasCustomGoogleAiStudioApiKey => geminiApiKey.trim().isNotEmpty;
  bool get hasCustomOpenRouterApiKey => openRouterApiKey.trim().isNotEmpty;
  bool get hasCustomDoubaoApiKey => doubaoApiKey.trim().isNotEmpty;
  bool get hasCustomDeepSeekApiKey => deepseekApiKey.trim().isNotEmpty;
  bool get hasCustomProviderConfigured =>
      customProviderApiKey.trim().isNotEmpty;
  bool get hasBothLyricsGenerationApiKeys =>
      geminiApiKey.trim().isNotEmpty &&
      openRouterApiKey.trim().isNotEmpty &&
      doubaoApiKey.trim().isNotEmpty;
  bool get canAutoSwitchLyricsProvider => false;
  bool get shouldAutoSwitchLyricsProvider => false;
  String get activeLyricsGenerationApiKey =>
      apiKeyForProvider(generationPrimaryModel.provider);
  String get activeLyricsApiKey => activeLyricsGenerationApiKey;
  bool get hasActiveLyricsGenerationApiKey =>
      activeLyricsGenerationApiKey.trim().isNotEmpty;
  bool get hasActiveLyricsApiKey => hasActiveLyricsGenerationApiKey;
  String get activeGeminiTranslationApiKey => geminiApiKey;
  bool get hasGeminiTranslationApiKey => geminiApiKey.trim().isNotEmpty;

  String get geminiPrimaryModelId => generationPrimaryModel.modelId;
  set geminiPrimaryModelId(String value) {
    generationPrimaryModel = generationPrimaryModel.copyWith(modelId: value);
  }

  String get geminiFallbackModelId => generationFallbackModel.modelId;
  set geminiFallbackModelId(String value) {
    generationFallbackModel = generationFallbackModel.copyWith(modelId: value);
  }

  String get geminiTranslationModelId => translationPrimaryModel.modelId;
  set geminiTranslationModelId(String value) {
    translationPrimaryModel = translationPrimaryModel.copyWith(modelId: value);
  }

  String apiKeyForProvider(LyricsAiProvider provider) {
    return switch (provider) {
      LyricsAiProvider.googleAiStudio => geminiApiKey,
      LyricsAiProvider.openRouter => openRouterApiKey,
      LyricsAiProvider.doubao => doubaoApiKey,
      LyricsAiProvider.deepseek => deepseekApiKey,
      LyricsAiProvider.custom => customProviderApiKey,
    };
  }

  bool hasApiKeyForProvider(LyricsAiProvider provider) {
    return apiKeyForProvider(provider).trim().isNotEmpty;
  }

  List<LyricsAiProvider> get availableLyricsModelProviders {
    return LyricsAiProvider.values
        .where(hasApiKeyForProvider)
        .toList(growable: false);
  }

  bool get hasAnyLyricsModelProvider =>
      availableLyricsModelProviders.isNotEmpty;

  bool get hasCustomAcoustidApiKey =>
      _prefs.containsKey(acoustidApiKeyStorageKey);
  ShortcutBinding shortcutBinding(AppShortcutAction action) {
    return _shortcutBindings[action.storageKey] ?? action.defaultBinding;
  }

  Map<AppShortcutAction, ShortcutBinding> get shortcutBindings {
    return {
      for (final action in AppShortcutAction.values)
        action: shortcutBinding(action),
    };
  }

  static String lyricsModelDisplayName(String modelId) {
    final trimmed = modelId.trim();
    if (trimmed.isEmpty) {
      return _l10n().noModelSelected;
    }

    final normalized = trimmed.startsWith('google/')
        ? trimmed.substring('google/'.length)
        : trimmed;
    return normalized
        .split('-')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  static String lyricsModelSelectionLabel(LyricsAiModelSelection selection) {
    final providerName = selection.provider.displayName;
    final modelName = lyricsModelDisplayName(selection.modelId);
    if (selection.modelId.trim().isEmpty) {
      return modelName;
    }
    return '$providerName · $modelName';
  }

  String get acoustidApiKey {
    final stored = _prefs.getString(acoustidApiKeyStorageKey)?.trim();
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    return _builtInAcoustidApiKey;
  }

  VisualizerStyle get visualizerStyle => _visualizerStyleProperty.value;
  set visualizerStyle(VisualizerStyle value) =>
      _visualizerStyleProperty.value = value;

  Color get visualizerColor => _visualizerColorProperty.value;
  set visualizerColor(Color value) => _visualizerColorProperty.value = value;

  double getVisualizerOpacityForStyle(VisualizerStyle style) {
    final key = 'visualizer_opacity_${style.name}';
    final stored = _prefs.getDouble(key);
    if (stored != null) return stored;
    return style.defaultOpacity;
  }

  void setVisualizerOpacityForStyle(VisualizerStyle style, double value) {
    final key = 'visualizer_opacity_${style.name}';
    _prefs.setDouble(key, value);
    notifyListeners();
  }

  double get visualizerOpacity => getVisualizerOpacityForStyle(visualizerStyle);
  set visualizerOpacity(double value) =>
      setVisualizerOpacityForStyle(visualizerStyle, value);

  double get visualizerCapDropSpeed => _visualizerCapDropSpeedProperty.value;
  set visualizerCapDropSpeed(double value) =>
      _visualizerCapDropSpeedProperty.value = value;

  bool get isVisualizerGradientEnabled =>
      _isVisualizerGradientEnabledProperty.value;
  set isVisualizerGradientEnabled(bool value) =>
      _isVisualizerGradientEnabledProperty.value = value;

  Color get visualizerStartColor => _visualizerStartColorProperty.value;
  set visualizerStartColor(Color value) =>
      _visualizerStartColorProperty.value = value;

  Color get visualizerEndColor => _visualizerEndColorProperty.value;
  set visualizerEndColor(Color value) =>
      _visualizerEndColorProperty.value = value;

  double get visualizerGradientStop1 => _visualizerGradientStop1Property.value;
  set visualizerGradientStop1(double value) =>
      _visualizerGradientStop1Property.value = value;

  double get visualizerGradientStop2 => _visualizerGradientStop2Property.value;
  set visualizerGradientStop2(double value) =>
      _visualizerGradientStop2Property.value = value;

  int get visualizerGradientTileMode =>
      _visualizerGradientTileModeProperty.value;
  set visualizerGradientTileMode(int value) =>
      _visualizerGradientTileModeProperty.value = value;

  bool get isVisualizerDynamicColor => _isVisualizerDynamicColorProperty.value;
  set isVisualizerDynamicColor(bool value) =>
      _isVisualizerDynamicColorProperty.value = value;

  bool get isVisualizerDynamicStartColor =>
      _isVisualizerDynamicStartColorProperty.value;
  set isVisualizerDynamicStartColor(bool value) =>
      _isVisualizerDynamicStartColorProperty.value = value;

  bool get isVisualizerDynamicEndColor =>
      _isVisualizerDynamicEndColorProperty.value;
  set isVisualizerDynamicEndColor(bool value) =>
      _isVisualizerDynamicEndColorProperty.value = value;

  int get playbackBackgroundType => _playbackBackgroundTypeProperty.value;
  set playbackBackgroundType(int value) =>
      _playbackBackgroundTypeProperty.value = value;

  bool get playbackRadialGradientEnabled =>
      _playbackRadialGradientEnabledProperty.value;
  set playbackRadialGradientEnabled(bool value) =>
      _playbackRadialGradientEnabledProperty.value = value;

  int get playbackBackgroundColor => _playbackBackgroundColorProperty.value;
  set playbackBackgroundColor(int value) =>
      _playbackBackgroundColorProperty.value = value;

  String get playbackBackgroundCustomImagePath =>
      _playbackBackgroundCustomImagePathProperty.value;
  set playbackBackgroundCustomImagePath(String value) =>
      _playbackBackgroundCustomImagePathProperty.value = value;

  double get playbackBackgroundNormalOpacity =>
      _playbackBackgroundNormalOpacityProperty.value;
  set playbackBackgroundNormalOpacity(double value) =>
      _playbackBackgroundNormalOpacityProperty.value = value;

  double get playbackBackgroundLyricsOpacity =>
      _playbackBackgroundLyricsOpacityProperty.value;
  set playbackBackgroundLyricsOpacity(double value) =>
      _playbackBackgroundLyricsOpacityProperty.value = value;

  double get playbackBlurredArtworkBlurSigma =>
      defaultPlaybackBlurredArtworkBlurSigma;
  set playbackBlurredArtworkBlurSigma(double value) =>
      _playbackBlurredArtworkBlurSigmaProperty.value = value;

  double get playbackCustomImageBlurSigma =>
      defaultPlaybackCustomImageBlurSigma;
  set playbackCustomImageBlurSigma(double value) =>
      _playbackCustomImageBlurSigmaProperty.value = value;

  double get playbackMeshBackgroundSpeed =>
      _playbackMeshBackgroundSpeedProperty.value;
  set playbackMeshBackgroundSpeed(double value) =>
      _playbackMeshBackgroundSpeedProperty.value = value;

  bool getIsAutoModeForStyle(VisualizerStyle style) {
    final key = 'visualizer_auto_mode_${style.name}';
    final stored = _prefs.getBool(key);
    if (stored != null) return stored;
    return true; // Defaults to auto mode
  }

  void setIsAutoModeForStyle(VisualizerStyle style, bool value) {
    final key = 'visualizer_auto_mode_${style.name}';
    _prefs.setBool(key, value);
    notifyListeners();
  }

  bool get isAutoMode => getIsAutoModeForStyle(visualizerStyle);
  set isAutoMode(bool value) => setIsAutoModeForStyle(visualizerStyle, value);

  String getAutoSpectrumQuantityForStyle(VisualizerStyle style) {
    final key = 'visualizer_auto_quantity_${style.name}';
    final stored = _prefs.getString(key);
    if (stored != null) return stored;
    return 'high';
  }

  void setAutoSpectrumQuantityForStyle(VisualizerStyle style, String value) {
    final key = 'visualizer_auto_quantity_${style.name}';
    _prefs.setString(key, value);
    notifyListeners();
  }

  String get autoSpectrumQuantity =>
      getAutoSpectrumQuantityForStyle(visualizerStyle);
  set autoSpectrumQuantity(String value) =>
      setAutoSpectrumQuantityForStyle(visualizerStyle, value);

  String getAutoSpeedForStyle(VisualizerStyle style) {
    final key = 'visualizer_auto_speed_${style.name}';
    final stored = _prefs.getString(key);
    if (stored != null) return stored;
    return style.defaultAutoSpeed;
  }

  void setAutoSpeedForStyle(VisualizerStyle style, String value) {
    final key = 'visualizer_auto_speed_${style.name}';
    _prefs.setString(key, value);
    notifyListeners();
  }

  String get autoSpeed => getAutoSpeedForStyle(visualizerStyle);
  set autoSpeed(String value) => setAutoSpeedForStyle(visualizerStyle, value);

  int get portraitFrequencyGroups => _portraitFrequencyGroupsProperty.value;
  set portraitFrequencyGroups(int value) =>
      _portraitFrequencyGroupsProperty.value = value;

  int get landscapeFrequencyGroups => _landscapeFrequencyGroupsProperty.value;
  set landscapeFrequencyGroups(int value) =>
      _landscapeFrequencyGroupsProperty.value = value;

  double get portraitGap => _portraitGapProperty.value;
  set portraitGap(double value) => _portraitGapProperty.value = value;

  double get landscapeGap => _landscapeGapProperty.value;
  set landscapeGap(double value) => _landscapeGapProperty.value = value;

  bool get isWaveformProgressBarEnabled =>
      _isWaveformProgressBarEnabledProperty.value;
  set isWaveformProgressBarEnabled(bool value) =>
      _isWaveformProgressBarEnabledProperty.value = value;

  double get waveformLongPressSeekSpeed =>
      _waveformLongPressSeekSpeedProperty.value;
  set waveformLongPressSeekSpeed(double value) =>
      _waveformLongPressSeekSpeedProperty.value = value;

  bool get enableWaveformLongPressSeek =>
      _enableWaveformLongPressSeekProperty.value;
  set enableWaveformLongPressSeek(bool value) =>
      _enableWaveformLongPressSeekProperty.value = value;

  bool get playbackSpeedLimit5x => _playbackSpeedLimit5xProperty.value;
  set playbackSpeedLimit5x(bool value) =>
      _playbackSpeedLimit5xProperty.value = value;

  bool get enableFadeEffect => _enableFadeEffectProperty.value;
  set enableFadeEffect(bool value) => _enableFadeEffectProperty.value = value;

  int get equalizerBandCount => _equalizerBandCountProperty.value;
  set equalizerBandCount(int value) =>
      _equalizerBandCountProperty.value = value;

  bool get showDeveloperOptions => _showDeveloperOptionsProperty.value;
  set showDeveloperOptions(bool value) =>
      _showDeveloperOptionsProperty.value = value;

  bool get skipShortAudioScanEnabled =>
      _skipShortAudioScanEnabledProperty.value;
  set skipShortAudioScanEnabled(bool value) =>
      _skipShortAudioScanEnabledProperty.value = value;

  int get skipShortAudioScanMinimumDurationSeconds =>
      _skipShortAudioScanMinimumDurationSecondsProperty.value;
  set skipShortAudioScanMinimumDurationSeconds(int value) =>
      _skipShortAudioScanMinimumDurationSecondsProperty.value = value;

  int get randomRange => _randomRangeProperty.value;
  set randomRange(int value) => _randomRangeProperty.value = value;

  int get randomMethod => _randomMethodProperty.value;
  set randomMethod(int value) => _randomMethodProperty.value = value;

  AudioFormat get transcodeDefaultFormat =>
      _transcodeDefaultFormatProperty.value;
  set transcodeDefaultFormat(AudioFormat value) =>
      _transcodeDefaultFormatProperty.value = value;

  TranscodeQualityTier get transcodeDefaultQualityTier =>
      _transcodeDefaultQualityTierProperty.value;
  set transcodeDefaultQualityTier(TranscodeQualityTier value) =>
      _transcodeDefaultQualityTierProperty.value = value;

  double get smallWindowWidth => _smallWindowWidthProperty.value;
  set smallWindowWidth(double value) => _smallWindowWidthProperty.value = value;

  double get smallWindowHeight => _smallWindowHeightProperty.value;
  set smallWindowHeight(double value) =>
      _smallWindowHeightProperty.value = value;

  double get smallWindowQueueWidth => _smallWindowQueueWidthProperty.value;
  set smallWindowQueueWidth(double value) =>
      _smallWindowQueueWidthProperty.value = value;

  double get smallWindowQueueHeight => _smallWindowQueueHeightProperty.value;
  set smallWindowQueueHeight(double value) =>
      _smallWindowQueueHeightProperty.value = value;

  Size get savedSmallWindowSize => Size(smallWindowWidth, smallWindowHeight);
  set savedSmallWindowSize(Size size) {
    smallWindowWidth = size.width;
    smallWindowHeight = size.height;
  }

  Size get savedSmallWindowQueueSize =>
      Size(smallWindowQueueWidth, smallWindowQueueHeight);
  set savedSmallWindowQueueSize(Size size) {
    smallWindowQueueWidth = size.width;
    smallWindowQueueHeight = size.height;
  }

  FolderViewMode get folderViewMode => _folderViewModeProperty.value;
  set folderViewMode(FolderViewMode value) =>
      _folderViewModeProperty.value = value;

  SharedPreferences get prefs => _prefs;

  static AudioFormat _audioFormatFromStorageValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return AudioFormat.m4a;
    }
    try {
      return audioFormatFromValue(normalized);
    } catch (_) {
      return AudioFormat.m4a;
    }
  }

  static Map<String, ShortcutBinding> _loadShortcutBindings(
    SharedPreferences prefs,
  ) {
    final raw = prefs.getString(_keyShortcutBindings);
    if (raw == null || raw.trim().isEmpty) {
      return <String, ShortcutBinding>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, ShortcutBinding>{};
      }

      final result = <String, ShortcutBinding>{};
      for (final entry in decoded.entries) {
        if (entry.key is! String) {
          continue;
        }
        final binding = ShortcutBinding.fromJson(entry.value);
        if (binding == null) {
          continue;
        }
        result[entry.key as String] = binding;
      }
      return result;
    } catch (_) {
      return <String, ShortcutBinding>{};
    }
  }

  Future<void> _saveShortcutBindings() async {
    if (_shortcutBindings.isEmpty) {
      await _prefs.remove(_keyShortcutBindings);
      return;
    }

    final encoded = jsonEncode({
      for (final entry in _shortcutBindings.entries)
        entry.key: entry.value.toJson(),
    });
    await _prefs.setString(_keyShortcutBindings, encoded);
  }

  void resetVisualizerAppearance() {
    _visualizerStyleProperty.reset();
    _visualizerOpacityProperty.reset();
    for (final s in VisualizerStyle.values) {
      _prefs.remove('visualizer_opacity_${s.name}');
      _prefs.remove('visualizer_auto_mode_${s.name}');
      _prefs.remove('visualizer_auto_quantity_${s.name}');
      _prefs.remove('visualizer_auto_speed_${s.name}');
    }
    _visualizerCapDropSpeedProperty.reset();
    _visualizerColorProperty.reset();
    _isVisualizerGradientEnabledProperty.reset();
    _visualizerStartColorProperty.reset();
    _visualizerEndColorProperty.reset();
    _visualizerGradientStop1Property.reset();
    _visualizerGradientStop2Property.reset();
    _visualizerGradientTileModeProperty.reset();
    _isVisualizerDynamicColorProperty.reset();
    _isVisualizerDynamicStartColorProperty.reset();
    _isVisualizerDynamicEndColorProperty.reset();
    _playbackMeshBackgroundSpeedProperty.reset();
    _playbackBackgroundColorProperty.reset();
    _playbackRadialGradientEnabledProperty.reset();
    _playbackBackgroundCustomImagePathProperty.reset();
    _playbackBackgroundNormalOpacityProperty.reset();
    _playbackBackgroundLyricsOpacityProperty.reset();
    _playbackBlurredArtworkBlurSigmaProperty.reset();
    _playbackCustomImageBlurSigmaProperty.reset();
    _portraitFrequencyGroupsProperty.reset();
    _landscapeFrequencyGroupsProperty.reset();
    _portraitGapProperty.reset();
    _landscapeGapProperty.reset();
    _isWaveformProgressBarEnabledProperty.reset();
    _showDeveloperOptionsProperty.reset();
    _randomRangeProperty.reset();
    _randomMethodProperty.reset();
  }

  void increaseLyricsFontScale() {
    lyricsFontScale = lyricsFontScale + lyricsFontScaleStep;
  }

  void decreaseLyricsFontScale() {
    lyricsFontScale = lyricsFontScale - lyricsFontScaleStep;
  }

  void resetLyricsFontScale() {
    resetLyricsFontScaleTraditional();
  }

  void resetLyricsFontScaleTraditional() {
    _lyricsFontScaleTraditionalProperty.reset();
  }

  void resetLyricsFontScaleApple() {
    _lyricsFontScaleAppleProperty.reset();
  }

  void resetLyricsAiModels() {
    generationPrimaryModel = const LyricsAiModelSelection(
      provider: LyricsAiProvider.googleAiStudio,
      modelId: defaultGenerationPrimaryModelId,
    );
    generationFallbackModel = const LyricsAiModelSelection(
      provider: LyricsAiProvider.googleAiStudio,
      modelId: defaultGenerationFallbackModelId,
    );
    translationPrimaryModel = const LyricsAiModelSelection(
      provider: LyricsAiProvider.googleAiStudio,
      modelId: defaultTranslationPrimaryModelId,
    );
    translationFallbackModel = const LyricsAiModelSelection(
      provider: LyricsAiProvider.googleAiStudio,
      modelId: defaultTranslationFallbackModelId,
    );
  }

  void applyProviderDefaults(LyricsAiProvider provider) {
    switch (provider) {
      case LyricsAiProvider.googleAiStudio:
        resetLyricsAiModels();
        break;
      case LyricsAiProvider.openRouter:
        generationPrimaryModel = const LyricsAiModelSelection(
          provider: LyricsAiProvider.openRouter,
          modelId: defaultOpenRouterGenerationModelId,
        );
        generationFallbackModel = const LyricsAiModelSelection(
          provider: LyricsAiProvider.openRouter,
          modelId: '',
        );
        translationPrimaryModel = const LyricsAiModelSelection(
          provider: LyricsAiProvider.openRouter,
          modelId: defaultOpenRouterTranslationModelId,
        );
        translationFallbackModel = const LyricsAiModelSelection(
          provider: LyricsAiProvider.openRouter,
          modelId: '',
        );
        break;
      case LyricsAiProvider.doubao:
        generationPrimaryModel = const LyricsAiModelSelection(
          provider: LyricsAiProvider.doubao,
          modelId: defaultDoubaoGenerationModelId,
        );
        generationFallbackModel = const LyricsAiModelSelection(
          provider: LyricsAiProvider.doubao,
          modelId: '',
        );
        translationPrimaryModel = const LyricsAiModelSelection(
          provider: LyricsAiProvider.doubao,
          modelId: defaultDoubaoTranslationModelId,
        );
        translationFallbackModel = const LyricsAiModelSelection(
          provider: LyricsAiProvider.doubao,
          modelId: '',
        );
        break;
      case LyricsAiProvider.deepseek:
        translationPrimaryModel = const LyricsAiModelSelection(
          provider: LyricsAiProvider.deepseek,
          modelId: defaultDeepSeekTranslationModelId,
        );
        translationFallbackModel = const LyricsAiModelSelection(
          provider: LyricsAiProvider.deepseek,
          modelId: '',
        );
        break;
      case LyricsAiProvider.custom:
        break;
    }
  }

  void resetLyricsTranslationTargetLanguage() {
    _lyricsTranslationTargetLanguageProperty.reset();
  }

  void setShortcutBinding(AppShortcutAction action, ShortcutBinding binding) {
    _shortcutBindings[action.storageKey] = binding;
    unawaited(_saveShortcutBindings());
    notifyListeners();
  }

  void setShortcutBindings(Map<AppShortcutAction, ShortcutBinding> bindings) {
    _shortcutBindings = {
      for (final entry in bindings.entries) entry.key.storageKey: entry.value,
    };
    unawaited(_saveShortcutBindings());
    notifyListeners();
  }

  void resetShortcutBindings() {
    _shortcutBindings = <String, ShortcutBinding>{};
    unawaited(_saveShortcutBindings());
    notifyListeners();
  }

  set acoustidApiKey(String value) {
    final normalized = value.trim();
    if (acoustidApiKey == normalized) {
      return;
    }

    if (normalized.isEmpty) {
      _prefs.remove(acoustidApiKeyStorageKey);
    } else {
      _prefs.setString(acoustidApiKeyStorageKey, normalized);
    }
    notifyListeners();
  }

  void startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 3), () {
      if (!_isUserInactive) {
        _isUserInactive = true;
        notifyListeners();
      }
    });
  }

  void resetInactivity() {
    if (_isUserInactive) {
      _isUserInactive = false;
      notifyListeners();
    }
    startInactivityTimer();
  }

  static Future<SettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    final secureApiKeys = <String, String>{};
    for (final key in _apiKeyStorageKeys) {
      try {
        final secureValue = (await secureStorage.read(key: key))?.trim();
        final legacyValue = prefs.getString(key)?.trim();
        if (secureValue != null && secureValue.isNotEmpty) {
          secureApiKeys[key] = secureValue;
        } else if (legacyValue != null && legacyValue.isNotEmpty) {
          secureApiKeys[key] = legacyValue;
          try {
            await secureStorage.write(key: key, value: legacyValue);
          } catch (_) {}
        }
        if (legacyValue != null) {
          await prefs.remove(key);
        }
      } catch (_) {
        final legacyValue = prefs.getString(key)?.trim();
        if (legacyValue != null && legacyValue.isNotEmpty) {
          secureApiKeys[key] = legacyValue;
        }
      }
    }
    return SettingsService(
      prefs,
      secureStorage: secureStorage,
      secureApiKeys: secureApiKeys,
    );
  }

  static double _normalizeLyricsFontScale(double value) {
    final clamped = value.clamp(minLyricsFontScale, maxLyricsFontScale);
    return (clamped * 10).roundToDouble() / 10.0;
  }

  bool _isSmallWindowMode = false;
  bool get isSmallWindowMode => _isSmallWindowMode;
  set isSmallWindowMode(bool value) {
    if (_isSmallWindowMode != value) {
      _isSmallWindowMode = value;
      notifyListeners();
    }
  }

  bool get isSmallWindowAlwaysOnTop => _smallWindowAlwaysOnTopProperty.value;
  set isSmallWindowAlwaysOnTop(bool value) {
    _smallWindowAlwaysOnTopProperty.value = value;
  }

  SmallWindowBottomPanelMode get smallWindowBottomPanelMode {
    return SmallWindowBottomPanelMode.values.firstWhere(
      (mode) => mode.name == _smallWindowBottomPanelModeProperty.value,
      orElse: () => SmallWindowBottomPanelMode.collapsed,
    );
  }

  set smallWindowBottomPanelMode(SmallWindowBottomPanelMode value) {
    _smallWindowBottomPanelModeProperty.value = value.name;
  }

  void toggleSmallWindowBottomPanelMode(SmallWindowBottomPanelMode mode) {
    smallWindowBottomPanelMode = smallWindowBottomPanelMode == mode
        ? SmallWindowBottomPanelMode.collapsed
        : mode;
  }

  bool get isSmallWindowQueueExpanded =>
      smallWindowBottomPanelMode == SmallWindowBottomPanelMode.queue;
  set isSmallWindowQueueExpanded(bool value) {
    if (value) {
      smallWindowBottomPanelMode = SmallWindowBottomPanelMode.queue;
    } else if (smallWindowBottomPanelMode == SmallWindowBottomPanelMode.queue) {
      smallWindowBottomPanelMode = SmallWindowBottomPanelMode.collapsed;
    }
  }

  bool get isSmallWindowLyricsExpanded =>
      smallWindowBottomPanelMode == SmallWindowBottomPanelMode.lyrics;
  set isSmallWindowLyricsExpanded(bool value) {
    if (value) {
      smallWindowBottomPanelMode = SmallWindowBottomPanelMode.lyrics;
    } else if (smallWindowBottomPanelMode ==
        SmallWindowBottomPanelMode.lyrics) {
      smallWindowBottomPanelMode = SmallWindowBottomPanelMode.collapsed;
    }
  }

  bool get isSmallWindowBottomPanelExpanded =>
      smallWindowBottomPanelMode != SmallWindowBottomPanelMode.collapsed;

  Size get savedRegularWindowSize => Size(
    _regularWindowWidthProperty.value.clamp(400.0, 99999.0),
    _regularWindowHeightProperty.value.clamp(650.0, 99999.0),
  );

  set savedRegularWindowSize(Size size) {
    _regularWindowWidthProperty.value = size.width.clamp(400.0, 99999.0);
    _regularWindowHeightProperty.value = size.height.clamp(650.0, 99999.0);
  }
}

abstract final class LyricsModelRecommendation {
  static bool isGoogleRecommended(String modelId) {
    final lowerId = modelId.toLowerCase();
    var baseId = lowerId;
    if (baseId.contains(':')) {
      baseId = baseId.split(':').first;
    }

    if (baseId.contains('image') || baseId.contains('tts')) {
      return false;
    }

    if (baseId == 'gemini-flash-latest' ||
        baseId == 'gemini-flash-lite-latest') {
      return true;
    }

    if (baseId.startsWith('gemma-')) {
      final match = RegExp(r'^gemma-(\d+(?:\.\d+)?)-').firstMatch(baseId);
      if (match != null) {
        final ver = double.tryParse(match.group(1) ?? '');
        return ver != null && ver >= 4.0;
      }
    }

    if (baseId.contains('-flash-lite')) {
      final match = RegExp(
        r'gemini-(\d+(?:\.\d+)?)-flash-lite',
      ).firstMatch(baseId);
      if (match != null) {
        final ver = double.tryParse(match.group(1) ?? '');
        return ver != null && ver >= 3.1;
      }
    } else if (baseId.contains('-flash')) {
      final match = RegExp(r'gemini-(\d+(?:\.\d+)?)-flash').firstMatch(baseId);
      if (match != null) {
        final ver = double.tryParse(match.group(1) ?? '');
        return ver != null && ver >= 2.5;
      }
    }

    return false;
  }

  static bool isOpenRouterRecommended(String modelId) {
    var id = modelId.toLowerCase();
    if (id.startsWith('google/')) {
      id = id.substring('google/'.length);
    } else if (id.startsWith('~google/')) {
      id = id.substring('~google/'.length);
    } else {
      return false;
    }
    return isGoogleRecommended(id);
  }

  static bool isDoubaoRecommended(String modelId) {
    final lowerId = modelId.toLowerCase();
    final regExp = RegExp(
      r'^doubao-seed-([0-9]+[\.-][0-9]+)-(lite|mini|pro)(?:-.*)?$',
    );
    final match = regExp.firstMatch(lowerId);
    if (match == null) {
      return false;
    }

    final versionStr = match.group(1)!.replaceAll('-', '.');
    final version = double.tryParse(versionStr);
    if (version == null) {
      return false;
    }

    return version >= 2.0;
  }

  static bool isRecommended(String modelId, LyricsAiProvider provider) {
    return switch (provider) {
      LyricsAiProvider.googleAiStudio => isGoogleRecommended(modelId),
      LyricsAiProvider.openRouter => isOpenRouterRecommended(modelId),
      LyricsAiProvider.doubao => isDoubaoRecommended(modelId),
      LyricsAiProvider.deepseek => true,
      LyricsAiProvider.custom => true,
    };
  }
}
