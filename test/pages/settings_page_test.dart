import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/pages/settings/sections/about_section.dart';
import 'package:vynody/pages/settings/sections/acoustid_section.dart';
import 'package:vynody/pages/settings/sections/shortcuts_section.dart';
import 'package:vynody/pages/settings/sections/tags_section.dart';
import 'package:vynody/pages/settings/sections/transcode_section.dart';
import 'package:vynody/pages/settings/widgets/settings_dropdown_tile.dart';
import 'package:vynody/pages/settings/widgets/settings_group_card.dart';
import 'package:vynody/pages/settings/widgets/settings_section_header.dart';
import 'package:vynody/pages/settings_page.dart';
import 'package:vynody/player/settings/settings_service.dart';

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

  testWidgets('SettingsDropdownTile renders selection and options', (tester) async {
    String selected = 'opt1';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsDropdownTile<String>(
            title: 'Dropdown Title',
            value: selected,
            options: const [
              SettingsDropdownOption(value: 'opt1', label: 'Option 1'),
              SettingsDropdownOption(value: 'opt2', label: 'Option 2'),
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
}
