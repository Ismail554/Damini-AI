import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../shared/global_key.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _userRole;
  String? get userRole => _userRole;

  bool _isApiConnected = true;
  bool get isApiConnected => _isApiConnected;

  Future<bool> checkAuthStatus() async {
    final token = await StorageService.getToken();
    _userRole = await StorageService.getRole();
    _isApiConnected = await StorageService.getIsApiConnected();
    _isAuthenticated = token != null;
    notifyListeners();
    return _isAuthenticated;
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    await StorageService.saveToken("mock_jwt_token");
    await StorageService.saveUuid("mock_uuid");
    await StorageService.saveIsApiConnected(true);
    _isApiConnected = true;

    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail == GlobalKeys.demoInvestorEmail) {
      _userRole = GlobalKeys.investorRole;
      await StorageService.saveRole(GlobalKeys.investorRole);
    } else if (cleanEmail == GlobalKeys.demoSponsorEmail) {
      _userRole = GlobalKeys.sponsorRole;
      await StorageService.saveRole(GlobalKeys.sponsorRole);
    } else {
      _userRole = await StorageService.getRole();
    }

    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> verifyOtp(String code) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    await StorageService.saveToken("mock_jwt_token");
    await StorageService.saveUuid("mock_uuid");
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetPassword(String password) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setRole(String role) async {
    if (!GlobalKeys.isValidRole(role)) return;
    _isLoading = true;
    notifyListeners();
    await StorageService.saveRole(role);
    _userRole = role;
    _isLoading = false;
    notifyListeners();
  }

  bool validateCurrentRole() {
    return GlobalKeys.validateKeyResponse(
      isApiConnected: _isApiConnected,
      role: _userRole,
    );
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    _userRole = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
