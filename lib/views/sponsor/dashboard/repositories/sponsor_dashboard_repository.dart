import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/sponsor_dashboard_models.dart';

final sponsorDashboardRepositoryProvider =
    Provider<SponsorDashboardRepository>((ref) {
  return SponsorDashboardRepository(ref.watch(apiServiceProvider));
});

class SponsorDashboardRepository {
  final ApiService _apiService;

  SponsorDashboardRepository(this._apiService);

  /// 1. Fetch current user profile with nested stats from GET /api/v1/users/me/
  Future<SponsorUserProfile> fetchUserProfile() async {
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
        return SponsorUserProfile.fromJson(data);
      } else if (data is Map) {
        return SponsorUserProfile.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Unexpected format from users/me endpoint');
    } catch (e) {
      rethrow;
    }
  }

  /// 2. Fetch paginated list of sponsor projects from GET /api/v1/projects/sponsor/
  Future<List<SponsorActiveProjectData>> fetchProjects() async {
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
        } else if (data['data'] is Map && (data['data'] as Map)['results'] is List) {
          rawList = (data['data'] as Map)['results'] as List;
        } else if (data['data'] is Map && (data['data'] as Map)['projects'] is List) {
          rawList = (data['data'] as Map)['projects'] as List;
        } else if (data['projects'] is List) {
          rawList = data['projects'] as List;
        }
      }

      final projects = <SponsorActiveProjectData>[];
      for (final item in rawList.whereType<Map>()) {
        try {
          projects.add(
            SponsorActiveProjectData.fromJson(Map<String, dynamic>.from(item)),
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

  /// Fetch metrics directly or derived from user profile
  Future<List<SponsorDashboardMetric>> fetchMetrics() async {
    try {
      final profile = await fetchUserProfile();
      return profile.toMetrics();
    } catch (_) {
      return const [
        SponsorDashboardMetric(
          label: "Total Raised",
          value: "\$0.00",
          icon: Icons.monetization_on_outlined,
        ),
        SponsorDashboardMetric(
          label: "Active Investors",
          value: "0",
          icon: Icons.people_outline_rounded,
        ),
      ];
    }
  }

  /// Pending collaboration requests preview from GET /api/v1/projects/sponsor/requests/
  Future<List<SponsorCollaborationRequestPreview>>
      fetchCollaborationRequests() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.sponsorCollaborationRequests,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      List rawList = [];
      if (data is Map && data['data'] is List) {
        rawList = data['data'] as List;
      } else if (data is List) {
        rawList = data;
      } else if (data is Map && data['results'] is List) {
        rawList = data['results'] as List;
      }

      final requests = <SponsorCollaborationRequestPreview>[];
      for (final item in rawList.whereType<Map>()) {
        try {
          requests.add(
            SponsorCollaborationRequestPreview.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (_) {
          continue;
        }
      }

      // Sort by most recent first
      requests.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(0);
        final bDate = b.createdAt ?? DateTime(0);
        return bDate.compareTo(aDate);
      });

      return requests;
    } catch (_) {
      return [];
    }
  }
}
