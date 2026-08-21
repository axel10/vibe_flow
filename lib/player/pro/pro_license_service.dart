import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/dialogs/upgrade_to_pro_dialog.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
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
  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  LicenseState _state = const LicenseState(
    type: LicenseType.unlimitedCommunity,
  );

  LicenseState get state => _state;

  /// Reads the trial start timestamp from SharedPreferences, Windows PasswordVault, or Keychain.
  Future<int?> _readPersistentFirstLaunchMs(SharedPreferences prefs) async {
    // 1. Fast check in SharedPreferences
    final prefMs = prefs.getInt(_kFirstLaunchTimeKey);
    if (prefMs != null && prefMs > 0) {
      return prefMs;
    }

    // 2. Windows: check PasswordVault via native MethodChannel
    if (Platform.isWindows) {
      try {
        const channel = MethodChannel('vynody/single_instance');
        final dynamic vaultMs = await channel.invokeMethod('getSecureVaultTrialTime');
        if (vaultMs is int && vaultMs > 0) {
          await prefs.setInt(_kFirstLaunchTimeKey, vaultMs);
          return vaultMs;
        }
      } catch (e) {
        debugPrint('[ProLicenseService] Failed to read trial time from PasswordVault: $e');
      }
    }

    // 3. Apple/Other: check Keychain via FlutterSecureStorage
    try {
      final secureVal = await _secureStorage.read(key: _kFirstLaunchTimeKey);
      if (secureVal != null) {
        final parsed = int.tryParse(secureVal);
        if (parsed != null && parsed > 0) {
          await prefs.setInt(_kFirstLaunchTimeKey, parsed);
          return parsed;
        }
      }
    } catch (e) {
      debugPrint('[ProLicenseService] Failed to read trial time from SecureStorage: $e');
    }

    return null;
  }

  /// Writes the trial start timestamp to SharedPreferences, Windows PasswordVault, and Keychain.
  Future<void> _writePersistentFirstLaunchMs(SharedPreferences prefs, int epochMs) async {
    await prefs.setInt(_kFirstLaunchTimeKey, epochMs);

    if (Platform.isWindows) {
      try {
        const channel = MethodChannel('vynody/single_instance');
        await channel.invokeMethod('setSecureVaultTrialTime', {'epochMs': epochMs});
      } catch (e) {
        debugPrint('[ProLicenseService] Failed to write trial time to PasswordVault: $e');
      }
    }

    try {
      await _secureStorage.write(key: _kFirstLaunchTimeKey, value: epochMs.toString());
    } catch (e) {
      debugPrint('[ProLicenseService] Failed to write trial time to SecureStorage: $e');
    }
  }

  Future<void> _init() async {
    // 1. If running GitHub Community build, permanently unlock.
    if (AppChannel.isGitHubRelease) {
      _state = const LicenseState(type: LicenseType.unlimitedCommunity);
      notifyListeners();
      return;
    }

    // 2. Windows Store build: query real Microsoft Store license via WinRT if packaged
    if (Platform.isWindows && AppChannel.isStoreRelease) {
      try {
        const channel = MethodChannel('vynody/single_instance');
        final dynamic res = await channel.invokeMethod('getStoreLicense');
        if (res is Map && res['isPackaged'] == true) {
          final isProPurchased = res['isProPurchased'] as bool? ?? false;
          final isTrial = res['isTrial'] as bool? ?? false;
          final remainingDays = res['remainingDays'] as int? ?? 0;

          if (isProPurchased) {
            _state = const LicenseState(type: LicenseType.purchasedPro);
            notifyListeners();
            return;
          } else if (isTrial && remainingDays > 0) {
            _state = LicenseState(
              type: LicenseType.activeTrial,
              trialTotalDays: ProConfig.trialDays,
              trialDaysRemaining: remainingDays.clamp(1, ProConfig.trialDays),
            );
            notifyListeners();
            return;
          } else if (isTrial && remainingDays <= 0) {
            _state = const LicenseState(
              type: LicenseType.expiredTrial,
              trialTotalDays: ProConfig.trialDays,
              trialDaysRemaining: 0,
            );
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        debugPrint('[ProLicenseService] Failed to query Windows Store license: $e');
      }
    }

    // 3. Store build fallback: Check storage for purchase or trial timestamps.
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    final isPurchased = prefs.getBool(_kProPurchasedKey) ?? false;
    if (isPurchased) {
      _state = const LicenseState(type: LicenseType.purchasedPro);
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    int? firstLaunchMs = await _readPersistentFirstLaunchMs(prefs);

    if (firstLaunchMs == null) {
      // First time launching Store version: record start timestamp
      firstLaunchMs = now.millisecondsSinceEpoch;
      await _writePersistentFirstLaunchMs(prefs, firstLaunchMs);
    } else {
      // Ensure all persistent layers are in sync
      await _writePersistentFirstLaunchMs(prefs, firstLaunchMs);
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

  /// Refresh license status (e.g. after returning from Microsoft Store or App Store).
  Future<void> refreshLicense() async {
    await _init();
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
    await _writePersistentFirstLaunchMs(prefs, newStart.millisecondsSinceEpoch);
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

/// Provider for whether waveform progress bar is effectively enabled (Pro unlocked & setting enabled).
final isEffectiveWaveformEnabledProvider = Provider<bool>((ref) {
  final isProUnlocked = ref.watch(isProUnlockedProvider);
  final isWaveformSettingEnabled = ref.watch(
    settingsServiceProvider.select((s) => s.isWaveformProgressBarEnabled),
  );
  return isProUnlocked && isWaveformSettingEnabled;
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
