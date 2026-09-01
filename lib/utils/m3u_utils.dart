import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/remote_server_storage.dart';
import 'package:vynody/player/scanner/scanner_path_utils.dart';

/// Single track entry parsed from an M3U file
class M3uEntry {
  final String path;
  final String? rawPath;
  final String? title;
  final String? artist;
  final int? durationMillis;

  const M3uEntry({
    required this.path,
    this.rawPath,
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

      final originalRawPath = trackPath;

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
          rawPath: originalRawPath,
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

  /// Generate Extended M3U8 string content from song list and optional playlist name.
  ///
  /// Local songs within [rootPaths] will be exported as relative paths normalized with `/`.
  /// If [baseDir] is specified and the song is located inside [baseDir], relative path will be used.
  /// WebDAV songs will be exported with cross-platform URI format.
  static String generate(
    List<MusicFile> songs, {
    String? playlistName,
    Iterable<String>? rootPaths,
    String? baseDir,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('#EXTM3U');
    if (playlistName != null && playlistName.trim().isNotEmpty) {
      buffer.writeln('#PLAYLIST:${playlistName.trim()}');
    }

    final normalizedRoots = rootPaths != null
        ? ScannerPathUtils.normalizeDeclaredRootPaths(rootPaths)
        : <String>[];

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

      String exportPath = song.path;

      if (RemoteMediaResolver.isRemoteUri(song.path)) {
        if (song.path.startsWith('webdav://')) {
          final uriInfo = RemoteMediaResolver.parseUri(song.path);
          if (uriInfo != null) {
            final rel = uriInfo.trackIdOrPath.startsWith('/')
                ? uriInfo.trackIdOrPath.substring(1)
                : uriInfo.trackIdOrPath;
            exportPath = 'webdav:///$rel';
          }
        }
      } else {
        // Local song: check scan roots first
        bool convertedToRelative = false;
        for (final root in normalizedRoots) {
          if (ScannerPathUtils.pathContains(root, song.path)) {
            final rel = p.relative(song.path, from: root).replaceAll('\\', '/');
            exportPath = rel;
            convertedToRelative = true;
            break;
          }
        }

        if (!convertedToRelative && baseDir != null && baseDir.isNotEmpty) {
          if (ScannerPathUtils.pathContains(baseDir, song.path)) {
            exportPath = p.relative(song.path, from: baseDir).replaceAll('\\', '/');
            convertedToRelative = true;
          }
        }

        if (!convertedToRelative) {
          exportPath = song.path.replaceAll('\\', '/');
        }
      }

      buffer.writeln(exportPath);
    }

    return buffer.toString();
  }

  /// Resolve a list of [M3uEntry] items to [MusicFile] models using a multi-stage
  /// cross-platform matching strategy:
  ///
  /// 1. Direct local file or existing remote virtual URI in DB.
  /// 2. Scan directories (local roots) via relative path joining and right-to-left subpath matching.
  /// 3. Configured remote servers (WebDAV & Subsonic) via virtual URI rewriting.
  /// 4. Database search by path suffix, filename, or Title + Artist.
  /// 5. Missing fallback preserving all available metadata.
  static Future<List<MusicFile>> resolveMusicFiles(
    List<M3uEntry> entries, {
    Iterable<String>? rootPaths,
    List<RemoteServer>? remoteServers,
    MetadataDatabase? db,
  }) async {
    if (entries.isEmpty) return [];

    final targetDb = db ?? MetadataDatabase();

    // 1. Load scan roots if not provided
    List<String> effectiveRoots = [];
    if (rootPaths != null) {
      effectiveRoots = ScannerPathUtils.normalizeDeclaredRootPaths(rootPaths);
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedRoots = prefs.getStringList('root_paths') ?? [];
        effectiveRoots = ScannerPathUtils.normalizeDeclaredRootPaths(savedRoots);
      } catch (_) {}
    }

    // 2. Load remote servers if not provided
    List<RemoteServer> effectiveServers = [];
    if (remoteServers != null) {
      effectiveServers = remoteServers;
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final storage = RemoteServerStorage(prefs: prefs);
        effectiveServers = storage.loadServers();
      } catch (_) {}
    }
    final webdavServers =
        effectiveServers.where((s) => s.type == RemoteServerType.webdav).toList();
    final subsonicServers =
        effectiveServers.where((s) => s.type == RemoteServerType.subsonic).toList();

    // 3. Batch query direct paths
    final directPaths = entries.map((e) => e.path).toList();
    Map<String, SongMetadata> directMetadataMap = {};
    try {
      directMetadataMap = await targetDb.getSongMetadataByPaths(directPaths);
    } catch (_) {}

    final result = <MusicFile>[];

    for (final entry in entries) {
      MusicFile? resolvedSong;

      // ---- Level 1: Direct Match ----
      final directMeta = directMetadataMap[entry.path];
      final isDirectRemote = RemoteMediaResolver.isRemoteUri(entry.path);
      final directExists = isDirectRemote || File(entry.path).existsSync();

      if (directMeta != null && directExists) {
        resolvedSong = _buildMusicFileFromMetadata(
          directMeta,
          exists: true,
          fallbackTitle: entry.title,
          fallbackArtist: entry.artist,
          fallbackDuration: entry.durationMillis,
        );
      } else if (!isDirectRemote && File(entry.path).existsSync()) {
        try {
          final meta = await targetDb.getSongMetadata(entry.path);
          if (meta != null) {
            resolvedSong = _buildMusicFileFromMetadata(
              meta,
              exists: true,
              fallbackTitle: entry.title,
              fallbackArtist: entry.artist,
              fallbackDuration: entry.durationMillis,
            );
          } else {
            final fileName = p.basename(entry.path);
            final title = (entry.title != null && entry.title!.trim().isNotEmpty)
                ? entry.title!.trim()
                : p.basenameWithoutExtension(entry.path);
            resolvedSong = MusicFile(
              path: entry.path,
              name: fileName.isNotEmpty ? fileName : entry.path,
              title: title,
              artist: entry.artist,
              durationMillis: entry.durationMillis,
              isMissing: false,
            );
          }
        } catch (_) {}
      }

      if (resolvedSong != null) {
        result.add(resolvedSong);
        continue;
      }

      // ---- Level 2: Scan Roots (Local Roots) Matching ----
      final rawPath = (entry.rawPath ?? entry.path).replaceAll('\\', '/').trim();

      if (!RemoteMediaResolver.isRemoteUri(rawPath)) {
        // Try relative path direct join with all roots
        for (final root in effectiveRoots) {
          final candidate = p.normalize(p.join(root, rawPath));
          if (File(candidate).existsSync()) {
            final meta = await targetDb.getSongMetadata(candidate);
            if (meta != null) {
              resolvedSong = _buildMusicFileFromMetadata(
                meta,
                exists: true,
                fallbackTitle: entry.title,
                fallbackArtist: entry.artist,
                fallbackDuration: entry.durationMillis,
              );
            } else {
              final fileName = p.basename(candidate);
              final title = (entry.title != null && entry.title!.trim().isNotEmpty)
                  ? entry.title!.trim()
                  : p.basenameWithoutExtension(candidate);
              resolvedSong = MusicFile(
                path: candidate,
                name: fileName.isNotEmpty ? fileName : candidate,
                title: title,
                artist: entry.artist,
                durationMillis: entry.durationMillis,
                isMissing: false,
              );
            }
            break;
          }
        }

        // If not found, try progressive right-to-left subpaths (e.g. from foreign absolute path)
        if (resolvedSong == null) {
          final segments = rawPath.split('/').where((s) => s.isNotEmpty).toList();
          if (segments.length > 1) {
            for (var i = 1; i < segments.length; i++) {
              final subpath = segments.sublist(i).join('/');
              for (final root in effectiveRoots) {
                final candidate = p.normalize(p.join(root, subpath));
                if (File(candidate).existsSync()) {
                  final meta = await targetDb.getSongMetadata(candidate);
                  if (meta != null) {
                    resolvedSong = _buildMusicFileFromMetadata(
                      meta,
                      exists: true,
                      fallbackTitle: entry.title,
                      fallbackArtist: entry.artist,
                      fallbackDuration: entry.durationMillis,
                    );
                  } else {
                    final fileName = p.basename(candidate);
                    final title =
                        (entry.title != null && entry.title!.trim().isNotEmpty)
                            ? entry.title!.trim()
                            : p.basenameWithoutExtension(candidate);
                    resolvedSong = MusicFile(
                      path: candidate,
                      name: fileName.isNotEmpty ? fileName : candidate,
                      title: title,
                      artist: entry.artist,
                      durationMillis: entry.durationMillis,
                      isMissing: false,
                    );
                  }
                  break;
                }
              }
              if (resolvedSong != null) break;
            }
          }
        }
      }

      if (resolvedSong != null) {
        result.add(resolvedSong);
        continue;
      }

      // ---- Level 3: Remote Server (WebDAV & Subsonic) Matching ----
      if (rawPath.startsWith('webdav://')) {
        final uriInfo = RemoteMediaResolver.parseUri(rawPath);
        final relPath = uriInfo != null
            ? uriInfo.trackIdOrPath
            : rawPath.replaceFirst(RegExp(r'^webdav://[^/]*'), '');
        final cleanRel = relPath.startsWith('/') ? relPath : '/$relPath';

        for (final srv in webdavServers) {
          final candidateUri =
              RemoteMediaResolver.buildWebDavUri(srv.id, cleanRel);
          final meta = await targetDb.getRemoteSongMetadata(candidateUri);
          if (meta != null) {
            resolvedSong = _buildMusicFileFromMetadata(
              meta,
              exists: true,
              fallbackTitle: entry.title,
              fallbackArtist: entry.artist,
              fallbackDuration: entry.durationMillis,
            );
            break;
          }
        }

        if (resolvedSong == null && webdavServers.isNotEmpty) {
          final firstSrv = webdavServers.first;
          final candidateUri =
              RemoteMediaResolver.buildWebDavUri(firstSrv.id, cleanRel);
          final fileName = p.basename(cleanRel);
          final title = (entry.title != null && entry.title!.trim().isNotEmpty)
              ? entry.title!.trim()
              : p.basenameWithoutExtension(cleanRel);
          resolvedSong = MusicFile(
            path: candidateUri,
            name: fileName.isNotEmpty ? fileName : cleanRel,
            title: title,
            artist: entry.artist,
            durationMillis: entry.durationMillis,
            isMissing: false,
          );
        }
      } else if (rawPath.startsWith('subsonic://')) {
        final uriInfo = RemoteMediaResolver.parseUri(rawPath);
        if (uriInfo != null) {
          for (final srv in subsonicServers) {
            final candidateUri = RemoteMediaResolver.buildSubsonicUri(
              srv.id,
              uriInfo.trackIdOrPath,
            );
            final meta = await targetDb.getRemoteSongMetadata(candidateUri);
            if (meta != null) {
              resolvedSong = _buildMusicFileFromMetadata(
                meta,
                exists: true,
                fallbackTitle: entry.title,
                fallbackArtist: entry.artist,
                fallbackDuration: entry.durationMillis,
              );
              break;
            }
          }
        }
      }

      if (resolvedSong != null) {
        result.add(resolvedSong);
        continue;
      }

      // ---- Level 4: Database Search Match ----
      // 4.1 Match by path suffix / filename
      final fileName = p.basename(rawPath);
      if (fileName.isNotEmpty) {
        try {
          final suffixMatches = await targetDb.findSongsByPathSuffix(fileName);
          for (final candidate in suffixMatches) {
            if (File(candidate.path).existsSync()) {
              resolvedSong = _buildMusicFileFromMetadata(
                candidate,
                exists: true,
                fallbackTitle: entry.title,
                fallbackArtist: entry.artist,
                fallbackDuration: entry.durationMillis,
              );
              break;
            }
          }
        } catch (_) {}

        if (resolvedSong == null) {
          try {
            final remoteMatches =
                await targetDb.findRemoteSongsByRemoteId(rawPath);
            if (remoteMatches.isNotEmpty) {
              resolvedSong = _buildMusicFileFromMetadata(
                remoteMatches.first,
                exists: true,
                fallbackTitle: entry.title,
                fallbackArtist: entry.artist,
                fallbackDuration: entry.durationMillis,
              );
            }
          } catch (_) {}
        }
      }

      // 4.2 Match by Title & Artist in DB
      if (resolvedSong == null &&
          entry.title != null &&
          entry.title!.trim().isNotEmpty) {
        try {
          final titleMatches = await targetDb.findSongsByTitleAndArtist(
            title: entry.title!,
            artist: entry.artist,
          );

          if (titleMatches.isNotEmpty) {
            SongMetadata best = titleMatches.first;
            if (entry.durationMillis != null && titleMatches.length > 1) {
              best = titleMatches.reduce((a, b) {
                final diffA =
                    ((a.duration ?? 0) - entry.durationMillis!).abs();
                final diffB =
                    ((b.duration ?? 0) - entry.durationMillis!).abs();
                return diffA < diffB ? a : b;
              });
            }

            final isRemote = RemoteMediaResolver.isRemoteUri(best.path);
            final exists = isRemote || File(best.path).existsSync();
            if (exists) {
              resolvedSong = _buildMusicFileFromMetadata(
                best,
                exists: true,
                fallbackTitle: entry.title,
                fallbackArtist: entry.artist,
                fallbackDuration: entry.durationMillis,
              );
            }
          }
        } catch (_) {}
      }

      if (resolvedSong != null) {
        result.add(resolvedSong);
        continue;
      }

      // ---- Level 5: Missing Fallback ----
      final fallbackName = fileName.isNotEmpty ? fileName : entry.path;
      final fallbackTitle =
          (entry.title != null && entry.title!.trim().isNotEmpty)
              ? entry.title!.trim()
              : (fileName.isNotEmpty
                  ? p.basenameWithoutExtension(fileName)
                  : entry.path);

      result.add(
        MusicFile(
          path: entry.path,
          name: fallbackName,
          title: fallbackTitle,
          artist: entry.artist,
          durationMillis: entry.durationMillis,
          isMissing: true,
        ),
      );
    }

    return result;
  }

  static MusicFile _buildMusicFileFromMetadata(
    SongMetadata metadata, {
    bool exists = true,
    String? fallbackTitle,
    String? fallbackArtist,
    int? fallbackDuration,
  }) {
    final title = metadata.title.trim().isNotEmpty
        ? metadata.title
        : (fallbackTitle ?? p.basenameWithoutExtension(metadata.path));
    final artist = metadata.artist.trim().isNotEmpty
        ? metadata.artist
        : fallbackArtist;

    return MusicFile(
      path: metadata.path,
      name: p.basename(metadata.path),
      title: title,
      artist: artist,
      albumArtist: metadata.albumArtist,
      album: metadata.album,
      trackNumber: metadata.trackNumber,
      durationMillis: metadata.duration ?? fallbackDuration,
      id: metadata.id,
      thumbnailPath: metadata.thumbnailPath,
      artworkPath: metadata.artworkPath,
      artworkWidth: metadata.artworkWidth,
      artworkHeight: metadata.artworkHeight,
      themeColorsBlob: metadata.themeColorsBlob,
      lastModifiedTime: metadata.lastModifiedTime,
      isMissing: !exists,
    );
  }
}
