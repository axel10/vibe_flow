import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/dialogs/upgrade_to_pro_dialog.dart';
import 'package:vynody/player/pro/app_channel.dart';
import 'package:vynody/player/pro/pro_models.dart';

const String _kFirstLaunchTimeKey = 'vynody_license_first_launch_epoch_ms';
const String _kProPurchasedKey = 'vynody_license_pro_purchased';

/// Service managing trial periods and license verification.
class ProLicenseService extends ChangeNotifier {
  ProLicenseService({SharedPreferences? prefs}) : _prefs = prefs {
    _init();
  }

  final SharedPreferences? _prefs;
  LicenseState _state = const LicenseState(
    type: LicenseType.unlimitedCommunity,
  );

  LicenseState get state => _state;

  Future<void> _init() async {
    // 1. If running GitHub Community build, permanently unlock.
    if (AppChannel.isGitHubRelease) {
      _state = const LicenseState(type: LicenseType.unlimitedCommunity);
      notifyListeners();
      return;
    }

    // 2. Store build: Check storage for purchase or trial timestamps.
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    final isPurchased = prefs.getBool(_kProPurchasedKey) ?? false;
    if (isPurchased) {
      _state = const LicenseState(type: LicenseType.purchasedPro);
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    int? firstLaunchMs = prefs.getInt(_kFirstLaunchTimeKey);

    if (firstLaunchMs == null) {
      // First time launching Store version: record start timestamp
      firstLaunchMs = now.millisecondsSinceEpoch;
      await prefs.setInt(_kFirstLaunchTimeKey, firstLaunchMs);
    }

    final firstLaunchTime = DateTime.fromMillisecondsSinceEpoch(firstLaunchMs);
    final expireTime = firstLaunchTime.add(const Duration(days: ProConfig.trialDays));
    final remainingDifference = expireTime.difference(now);

    final remainingDays = remainingDifference.inDays + (remainingDifference.inHours % 24 > 0 ? 1 : 0);

    if (now.isBefore(expireTime) && remainingDays > 0) {
      _state = LicenseState(
        type: LicenseType.activeTrial,
        trialTotalDays: ProConfig.trialDays,
        trialDaysRemaining: remainingDays.clamp(1, ProConfig.trialDays),
        firstLaunchTime: firstLaunchTime,
        trialExpireTime: expireTime,
      );
    } else {
      _state = LicenseState(
        type: LicenseType.expiredTrial,
        trialTotalDays: ProConfig.trialDays,
        trialDaysRemaining: 0,
        firstLaunchTime: firstLaunchTime,
        trialExpireTime: expireTime,
      );
    }

    notifyListeners();
  }

  /// Mark Pro as purchased (for IAP callback / restore purchases).
  Future<void> setPurchased(bool purchased) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_kProPurchasedKey, purchased);
    if (purchased) {
      _state = _state.copyWith(type: LicenseType.purchasedPro);
    } else {
      await _init();
    }
    notifyListeners();
  }

  /// Debug helper: Reset trial timestamp for testing.
  Future<void> debugResetTrial({int offsetDays = 0}) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final newStart = DateTime.now().subtract(Duration(days: offsetDays));
    await prefs.setInt(_kFirstLaunchTimeKey, newStart.millisecondsSinceEpoch);
    await prefs.setBool(_kProPurchasedKey, false);
    await _init();
  }

  /// Check whether a feature can be accessed.
  bool hasAccess(ProFeature feature) {
    return _state.isProUnlocked;
  }
}

/// Provider for the [ProLicenseService] instance.
final proLicenseServiceProvider = ChangeNotifierProvider<ProLicenseService>((ref) {
  return ProLicenseService();
});

/// Provider for the current [LicenseState].
final licenseStateProvider = Provider<LicenseState>((ref) {
  final service = ref.watch(proLicenseServiceProvider);
  return service.state;
});

/// Convenience provider: whether Pro features are currently unlocked.
final isProUnlockedProvider = Provider<bool>((ref) {
  final license = ref.watch(licenseStateProvider);
  return license.isProUnlocked;
});

/// Check access for a specific Pro feature. If locked, opens the upgrade dialog.
/// Returns true if access is granted, false if blocked.
Future<bool> checkProGate(
  BuildContext context,
  WidgetRef ref, {
  ProFeature? feature,
}) async {
  final isUnlocked = ref.read(isProUnlockedProvider);
  if (isUnlocked) return true;

  if (context.mounted) {
    await showUpgradeToProDialog(context, initialFeature: feature);
  }
  return false;
}
