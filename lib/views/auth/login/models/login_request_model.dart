class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email.trim(), 'password': password};
  }
}

class UserModel {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String role;
  final bool isEmailVerified;
  final bool pushNotificationsEnabled;
  final String subscriptionTier;

  const UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.role = 'NONE',
    this.isEmailVerified = false,
    this.pushNotificationsEnabled = false,
    this.subscriptionTier = 'FREE',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? 'NONE',
      isEmailVerified: json['is_email_verified'] == true,
      pushNotificationsEnabled: json['push_notifications_enabled'] == true,
      subscriptionTier: json['subscription_tier']?.toString() ?? 'FREE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'role': role,
      'is_email_verified': isEmailVerified,
      'push_notifications_enabled': pushNotificationsEnabled,
      'subscription_tier': subscriptionTier,
    };
  }
}

class LoginResponseModel {
  final bool success;
  final String? token;
  final String? refreshToken;
  final UserModel? user;
  final String? role;
  final String? message;

  const LoginResponseModel({
    required this.success,
    this.token,
    this.refreshToken,
    this.user,
    this.role,
    this.message,
  });
}
