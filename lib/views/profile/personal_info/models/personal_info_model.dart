import '../../../../core/constants/api_endpoints.dart';

class PersonalInfoModel {
  final String fullName;
  final String email;
  final String phone;
  final String country;
  final String location;
  final String companyName;
  final String position;
  final String website;
  final String bio;
  final String role;
  final String? profilePhotoUrl;

  const PersonalInfoModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
    required this.location,
    required this.companyName,
    required this.position,
    required this.website,
    required this.bio,
    this.role = '',
    this.profilePhotoUrl,
  });

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final profile = data['profile'] is Map
        ? Map<String, dynamic>.from(data['profile'] as Map)
        : const <String, dynamic>{};

    final first = (data['first_name']?.toString() ??
            profile['first_name']?.toString() ??
            '')
        .trim();
    final last = (data['last_name']?.toString() ??
            profile['last_name']?.toString() ??
            '')
        .trim();

    String capitalize(String s) =>
        s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';

    String name = '';
    if (first.isNotEmpty && last.isNotEmpty) {
      name = '${capitalize(first)} ${capitalize(last)}';
    } else if (first.isNotEmpty) {
      name = capitalize(first);
    } else if (last.isNotEmpty) {
      name = capitalize(last);
    } else {
      name = 'Member';
    }

    final rawPhoto = profile['profile_photo']?.toString() ??
        data['profile_photo']?.toString() ??
        data['profile_image']?.toString() ??
        data['avatar']?.toString();

    String? photoUrl;
    if (rawPhoto != null && rawPhoto != 'null' && rawPhoto.isNotEmpty) {
      if (rawPhoto.startsWith('http://') || rawPhoto.startsWith('https://')) {
        photoUrl = rawPhoto;
      } else {
        final base = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = rawPhoto.startsWith('/') ? rawPhoto : '/$rawPhoto';
        photoUrl = '$base$path';
      }
    }

    final role = data['role']?.toString() ?? '';

    return PersonalInfoModel(
      fullName: name,
      email: data['email']?.toString() ?? profile['email']?.toString() ?? '',
      phone: profile['phone']?.toString() ?? '',
      country: profile['country']?.toString() ?? '',
      location: profile['location']?.toString() ?? '',
      companyName: profile['legal_company_name']?.toString() ?? '',
      position: profile['position_title']?.toString() ?? '',
      website: profile['company_website']?.toString() ?? '',
      bio: profile['bio']?.toString() ?? '',
      role: role,
      profilePhotoUrl: photoUrl,
    );
  }

  PersonalInfoModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? country,
    String? location,
    String? companyName,
    String? position,
    String? website,
    String? bio,
    String? role,
    String? profilePhotoUrl,
  }) {
    return PersonalInfoModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      location: location ?? this.location,
      companyName: companyName ?? this.companyName,
      position: position ?? this.position,
      website: website ?? this.website,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}
