import 'dart:async';
import 'package:flutter/material.dart';
import '../models/emergency.dart';
import 'api_service.dart';
import 'socket_service.dart';

class MissionController extends ChangeNotifier {
  Emergency? currentEmergency;
  String? assignedHospital;
  String? assignedHospitalAddress;
  double? hospitalLat;
  double? hospitalLng;
  int missionStage = 0;

  Timer? _pollTimer;
  int? _ambulanceId;
  final SocketService _socketService = SocketService();

  /// Start polling AND Socket.IO for pending emergencies.
  void startPolling(int ambulanceId) {
    _ambulanceId = ambulanceId;

    // Connect to Socket.IO for real-time updates
    _initSocket();

    // Also poll as fallback every 5 seconds
    _poll();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  void _initSocket() {
    if (_ambulanceId == null) return;
    _socketService.connect(_ambulanceId!);

    // Handle new assignment via Socket.IO
    _socketService.setOnNewAssignment((emergency) {
      print('[MissionController] Received new assignment via Socket.IO');
      receiveEmergency(emergency);
    });

    // Handle hospital assignment via Socket.IO
    _socketService.setOnHospitalAssigned((data) {
      print('[MissionController] Received hospital assignment via Socket.IO');
      final hospital = data['hospital'] as Map<String, dynamic>?;
      if (hospital != null) {
        hospitalConfirmed(
          hospital['name']?.toString() ?? 'Hospital',
          hospital['address']?.toString(),
          (hospital['latitude'] as num?)?.toDouble(),
          (hospital['longitude'] as num?)?.toDouble(),
        );
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _socketService.disconnect();
  }

  Future<void> _poll() async {
    if (_ambulanceId == null || currentEmergency != null) return;

    final data = await ApiService.getPendingEmergency(_ambulanceId.toString());
    if (data != null) {
      receiveEmergency(Emergency.fromJson(data));
    }
  }

  /// Respond to the current emergency assignment (approve or reject).
  /// Called by dispatch_screen when user accepts/rejects.
  Future<bool> respondToEmergency(String decision) async {
    if (currentEmergency == null || _ambulanceId == null) return false;
    final result = await ApiService.respondToEmergency(
      ambulanceId: _ambulanceId.toString(),
      requestId: currentEmergency!.requestId,
      decision: decision,
    );
    return result != null;
  }

  /// Complete the mission by marking arrival at the hospital.
  Future<bool> completeMission() async {
    if (currentEmergency == null) return false;
    final result = await ApiService.markArrival(currentEmergency!.requestId);
    if (result != null) {
      missionStage = 3;
      notifyListeners();
      return true;
    }
    return false;
  }

  // called when backend assigns emergency
  void receiveEmergency(Emergency emergency) {
    currentEmergency = emergency;
    missionStage = 0;
    assignedHospital = null;
    assignedHospitalAddress = null;
    hospitalLat = null;
    hospitalLng = null;
    notifyListeners();
  }

  // called when hospital confirms from backend
  void hospitalConfirmed(String hospitalName, String? address, double? lat, double? lng) {
    assignedHospital = hospitalName;
    assignedHospitalAddress = address;
    hospitalLat = lat;
    hospitalLng = lng;
    notifyListeners();
  }

  // driver actions
  Future<void> nextStage() async {
    if (missionStage < 3) {
      missionStage++;
      notifyListeners();
      // When reaching final stage, notify backend of arrival
      if (missionStage == 3) {
        await completeMission();
      }
    }
  }

  void clearMission() {
    currentEmergency = null;
    assignedHospital = null;
    assignedHospitalAddress = null;
    hospitalLat = null;
    hospitalLng = null;
    missionStage = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
