import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keyLastEmail = 'last_login_email';
  static const String _keyRememberMe = 'remember_me_preference';

  static SharedPreferences? _prefs;
  static String? _cachedToken;
  static User? _cachedUser;

  static String? get token => _cachedToken;
  static User? get currentUser => _cachedUser;

  /// Inisialisasi awal saat aplikasi start (memastikan token langsung siap di memori)
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _cachedToken = _prefs?.getString(_keyToken);

    final jsonStr = _prefs?.getString(_keyUser);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map) {
          _cachedUser = User.fromJson(Map<String, dynamic>.from(decoded));
          if (_cachedUser != null) {
            _prefs?.setString(_keyUser, jsonEncode(_cachedUser!.toJson()));
          }
        }
      } catch (_) {
        _cachedUser = null;
      }
    }
  }

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Token Management
  static Future<void> saveToken(String token) async {
    _cachedToken = token;
    final prefs = await _getPrefs();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }
    final prefs = await _getPrefs();
    _cachedToken = prefs.getString(_keyToken);
    return _cachedToken;
  }

  static Future<void> removeToken() async {
    _cachedToken = null;
    final prefs = await _getPrefs();
    await prefs.remove(_keyToken);
  }

  // User Management
  static Future<void> saveUser(User user) async {
    _cachedUser = user;
    final prefs = await _getPrefs();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    if (_cachedUser != null) {
      return _cachedUser;
    }
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keyUser);
    if (jsonStr == null || jsonStr.isEmpty) {
      _cachedUser = null;
      return null;
    }
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map) {
        _cachedUser = User.fromJson(Map<String, dynamic>.from(decoded));
        if (_cachedUser != null) {
          prefs.setString(_keyUser, jsonEncode(_cachedUser!.toJson()));
        }
        return _cachedUser;
      }
      return null;
    } catch (_) {
      _cachedUser = null;
      return null;
    }
  }

  static Future<void> removeUser() async {
    _cachedUser = null;
    final prefs = await _getPrefs();
    await prefs.remove(_keyUser);
  }

  // Combined Session
  static Future<void> saveSession({required String token, User? user}) async {
    await saveToken(token);
    if (user != null) {
      await saveUser(user);
    }
  }

  static Future<void> clearSession() async {
    _cachedToken = null;
    _cachedUser = null;
    final prefs = await _getPrefs();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  // Remember Me & Last Email Persistence
  static Future<void> saveLastEmail(String email) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyLastEmail, email);
  }

  static Future<String?> getLastEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyLastEmail);
  }

  static Future<void> setRememberMe(bool remember) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyRememberMe, remember);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyRememberMe) ?? true;
  }

  // Dark Mode Preference
  static Future<bool> isDarkMode() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyDarkMode, isDark);
  }
}
