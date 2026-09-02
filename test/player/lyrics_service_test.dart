import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/lyrics/lyrics_cache_repository.dart';
import 'package:vynody/player/lyrics/lyrics_service.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/utils/network_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LyricsService.searchTracksByTitle', () {
    test('sends only title-related query parameters', () async {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: 'https://lrclib.net/api/search'),
        data: [
          {
            'trackName': 'Song Title',
            'artistName': 'Artist',
            'albumName': 'Album',
            'duration': 185,
            'plainLyrics': 'Line 1\nLine 2',
            'syncedLyrics': null,
          },
        ],
      );
      final client = _RecordingNetworkClient(response);
      final service = LyricsService(client: client);

      final tracks = await service.searchTracksByTitle(title: 'Song Title');

      expect(client.callCount, 1);
      expect(client.lastPath, 'https://lrclib.net/api/search');
      expect(client.lastQueryParameters, {
        'track_name': 'Song Title',
        'q': 'Song Title',
      });
      expect(tracks, hasLength(1));
      expect(tracks.single.displayTitle, 'Song Title');
      expect(tracks.single.hasSyncedLyrics, isFalse);
    });

    test(
      'returns empty list without issuing a request for blank title',
      () async {
        final client = _RecordingNetworkClient(
          Response<dynamic>(
            requestOptions: RequestOptions(
              path: 'https://lrclib.net/api/search',
            ),
            data: const [],
          ),
        );
        final service = LyricsService(client: client);

        final tracks = await service.searchTracksByTitle(title: '   ');

        expect(tracks, isEmpty);
        expect(client.callCount, 0);
      },
    );
  });

  group('LyricsService.fetchBestLyrics', () {
    test(
      'selects lrclib result from search without using get',
      () async {
        final searchResponse = Response<dynamic>(
          requestOptions: RequestOptions(path: 'https://lrclib.net/api/search'),
          data: [
            {
              'trackName': 'Song Title',
              'artistName': null,
              'albumName': null,
              'duration': 171,
              'plainLyrics': 'Line 1\nLine 2',
              'syncedLyrics': null,
            },
            {
              'trackName': 'Song Titl',
              'artistName': null,
              'albumName': null,
              'duration': 180,
              'plainLyrics': 'Line 1\nLine 2',
              'syncedLyrics': null,
            },
          ],
        );
        final client = _RoutingNetworkClient(
          searchResponse: searchResponse,
        );
        final service = LyricsService(
          client: client,
          cacheRepository: _NoopLyricsCacheRepository(),
        );

        final result = await service.fetchBestLyrics(
          query: const LyricsQuery(
            filePath: '/music/song.mp3',
            fileName: 'song.mp3',
            title: 'Song Title',
            duration: Duration(seconds: 180),
          ),
        );

        expect(result, isNotNull);
        expect(result!.track.trackName, 'Song Titl');
        expect(result.durationDiffSeconds, 0);
        expect(client.callCount, 1);
        expect(client.lastPath, 'https://lrclib.net/api/search');
      },
    );

    test(
      'selects candidate matching artist and duration among multiple results with same title',
      () async {
        final searchResponse = Response<dynamic>(
          requestOptions: RequestOptions(path: 'https://lrclib.net/api/search'),
          data: [
            {
              'id': 1,
              'trackName': 'Black Board',
              'artistName': 'Nano',
              'albumName': 'N',
              'duration': 222,
              'plainLyrics': 'The tears I cried for you',
              'syncedLyrics': '[00:15.00] The tears I cried for you',
            },
            {
              'id': 2,
              'trackName': 'Black Board',
              'artistName': '蝶々P',
              'albumName': 'EXIT TUNES',
              'duration': 222,
              'plainLyrics': '君への涙はあの日と同じ',
              'syncedLyrics': '[00:15.00] 君への涙はあの日と同じ',
            },
          ],
        );
        final client = _RoutingNetworkClient(
          searchResponse: searchResponse,
        );
        final service = LyricsService(
          client: client,
          cacheRepository: _NoopLyricsCacheRepository(),
        );

        final result = await service.fetchBestLyrics(
          query: const LyricsQuery(
            filePath: '/music/Black Board.mp3',
            fileName: '06.蝶々P feat.初音ミク - Black Board.mp3',
            title: 'Black Board',
            artist: '蝶々P',
            duration: Duration(seconds: 222),
          ),
        );

        expect(result, isNotNull);
        expect(result!.track.artistName, '蝶々P');
        expect(result.lyricsText, contains('君への涙はあの日と同じ'));
      },
    );
  });
}

class _RecordingNetworkClient implements NetworkClient {
  _RecordingNetworkClient(this.response);

  final Response<dynamic> response;
  int callCount = 0;
  String? lastPath;
  Map<String, dynamic>? lastQueryParameters;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    callCount++;
    lastPath = path;
    lastQueryParameters = queryParameters == null
        ? null
        : Map<String, dynamic>.from(queryParameters);
    return response as Response<T>;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Dio get dio => throw UnimplementedError();
}

class _RoutingNetworkClient implements NetworkClient {
  _RoutingNetworkClient({required this.searchResponse});

  final Response<dynamic> searchResponse;
  int callCount = 0;
  String? lastPath;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    if (path.contains('/api/search')) {
      callCount++;
      lastPath = path;
      return searchResponse as Response<T>;
    }
    throw StateError('Unexpected path: $path');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Dio get dio => throw UnimplementedError();
}

class _NoopLyricsCacheRepository implements LyricsCacheRepository {
  @override
  Future<void> clearAllLyricsCaches() async {}

  @override
  Future<void> clearAllLyricsCachesByKey(String cacheKey) async {}

  @override
  Future<void> clearLyricsCache() async {}

  @override
  Future<void> clearLyricsCacheByKey(String cacheKey) async {}

  @override
  Future<void> clearLyricsTranslationCache() async {}

  @override
  Future<void> clearLyricsTranslationCacheByKey(String cacheKey) async {}

  @override
  Future<LyricsCacheRecord?> getLyricsCache(String cacheKey) async => null;

  @override
  Future<List<LyricsCacheRecord>> getLyricsCaches(String cacheKey) async => const [];

  @override
  Future<List<LyricsTranslationCacheRecord>> getLyricsTranslationCaches(
    String cacheKey,
  ) async {
    return const [];
  }

  @override
  Stream<LyricsCacheRecord?> watchLyricsCache(String cacheKey) =>
      const Stream<LyricsCacheRecord?>.empty();

  @override
  Stream<List<LyricsCacheRecord>> watchLyricsCaches(String cacheKey) =>
      const Stream<List<LyricsCacheRecord>>.empty();

  @override
  Stream<List<LyricsTranslationCacheRecord>> watchLyricsTranslationCaches(
    String cacheKey,
  ) =>
      const Stream<List<LyricsTranslationCacheRecord>>.empty();

  @override
  Future<void> saveLyricsCache(LyricsCacheRecord record) async {}

  @override
  Future<void> saveLyricsTranslationCache(
    LyricsTranslationCacheRecord record,
  ) async {}

  @override
  Future<List<LyricsCacheRecord>> getAllLyricsCaches() async => const [];

  @override
  Future<List<LyricsTranslationCacheRecord>> getAllLyricsTranslationCaches() async => const [];
}
