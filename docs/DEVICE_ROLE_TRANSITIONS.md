# 👑 Device Role Transitions & Master Election Protocol

This document details the device role management system, master election protocol, and role transition flows in the advanced sync system.

---

## 📋 Table of Contents

1. [Device Roles Overview](#device-roles-overview)
2. [Master Election Protocol](#master-election-protocol)
3. [Role Transition Flows](#role-transition-flows)
4. [Priority System](#priority-system)
5. [Failover Scenarios](#failover-scenarios)
6. [Implementation Guidelines](#implementation-guidelines)
7. [Troubleshooting](#troubleshooting)

---

## 🏷️ Device Roles Overview

### Master Device
- **Responsibilities:**
  - Primary data synchronization coordinator
  - Conflict resolution authority
  - System-wide data consistency management
  - Backup device coordination
  - Audit log management

- **Capabilities:**
  - Full read/write access to all data
  - Can initiate system-wide sync operations
  - Can override client decisions
  - Can manage device priorities
  - Can trigger manual master election

### Client Device
- **Responsibilities:**
  - Local data management
  - Sync request initiation
  - Conflict reporting
  - Offline operation support
  - Data validation

- **Capabilities:**
  - Read access to all data
  - Write access to local changes
  - Can request sync operations
  - Can report conflicts
  - Can participate in master election

---

## 🗳️ Master Election Protocol

### Election Triggers
1. **Master Device Offline**: When current master goes offline
2. **Manual Trigger**: Admin-initiated master change
3. **Timeout**: Master device unresponsive for extended period
4. **Priority Change**: Higher priority device comes online
5. **System Recovery**: After system restart or failure

### Election Process
```
1. Election Triggered
   ↓
2. Collect Online Devices
   ↓
3. Filter by Capabilities
   ↓
4. Sort by Priority
   ↓
5. Select Highest Priority Device
   ↓
6. Notify All Devices
   ↓
7. Role Transition
   ↓
8. Sync State Update
```

### Election Algorithm
```python
def elect_master(devices):
    # Filter devices with master capabilities
    candidates = [d for d in devices if d.has_master_capability()]
    
    # Sort by priority (highest first)
    candidates.sort(key=lambda x: x.priority, reverse=True)
    
    # Select highest priority device
    if candidates:
        return candidates[0]
    return None
```

---

## 🔄 Role Transition Flows

### Client → Master Transition
```
1. Device receives master_elected event
   ↓
2. Update local role to 'master'
   ↓
3. Initialize master services
   ↓
4. Send role_change_ack to server
   ↓
5. Start master responsibilities
   ↓
6. Update UI to show master status
```

### Master → Client Transition
```
1. Device receives role_change event
   ↓
2. Stop master services gracefully
   ↓
3. Update local role to 'client'
   ↓
4. Send role_change_ack to server
   ↓
5. Resume client operations
   ↓
6. Update UI to show client status
```

### New Device Registration
```
1. Device comes online
   ↓
2. Register with server
   ↓
3. Receive device_online_ack
   ↓
4. Check assigned role
   ↓
5. Initialize appropriate services
   ↓
6. Update UI status
```

---

## 🏆 Priority System

### Priority Levels
| Priority | Device Type | Description |
|----------|-------------|-------------|
| 100 | Primary Server | Main server with full capabilities |
| 90 | Backup Server | Secondary server for failover |
| 80 | Manager Terminal | Manager's primary workstation |
| 70 | Assistant Terminal | Assistant manager workstation |
| 60 | POS Terminal | Point of sale terminal |
| 50 | Inventory Terminal | Inventory management terminal |
| 40 | Mobile Device | Tablet or mobile device |
| 30 | Backup Terminal | Secondary terminal |
| 20 | Test Device | Development/testing device |
| 10 | Emergency Device | Last resort device |

### Priority Calculation
```python
def calculate_priority(device):
    base_priority = device.type_priority
    
    # Bonus for uptime
    uptime_bonus = min(device.uptime_hours / 24, 10)
    
    # Bonus for reliability
    reliability_bonus = device.success_rate * 5
    
    # Penalty for recent failures
    failure_penalty = device.recent_failures * 2
    
    return base_priority + uptime_bonus + reliability_bonus - failure_penalty
```

---

## 🚨 Failover Scenarios

### Scenario 1: Master Device Crashes
```
1. Master device crashes unexpectedly
   ↓
2. Server detects device offline
   ↓
3. Trigger master election
   ↓
4. Select highest priority online device
   ↓
5. Notify all devices of new master
   ↓
6. New master initializes services
   ↓
7. Resume normal operations
```

### Scenario 2: Network Partition
```
1. Network partition occurs
   ↓
2. Devices detect connection loss
   ↓
3. Each partition elects local master
   ↓
4. Continue local operations
   ↓
5. When network restored:
     - Detect multiple masters
     - Trigger conflict resolution
     - Elect single master
     - Sync divergent data
```

### Scenario 3: Manual Master Change
```
1. Admin initiates master change
   ↓
2. Server validates request
   ↓
3. Trigger master election
   ↓
4. Select specified device
   ↓
5. Notify all devices
   ↓
6. Graceful role transition
   ↓
7. Confirm change completion
```

### Scenario 4: Former Master Returns
```
1. Former master comes back online
   ↓
2. Register with server
   ↓
3. Check current master priority
   ↓
4. If higher priority:
     - Trigger election
     - Become new master
   ↓
5. If lower priority:
     - Join as client
     - Sync with current master
```

---

## 🛠️ Implementation Guidelines

### Backend Implementation
```python
class MasterElectionService:
    def __init__(self):
        self.current_master = None
        self.devices = {}
        self.election_in_progress = False
    
    def trigger_election(self, reason):
        if self.election_in_progress:
            return
        
        self.election_in_progress = True
        candidates = self.get_online_devices()
        new_master = self.select_master(candidates)
        
        if new_master:
            self.transfer_master_role(new_master, reason)
        
        self.election_in_progress = False
    
    def select_master(self, devices):
        # Implementation of election algorithm
        pass
    
    def transfer_master_role(self, new_master, reason):
        # Handle role transfer
        pass
```

### Frontend Implementation
```dart
class DeviceRoleManager {
  DeviceRole currentRole = DeviceRole.client;
  String? currentMasterId;
  
  void handleRoleChange(Map<String, dynamic> data) {
    final newRole = DeviceRole.values.firstWhere(
      (role) => role.toString() == data['new_role']
    );
    
    if (newRole != currentRole) {
      _transitionRole(newRole, data);
    }
  }
  
  void _transitionRole(DeviceRole newRole, Map<String, dynamic> data) {
    // Stop current role services
    _stopCurrentRoleServices();
    
    // Update role
    currentRole = newRole;
    
    // Initialize new role services
    _initializeNewRoleServices();
    
    // Update UI
    _updateUI();
    
    // Acknowledge role change
    _acknowledgeRoleChange(data);
  }
}
```

### Database Schema
```sql
-- Device roles table
CREATE TABLE device_roles (
    id INTEGER PRIMARY KEY,
    device_id TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('master', 'client')),
    priority INTEGER NOT NULL DEFAULT 50,
    capabilities TEXT, -- JSON array
    last_seen TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Master election logs
CREATE TABLE master_election_logs (
    id INTEGER PRIMARY KEY,
    election_id TEXT NOT NULL,
    trigger_reason TEXT NOT NULL,
    previous_master_id TEXT,
    new_master_id TEXT NOT NULL,
    candidates TEXT, -- JSON array
    election_duration_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔧 Troubleshooting

### Common Issues

#### Issue 1: Election Loop
**Symptoms:** Continuous master elections
**Causes:** 
- Network instability
- Device priority conflicts
- Bug in election logic

**Solutions:**
- Implement election cooldown
- Add election timeout
- Log election triggers for debugging

#### Issue 2: Role Stuck
**Symptoms:** Device stuck in wrong role
**Causes:**
- Failed role transition
- Network interruption during transition
- Database inconsistency

**Solutions:**
- Implement role validation
- Add manual role override
- Check database consistency

#### Issue 3: Split Brain
**Symptoms:** Multiple masters in system
**Causes:**
- Network partition
- Election race condition
- Database replication lag

**Solutions:**
- Implement master validation
- Add conflict detection
- Use consensus algorithm

### Debug Commands
```bash
# Check current master
curl -X GET http://localhost:5000/api/sync/master

# Trigger manual election
curl -X POST http://localhost:5000/api/sync/election/trigger

# Check device roles
curl -X GET http://localhost:5000/api/device/roles

# View election logs
curl -X GET http://localhost:5000/api/sync/master-election-logs
```

### Monitoring Metrics
- Election frequency
- Role transition success rate
- Device uptime and reliability
- Network connectivity status
- Sync operation success rate

---

## 📝 Best Practices

1. **Always validate role changes** before applying
2. **Implement graceful shutdown** for role transitions
3. **Log all role changes** for audit trail
4. **Monitor election frequency** to detect issues
5. **Test failover scenarios** regularly
6. **Implement role validation** on startup
7. **Use timeouts** for all operations
8. **Handle edge cases** in election logic

---

*This document should be updated when the role management system is modified or new scenarios are identified.* 