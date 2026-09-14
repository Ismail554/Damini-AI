import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/signup_request_model.dart';
import '../repositories/signup_repository.dart';

final signupRepositoryProvider = Provider<SignupRepository>((ref) {
  return SignupRepositoryImpl();
});

class SignupState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const SignupState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  SignupState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final signupProvider = NotifierProvider<SignupNotifier, SignupState>(SignupNotifier.new);

class SignupNotifier extends Notifier<SignupState> {
  @override
  SignupState build() => const SignupState();

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      final repository = ref.read(signupRepositoryProvider);
      final response = await repository.signUp(
        SignupRequestModel(
          fullName: fullName,
          email: email,
          password: password,
        ),
      );

      if (response.success) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? "Registration failed",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}
