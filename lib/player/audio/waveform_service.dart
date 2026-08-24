/// 波形数据服务
///
/// 提供歌曲波形图的获取、计算、缓存同步以及 BLOB 数据的序列化与反序列化。
library;

import 'dart:typed_data';
import 'package:audio_core/audio_core.dart';
import 'package:path/path.dart' as p;
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';

typedef WaveformCacheResult = ({
  List<double> waveform,
  Uint8List? waveformBlob,
});

class WaveformService {
  final MetadataDatabase db;
  final AudioCoreController player;

  WaveformService({required this.db, required this.player});

  Future<List<double>> getWaveform({
    required String path,
    int expectedChunks = 80,
    int sampleStride = 4,
  }) async {
    return (await getWaveformData(
      path: path,
      expectedChunks: expectedChunks,
      sampleStride: sampleStride,
    ))
        .waveform;
  }

  Future<WaveformCacheResult> getWaveformData({
    required String path,
    int expectedChunks = 80,
    int sampleStride = 4,
    SongMetadata? baseMetadata,
  }) async {
    var songMetadata = await db.getSongMetadata(path);
    if (songMetadata != null && songMetadata.waveformBlob != null) {
      final cached = waveformFromBlob(songMetadata.waveformBlob);
      if (isWaveformValid(cached)) {
        return (
          waveform: cached,
          waveformBlob: songMetadata.waveformBlob,
        );
      }
    }

    if (songMetadata == null) {
      final playbackMetadata = await MetadataHelper.loadMetadataForPlayback(
        path,
        generateThumbnail: false,
      );
      songMetadata = playbackMetadata?.$1;
      if (songMetadata?.waveformBlob != null) {
        final cached = waveformFromBlob(songMetadata!.waveformBlob);
        if (isWaveformValid(cached)) {
          return (
            waveform: cached,
            waveformBlob: songMetadata.waveformBlob,
          );
        }
      }
    }

    final waveform = await player.getWaveform(
      expectedChunks: expectedChunks,
      sampleStride: sampleStride,
      filePath: path,
    );
    if (waveform.isEmpty) {
      return (waveform: waveform, waveformBlob: null);
    }

    final isValid = isWaveformValid(waveform);
    final blob = isValid ? waveformToBlob(waveform) : null;
    if (isValid) {
      final fallbackMetadata =
          baseMetadata ??
          SongMetadata(
            path: path,
            title: p.basenameWithoutExtension(path),
            album: 'Unknown Album',
            artist: 'Unknown Artist',
          );
      final updated = (songMetadata ?? fallbackMetadata).copyWith(
        waveformBlob: blob,
      );
      await db.insertOrUpdateSong(updated);
    }

    return (waveform: waveform, waveformBlob: blob);
  }

  Stream<List<double>> streamWaveform({
    required String path,
    int expectedChunks = 80,
    int sampleStride = 4,
    SongMetadata? baseMetadata,
  }) async* {
    var songMetadata = await db.getSongMetadata(path);
    if (songMetadata != null && songMetadata.waveformBlob != null) {
      final cached = waveformFromBlob(songMetadata.waveformBlob);
      if (isWaveformValid(cached)) {
        yield cached;
        return;
      }
    }

    if (songMetadata == null) {
      final playbackMetadata = await MetadataHelper.loadMetadataForPlayback(
        path,
        generateThumbnail: false,
      );
      songMetadata = playbackMetadata?.$1;
      if (songMetadata?.waveformBlob != null) {
        final cached = waveformFromBlob(songMetadata!.waveformBlob);
        if (isWaveformValid(cached)) {
          yield cached;
          return;
        }
      }
    }

    List<double> lastWaveform = const [];
    await for (final waveformChunk in player.streamWaveform(
      expectedChunks: expectedChunks,
      sampleStride: sampleStride,
      filePath: path,
    )) {
      if (waveformChunk.isNotEmpty) {
        lastWaveform = waveformChunk;
        yield waveformChunk;
      }
    }

    if (lastWaveform.isNotEmpty && isWaveformValid(lastWaveform)) {
      final blob = waveformToBlob(lastWaveform);
      final fallbackMetadata =
          baseMetadata ??
          SongMetadata(
            path: path,
            title: p.basenameWithoutExtension(path),
            album: 'Unknown Album',
            artist: 'Unknown Artist',
          );
      final updated = (songMetadata ?? fallbackMetadata).copyWith(
        waveformBlob: blob,
      );
      await db.insertOrUpdateSong(updated);
    }
  }

  /// Checks whether a generated waveform appears valid (contains non-empty samples).
  static bool isWaveformValid(List<double> waveform) {
    if (waveform.isEmpty) return false;
    return waveform.any((v) => v > 0.0);
  }

  Future<bool> hasCachedWaveform(String path) async {
    final songMetadata = await db.getSongMetadata(path);
    return songMetadata?.waveformBlob != null;
  }

  Uint8List waveformToBlob(List<double> waveform) {
    return Float32List.fromList(
      waveform.map((e) => e.toDouble()).toList(),
    ).buffer.asUint8List();
  }

  List<double> waveformFromBlob(Uint8List? blob) {
    if (blob == null || blob.isEmpty) return const [];
    // Ensure the offset is aligned to 4 bytes for asFloat32List
    final alignedBlob = (blob.offsetInBytes % 4 == 0)
        ? blob
        : Uint8List.fromList(blob);
    final list = alignedBlob.buffer.asFloat32List(
      alignedBlob.offsetInBytes,
      alignedBlob.length ~/ 4,
    );
    return list.map((e) => e.toDouble()).toList();
  }
}
