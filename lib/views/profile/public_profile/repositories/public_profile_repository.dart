import '../models/public_profile_model.dart';

abstract class PublicProfileRepository {
  Future<PublicProfileModel> getPublicProfile();
}

class PublicProfileRepositoryImpl implements PublicProfileRepository {
  @override
  Future<PublicProfileModel> getPublicProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const PublicProfileModel();
  }
}
