import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/secure_storage.dart';
import '../metadata/metadata_database.dart';
import 'remote_server_models.dart';

class RemoteServerStorage {
  static const String _serversPrefKey = 'vynody_remote_servers_v1';
  static const String _securePasswordPrefix = 'vynody_server_pwd_';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  static final Map<String, String> _passwordCache = {};

  RemoteServerStorage({
    required SharedPreferences prefs,
    FlutterSecureStorage? secureStorage,
  })  : _prefs = prefs,
        _secureStorage = secureStorage ?? appSecureStorage;

  /// Loads all saved remote servers.
  List<RemoteServer> loadServers() {
    final raw = _prefs.getString(_serversPrefKey) ?? '';
    return RemoteServer.decodeList(raw);
  }

  /// Saves the updated list of remote servers.
  Future<void> saveServers(List<RemoteServer> servers) async {
    final raw = RemoteServer.encodeList(servers);
    await _prefs.setString(_serversPrefKey, raw);
  }

  /// Retrieves the stored password / token synchronously if cached.
  String? getPasswordSync(String serverId) {
    return _passwordCache[serverId];
  }

  /// Retrieves the stored password / token for the specified server id.
  Future<String?> getPassword(String serverId) async {
    if (_passwordCache.containsKey(serverId)) {
      return _passwordCache[serverId];
    }
    try {
      final pwd = await _secureStorage.read(key: '$_securePasswordPrefix$serverId');
      if (pwd != null) {
        _passwordCache[serverId] = pwd;
      }
      return pwd;
    } catch (_) {
      return null;
    }
  }

  /// Saves or updates the password / token for the specified server id.
  Future<void> savePassword(String serverId, String password) async {
    _passwordCache[serverId] = password;
    try {
      await _secureStorage.write(
        key: '$_securePasswordPrefix$serverId',
        value: password,
      );
    } catch (_) {}
  }

  /// Deletes a server and its associated secure credentials.
  Future<void> deleteServer(String serverId) async {
    _passwordCache.remove(serverId);
    final list = loadServers();
    final updated = list.where((s) => s.id != serverId).toList();
    await saveServers(updated);
    try {
      await _secureStorage.delete(key: '$_securePasswordPrefix$serverId');
    } catch (_) {}
    try {
      await MetadataDatabase().deleteRemoteSongsByServerId(serverId);
    } catch (_) {}
  }
}

