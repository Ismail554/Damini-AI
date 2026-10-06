import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_project_model.dart';
import '../repositories/sponsor_projects_repository.dart';

class SponsorProjectsState {
  final bool isLoading;
  final bool isRefreshing;
  final List<SponsorProjectModel> allProjects;
  final List<SponsorProjectModel> activeProjects;
  final List<SponsorProjectModel> completedProjects;
  final List<SponsorProjectModel> terminatedProjects;
  final String? error;

  const SponsorProjectsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.allProjects = const [],
    this.activeProjects = const [],
    this.completedProjects = const [],
    this.terminatedProjects = const [],
    this.error,
  });

  SponsorProjectsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<SponsorProjectModel>? allProjects,
    List<SponsorProjectModel>? activeProjects,
    List<SponsorProjectModel>? completedProjects,
    List<SponsorProjectModel>? terminatedProjects,
    String? error,
  }) {
    return SponsorProjectsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      allProjects: allProjects ?? this.allProjects,
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
    Future.microtask(() => _loadProjects());
    return const SponsorProjectsState(isLoading: true);
  }

  Future<void> _loadProjects({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final projects = await _repository.fetchProjects();

      final active = projects
          .where((p) => p.status == SponsorProjectStatus.active)
          .toList();
      final completed = projects
          .where((p) => p.status == SponsorProjectStatus.completed)
          .toList();
      var terminated = projects
          .where((p) => p.status == SponsorProjectStatus.terminated)
          .toList();

      if (terminated.isEmpty) {
        try {
          final termList = await _repository.fetchTerminatedProjects();
          if (termList.isNotEmpty) {
            terminated = termList;
          }
        } catch (_) {}
      }

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        allProjects: projects,
        activeProjects: active,
        completedProjects: completed,
        terminatedProjects: terminated,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: state.allProjects.isEmpty
            ? 'Failed to load projects: $e'
            : null,
      );
    }
  }

  Future<void> refresh() async {
    await _loadProjects(isRefresh: true);
  }
}

final sponsorProjectsProvider =
    NotifierProvider<SponsorProjectsNotifier, SponsorProjectsState>(
  SponsorProjectsNotifier.new,
);
