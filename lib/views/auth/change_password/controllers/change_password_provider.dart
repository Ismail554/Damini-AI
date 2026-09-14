import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
export '../models/change_password_model.dart';
import '../repositories/change_password_repository.dart';

final changePasswordRepositoryProvider =
    Provider<ChangePasswordRepository>((ref) {
  return ChangePasswordRepositoryImpl();
});

class ChangePasswordState {
  final bool obscureCurrent;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool isLoading;

  const ChangePasswordState({
    this.obscureCurrent = true,
    this.obscureNew = true,
    this.obscureConfirm = true,
    this.isLoading = false,
  });

  ChangePasswordState copyWith({
    bool? obscureCurrent,
    bool? obscureNew,
    bool? obscureConfirm,
    bool? isLoading,
  }) {
    return ChangePasswordState(
      obscureCurrent: obscureCurrent ?? this.obscureCurrent,
      obscureNew: obscureNew ?? this.obscureNew,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final changePasswordProvider = NotifierProvider.autoDispose<
    ChangePasswordNotifier, ChangePasswordState>(
  ChangePasswordNotifier.new,
);

class ChangePasswordNotifier extends Notifier<ChangePasswordState> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  ChangePasswordState build() {
    ref.onDispose(() {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    });
    return const ChangePasswordState();
  }

  void toggleObscureCurrent() {
    state = state.copyWith(obscureCurrent: !state.obscureCurrent);
  }

  void toggleObscureNew() {
    state = state.copyWith(obscureNew: !state.obscureNew);
  }

  void toggleObscureConfirm() {
    state = state.copyWith(obscureConfirm: !state.obscureConfirm);
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
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 1000));
    state = state.copyWith(isLoading: false);
    return true;
  }
}
