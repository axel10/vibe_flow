import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'music_lyric.dart';

part 'music_file.freezed.dart';

@freezed
abstract class MusicFile with _$MusicFile {
  const MusicFile._();

  const factory MusicFile({
    required String path,
    required String name,
    String? title,
    String? artist,
    String? albumArtist,
    String? album,
    int? trackNumber,
    int? id, // System Media Library ID
    String? mediaUri,
    String? thumbnailPath,
    String? artworkPath,
    int? artworkWidth,
    int? artworkHeight,
    int? durationMillis,
    Uint8List? themeColorsBlob,
    Uint8List? waveformBlob,
    Uint8List? artworkBytes,
    int? lastModifiedTime,
    MusicLyric? lyrics,
    @Default(false) bool isMissing,
  }) = _MusicFile;

  static final Map<String, List<double>> _waveformMemoryCache = {};
  static final List<String> _waveformMemoryCacheKeys = [];
  static const int _maxCacheSize = 8;

  static void clearCache() {
    _waveformMemoryCache.clear();
    _waveformMemoryCacheKeys.clear();
  }

  static void invalidateWaveformCache(String path) {
    _waveformMemoryCache.remove(path);
    _waveformMemoryCacheKeys.remove(path);
  }

  List<double> get waveform {
    final cached = _waveformMemoryCache[path];
    if (cached != null) return cached;

    final blob = waveformBlob;
    if (blob == null || blob.isEmpty) {
      return const <double>[];
    }
    final alignedBlob = (blob.offsetInBytes % 4 == 0)
        ? blob
        : Uint8List.fromList(blob);
    final list = alignedBlob.buffer.asFloat32List(
      alignedBlob.offsetInBytes,
      alignedBlob.length ~/ 4,
    );
    final result = list.map((e) => e.toDouble()).toList();

    if (_waveformMemoryCacheKeys.length >= _maxCacheSize) {
      final oldestKey = _waveformMemoryCacheKeys.removeAt(0);
      _waveformMemoryCache.remove(oldestKey);
    }
    _waveformMemoryCache[path] = result;
    _waveformMemoryCacheKeys.add(path);

    return result;
  }

  String get displayName {
    if (title != null && title!.trim().isNotEmpty) {
      return title!;
    }
    return p.basenameWithoutExtension(path);
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MusicFile &&
        other.runtimeType == runtimeType &&
        other.path == path &&
        other.name == name &&
        other.title == title &&
        other.artist == artist &&
        other.albumArtist == albumArtist &&
        other.album == album &&
        other.trackNumber == trackNumber &&
        other.id == id &&
        other.mediaUri == mediaUri &&
        other.thumbnailPath == thumbnailPath &&
        other.artworkPath == artworkPath &&
        other.artworkWidth == artworkWidth &&
        other.artworkHeight == artworkHeight &&
        other.durationMillis == durationMillis &&
        identical(other.themeColorsBlob, themeColorsBlob) &&
        identical(other.waveformBlob, waveformBlob) &&
        identical(other.artworkBytes, artworkBytes) &&
        other.lastModifiedTime == lastModifiedTime &&
        other.lyrics == lyrics &&
        other.isMissing == isMissing;
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        path,
        name,
        title,
        artist,
        albumArtist,
        album,
        trackNumber,
        id,
        mediaUri,
        thumbnailPath,
        artworkPath,
        artworkWidth,
        artworkHeight,
        durationMillis,
        themeColorsBlob != null ? identityHashCode(themeColorsBlob) : null,
        waveformBlob != null ? identityHashCode(waveformBlob) : null,
        artworkBytes != null ? identityHashCode(artworkBytes) : null,
        lastModifiedTime,
        lyrics,
        isMissing,
      ]);
}

