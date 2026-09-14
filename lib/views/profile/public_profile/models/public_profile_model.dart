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

  const PublicProfileModel({
    this.name = 'John Doe',
    this.title = 'CEO at Acme Corp',
    this.company = 'Apex Ventures Ltd.',
    this.avatarUrl =
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop',
    this.country = 'United States',
    this.phone = '000001111444455',
    this.email = 'john@apexventures.com',
    this.location = 'San Francisco, CA',
    this.website = 'apexventures.com',
    this.bio = 'Venture capitalist focused on tech innovation and sustainable energy.',
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
    );
  }
}
