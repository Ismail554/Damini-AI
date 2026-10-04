import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/sponsor_edit_profile_model.dart';

final sponsorEditProfileRepositoryProvider =
    Provider<SponsorEditProfileRepository>((ref) {
  return SponsorEditProfileRepositoryImpl(ref.watch(apiServiceProvider));
});

abstract class SponsorEditProfileRepository {
  Future<SponsorEditProfileModel> getProfile();
  Future<bool> updateProfile(
    SponsorEditProfileModel profile, {
    File? photoFile,
  });
  Future<bool> updateName(String firstName, String lastName);
}

class SponsorEditProfileRepositoryImpl implements SponsorEditProfileRepository {
  final ApiService _apiService;

  SponsorEditProfileRepositoryImpl(this._apiService);

  @override
  Future<SponsorEditProfileModel> getProfile() async {
    final response = await _apiService.get(
      ApiEndpoints.profileByRole('sponsor'),
      requireAuth: true,
    );

    dynamic profileData = response.data;
    if (profileData is String) {
      try {
        profileData = jsonDecode(profileData);
      } catch (_) {}
    }

    final mergedMap = <String, dynamic>{};
    if (profileData is Map) {
      mergedMap.addAll(Map<String, dynamic>.from(profileData));
    }

    // Check if name/email are present in the response
    final hasUserFields = mergedMap['first_name'] != null ||
        mergedMap['email'] != null ||
        (mergedMap['data'] is Map &&
            (mergedMap['data']['first_name'] != null ||
                mergedMap['data']['email'] != null));

    if (!hasUserFields) {
      try {
        final userResponse = await _apiService.get(
          ApiEndpoints.currentUser,
          requireAuth: true,
        );
        dynamic userData = userResponse.data;
        if (userData is String) {
          try {
            userData = jsonDecode(userData);
          } catch (_) {}
        }
        if (userData is Map) {
          final uMap = Map<String, dynamic>.from(userData);
          final uData = uMap['data'] is Map
              ? Map<String, dynamic>.from(uMap['data'] as Map)
              : uMap;
          mergedMap['first_name'] ??= uData['first_name'];
          mergedMap['last_name'] ??= uData['last_name'];
          mergedMap['email'] ??= uData['email'];
        }
      } catch (_) {
        // Continue with whatever was returned by profileByRole
      }
    }

    return SponsorEditProfileModel.fromJson(mergedMap);
  }

  @override
  Future<bool> updateProfile(
    SponsorEditProfileModel profile, {
    File? photoFile,
  }) async {
    final payload = profile.toPatchPayload();
    dynamic data;

    if (photoFile != null) {
      final fileName = photoFile.path.split(RegExp(r'[\\/]')).last;
      final map = Map<String, dynamic>.from(payload);
      map['profile_photo'] = await MultipartFile.fromFile(
        photoFile.path,
        filename: fileName,
      );
      data = FormData.fromMap(map);
    } else {
      data = payload;
    }

    final response = await _apiService.patch(
      ApiEndpoints.profileByRole('sponsor'),
      data: data,
      requireAuth: true,
    );

    final status = response.statusCode ?? 0;
    return status >= 200 && status < 300;
  }

  @override
  Future<bool> updateName(String firstName, String lastName) async {
    final response = await _apiService.patch(
      ApiEndpoints.currentUser,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
      },
      requireAuth: true,
    );

    final status = response.statusCode ?? 0;
    return status >= 200 && status < 300;
  }
}
