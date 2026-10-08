class ForgotPasswordRequestModel {
  final String email;

  const ForgotPasswordRequestModel({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ForgotPasswordResponseModel {
  final bool success;
  final String? message;

  const ForgotPasswordResponseModel({required this.success, this.message});

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      success: json['status'] == 'success' || json['success'] == true,
      message: json['message']?.toString() ?? json['detail']?.toString(),
    );
  }
}
