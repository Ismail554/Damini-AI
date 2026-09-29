import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_draft_model.dart';
import '../repositories/project_draft_repository.dart';

class ProjectDraftState {
  final List<ProjectDraftModel> drafts;
  final bool isLoading;

  const ProjectDraftState({
    this.drafts = const [],
    this.isLoading = false,
  });

  ProjectDraftState copyWith({
    List<ProjectDraftModel>? drafts,
    bool? isLoading,
  }) {
    return ProjectDraftState(
      drafts: drafts ?? this.drafts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final projectDraftProvider =
    NotifierProvider<ProjectDraftNotifier, ProjectDraftState>(
        ProjectDraftNotifier.new);

class ProjectDraftNotifier extends Notifier<ProjectDraftState> {
  late final ProjectDraftRepository _repository;

  @override
  ProjectDraftState build() {
    _repository = ProjectDraftRepository();
    Future.microtask(() => loadDrafts());
    return const ProjectDraftState(isLoading: true);
  }

  Future<void> loadDrafts() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getDrafts();
      state = state.copyWith(drafts: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(drafts: [], isLoading: false);
    }
  }

  Future<void> saveDraft(ProjectDraftModel draft) async {
    final list = List<ProjectDraftModel>.from(state.drafts);
    final index = list.indexWhere((d) => d.id == draft.id);
    if (index != -1) {
      list[index] = draft;
    } else {
      list.insert(0, draft);
    }
    state = state.copyWith(drafts: list, isLoading: false);
    try {
      await _repository.saveDrafts(list);
    } catch (_) {}
  }

  Future<void> deleteDraft(String id) async {
    final list = List<ProjectDraftModel>.from(state.drafts)
      ..removeWhere((d) => d.id == id);
    state = state.copyWith(drafts: list, isLoading: false);
    try {
      await _repository.saveDrafts(list);
    } catch (_) {}
  }

  /// Remove draft after successful publish (if editing an existing draft)
  Future<void> deleteDraftIfExists(String? draftId) async {
    if (draftId == null || draftId.isEmpty) return;
    await deleteDraft(draftId);
  }
}
