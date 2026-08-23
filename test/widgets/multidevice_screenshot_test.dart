import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/pages/sharing_page.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/sharing/remote_control/remote_control_service.dart';
import 'package:vynody/player/sharing/sharing_riverpod.dart';

import 'helpers/mobile_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Finished Store Poster 05 - Multi-Device Connect', (tester) async {
    SharedPreferences.setMockInitialValues({
      'lan_sharing_enabled': true,
      'allow_remote_control': true,
      'lan_sharing_folder_path': '/Users/axel10/Music/Vynody Music',
    });
    final prefs = await SharedPreferences.getInstance();
    final settingsService = TestSettingsService(prefs);
    settingsService.lanSharingEnabled = true;
    settingsService.allowRemoteControl = true;
    settingsService.lanSharingFolderPath = '/Users/axel10/Music/Vynody Music';

    const posterConfig = MobilePosterConfig(
      tagText: '全平台安全互联',
      tagColor: Color(0xFF38BDF8),
      title: '多端互联',
      subtitle: 'TLS 端到端加密 · 局域网无损秒传与跨端遥控',
      backgroundGradient: [
        Color(0xFF0D1B2A),
        Color(0xFF08111D),
        Color(0xFF05080E),
      ],
      glowColor: Color(0xFF0284C7),
      outputPosterFileName: 'ios_store_05_multidevice.png',
      outputScreenFileName: 'ios_screen_05_multidevice.png',
    );

    await runTwoStageMobilePosterTest(
      tester: tester,
      posterConfig: posterConfig,
      screenChild: const SharingPage(),
      overrides: [
        settingsServiceProvider.overrideWith((ref) => settingsService),
        sharingServiceProvider.overrideWith((ref) => MockSharingService(ref)),
        sharingServerStateProvider.overrideWith(() => MockSharingServerStateNotifier()),
        hostConnectedClientsProvider.overrideWith(() => MockHostConnectedClientsNotifier()),
        trustedDevicesProvider.overrideWith(() => MockTrustedDevicesNotifier()),
        discoveredDevicesProvider.overrideWith(
          (ref) => Stream.value(defaultMockDiscoveredDevices.take(3).toList()),
        ),
        audioCurrentMusicProvider.overrideWith((ref) => null),
        isProUnlockedProvider.overrideWith((ref) => true),
      ],
    );
  });
}
