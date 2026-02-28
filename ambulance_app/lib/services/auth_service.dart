import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static const _userKey = 'hc005_user';

  UserModel? _user;
  UserModel? get user     => _user;
  bool get isLoggedIn     => _user != null;

  // ── Restore session on app start ──────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_userKey);
    if (raw != null) {
      _user = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      notifyListeners();
    }
  }

  // ── Register ──────────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String ambulanceId,
    required String phone,
  }) async {
    final user = UserModel(
      name:        name.trim(),
      ambulanceId: ambulanceId.trim(),
      phone:       phone.trim(),
    );
    await _persist(user);
    _user = user;
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────
  // Matches stored ambulanceId + phone. Returns false if no match.
  Future<bool> login({
    required String ambulanceId,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_userKey);
    if (raw == null) return false;

    final stored = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    if (stored.ambulanceId == ambulanceId.trim() &&
        stored.phone       == phone.trim()) {
      _user = stored;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── Update profile ────────────────────────────────────────────
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_user == null) return;
    final updated = UserModel(
      name:        name.trim(),
      ambulanceId: _user!.ambulanceId,
      phone:       phone.trim(),
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