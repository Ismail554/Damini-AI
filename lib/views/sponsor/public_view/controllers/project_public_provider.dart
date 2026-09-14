import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_public_view_model.dart';
import '../repositories/project_public_repository.dart';

class ProjectPublicState {
  final bool isLoading;
  final ProjectPublicViewModel? project;
  final bool isSaved;
  final String? error;

  const ProjectPublicState({
    this.isLoading = false,
    this.project,
    this.isSaved = false,
    this.error,
  });

  ProjectPublicState copyWith({
    bool? isLoading,
    ProjectPublicViewModel? project,
    bool? isSaved,
    String? error,
  }) {
    return ProjectPublicState(
      isLoading: isLoading ?? this.isLoading,
      project: project ?? this.project,
      isSaved: isSaved ?? this.isSaved,
      error: error,
    );
  }
}

class ProjectPublicNotifier extends Notifier<ProjectPublicState> {
  late final ProjectPublicRepository _repository;

  @override
  ProjectPublicState build() {
    _repository = ref.watch(projectPublicRepositoryProvider);
    _loadProject();
    return const ProjectPublicState(isLoading: true);
  }

  Future<void> _loadProject([String? id]) async {
    try {
      final data = await _repository.fetchProjectPublicDetails(id);
      state = state.copyWith(isLoading: false, project: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleSave() {
    state = state.copyWith(isSaved: !state.isSaved);
  }

  void setProject(ProjectPublicViewModel project) {
    state = state.copyWith(project: project, isLoading: false);
  }
}

final projectPublicProvider =
    NotifierProvider<ProjectPublicNotifier, ProjectPublicState>(
  ProjectPublicNotifier.new,
);
