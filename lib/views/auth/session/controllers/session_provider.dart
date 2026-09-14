import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/global_key.dart';
import '../models/session_model.dart';

export '../models/session_model.dart';

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

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
    final isAuth = token != null;
    state = state.copyWith(
      isAuthenticated: isAuth,
      userRole: role,
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

  Future<void> setRole(String role) async {
    if (!GlobalKeys.isValidRole(role)) return;
    state = state.copyWith(isLoading: true);
    await StorageService.saveRole(role);
    state = state.copyWith(
      isLoading: false,
      userRole: role,
    );
  }

  bool validateCurrentRole() {
    return GlobalKeys.validateKeyResponse(
      isApiConnected: state.isApiConnected,
      role: state.userRole,
    );
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    state = state.copyWith(
      isAuthenticated: false,
      clearRole: true,
    );
  }
}
