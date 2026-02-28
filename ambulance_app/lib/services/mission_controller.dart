import 'package:flutter/material.dart';
import '../models/emergency.dart';

class MissionController extends ChangeNotifier {

  Emergency? currentEmergency;
  String? assignedHospital;
  int missionStage = 0;

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
}