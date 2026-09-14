import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_dashboard_models.dart';
import '../repositories/sponsor_dashboard_repository.dart';

class SponsorDashboardState {
  final bool isLoading;
  final List<SponsorDashboardMetric> metrics;
  final SponsorActiveProjectData? activeProject;
  final List<SponsorCollaborationRequestPreview> requests;
  final String? error;

  const SponsorDashboardState({
    this.isLoading = false,
    this.metrics = const [],
    this.activeProject,
    this.requests = const [],
    this.error,
  });

  SponsorDashboardState copyWith({
    bool? isLoading,
    List<SponsorDashboardMetric>? metrics,
    SponsorActiveProjectData? activeProject,
    List<SponsorCollaborationRequestPreview>? requests,
    String? error,
  }) {
    return SponsorDashboardState(
      isLoading: isLoading ?? this.isLoading,
      metrics: metrics ?? this.metrics,
      activeProject: activeProject ?? this.activeProject,
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
    _loadDashboard();
    return const SponsorDashboardState(isLoading: true);
  }

  Future<void> _loadDashboard() async {
    try {
      final metrics = await _repository.fetchMetrics();
      final project = await _repository.fetchActiveProject();
      final requests = await _repository.fetchCollaborationRequests();
      state = state.copyWith(
        isLoading: false,
        metrics: metrics,
        activeProject: project,
        requests: requests,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadDashboard();
  }
}

final sponsorDashboardProvider =
    NotifierProvider<SponsorDashboardNotifier, SponsorDashboardState>(
  SponsorDashboardNotifier.new,
);
