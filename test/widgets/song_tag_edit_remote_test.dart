import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vynody/dialogs/song_tag_edit_dialog.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';

void main() {
  testWidgets('SongTagEditSheet disables both save buttons for remote song', (
    WidgetTester tester,
  ) async {
    const remoteSong = MusicFile(
      path: 'subsonic://server1/track123',
      name: 'Remote Song',
      title: 'Remote Song',
      artist: 'Remote Artist',
      album: 'Remote Album',
      durationMillis: 180000,
    );

    await tester.pumpWidget(
      const OKToast(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('zh'),
          home: Scaffold(
            body: SizedBox(
              height: 800,
              width: 400,
              child: SongTagEditSheet(song: remoteSong),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final filledButtons = tester.widgetList<FilledButton>(find.byType(FilledButton)).toList();
    expect(filledButtons.length, 2);

    expect(filledButtons[0].onPressed, isNull);
    expect(filledButtons[1].onPressed, isNull);
  });

  testWidgets('SongTagEditSheet enables save to app button for local song', (
    WidgetTester tester,
  ) async {
    const localSong = MusicFile(
      path: '/local/music/test.mp3',
      name: 'test.mp3',
      title: 'Local Song',
      artist: 'Local Artist',
      album: 'Local Album',
      durationMillis: 180000,
    );

    await tester.pumpWidget(
      const OKToast(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('zh'),
          home: Scaffold(
            body: SizedBox(
              height: 800,
              width: 400,
              child: SongTagEditSheet(song: localSong),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final filledButtons = tester.widgetList<FilledButton>(find.byType(FilledButton)).toList();
    expect(filledButtons.length, 2);

    expect(filledButtons[0].onPressed, isNotNull);
  });

  testWidgets('SongTagEditSheet displays and populates album artist field', (
    WidgetTester tester,
  ) async {
    const song = MusicFile(
      path: '/local/music/test.mp3',
      name: 'test.mp3',
      title: 'Song Title',
      artist: 'Track Artist',
      albumArtist: 'Main Album Artist',
      album: 'Album Title',
      durationMillis: 180000,
    );

    await tester.pumpWidget(
      const OKToast(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('zh'),
          home: Scaffold(
            body: SizedBox(
              height: 800,
              width: 400,
              child: SongTagEditSheet(song: song),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('专辑艺术家'), findsOneWidget);
    expect(find.text('Main Album Artist'), findsOneWidget);
  });
}
