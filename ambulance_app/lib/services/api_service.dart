import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  /// GET /api/ambulance/:ambulanceId/pending
  /// Returns the pending emergency map if one exists, or null.
  static Future<Map<String, dynamic>?> getPendingEmergency(
    String ambulanceId,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/ambulance/$ambulanceId/pending',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body['data'] as Map<String, dynamic>?;
        if (data != null && data['has_emergency'] == true) {
          return data['emergency'] as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      print('getPendingEmergency error: $e');
      return null;
    }
  }

  /// POST /api/ambulance/register
  /// Returns the created ambulance data, or throws on failure.
  static Future<Map<String, dynamic>> registerAmbulance({
    required String driverName,
    required String ambulanceNo,
    required String driverPhone,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/ambulance/register');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'driver_name': driverName,
            'ambulance_no': ambulanceNo,
            'driver_phone': driverPhone,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final body = json.decode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return body['data'] as Map<String, dynamic>;
    }

    throw Exception(body['message'] ?? 'Registration failed');
  }

  /// POST /api/ambulance/login
  /// Returns ambulance data on success, or null on invalid credentials.
  static Future<Map<String, dynamic>?> loginAmbulance({
    required String ambulanceNo,
    required String driverPhone,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ambulance/login');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'ambulance_no': ambulanceNo,
              'driver_phone': driverPhone,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return body['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('loginAmbulance error: $e');
      return null;
    }
  }

  /// POST /api/ambulance/:ambulanceId/respond
  /// Approve or reject an emergency assignment.
  /// decision: "approve" | "reject"
  static Future<Map<String, dynamic>?> respondToEmergency({
    required String ambulanceId,
    required String requestId,
    required String decision,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/ambulance/$ambulanceId/respond',
      );
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'requestId': requestId,
              'decision': decision,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
      print('respondToEmergency status ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      print('respondToEmergency error: $e');
      return null;
    }
  }

  /// PUT /api/ambulance/:ambulanceId/location
  /// Update ambulance GPS location.
  static Future<Map<String, dynamic>?> updateLocation({
    required String ambulanceId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/ambulance/$ambulanceId/location',
      );
      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('updateLocation error: $e');
      return null;
    }
  }

  /// POST /api/ambulance/arrival
  /// Mark arrival at hospital/stabilization center and complete emergency.
  static Future<Map<String, dynamic>?> markArrival(String requestId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ambulance/arrival');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'requestId': requestId}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
      print('markArrival status ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      print('markArrival error: $e');
      return null;
    }
  }
}
