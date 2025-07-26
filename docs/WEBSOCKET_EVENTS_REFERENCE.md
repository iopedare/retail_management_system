# 🔌 WebSocket Events Reference – Advanced Sync System

This document provides a comprehensive reference for all WebSocket events used in the advanced sync system, including payloads, frontend integration guidelines, and error handling procedures.

---

## 📋 Table of Contents

1. [Event Categories](#event-categories)
2. [Device Management Events](#device-management-events)
3. [Master Election Events](#master-election-events)
4. [Sync Operation Events](#sync-operation-events)
5. [Data Management Events](#data-management-events)
6. [System Health Events](#system-health-events)
7. [Error Handling](#error-handling)
8. [Frontend Integration Guidelines](#frontend-integration-guidelines)
9. [Event Flow Diagrams](#event-flow-diagrams)

---

## 🏷️ Event Categories

### Device Management
- Device registration, online/offline status, shutdown handling

### Master Election
- Automatic master election, role changes, priority management

### Sync Operations
- Data synchronization, conflict resolution, queue management

### Data Management
- Real-time data updates, requests, and responses

### System Health
- Heartbeat, connection monitoring, status updates

---

## 📱 Device Management Events

### `device_online`
**Purpose:** Notify when a device comes online
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "device_name": "string",
  "device_type": "string",
  "priority": "integer",
  "capabilities": ["array"],
  "timestamp": "ISO8601"
}
```

### `device_online_ack`
**Purpose:** Acknowledge device online registration
**Direction:** Server → Client
**Payload:**
```json
{
  "status": "success|error",
  "device_id": "string",
  "assigned_role": "master|client",
  "current_master": "string|null",
  "sync_required": "boolean",
  "message": "string",
  "timestamp": "ISO8601"
}
```

### `device_offline`
**Purpose:** Notify when a device goes offline
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "reason": "shutdown|network|manual",
  "timestamp": "ISO8601"
}
```

### `device_offline_ack`
**Purpose:** Acknowledge device offline notification
**Direction:** Server → Client
**Payload:**
```json
{
  "status": "success|error",
  "device_id": "string",
  "master_election_triggered": "boolean",
  "message": "string",
  "timestamp": "ISO8601"
}
```

### `device_shutdown`
**Purpose:** Notify graceful device shutdown
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "shutdown_reason": "string",
  "pending_operations": "integer",
  "timestamp": "ISO8601"
}
```

---

## 👑 Master Election Events

### `master_election`
**Purpose:** Trigger master election process
**Direction:** Server → All Clients
**Payload:**
```json
{
  "trigger_reason": "master_offline|manual|timeout",
  "candidates": [
    {
      "device_id": "string",
      "priority": "integer",
      "capabilities": ["array"],
      "last_seen": "ISO8601"
    }
  ],
  "election_id": "string",
  "timestamp": "ISO8601"
}
```

### `master_elected`
**Purpose:** Announce new master device
**Direction:** Server → All Clients
**Payload:**
```json
{
  "new_master_id": "string",
  "new_master_name": "string",
  "election_id": "string",
  "election_reason": "string",
  "previous_master": "string|null",
  "timestamp": "ISO8601"
}
```

### `role_change`
**Purpose:** Notify device of role change
**Direction:** Server → Client
**Payload:**
```json
{
  "device_id": "string",
  "new_role": "master|client",
  "previous_role": "master|client",
  "reason": "election|manual|failover",
  "timestamp": "ISO8601"
}
```

### `role_change_ack`
**Purpose:** Acknowledge role change
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "new_role": "master|client",
  "status": "success|error",
  "capabilities_updated": "boolean",
  "timestamp": "ISO8601"
}
```

---

## 🔄 Sync Operation Events

### `sync_request`
**Purpose:** Request data synchronization
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "sync_type": "full|incremental|critical",
  "last_sync_timestamp": "ISO8601|null",
  "requested_tables": ["array"],
  "timestamp": "ISO8601"
}
```

### `sync_response`
**Purpose:** Respond to sync request
**Direction:** Server → Client
**Payload:**
```json
{
  "device_id": "string",
  "sync_type": "full|incremental|critical",
  "status": "success|error|partial",
  "data": {
    "table_name": "array_of_records"
  },
  "conflicts": [
    {
      "table": "string",
      "record_id": "string",
      "conflict_type": "version|deletion|modification"
    }
  ],
  "timestamp": "ISO8601"
}
```

### `sync_complete`
**Purpose:** Notify sync completion
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "sync_type": "full|incremental|critical",
  "records_processed": "integer",
  "conflicts_resolved": "integer",
  "duration_ms": "integer",
  "timestamp": "ISO8601"
}
```

### `sync_complete_ack`
**Purpose:** Acknowledge sync completion
**Direction:** Server → Client
**Payload:**
```json
{
  "device_id": "string",
  "status": "success|error",
  "next_sync_scheduled": "ISO8601",
  "message": "string",
  "timestamp": "ISO8601"
}
```

### `sync_conflict`
**Purpose:** Report sync conflict
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "table": "string",
  "record_id": "string",
  "conflict_type": "version|deletion|modification",
  "local_version": "integer",
  "server_version": "integer",
  "local_data": "object",
  "server_data": "object",
  "timestamp": "ISO8601"
}
```

### `sync_conflict_resolved`
**Purpose:** Notify conflict resolution
**Direction:** Server → Client
**Payload:**
```json
{
  "device_id": "string",
  "table": "string",
  "record_id": "string",
  "resolution": "local_wins|server_wins|merged",
  "resolved_data": "object",
  "timestamp": "ISO8601"
}
```

### `sync_error`
**Purpose:** Report sync error
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "error_type": "network|data|validation|timeout",
  "error_message": "string",
  "sync_type": "full|incremental|critical",
  "retry_count": "integer",
  "timestamp": "ISO8601"
}
```

### `sync_error_ack`
**Purpose:** Acknowledge sync error
**Direction:** Server → Client
**Payload:**
```json
{
  "device_id": "string",
  "status": "acknowledged|retry_scheduled|manual_intervention",
  "retry_after": "ISO8601|null",
  "message": "string",
  "timestamp": "ISO8601"
}
```

---

## 📊 Data Management Events

### `data_update`
**Purpose:** Broadcast data changes
**Direction:** Server → All Clients
**Payload:**
```json
{
  "table": "string",
  "operation": "create|update|delete",
  "record_id": "string",
  "data": "object|null",
  "version": "integer",
  "source_device": "string",
  "timestamp": "ISO8601"
}
```

### `data_request`
**Purpose:** Request specific data
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "table": "string",
  "record_id": "string",
  "request_type": "single|batch|latest",
  "timestamp": "ISO8601"
}
```

### `data_response`
**Purpose:** Respond to data request
**Direction:** Server → Client
**Payload:**
```json
{
  "device_id": "string",
  "table": "string",
  "record_id": "string",
  "status": "success|not_found|error",
  "data": "object|null",
  "version": "integer",
  "timestamp": "ISO8601"
}
```

### `queue_status_request`
**Purpose:** Request sync queue status
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "queue_type": "sync|conflict|error",
  "timestamp": "ISO8601"
}
```

### `queue_status_response`
**Purpose:** Respond with queue status
**Direction:** Server → Client
**Payload:**
```json
{
  "device_id": "string",
  "queue_type": "sync|conflict|error",
  "pending_count": "integer",
  "processing_count": "integer",
  "completed_count": "integer",
  "error_count": "integer",
  "timestamp": "ISO8601"
}
```

---

## 💓 System Health Events

### `heartbeat`
**Purpose:** Maintain connection health
**Direction:** Client → Server
**Payload:**
```json
{
  "device_id": "string",
  "status": "healthy|warning|error",
  "uptime_seconds": "integer",
  "memory_usage": "float",
  "cpu_usage": "float",
  "timestamp": "ISO8601"
}
```

### `heartbeat_ack`
**Purpose:** Acknowledge heartbeat
**Direction:** Server → Client
**Payload:**
```json
{
  "device_id": "string",
  "status": "acknowledged",
  "server_time": "ISO8601",
  "timestamp": "ISO8601"
}
```

### `connection_status`
**Purpose:** Report connection status
**Direction:** Server → Client
**Payload:**
```json
{
  "status": "connected|disconnected|reconnecting",
  "connection_quality": "excellent|good|poor",
  "latency_ms": "integer",
  "active_devices": "integer",
  "timestamp": "ISO8601"
}
```

---

## ⚠️ Error Handling

### Error Response Format
All error responses follow this format:
```json
{
  "status": "error",
  "error_code": "string",
  "error_message": "string",
  "error_details": "object|null",
  "timestamp": "ISO8601"
}
```

### Common Error Codes
- `INVALID_PAYLOAD`: Malformed event payload
- `DEVICE_NOT_FOUND`: Device ID not registered
- `INSUFFICIENT_PERMISSIONS`: Role-based access denied
- `SYNC_CONFLICT`: Data synchronization conflict
- `NETWORK_TIMEOUT`: Network operation timeout
- `SERVER_ERROR`: Internal server error
- `MAINTENANCE_MODE`: System in maintenance mode

### Error Recovery Procedures
1. **Network Errors**: Implement exponential backoff retry
2. **Data Conflicts**: Follow conflict resolution protocol
3. **Authentication Errors**: Re-authenticate and retry
4. **Server Errors**: Log error and notify user
5. **Timeout Errors**: Increase timeout and retry

---

## 🎨 Frontend Integration Guidelines

### Event Listener Setup
```dart
// Example event listener setup
socketService.on('device_online_ack', (data) {
  _handleDeviceOnlineAck(data);
});

socketService.on('master_elected', (data) {
  _handleMasterElected(data);
});
```

### State Management
```dart
// Update app state based on events
void _handleRoleChange(Map<String, dynamic> data) {
  setState(() {
    deviceRole = data['new_role'];
    syncStatus = SyncStatus.connected;
  });
  
  // Update UI components
  _updateSyncStatusBar();
  _updateNavigationMenu();
}
```

### Error Handling
```dart
// Handle errors gracefully
void _handleSyncError(Map<String, dynamic> data) {
  final errorCode = data['error_code'];
  final errorMessage = data['error_message'];
  
  // Show user-friendly error message
  _showErrorDialog(errorMessage);
  
  // Log error for debugging
  _logError(errorCode, errorMessage);
  
  // Implement retry logic if appropriate
  if (_shouldRetry(errorCode)) {
    _scheduleRetry();
  }
}
```

### UI Updates
```dart
// Update UI based on sync status
void _updateSyncStatusBar() {
  switch (syncStatus) {
    case SyncStatus.connected:
      _statusBar.setStatus('Connected', Colors.green);
      break;
    case SyncStatus.disconnected:
      _statusBar.setStatus('Disconnected', Colors.red);
      break;
    case SyncStatus.reconnecting:
      _statusBar.setStatus('Reconnecting...', Colors.orange);
      break;
  }
}
```

---

## 🔄 Event Flow Diagrams

### Device Registration Flow
```
Client                    Server
  |                         |
  |-- device_online ------>|
  |                         |
  |<-- device_online_ack ---|
  |                         |
  |-- connect ------------->|
  |                         |
  |<-- connection_status ---|
```

### Master Election Flow
```
Client A    Client B    Server
   |           |          |
   |           |          |
   |<-- master_election --|
   |           |          |
   |           |          |
   |<-- master_elected ---|
   |           |          |
   |-- role_change_ack -->|
   |           |          |
```

### Data Sync Flow
```
Client                    Server
  |                         |
  |-- sync_request -------->|
  |                         |
  |<-- sync_response -------|
  |                         |
  |-- sync_complete ------->|
  |                         |
  |<-- sync_complete_ack ---|
```

---

## 📝 Implementation Notes

### Best Practices
1. **Always validate payloads** before processing
2. **Implement proper error handling** for all events
3. **Use type-safe data structures** for payloads
4. **Log all events** for debugging and audit
5. **Implement retry logic** for critical operations
6. **Update UI immediately** for user feedback
7. **Handle offline scenarios** gracefully

### Performance Considerations
1. **Batch operations** when possible
2. **Implement rate limiting** for high-frequency events
3. **Use efficient data serialization**
4. **Monitor memory usage** for large payloads
5. **Implement connection pooling** if needed

### Security Considerations
1. **Validate device authentication** for all events
2. **Implement role-based access control**
3. **Encrypt sensitive data** in payloads
4. **Log security-relevant events**
5. **Implement request throttling**

---

*This document should be updated whenever new events are added or existing events are modified.* 