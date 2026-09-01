import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';

/// Single track entry parsed from an M3U file
class M3uEntry {
  final String path;
  final String? title;
  final String? artist;
  final int? durationMillis;

  const M3uEntry({
    required this.path,
    this.title,
    this.artist,
    this.durationMillis,
  });
}

/// Parsed M3U playlist data containing name and track entries
class M3uPlaylistData {
  final String? playlistName;
  final List<M3uEntry> entries;

  const M3uPlaylistData({
    this.playlistName,
    required this.entries,
  });
}

/// Helper class for M3U / M3U8 import, export and resolution
class M3uUtils {
  M3uUtils._();

  /// Parse M3U / M3U8 content into [M3uPlaylistData].
  ///
  /// If [baseDir] is provided, relative paths in the M3U will be resolved relative to [baseDir].
  static M3uPlaylistData parse(String content, {String? baseDir}) {
    String? playlistName;
    final entries = <M3uEntry>[];

    // Strip UTF-8 BOM if present
    String cleaned = content;
    if (cleaned.startsWith('\uFEFF')) {
      cleaned = cleaned.substring(1);
    }

    final lines = cleaned.split(RegExp(r'\r?\n'));

    int? pendingDurationMillis;
    String? pendingArtist;
    String? pendingTitle;

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#')) {
        // Parse #PLAYLIST: or #EXT-X-PLAYLIST-NAME:
        if (line.toUpperCase().startsWith('#PLAYLIST:')) {
          playlistName = line.substring('#PLAYLIST:'.length).trim();
          continue;
        }
        if (line.toUpperCase().startsWith('#EXT-X-PLAYLIST-NAME:')) {
          playlistName = line.substring('#EXT-X-PLAYLIST-NAME:'.length).trim();
          continue;
        }

        // Parse #EXTINF:<seconds>,[Artist - ]Title
        if (line.toUpperCase().startsWith('#EXTINF:')) {
          final extinfContent = line.substring('#EXTINF:'.length).trim();
          final commaIndex = extinfContent.indexOf(',');
          if (commaIndex != -1) {
            final durationStr = extinfContent.substring(0, commaIndex).trim();
            final infoStr = extinfContent.substring(commaIndex + 1).trim();

            final seconds = double.tryParse(durationStr);
            if (seconds != null && seconds > 0) {
              pendingDurationMillis = (seconds * 1000).round();
            } else {
              pendingDurationMillis = null;
            }

            if (infoStr.isNotEmpty) {
              final separatorIndex = infoStr.indexOf(' - ');
              if (separatorIndex != -1) {
                pendingArtist = infoStr.substring(0, separatorIndex).trim();
                pendingTitle = infoStr.substring(separatorIndex + 3).trim();
              } else {
                pendingArtist = null;
                pendingTitle = infoStr;
              }
            }
          }
          continue;
        }

        // Other comments / tags are ignored
        continue;
      }

      // Track file path line
      String trackPath = line;
      // Strip wrapping quotes if any
      if ((trackPath.startsWith('"') && trackPath.endsWith('"')) ||
          (trackPath.startsWith("'") && trackPath.endsWith("'"))) {
        trackPath = trackPath.substring(1, trackPath.length - 1);
      }

      // Check if it's a file:// URI
      if (trackPath.startsWith('file://')) {
        try {
          final uri = Uri.parse(trackPath);
          trackPath = uri.toFilePath();
        } catch (_) {
          // If toFilePath fails, strip file:// and decode
          trackPath = Uri.decodeFull(trackPath.replaceFirst('file://', ''));
        }
      }

      // Check if relative path (and not a remote URI)
      if (!RemoteMediaResolver.isRemoteUri(trackPath)) {
        if (!p.isAbsolute(trackPath) && baseDir != null && baseDir.isNotEmpty) {
          trackPath = p.normalize(p.join(baseDir, trackPath));
        } else {
          trackPath = p.normalize(trackPath);
        }
      }

      entries.add(
        M3uEntry(
          path: trackPath,
          title: pendingTitle,
          artist: pendingArtist,
          durationMillis: pendingDurationMillis,
        ),
      );

      // Reset pending metadata for next track
      pendingDurationMillis = null;
      pendingArtist = null;
      pendingTitle = null;
    }

    return M3uPlaylistData(
      playlistName: playlistName,
      entries: entries,
    );
  }

  /// Generate Extended M3U8 string content from song list and optional playlist name
  static String generate(List<MusicFile> songs, {String? playlistName}) {
    final buffer = StringBuffer();
    buffer.writeln('#EXTM3U');
    if (playlistName != null && playlistName.trim().isNotEmpty) {
      buffer.writeln('#PLAYLIST:${playlistName.trim()}');
    }

    for (final song in songs) {
      final durationSec = (song.durationMillis != null && song.durationMillis! > 0)
          ? (song.durationMillis! / 1000).round()
          : -1;
      final title = song.title?.trim().isNotEmpty == true
          ? song.title!.trim()
          : song.name;
      final artist = song.artist?.trim();
      final info = (artist != null && artist.isNotEmpty)
          ? '$artist - $title'
          : title;

      buffer.writeln('#EXTINF:$durationSec,$info');
      buffer.writeln(song.path);
    }

    return buffer.toString();
  }

  /// Resolve a list of [M3uEntry] items to [MusicFile] models, looking up rich metadata
  /// from local [MetadataDatabase] when available.
  static Future<List<MusicFile>> resolveMusicFiles(
    List<M3uEntry> entries,
  ) async {
    if (entries.isEmpty) return [];

    final paths = entries.map((e) => e.path).toList();
    final db = MetadataDatabase();
    Map<String, SongMetadata> metadataMap = {};

    try {
      metadataMap = await db.getSongMetadataByPaths(paths);
    } catch (e) {
      // Fallback if query fails
    }

    final result = <MusicFile>[];

    for (final entry in entries) {
      final metadata = metadataMap[entry.path];
      final isRemote = RemoteMediaResolver.isRemoteUri(entry.path);
      final exists = isRemote || File(entry.path).existsSync();

      if (metadata != null) {
        final title = metadata.title.trim().isNotEmpty
            ? metadata.title
            : (entry.title ?? p.basenameWithoutExtension(metadata.path));
        final artist = metadata.artist.trim().isNotEmpty
            ? metadata.artist
            : entry.artist;

        result.add(
          MusicFile(
            path: metadata.path,
            name: p.basename(metadata.path),
            title: title,
            artist: artist,
            albumArtist: metadata.albumArtist,
            album: metadata.album,
            trackNumber: metadata.trackNumber,
            durationMillis: metadata.duration ?? entry.durationMillis,
            id: metadata.id,
            thumbnailPath: metadata.thumbnailPath,
            artworkPath: metadata.artworkPath,
            artworkWidth: metadata.artworkWidth,
            artworkHeight: metadata.artworkHeight,
            themeColorsBlob: metadata.themeColorsBlob,
            lastModifiedTime: metadata.lastModifiedTime,
            isMissing: !exists,
          ),
        );
      } else {
        final fileName = p.basename(entry.path);
        final title = (entry.title != null && entry.title!.trim().isNotEmpty)
            ? entry.title!.trim()
            : p.basenameWithoutExtension(entry.path);

        result.add(
          MusicFile(
            path: entry.path,
            name: fileName.isNotEmpty ? fileName : entry.path,
            title: title,
            artist: entry.artist,
            durationMillis: entry.durationMillis,
            isMissing: !exists,
          ),
        );
      }
    }

    return result;
  }
}
