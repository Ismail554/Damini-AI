import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/request_collaboration_model.dart';
import '../repositories/request_collaboration_repository.dart';

final requestCollaborationRepositoryProvider =
    Provider<RequestCollaborationRepository>((ref) {
  return RequestCollaborationRepositoryImpl();
});

class RequestCollaborationState {
  final bool isLoading;
  final bool isSubmitted;
  final String? errorMessage;

  const RequestCollaborationState({
    this.isLoading = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  RequestCollaborationState copyWith({
    bool? isLoading,
    bool? isSubmitted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RequestCollaborationState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final requestCollaborationProvider = NotifierProvider<
    RequestCollaborationNotifier, RequestCollaborationState>(
  RequestCollaborationNotifier.new,
);

class RequestCollaborationNotifier
    extends Notifier<RequestCollaborationState> {
  @override
  RequestCollaborationState build() => const RequestCollaborationState();

  Future<bool> submitRequest(CollaborationSubmissionModel submission) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read(requestCollaborationRepositoryProvider);
      final success = await repo.submitCollaborationRequest(submission);
      state = state.copyWith(isLoading: false, isSubmitted: success);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() {
    state = const RequestCollaborationState();
  }
}
