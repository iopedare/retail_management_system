import 'dart:io';

/// Model representing device information for sync operations
///
/// This model contains device identification and capabilities
/// used for device registration, role management, and sync operations
class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String platform;
  final String? version;
  final String? buildNumber;
  final DeviceRole role;
  final DateTime lastSeen;
  final bool isOnline;

  /// Create device information
  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    this.version,
    this.buildNumber,
    this.role = DeviceRole.client,
    DateTime? lastSeen,
    this.isOnline = true,
  }) : lastSeen = lastSeen ?? DateTime.now();

  /// Create DeviceInfo from JSON data
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['device_id'] ?? '',
      deviceName: json['device_name'] ?? '',
      platform: json['platform'] ?? '',
      version: json['version'],
      buildNumber: json['build_number'],
      role: DeviceRole.values.firstWhere(
        (role) => role.toString().split('.').last == json['role'],
        orElse: () => DeviceRole.client,
      ),
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : DateTime.now(),
      isOnline: json['is_online'] ?? true,
    );
  }

  /// Convert DeviceInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'platform': platform,
      'version': version,
      'build_number': buildNumber,
      'role': role.toString().split('.').last,
      'last_seen': lastSeen.toIso8601String(),
      'is_online': isOnline,
    };
  }

  /// Create a copy with updated fields
  DeviceInfo copyWith({
    String? deviceId,
    String? deviceName,
    String? platform,
    String? version,
    String? buildNumber,
    DeviceRole? role,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      platform: platform ?? this.platform,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      role: role ?? this.role,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  /// Update last seen timestamp
  DeviceInfo updateLastSeen() {
    return copyWith(lastSeen: DateTime.now());
  }

  /// Mark device as online
  DeviceInfo markOnline() {
    return copyWith(isOnline: true, lastSeen: DateTime.now());
  }

  /// Mark device as offline
  DeviceInfo markOffline() {
    return copyWith(isOnline: false);
  }

  /// Check if this device is the master
  bool get isMaster => role == DeviceRole.master;

  /// Check if this device is a client
  bool get isClient => role == DeviceRole.client;

  @override
  String toString() {
    return 'DeviceInfo(id: $deviceId, name: $deviceName, role: $role, online: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;
}

/// Enum representing device roles in the sync network
enum DeviceRole {
  /// Master device - coordinates sync operations
  master,

  /// Client device - participates in sync operations
  client,
}

/// Extension to provide human-readable descriptions for device roles
extension DeviceRoleExtension on DeviceRole {
  /// Get a human-readable description of the device role
  String get description {
    switch (this) {
      case DeviceRole.master:
        return 'Master';
      case DeviceRole.client:
        return 'Client';
    }
  }
}
