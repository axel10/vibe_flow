import 'package:flutter/material.dart';
import 'package:vynody/player/pro/app_channel.dart';

/// Features restricted to Pro tier in Store distribution.
enum ProFeature {
  /// Real-time FFT Audio Spectrum Visualizer
  fftVisualizer,

  /// Dynamic audio waveform progress bar
  waveformBar,

  /// AI lyrics generation, word-by-word alignment, and refining
  aiLyrics,

  /// AI lyrics real-time translation & romanization
  aiTranslation,

  /// LAN music streaming & Bonsoir device sharing
  lanSharing,

  /// Multi-device remote control
  remoteControl,

  /// Audio batch format transcode & export
  transcoder,
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
