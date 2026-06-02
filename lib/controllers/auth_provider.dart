import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> checkAuthStatus() async {
    final token = await StorageService.getToken();
    _isAuthenticated = token != null;
    notifyListeners();
    return _isAuthenticated;
  }

  Future<void> login(String email, String password) async {
    _isLoading = true; notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    await StorageService.saveToken("mock_jwt_token");
    await StorageService.saveUuid("mock_uuid");
    _isAuthenticated = true; _isLoading = false; notifyListeners();
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    _isAuthenticated = false; notifyListeners();
  }
}
