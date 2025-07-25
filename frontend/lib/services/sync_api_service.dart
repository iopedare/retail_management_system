import 'dart:convert';
import 'package:http/http.dart' as http;

class SyncApiService {
  final String baseUrl;

  SyncApiService(this.baseUrl);

  Future<http.Response> pushSyncEvent(Map<String, dynamic> event) async {
    return await http.post(
      Uri.parse('$baseUrl/sync/push'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(event),
    );
  }

  Future<http.Response> pullSyncEvents() async {
    return await http.get(Uri.parse('$baseUrl/sync/pull'));
  }

  Future<http.Response> getSyncStatus() async {
    return await http.get(Uri.parse('$baseUrl/sync/status'));
  }

  // Registers the device with the backend via REST API
  Future<http.Response> registerDevice(String deviceId, String role) async {
    return await http.post(
      Uri.parse('$baseUrl/device/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'device_id': deviceId, 'role': role}),
    );
  }
}
