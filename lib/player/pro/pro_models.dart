import 'package:flutter/material.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/pro/app_channel.dart';

/// Features restricted to Pro tier in Store distribution.
enum ProFeature {
  /// Real-time FFT Audio Spectrum Visualizer
  fftVisualizer,

  /// Dynamic audio waveform progress bar
  waveformBar,

  /// AI lyrics generation, timeline alignment, and translation
  aiLyrics,

  /// AI lyrics real-time translation
  aiTranslation,

  /// LAN music file sharing
  lanSharing,

  /// Multi-device remote control
  remoteControl,

  /// Audio batch format transcode & export
  transcoder,

  /// Automatic song metadata & tag completion via MusicBrainz
  tagCompletion;

  String getTitle(AppLocalizations l10n) {
    switch (this) {
      case ProFeature.fftVisualizer:
        return l10n.proFeatureFftVisualizerTitle;
      case ProFeature.waveformBar:
        return l10n.proFeatureWaveformBarTitle;
      case ProFeature.aiLyrics:
      case ProFeature.aiTranslation:
        return l10n.proFeatureAiLyricsTitle;
      case ProFeature.lanSharing:
        return l10n.proFeatureLanSharingTitle;
      case ProFeature.remoteControl:
        return l10n.proFeatureRemoteControlTitle;
      case ProFeature.transcoder:
        return l10n.proFeatureTranscoderTitle;
      case ProFeature.tagCompletion:
        return l10n.proFeatureTagCompletionTitle;
    }
  }

  String getDescription(AppLocalizations l10n) {
    switch (this) {
      case ProFeature.fftVisualizer:
        return l10n.proFeatureFftVisualizerDesc;
      case ProFeature.waveformBar:
        return l10n.proFeatureWaveformBarDesc;
      case ProFeature.aiLyrics:
      case ProFeature.aiTranslation:
        return l10n.proFeatureAiLyricsDesc;
      case ProFeature.lanSharing:
        return l10n.proFeatureLanSharingDesc;
      case ProFeature.remoteControl:
        return l10n.proFeatureRemoteControlDesc;
      case ProFeature.transcoder:
        return l10n.proFeatureTranscoderDesc;
      case ProFeature.tagCompletion:
        return l10n.proFeatureTagCompletionDesc;
    }
  }

  IconData get icon {
    switch (this) {
      case ProFeature.fftVisualizer:
        return Icons.graphic_eq;
      case ProFeature.waveformBar:
        return Icons.waterfall_chart;
      case ProFeature.aiLyrics:
      case ProFeature.aiTranslation:
        return Icons.auto_awesome;
      case ProFeature.lanSharing:
        return Icons.hub;
      case ProFeature.remoteControl:
        return Icons.phonelink;
      case ProFeature.transcoder:
        return Icons.transform;
      case ProFeature.tagCompletion:
        return Icons.auto_fix_high_rounded;
    }
  }
}

/// Metadata describing a Pro feature for dialog display.
class ProFeatureInfo {
  final ProFeature feature;
  final String title;
  final String description;
  final IconData icon;

  const ProFeatureInfo({
    required this.feature,
    required this.title,
    required this.description,
    required this.icon,
  });

  factory ProFeatureInfo.fromFeature(ProFeature feature, AppLocalizations l10n) {
    return ProFeatureInfo(
      feature: feature,
      title: feature.getTitle(l10n),
      description: feature.getDescription(l10n),
      icon: feature.icon,
    );
  }
}

/// License and trial status for the current installation.
enum LicenseType {
  /// Community full version (GitHub builds, permanent unlimited access)
  unlimitedCommunity,

  /// Active free trial (Store builds)
  activeTrial,

  /// Expired free trial (Store builds, Pro features locked)
  expiredTrial,

  /// Purchased Pro license / subscription (Store builds, permanently unlocked)
  purchasedPro,
}

/// Snapshot of the current license state.
class LicenseState {
  final LicenseType type;
  final int trialTotalDays;
  final int trialDaysRemaining;
  final DateTime? firstLaunchTime;
  final DateTime? trialExpireTime;

  const LicenseState({
    required this.type,
    this.trialTotalDays = ProConfig.trialDays,
    this.trialDaysRemaining = ProConfig.trialDays,
    this.firstLaunchTime,
    this.trialExpireTime,
  });

  /// Whether all Pro features are currently accessible.
  bool get isProUnlocked =>
      type == LicenseType.unlimitedCommunity ||
      type == LicenseType.activeTrial ||
      type == LicenseType.purchasedPro;

  /// Whether the license is permanently unlocked (either community build or paid purchase).
  bool get isPermanentlyUnlocked =>
      type == LicenseType.unlimitedCommunity ||
      type == LicenseType.purchasedPro;

  /// Whether the app is running in an active trial period.
  bool get isInTrial => type == LicenseType.activeTrial;

  /// Whether the trial has expired without purchase.
  bool get isTrialExpired => type == LicenseType.expiredTrial;

  /// Copy with updated fields.
  LicenseState copyWith({
    LicenseType? type,
    int? trialTotalDays,
    int? trialDaysRemaining,
    DateTime? firstLaunchTime,
    DateTime? trialExpireTime,
  }) {
    return LicenseState(
      type: type ?? this.type,
      trialTotalDays: trialTotalDays ?? this.trialTotalDays,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
      firstLaunchTime: firstLaunchTime ?? this.firstLaunchTime,
      trialExpireTime: trialExpireTime ?? this.trialExpireTime,
    );
  }
}
