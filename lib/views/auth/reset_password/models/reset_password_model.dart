class ResetPasswordRequestModel {
  final String email;
  final String code;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequestModel({
    required this.email,
    required this.code,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'code': code,
        'otp': code,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };
}

class ResetPasswordResponseModel {
  final bool success;
  final String? message;

  const ResetPasswordResponseModel({required this.success, this.message});

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      success: json['status'] == 'success' || json['success'] == true,
      message: json['message']?.toString() ?? json['detail']?.toString(),
    );
  }
}
