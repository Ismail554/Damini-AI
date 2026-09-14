import '../models/investor_profile_model.dart';

abstract class InvestorProfileRepository {
  Future<InvestorProfileModel> getProfile();
}

class InvestorProfileRepositoryImpl implements InvestorProfileRepository {
  @override
  Future<InvestorProfileModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const InvestorProfileModel();
  }
}
