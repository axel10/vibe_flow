import 'package:audio_core/audio_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_riverpod.dart';
import 'proxy/remote_media_resolver.dart';
import 'remote_server_riverpod.dart';

final audioStreamCacheManagerProvider = Provider<AudioStreamCacheManager>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return AudioStreamCacheManager(
    maxCacheSizeBytesGetter: () => settings.remoteCacheMaxSizeBytes,
  );
});

final remoteMediaResolverProvider = FutureProvider<RemoteMediaResolver>((ref) async {
  final storage = await ref.watch(remoteServerStorageProvider.future);
  final cacheManager = ref.watch(audioStreamCacheManagerProvider);
  return RemoteMediaResolver(storage: storage, cacheManager: cacheManager);
});
