class OtpVerificationRequestModel {
  final String email;
  final String code;
  final bool isRecovery;

  const OtpVerificationRequestModel({
    required this.email,
    required this.code,
    this.isRecovery = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'code': code.trim(),
    };
  }
}

class OtpVerificationResponseModel {
  final bool success;
  final String? token;
  final String? message;

  const OtpVerificationResponseModel({
    required this.success,
    this.token,
    this.message,
  });
}
