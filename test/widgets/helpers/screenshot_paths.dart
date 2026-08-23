import 'dart:io';

/// Centralized configuration and path generator for screenshot test outputs.
class ScreenshotPaths {
  /// Root directory for all generated screenshots and store posters.
  static const String baseDir = '/Volumes/Untitled/projects/vibe_flow/screenshots';

  /// Generates a relative path for a raw device/window screenshot.
  /// Example: ScreenshotPaths.raw('ios_screen_01_playback.png', lang: 'zh') -> 'raw/zh/ios_screen_01_playback.png'
  static String raw(String filename, {String lang = 'zh'}) => 'raw/$lang/$filename';

  /// Generates a relative path for a finished store poster screenshot.
  /// Example: ScreenshotPaths.store('ios_store_01_playback.png', lang: 'zh') -> 'store/zh/ios_store_01_playback.png'
  static String store(String filename, {String lang = 'zh'}) => 'store/$lang/$filename';

  /// Resolves relative or absolute path against [baseDir] and returns a [File].
  static File resolve(String pathOrFilename) {
    if (pathOrFilename.startsWith('/') || pathOrFilename.contains(':\\')) {
      return File(pathOrFilename);
    }
    return File('$baseDir/$pathOrFilename');
  }
}
