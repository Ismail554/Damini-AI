import 'package:Braintech/core/services/api_error_handler.dart';
import 'package:Braintech/core/services/apple_auth_service.dart';
import 'package:Braintech/core/services/google_auth_service.dart';
import 'package:Braintech/shared/global_key.dart';
import 'package:Braintech/views/auth/login/models/login_request_model.dart';
import 'package:Braintech/views/auth/login/provider/login_provider.dart';
import 'package:Braintech/views/auth/session/controllers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for GoogleAuthService
final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

/// Provider for AppleAuthService
final appleAuthServiceProvider = Provider<AppleAuthService>((ref) {
  return AppleAuthService();
});

/// State representing social authentication status.
class SocialAuthState {
  final bool isGoogleLoading;
  final bool isAppleLoading;
  final String? errorMessage;
  final LoginResponseModel? response;

  const SocialAuthState({
    this.isGoogleLoading = false,
    this.isAppleLoading = false,
    this.errorMessage,
    this.response,
  });

  bool get isLoading => isGoogleLoading || isAppleLoading;

  SocialAuthState copyWith({
    bool? isGoogleLoading,
    bool? isAppleLoading,
    String? errorMessage,
    LoginResponseModel? response,
    bool clearError = false,
  }) {
    return SocialAuthState(
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isAppleLoading: isAppleLoading ?? this.isAppleLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      response: response ?? this.response,
    );
  }
}

/// Notifier managing social authentication flows (Google and Apple).
class SocialAuthNotifier extends Notifier<SocialAuthState> {
  @override
  SocialAuthState build() => const SocialAuthState();

  /// Initiates the Google Sign-In flow, sends the idToken to the backend,
  /// persists tokens, updates session state, and returns the [LoginResponseModel].
  ///
  /// Returns `null` if the user cancelled the Google Sign-In prompt.
  Future<LoginResponseModel?> signInWithGoogle() async {
    if (state.isLoading) return null;
    state = state.copyWith(isGoogleLoading: true, clearError: true);

    try {
      final googleService = ref.read(googleAuthServiceProvider);
      final result = await googleService.signIn();

      if (result == null) {
        // User cancelled
        state = state.copyWith(isGoogleLoading: false);
        return null;
      }

      final repo = ref.read(loginRepositoryProvider);
      final response = await repo.loginWithGoogle(result.idToken);

      if (response.success) {
        final role = response.role?.trim().toLowerCase();
        final validRole = GlobalKeys.isValidRole(role) ? role : null;
        ref.read(sessionProvider.notifier).updateSession(
              isAuthenticated: true,
              userRole: validRole,
              isApiConnected: true,
            );
        state = state.copyWith(
          isGoogleLoading: false,
          response: response,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isGoogleLoading: false,
          errorMessage: response.message,
          response: response,
        );
      }
      return response;
    } catch (e) {
      final errorMsg = e is ApiException
          ? e.message
          : (e is AppException
              ? e.message
              : (e is AppleSignInNotAvailableException
                  ? e.message
                  : e.toString()));
      state = state.copyWith(
        isGoogleLoading: false,
        errorMessage: errorMsg,
      );
      return LoginResponseModel(success: false, message: errorMsg);
    }
  }

  /// Initiates the Sign in with Apple flow, sends credentials to the backend,
  /// persists tokens, updates session state, and returns the [LoginResponseModel].
  ///
  /// Returns `null` if the user cancelled the Apple Sign-In prompt.
  Future<LoginResponseModel?> signInWithApple() async {
    if (state.isLoading) return null;
    state = state.copyWith(isAppleLoading: true, clearError: true);

    try {
      final appleService = ref.read(appleAuthServiceProvider);
      final result = await appleService.signIn();

      if (result == null) {
        // User cancelled
        state = state.copyWith(isAppleLoading: false);
        return null;
      }

      final repo = ref.read(loginRepositoryProvider);
      final response = await repo.loginWithApple(
        idToken: result.idToken,
        firstName: result.firstName,
        lastName: result.lastName,
      );

      if (response.success) {
        final role = response.role?.trim().toLowerCase();
        final validRole = GlobalKeys.isValidRole(role) ? role : null;
        ref.read(sessionProvider.notifier).updateSession(
              isAuthenticated: true,
              userRole: validRole,
              isApiConnected: true,
            );
        state = state.copyWith(
          isAppleLoading: false,
          response: response,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isAppleLoading: false,
          errorMessage: response.message,
          response: response,
        );
      }
      return response;
    } catch (e) {
      final errorMsg = e is ApiException
          ? e.message
          : (e is AppException
              ? e.message
              : (e is AppleSignInNotAvailableException
                  ? e.message
                  : e.toString()));
      state = state.copyWith(
        isAppleLoading: false,
        errorMessage: errorMsg,
      );
      return LoginResponseModel(success: false, message: errorMsg);
    }
  }

  /// Resets any current error message in the state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final socialAuthProvider =
    NotifierProvider<SocialAuthNotifier, SocialAuthState>(
  SocialAuthNotifier.new,
);
