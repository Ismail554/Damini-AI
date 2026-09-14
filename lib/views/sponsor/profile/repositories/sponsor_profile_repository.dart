import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_profile_model.dart';

final sponsorProfileRepositoryProvider = Provider<SponsorProfileRepository>((ref) {
  return SponsorProfileRepository();
});

class SponsorProfileRepository {
  Future<SponsorProfileData> fetchProfile() async {
    return const SponsorProfileData(
      name: "Shawn Blake",
      title: "Managing Director at Austin Tech Capital",
      avatarUrl:
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop",
      investedAmount: "\$1.2M",
      projectsCount: "2",
    );
  }
}
