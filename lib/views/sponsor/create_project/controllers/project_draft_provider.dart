import 'package:flutter/material.dart';
import '../models/project_draft_model.dart';
import '../repositories/project_draft_repository.dart';

class ProjectDraftProvider extends ChangeNotifier {
  final ProjectDraftRepository _repository = ProjectDraftRepository();

  List<ProjectDraftModel> _drafts = [];
  List<ProjectDraftModel> get drafts => _drafts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProjectDraftProvider() {
    loadDrafts();
  }

  Future<void> loadDrafts() async {
    _isLoading = true;
    notifyListeners();
    _drafts = await _repository.getDrafts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveDraft(ProjectDraftModel draft) async {
    final index = _drafts.indexWhere((d) => d.id == draft.id);
    if (index != -1) {
      _drafts[index] = draft;
    } else {
      _drafts.insert(0, draft);
    }
    notifyListeners();
    await _repository.saveDrafts(_drafts);
  }

  Future<void> deleteDraft(String id) async {
    _drafts.removeWhere((d) => d.id == id);
    notifyListeners();
    await _repository.saveDrafts(_drafts);
  }
}
