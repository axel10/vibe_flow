import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/scanner/scanner_directory_scanner.dart';
import 'package:vynody/player/scanner/scanner_scan_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScannerDirectoryScanner', () {
    test(
      'discoverMusicFilesInDirectory only scans the current directory',
      () async {
        final tempDirectory = await Directory.systemTemp.createTemp(
          'scanner_directory_scanner_test_',
        );

        try {
          final rootSong = File(p.join(tempDirectory.path, 'root-song.mp3'));
          await rootSong.writeAsBytes(List<int>.filled(8, 1));

          final nestedDirectory = Directory(p.join(tempDirectory.path, 'nested'));
          await nestedDirectory.create();

          final nestedSong = File(p.join(nestedDirectory.path, 'nested-song.mp3'));
          await nestedSong.writeAsBytes(List<int>.filled(8, 2));

          final scanner = ScannerDirectoryScanner(emitScanProgress: (_, __) {});
          final scanState = ScanProgressState(
            comparePaths: (a, b) => a.compareTo(b),
          );

          final discovered = await scanner.discoverMusicFilesInDirectory(
            tempDirectory.path,
            scanState,
          );

          final discoveredPaths = discovered.map((f) => f.path).toList();
          expect(discoveredPaths, contains(rootSong.path));
          expect(discoveredPaths, isNot(contains(nestedSong.path)));
          expect(discovered.first.lastModifiedTime, isNotNull);
        } finally {
          if (await tempDirectory.exists()) {
            await tempDirectory.delete(recursive: true);
          }
        }
      },
    );

    test(
      'discoverMusicFiles prevents infinite loops on circular paths/junctions',
      () async {
        final tempDirectory = await Directory.systemTemp.createTemp(
          'scanner_directory_scanner_test_loop_',
        );

        try {
          final rootSong = File(p.join(tempDirectory.path, 'root-song.mp3'));
          await rootSong.writeAsBytes(List<int>.filled(8, 1));

          final nestedDirectory = Directory(p.join(tempDirectory.path, 'nested'));
          await nestedDirectory.create();

          final loopPath = p.join(nestedDirectory.path, 'loop');
          if (Platform.isWindows) {
            // Junction points don't require admin rights on Windows
            final result = await Process.run('cmd', ['/c', 'mklink', '/j', loopPath, tempDirectory.path]);
            if (result.exitCode != 0) {
              try {
                await Link(loopPath).create(tempDirectory.path);
              } catch (_) {
                // Skip if OS environment doesn't allow symbolic link creation
                return;
              }
            }
          } else {
            try {
              await Link(loopPath).create(tempDirectory.path);
            } catch (_) {
              return;
            }
          }

          final scanner = ScannerDirectoryScanner(emitScanProgress: (_, __) {});
          final scanState = ScanProgressState(
            comparePaths: (a, b) => a.compareTo(b),
          );

          // Run recursive discovery. If loop prevention fails, this will hang or stack overflow.
          final discovered = await scanner.discoverMusicFiles(
            tempDirectory.path,
            scanState,
          );

          final discoveredPaths = discovered.map((f) => f.path).toList();
          expect(discoveredPaths, contains(rootSong.path));
          expect(discovered.first.lastModifiedTime, isNotNull);
        } finally {
          // Cleanup Windows junctions correctly first so recursive deletion doesn't delete target files
          final loopDir = Directory(p.join(tempDirectory.path, 'nested', 'loop'));
          if (Platform.isWindows && await loopDir.exists()) {
            await Process.run('cmd', ['/c', 'rmdir', loopDir.path]);
          }
          if (await tempDirectory.exists()) {
            await tempDirectory.delete(recursive: true);
          }
        }
      },
    );
  });
}
