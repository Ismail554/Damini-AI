import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/global_key.dart';
import '../models/session_model.dart';
import '../models/switch_role_response_model.dart';
import '../repositories/switch_role_repository.dart';

export '../models/session_model.dart';
export '../models/switch_role_response_model.dart';

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

// Aliases for compatibility
typedef AuthState = SessionState;
typedef AuthNotifier = SessionNotifier;
final authProvider = sessionProvider;

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  Future<bool> checkAuthStatus() async {
    final token = await StorageService.getToken();
    final role = await StorageService.getRole();
    final isApiConnected = await StorageService.getIsApiConnected();
    final isAuth = token != null && token.isNotEmpty;
    final normalizedRole = (role != null && GlobalKeys.isValidRole(role.toLowerCase()))
        ? role.toLowerCase()
        : null;
    state = state.copyWith(
      isAuthenticated: isAuth,
      userRole: normalizedRole,
      isApiConnected: isApiConnected,
    );
    return isAuth;
  }

  void updateSession({
    bool? isAuthenticated,
    String? userRole,
    bool? isApiConnected,
  }) {
    state = state.copyWith(
      isAuthenticated: isAuthenticated,
      userRole: userRole,
      isApiConnected: isApiConnected,
    );
  }

  /// Local-only role set (for onboarding flow — no API call needed).
  Future<void> setRole(String role) async {
    if (!GlobalKeys.isValidRole(role)) return;
    state = state.copyWith(isLoading: true);
    await StorageService.saveRole(role);
    state = state.copyWith(isLoading: false, userRole: role);
  }

  /// API-backed role switch (for in-app switching via AccountTypeSwitcherCard).
  Future<SwitchRoleResult> switchRole(String role) async {
    final normalized = role.trim().toLowerCase();
    if (!GlobalKeys.isValidRole(normalized)) {
      return SwitchRoleResult.failure('Invalid role.');
    }
    // Skip if already in target role
    if (state.userRole == normalized) {
      return SwitchRoleResult.failure('Already in $normalized mode.');
    }
    state = state.copyWith(isLoading: true);
    try {
      final result =
          await ref.read(switchRoleRepositoryProvider).switchRole(normalized);
      if (result.success) {
        // Save new tokens
        if (result.accessToken != null && result.accessToken!.isNotEmpty) {
          await StorageService.saveToken(result.accessToken!);
        }
        if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
          await StorageService.saveRefreshToken(result.refreshToken!);
        }
        await StorageService.saveRole(normalized);
        state = state.copyWith(isLoading: false, userRole: normalized);
      } else {
        state = state.copyWith(isLoading: false);
      }
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return SwitchRoleResult.failure(e.toString());
    }
  }

  bool validateCurrentRole() {
    return GlobalKeys.isValidRole(state.userRole);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await ref.read(apiServiceProvider).post(
          ApiEndpoints.logout,
          data: {'refresh': refreshToken},
          requireAuth: true,
        );
      }
    } catch (e) {
      log('Logout API error: $e');
    } finally {
      await NotificationService.onLogout();
      await StorageService.clearAll();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        clearRole: true,
      );
    }
  }
}
