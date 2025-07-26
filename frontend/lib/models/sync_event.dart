import 'dart:convert';

/// Model representing a sync event for data synchronization between devices
/// 
/// This model matches the backend SyncEvent structure and includes:
/// - Event type and payload for the actual data being synced
/// - Timestamp for conflict resolution and audit trail
/// - Device and user identification for tracking
/// - Status tracking for sync progress
class SyncEvent {
  final String id;
  final String eventType;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final String deviceId;
  final String? userId;
  final String status;
  final bool isCritical;

  /// Create a new sync event
  /// 
  /// [eventType] - Type of event (e.g., 'product_update', 'inventory_update', 'order_create')
  /// [payload] - The actual data being synced
  /// [deviceId] - ID of the originating device
  /// [userId] - ID of the user who triggered the event (optional)
  /// [isCritical] - Whether this event requires immediate sync
  SyncEvent({
    required this.eventType,
    required this.payload,
    required this.deviceId,
    this.userId,
    this.isCritical = false,
    String? id,
    DateTime? timestamp,
    String? status,
  })  : id = id ?? _generateId(),
        timestamp = timestamp ?? DateTime.now(),
        status = status ?? 'pending';

  /// Generate a unique ID for the event
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (1000 + (DateTime.now().microsecond % 1000)).toString();
  }

  /// Create a SyncEvent from JSON data (from backend)
  factory SyncEvent.fromJson(Map<String, dynamic> json) {
    return SyncEvent(
      id: json['id']?.toString() ?? '',
      eventType: json['event_type'] ?? '',
      payload: json['payload'] is Map<String, dynamic> 
          ? json['payload'] 
          : jsonDecode(json['payload'].toString()),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      deviceId: json['device_id'] ?? '',
      userId: json['user_id'],
      status: json['status'] ?? 'pending',
      isCritical: json['is_critical'] ?? false,
    );
  }

  /// Convert SyncEvent to JSON for backend communication
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_type': eventType,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'device_id': deviceId,
      'user_id': userId,
      'status': status,
      'is_critical': isCritical,
    };
  }

  /// Create a copy of this event with updated fields
  SyncEvent copyWith({
    String? id,
    String? eventType,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
    String? deviceId,
    String? userId,
    String? status,
    bool? isCritical,
  }) {
    return SyncEvent(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      isCritical: isCritical ?? this.isCritical,
    );
  }

  /// Mark this event as synced
  SyncEvent markAsSynced() {
    return copyWith(status: 'synced');
  }

  /// Mark this event as failed
  SyncEvent markAsFailed() {
    return copyWith(status: 'failed');
  }

  @override
  String toString() {
    return 'SyncEvent(id: $id, type: $eventType, status: $status, device: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 