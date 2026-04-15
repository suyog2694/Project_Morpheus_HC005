import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static const _userKey = 'hc005_user';

  UserModel? _user;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  // ── Restore session on app start ──────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw != null) {
      _user = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      notifyListeners();
    }
  }

  // ── Register (calls server, then persists locally) ────────────
  /// Returns null on success, or an error message string on failure.
  Future<String?> register({
    required String name,
    required String ambulanceId,
    required String phone,
  }) async {
    try {
      final data = await ApiService.registerAmbulance(
        driverName: name.trim(),
        ambulanceNo: ambulanceId.trim(),
        driverPhone: phone.trim(),
      );

      final user = UserModel(
        name: data['driver_name'] ?? name.trim(),
        ambulanceId: data['ambulance_id'] ?? int.tryParse(ambulanceId.trim()) ?? 0,
        ambulanceNo: data['ambulance_no'] ?? ambulanceId.trim(),
        phone: data['driver_phone'] ?? phone.trim(),
      );
      await _persist(user);
      _user = user;
      notifyListeners();
      return null; // success
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  // ── Login (calls server, then persists locally) ───────────────
  /// Returns true on success, false on invalid credentials / error.
  Future<bool> login({
    required String ambulanceId,
    required String phone,
  }) async {
    final data = await ApiService.loginAmbulance(
      ambulanceNo: ambulanceId.trim(),
      driverPhone: phone.trim(),
    );

    if (data == null) return false;

    final user = UserModel(
      name: data['driver_name'] ?? '',
      ambulanceId: data['ambulance_id'] ?? int.tryParse(ambulanceId.trim()) ?? 0,
      ambulanceNo: data['ambulance_no'] ?? ambulanceId.trim(),
      phone: data['driver_phone'] ?? phone.trim(),
    );
    await _persist(user);
    _user = user;
    notifyListeners();
    return true;
  }

  // ── Update profile ────────────────────────────────────────────
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_user == null) return;
    final updated = UserModel(
      name: name.trim(),
      ambulanceId: _user!.ambulanceId,
      ambulanceNo: _user!.ambulanceNo,
      phone: phone.trim(),
    );
    await _persist(updated);
    _user = updated;
    notifyListeners();
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _user = null;
    notifyListeners();
  }

  Future<void> _persist(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
