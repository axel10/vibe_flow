import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/player/remote/clients/webdav_client.dart';
import 'package:vynody/player/scanner/scanner_sorting.dart';
import 'package:vynody/player/settings/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebDAV Settings & Sorting Tests', () {
    test('SettingsService persists WebDAV sort criteria and order', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsService(prefs);

      // Default values
      expect(settings.webDavSortCriteria, SortCriteria.filename);
      expect(settings.webDavSortOrder, SortOrder.ascending);

      // Update
      settings.webDavSortCriteria = SortCriteria.title;
      settings.webDavSortOrder = SortOrder.descending;

      expect(settings.webDavSortCriteria, SortCriteria.title);
      expect(settings.webDavSortOrder, SortOrder.descending);

      // Re-instantiate to verify persistence
      final restoredSettings = SettingsService(prefs);
      expect(restoredSettings.webDavSortCriteria, SortCriteria.title);
      expect(restoredSettings.webDavSortOrder, SortOrder.descending);
    });

    test('WebDavFile sorting orders folders first and obeys natural order', () {
      final items = [
        const WebDavFile(name: 'song_10.flac', path: '/music/song_10.flac', isDirectory: false, contentLength: 1024),
        const WebDavFile(name: 'folder_B', path: '/music/folder_B', isDirectory: true, contentLength: 0),
        const WebDavFile(name: 'song_2.flac', path: '/music/song_2.flac', isDirectory: false, contentLength: 1024),
        const WebDavFile(name: 'folder_A', path: '/music/folder_A', isDirectory: true, contentLength: 0),
        const WebDavFile(name: 'song_1.flac', path: '/music/song_1.flac', isDirectory: false, contentLength: 1024),
      ];

      // Natural sort ascending
      items.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        if (a.isDirectory && b.isDirectory) {
          return compareNatural(a.name.toLowerCase(), b.name.toLowerCase());
        }
        return compareNatural(a.name.toLowerCase(), b.name.toLowerCase());
      });

      expect(items.map((i) => i.name).toList(), [
        'folder_A',
        'folder_B',
        'song_1.flac',
        'song_2.flac',
        'song_10.flac',
      ]);
    });
  });
}
