import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'remote_server_models.dart';
import 'remote_server_storage.dart';
import 'clients/subsonic_client.dart';
import 'clients/webdav_client.dart';

final remoteServerStorageProvider = FutureProvider<RemoteServerStorage>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return RemoteServerStorage(prefs: prefs);
});

class RemoteServersNotifier extends AsyncNotifier<List<RemoteServer>> {
  @override
  Future<List<RemoteServer>> build() async {
    final storage = await ref.watch(remoteServerStorageProvider.future);
    return storage.loadServers();
  }

  Future<void> addServer(RemoteServer server, String password) async {
    final storage = await ref.read(remoteServerStorageProvider.future);
    await storage.savePassword(server.id, password);

    final currentList = state.asData?.value ?? [];
    final updatedList = [...currentList.where((s) => s.id != server.id), server];
    await storage.saveServers(updatedList);
    state = AsyncData(updatedList);
  }

  Future<void> updateServer(RemoteServer server, {String? newPassword}) async {
    final storage = await ref.read(remoteServerStorageProvider.future);
    if (newPassword != null && newPassword.isNotEmpty) {
      await storage.savePassword(server.id, newPassword);
    }

    final currentList = state.asData?.value ?? [];
    final updatedList = currentList.map((s) => s.id == server.id ? server : s).toList();
    await storage.saveServers(updatedList);
    state = AsyncData(updatedList);
  }

  Future<void> deleteServer(String serverId) async {
    final storage = await ref.read(remoteServerStorageProvider.future);
    await storage.deleteServer(serverId);

    final currentList = state.asData?.value ?? [];
    final updatedList = currentList.where((s) => s.id != serverId).toList();
    state = AsyncData(updatedList);
  }

  Future<String?> getPassword(String serverId) async {
    final storage = await ref.read(remoteServerStorageProvider.future);
    return storage.getPassword(serverId);
  }

  Future<ConnectionTestResult> testConnection(RemoteServer server, String password) async {
    if (server.type == RemoteServerType.subsonic) {
      final client = SubsonicClient(server: server, password: password);
      return client.testConnection();
    } else {
      final client = WebDavClient(server: server, password: password);
      return client.testConnection();
    }
  }
}

final remoteServersProvider =
    AsyncNotifierProvider<RemoteServersNotifier, List<RemoteServer>>(() {
  return RemoteServersNotifier();
});

sealed class NavidromeDetailRoute {
  const NavidromeDetailRoute();
}

class NavidromeAlbumRoute extends NavidromeDetailRoute {
  final String albumId;
  final String albumName;
  final String? coverArtId;
  final String? artistName;

  const NavidromeAlbumRoute({
    required this.albumId,
    required this.albumName,
    this.coverArtId,
    this.artistName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavidromeAlbumRoute &&
          runtimeType == other.runtimeType &&
          albumId == other.albumId;

  @override
  int get hashCode => albumId.hashCode;
}

class NavidromeArtistRoute extends NavidromeDetailRoute {
  final String artistId;
  final String artistName;
  final String? coverArtId;
  final int? albumCount;

  const NavidromeArtistRoute({
    required this.artistId,
    required this.artistName,
    this.coverArtId,
    this.albumCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavidromeArtistRoute &&
          runtimeType == other.runtimeType &&
          artistId == other.artistId &&
          artistName == other.artistName;

  @override
  int get hashCode => Object.hash(artistId, artistName);
}

class NavidromePlaylistRoute extends NavidromeDetailRoute {
  final String playlistId;
  final String playlistName;
  final String? coverArtId;
  final int? songCount;
  final int? duration;
  final bool isStarred;

  const NavidromePlaylistRoute({
    required this.playlistId,
    required this.playlistName,
    this.coverArtId,
    this.songCount,
    this.duration,
    this.isStarred = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavidromePlaylistRoute &&
          runtimeType == other.runtimeType &&
          playlistId == other.playlistId;

  @override
  int get hashCode => playlistId.hashCode;
}

class ActiveRemoteSession {
  final RemoteServer server;
  final String password;
  final String? initialPath;
  final String? rootPath;
  final int? initialTabIndex;
  final Map<String, List<WebDavFile>> webDavDirectoryCache;

  // Navidrome / Subsonic cached states
  final List<Map<String, dynamic>>? navidromeAlbums;
  final String? navidromeAlbumSortType;
  final List<Map<String, dynamic>>? navidromeArtists;
  final Set<String>? navidromeStarredArtistIds;
  final String? navidromeSelectedArtistId;
  final List<Map<String, dynamic>>? navidromePlaylists;
  final String? navidromeSelectedPlaylistId;
  final List<NavidromeDetailRoute> navidromeDetailStack;

  const ActiveRemoteSession({
    required this.server,
    required this.password,
    this.initialPath,
    this.rootPath,
    this.initialTabIndex,
    this.webDavDirectoryCache = const {},
    this.navidromeAlbums,
    this.navidromeAlbumSortType,
    this.navidromeArtists,
    this.navidromeStarredArtistIds,
    this.navidromeSelectedArtistId,
    this.navidromePlaylists,
    this.navidromeSelectedPlaylistId,
    this.navidromeDetailStack = const [],
  });

  ActiveRemoteSession copyWith({
    RemoteServer? server,
    String? password,
    String? initialPath,
    String? rootPath,
    int? initialTabIndex,
    Map<String, List<WebDavFile>>? webDavDirectoryCache,
    List<Map<String, dynamic>>? navidromeAlbums,
    String? navidromeAlbumSortType,
    List<Map<String, dynamic>>? navidromeArtists,
    Set<String>? navidromeStarredArtistIds,
    String? navidromeSelectedArtistId,
    List<Map<String, dynamic>>? navidromePlaylists,
    String? navidromeSelectedPlaylistId,
    List<NavidromeDetailRoute>? navidromeDetailStack,
  }) {
    return ActiveRemoteSession(
      server: server ?? this.server,
      password: password ?? this.password,
      initialPath: initialPath ?? this.initialPath,
      rootPath: rootPath ?? this.rootPath,
      initialTabIndex: initialTabIndex ?? this.initialTabIndex,
      webDavDirectoryCache: webDavDirectoryCache ?? this.webDavDirectoryCache,
      navidromeAlbums: navidromeAlbums ?? this.navidromeAlbums,
      navidromeAlbumSortType:
          navidromeAlbumSortType ?? this.navidromeAlbumSortType,
      navidromeArtists: navidromeArtists ?? this.navidromeArtists,
      navidromeStarredArtistIds:
          navidromeStarredArtistIds ?? this.navidromeStarredArtistIds,
      navidromeSelectedArtistId:
          navidromeSelectedArtistId ?? this.navidromeSelectedArtistId,
      navidromePlaylists: navidromePlaylists ?? this.navidromePlaylists,
      navidromeSelectedPlaylistId:
          navidromeSelectedPlaylistId ?? this.navidromeSelectedPlaylistId,
      navidromeDetailStack: navidromeDetailStack ?? this.navidromeDetailStack,
    );
  }
}

class ActiveRemoteSessionNotifier extends Notifier<ActiveRemoteSession?> {
  @override
  ActiveRemoteSession? build() => null;

  void setSession(ActiveRemoteSession? session) {
    state = session;
  }

  void updateInitialPath(String? path) {
    if (state != null) {
      state = state!.copyWith(initialPath: path);
    }
  }

  void updateWebDavState({
    required String currentPath,
    String? rootPath,
    List<WebDavFile>? items,
  }) {
    if (state != null) {
      final newCache =
          Map<String, List<WebDavFile>>.from(state!.webDavDirectoryCache);
      if (items != null) {
        newCache[currentPath] = items;
      }
      state = state!.copyWith(
        initialPath: currentPath,
        rootPath: rootPath ?? state!.rootPath,
        webDavDirectoryCache: newCache,
      );
    }
  }

  void updateInitialTabIndex(int? index) {
    if (state != null) {
      state = state!.copyWith(initialTabIndex: index);
    }
  }

  void updateNavidromeAlbums(
    List<Map<String, dynamic>> albums, {
    String? sortType,
  }) {
    if (state != null) {
      state = state!.copyWith(
        navidromeAlbums: albums,
        navidromeAlbumSortType: sortType ?? state!.navidromeAlbumSortType,
      );
    }
  }

  void updateNavidromeArtists({
    List<Map<String, dynamic>>? artists,
    Set<String>? starredArtistIds,
    String? selectedArtistId,
  }) {
    if (state != null) {
      state = state!.copyWith(
        navidromeArtists: artists ?? state!.navidromeArtists,
        navidromeStarredArtistIds:
            starredArtistIds ?? state!.navidromeStarredArtistIds,
        navidromeSelectedArtistId:
            selectedArtistId ?? state!.navidromeSelectedArtistId,
      );
    }
  }

  void updateNavidromePlaylists({
    List<Map<String, dynamic>>? playlists,
    String? selectedPlaylistId,
  }) {
    if (state != null) {
      state = state!.copyWith(
        navidromePlaylists: playlists ?? state!.navidromePlaylists,
        navidromeSelectedPlaylistId:
            selectedPlaylistId ?? state!.navidromeSelectedPlaylistId,
      );
    }
  }

  void pushNavidromeDetail(NavidromeDetailRoute route) {
    if (state != null) {
      state = state!.copyWith(
        navidromeDetailStack: [...state!.navidromeDetailStack, route],
      );
    }
  }

  void popNavidromeDetail() {
    if (state != null && state!.navidromeDetailStack.isNotEmpty) {
      final newStack =
          List<NavidromeDetailRoute>.from(state!.navidromeDetailStack)
            ..removeLast();
      state = state!.copyWith(navidromeDetailStack: newStack);
    }
  }

  void clear() {
    state = null;
  }
}

final activeRemoteSessionProvider =
    NotifierProvider<ActiveRemoteSessionNotifier, ActiveRemoteSession?>(
      ActiveRemoteSessionNotifier.new,
    );
