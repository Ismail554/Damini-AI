import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../models/change_password_model.dart';
export '../models/change_password_model.dart';
import '../repositories/change_password_repository.dart';

final changePasswordRepositoryProvider =
    Provider<ChangePasswordRepository>((ref) {
  return ChangePasswordRepositoryImpl(ref.watch(apiServiceProvider));
});

class ChangePasswordState {
  final bool obscureCurrent;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool isLoading;
  final String? errorMessage;

  const ChangePasswordState({
    this.obscureCurrent = true,
    this.obscureNew = true,
    this.obscureConfirm = true,
    this.isLoading = false,
    this.errorMessage,
  });

  ChangePasswordState copyWith({
    bool? obscureCurrent,
    bool? obscureNew,
    bool? obscureConfirm,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      obscureCurrent: obscureCurrent ?? this.obscureCurrent,
      obscureNew: obscureNew ?? this.obscureNew,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(changePasswordRepositoryProvider);
      final success = await repo.changePassword(
        ChangePasswordModel(
          currentPassword: currentPasswordController.text.trim(),
          newPassword: newPasswordController.text.trim(),
          confirmPassword: confirmPasswordController.text.trim(),
        ),
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}
