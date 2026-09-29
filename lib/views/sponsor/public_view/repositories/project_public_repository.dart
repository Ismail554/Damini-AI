import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/project_public_view_model.dart';

final projectPublicRepositoryProvider =
    Provider<ProjectPublicRepository>((ref) {
  return ProjectPublicRepository(ref.watch(apiServiceProvider));
});

class ProjectPublicRepository {
  final ApiService _apiService;

  ProjectPublicRepository(this._apiService);

  /// Toggle save/bookmark for project: POST /api/v1/projects/{id}/save/
  /// Returns the updated saved status (true if saved, false if unsaved) or null if unknown.
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
        if (data.containsKey('status')) {
          final status = data['status']?.toString().toLowerCase();
          if (status == 'saved') return true;
          if (status == 'unsaved' || status == 'removed') return false;
        }
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ProjectPublicViewModel> fetchProjectPublicDetails([String? id]) async {
    return ProjectPublicViewModel.mockData();
  }
}
