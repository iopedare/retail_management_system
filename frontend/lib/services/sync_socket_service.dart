import 'package:socket_io_client/socket_io_client.dart' as IO;

class SyncSocketService {
  IO.Socket? socket;

  void connect(String wsUrl, String deviceId, String role) {
    socket = IO.io(wsUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      // Enable reconnection logic
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });
    socket?.connect();

    socket?.onConnect((_) {
      print('Connected to backend');
      registerDevice(deviceId, role); // Always register after (re)connect
    });

    socket?.on('critical_event', (data) {
      print('Received critical_event: $data');
      // TODO: Handle event in app logic
    });

    socket?.on('registered', (data) {
      print('Device registered: $data');
    });

    socket?.on('acknowledged', (data) {
      print('Acknowledgement received: $data');
    });

    socket?.on('error', (data) {
      print('Socket error: $data');
    });

    socket?.on('disconnect', (_) {
      print('Socket disconnected, will attempt to reconnect if enabled');
    });
  }

  void registerDevice(String deviceId, String role) {
    socket?.emit('register_device', {'device_id': deviceId, 'role': role});
  }

  void acknowledge(String eventType, String deviceId) {
    socket?.emit('acknowledge', {'event_type': eventType, 'device_id': deviceId});
  }

  void removeAllListeners() {
    if (socket != null) {
      socket!.clearListeners();
    }
  }

  void disconnect() {
    socket?.disconnect();
  }
}
