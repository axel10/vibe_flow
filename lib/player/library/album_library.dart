import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:vynody/models/album_summary.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/metadata/metadata_database.dart';

final albumLibraryProvider = StreamProvider<List<AlbumSummary>>((ref) async* {
  final db = MetadataDatabase();
  await for (final songs in db.watchAllSongMetadata()) {
    yield buildAlbumSummaries(songs);
  }
});

List<AlbumSummary> buildAlbumSummaries(Iterable<SongMetadata> songs) {
  final groups = <String, List<MusicFile>>{};

  for (final metadata in songs) {
    final flags = metadata.sourceFlags ?? 0;
    if ((flags & SongSourceFlags.external) != 0) continue;
    final path = metadata.path;
    if (path.isEmpty) continue;

    final title = _cleanMetadataText(
      metadata.album,
      fallback: 'Unknown Album',
    );
    final artist = _cleanMetadataText(
      metadata.artist,
      fallback: 'Unknown Artist',
    );
    final song = MusicFile(
      path: path,
      name: p.basename(path),
      title: _cleanMetadataText(
        metadata.title,
        fallback: 'Unknown',
      ),
      artist: artist,
      album: title,
      trackNumber: metadata.trackNumber,
      id: metadata.id,
      artworkPath: metadata.artworkPath,
      thumbnailPath: metadata.thumbnailPath,
      artworkWidth: metadata.artworkWidth,
      artworkHeight: metadata.artworkHeight,
      durationMillis: metadata.duration,
      lastModifiedTime: metadata.lastModifiedTime,
    );

    final key = '${title.toLowerCase()}::${artist.toLowerCase()}';
    (groups[key] ??= []).add(song);
  }

  final albums = groups.entries.map((entry) {
    final sortedSongs = List<MusicFile>.from(entry.value)..sort(_compareAlbumMusicFiles);
    final representativeSong = sortedSongs.firstWhere(
      (song) => _hasMusicFileArtwork(song),
      orElse: () => sortedSongs.first,
    );
    final totalDurationMillis = sortedSongs.fold<int>(
      0,
      (sum, song) => sum + (song.durationMillis ?? 0),
    );

    return AlbumSummary(
      id: entry.key,
      title: sortedSongs.first.album ?? 'Unknown Album',
      artist: sortedSongs.first.artist ?? 'Unknown Artist',
      songs: sortedSongs,
      representativeSong: representativeSong,
      totalDurationMillis: totalDurationMillis,
    );
  }).toList(growable: false)
    ..sort((a, b) {
      final artistCompare = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      if (artistCompare != 0) return artistCompare;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

  return albums;
}

bool _hasMusicFileArtwork(MusicFile song) {
  final hasThumbnail = song.thumbnailPath?.isNotEmpty ?? false;
  final hasArtwork = song.artworkPath?.isNotEmpty ?? false;
  return hasThumbnail || hasArtwork;
}

int _compareAlbumMusicFiles(MusicFile a, MusicFile b) {
  final leftTrack = a.trackNumber;
  final rightTrack = b.trackNumber;
  if (leftTrack != null && rightTrack != null && leftTrack != rightTrack) {
    return leftTrack.compareTo(rightTrack);
  }
  if (leftTrack != null && rightTrack == null) return -1;
  if (leftTrack == null && rightTrack != null) return 1;

  final titleCompare = (a.title ?? p.basenameWithoutExtension(a.path))
      .toLowerCase()
      .compareTo((b.title ?? p.basenameWithoutExtension(b.path)).toLowerCase());
  if (titleCompare != 0) return titleCompare;
  return a.path.toLowerCase().compareTo(b.path.toLowerCase());
}

String _cleanMetadataText(String? value, {required String fallback}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return fallback;
  }
  return trimmed;
}

