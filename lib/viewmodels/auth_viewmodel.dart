import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user = AuthStorage.currentUser;
  String? _token = AuthStorage.token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // Cek token dan sesi saat app pertama kali dibuka
  Future<bool> checkAuthStatus() async {
    _token = await AuthStorage.getToken();
    _user = await AuthStorage.getUser();
    notifyListeners();

    if (isAuthenticated) {
      // Background sync profile secara non-blocking
      refreshProfile();
      return true;
    }
    return false;
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      _token = response.resolvedToken ?? await AuthStorage.getToken();
      _user = response.resolvedUser ?? await AuthStorage.getUser();

      if (_token != null && _token!.isNotEmpty) {
        await AuthStorage.saveSession(token: _token!, user: _user);
      }

      // Simpan email agar pengguna tidak perlu mengetik ulang
      await AuthStorage.saveLastEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(request);
      _token = response.resolvedToken ?? await AuthStorage.getToken();
      _user = response.resolvedUser ?? await AuthStorage.getUser();

      if (_token != null && _token!.isNotEmpty) {
        await AuthStorage.saveSession(token: _token!, user: _user);
      }

      await AuthStorage.saveLastEmail(request.email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh Profile
  Future<void> refreshProfile() async {
    try {
      final user = await _authService.getProfile();
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    } catch (_) {
      // Pertahankan sesi lokal aktif jika terjadi kendala jaringan saat sync background
    }
  }

  // Update Profile (Nama / Email)
  Future<bool> updateProfile({required String name, String? email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        email: email,
      );
      if (updatedUser != null) {
        _user = updatedUser;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Profile Photo
  Future<bool> updateProfilePhoto(String base64Image) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateProfilePhoto(base64Image);
      await refreshProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _token = null;
    _user = null;

    _isLoading = false;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// Backward compatibility alias
typedef AuthProvider = AuthViewModel;
