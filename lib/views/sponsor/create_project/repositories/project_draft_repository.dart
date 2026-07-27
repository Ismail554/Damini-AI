import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_draft_model.dart';

class ProjectDraftRepository {
  static const String _key = 'cached_sponsor_project_drafts';

  Future<List<ProjectDraftModel>> getDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? rawList = prefs.getStringList(_key);

    if (rawList == null || rawList.isEmpty) {
      return ProjectDraftModel.mockDrafts();
    }

    try {
      return rawList.map((item) => ProjectDraftModel.fromJson(item)).toList();
    } catch (_) {
      return ProjectDraftModel.mockDrafts();
    }
  }

  Future<void> saveDrafts(List<ProjectDraftModel> drafts) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = drafts.map((d) => d.toJson()).toList();
    await prefs.setStringList(_key, rawList);
  }
}
