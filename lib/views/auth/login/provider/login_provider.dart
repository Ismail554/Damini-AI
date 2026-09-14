import 'dart:async';

import 'package:Braintech/core/services/api_service.dart';
import 'package:Braintech/views/auth/login/models/login_request_model.dart';
import 'package:Braintech/views/auth/login/repositories/login_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/controllers/session_provider.dart';

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  return LoginRepositoryImpl(ref.watch(apiServiceProvider));
});

class LoginProvider extends AsyncNotifier<LoginResponseModel?> {
  @override
  FutureOr<LoginResponseModel?> build() => null;

  Future<bool> login(LoginRequestModel request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(loginRepositoryProvider).login(request),
    );

    final isSuccess = state.value?.success ?? false;
    if (isSuccess) {
      ref
          .read(sessionProvider.notifier)
          .updateSession(isAuthenticated: true, userRole: state.value?.role);
    }
    return isSuccess;
  }
}

final loginProvider = AsyncNotifierProvider<LoginProvider, LoginResponseModel?>(
  LoginProvider.new,
);
