import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/pages/settings/sections/audio_section.dart';
import 'package:vynody/pages/settings/settings_search_registry.dart';
import 'package:vynody/pages/settings_page.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/settings_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Settings search registry matches titles, descriptions and sections', (tester) async {
    late AppLocalizations l10n;
    late BuildContext testContext;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            testContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    // 1. 验证注册列表不为空
    expect(settingsSearchRegistry.isNotEmpty, isTrue);

    // 2. 验证空搜索词不匹配任何项
    final emptyMatches = settingsSearchRegistry.where((item) => item.matches('', l10n, testContext)).toList();
    expect(emptyMatches.isEmpty, isTrue);

    final whitespaceMatches = settingsSearchRegistry.where((item) => item.matches('   ', l10n, testContext)).toList();
    expect(whitespaceMatches.isEmpty, isTrue);

    // 3. 验证标题匹配 (大小写不敏感)
    final themeMatches = settingsSearchRegistry.where((item) {
      return item.matches('theme', l10n, testContext) || item.matches('主题', l10n, testContext);
    }).toList();
    expect(themeMatches.any((item) => item.section == SettingsSection.general), isTrue);

    // 4. 验证描述文字匹配
    final descMatches = settingsSearchRegistry.where((item) {
      return item.matches(l10n.interfaceLanguageDescription, l10n, testContext);
    }).toList();
    expect(descMatches.any((item) => item.id == 'general.language'), isTrue);

    // 5. 验证板块名称匹配
    final audioSectionTitle = SettingsSection.audio.title(testContext);
    final audioMatches = settingsSearchRegistry.where((item) {
      return item.matches(audioSectionTitle, l10n, testContext);
    }).toList();
    expect(audioMatches.any((item) => item.section == SettingsSection.audio), isTrue);
  });

  testWidgets('SettingsPage search filtering and navigation in landscape mode', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);

    // 模拟桌面/横屏宽度 1200x800
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    late AppLocalizations l10n;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsServiceProvider.overrideWith((ref) => settings),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SettingsPage();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final searchFieldFinder = find.byType(TextField);
    expect(searchFieldFinder, findsOneWidget);

    await tester.enterText(searchFieldFinder, l10n.equalizerBandCount);
    await tester.pumpAndSettle();

    // 验证右侧切换为搜索结果视图
    expect(find.byKey(const ValueKey('settings-search-results')), findsOneWidget);

    // 点击搜索结果卡片中的 ListTile
    final resultTile = find.widgetWithText(ListTile, l10n.equalizerBandCount);
    expect(resultTile, findsOneWidget);
    await tester.tap(resultTile);
    await tester.pumpAndSettle();

    // 验证点击后自动清空了搜索框，并切换到了 AudioSection
    expect(find.byType(AudioSection), findsOneWidget);
  });

  testWidgets('SettingsPage search filtering in portrait mode', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);

    // 模拟移动/竖屏 400x800
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsServiceProvider.overrideWith((ref) => settings),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final searchFieldFinder = find.byType(TextField);
    expect(searchFieldFinder, findsOneWidget);

    // 输入无匹配内容
    await tester.enterText(searchFieldFinder, 'xyz_no_such_setting_123');
    await tester.pumpAndSettle();

    // 验证无匹配提示
    expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);

    // 点击清除按钮
    final clearBtn = find.byIcon(Icons.clear_rounded);
    expect(clearBtn, findsOneWidget);
    await tester.tap(clearBtn);
    await tester.pumpAndSettle();

    // 验证恢复常规首页列表
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
  });
}
