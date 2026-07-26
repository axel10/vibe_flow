import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/metadata/metadata_database.dart';

enum LibraryTimeRange { allTime, last7Days, last30Days, last90Days }

class LibraryInsightSongEntry {
  const LibraryInsightSongEntry({
    required this.song,
    required this.playCount,
    this.lastPlayedAt,
    this.createdAt,
  });

  final MusicFile song;
  final int playCount;
  final int? lastPlayedAt;
  final int? createdAt;
}

class LibraryInsightsService {
  LibraryInsightsService({MetadataDatabase? database})
    : _database = database ?? MetadataDatabase();

  final MetadataDatabase _database;

  Future<void> recordPlayback({
    required MusicFile song,
    required int playedAtMillis,
    required int playedDurationMillis,
    String? source,
  }) {
    return _database.recordSongPlayback(
      songPath: song.path,
      playedAt: playedAtMillis,
      playedDurationMillis: playedDurationMillis,
      songDurationMillis: song.durationMillis,
      source: source,
    );
  }

  Stream<List<LibraryInsightSongEntry>> watchRecentlyAdded(
    LibraryTimeRange range, {
    int? limit = 500,
  }) {
    return _database
        .watchRecentlyAddedSongs(
          startAtMillis: _startAtMillis(range),
          limit: limit,
        )
        .map(_mapRecords);
  }

  Stream<List<LibraryInsightSongEntry>> watchMostPlayed(
    LibraryTimeRange range, {
    int? limit = 500,
  }) {
    return _database
        .watchMostPlayedSongs(
          startAtMillis: _startAtMillis(range),
          limit: limit,
        )
        .map(_mapRecords);
  }

  int? _startAtMillis(LibraryTimeRange range) {
    final now = DateTime.now();
    return switch (range) {
      LibraryTimeRange.allTime => null,
      LibraryTimeRange.last7Days =>
        now.subtract(const Duration(days: 7)).millisecondsSinceEpoch,
      LibraryTimeRange.last30Days =>
        now.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
      LibraryTimeRange.last90Days =>
        now.subtract(const Duration(days: 90)).millisecondsSinceEpoch,
    };
  }

  List<LibraryInsightSongEntry> _mapRecords(
    List<LibraryInsightSongRecord> records,
  ) {
    return records
        .where((record) {
          final flags = record.song.sourceFlags ?? 0;
          return (flags & SongSourceFlags.external) == 0;
        })
        .map(
          (record) => LibraryInsightSongEntry(
            song: MusicFile(
              path: record.song.path,
              name: _basename(record.song.path),
              title: record.song.title,
              artist: record.song.artist,
              album: record.song.album,
              trackNumber: record.song.trackNumber,
              id: record.song.id,
              thumbnailPath: record.song.thumbnailPath,
              artworkPath: record.song.artworkPath,
              artworkWidth: record.song.artworkWidth,
              artworkHeight: record.song.artworkHeight,
              durationMillis: record.song.duration,
              themeColorsBlob: record.song.themeColorsBlob,
              waveformBlob: record.song.waveformBlob,
              lastModifiedTime: record.song.lastModifiedTime,
            ),
            playCount: record.playCount,
            lastPlayedAt: record.lastPlayedAt,
            createdAt: record.song.createdAt,
          ),
        )
        .toList(growable: false);
  }

  String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index == -1 ? normalized : normalized.substring(index + 1);
  }
}

final libraryInsightsServiceProvider = Provider<LibraryInsightsService>((ref) {
  return LibraryInsightsService();
});

final mostPlayedSongsProvider =
    StreamProvider.family<List<LibraryInsightSongEntry>, LibraryTimeRange>((
      ref,
      range,
    ) {
      return ref.read(libraryInsightsServiceProvider).watchMostPlayed(range);
    });

final recentlyAddedSongsProvider =
    StreamProvider.family<List<LibraryInsightSongEntry>, LibraryTimeRange>((
      ref,
      range,
    ) {
      return ref.read(libraryInsightsServiceProvider).watchRecentlyAdded(range);
    });
