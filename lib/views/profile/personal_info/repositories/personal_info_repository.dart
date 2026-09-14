import '../models/personal_info_model.dart';

abstract class PersonalInfoRepository {
  Future<PersonalInfoModel> getProfile();
  Future<bool> updateProfile(PersonalInfoModel profile);
}

class PersonalInfoRepositoryImpl implements PersonalInfoRepository {
  @override
  Future<PersonalInfoModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const PersonalInfoModel(
      fullName: 'John Doe',
      email: 'john@apexventures.com',
      phone: '+1 (415) 555-0142',
      country: 'United States',
      location: 'San Francisco, CA',
      companyName: 'Apex Ventures Ltd.',
      position: 'CEO & Co-Founder',
      website: 'apexventures.com',
      bio: 'Venture capitalist focused on tech innovation and sustainable energy.',
      profilePhotoUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop',
    );
  }

  @override
  Future<bool> updateProfile(PersonalInfoModel profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
