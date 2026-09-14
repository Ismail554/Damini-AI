class SignupRequestModel {
  final String fullName;
  final String email;
  final String password;

  const SignupRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': fullName,
      'email': email,
      'password': password,
    };
  }
}

class SignupResponseModel {
  final bool success;
  final String? message;

  const SignupResponseModel({
    required this.success,
    this.message,
  });
}
