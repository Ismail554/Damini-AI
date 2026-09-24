import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/personal_info_model.dart';

final personalInfoRepositoryProvider = Provider<PersonalInfoRepository>((ref) {
  return PersonalInfoRepositoryImpl(ref.watch(apiServiceProvider));
});

abstract class PersonalInfoRepository {
  Future<PersonalInfoModel> getProfile();
  Future<bool> updateProfile(PersonalInfoModel profile);
}

class PersonalInfoRepositoryImpl implements PersonalInfoRepository {
  final ApiService _apiService;

  PersonalInfoRepositoryImpl(this._apiService);

  @override
  Future<PersonalInfoModel> getProfile() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.currentUser,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return PersonalInfoModel.fromJson(data);
      } else if (data is Map) {
        return PersonalInfoModel.fromJson(Map<String, dynamic>.from(data));
      }
      return const PersonalInfoModel(
        fullName: 'Member',
        email: '',
        phone: '',
        country: '',
        location: '',
        companyName: '',
        position: '',
        website: '',
        bio: '',
      );
    } catch (_) {
      return const PersonalInfoModel(
        fullName: 'Member',
        email: '',
        phone: '',
        country: '',
        location: '',
        companyName: '',
        position: '',
        website: '',
        bio: '',
      );
    }
  }

  @override
  Future<bool> updateProfile(PersonalInfoModel profile) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.currentUser,
        data: {
          'first_name': profile.fullName.split(' ').first,
          'last_name': profile.fullName.split(' ').length > 1
              ? profile.fullName.split(' ').sublist(1).join(' ')
              : '',
        },
        requireAuth: true,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
