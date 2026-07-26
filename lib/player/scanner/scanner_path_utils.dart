import 'dart:io';

import 'package:path/path.dart' as p;

class ScannerPathUtils {
  static bool isLikelyPackagedWindowsApp() {
    if (!Platform.isWindows) return false;
    try {
      final executablePath = Platform.resolvedExecutable.replaceAll('/', r'\');
      return executablePath.toLowerCase().contains(r'\windowsapps\');
    } catch (_) {
      return false;
    }
  }

  static String normalizePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return trimmed;

    if (Platform.isWindows) {
      if (!trimmed.contains('/') &&
          !trimmed.contains(r'\.\') &&
          !trimmed.contains(r'\..\') &&
          !trimmed.startsWith(r'.\') &&
          !trimmed.startsWith(r'..\')) {
        var s = trimmed;
        if (s.length > 3 && s.endsWith(r'\')) {
          s = s.substring(0, s.length - 1);
        }
        return s;
      }
      var normalized = p.normalize(trimmed).replaceAll('/', r'\');
      if (normalized.length > 3 && normalized.endsWith(r'\')) {
        normalized = normalized.substring(0, normalized.length - 1);
      }
      return normalized;
    } else {
      if (!trimmed.contains('//') &&
          !trimmed.contains('/./') &&
          !trimmed.contains('/../') &&
          !trimmed.startsWith('./') &&
          !trimmed.startsWith('../')) {
        var s = trimmed;
        if (s.length > 1 && s.endsWith('/')) {
          s = s.substring(0, s.length - 1);
        }
        return s;
      }
      var normalized = p.normalize(trimmed);
      if (normalized.length > 1 && normalized.endsWith('/')) {
        normalized = normalized.substring(0, normalized.length - 1);
      }
      return normalized;
    }
  }

  static String pathLookupKey(String path) {
    final normalized = normalizePath(path);
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  static List<String> normalizeDeclaredRootPaths(Iterable<String> paths) {
    final normalizedPaths = paths
        .map(normalizePath)
        .where((path) => path.isNotEmpty)
        .toList();

    final result = <String>[];
    for (final path in normalizedPaths) {
      if (result.any((existing) => pathsEqual(existing, path))) {
        continue;
      }
      result.add(path);
    }

    return result;
  }

  static List<String> computeScanRoots(Iterable<String> paths) {
    final normalizedPaths = normalizeDeclaredRootPaths(paths);
    normalizedPaths.sort((a, b) => a.length.compareTo(b.length));

    final result = <String>[];
    for (final path in normalizedPaths) {
      if (result.any((existing) => pathContains(existing, path))) {
        continue;
      }
      result.add(path);
    }

    return result;
  }

  static bool pathsEqual(String left, String right) {
    final normalizedLeft = normalizePath(left);
    final normalizedRight = normalizePath(right);
    if (Platform.isWindows) {
      return normalizedLeft.toLowerCase() == normalizedRight.toLowerCase();
    }
    return normalizedLeft == normalizedRight;
  }

  static bool pathContains(String parent, String child) {
    final normalizedParent = normalizePath(parent);
    final normalizedChild = normalizePath(child);

    if (pathsEqual(normalizedParent, normalizedChild)) {
      return true;
    }

    if (Platform.isWindows) {
      return p.isWithin(
        normalizedParent.toLowerCase(),
        normalizedChild.toLowerCase(),
      );
    }

    return p.isWithin(normalizedParent, normalizedChild);
  }

  static String displayNameForPath(String path) {
    final normalizedPath = normalizePath(path);
    final basename = p.basename(normalizedPath);
    if (basename.isNotEmpty) return basename;

    if (Platform.isWindows) {
      var drive = p.rootPrefix(normalizedPath);
      if (drive.endsWith(r'\') || drive.endsWith('/')) {
        drive = drive.substring(0, drive.length - 1);
      }
      if (drive.isNotEmpty) return drive;
    }

    return normalizedPath;
  }

  static String cleanDisplayPath(String path) {
    var cleaned = normalizePath(path);
    if (Platform.isIOS) {
      // Clean AppGroup path: /private/var/mobile/Containers/Shared/AppGroup/UUID/ -> AppGroup/
      cleaned = cleaned.replaceFirst(
        RegExp(r'^/(private/)?var/mobile/Containers/Shared/AppGroup/[^/]+/'),
        'AppGroup/',
      );
      // Clean Application Documents path: /private/var/mobile/Containers/Data/Application/UUID/Documents/ -> Documents/
      cleaned = cleaned.replaceFirst(
        RegExp(r'^/(private/)?var/mobile/Containers/Data/Application/[^/]+/Documents/'),
        'Documents/',
      );
      // Clean Application Library path: /private/var/mobile/Containers/Data/Application/UUID/Library/ -> Library/
      cleaned = cleaned.replaceFirst(
        RegExp(r'^/(private/)?var/mobile/Containers/Data/Application/[^/]+/Library/'),
        'Library/',
      );
      // Clean general Containers path: /private/var/mobile/Containers/Type/UUID/ -> Container/
      cleaned = cleaned.replaceFirst(
        RegExp(r'^/(private/)?var/mobile/Containers/[^/]+/[^/]+/'),
        'Container/',
      );
    }
    return cleaned;
  }
}

