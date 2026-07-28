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
    this.profilePhotoUrl,
  });

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
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}
