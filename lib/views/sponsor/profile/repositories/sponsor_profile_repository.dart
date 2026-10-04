import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/sponsor_profile_model.dart';

final sponsorProfileRepositoryProvider = Provider<SponsorProfileRepository>((ref) {
  return SponsorProfileRepository(ref.watch(apiServiceProvider));
});

class SponsorProfileRepository {
  final ApiService _apiService;

  SponsorProfileRepository(this._apiService);

  Future<SponsorProfileData> fetchProfile() async {
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
        return SponsorProfileData.fromJson(data);
      } else if (data is Map) {
        return SponsorProfileData.fromJson(Map<String, dynamic>.from(data));
      }
      return const SponsorProfileData(
        name: "Member",
        title: "Sponsor Partner",
        avatarUrl: "",
        investedAmount: "\$0.00",
        projectsCount: "0",
      );
    } catch (_) {
      return const SponsorProfileData(
        name: "Member",
        title: "Sponsor Partner",
        avatarUrl: "",
        investedAmount: "\$0.00",
        projectsCount: "0",
      );
    }
  }
}
