import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vynody/models/artist_summary.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/metadata/metadata_database.dart';

final artistLibraryProvider = StreamProvider<List<ArtistSummary>>((ref) async* {
  final repository = ArtistLibraryRepository();
  yield* repository.watchArtistSummaries();
});

int _artistLibrarySessionSeq = 0;

void _artistLibraryLog(String message) {
  debugPrint('[ArtistLibrary] $message');
}

class ArtistLibraryRepository {
  ArtistLibraryRepository({
    MetadataDatabase? database,
  }) : _database = database ?? MetadataDatabase();

  final MetadataDatabase _database;

  Stream<List<ArtistSummary>> watchArtistSummaries() async* {
    final sessionId = ++_artistLibrarySessionSeq;
    _artistLibraryLog('session#$sessionId start');

    await for (final songs in _database.watchAllSongMetadata()) {
      final filteredSongs = songs.where((song) {
        final flags = song.sourceFlags ?? 0;
        return (flags & SongSourceFlags.external) == 0;
      }).toList(growable: false);
      final groups = _groupSongsByArtist(filteredSongs);

      final cacheKeys = groups
          .map((group) => group.queryKey)
          .toList(growable: false);
      final caches = await _database.getArtistCachesByKeys(cacheKeys);
      final orderedGroups = _sortGroupsForDisplay(groups, caches);
      _artistLibraryLog(
        'session#$sessionId loaded songs=${songs.length} groups=${groups.length} '
        'caches=${caches.length}',
      );
      yield _buildSummaries(orderedGroups, caches);
    }
    _artistLibraryLog('session#$sessionId complete');
  }

  List<_ArtistGroup> _groupSongsByArtist(List<SongMetadata> songs) {
    final groups = <String, _ArtistGroup>{};
    final order = <String>[];

    for (final song in songs) {
      final artistNames = splitArtistNames(song.artist);
      if (artistNames.isEmpty) continue;

      final seenKeys = <String>{};
      for (final artistName in artistNames) {
        final queryKey = normalizeArtistKey(artistName);
        if (queryKey.isEmpty || !seenKeys.add(queryKey)) {
          continue;
        }

        final group = groups.putIfAbsent(queryKey, () {
          order.add(queryKey);
          return _ArtistGroup(
            queryKey: queryKey,
            displayName: artistName,
            songs: <MusicFile>[],
          );
        });

        group.addSong(song);
        if (group.displayName == 'Unknown Artist' &&
            artistName.toLowerCase() != 'unknown artist') {
          group.displayName = artistName;
        }
        if (group.displayName.trim().isEmpty) {
          group.displayName = artistName;
        }
      }
    }

    return order.map((key) => groups[key]!).toList(growable: false);
  }

  ArtistSummary _buildSummary(
    _ArtistGroup group,
    ArtistCacheRecord? cache, {
    bool isImageLoading = false,
  }) {
    final representativeSong = group.songs.firstWhere(
      _hasArtwork,
      orElse: () => group.songs.first,
    );
    final tags = _decodeStringList(cache?.tagsJson);
    return ArtistSummary(
      queryKey: group.queryKey,
      name: cache?.artistName?.trim().isNotEmpty == true
          ? cache!.artistName!.trim()
          : group.displayName,
      songs: List<MusicFile>.unmodifiable(group.songs),
      representativeSong: representativeSong,
      songCount: group.songs.length,
      artistId: cache?.artistId,
      sortName: cache?.sortName,
      disambiguation: cache?.disambiguation,
      country: cache?.country,
      areaName: cache?.areaName,
      beginDate: cache?.beginDate,
      endDate: cache?.endDate,
      imageFileTitle: null,
      imageUrl: null,
      thumbnailUrl: null,
      cachedImagePath: null,
      isImageLoading: isImageLoading,
      tags: tags,
      noData: cache?.noData ?? false,
    );
  }

  List<ArtistSummary> _buildSummaries(
    List<_ArtistGroup> groups,
    Map<String, ArtistCacheRecord> caches, {
    String? loadingKey,
  }) {
    // Keep the list order stable while artist metadata refreshes in the
    // background. Re-sorting on every incremental update makes the grid jump and
    // looks like a loading flash to the user.
    return groups
        .map(
          (group) => _buildSummary(
            group,
            caches[group.queryKey],
            isImageLoading: loadingKey == group.queryKey,
          ),
        )
        .toList(growable: false);
  }

  List<_ArtistGroup> _sortGroupsForDisplay(
    List<_ArtistGroup> groups,
    Map<String, ArtistCacheRecord> caches,
  ) {
    final sorted = groups.toList(growable: false);
    sorted.sort((left, right) {
      final leftCache = caches[left.queryKey];
      final rightCache = caches[right.queryKey];
      final leftLabel = _groupSortLabel(left, leftCache);
      final rightLabel = _groupSortLabel(right, rightCache);
      final compare = leftLabel.compareTo(rightLabel);
      if (compare != 0) return compare;
      return _artistDisplayName(
        left,
        leftCache,
      ).compareTo(_artistDisplayName(right, rightCache));
    });
    return sorted;
  }
}

class _ArtistGroup {
  _ArtistGroup({
    required this.queryKey,
    required this.displayName,
    required this.songs,
  });

  final String queryKey;
  String displayName;
  final List<MusicFile> songs;

  void addSong(SongMetadata metadata) {
    songs.add(
      MusicFile(
        path: metadata.path,
        name: metadata.path.split(RegExp(r'[\\/]+')).last,
        title: metadata.title,
        artist: metadata.artist,
        album: metadata.album,
        trackNumber: metadata.trackNumber,
        id: metadata.id,
        artworkPath: metadata.artworkPath,
        thumbnailPath: metadata.thumbnailPath,
        artworkWidth: metadata.artworkWidth,
        artworkHeight: metadata.artworkHeight,
        durationMillis: metadata.duration,
        lastModifiedTime: metadata.lastModifiedTime,
      ),
    );
  }
}

String _groupSortLabel(_ArtistGroup group, ArtistCacheRecord? cache) {
  final cachedSortName = cache?.sortName?.trim();
  if (cachedSortName != null && cachedSortName.isNotEmpty) {
    return cachedSortName.toLowerCase();
  }
  final cachedName = cache?.artistName?.trim();
  if (cachedName != null && cachedName.isNotEmpty) {
    return cachedName.toLowerCase();
  }
  return group.displayName.toLowerCase();
}

String _groupDisplayName(_ArtistGroup group, ArtistCacheRecord? cache) {
  final cachedName = cache?.artistName?.trim();
  if (cachedName != null && cachedName.isNotEmpty) {
    return cachedName;
  }
  return group.displayName;
}

String _artistDisplayName(_ArtistGroup group, ArtistCacheRecord? cache) {
  return _groupDisplayName(group, cache);
}

bool _hasArtwork(MusicFile song) {
  return (song.thumbnailPath?.trim().isNotEmpty ?? false) ||
      (song.artworkPath?.trim().isNotEmpty ?? false);
}

List<String> splitArtistNames(String value) {
  final raw = value.trim();
  if (raw.isEmpty) return const <String>[];

  return raw
      .split(RegExp(r'\s*[,;]\s*'))
      .map((artist) => artist.trim())
      .where((artist) => artist.isNotEmpty)
      .toList(growable: false);
}

List<String> _decodeStringList(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const <String>[];
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const <String>[];
  return decoded
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
