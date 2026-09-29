import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/sponsor_saved_profile_model.dart';
import '../models/sponsor_saved_project_model.dart';

final sponsorSavedRepositoryProvider = Provider<SponsorSavedRepository>((ref) {
  return SponsorSavedRepository(ref.watch(apiServiceProvider));
});

class SponsorSavedRepository {
  final ApiService _apiService;

  SponsorSavedRepository(this._apiService);

  /// Fetch saved projects from GET /api/v1/projects/saved/
  /// Supports optional `search`, `ordering`, and `status` query parameters.
  Future<SavedProjectsResponse> fetchSavedProjects({
    String? search,
    String? ordering,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (ordering != null && ordering.trim().isNotEmpty) {
        queryParams['ordering'] = ordering.trim();
      }
      if (status != null &&
          status.trim().isNotEmpty &&
          status.trim().toLowerCase() != 'all') {
        queryParams['status'] = status.trim().toUpperCase();
      }

      final response = await _apiService.get(
        ApiEndpoints.savedProjects,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        if (data['results'] is List) {
          return SavedProjectsResponse.fromJson(data);
        } else if (data['data'] is Map<String, dynamic> &&
            (data['data'] as Map)['results'] is List) {
          return SavedProjectsResponse.fromJson(
            Map<String, dynamic>.from(data['data']),
          );
        } else if (data['data'] is List) {
          final list = (data['data'] as List)
              .whereType<Map>()
              .map(
                (e) => SponsorSavedProjectModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
          return SavedProjectsResponse(count: list.length, results: list);
        }
      } else if (data is List) {
        final list = data
            .whereType<Map>()
            .map(
              (e) => SponsorSavedProjectModel.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
        return SavedProjectsResponse(count: list.length, results: list);
      }

      return const SavedProjectsResponse(count: 0, results: []);
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle save/bookmark for project: POST /api/v1/projects/{id}/save/
  Future<bool?> toggleSaveProject(String projectId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.saveProject(projectId),
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        if (data.containsKey('is_saved')) {
          final isSaved = data['is_saved'];
          if (isSaved is bool) return isSaved;
          if (isSaved != null) {
            return isSaved.toString().toLowerCase() == 'true';
          }
        }
        if (data.containsKey('saved')) {
          final saved = data['saved'];
          if (saved is bool) return saved;
        }
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SponsorSavedProfileModel>> fetchSavedProfiles() async {
    return SponsorSavedProfileModel.mockList();
  }
}
