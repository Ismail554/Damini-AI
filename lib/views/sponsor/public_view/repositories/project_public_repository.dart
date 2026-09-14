import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_public_view_model.dart';

final projectPublicRepositoryProvider =
    Provider<ProjectPublicRepository>((ref) {
  return ProjectPublicRepository();
});

class ProjectPublicRepository {
  Future<ProjectPublicViewModel> fetchProjectPublicDetails([String? id]) async {
    return ProjectPublicViewModel.mockData();
  }
}
