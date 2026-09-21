import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/onboarding_models.dart';
import '../repositories/onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(apiServiceProvider));
});

final industriesProvider = FutureProvider<List<IndustryModel>>((ref) async {
  return ref.watch(onboardingRepositoryProvider).fetchIndustries();
});

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void initRole(String role) {
    state = state.copyWith(role: role.toLowerCase());
  }

  Future<bool> setRole(String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final success = await ref.read(onboardingRepositoryProvider).setRole(role);
      if (success) {
        await StorageService.saveRole(role.toLowerCase());
        state = state.copyWith(
          role: role.toLowerCase(),
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Failed to set role. Please try again.",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> setAccountType(String type) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final normalizedType = type.toUpperCase() == 'CORPORATE' || type.toUpperCase() == 'COMPANY'
          ? 'COMPANY'
          : 'INDIVIDUAL';
      final success = await ref.read(onboardingRepositoryProvider).setAccountType(
            role: state.role,
            accountType: normalizedType,
          );
      state = state.copyWith(
        accountType: normalizedType,
        isLoading: false,
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> saveProfileDetails({
    required String phone,
    required String country,
    required String location,
    String? photoPath,
    String? positionTitle,
    String? legalCompanyName,
    String? registrationNumber,
    String? businessAddress,
    String? companyWebsite,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final fields = <String, dynamic>{
        'phone': phone,
        'country': country,
        'location': location,
      };

      if (positionTitle != null && positionTitle.isNotEmpty) {
        fields['position_title'] = positionTitle;
      }
      if (state.isCompany) {
        if (legalCompanyName != null && legalCompanyName.isNotEmpty) {
          fields['legal_company_name'] = legalCompanyName;
        }
        if (registrationNumber != null && registrationNumber.isNotEmpty) {
          fields['registration_number'] = registrationNumber;
        }
        if (businessAddress != null && businessAddress.isNotEmpty) {
          fields['business_address'] = businessAddress;
        }
        if (companyWebsite != null && companyWebsite.isNotEmpty) {
          fields['company_website'] = companyWebsite;
        }
      }

      final success = await ref.read(onboardingRepositoryProvider).updateProfileDetails(
            role: state.role,
            fields: fields,
            photoPath: photoPath,
          );

      if (success) {
        state = state.copyWith(
          phone: phone,
          country: country,
          location: location,
          profilePhotoPath: photoPath,
          positionTitle: positionTitle,
          legalCompanyName: legalCompanyName,
          registrationNumber: registrationNumber,
          businessAddress: businessAddress,
          companyWebsite: companyWebsite,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> setInterests(List<int> industryIds) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final success = await ref.read(onboardingRepositoryProvider).setInterests(
            role: state.role,
            industryIds: industryIds,
          );
      if (success) {
        state = state.copyWith(
          selectedIndustryIds: industryIds,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> uploadDocument(String documentType, String filePath) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final success = await ref.read(onboardingRepositoryProvider).uploadVerificationDocument(
            documentType: documentType,
            filePath: filePath,
          );
      if (success) {
        final docs = Map<String, String>.from(state.uploadedDocuments);
        docs[documentType] = filePath;
        state = state.copyWith(
          uploadedDocuments: docs,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<VerificationStatusModel> checkVerificationStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final status = await ref.read(onboardingRepositoryProvider).getVerificationStatus();
      state = state.copyWith(
        verificationStatus: status,
        isLoading: false,
      );
      return status;
    } catch (e) {
      const fallback = VerificationStatusModel(status: 'PENDING');
      state = state.copyWith(
        verificationStatus: fallback,
        isLoading: false,
        errorMessage: e.toString(),
      );
      return fallback;
    }
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
