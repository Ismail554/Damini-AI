class SignupState {
  final bool password;
  final bool confirmPassword;

  const SignupState({this.password = true, this.confirmPassword = true});

  SignupState copyWith({bool? password, bool? confirmPassword}) {
    return SignupState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}
