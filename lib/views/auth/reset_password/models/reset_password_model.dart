class ResetPasswordRequestModel {
  final String newPassword;

  const ResetPasswordRequestModel({required this.newPassword});

  Map<String, dynamic> toJson() => {'password': newPassword};
}

class ResetPasswordResponseModel {
  final bool success;
  final String? message;

  const ResetPasswordResponseModel({required this.success, this.message});
}
