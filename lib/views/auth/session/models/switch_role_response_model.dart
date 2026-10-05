class SwitchRoleResult {
  final bool success;
  final String? activeRole;
  final bool isOnboarded;
  final String? verificationStatus;
  final String? accountType;
  final String? accessToken;
  final String? refreshToken;
  final String? errorCode;
  final String? message;

  const SwitchRoleResult({
    required this.success,
    this.activeRole,
    this.isOnboarded = true,
    this.verificationStatus,
    this.accountType,
    this.accessToken,
    this.refreshToken,
    this.errorCode,
    this.message,
  });

  bool get isProfileMissing =>
      errorCode == 'PROFILE_MISSING' ||
      (message != null &&
          message!.toLowerCase().contains('profile does not exist'));

  factory SwitchRoleResult.fromSuccessJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return SwitchRoleResult(
      success: true,
      activeRole: data['active_role']?.toString(),
      isOnboarded: data['is_onboarded'] == true,
      verificationStatus: data['verification_status']?.toString(),
      accountType: data['account_type']?.toString(),
      accessToken: data['access']?.toString(),
      refreshToken: data['refresh']?.toString(),
      message: json['message']?.toString(),
    );
  }

  factory SwitchRoleResult.fromErrorJson(Map<String, dynamic> json) {
    String? code;
    if (json['errors'] is Map) {
      code = (json['errors'] as Map)['error_code']?.toString();
    }
    if (code == null && json['data'] is Map) {
      code = (json['data'] as Map)['error_code']?.toString();
    }
    code ??= json['error_code']?.toString();

    return SwitchRoleResult(
      success: false,
      errorCode: code,
      message: json['message']?.toString(),
    );
  }

  factory SwitchRoleResult.failure(String message, {String? errorCode}) {
    return SwitchRoleResult(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }
}
