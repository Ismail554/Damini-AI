import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_saved_profile_model.dart';
import '../models/sponsor_saved_project_model.dart';

final sponsorSavedRepositoryProvider = Provider<SponsorSavedRepository>((ref) {
  return SponsorSavedRepository();
});

class SponsorSavedRepository {
  Future<List<SponsorSavedProjectModel>> fetchSavedProjects() async {
    return SponsorSavedProjectModel.mockList();
  }

  Future<List<SponsorSavedProfileModel>> fetchSavedProfiles() async {
    return SponsorSavedProfileModel.mockList();
  }
}
