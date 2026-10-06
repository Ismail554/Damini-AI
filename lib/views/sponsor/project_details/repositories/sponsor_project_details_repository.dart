import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/sponsor_project_details_model.dart';

final sponsorProjectDetailsRepositoryProvider =
    Provider<SponsorProjectDetailsRepository>((ref) {
  return SponsorProjectDetailsRepository(ref.watch(apiServiceProvider));
});

class SponsorProjectDetailsRepository {
  final ApiService _apiService;

  SponsorProjectDetailsRepository(this._apiService);

  /// Fetch single project details from GET /api/v1/projects/{id}/
  Future<SponsorProjectDetailsModel> fetchProjectDetails(
    String projectId,
  ) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.projectDetails(projectId),
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map && data['data'] is Map) {
        return SponsorProjectDetailsModel.fromJson(
          Map<String, dynamic>.from(data['data'] as Map),
        );
      } else if (data is Map<String, dynamic>) {
        return SponsorProjectDetailsModel.fromJson(data);
      } else if (data is Map) {
        return SponsorProjectDetailsModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception('Unexpected response format for project details');
    } catch (e) {
      rethrow;
    }
  }

  /// Terminate project: POST /api/v1/projects/{id}/terminate/
  Future<void> terminateProject(String projectId, String reason) async {
    try {
      await _apiService.post(
        ApiEndpoints.terminateProject(projectId),
        data: {'reason': reason},
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
