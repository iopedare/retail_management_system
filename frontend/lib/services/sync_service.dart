import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/sync_event.dart';
import '../models/sync_status.dart';
import '../models/device_info.dart';
import 'database_service.dart';
import 'websocket_service.dart';
import 'offline_queue_service.dart';
import '../utils/sync_utils.dart';
import '../utils/conflict_resolver.dart';

/// Main sync service that orchestrates all sync operations
/// Handles periodic sync, immediate sync for critical events, and conflict resolution
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  // Services
  late DatabaseService _databaseService;
  late WebSocketService _webSocketService;
  late OfflineQueueService _offlineQueueService;
  late ConflictResolver _conflictResolver;

  // Sync configuration
  static const int _syncIntervalSeconds = 30;
  static const String _baseUrl = 'http://localhost:5000';
  static const String _deviceId =
      'flutter_device_001'; // TODO: Generate unique device ID

  // State management
  Timer? _periodicSyncTimer;
  SyncStatus _syncStatus = SyncStatus.disconnected;
  bool _isInitialized = false;
  StreamController<SyncStatus>? _statusController;

  /// Initialize the sync service with all required dependencies
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize services
      _databaseService = DatabaseService();
      _webSocketService = WebSocketService();
      _offlineQueueService = OfflineQueueService();
      _conflictResolver = ConflictResolver();

      await _databaseService.initialize();
      await _offlineQueueService.initialize();

      // Initialize WebSocket connection
      await _webSocketService.initialize(
        onCriticalEvent: _handleCriticalEvent,
        onAcknowledge: _handleAcknowledge,
        onConnect: _handleWebSocketConnect,
        onDisconnect: _handleWebSocketDisconnect,
      );

      _statusController = StreamController<SyncStatus>.broadcast();
      _isInitialized = true;

      // Start periodic sync
      _startPeriodicSync();

      print('SyncService initialized successfully');
    } catch (e) {
      print('Error initializing SyncService: $e');
      rethrow;
    }
  }

  /// Start periodic sync timer (every 30 seconds)
  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(
      Duration(seconds: _syncIntervalSeconds),
      (_) => _performPeriodicSync(),
    );
  }

  /// Perform periodic sync of all pending changes
  Future<void> _performPeriodicSync() async {
    if (!_isInitialized) return;

    try {
      _updateSyncStatus(SyncStatus.syncing);

      // Get all pending changes from offline queue
      final pendingEvents = await _offlineQueueService.getPendingEvents();

      if (pendingEvents.isEmpty) {
        _updateSyncStatus(SyncStatus.synced);
        return;
      }

      // Push pending events to backend
      for (final event in pendingEvents) {
        await _pushEventToBackend(event);
      }

      // Pull any new events from backend
      await _pullEventsFromBackend();

      _updateSyncStatus(SyncStatus.synced);
    } catch (e) {
      print('Error during periodic sync: $e');
      _updateSyncStatus(SyncStatus.error);
    }
  }

  /// Push a single event to the backend
  Future<void> _pushEventToBackend(SyncEvent event) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sync/push'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'event_type': event.eventType,
          'payload': event.payload,
          'device_id': _deviceId,
          'timestamp': event.timestamp.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        // Mark event as synced
        await _offlineQueueService.markEventAsSynced(event.id);

        // If this is a critical event, broadcast via WebSocket
        if (event.isCritical) {
          _webSocketService.emitCriticalEvent(event);
        }
      } else {
        throw Exception('Failed to push event: ${response.statusCode}');
      }
    } catch (e) {
      print('Error pushing event to backend: $e');
      // Event remains in offline queue for retry
      rethrow;
    }
  }

  /// Pull events from backend
  Future<void> _pullEventsFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/sync/pull?device_id=$_deviceId'),
      );

      if (response.statusCode == 200) {
        final events = jsonDecode(response.body) as List;

        for (final eventData in events) {
          final event = SyncEvent.fromJson(eventData);
          await _processIncomingEvent(event);
        }
      }
    } catch (e) {
      print('Error pulling events from backend: $e');
    }
  }

  /// Process incoming event from backend
  Future<void> _processIncomingEvent(SyncEvent event) async {
    try {
      // Check for conflicts
      final conflict = await _conflictResolver.checkForConflict(event);

      if (conflict != null) {
        // Resolve conflict using backend resolution
        final resolvedEvent = await _conflictResolver.resolveConflict(conflict);
        await _applyEventToLocalDatabase(resolvedEvent);
      } else {
        // No conflict, apply directly
        await _applyEventToLocalDatabase(event);
      }
    } catch (e) {
      print('Error processing incoming event: $e');
    }
  }

  /// Apply event to local database
  Future<void> _applyEventToLocalDatabase(SyncEvent event) async {
    try {
      switch (event.eventType) {
        case 'product_update':
          await _databaseService.updateProduct(event.payload);
          break;
        case 'inventory_update':
          await _databaseService.updateInventory(event.payload);
          break;
        case 'order_create':
          await _databaseService.createOrder(event.payload);
          break;
        // Add more event types as needed
        default:
          print('Unknown event type: ${event.eventType}');
      }
    } catch (e) {
      print('Error applying event to local database: $e');
    }
  }

  /// Handle critical event from WebSocket
  void _handleCriticalEvent(Map<String, dynamic> eventData) {
    final event = SyncEvent.fromJson(eventData);
    _processIncomingEvent(event);
  }

  /// Handle acknowledge event from WebSocket
  void _handleAcknowledge(Map<String, dynamic> data) {
    // Update sync status based on acknowledgement
    print('Received acknowledge: $data');
  }

  /// Handle WebSocket connection
  void _handleWebSocketConnect() {
    _updateSyncStatus(SyncStatus.connected);
  }

  /// Handle WebSocket disconnection
  void _handleWebSocketDisconnect() {
    _updateSyncStatus(SyncStatus.disconnected);
  }

  /// Update sync status and notify listeners
  void _updateSyncStatus(SyncStatus status) {
    _syncStatus = status;
    _statusController?.add(status);
  }

  /// Get current sync status
  SyncStatus get syncStatus => _syncStatus;

  /// Stream of sync status updates
  Stream<SyncStatus> get statusStream =>
      _statusController?.stream ?? Stream.empty();

  /// Queue an event for sync (for immediate or periodic sync)
  Future<void> queueEvent(SyncEvent event) async {
    if (!_isInitialized) {
      throw Exception('SyncService not initialized');
    }

    // Add to offline queue
    await _offlineQueueService.addEvent(event);

    // If critical event, sync immediately
    if (event.isCritical) {
      await _performImmediateSync(event);
    }
  }

  /// Perform immediate sync for critical events
  Future<void> _performImmediateSync(SyncEvent event) async {
    try {
      await _pushEventToBackend(event);
      _webSocketService.emitCriticalEvent(event);
    } catch (e) {
      print('Error during immediate sync: $e');
      // Event remains in offline queue for periodic sync retry
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    final pendingCount = await _offlineQueueService.getPendingEventCount();
    final syncedCount = await _offlineQueueService.getSyncedEventCount();

    return {
      'pending_events': pendingCount,
      'synced_events': syncedCount,
      'sync_status': _syncStatus.toString(),
      'device_id': _deviceId,
    };
  }

  /// Dispose resources
  void dispose() {
    _periodicSyncTimer?.cancel();
    _statusController?.close();
    _webSocketService.dispose();
    _isInitialized = false;
  }
}
