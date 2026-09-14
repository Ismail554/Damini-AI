import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forgot_password_model.dart';
import '../repositories/forgot_password_repository.dart';

final forgotPasswordRepositoryProvider = Provider<ForgotPasswordRepository>((ref) {
  return ForgotPasswordRepositoryImpl();
});

class ForgotPasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const ForgotPasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final forgotPasswordProvider =
    NotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
  ForgotPasswordNotifier.new,
);

class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<bool> sendRecoveryEmail(String email) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      final repository = ref.read(forgotPasswordRepositoryProvider);
      final response = await repository.forgotPassword(
        ForgotPasswordRequestModel(email: email),
      );

      if (response.success) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? "Failed to send recovery code",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
