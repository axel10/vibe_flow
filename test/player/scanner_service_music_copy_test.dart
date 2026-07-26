import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/pages/folder_page.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/audio/audio_service.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/scanner/scanner_service.dart';
import 'package:vynody/player/scanner/scanner_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScannerService', () {
    late Directory supportDirectory;

    setUpAll(() async {
      supportDirectory = await Directory.systemTemp.createTemp(
        'scanner_service_music_copy_test_',
      );
      PathProviderPlatform.instance = _TestPathProviderPlatform(
        supportPath: supportDirectory.path,
      );
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await MetadataDatabase().clearAll();
    });

    tearDownAll(() async {
      try {
        if (await supportDirectory.exists()) {
          await supportDirectory.delete(recursive: true);
        }
      } catch (_) {}
    });

    test(
      'should keep current folder and show copied song after incremental sync',
      () async {
        const rootPath = '/Users/axel10/Music';
        final rootDirectory = Directory(rootPath);
        if (!await rootDirectory.exists()) {
          return;
        }

        final scanner = ScannerService(
          autoInitialize: false,
          directoryRescanBatchWindow: const Duration(milliseconds: 80),
        );
        final notifications = <DateTime>[];
        scanner.addListener(() {
          notifications.add(DateTime.now());
        });

        File? copiedFile;
        try {
          final addResult = await scanner.addRootPath(rootPath);
          expect(addResult.status, RootPathAddStatus.added);

          await _waitUntil(
            () =>
                scanner.runtimeState.phase == ScanPhase.scanningArtwork &&
                _firstFolderWithFiles(scanner.rootFolders) != null,
            reason: 'waiting for stage 3 root tree refresh before copy test',
          );
          await _pumpEventQueue();

          final targetFolder = _firstFolderWithFiles(scanner.rootFolders);
          expect(targetFolder, isNotNull);

          final currentFolder = targetFolder!;
          final sourceSong = currentFolder.files.first;
          final initialFileCount = currentFolder.files.length;
          final initialNotificationCount = notifications.length;

          scanner.setNavigationState(currentFolder, <MusicFolder>[]);
          expect(scanner.navigationCurrentFolder?.path, currentFolder.path);

          copiedFile = await _copySongWithinSameDirectory(sourceSong.path);

          await _waitUntil(() {
            final refreshed = scanner.navigationCurrentFolder;
            if (refreshed == null) {
              return false;
            }
            return refreshed.path == currentFolder.path &&
                refreshed.files.any((file) => file.path == copiedFile!.path) &&
                refreshed.files.length == initialFileCount + 1;
          }, reason: 'waiting for copied song to appear in current folder');

          expect(scanner.navigationCurrentFolder, isNotNull);
          expect(scanner.navigationCurrentFolder!.path, currentFolder.path);
          expect(
            scanner.navigationCurrentFolder!.files.any(
              (file) => file.path == copiedFile!.path,
            ),
            isTrue,
          );
          expect(
            scanner.navigationCurrentFolder!.files.length,
            initialFileCount + 1,
          );
          expect(notifications.length, greaterThan(initialNotificationCount));
        } finally {
          if (copiedFile != null && await copiedFile.exists()) {
            await copiedFile.delete();
          }
          scanner.dispose();
        }
      },
      skip: !Platform.environment.containsKey(
        'RUN_SCANNER_SERVICE_MUSIC_COPY_TEST',
      ),
    );

    testWidgets(
      'should show copied song within three seconds without scan toast',
      (tester) async {
        const rootPath = '/Users/axel10/Music';
        if (!await Directory(rootPath).exists()) {
          return;
        }

        final scanner = ScannerService(
          autoInitialize: false,
          directoryRescanBatchWindow: const Duration(milliseconds: 80),
        );

        File? copiedFile;
        try {
          await tester.pumpWidget(_buildFoldersPageTestApp(scanner));

          final addResult = await scanner.addRootPath(rootPath);
          expect(addResult.status, RootPathAddStatus.added);

          await _pumpUntil(
            tester,
            () =>
                scanner.runtimeState.phase == ScanPhase.scanningArtwork &&
                _findFolderWithUniqueSongDisplayName(scanner.rootFolders) !=
                    null,
            reason: 'waiting for stage 3 widget tree refresh before add test',
            timeout: const Duration(seconds: 20),
          );

          await tester.pump();

          final target = _findFolderWithUniqueSongDisplayName(
            scanner.rootFolders,
          );
          expect(target, isNotNull);

          final folder = target!.$1;
          final sourceSong = target.$2;

          scanner.setNavigationState(folder, <MusicFolder>[]);
          await tester.pumpAndSettle();

          expect(find.text(sourceSong.displayName), findsOneWidget);

          copiedFile = await _copySongWithinSameDirectory(sourceSong.path);

          final stopwatch = Stopwatch()..start();
          var copiedSongVisible = false;
          var scanToastVisible = false;

          while (stopwatch.elapsed <= const Duration(seconds: 3)) {
            await tester.pump(const Duration(milliseconds: 100));

            if (find.text('Scanning directory...').evaluate().isNotEmpty) {
              scanToastVisible = true;
            }

            final currentFolder = scanner.navigationCurrentFolder;
            final copiedInService =
                currentFolder != null &&
                currentFolder.files.any(
                  (file) => file.path == copiedFile!.path,
                );
            final duplicateTitleCount = find
                .text(sourceSong.displayName)
                .evaluate()
                .length;

            if (copiedInService && duplicateTitleCount >= 2) {
              copiedSongVisible = true;
              break;
            }
          }

          expect(
            copiedSongVisible,
            isTrue,
            reason: 'copied song should be visible in UI within three seconds',
          );
          expect(
            stopwatch.elapsed,
            lessThanOrEqualTo(const Duration(seconds: 3)),
          );
          expect(
            scanToastVisible,
            isFalse,
            reason: 'incremental add should not show scan toast in UI',
          );
          expect(find.text('Scanning directory...'), findsNothing);
        } finally {
          if (copiedFile != null && await copiedFile.exists()) {
            await copiedFile.delete();
          }
          scanner.dispose();
        }
      },
      skip: !Platform.environment.containsKey(
        'RUN_SCANNER_SERVICE_MUSIC_COPY_TEST',
      ),
    );

    testWidgets(
      'should remove deleted copied song from UI after incremental sync',
      (tester) async {
        const rootPath = '/Users/axel10/Music';
        if (!await Directory(rootPath).exists()) {
          return;
        }

        final scanner = ScannerService(
          autoInitialize: false,
          directoryRescanBatchWindow: const Duration(milliseconds: 80),
        );

        File? copiedFile;
        try {
          await tester.pumpWidget(_buildFoldersPageTestApp(scanner));

          final addResult = await scanner.addRootPath(rootPath);
          expect(addResult.status, RootPathAddStatus.added);

          await _pumpUntil(
            tester,
            () =>
                scanner.runtimeState.phase == ScanPhase.scanningArtwork &&
                _findFolderWithUniqueSongDisplayName(scanner.rootFolders) !=
                    null,
            reason:
                'waiting for stage 3 widget tree refresh before delete test',
            timeout: const Duration(seconds: 20),
          );

          final target = _findFolderWithUniqueSongDisplayName(
            scanner.rootFolders,
          );
          expect(target, isNotNull);

          final folder = target!.$1;
          final sourceSong = target.$2;

          scanner.setNavigationState(folder, <MusicFolder>[]);
          await tester.pumpAndSettle();
          expect(find.text(sourceSong.displayName), findsOneWidget);

          copiedFile = await _copySongWithinSameDirectory(sourceSong.path);

          await _pumpUntil(tester, () {
            final currentFolder = scanner.navigationCurrentFolder;
            final copiedInService =
                currentFolder != null &&
                currentFolder.files.any(
                  (file) => file.path == copiedFile!.path,
                );
            final duplicateTitleCount = find
                .text(sourceSong.displayName)
                .evaluate()
                .length;
            return copiedInService && duplicateTitleCount >= 2;
          }, reason: 'waiting for copied song to appear before delete');

          await copiedFile.delete();

          await _pumpUntil(tester, () {
            final currentFolder = scanner.navigationCurrentFolder;
            final copiedStillInService =
                currentFolder != null &&
                currentFolder.files.any(
                  (file) => file.path == copiedFile!.path,
                );
            final remainingTitleCount = find
                .text(sourceSong.displayName)
                .evaluate()
                .length;
            return !copiedStillInService && remainingTitleCount == 1;
          }, reason: 'waiting for deleted copied song to disappear from UI');

          expect(
            scanner.navigationCurrentFolder?.files.any(
              (file) => file.path == copiedFile!.path,
            ),
            isFalse,
          );
          expect(find.text(sourceSong.displayName), findsOneWidget);
        } finally {
          if (copiedFile != null && await copiedFile.exists()) {
            await copiedFile.delete();
          }
          scanner.dispose();
        }
      },
      skip: !Platform.environment.containsKey(
        'RUN_SCANNER_SERVICE_MUSIC_COPY_TEST',
      ),
    );

    test(
      'should remove a deleted directory subtree after delayed rescan',
      () async {
        final tempRoot = await Directory.systemTemp.createTemp(
          'scanner_service_directory_rescan_test_',
        );
        final nestedDirectory = Directory(p.join(tempRoot.path, 'nested'));
        final nestedSong = File(p.join(nestedDirectory.path, 'song.mp3'));

        try {
          await nestedDirectory.create(recursive: true);
          await nestedSong.writeAsBytes(List<int>.filled(8, 3));

          final scanner = ScannerService(
            autoInitialize: false,
            directoryRescanBatchWindow: const Duration(milliseconds: 80),
          );

          try {
            final addResult = await scanner.addRootPath(tempRoot.path);
            expect(addResult.status, RootPathAddStatus.added);

            await _waitUntil(
              () => _folderContainsPath(scanner.rootFolders, nestedSong.path),
              reason: 'waiting for nested song to be indexed',
            );

            await nestedDirectory.delete(recursive: true);

            await _waitUntil(
              () => !_folderContainsPath(scanner.rootFolders, nestedSong.path),
              reason: 'waiting for deleted directory subtree to disappear',
            );
          } finally {
            scanner.dispose();
          }
        } finally {
          if (await tempRoot.exists()) {
            await tempRoot.delete(recursive: true);
          }
        }
      },
    );

    test(
      'should discover a new nested directory after recursive rescan',
      () async {
        final tempRoot = await Directory.systemTemp.createTemp(
          'scanner_service_directory_recursive_add_test_',
        );
        final rootSong = File(p.join(tempRoot.path, 'root-song.mp3'));
        final nestedDirectory = Directory(p.join(tempRoot.path, 'nested'));
        final nestedSong = File(p.join(nestedDirectory.path, 'song.mp3'));

        try {
          await rootSong.writeAsBytes(List<int>.filled(8, 1));

          final scanner = ScannerService(
            autoInitialize: false,
            directoryRescanBatchWindow: const Duration(milliseconds: 80),
          );

          try {
            final addResult = await scanner.addRootPath(tempRoot.path);
            expect(addResult.status, RootPathAddStatus.added);

            await _waitUntil(
              () => _folderContainsPath(scanner.rootFolders, rootSong.path),
              reason: 'waiting for root song to be indexed',
            );

            await nestedDirectory.create(recursive: true);
            await nestedSong.writeAsBytes(List<int>.filled(8, 2));

            await _waitUntil(
              () => _folderContainsPath(scanner.rootFolders, nestedSong.path),
              reason: 'waiting for nested directory song to be discovered',
            );
          } finally {
            scanner.dispose();
          }
        } finally {
          if (await tempRoot.exists()) {
            await tempRoot.delete(recursive: true);
          }
        }
      },
    );
  });
}

MusicFolder? _firstFolderWithFiles(Iterable<MusicFolder> folders) {
  for (final folder in folders) {
    if (folder.files.isNotEmpty) {
      return folder;
    }
    final nested = _firstFolderWithFiles(folder.subFolders);
    if (nested != null) {
      return nested;
    }
  }
  return null;
}

bool _folderContainsPath(Iterable<MusicFolder> folders, String path) {
  for (final folder in folders) {
    if (folder.path == path) {
      return true;
    }
    if (folder.files.any((file) => file.path == path)) {
      return true;
    }
    if (_folderContainsPath(folder.subFolders, path)) {
      return true;
    }
  }
  return false;
}

Future<File> _copySongWithinSameDirectory(String sourcePath) async {
  final sourceFile = File(sourcePath);
  final directory = sourceFile.parent.path;
  final baseName = p.basenameWithoutExtension(sourcePath);
  final extension = p.extension(sourcePath);
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final destinationPath = p.join(
    directory,
    '${baseName}__scanner_copy_test__$timestamp$extension',
  );
  return sourceFile.copy(destinationPath);
}

Future<void> _waitUntil(
  bool Function() condition, {
  required String reason,
  Duration timeout = const Duration(seconds: 45),
  Duration pollInterval = const Duration(milliseconds: 200),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(pollInterval);
  }
  fail('Timed out while $reason');
}

Future<void> _pumpEventQueue() async {
  await Future<void>.delayed(const Duration(milliseconds: 50));
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  required String reason,
  Duration timeout = const Duration(seconds: 45),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed <= timeout) {
    await tester.pump(step);
    if (condition()) {
      return;
    }
  }
  fail('Timed out while $reason');
}

(MusicFolder, MusicFile)? _findFolderWithUniqueSongDisplayName(
  Iterable<MusicFolder> folders,
) {
  for (final folder in folders) {
    if (folder.subFolders.isEmpty && folder.files.isNotEmpty) {
      final counts = <String, int>{};
      for (final file in folder.files) {
        counts.update(
          file.displayName,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
      if (folder.files.length <= 20) {
        for (final file in folder.files) {
          if (counts[file.displayName] == 1) {
            return (folder, file);
          }
        }
      }
    }
    final nested = _findFolderWithUniqueSongDisplayName(folder.subFolders);
    if (nested != null) {
      return nested;
    }
  }
  return null;
}

Widget _buildFoldersPageTestApp(ScannerService scanner) {
  return ProviderScope(
    overrides: [
      scannerServiceProvider.overrideWith((ref) => scanner),
      audioServiceProvider.overrideWith((ref) => _FakeAudioService()),
      audioCurrentMusicProvider.overrideWith((ref) => null),
    ],
    child: OKToast(
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: FoldersPage()),
      ),
    ),
  );
}

class _TestPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _TestPathProviderPlatform({required this.supportPath});

  final String supportPath;

  @override
  Future<String?> getApplicationSupportPath() async => supportPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => supportPath;

  @override
  Future<String?> getTemporaryPath() async => supportPath;

  @override
  Future<String?> getLibraryPath() async => supportPath;
}

class _FakeAudioService extends AudioService {}
