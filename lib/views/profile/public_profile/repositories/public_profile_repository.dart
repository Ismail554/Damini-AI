import 'dart:convert';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/public_profile_model.dart';

abstract class PublicProfileRepository {
  Future<PublicProfileModel> getPublicProfile([String? userId]);
}

class PublicProfileRepositoryImpl implements PublicProfileRepository {
  final ApiService _apiService;

  PublicProfileRepositoryImpl(this._apiService);

  @override
  Future<PublicProfileModel> getPublicProfile([String? userId]) async {
    if (userId == null || userId.trim().isEmpty) {
      return const PublicProfileModel();
    }
    try {
      final response = await _apiService.get(
        ApiEndpoints.userPublicProfile(userId.trim()),
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return PublicProfileModel.fromJson(
            Map<String, dynamic>.from(data['data']),
          );
        }
        return PublicProfileModel.fromJson(data);
      }
      return const PublicProfileModel();
    } catch (e) {
      // Graceful fallback to empty model so UI uses passed navigation attributes
      return const PublicProfileModel();
    }
  }
}
