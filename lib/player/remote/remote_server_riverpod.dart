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

class ActiveRemoteSession {
  final RemoteServer server;
  final String password;
  final String? initialPath;
  final int? initialTabIndex;

  const ActiveRemoteSession({
    required this.server,
    required this.password,
    this.initialPath,
    this.initialTabIndex,
  });

  ActiveRemoteSession copyWith({
    RemoteServer? server,
    String? password,
    String? initialPath,
    int? initialTabIndex,
  }) {
    return ActiveRemoteSession(
      server: server ?? this.server,
      password: password ?? this.password,
      initialPath: initialPath ?? this.initialPath,
      initialTabIndex: initialTabIndex ?? this.initialTabIndex,
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

  void updateInitialTabIndex(int? index) {
    if (state != null) {
      state = state!.copyWith(initialTabIndex: index);
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
