import 'dart:convert';

/// Supported remote media server types.
enum RemoteServerType {
  subsonic,
  webdav;

  String get displayName => switch (this) {
        RemoteServerType.subsonic => 'Navidrome / Subsonic',
        RemoteServerType.webdav => 'WebDAV',
      };

  static RemoteServerType fromString(String? value) {
    if (value == null) return RemoteServerType.subsonic;
    return RemoteServerType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => RemoteServerType.subsonic,
    );
  }
}

/// Metadata model for a connected remote media server.
class RemoteServer {
  final String id;
  final String name;
  final RemoteServerType type;
  final String url;
  final String username;
  final String? customPath;
  final int? maxBitRate; // e.g. 320 for 320kbps transcoding
  final bool ignoreSsl;
  final DateTime createdAt;
  final DateTime? lastConnectedAt;

  const RemoteServer({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.username,
    this.customPath,
    this.maxBitRate,
    this.ignoreSsl = false,
    required this.createdAt,
    this.lastConnectedAt,
  });

  RemoteServer copyWith({
    String? id,
    String? name,
    RemoteServerType? type,
    String? url,
    String? username,
    String? customPath,
    int? maxBitRate,
    bool? ignoreSsl,
    DateTime? createdAt,
    DateTime? lastConnectedAt,
  }) {
    return RemoteServer(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      username: username ?? this.username,
      customPath: customPath ?? this.customPath,
      maxBitRate: maxBitRate ?? this.maxBitRate,
      ignoreSsl: ignoreSsl ?? this.ignoreSsl,
      createdAt: createdAt ?? this.createdAt,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'url': url,
      'username': username,
      'customPath': customPath,
      'maxBitRate': maxBitRate,
      'ignoreSsl': ignoreSsl,
      'createdAt': createdAt.toIso8601String(),
      'lastConnectedAt': lastConnectedAt?.toIso8601String(),
    };
  }

  factory RemoteServer.fromJson(Map<String, dynamic> json) {
    return RemoteServer(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unnamed Server',
      type: RemoteServerType.fromString(json['type'] as String?),
      url: json['url'] as String? ?? '',
      username: json['username'] as String? ?? '',
      customPath: json['customPath'] as String?,
      maxBitRate: json['maxBitRate'] as int?,
      ignoreSsl: json['ignoreSsl'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastConnectedAt: json['lastConnectedAt'] != null
          ? DateTime.tryParse(json['lastConnectedAt'] as String)
          : null,
    );
  }

  static List<RemoteServer> decodeList(String raw) {
    if (raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => RemoteServer.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  static String encodeList(List<RemoteServer> list) {
    return jsonEncode(list.map((s) => s.toJson()).toList());
  }
}

/// Result of testing a server connection.
class ConnectionTestResult {
  final bool isSuccess;
  final String message;
  final String? serverVersion;
  final int? songCount;
  final int? albumCount;

  const ConnectionTestResult({
    required this.isSuccess,
    required this.message,
    this.serverVersion,
    this.songCount,
    this.albumCount,
  });

  const ConnectionTestResult.success({
    required this.message,
    this.serverVersion,
    this.songCount,
    this.albumCount,
  }) : isSuccess = true;

  const ConnectionTestResult.failure(this.message)
      : isSuccess = false,
        serverVersion = null,
        songCount = null,
        albumCount = null;
}
