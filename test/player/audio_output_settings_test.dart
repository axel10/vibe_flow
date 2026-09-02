import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/player/settings/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Windows Audio Output Settings Tests', () {
    late SettingsService settings;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settings = SettingsService(prefs);
    });

    test('default settings are shared mode with bit-perfect enabled', () {
      expect(settings.windowsAudioOutputMode, 'shared');
      expect(settings.windowsAudioDeviceId, '');
      expect(settings.wasapiBitPerfect, true);
      expect(settings.wasapiReleaseOnPause, false);
    });

    test('settings persist and notify listeners on update', () {
      int notifyCount = 0;
      settings.addListener(() {
        notifyCount++;
      });

      settings.windowsAudioOutputMode = 'wasapi_exclusive';
      expect(settings.windowsAudioOutputMode, 'wasapi_exclusive');
      expect(notifyCount, 1);

      settings.windowsAudioDeviceId = '{0.0.0.00000000}.{device-guid}';
      expect(settings.windowsAudioDeviceId, '{0.0.0.00000000}.{device-guid}');
      expect(notifyCount, 2);

      settings.wasapiBitPerfect = false;
      expect(settings.wasapiBitPerfect, false);
      expect(notifyCount, 3);

      settings.wasapiReleaseOnPause = true;
      expect(settings.wasapiReleaseOnPause, true);
      expect(notifyCount, 4);
    });
  });
}
