import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_project_model.dart';

final sponsorProjectsRepositoryProvider =
    Provider<SponsorProjectsRepository>((ref) {
  return SponsorProjectsRepository();
});

class SponsorProjectsRepository {
  Future<List<SponsorProjectModel>> fetchActiveProjects() async {
    return SponsorProjectModel.mockActiveList();
  }

  Future<List<SponsorProjectModel>> fetchCompletedProjects() async {
    return SponsorProjectModel.mockCompletedList();
  }

  Future<List<SponsorProjectModel>> fetchTerminatedProjects() async {
    return SponsorProjectModel.mockTerminatedList();
  }
}
