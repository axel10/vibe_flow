import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'settings_section.dart';

class SettingSearchItem {
  final String id;
  final SettingsSection section;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n)? description;
  final IconData? icon;

  const SettingSearchItem({
    required this.id,
    required this.section,
    required this.title,
    this.description,
    this.icon,
  });

  bool matches(String query, AppLocalizations l10n, BuildContext context) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return false;

    final titleText = title(l10n).toLowerCase();
    if (titleText.contains(cleanQuery)) return true;

    final descText = description?.call(l10n).toLowerCase() ?? '';
    if (descText.contains(cleanQuery)) return true;

    final sectionText = section.title(context).toLowerCase();
    if (sectionText.contains(cleanQuery)) return true;

    return false;
  }
}

final List<SettingSearchItem> settingsSearchRegistry = [
  // --- 常规设置 (General) ---
  SettingSearchItem(
    id: 'general.theme_mode',
    section: SettingsSection.general,
    icon: Icons.brightness_6_rounded,
    title: (l10n) => l10n.themeMode,
  ),
  SettingSearchItem(
    id: 'general.theme_color',
    section: SettingsSection.general,
    icon: Icons.palette_outlined,
    title: (l10n) => l10n.themeColor,
  ),
  SettingSearchItem(
    id: 'general.language',
    section: SettingsSection.general,
    icon: Icons.language_rounded,
    title: (l10n) => l10n.interfaceLanguage,
    description: (l10n) => l10n.interfaceLanguageDescription,
  ),
  SettingSearchItem(
    id: 'general.ui_scale',
    section: SettingsSection.general,
    icon: Icons.aspect_ratio_rounded,
    title: (l10n) => l10n.uiDisplayScale,
    description: (l10n) => l10n.uiDisplayScaleDescription,
  ),
  SettingSearchItem(
    id: 'general.collapse_lyrics_buttons',
    section: SettingsSection.general,
    icon: Icons.view_sidebar_rounded,
    title: (l10n) => l10n.collapseButtonsInLandscapeLyrics,
    description: (l10n) => l10n.collapseButtonsInLandscapeLyricsDescription,
  ),
  SettingSearchItem(
    id: 'general.playback_button_layout',
    section: SettingsSection.general,
    icon: Icons.tune_rounded,
    title: (l10n) => l10n.playbackButtonLayoutTitle,
    description: (l10n) => l10n.playbackButtonLayoutDescription,
  ),
  SettingSearchItem(
    id: 'general.developer_options',
    section: SettingsSection.general,
    icon: Icons.developer_mode_rounded,
    title: (l10n) => l10n.showDeveloperOptions,
    description: (l10n) => l10n.showDeveloperOptionsDescription,
  ),
  SettingSearchItem(
    id: 'general.immersive_tab_bar',
    section: SettingsSection.general,
    icon: Icons.tab_rounded,
    title: (l10n) => l10n.immersiveTabBar,
    description: (l10n) => l10n.immersiveTabBarDescription,
  ),
  SettingSearchItem(
    id: 'general.open_playback_on_tap',
    section: SettingsSection.general,
    icon: Icons.play_circle_outline_rounded,
    title: (l10n) => l10n.openPlaybackOnDirectorySongTap,
    description: (l10n) => l10n.openPlaybackOnDirectorySongTapDescription,
  ),
  SettingSearchItem(
    id: 'general.default_lyrics_mode',
    section: SettingsSection.general,
    icon: Icons.lyrics_rounded,
    title: (l10n) => l10n.defaultToLyricsModeOnPlaybackOpen,
    description: (l10n) => l10n.defaultToLyricsModeOnPlaybackOpenDescription,
  ),
  SettingSearchItem(
    id: 'general.waveform_progress_bar',
    section: SettingsSection.general,
    icon: Icons.graphic_eq_rounded,
    title: (l10n) => l10n.enableWaveformProgressBar,
    description: (l10n) => l10n.enableWaveformProgressBarDescription,
  ),
  SettingSearchItem(
    id: 'general.waveform_long_press_seek',
    section: SettingsSection.general,
    icon: Icons.fast_forward_rounded,
    title: (l10n) => l10n.enableWaveformLongPressSeek,
    description: (l10n) => l10n.enableWaveformLongPressSeekDescription,
  ),
  SettingSearchItem(
    id: 'general.scan_progress_toast',
    section: SettingsSection.general,
    icon: Icons.notifications_none_rounded,
    title: (l10n) => l10n.showScanProgressToastSetting,
    description: (l10n) => l10n.showScanProgressToastSettingDescription,
  ),
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) ...[
    SettingSearchItem(
      id: 'general.system_tray',
      section: SettingsSection.general,
      icon: Icons.system_update_alt_rounded,
      title: (l10n) => l10n.enableSystemTray,
      description: (l10n) => l10n.enableSystemTrayDescription,
    ),
    SettingSearchItem(
      id: 'general.close_window_action',
      section: SettingsSection.general,
      icon: Icons.close_rounded,
      title: (l10n) => l10n.closeWindowActionTitle,
      description: (l10n) => l10n.closeWindowActionDescription,
    ),
  ],
  SettingSearchItem(
    id: 'general.reset_onboarding',
    section: SettingsSection.general,
    icon: Icons.help_outline_rounded,
    title: (l10n) => l10n.resetOnboarding,
    description: (l10n) => l10n.resetOnboardingDesc,
  ),

  // --- 音频设置 (Audio) ---
  if (Platform.isWindows) ...[
    SettingSearchItem(
      id: 'audio.windows_output',
      section: SettingsSection.audio,
      icon: Icons.speaker_group_rounded,
      title: (l10n) => l10n.windowsAudioOutputTitle,
      description: (l10n) => l10n.windowsAudioOutputDescription,
    ),
    SettingSearchItem(
      id: 'audio.wasapi_shortcut',
      section: SettingsSection.audio,
      icon: Icons.keyboard_rounded,
      title: (l10n) => l10n.wasapiExclusiveShortcutTitle,
      description: (l10n) => l10n.wasapiExclusiveShortcutDescription,
    ),
    SettingSearchItem(
      id: 'audio.device',
      section: SettingsSection.audio,
      icon: Icons.speaker_rounded,
      title: (l10n) => l10n.audioOutputDeviceTitle,
    ),
    SettingSearchItem(
      id: 'audio.bit_perfect',
      section: SettingsSection.audio,
      icon: Icons.auto_fix_high_rounded,
      title: (l10n) => l10n.wasapiBitPerfectTitle,
      description: (l10n) => l10n.wasapiBitPerfectDescription,
    ),
    SettingSearchItem(
      id: 'audio.release_on_pause',
      section: SettingsSection.audio,
      icon: Icons.pause_circle_outline_rounded,
      title: (l10n) => l10n.wasapiReleaseOnPauseTitle,
      description: (l10n) => l10n.wasapiReleaseOnPauseDescription,
    ),
  ],
  SettingSearchItem(
    id: 'audio.equalizer_bands',
    section: SettingsSection.audio,
    icon: Icons.equalizer_rounded,
    title: (l10n) => l10n.equalizerBandCount,
    description: (l10n) => l10n.equalizerBandCountDescription,
  ),
  SettingSearchItem(
    id: 'audio.fade_effect',
    section: SettingsSection.audio,
    icon: Icons.graphic_eq_rounded,
    title: (l10n) => l10n.enableFadeEffect,
    description: (l10n) => l10n.enableFadeEffectDescription,
  ),

  // --- 扫描设置 (Scanning) ---
  SettingSearchItem(
    id: 'scanning.skip_short',
    section: SettingsSection.scanning,
    icon: Icons.filter_list_rounded,
    title: (l10n) => l10n.skipShortAudioDuringScan,
    description: (l10n) => l10n.skipShortAudioDuringScanDescription,
  ),
  SettingSearchItem(
    id: 'scanning.short_threshold',
    section: SettingsSection.scanning,
    icon: Icons.timer_outlined,
    title: (l10n) => l10n.shortAudioScanThreshold,
    description: (l10n) => l10n.shortAudioScanThresholdDescription,
  ),
  SettingSearchItem(
    id: 'scanning.rebuild_index',
    section: SettingsSection.scanning,
    icon: Icons.restart_alt_rounded,
    title: (l10n) => l10n.rebuildIndex,
    description: (l10n) => l10n.rebuildIndexDescription,
  ),

  // --- 标签设置 (Tags) ---
  SettingSearchItem(
    id: 'tags.auto_save',
    section: SettingsSection.tags,
    icon: Icons.save_rounded,
    title: (l10n) => l10n.autoSaveToSourceFile,
    description: (l10n) => l10n.autoSaveToSourceFileDescription,
  ),

  // --- 转码设置 (Transcode) ---
  SettingSearchItem(
    id: 'transcode.default_format',
    section: SettingsSection.transcode,
    icon: Icons.swap_horiz_rounded,
    title: (l10n) => l10n.transcodeDefaultFormat,
    description: (l10n) => l10n.transcodeSectionDescription,
  ),
  SettingSearchItem(
    id: 'transcode.default_quality',
    section: SettingsSection.transcode,
    icon: Icons.high_quality_rounded,
    title: (l10n) => l10n.transcodeDefaultQuality,
  ),

  // --- 歌词设置 (Lyrics) ---
  SettingSearchItem(
    id: 'lyrics.translation_language',
    section: SettingsSection.lyrics,
    icon: Icons.translate_rounded,
    title: (l10n) => l10n.lyricsTranslationTargetLanguageLabel,
    description: (l10n) => l10n.lyricsTranslationTargetLanguageDescription,
  ),
  SettingSearchItem(
    id: 'lyrics.save_method',
    section: SettingsSection.lyrics,
    icon: Icons.save_alt_rounded,
    title: (l10n) => l10n.lyricsSaveMethodLabel,
    description: (l10n) => l10n.lyricsSaveMethodDescription,
  ),
  SettingSearchItem(
    id: 'lyrics.style',
    section: SettingsSection.lyrics,
    icon: Icons.style_rounded,
    title: (l10n) => l10n.lyricsStyleLabel,
    description: (l10n) => l10n.lyricsStyleDescription,
  ),
  SettingSearchItem(
    id: 'lyrics.import',
    section: SettingsSection.lyrics,
    icon: Icons.download_rounded,
    title: (l10n) => l10n.importLyricsLabel,
    description: (l10n) => l10n.importLyricsDescription,
  ),
  SettingSearchItem(
    id: 'lyrics.export',
    section: SettingsSection.lyrics,
    icon: Icons.upload_rounded,
    title: (l10n) => l10n.exportLyricsLabel,
    description: (l10n) => l10n.exportLyricsDescription,
  ),
  SettingSearchItem(
    id: 'lyrics.google_ai_key',
    section: SettingsSection.lyrics,
    icon: Icons.psychology_outlined,
    title: (l10n) => l10n.googleAiStudioApiKey,
  ),
  SettingSearchItem(
    id: 'lyrics.openrouter_key',
    section: SettingsSection.lyrics,
    icon: Icons.smart_toy_outlined,
    title: (l10n) => l10n.openRouterApiKey,
  ),
  SettingSearchItem(
    id: 'lyrics.doubao_key',
    section: SettingsSection.lyrics,
    icon: Icons.chat_bubble_outline_rounded,
    title: (l10n) => l10n.doubaoApiKey,
  ),
  SettingSearchItem(
    id: 'lyrics.deepseek_key',
    section: SettingsSection.lyrics,
    icon: Icons.auto_awesome_rounded,
    title: (l10n) => l10n.deepseekApiKey,
  ),
  SettingSearchItem(
    id: 'lyrics.custom_provider',
    section: SettingsSection.lyrics,
    icon: Icons.api_rounded,
    title: (l10n) => l10n.customApiProvider,
  ),
  SettingSearchItem(
    id: 'lyrics.models',
    section: SettingsSection.lyrics,
    icon: Icons.model_training_rounded,
    title: (l10n) => l10n.geminiModelsSectionTitle,
  ),

  // --- 声学指纹 (AcoustID) ---
  SettingSearchItem(
    id: 'acoustid.api_key',
    section: SettingsSection.acoustid,
    icon: Icons.radar_rounded,
    title: (l10n) => l10n.acoustidApiKeyTitle,
    description: (l10n) => l10n.acoustidApiKeyHelp,
  ),

  // --- 存储与缓存 (Storage) ---
  SettingSearchItem(
    id: 'storage.remote_cache',
    section: SettingsSection.storage,
    icon: Icons.cloud_download_outlined,
    title: (l10n) => l10n.remoteAudioCache,
    description: (l10n) => l10n.remoteAudioCacheDescription,
  ),
  SettingSearchItem(
    id: 'storage.remote_cache_limit',
    section: SettingsSection.storage,
    icon: Icons.storage_rounded,
    title: (l10n) => l10n.remoteCacheLimit,
  ),
  SettingSearchItem(
    id: 'storage.remote_prefetch_count',
    section: SettingsSection.storage,
    icon: Icons.sync_alt_rounded,
    title: (l10n) => l10n.remotePrefetchCount,
    description: (l10n) => l10n.remotePrefetchCountDescription,
  ),
  SettingSearchItem(
    id: 'storage.clear_waveform_cache',
    section: SettingsSection.storage,
    icon: Icons.graphic_eq_rounded,
    title: (l10n) => l10n.clearWaveformCache,
    description: (l10n) => l10n.clearWaveformCacheDescription,
  ),

  // --- 快捷键 (Shortcuts) ---
  SettingSearchItem(
    id: 'shortcuts.settings',
    section: SettingsSection.shortcuts,
    icon: Icons.keyboard_rounded,
    title: (l10n) => l10n.shortcutSettingsTitle,
    description: (l10n) => l10n.shortcutSettingsDescription,
  ),

  // --- Windows (Windows) ---
  if (Platform.isWindows) ...[
    SettingSearchItem(
      id: 'windows.file_association',
      section: SettingsSection.windows,
      icon: Icons.open_in_new_rounded,
      title: (l10n) => l10n.fileAssociationTitle,
      description: (l10n) => l10n.fileAssociationDescription,
    ),
  ],

  // --- 关于 (About) ---
  SettingSearchItem(
    id: 'about.check_updates',
    section: SettingsSection.about,
    icon: Icons.system_update_alt_rounded,
    title: (l10n) => l10n.checkForUpdates,
  ),
  SettingSearchItem(
    id: 'about.export_logs',
    section: SettingsSection.about,
    icon: Icons.description_outlined,
    title: (l10n) => l10n.exportLogs,
  ),
];
