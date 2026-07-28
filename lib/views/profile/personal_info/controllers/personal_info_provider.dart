import 'package:flutter/material.dart';
import '../models/personal_info_model.dart';

class PersonalInfoProvider extends ChangeNotifier {
  PersonalInfoModel _info = const PersonalInfoModel(
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

  bool _isLoading = false;

  PersonalInfoModel get info => _info;
  bool get isLoading => _isLoading;

  void updateInfo(PersonalInfoModel newInfo) {
    _info = newInfo;
    notifyListeners();
  }

  Future<bool> saveProfile(PersonalInfoModel updated) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _info = updated;
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
