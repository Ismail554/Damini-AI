class PublicProfileModel {
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

  const PublicProfileModel({
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
  });

  PublicProfileModel copyWith({
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
  }) {
    return PublicProfileModel(
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
    );
  }
}
