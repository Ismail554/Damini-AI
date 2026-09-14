import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reset_password_model.dart';
import '../repositories/reset_password_repository.dart';

final resetPasswordRepositoryProvider = Provider<ResetPasswordRepository>((ref) {
  return ResetPasswordRepositoryImpl();
});

class ResetPasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const ResetPasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final resetPasswordProvider =
    NotifierProvider<ResetPasswordNotifier, ResetPasswordState>(
  ResetPasswordNotifier.new,
);

class ResetPasswordNotifier extends Notifier<ResetPasswordState> {
  @override
  ResetPasswordState build() => const ResetPasswordState();

  Future<bool> resetPassword(String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      final repository = ref.read(resetPasswordRepositoryProvider);
      final response = await repository.resetPassword(
        ResetPasswordRequestModel(newPassword: newPassword),
      );

      if (response.success) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? "Password reset failed",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
