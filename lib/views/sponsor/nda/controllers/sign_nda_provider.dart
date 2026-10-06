import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/sign_nda_repository.dart';

class SignNdaState {
  final bool isAgreed;
  final String signatureText;
  final String? signatureImagePath;
  final String? signatureFileName;
  final bool isSubmitting;
  final String? errorMessage;
  final bool needsCollaborationRequest;

  const SignNdaState({
    this.isAgreed = false,
    this.signatureText = '',
    this.signatureImagePath,
    this.signatureFileName,
    this.isSubmitting = false,
    this.errorMessage,
    this.needsCollaborationRequest = false,
  });

  bool get canSubmit =>
      isAgreed &&
      !isSubmitting &&
      (signatureText.trim().isNotEmpty ||
          (signatureImagePath != null && signatureImagePath!.isNotEmpty));

  SignNdaState copyWith({
    bool? isAgreed,
    String? signatureText,
    String? signatureImagePath,
    String? signatureFileName,
    bool clearImage = false,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? needsCollaborationRequest,
  }) {
    return SignNdaState(
      isAgreed: isAgreed ?? this.isAgreed,
      signatureText: signatureText ?? this.signatureText,
      signatureImagePath:
          clearImage ? null : (signatureImagePath ?? this.signatureImagePath),
      signatureFileName:
          clearImage ? null : (signatureFileName ?? this.signatureFileName),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      needsCollaborationRequest:
          needsCollaborationRequest ?? this.needsCollaborationRequest,
    );
  }
}

class SignNdaNotifier extends Notifier<SignNdaState> {
  @override
  SignNdaState build() => const SignNdaState();

  void toggleAgreement(bool value) {
    state = state.copyWith(isAgreed: value);
  }

  void setSignatureText(String text) {
    state = state.copyWith(signatureText: text);
  }

  void setSignatureImage({
    required String imagePath,
    required String fileName,
  }) {
    state = state.copyWith(
      signatureImagePath: imagePath,
      signatureFileName: fileName,
      clearError: true,
    );
  }

  void removeSignatureImage() {
    state = state.copyWith(clearImage: true);
  }

  void clearCollaborationPrecondition() {
    state = state.copyWith(needsCollaborationRequest: false, clearError: true);
  }

  Future<SignNdaResult> submit(String projectId) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      needsCollaborationRequest: false,
    );

    final repo = ref.read(signNdaRepositoryProvider);
    final result = await repo.signNda(
      projectId: projectId,
      digitalSignature: state.signatureText.trim().isNotEmpty
          ? state.signatureText.trim()
          : (state.signatureFileName ?? 'Authorized Signer'),
      signatureImagePath: state.signatureImagePath,
    );

    state = state.copyWith(
      isSubmitting: false,
      errorMessage: result.isSuccess ? null : result.message,
      needsCollaborationRequest: result.needsCollaborationRequest,
    );

    return result;
  }
}

final signNdaProvider =
    NotifierProvider.autoDispose<SignNdaNotifier, SignNdaState>(
  SignNdaNotifier.new,
);
