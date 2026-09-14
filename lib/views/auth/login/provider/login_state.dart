import 'package:Braintech/views/auth/signup/models/signup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState extends Notifier<SignupState> {
  @override
  SignupState build() => SignupState();

  void passwordToggle() {
    state = state.copyWith(password: !state.password);
  }
}

final loginState = NotifierProvider.autoDispose<LoginState, SignupState>(
  LoginState.new,
);
