import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/widgets/lyrics_panel.dart';
import 'package:vynody/widgets/lyrics_panel_views.dart';

void main() {
  group('shouldShowGenerateLyricsButton', () {
    test('hides the button when there is no current song', () {
      expect(shouldShowGenerateLyricsButton(hasCurrentSong: false), isFalse);
    });

    test('shows the button after lyrics are cleared for the current song', () {
      expect(shouldShowGenerateLyricsButton(hasCurrentSong: true), isTrue);
    });
  });

  group('calculateLyricTopOffsetFromPanelTop', () {
    test('returns the visual top offset for the selected lyric line', () {
      final top = calculateLyricTopOffsetFromPanelTop(
        lineHeights: const [40.0, 50.0, 60.0],
        lineCenters: const [20.0, 65.0, 125.0],
        lineIndex: 1,
        scrollOffset: 10.0,
        scale: 1.12,
      );

      expect(top, closeTo(27.0, 0.0001));
    });

    test('returns null when the line index is out of range', () {
      final top = calculateLyricTopOffsetFromPanelTop(
        lineHeights: const [40.0],
        lineCenters: const [20.0],
        lineIndex: 2,
        scrollOffset: 0.0,
      );

      expect(top, isNull);
    });
  });

  group('AppleLyricLineFadeIn & AppleLyricTranslationFadeIn', () {
    testWidgets('AppleLyricLineFadeIn renders child and completes animation', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: AppleLyricLineFadeIn(
            index: 0,
            animate: true,
            child: Text('Lyric line'),
          ),
        ),
      );

      expect(find.text('Lyric line'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Lyric line'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Lyric line'), findsOneWidget);
    });

    testWidgets('AppleLyricTranslationFadeIn renders translation and completes animation', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: AppleLyricTranslationFadeIn(
            index: 0,
            animate: true,
            child: Text('Translated line'),
          ),
        ),
      );

      expect(find.text('Translated line'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Translated line'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Translated line'), findsOneWidget);
    });

    testWidgets('AppleLyricTranslationFadeIn skips SizeTransition when index < activeIndex', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: AppleLyricTranslationFadeIn(
            index: 2,
            activeIndex: 5,
            animate: true,
            child: Text('Above active line'),
          ),
        ),
      );

      expect(find.text('Above active line'), findsOneWidget);
      expect(find.byType(SizeTransition), findsNothing);
    });

    testWidgets('AppleLyricTranslationFadeIn uses SizeTransition when index >= activeIndex', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: AppleLyricTranslationFadeIn(
            index: 5,
            activeIndex: 5,
            animate: true,
            child: Text('Current active line'),
          ),
        ),
      );

      expect(find.text('Current active line'), findsOneWidget);
      expect(find.byType(SizeTransition), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Current active line'), findsOneWidget);
    });

    testWidgets('StaggeredAppleLyricsScrollWrapper composes properly with AppleLyricLineFadeIn', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StaggeredAppleLyricsScrollWrapper(
            index: 1,
            activeIndex: 1,
            scrollDelta: 50.0,
            scrollTriggerTime: DateTime.now().millisecondsSinceEpoch,
            isEnteringFocusMode: false,
            firstVisibleIndex: 0,
            isTransitioning: false,
            child: const AppleLyricLineFadeIn(
              index: 1,
              animate: true,
              isStaggered: false,
              child: Text('Generating lyric line'),
            ),
          ),
        ),
      );

      expect(find.text('Generating lyric line'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Generating lyric line'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Generating lyric line'), findsOneWidget);
    });
  });
}
