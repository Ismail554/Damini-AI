import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_project_model.dart';
import '../repositories/sponsor_projects_repository.dart';

class SponsorProjectsState {
  final bool isLoading;
  final List<SponsorProjectModel> activeProjects;
  final List<SponsorProjectModel> completedProjects;
  final List<SponsorProjectModel> terminatedProjects;
  final String? error;

  const SponsorProjectsState({
    this.isLoading = false,
    this.activeProjects = const [],
    this.completedProjects = const [],
    this.terminatedProjects = const [],
    this.error,
  });

  SponsorProjectsState copyWith({
    bool? isLoading,
    List<SponsorProjectModel>? activeProjects,
    List<SponsorProjectModel>? completedProjects,
    List<SponsorProjectModel>? terminatedProjects,
    String? error,
  }) {
    return SponsorProjectsState(
      isLoading: isLoading ?? this.isLoading,
      activeProjects: activeProjects ?? this.activeProjects,
      completedProjects: completedProjects ?? this.completedProjects,
      terminatedProjects: terminatedProjects ?? this.terminatedProjects,
      error: error,
    );
  }
}

class SponsorProjectsNotifier extends Notifier<SponsorProjectsState> {
  late final SponsorProjectsRepository _repository;

  @override
  SponsorProjectsState build() {
    _repository = ref.watch(sponsorProjectsRepositoryProvider);
    _loadProjects();
    return const SponsorProjectsState(isLoading: true);
  }

  Future<void> _loadProjects() async {
    try {
      final active = await _repository.fetchActiveProjects();
      final completed = await _repository.fetchCompletedProjects();
      final terminated = await _repository.fetchTerminatedProjects();
      state = state.copyWith(
        isLoading: false,
        activeProjects: active,
        completedProjects: completed,
        terminatedProjects: terminated,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadProjects();
  }
}

final sponsorProjectsProvider =
    NotifierProvider<SponsorProjectsNotifier, SponsorProjectsState>(
  SponsorProjectsNotifier.new,
);
