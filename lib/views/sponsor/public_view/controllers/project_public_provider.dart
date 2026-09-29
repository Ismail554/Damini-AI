import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../saved/controllers/sponsor_saved_provider.dart';
import '../models/project_public_view_model.dart';
import '../repositories/project_public_repository.dart';

class ProjectPublicState {
  final bool isLoading;
  final bool isSaving;
  final ProjectPublicViewModel? project;
  final bool isSaved;
  final String? error;

  const ProjectPublicState({
    this.isLoading = false,
    this.isSaving = false,
    this.project,
    this.isSaved = false,
    this.error,
  });

  ProjectPublicState copyWith({
    bool? isLoading,
    bool? isSaving,
    ProjectPublicViewModel? project,
    bool? isSaved,
    String? error,
  }) {
    return ProjectPublicState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
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
      state = state.copyWith(
        isLoading: false,
        project: data,
        isSaved: data.isSaved,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Toggle bookmark/save for the project via POST /api/v1/projects/{id}/save/
  Future<bool> toggleSave([String? projectId]) async {
    final id = projectId ?? state.project?.id;
    if (id == null || id.isEmpty) {
      final next = !state.isSaved;
      state = state.copyWith(isSaved: next);
      return next;
    }

    final prevSaved = state.isSaved;
    state = state.copyWith(isSaved: !prevSaved, isSaving: true);

    try {
      final result = await _repository.toggleSaveProject(id);
      final finalSaved = result ?? !prevSaved;
      state = state.copyWith(isSaved: finalSaved, isSaving: false);

      // Notify SponsorSavedView and provider to update /api/v1/projects/saved/
      ref.read(sponsorSavedProvider.notifier).onProjectBookmarkToggled(
        projectId: id,
        isSaved: finalSaved,
      );

      return finalSaved;
    } catch (e) {
      state = state.copyWith(isSaved: prevSaved, isSaving: false);
      rethrow;
    }
  }

  void setProject(ProjectPublicViewModel project) {
    state = state.copyWith(
      project: project,
      isSaved: project.isSaved,
      isLoading: false,
    );
  }
}

final projectPublicProvider =
    NotifierProvider<ProjectPublicNotifier, ProjectPublicState>(
  ProjectPublicNotifier.new,
);
