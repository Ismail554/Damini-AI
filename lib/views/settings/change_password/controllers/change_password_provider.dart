import 'package:flutter/material.dart';

class ChangePasswordProvider extends ChangeNotifier {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  bool get obscureCurrent => _obscureCurrent;
  bool get obscureNew => _obscureNew;
  bool get obscureConfirm => _obscureConfirm;
  bool get isLoading => _isLoading;

  void toggleObscureCurrent() {
    _obscureCurrent = !_obscureCurrent;
    notifyListeners();
  }

  void toggleObscureNew() {
    _obscureNew = !_obscureNew;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  String? validateForm() {
    if (currentPasswordController.text.isEmpty) {
      return "Please enter your current password";
    }
    if (newPasswordController.text.length < 6) {
      return "New password must be at least 6 characters";
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      return "New passwords do not match";
    }
    return null;
  }

  Future<bool> changePassword() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API network call
    await Future.delayed(const Duration(milliseconds: 1000));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
