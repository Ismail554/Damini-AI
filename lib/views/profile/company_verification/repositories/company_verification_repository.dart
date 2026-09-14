import '../models/company_verification_model.dart';

abstract class CompanyVerificationRepository {
  Future<CompanyVerificationModel> getVerificationStatus();
  Future<bool> submitVerification(CompanyVerificationModel verification);
}

class CompanyVerificationRepositoryImpl implements CompanyVerificationRepository {
  @override
  Future<CompanyVerificationModel> getVerificationStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const CompanyVerificationModel(
      companyName: 'Apex Ventures Ltd.',
      registrationNumber: 'REG-88921-X',
      address: '100 Montgomery St, Suite 400, San Francisco, CA',
      website: 'apexventures.com',
      status: 'pending',
    );
  }

  @override
  Future<bool> submitVerification(CompanyVerificationModel verification) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}
