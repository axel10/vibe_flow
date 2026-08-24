import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'proxy/local_stream_cache_proxy.dart';
import 'proxy/remote_stream_cache_manager.dart';
import 'proxy/remote_media_resolver.dart';
import 'remote_server_riverpod.dart';

final remoteStreamCacheManagerProvider = Provider<RemoteStreamCacheManager>((ref) {
  return RemoteStreamCacheManager();
});

final localStreamCacheProxyProvider = Provider<LocalStreamCacheProxy>((ref) {
  final cacheManager = ref.watch(remoteStreamCacheManagerProvider);
  final proxy = LocalStreamCacheProxy(cacheManager: cacheManager);
  
  // Eagerly start proxy
  proxy.start();
  
  ref.onDispose(() {
    proxy.stop();
  });
  
  return proxy;
});

final remoteMediaResolverProvider = FutureProvider<RemoteMediaResolver>((ref) async {
  final storage = await ref.watch(remoteServerStorageProvider.future);
  final proxy = ref.watch(localStreamCacheProxyProvider);
  if (!proxy.isRunning) {
    await proxy.start();
  }
  return RemoteMediaResolver(storage: storage, proxy: proxy);
});
