import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ambulance.dart';
import '../models/hospital.dart';
import '../models/stabilization_center.dart';
import 'api_config.dart';

class ApiService {
  // ── Ambulances ──────────────────────────────────────────
  static Future<List<Ambulance>> getAllAmbulances({String? status}) async {
    try {
      final uri = status != null
          ? Uri.parse('${ApiConfig.baseUrl}/ambulance?status=$status')
          : Uri.parse('${ApiConfig.baseUrl}/ambulance');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final Map<String, dynamic> wrapper = body['data'] ?? {};
        final List data = wrapper['ambulances'] ?? [];
        return data.map((e) => Ambulance.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('getAllAmbulances error: $e');
      return [];
    }
  }

  static Future<List<Ambulance>> getAvailableAmbulances() {
    return getAllAmbulances(status: 'Available');
  }

  // ── Hospitals (with resources) ──────────────────────────
  static Future<List<Hospital>> getAllHospitals({
    bool availableOnly = false,
  }) async {
    try {
      final uri = availableOnly
          ? Uri.parse('${ApiConfig.baseUrl}/hospital/all?available_only=true')
          : Uri.parse('${ApiConfig.baseUrl}/hospital/all');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final Map<String, dynamic> wrapper = body['data'] ?? {};
        final List data = wrapper['hospitals'] ?? [];
        return data.map((e) => Hospital.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('getAllHospitals error: $e');
      return [];
    }
  }

  // ── Resource Summary ────────────────────────────────────
  static Future<Map<String, dynamic>?> getResourceSummary() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/hospital/resource-summary');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── Stabilization Centers ──────────────────────────────
  // (if you add a route on the server later)
  static Future<List<StabilizationCenter>> getStabilizationCenters() async {
    // Placeholder – no dedicated public route yet
    return [];
  }

  // ── Emergency Request ──────────────────────────────────
  /// POST /api/patient/emergency
  /// Creates a new emergency and assigns nearest ambulance.
  /// Returns the full JSON body on success, or null on failure.
  static Future<Map<String, dynamic>?> createEmergency({
    required double patientLat,
    required double patientLng,
    String? description,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/patient/emergency');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'patient_lat': patientLat,
              'patient_lng': patientLng,
              if (description != null && description.isNotEmpty)
                'description': description,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
      print('createEmergency status ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      print('createEmergency error: $e');
      return null;
    }
  }
}
