import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nda_model.dart';
import '../repositories/nda_repository.dart';

class NdaState {
  final bool isLoading;
  final NdaAgreementModel? agreement;
  final bool isAgreed;
  final String signature;
  final String? signatureFileName;
  final bool isSubmitting;
  final String? error;

  const NdaState({
    this.isLoading = false,
    this.agreement,
    this.isAgreed = false,
    this.signature = '',
    this.signatureFileName,
    this.isSubmitting = false,
    this.error,
  });

  bool get canSubmit =>
      isAgreed && (signature.trim().isNotEmpty || signatureFileName != null);

  NdaState copyWith({
    bool? isLoading,
    NdaAgreementModel? agreement,
    bool? isAgreed,
    String? signature,
    String? signatureFileName,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return NdaState(
      isLoading: isLoading ?? this.isLoading,
      agreement: agreement ?? this.agreement,
      isAgreed: isAgreed ?? this.isAgreed,
      signature: signature ?? this.signature,
      signatureFileName: signatureFileName ?? this.signatureFileName,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NdaNotifier extends Notifier<NdaState> {
  late final NdaRepository _repository;

  @override
  NdaState build() {
    _repository = ref.watch(ndaRepositoryProvider);
    _loadAgreement();
    return const NdaState(isLoading: true);
  }

  Future<void> _loadAgreement() async {
    try {
      final data = await _repository.fetchSponsorNda();
      state = state.copyWith(isLoading: false, agreement: data, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadAgreement();
  }

  void toggleAgreement(bool value) {
    state = state.copyWith(isAgreed: value);
  }

  void setSignature(String signature) {
    state = state.copyWith(signature: signature);
  }

  void setSignatureFileName(String? fileName) {
    state = state.copyWith(signatureFileName: fileName);
  }

  Future<bool> updateSponsorNda({
    String? confidentialityTerms,
    String? pitchDeckPath,
    List<String>? customClauses,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final updated = await _repository.updateSponsorNda(
        confidentialityTerms: confidentialityTerms,
        pitchDeckPath: pitchDeckPath,
        customClauses: customClauses,
      );
      state = state.copyWith(
        isSubmitting: false,
        agreement: updated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final success = await _repository.submitSignature(
        ndaId: state.agreement?.title ?? 'nda',
        signatureText: state.signature,
        signatureImagePath: state.signatureFileName,
      );
      state = state.copyWith(isSubmitting: false);
      return success;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final ndaProvider =
    NotifierProvider.autoDispose<NdaNotifier, NdaState>(
  NdaNotifier.new,
);
