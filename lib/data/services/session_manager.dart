import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Persistent session store backed by [SharedPreferences].
///
/// Registered as `Get.put(SessionManager(), permanent: true)` in
/// [InitialBindings] before any controller that depends on it.
///
/// Usage:
/// ```dart
/// final session = Get.find<SessionManager>();
/// await session.saveSession(user: user, token: token);
/// final user = await session.loadUser();   // null if none saved
/// await session.clearSession();
/// ```
class SessionManager extends GetxService {
  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';

  late SharedPreferences _prefs;

  /// Initializes SharedPreferences and returns the service instance.
  Future<SessionManager> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── Write ────────────────────────────────────────────────────────────────

  /// Persists the authenticated [user] and their [token].
  /// Token is also stored separately for quick header injection.
  Future<void> saveSession({
    required UserModel user,
    required String token,
  }) async {
    final userWithToken = user..token = token; // ensure token is on model
    await Future.wait([
      _prefs.setString(_keyToken, token),
      _prefs.setString(_keyUser, jsonEncode(userWithToken.toJson())),
    ]);
  }

  /// Removes all persisted auth data (logout).
  Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(_keyToken),
      _prefs.remove(_keyUser),
    ]);
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  /// Returns the saved JWT token, or `null` if not logged in.
  String? get token => _prefs.getString(_keyToken);

  /// Returns the saved [UserModel], or `null` if no session exists.
  UserModel? get savedUser {
    final raw = _prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// `true` when a valid token is stored.
  bool get hasSession => (token ?? '').isNotEmpty;
}
