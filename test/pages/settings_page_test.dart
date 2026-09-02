import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/dialogs/shortcut_settings_dialog.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/pages/settings/sections/about_section.dart';
import 'package:vynody/pages/settings/sections/acoustid_section.dart';
import 'package:vynody/pages/settings/sections/audio_section.dart';
import 'package:vynody/pages/settings/sections/shortcuts_section.dart';
import 'package:vynody/pages/settings/sections/tags_section.dart';
import 'package:vynody/pages/settings/sections/transcode_section.dart';
import 'package:vynody/pages/settings/widgets/settings_dropdown_tile.dart';
import 'package:vynody/pages/settings/widgets/settings_group_card.dart';
import 'package:vynody/pages/settings/widgets/settings_section_header.dart';
import 'package:vynody/pages/settings_page.dart';
import 'package:vynody/player/pro/pro_models.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/player/settings/shortcut_bindings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('SettingsSection enum provides correct metadata', () {
    expect(SettingsSection.values.length, 12);
    expect(SettingsSection.sidebarSections.contains(SettingsSection.general), isTrue);
    expect(SettingsSection.sidebarSections.contains(SettingsSection.audio), isTrue);
    expect(SettingsSection.sidebarSections.contains(SettingsSection.lyrics), isTrue);
    expect(SettingsSection.sidebarSections.contains(SettingsSection.about), isTrue);
  });

  test('ProFeature.wasapiExclusive exists and provides metadata', () {
    expect(ProFeature.values.contains(ProFeature.wasapiExclusive), isTrue);
    expect(ProFeature.wasapiExclusive.icon, Icons.speaker_group_rounded);
  });

  testWidgets('SettingsSectionHeader renders title and description', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SettingsSectionHeader(
            title: 'Test Header',
            description: 'Test Description',
          ),
        ),
      ),
    );

    expect(find.text('Test Header'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
  });

  testWidgets('SettingsGroupCard renders title, icon and children', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SettingsGroupCard(
            title: 'Group Title',
            icon: Icons.settings,
            children: [Text('Child 1'), Text('Child 2')],
          ),
        ),
      ),
    );

    expect(find.text('Group Title'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.text('Child 1'), findsOneWidget);
    expect(find.text('Child 2'), findsOneWidget);
  });

  testWidgets('SettingsDropdownTile renders selection and options with trailing badge', (tester) async {
    String selected = 'opt1';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsDropdownTile<String>(
            title: 'Dropdown Title',
            value: selected,
            options: const [
              SettingsDropdownOption(value: 'opt1', label: 'Option 1'),
              SettingsDropdownOption(
                value: 'opt2',
                label: 'Option 2',
                trailing: Text('PRO_BADGE'),
              ),
            ],
            onChanged: (val) {
              if (val != null) selected = val;
            },
          ),
        ),
      ),
    );

    expect(find.text('Dropdown Title'), findsOneWidget);
    expect(find.text('Option 1'), findsOneWidget);
  });

  testWidgets('ShortcutsSection renders correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ShortcutsSection(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ShortcutsSection), findsOneWidget);
  });

  testWidgets('AudioSection renders correctly', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AudioSection(settings: settings),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AudioSection), findsOneWidget);
  });

  testWidgets('TagsSection renders correctly', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TagsSection(settings: settings),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TagsSection), findsOneWidget);
  });

  testWidgets('TranscodeSection renders correctly', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TranscodeSection(settings: settings),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TranscodeSection), findsOneWidget);
  });

  testWidgets('AcoustidSection renders correctly', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AcoustidSection(settings: settings),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AcoustidSection), findsOneWidget);
  });

  testWidgets('AboutSection renders correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AboutSection(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AboutSection), findsOneWidget);
  });

  test('AppShortcutAction.toggleWasapiExclusive metadata and defaults', () {
    expect(
      AppShortcutAction.values.contains(AppShortcutAction.toggleWasapiExclusive),
      isTrue,
    );
    expect(
      AppShortcutAction.toggleWasapiExclusive.storageKey,
      'toggle_wasapi_exclusive',
    );
    final defaultBinding =
        AppShortcutAction.toggleWasapiExclusive.defaultBinding;
    expect(defaultBinding.shift, isTrue);
  });

  test('hasUsedWasapiExclusive auto-activates when mode is set to wasapi_exclusive', () async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);

    expect(settings.hasUsedWasapiExclusive, isFalse);

    // Setting mode to wasapi_exclusive triggers hasUsedWasapiExclusive
    settings.windowsAudioOutputMode = 'wasapi_exclusive';
    expect(settings.hasUsedWasapiExclusive, isTrue);

    // Resetting mode to shared preserves hasUsedWasapiExclusive
    settings.windowsAudioOutputMode = 'shared';
    expect(settings.hasUsedWasapiExclusive, isTrue);
  });

  testWidgets('SingleShortcutEditDialog renders correctly', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsServiceProvider.overrideWith((ref) => settings),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleShortcutEditDialog(
              action: AppShortcutAction.toggleWasapiExclusive,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleShortcutEditDialog), findsOneWidget);
    expect(find.byType(ShortcutRecorderField), findsOneWidget);
  });
}
