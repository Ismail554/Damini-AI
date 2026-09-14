import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_project_details_model.dart';

final sponsorProjectDetailsRepositoryProvider =
    Provider<SponsorProjectDetailsRepository>((ref) {
  return SponsorProjectDetailsRepository();
});

class SponsorProjectDetailsRepository {
  Future<SponsorProjectDetailsModel> fetchProjectDetails(String projectId) async {
    return SponsorProjectDetailsModel.mockData();
  }
}
