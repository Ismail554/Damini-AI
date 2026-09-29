import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_draft_model.dart';

class ProjectDraftRepository {
  static const String _key = 'cached_sponsor_project_drafts';

  Future<List<ProjectDraftModel>> getDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? rawList = prefs.getStringList(_key);

      if (rawList == null || rawList.isEmpty) {
        return [];
      }

      final drafts = <ProjectDraftModel>[];
      for (final item in rawList) {
        try {
          drafts.add(ProjectDraftModel.fromJson(item));
        } catch (_) {
          continue;
        }
      }
      return drafts;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDrafts(List<ProjectDraftModel> drafts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = drafts.map((d) => d.toJson()).toList();
      await prefs.setStringList(_key, rawList);
    } catch (_) {}
  }
}
