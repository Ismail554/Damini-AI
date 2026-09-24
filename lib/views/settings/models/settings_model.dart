import '../../../../core/constants/api_endpoints.dart';

class UserSettingsModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? profilePhoto;
  final bool pushNotificationsEnabled;
  final String subscriptionTier;
  final String? verificationStatus;
  final String? companyName;

  const UserSettingsModel({
    this.id,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.role = '',
    this.profilePhoto,
    this.pushNotificationsEnabled = true,
    this.subscriptionTier = 'FREE',
    this.verificationStatus,
    this.companyName,
  });

  String get fullName {
    final first = firstName.trim();
    final last = lastName.trim();
    String capitalize(String s) =>
        s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';
    final capFirst = capitalize(first);
    final capLast = capitalize(last);
    if (capFirst.isNotEmpty && capLast.isNotEmpty) return '$capFirst $capLast';
    if (capFirst.isNotEmpty) return capFirst;
    if (capLast.isNotEmpty) return capLast;
    return 'Member';
  }

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final id = data['id'] is int
        ? data['id'] as int
        : int.tryParse(data['id']?.toString() ?? '');
    final email = data['email']?.toString() ?? '';
    final role = data['role']?.toString() ?? '';

    final profile = data['profile'] is Map
        ? Map<String, dynamic>.from(data['profile'] as Map)
        : const <String, dynamic>{};

    final firstName = data['first_name']?.toString() ??
        profile['first_name']?.toString() ??
        '';
    final lastName = data['last_name']?.toString() ??
        profile['last_name']?.toString() ??
        '';

    final rawPhoto = profile['profile_photo']?.toString() ??
        data['profile_photo']?.toString() ??
        data['profile_image']?.toString() ??
        data['avatar']?.toString();

    String? profilePhoto;
    if (rawPhoto != null && rawPhoto != 'null' && rawPhoto.isNotEmpty) {
      if (rawPhoto.startsWith('http://') || rawPhoto.startsWith('https://')) {
        profilePhoto = rawPhoto;
      } else {
        final base = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = rawPhoto.startsWith('/') ? rawPhoto : '/$rawPhoto';
        profilePhoto = '$base$path';
      }
    }

    final verificationStatus = profile['verification_status']?.toString();
    final companyName = profile['legal_company_name']?.toString();
    final notifications = data['push_notifications_enabled'] == true;
    final subTier = data['subscription_tier']?.toString() ?? 'FREE';

    return UserSettingsModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
      profilePhoto: profilePhoto,
      pushNotificationsEnabled: notifications,
      subscriptionTier: subTier,
      verificationStatus: verificationStatus,
      companyName: companyName,
    );
  }
}

class SettingsModel {
  final bool notificationsEnabled;
  final String currentLanguage;

  const SettingsModel({
    this.notificationsEnabled = true,
    this.currentLanguage = 'English',
  });

  SettingsModel copyWith({
    bool? notificationsEnabled,
    String? currentLanguage,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }
}
