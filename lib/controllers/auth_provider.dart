import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  
  String? _userRole;
  String? get userRole => _userRole;

  Future<bool> checkAuthStatus() async {
    final token = await StorageService.getToken();
    _userRole = await StorageService.getRole();
    _isAuthenticated = token != null;
    notifyListeners();
    return _isAuthenticated;
  }

  Future<void> login(String email, String password) async {
    _isLoading = true; notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    await StorageService.saveToken("mock_jwt_token");
    await StorageService.saveUuid("mock_uuid");
    _userRole = await StorageService.getRole();
    _isAuthenticated = true; 
    _isLoading = false; 
    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true; notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false; notifyListeners();
  }

  Future<void> verifyOtp(String code) async {
    _isLoading = true; notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    await StorageService.saveToken("mock_jwt_token");
    await StorageService.saveUuid("mock_uuid");
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    _isLoading = true; notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false; notifyListeners();
  }

  Future<void> resetPassword(String password) async {
    _isLoading = true; notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false; notifyListeners();
  }

  Future<void> setRole(String role) async {
    _isLoading = true; notifyListeners();
    await StorageService.saveRole(role);
    _userRole = role;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    _userRole = null;
    _isAuthenticated = false; 
    notifyListeners();
  }
}

