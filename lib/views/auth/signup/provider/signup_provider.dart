import 'dart:async';

import 'package:Braintech/core/services/api_service.dart';
import 'package:Braintech/views/auth/signup/models/signup_request_model.dart';
import 'package:Braintech/views/auth/signup/repositories/signup_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signupRepositoryProvider = Provider<SignupRepository>((ref) {
  return SignupRepositoryImpl(ref.watch(apiServiceProvider));
});

class SignupProvider extends AsyncNotifier<SignupResponseModel?> {
  @override
  FutureOr<SignupResponseModel?> build() => null;

  Future<bool> signUp(SignupRequestModel request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signupRepositoryProvider).signUp(request),
    );
    return state.value?.success ?? false;
  }
}

final signupProvider =
    AsyncNotifierProvider<SignupProvider, SignupResponseModel?>(
      SignupProvider.new,
    );
