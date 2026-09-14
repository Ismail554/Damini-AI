class ForgotPasswordRequestModel {
  final String email;

  const ForgotPasswordRequestModel({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ForgotPasswordResponseModel {
  final bool success;
  final String? message;

  const ForgotPasswordResponseModel({required this.success, this.message});
}
