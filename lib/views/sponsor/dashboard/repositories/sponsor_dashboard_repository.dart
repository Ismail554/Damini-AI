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
        } else if (data['projects'] is List) {
          rawList = data['projects'] as List;
        }
      }

      return rawList
          .whereType<Map>()
          .map((item) =>
              SponsorActiveProjectData.fromJson(Map<String, dynamic>.from(item)))
          .toList();
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

  /// Pending collaboration requests preview
  Future<List<SponsorCollaborationRequestPreview>> fetchCollaborationRequests() async {
    return const [
      SponsorCollaborationRequestPreview(
        id: "req_sarah_jenkins",
        name: "Sarah Jenkins",
        subtitle: "Interested in EcoTech Solar Farm",
        avatarUrl:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop",
      ),
    ];
  }
}
