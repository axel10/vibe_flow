import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/models/artist_summary.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/pages/album_detail_page.dart';
import 'package:vynody/pages/albums_tab.dart';
import 'package:vynody/pages/artist_detail_page.dart';
import 'package:vynody/pages/artists_tab.dart';
import 'package:vynody/pages/folder_detail_view.dart';
import 'package:vynody/pages/folder_page.dart';
import 'package:vynody/pages/library_page.dart';
import 'package:vynody/pages/most_played_tab.dart';
import 'package:vynody/pages/playlist_tab.dart';
import 'package:vynody/pages/queue_page.dart';
import 'package:vynody/pages/recently_added_tab.dart';
import 'package:vynody/pages/recently_played_tab.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/library/album_library.dart';
import 'package:vynody/player/library/artist_library.dart';
import 'package:vynody/player/library/library_insights_service.dart';
import 'package:vynody/player/library/playlist_service.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/pro/pro_license_service.dart';

import 'helpers/mobile_screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestSettingsService settingsService;
  late ({
    List<MusicFile> songs,
    List<AlbumSummary> albums,
    Map<String, SongMetadata> metadataMap
  }) demoData;
  late List<ArtistSummary> demoArtists;
  late List<LibraryInsightSongEntry> demoInsightEntries;
  late MusicFolder rootFolder;
  late MusicFolder subFolder;
  late AudioSnapshot audioSnapshot;
  late MockAudioService audioService;
  late MockScannerService scannerService;
  late PlaylistService playlistService;

  setUp(() async {
    await loadMobileTestFonts();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('window_manager'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'isFullScreen':
            return false;
          case 'isMaximized':
            return false;
          case 'getSize':
            return {'width': 1280.0, 'height': 800.0};
          default:
            return null;
        }
      },
    );

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = TestSettingsService(prefs);

    demoData = createDemoLibraryData(
      basePath: '/test/music',
      demoItems: defaultDemoListEn,
    );

    subFolder = MusicFolder(
      path: '/test/music/SubFolder',
      name: 'SubFolder',
      files: demoData.songs.take(4).toList(),
    );

    rootFolder = MusicFolder(
      path: '/test/music',
      name: 'Test Library',
      files: demoData.songs,
      subFolders: [subFolder],
    );

    demoArtists = [
      ArtistSummary(
        queryKey: 'soda pop',
        name: 'Soda Pop',
        songs: demoData.songs.where((s) => s.artist == 'Soda Pop').toList(),
        representativeSong: demoData.songs[3],
        songCount: 1,
      ),
      ArtistSummary(
        queryKey: 'lin zhou',
        name: 'Lin Zhou',
        songs: demoData.songs.where((s) => s.artist == 'Lin Zhou').toList(),
        representativeSong: demoData.songs[0],
        songCount: 1,
      ),
      ArtistSummary(
        queryKey: 'white noise forest',
        name: 'White Noise Forest',
        songs: demoData.songs.where((s) => s.artist == 'White Noise Forest').toList(),
        representativeSong: demoData.songs[2],
        songCount: 1,
      ),
    ];

    demoInsightEntries = demoData.songs.take(6).map((song) {
      return LibraryInsightSongEntry(
        song: song,
        playCount: 12,
        lastPlayedAt: DateTime.now().millisecondsSinceEpoch - 3600000,
        createdAt: DateTime.now().millisecondsSinceEpoch - 86400000,
      );
    }).toList();

    audioSnapshot = AudioSnapshot(
      isPlaying: true,
      isTransitioning: false,
      isLastActionNext: null,
      currentMusic: demoData.songs.first,
      position: const Duration(seconds: 45),
      duration: const Duration(seconds: 220),
      volume: 0.9,
      isMuted: false,
      playbackQueue: demoData.songs,
      currentIndex: 0,
      isRandomMode: false,
      isShuffleRandomMode: false,
      playbackMode: AppPlaybackMode.queue,
      equalizerConfig: EqualizerConfig(
        enabled: false,
        bandCount: 10,
        preampDb: 0.0,
        bassBoostDb: 0.0,
        bassBoostFrequencyHz: 80.0,
        bassBoostQ: 1.0,
        bandGainsDb: Float32List(10),
      ),
      currentVisualizerOptions: const VisualizerOptimizationOptions(
        frequencyGroups: 100,
      ),
      randomHistory: [demoData.songs[1]],
      randomQueue: [demoData.songs[2], demoData.songs[3]],
      historyCursor: 0,
      deckCursor: 0,
      isVisualizerEnabled: true,
      dynamicStartColor: const Color(0xFF38BDF8),
      dynamicEndColor: const Color(0xFF0F172A),
      isLyricsActive: false,
      sleepTimerRemaining: null,
      sleepTimerDuration: null,
    );

    audioService = MockAudioService(
      snapshot: audioSnapshot,
      artworkBytes: demoData.songs.first.artworkBytes,
      visualizerStream: const Stream.empty(),
    );

    scannerService = MockScannerService(
      rootFolders: [rootFolder],
      metadataMap: demoData.metadataMap,
    );

    playlistService = PlaylistService();
    await playlistService.createPlaylist('Favorites');
    final p = playlistService.playlists.first;
    await playlistService.addSongsToPlaylist(p.id, demoData.songs.take(3).toList());
  });

  Widget createTestWidget({
    required Widget child,
    Size logicalSize = const Size(430, 932),
    Locale locale = const Locale('zh'),
    Brightness brightness = Brightness.dark,
  }) {
    return ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWith((ref) => settingsService),
        audioServiceProvider.overrideWith((ref) => audioService),
        audioSnapshotProvider.overrideWith((ref) => audioSnapshot),
        audioCurrentMusicProvider.overrideWith((ref) => audioSnapshot.currentMusic),
        scannerServiceProvider.overrideWith((ref) => scannerService),
        albumLibraryProvider.overrideWith((ref) => Stream.value(demoData.albums)),
        artistLibraryProvider.overrideWith((ref) => Stream.value(demoArtists)),
        playlistServiceProvider.overrideWith((ref) => playlistService),
        recentlyPlayedSongsProvider.overrideWith((ref, range) => Stream.value(demoInsightEntries)),
        mostPlayedSongsProvider.overrideWith((ref, range) => Stream.value(demoInsightEntries)),
        recentlyAddedSongsProvider.overrideWith((ref, range) => Stream.value(demoInsightEntries)),
        isProUnlockedProvider.overrideWith((ref) => true),
        isEffectiveWaveformEnabledProvider.overrideWith((ref) => true),
      ],
      child: OKToast(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            brightness: brightness,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF38BDF8),
              brightness: brightness,
            ),
          ),
          home: MediaQuery(
            data: MediaQueryData(
              size: logicalSize,
              padding: const EdgeInsets.only(top: 48, bottom: 34),
            ),
            child: SizedBox(
              width: logicalSize.width,
              height: logicalSize.height,
              child: Material(child: child),
            ),
          ),
        ),
      ),
    );
  }

  group('Layout Smoke Tests - Directory / Folders', () {
    testWidgets('FoldersPage - Root View renders without layout errors', (tester) async {
      tester.view.physicalSize = const Size(1290, 2796);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestWidget(child: const FoldersPage()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.byType(FoldersPage), findsOneWidget);
    });

    testWidgets('FoldersPage - Responsive layouts (Phone, Tablet, Desktop)', (tester) async {
      const sizes = [
        Size(390, 844),   // iPhone
        Size(820, 1180),  // iPad
        Size(1280, 800),  // Desktop wide
      ];

      for (final size in sizes) {
        tester.view.physicalSize = size * 2.0;
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(child: const FoldersPage(), logicalSize: size),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('FolderDetailView - renders songs and subfolders without layout errors', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: FolderDetailView(
            folder: rootFolder,
            isSelectionMode: false,
            selectedSongPaths: const {},
            selectedFolderPaths: const {},
            onToggleSelectionMode: () {},
            onToggleFolderSelection: (_) {},
            onToggleSelection: (_) {},
            onSelectAllVisible: () {},
            onClearAllSelection: () {},
            onOpenPlayback: () async {},
            onNavigateTo: (_) {},
            onGoBack: () {},
            onShowFolderBottomSheet: (_, {required isRoot}) {},
            onShowFolderContextMenu: (_, offset, {required isRoot}) {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.byType(FolderDetailView), findsOneWidget);
    });
  });

  group('Layout Smoke Tests - Media Library All Tabs & Switching', () {
    testWidgets('LibraryPage - switches through all 6 tabs without errors', (tester) async {
      tester.view.physicalSize = const Size(1290, 2796);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestWidget(child: const LibraryPage()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      final tabFinder = find.byType(Tab);
      final tabCount = tabFinder.evaluate().length;
      expect(tabCount, 6);

      // Tap through each tab in sequence
      for (int i = 0; i < tabCount; i++) {
        await tester.tap(tabFinder.at(i));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('PlaylistTab - renders playlists and controls', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const SafeArea(child: PlaylistTab())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.byType(PlaylistTab), findsOneWidget);
    });

    testWidgets('RecentlyPlayedTab - renders time range and song entries', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const SafeArea(child: RecentlyPlayedTab())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.byType(RecentlyPlayedTab), findsOneWidget);
    });

    testWidgets('MostPlayedTab - renders ranked items and play counts', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const SafeArea(child: MostPlayedTab())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.byType(MostPlayedTab), findsOneWidget);
    });

    testWidgets('RecentlyAddedTab - renders timeline items', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const SafeArea(child: RecentlyAddedTab())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.byType(RecentlyAddedTab), findsOneWidget);
    });

    testWidgets('AlbumsTab - 2D Grid and 3D Cover Flow modes', (tester) async {
      // 2D Grid mode
      await tester.pumpWidget(
        createTestWidget(child: const SafeArea(child: AlbumsTab(initial3DView: false))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      expect(find.byType(AlbumsTab), findsOneWidget);

      // 3D Cover Flow mode
      await tester.pumpWidget(
        createTestWidget(child: const SafeArea(child: AlbumsTab(initial3DView: true, initial3DIndex: 1))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });

    testWidgets('ArtistsTab - renders artist grid, avatars and search', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const SafeArea(child: ArtistsTab())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.byType(ArtistsTab), findsOneWidget);
    });

    testWidgets('AlbumDetailPage - renders album header and song list', (tester) async {
      final sampleAlbum = demoData.albums.first;
      await tester.pumpWidget(
        createTestWidget(
          child: AlbumDetailPage(album: sampleAlbum),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.byType(AlbumDetailPage), findsOneWidget);
    });

    testWidgets('ArtistDetailPage - renders artist header and grouped sections', (tester) async {
      final sampleArtist = demoArtists.first;
      await tester.pumpWidget(
        createTestWidget(
          child: ArtistDetailPage(artist: sampleArtist),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.byType(ArtistDetailPage), findsOneWidget);
    });
  });

  group('Layout Smoke Tests - Playback Queue Page', () {
    testWidgets('QueuePage - renders normal queue, history, and random queue', (tester) async {
      tester.view.physicalSize = const Size(1290, 2796);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestWidget(child: const QueuePage()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.byType(QueuePage), findsOneWidget);

      // Switch SegmentedButton / Tabs if available
      final segmentFinder = find.byType(SegmentedButton<int>);
      if (segmentFinder.evaluate().isNotEmpty) {
        await tester.tap(segmentFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('QueuePage - Responsive dimensions (Phone, Tablet, Desktop)', (tester) async {
      const testSizes = [
        Size(390, 844),   // Mobile portrait
        Size(820, 1180),  // Tablet portrait
        Size(1280, 800),  // Desktop
      ];

      for (final size in testSizes) {
        tester.view.physicalSize = size * 2.0;
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(child: const QueuePage(), logicalSize: size),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(tester.takeException(), isNull);
      }
    });
  });
}
