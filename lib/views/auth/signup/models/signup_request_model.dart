class SignupRequestModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const SignupRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
    };
  }
}

class SignupResponseModel {
  final bool success;
  final String? message;
  final Map<String, String>? errors;

  const SignupResponseModel({
    required this.success,
    this.message,
    this.errors,
  });
}
