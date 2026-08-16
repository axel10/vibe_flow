class LanDevice {
  final String id;
  final String name;
  final String deviceType; // 'macos', 'windows', 'linux', 'android', 'ios'
  final int httpPort;
  final String ip;
  final DateTime lastSeen;
  final bool isOnline;
  final String? certFingerprint;

  LanDevice({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.httpPort,
    required this.ip,
    required this.lastSeen,
    required this.isOnline,
    this.certFingerprint,
  });

  LanDevice copyWith({
    String? id,
    String? name,
    String? deviceType,
    int? httpPort,
    String? ip,
    DateTime? lastSeen,
    bool? isOnline,
    String? certFingerprint,
  }) {
    return LanDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
      httpPort: httpPort ?? this.httpPort,
      ip: ip ?? this.ip,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      certFingerprint: certFingerprint ?? this.certFingerprint,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceType': deviceType,
      'httpPort': httpPort,
      'ip': ip,
      'isOnline': isOnline,
      if (certFingerprint != null) 'certFingerprint': certFingerprint,
    };
  }

  factory LanDevice.fromJson(Map<String, dynamic> json, String ipAddress, DateTime timestamp) {
    return LanDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Device',
      deviceType: json['deviceType'] as String? ?? 'unknown',
      httpPort: json['httpPort'] as int? ?? 53536,
      ip: ipAddress,
      lastSeen: timestamp,
      isOnline: json['isOnline'] as bool? ?? true,
      certFingerprint: json['certFingerprint'] as String? ?? json['fp'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LanDevice{id: $id, name: $name, deviceType: $deviceType, httpPort: $httpPort, ip: $ip, lastSeen: $lastSeen, isOnline: $isOnline, certFingerprint: $certFingerprint}';
  }
}
