import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/utils/app_orientation_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppOrientationManager.currentMode = null;
    AppOrientationManager.isMobileOverride = true;
  });

  tearDown(() {
    AppOrientationManager.currentMode = null;
    AppOrientationManager.isMobileOverride = null;
  });

  group('AppOrientationManager.syncWithMetrics', () {
    test('On tablet / desktop mode (shortestSide >= 600), mode is unrestricted', () {
      AppOrientationManager.syncWithMetrics(
        shortestSide: 600.0,
        isCoverFlowActive: false,
      );
      expect(AppOrientationManager.currentMode, AppOrientationMode.unrestricted);

      // Even if Cover Flow is active, tablets stay unrestricted
      AppOrientationManager.syncWithMetrics(
        shortestSide: 800.0,
        isCoverFlowActive: true,
      );
      expect(AppOrientationManager.currentMode, AppOrientationMode.unrestricted);
    });

    test('On mobile phone (shortestSide < 600), portrait locked by default', () {
      AppOrientationManager.syncWithMetrics(
        shortestSide: 390.0,
        isCoverFlowActive: false,
      );
      expect(AppOrientationManager.currentMode, AppOrientationMode.portraitOnly);
    });

    test('On mobile phone, switching to Cover Flow locks to landscape', () {
      AppOrientationManager.syncWithMetrics(
        shortestSide: 390.0,
        isCoverFlowActive: false,
      );
      expect(AppOrientationManager.currentMode, AppOrientationMode.portraitOnly);

      AppOrientationManager.syncWithMetrics(
        shortestSide: 390.0,
        isCoverFlowActive: true,
      );
      expect(AppOrientationManager.currentMode, AppOrientationMode.landscapeOnly);
    });

    test('On mobile phone, exiting Cover Flow restores portrait', () {
      AppOrientationManager.syncWithMetrics(
        shortestSide: 412.0,
        isCoverFlowActive: true,
      );
      expect(AppOrientationManager.currentMode, AppOrientationMode.landscapeOnly);

      AppOrientationManager.syncWithMetrics(
        shortestSide: 412.0,
        isCoverFlowActive: false,
      );
      expect(AppOrientationManager.currentMode, AppOrientationMode.portraitOnly);
    });
  });

  group('AppOrientationWatcher Widget', () {
    testWidgets('syncs orientation mode on build and metric change', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppOrientationWatcher(
              child: SizedBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(AppOrientationManager.currentMode, AppOrientationMode.portraitOnly);

      // Change to tablet size
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppOrientationWatcher(
              child: SizedBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(AppOrientationManager.currentMode, AppOrientationMode.unrestricted);
    });
  });
}
