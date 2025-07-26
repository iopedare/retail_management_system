/// Enum representing the current sync status of the application
///
/// This enum is used to provide real-time feedback about the sync state
/// and is broadcast via streams to update the UI accordingly
enum SyncStatus {
  /// Initial state before sync service is initialized
  disconnected,

  /// Sync service is currently initializing
  initializing,

  /// Connected to backend and ready for sync operations
  connected,

  /// Currently performing a sync operation
  syncing,

  /// Last sync operation completed successfully
  synced,

  /// An error occurred during sync operations
  error,

  /// Offline mode - no connection to backend
  offline,

  /// Conflict detected and being resolved
  resolving,
}

/// Extension to provide human-readable descriptions for sync status
extension SyncStatusExtension on SyncStatus {
  /// Get a human-readable description of the sync status
  String get description {
    switch (this) {
      case SyncStatus.disconnected:
        return 'Disconnected';
      case SyncStatus.initializing:
        return 'Initializing...';
      case SyncStatus.connected:
        return 'Connected';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.resolving:
        return 'Resolving conflicts...';
    }
  }

  /// Check if the status indicates an error state
  bool get isError => this == SyncStatus.error;

  /// Check if the status indicates a syncing state
  bool get isSyncing =>
      this == SyncStatus.syncing || this == SyncStatus.resolving;

  /// Check if the status indicates a connected state
  bool get isConnected =>
      this == SyncStatus.connected || this == SyncStatus.synced;

  /// Check if the status indicates an offline state
  bool get isOffline =>
      this == SyncStatus.offline || this == SyncStatus.disconnected;
}
