class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class LoginResponseModel {
  final bool success;
  final String? token;
  final String? role;
  final String? message;

  const LoginResponseModel({
    required this.success,
    this.token,
    this.role,
    this.message,
  });
}
