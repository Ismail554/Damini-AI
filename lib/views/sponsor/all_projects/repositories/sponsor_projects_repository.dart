import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/sponsor_project_model.dart';

final sponsorProjectsRepositoryProvider =
    Provider<SponsorProjectsRepository>((ref) {
  return SponsorProjectsRepository(ref.watch(apiServiceProvider));
});

class SponsorProjectsRepository {
  final ApiService _apiService;

  SponsorProjectsRepository(this._apiService);

  /// Fetch all projects from GET /api/v1/projects/sponsor/
  Future<List<SponsorProjectModel>> fetchProjects() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.sponsorProjects,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map) {
        if (data['results'] is List) {
          rawList = data['results'] as List;
        } else if (data['data'] is List) {
          rawList = data['data'] as List;
        } else if (data['data'] is Map &&
            (data['data'] as Map)['results'] is List) {
          rawList = (data['data'] as Map)['results'] as List;
        } else if (data['data'] is Map &&
            (data['data'] as Map)['projects'] is List) {
          rawList = (data['data'] as Map)['projects'] as List;
        } else if (data['projects'] is List) {
          rawList = data['projects'] as List;
        }
      }

      final projects = <SponsorProjectModel>[];
      for (final item in rawList.whereType<Map>()) {
        try {
          projects.add(
            SponsorProjectModel.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (_) {
          continue;
        }
      }

      // Sort by most recent first
      projects.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        final aId = int.tryParse(a.id) ?? 0;
        final bId = int.tryParse(b.id) ?? 0;
        return bId.compareTo(aId);
      });

      return projects;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SponsorProjectModel>> fetchActiveProjects() async {
    try {
      final all = await fetchProjects();
      return all
          .where((p) => p.status == SponsorProjectStatus.active)
          .toList();
    } catch (_) {
      return SponsorProjectModel.mockActiveList();
    }
  }

  Future<List<SponsorProjectModel>> fetchCompletedProjects() async {
    try {
      final all = await fetchProjects();
      return all
          .where((p) => p.status == SponsorProjectStatus.completed)
          .toList();
    } catch (_) {
      return SponsorProjectModel.mockCompletedList();
    }
  }

  Future<List<SponsorProjectModel>> fetchTerminatedProjects() async {
    try {
      final all = await fetchProjects();
      return all
          .where((p) => p.status == SponsorProjectStatus.terminated)
          .toList();
    } catch (_) {
      return SponsorProjectModel.mockTerminatedList();
    }
  }
}
