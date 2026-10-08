import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company_verification_model.dart';
import '../repositories/company_verification_repository.dart';

class CompanyVerificationState {
  final CompanyVerificationModel verification;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitted;

  const CompanyVerificationState({
    this.verification = const CompanyVerificationModel(),
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitted = false,
  });

  CompanyVerificationState copyWith({
    CompanyVerificationModel? verification,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitted,
    bool clearError = false,
  }) {
    return CompanyVerificationState(
      verification: verification ?? this.verification,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class CompanyVerificationNotifier extends Notifier<CompanyVerificationState> {
  late final CompanyVerificationRepository _repo;

  @override
  CompanyVerificationState build() {
    _repo = ref.watch(companyVerificationRepositoryProvider);
    Future.microtask(() => loadStatus());
    return const CompanyVerificationState(isLoading: true);
  }

  Future<void> loadStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final status = await _repo.getVerificationStatus();
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        verification: status,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateModel(CompanyVerificationModel model) {
    state = state.copyWith(verification: model);
  }

  void setBusinessLicense(String? path) {
    state = state.copyWith(
      verification: state.verification.copyWith(businessLicensePath: path),
    );
  }

  void setTaxDocument(String? path) {
    state = state.copyWith(
      verification: state.verification.copyWith(taxDocumentPath: path),
    );
  }

  Future<bool> submitVerification() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final success = await _repo.submitVerification(state.verification);
      await loadStatus();
      state = state.copyWith(isLoading: false, isSubmitted: success);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

final companyVerificationProvider = NotifierProvider.autoDispose<
    CompanyVerificationNotifier, CompanyVerificationState>(
  CompanyVerificationNotifier.new,
);
