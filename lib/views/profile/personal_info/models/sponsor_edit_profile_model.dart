import '../../../../core/constants/api_endpoints.dart';

class SponsorEditProfileModel {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? country;
  final String? location;
  final String? positionTitle;
  final String? bio;
  final String? profilePhotoUrl;
  final String sponsorType;
  final String verificationStatus;
  final String? legalCompanyName;
  final String? registrationNumber;
  final String? businessAddress;
  final String? companyWebsite;

  const SponsorEditProfileModel({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.country,
    this.location,
    this.positionTitle,
    this.bio,
    this.profilePhotoUrl,
    this.sponsorType = 'INDIVIDUAL',
    this.verificationStatus = 'PENDING',
    this.legalCompanyName,
    this.registrationNumber,
    this.businessAddress,
    this.companyWebsite,
  });

  bool get isCompany => sponsorType.toUpperCase() == 'COMPANY';

  String get fullName {
    final parts = [firstName, lastName]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    return parts.isEmpty ? 'Member' : parts.join(' ');
  }

  factory SponsorEditProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final profile = data['profile'] is Map
        ? Map<String, dynamic>.from(data['profile'] as Map)
        : data;

    final firstName = data['first_name']?.toString() ??
        profile['first_name']?.toString();
    final lastName = data['last_name']?.toString() ??
        profile['last_name']?.toString();

    final rawPhoto = profile['profile_photo']?.toString() ??
        data['profile_photo']?.toString() ??
        data['profile_image']?.toString();

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

    final rawSponsorType = profile['sponsor_type']?.toString() ??
        data['sponsor_type']?.toString() ??
        'INDIVIDUAL';

    final rawVerificationStatus = profile['verification_status']?.toString() ??
        data['verification_status']?.toString() ??
        'PENDING';

    return SponsorEditProfileModel(
      firstName: firstName,
      lastName: lastName,
      email: data['email']?.toString() ?? profile['email']?.toString(),
      phone: profile['phone']?.toString(),
      country: profile['country']?.toString(),
      location: profile['location']?.toString(),
      positionTitle: profile['position_title']?.toString(),
      bio: profile['bio']?.toString(),
      profilePhotoUrl: photoUrl,
      sponsorType: rawSponsorType.toUpperCase(),
      verificationStatus: rawVerificationStatus.toUpperCase(),
      legalCompanyName: profile['legal_company_name']?.toString() ??
          profile['company_name']?.toString(),
      registrationNumber: profile['registration_number']?.toString(),
      businessAddress: profile['business_address']?.toString(),
      companyWebsite: profile['company_website']?.toString(),
    );
  }

  Map<String, dynamic> toPatchPayload({String? role}) {
    final map = <String, dynamic>{};
    if (phone != null && phone!.trim().isNotEmpty) {
      map['phone'] = phone!.trim();
    }
    if (country != null && country!.trim().isNotEmpty) {
      map['country'] = country!.trim();
    }
    if (location != null && location!.trim().isNotEmpty) {
      map['location'] = location!.trim();
    }
    if (positionTitle != null && positionTitle!.trim().isNotEmpty) {
      map['position_title'] = positionTitle!.trim();
    }
    if (bio != null && bio!.trim().isNotEmpty) {
      map['bio'] = bio!.trim();
    }

    if (role == 'investor') {
      if (legalCompanyName != null && legalCompanyName!.trim().isNotEmpty) {
        map['company_name'] = legalCompanyName!.trim();
      }
    } else {
      if (isCompany) {
        if (legalCompanyName != null && legalCompanyName!.trim().isNotEmpty) {
          map['legal_company_name'] = legalCompanyName!.trim();
        }
        if (registrationNumber != null &&
            registrationNumber!.trim().isNotEmpty) {
          map['registration_number'] = registrationNumber!.trim();
        }
        if (businessAddress != null && businessAddress!.trim().isNotEmpty) {
          map['business_address'] = businessAddress!.trim();
        }
        if (companyWebsite != null && companyWebsite!.trim().isNotEmpty) {
          map['company_website'] = companyWebsite!.trim();
        }
      }
    }

    return map;
  }

  SponsorEditProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? country,
    String? location,
    String? positionTitle,
    String? bio,
    String? profilePhotoUrl,
    String? sponsorType,
    String? verificationStatus,
    String? legalCompanyName,
    String? registrationNumber,
    String? businessAddress,
    String? companyWebsite,
  }) {
    return SponsorEditProfileModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      location: location ?? this.location,
      positionTitle: positionTitle ?? this.positionTitle,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      sponsorType: sponsorType ?? this.sponsorType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      legalCompanyName: legalCompanyName ?? this.legalCompanyName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      businessAddress: businessAddress ?? this.businessAddress,
      companyWebsite: companyWebsite ?? this.companyWebsite,
    );
  }
}
