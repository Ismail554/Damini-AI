import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_dashboard_models.dart';
import '../repositories/sponsor_dashboard_repository.dart';

class SponsorDashboardState {
  final bool isLoading;
  final bool isRefreshing;
  final SponsorUserProfile? userProfile;
  final List<SponsorDashboardMetric> metrics;
  final List<SponsorActiveProjectData> projects;
  final List<SponsorCollaborationRequestPreview> requests;
  final String? error;

  const SponsorDashboardState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.userProfile,
    this.metrics = const [],
    this.projects = const [],
    this.requests = const [],
    this.error,
  });

  /// Name to display in the greeting header
  String get displayName {
    if (userProfile != null && userProfile!.fullName.isNotEmpty) {
      return userProfile!.fullName;
    }
    return 'Shawn Blake';
  }

  /// Profile photo URL if available
  String? get profilePhoto => userProfile?.profilePhoto;

  /// Top active project for the primary card, backward compatible
  SponsorActiveProjectData? get activeProject =>
      projects.isNotEmpty ? projects.first : null;

  SponsorDashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    SponsorUserProfile? userProfile,
    List<SponsorDashboardMetric>? metrics,
    List<SponsorActiveProjectData>? projects,
    List<SponsorCollaborationRequestPreview>? requests,
    String? error,
  }) {
    return SponsorDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      userProfile: userProfile ?? this.userProfile,
      metrics: metrics ?? this.metrics,
      projects: projects ?? this.projects,
      requests: requests ?? this.requests,
      error: error,
    );
  }
}

class SponsorDashboardNotifier extends Notifier<SponsorDashboardState> {
  late final SponsorDashboardRepository _repository;

  @override
  SponsorDashboardState build() {
    _repository = ref.watch(sponsorDashboardRepositoryProvider);
    Future.microtask(() => _loadDashboard());
    return const SponsorDashboardState(
      isLoading: true,
      metrics: [
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
      ],
    );
  }

  Future<void> _loadDashboard({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    SponsorUserProfile? profile;
    List<SponsorDashboardMetric> metrics = state.metrics;
    List<SponsorActiveProjectData> projects = state.projects;
    List<SponsorCollaborationRequestPreview> requests = state.requests;
    String? errorMsg;

    // 1. Fetch user profile & stats cards from GET /api/v1/users/me/
    try {
      profile = await _repository.fetchUserProfile();
      metrics = profile.toMetrics();
    } catch (e) {
      errorMsg = 'Could not load profile: $e';
    }

    // 2. Fetch projects from GET /api/v1/projects/sponsor/
    try {
      projects = await _repository.fetchProjects();
    } catch (e) {
      errorMsg = errorMsg == null
          ? 'Could not load projects: $e'
          : '$errorMsg\nCould not load projects: $e';
    }

    // 3. Collaboration requests
    try {
      requests = await _repository.fetchCollaborationRequests();
    } catch (_) {}

    state = state.copyWith(
      isLoading: false,
      isRefreshing: false,
      userProfile: profile ?? state.userProfile,
      metrics: metrics,
      projects: projects,
      requests: requests,
      error: errorMsg,
    );
  }

  Future<void> refresh() async {
    await _loadDashboard(isRefresh: true);
  }
}

final sponsorDashboardProvider =
    NotifierProvider<SponsorDashboardNotifier, SponsorDashboardState>(
  SponsorDashboardNotifier.new,
);
