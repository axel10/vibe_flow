import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/metadata/acoustid_service.dart';
import 'package:vynody/player/metadata/metadata_helper.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/metadata/musicbrainz_tag_completion_service.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/remote/remote_service_providers.dart';
import 'package:vynody/utils/localized_text.dart';

AppLocalizations _l10n() => currentAppL10n;

final songTagCompletionControllerProvider = ChangeNotifierProvider.autoDispose
    .family<SongTagCompletionController, String>((ref, songPath) {
      return SongTagCompletionController(
        songPath: songPath,
        acoustidService: ref.read(acoustidServiceProvider),
        remoteResolverFuture: ref.read(remoteMediaResolverProvider.future),
      );
    });

class SongTagCompletionController extends ChangeNotifier {
  SongTagCompletionController({
    required this.songPath,
    required this.acoustidService,
    this.remoteResolverFuture,
  });

  final String songPath;
  final AcoustIDService acoustidService;
  final Future<RemoteMediaResolver>? remoteResolverFuture;
  final MusicBrainzTagCompletionService service =
      MusicBrainzTagCompletionService();

  List<MusicBrainzTrackMatch> musicBrainzMatches = const [];
  List<AcoustIDResult> acoustidResults = const [];
  bool isMusicBrainzLoading = true;
  bool isAcoustIDLoading = true;
  bool isApplying = false;
  String? musicBrainzErrorMessage;
  String? errorMessage;
  String? acoustidClientErrorMessage;

  int _musicBrainzQueryRevision = 0;
  bool _disposed = false;

  void _emit() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadMusicBrainzMatches({
    required String? title,
    required String? artist,
    required String? album,
    required int? durationMillis,
    required bool enableTitleQuery,
    required bool enableArtistQuery,
    required bool enableAlbumQuery,
    required bool enableDurationQuery,
  }) async {
    if (_disposed) return;

    final revision = ++_musicBrainzQueryRevision;
    isMusicBrainzLoading = true;
    musicBrainzErrorMessage = null;
    errorMessage = null;
    _emit();

    try {
      final results = await service.searchMatches(
        songPath: songPath,
        title: title,
        artist: artist,
        album: album,
        durationMillis: durationMillis,
        enableTitleQuery: enableTitleQuery,
        enableArtistQuery: enableArtistQuery,
        enableAlbumQuery: enableAlbumQuery,
        enableDurationQuery: enableDurationQuery,
      );

      if (_disposed || revision != _musicBrainzQueryRevision) return;
      musicBrainzMatches = results;
      isMusicBrainzLoading = false;
      musicBrainzErrorMessage = null;
      _emit();
    } catch (e) {
      if (_disposed || revision != _musicBrainzQueryRevision) return;
      musicBrainzErrorMessage = _l10n().musicBrainzQueryFailed;
      isMusicBrainzLoading = false;
      _emit();
    }
  }

  Future<void> loadAcoustIDResult({required int? durationMillis}) async {
    if (_disposed) return;

    isAcoustIDLoading = true;
    acoustidClientErrorMessage = null;
    acoustidResults = const [];
    _emit();

    try {
      String effectivePath = songPath;
      if (RemoteMediaResolver.isRemoteUri(songPath)) {
        if (remoteResolverFuture != null) {
          final resolver = await remoteResolverFuture!;
          if (_disposed) return;
          effectivePath = await resolver.resolvePlayableLocalPath(songPath);
          if (_disposed) return;
        } else {
          isAcoustIDLoading = false;
          _emit();
          return;
        }
      }

      final durationSec = (durationMillis ?? 0) ~/ 1000;
      final results = await acoustidService.lookupByFingerprint(
        filePath: effectivePath,
        durationSeconds: durationSec,
      );

      if (_disposed) return;
      acoustidResults = results;
      isAcoustIDLoading = false;
      _emit();
    } on AcoustIDClientException catch (e) {
      debugPrint('AcoustID: client error ${e.statusCode}: ${e.message}');
      if (_disposed) return;
      acoustidClientErrorMessage = _l10n().acoustidRequestReturnedStatus(e.statusCode);
      isAcoustIDLoading = false;
      _emit();
    } catch (e) {
      debugPrint('AcoustID: Failed to load result: $e');
      if (_disposed) return;
      isAcoustIDLoading = false;
      _emit();
    }
  }

  Future<MusicBrainzTagSelectionResult?> applyAcoustIDSelection({
    required AcoustIDResult trackResult,
    required AcoustIDRecording recording,
    required String albumTitle,
    required String sourceLabel,
    required String fallbackTitle,
    required int? fallbackDurationMillis,
    String? releaseId,
    String? releaseGroupId,
    String? coverLargeUrl,
    String? coverThumbnailUrl,
    Map<String, dynamic>? raw,
    String? country,
    String? releaseDate,
    SongMetadata? existingMetadata,
    bool writeToFile = false,
  }) async {
    if (_disposed || isApplying) return null;

    isApplying = true;
    errorMessage = null;
    _emit();

    try {
      final coverArtBytes = await acoustidService.downloadCoverBytes(
        candidateUrls: [coverLargeUrl, coverThumbnailUrl],
      );
      final durationMillis = recording.durationMillis ?? fallbackDurationMillis;
      final saved = await MetadataHelper.saveSelectedSongMetadata(
        filePath: songPath,
        title: recording.title.isNotEmpty ? recording.title : fallbackTitle,
        artist: recording.artist.isNotEmpty
            ? recording.artist
            : _l10n().unknownArtist,
        album: albumTitle,
        duration: durationMillis,
        artworkBytes: coverArtBytes,
        existingMetadata: existingMetadata,
        writeToFile: writeToFile,
      );

      if (saved == null) {
        throw StateError(_l10n().writeTagDatabaseFailed);
      }

      final updated = saved.$1;
      final resolvedCover = coverLargeUrl != null || coverThumbnailUrl != null
          ? ResolvedCover(
              endpoint: releaseId != null ? 'release' : 'release-group',
              id: releaseId ?? releaseGroupId ?? '',
              largeUrl: coverLargeUrl,
              thumbnailUrl: coverThumbnailUrl ?? coverLargeUrl,
            )
          : null;

      final result = MusicBrainzTagSelectionResult(
        metadata: updated,
        artworkBytes: coverArtBytes,
        match: _buildAcoustIDSelectionMatch(
          trackResult: trackResult,
          recording: recording,
          albumTitle: albumTitle,
          releaseId: releaseId,
          releaseGroupId: releaseGroupId,
          releaseDate: releaseDate,
          country: country,
          raw: raw,
          resolvedCover: resolvedCover,
          sourceLabel: sourceLabel,
          fallbackTitle: fallbackTitle,
          fallbackDurationMillis: fallbackDurationMillis,
        ),
      );

      if (_disposed) return null;
      isApplying = false;
      _emit();
      return result;
    } catch (e) {
      if (_disposed) return null;
      isApplying = false;
      errorMessage = _l10n().saveFailed;
      _emit();
      return null;
    }
  }

  Future<MusicBrainzTagSelectionResult?> applyMusicBrainzRelease({
    required MusicBrainzTrackMatch match,
    required MusicBrainzReleaseMatch release,
    required int? fallbackDurationMillis,
    SongMetadata? existingMetadata,
    bool writeToFile = false,
  }) async {
    if (_disposed || isApplying) return null;

    isApplying = true;
    errorMessage = null;
    _emit();

    try {
      final result = await service.applySelection(
        songPath: songPath,
        match: match,
        selectedRelease: release,
        fallbackDurationMillis: fallbackDurationMillis,
        existingMetadata: existingMetadata,
        writeToFile: writeToFile,
      );

      if (_disposed) return null;
      isApplying = false;
      _emit();
      return result;
    } catch (e) {
      if (_disposed) return null;
      isApplying = false;
      errorMessage = _l10n().saveFailed;
      _emit();
      return null;
    }
  }
}

MusicBrainzTrackMatch _buildAcoustIDSelectionMatch({
  required AcoustIDResult trackResult,
  required AcoustIDRecording recording,
  required String albumTitle,
  required String sourceLabel,
  required String fallbackTitle,
  required int? fallbackDurationMillis,
  String? releaseId,
  String? releaseGroupId,
  String? releaseDate,
  String? country,
  Map<String, dynamic>? raw,
  ResolvedCover? resolvedCover,
}) {
  return MusicBrainzTrackMatch(
    recordingId: recording.id.isNotEmpty ? recording.id : trackResult.id,
    title: recording.title.isNotEmpty ? recording.title : fallbackTitle,
    artist: recording.artist.isNotEmpty
        ? recording.artist
        : _l10n().unknownArtist,
    album: albumTitle,
    releaseId: releaseId,
    releaseGroupId: releaseGroupId,
    releaseDate: releaseDate,
    country: country,
    durationMillis: recording.durationMillis ?? fallbackDurationMillis,
    trackNumber: null,
    score: (trackResult.score * 100).round().clamp(0, 100),
    disambiguation: sourceLabel,
    releases: const [],
    raw: raw ?? {'track': trackResult.raw, 'recording': recording.raw},
    resolvedCover: resolvedCover,
  );
}
