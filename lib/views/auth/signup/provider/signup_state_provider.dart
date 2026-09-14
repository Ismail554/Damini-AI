import 'package:Braintech/views/auth/signup/models/signup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupStateProvider extends Notifier<SignupState> {
  @override
  SignupState build() => SignupState();

  void passwordToggle() {
    state = state.copyWith(password: !state.password);
  }

  void confirmPasswordToggle() {
    state = state.copyWith(confirmPassword: !state.confirmPassword);
  }
}

final signupStateProvider =
    NotifierProvider.autoDispose<SignupStateProvider, SignupState>(
      SignupStateProvider.new,
    );
