import 'dart:async';
import 'package:flutter/material.dart';
import '../models/emergency.dart';
import 'api_service.dart';

class MissionController extends ChangeNotifier {
  Emergency? currentEmergency;
  String? assignedHospital;
  int missionStage = 0;

  Timer? _pollTimer;
  String? _ambulanceId;

  /// Start polling the server for pending emergencies every 5 seconds.
  void startPolling(String ambulanceId) {
    _ambulanceId = ambulanceId;
    // Poll immediately, then every 5 seconds
    _poll();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll() async {
    if (_ambulanceId == null || currentEmergency != null) return;

    final data = await ApiService.getPendingEmergency(_ambulanceId!);
    if (data != null) {
      receiveEmergency(Emergency.fromJson(data));
    }
  }

  // called when backend assigns emergency
  void receiveEmergency(Emergency emergency) {
    currentEmergency = emergency;
    missionStage = 0;
    assignedHospital = null;
    notifyListeners();
  }

  // called when hospital confirms from backend
  void hospitalConfirmed(String hospitalName) {
    assignedHospital = hospitalName;
    notifyListeners();
  }

  // driver actions
  void nextStage() {
    if (missionStage < 3) {
      missionStage++;
      notifyListeners();
    }
  }

  void clearMission() {
    currentEmergency = null;
    assignedHospital = null;
    missionStage = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
