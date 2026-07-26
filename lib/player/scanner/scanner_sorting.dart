import 'package:collection/collection.dart';

import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';

enum SortCriteria { title, filename, trackNumber }

enum SortOrder { ascending, descending }

enum SortScope { global, currentFolder }

extension SortCriteriaX on SortCriteria {
  String get storageValue => switch (this) {
    SortCriteria.title => 'title',
    SortCriteria.filename => 'filename',
    SortCriteria.trackNumber => 'track_number',
  };

  static SortCriteria fromStorageValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'title':
        return SortCriteria.title;
      case 'track_number':
      case 'tracknumber':
        return SortCriteria.trackNumber;
      case 'filename':
      default:
        return SortCriteria.filename;
    }
  }
}

extension SortOrderX on SortOrder {
  String get storageValue => switch (this) {
    SortOrder.ascending => 'ascending',
    SortOrder.descending => 'descending',
  };

  static SortOrder fromStorageValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'descending':
        return SortOrder.descending;
      case 'ascending':
      default:
        return SortOrder.ascending;
    }
  }
}

extension SortScopeX on SortScope {
  String get storageValue => switch (this) {
    SortScope.global => 'global',
    SortScope.currentFolder => 'current_folder',
  };

  static SortScope fromStorageValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'current_folder':
      case 'currentfolder':
        return SortScope.currentFolder;
      case 'global':
      default:
        return SortScope.global;
    }
  }
}

class FolderSortSettings {
  const FolderSortSettings({required this.criteria, required this.order});

  final SortCriteria criteria;
  final SortOrder order;

  FolderSortSettings copyWith({SortCriteria? criteria, SortOrder? order}) {
    return FolderSortSettings(
      criteria: criteria ?? this.criteria,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {'criteria': criteria.storageValue, 'order': order.storageValue};
  }

  factory FolderSortSettings.fromJson(Map<String, dynamic> json) {
    return FolderSortSettings(
      criteria: SortCriteriaX.fromStorageValue(json['criteria'] as String?),
      order: SortOrderX.fromStorageValue(json['order'] as String?),
    );
  }
}

class ScannerFolderSorter {
  const ScannerFolderSorter();

  void sortFolders(
    List<MusicFolder> folders, {
    required SortCriteria criteria,
    required SortOrder order,
  }) {
    final folderComparator = _folderComparator(
      criteria: criteria,
      order: order,
    );
    folders.sort(folderComparator);
    for (final folder in folders) {
      sortFolderRecursive(folder, criteria: criteria, order: order);
    }
  }

  void sortFoldersForTree(
    List<MusicFolder> folders, {
    required FolderSortSettings Function(String path) resolveSettings,
  }) {
    folders.sort((a, b) => _compareNaturally(a.name, b.name));
    for (final folder in folders) {
      sortFolderRecursiveForTree(folder, resolveSettings: resolveSettings);
    }
  }

  void sortSpecificFolders(
    Iterable<MusicFolder> folders, {
    required FolderSortSettings Function(String path) resolveSettings,
  }) {
    for (final folder in folders) {
      final settings = resolveSettings(folder.path);
      folder.subFolders.sort(
        _folderComparator(criteria: settings.criteria, order: settings.order),
      );
      final comparator = _comparatorFor(
        criteria: settings.criteria,
        order: settings.order,
      );
      folder.files.sort(comparator);
    }
  }

  void sortFolderRecursive(
    MusicFolder folder, {
    required SortCriteria criteria,
    required SortOrder order,
  }) {
    folder.subFolders.sort(_folderComparator(criteria: criteria, order: order));

    int Function(MusicFile, MusicFile) comparator;

    switch (criteria) {
      case SortCriteria.title:
        comparator = (a, b) => _compareNaturally(a.displayName, b.displayName);
        break;
      case SortCriteria.filename:
        comparator = (a, b) => _compareNaturally(a.name, b.name);
        break;
      case SortCriteria.trackNumber:
        comparator = (a, b) {
          if (a.trackNumber != null && b.trackNumber != null) {
            return a.trackNumber!.compareTo(b.trackNumber!);
          }
          if (a.trackNumber != null) return -1;
          if (b.trackNumber != null) return 1;
          return _compareNaturally(a.name, b.name);
        };
        break;
    }

    if (order == SortOrder.descending) {
      final baseComparator = comparator;
      comparator = (a, b) => baseComparator(b, a);
    }

    folder.files.sort(comparator);

    for (final subFolder in folder.subFolders) {
      sortFolderRecursive(subFolder, criteria: criteria, order: order);
    }
  }

  void sortFolderRecursiveForTree(
    MusicFolder folder, {
    required FolderSortSettings Function(String path) resolveSettings,
  }) {
    final settings = resolveSettings(folder.path);
    folder.subFolders.sort(
      _folderComparator(criteria: settings.criteria, order: settings.order),
    );
    final comparator = _comparatorFor(
      criteria: settings.criteria,
      order: settings.order,
    );
    folder.files.sort(comparator);

    for (final subFolder in folder.subFolders) {
      sortFolderRecursiveForTree(subFolder, resolveSettings: resolveSettings);
    }
  }

  int Function(MusicFile, MusicFile) _comparatorFor({
    required SortCriteria criteria,
    required SortOrder order,
  }) {
    int Function(MusicFile, MusicFile) comparator;

    switch (criteria) {
      case SortCriteria.title:
        comparator = (a, b) => _compareNaturally(a.displayName, b.displayName);
        break;
      case SortCriteria.filename:
        comparator = (a, b) => _compareNaturally(a.name, b.name);
        break;
      case SortCriteria.trackNumber:
        comparator = (a, b) {
          if (a.trackNumber != null && b.trackNumber != null) {
            return a.trackNumber!.compareTo(b.trackNumber!);
          }
          if (a.trackNumber != null) return -1;
          if (b.trackNumber != null) return 1;
          return _compareNaturally(a.name, b.name);
        };
        break;
    }

    if (order == SortOrder.descending) {
      final baseComparator = comparator;
      comparator = (a, b) => baseComparator(b, a);
    }

    return comparator;
  }

  int Function(MusicFolder, MusicFolder) _folderComparator({
    required SortCriteria criteria,
    required SortOrder order,
  }) {
    int Function(MusicFolder, MusicFolder) comparator = (a, b) {
      return _compareNaturally(a.name, b.name);
    };

    if (order == SortOrder.descending) {
      final baseComparator = comparator;
      comparator = (a, b) => baseComparator(b, a);
    }

    return comparator;
  }

  int _compareNaturally(String left, String right) {
    if (identical(left, right) || left == right) return 0;
    return compareNatural(left.toLowerCase(), right.toLowerCase());
  }
}
