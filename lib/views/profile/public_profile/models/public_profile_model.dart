import '../../../../core/constants/api_endpoints.dart';

class PublicProfileModel {
  final String id;
  final String name;
  final String title;
  final String company;
  final String avatarUrl;
  final String country;
  final String phone;
  final String email;
  final String location;
  final String website;
  final String bio;
  final String role;
  final bool isVerified;
  final bool isSaved;
  final bool isOwnProfile;

  const PublicProfileModel({
    this.id = '',
    this.name = '',
    this.title = '',
    this.company = '',
    this.avatarUrl = '',
    this.country = '',
    this.phone = '',
    this.email = '',
    this.location = '',
    this.website = '',
    this.bio = '',
    this.role = '',
    this.isVerified = true,
    this.isSaved = false,
    this.isOwnProfile = false,
  });

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map
        ? Map<String, dynamic>.from(json['profile'] as Map)
        : const <String, dynamic>{};

    final id = json['id']?.toString() ?? profile['id']?.toString() ?? '';

    // Name
    String name = json['name']?.toString() ??
        json['full_name']?.toString() ??
        '';
    if (name.isEmpty) {
      final first = json['first_name']?.toString() ?? '';
      final last = json['last_name']?.toString() ?? '';
      name = '$first $last'.trim();
    }

    // Title / Designation
    final title = json['title']?.toString() ??
        profile['title']?.toString() ??
        profile['designation']?.toString() ??
        '';

    // Company
    final company = json['company']?.toString() ??
        profile['company']?.toString() ??
        profile['company_name']?.toString() ??
        profile['legal_company_name']?.toString() ??
        '';

    // Location & Country
    final location = json['location']?.toString() ??
        profile['location']?.toString() ??
        profile['city']?.toString() ??
        '';

    final country = json['country']?.toString() ??
        profile['country']?.toString() ??
        '';

    final email = json['email']?.toString() ?? '';
    final phone = json['phone']?.toString() ?? profile['phone']?.toString() ?? '';
    final website = json['website']?.toString() ?? profile['website']?.toString() ?? '';
    final bio = json['bio']?.toString() ?? profile['bio']?.toString() ?? '';
    final role = json['role']?.toString() ?? 'Investor';

    // Avatar URL
    final rawPhoto = profile['profile_photo']?.toString() ??
        profile['avatar']?.toString() ??
        json['profile_photo']?.toString() ??
        json['avatar_url']?.toString() ??
        json['avatar']?.toString();

    String avatarUrl = '';
    if (rawPhoto != null && rawPhoto.isNotEmpty && rawPhoto != 'null') {
      if (rawPhoto.startsWith('http://') || rawPhoto.startsWith('https://')) {
        avatarUrl = rawPhoto;
      } else {
        final base = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = rawPhoto.startsWith('/') ? rawPhoto : '/$rawPhoto';
        avatarUrl = '$base$path';
      }
    }

    final isVerified = json['is_verified'] == true || profile['is_verified'] == true;
    final isSaved = json['is_saved'] == true;
    final isOwnProfile = json['is_own_profile'] == true;

    return PublicProfileModel(
      id: id,
      name: name,
      title: title,
      company: company,
      avatarUrl: avatarUrl,
      country: country,
      phone: phone,
      email: email,
      location: location,
      website: website,
      bio: bio,
      role: role,
      isVerified: isVerified,
      isSaved: isSaved,
      isOwnProfile: isOwnProfile,
    );
  }

  PublicProfileModel copyWith({
    String? id,
    String? name,
    String? title,
    String? company,
    String? avatarUrl,
    String? country,
    String? phone,
    String? email,
    String? location,
    String? website,
    String? bio,
    String? role,
    bool? isVerified,
    bool? isSaved,
    bool? isOwnProfile,
  }) {
    return PublicProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      company: company ?? this.company,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      website: website ?? this.website,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isSaved: isSaved ?? this.isSaved,
      isOwnProfile: isOwnProfile ?? this.isOwnProfile,
    );
  }
}
