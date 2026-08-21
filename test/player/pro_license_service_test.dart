import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/player/pro/app_channel.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/pro/pro_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProLicenseService Tests', () {
    test('Default GitHub channel defaults to unlimitedCommunity', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = ProLicenseService(prefs: prefs);

      // Default env is github
      if (AppChannel.isGitHubRelease) {
        expect(service.state.type, LicenseType.unlimitedCommunity);
        expect(service.state.isProUnlocked, isTrue);
      }
    });

    test('LicenseState models and trial calculations', () {
      final now = DateTime.now();
      final expire = now.add(const Duration(days: 10));

      final trialState = LicenseState(
        type: LicenseType.activeTrial,
        trialTotalDays: 15,
        trialDaysRemaining: 10,
        firstLaunchTime: now,
        trialExpireTime: expire,
      );

      expect(trialState.isInTrial, isTrue);
      expect(trialState.isProUnlocked, isTrue);
      expect(trialState.trialDaysRemaining, 10);

      final expiredState = LicenseState(
        type: LicenseType.expiredTrial,
        trialTotalDays: 15,
        trialDaysRemaining: 0,
        firstLaunchTime: now.subtract(const Duration(days: 16)),
        trialExpireTime: now.subtract(const Duration(days: 1)),
      );

      expect(expiredState.isTrialExpired, isTrue);
      expect(expiredState.isProUnlocked, isFalse);
    });
  });
}
