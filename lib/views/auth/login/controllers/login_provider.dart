import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../session/controllers/session_provider.dart';
import '../models/login_request_model.dart';
import '../repositories/login_repository.dart';

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  return LoginRepositoryImpl();
});

class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? userRole;

  const LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.userRole,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? userRole,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      userRole: userRole ?? this.userRole,
    );
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(LoginNotifier.new);

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      final repository = ref.read(loginRepositoryProvider);
      final response = await repository.login(
        LoginRequestModel(email: email, password: password),
      );

      if (response.success) {
        // Sync with global session provider
        ref.read(sessionProvider.notifier).updateSession(
          isAuthenticated: true,
          userRole: response.role,
          isApiConnected: true,
        );

        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          userRole: response.role,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? "Login failed",
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
