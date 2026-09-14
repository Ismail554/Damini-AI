import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collaboration_request_model.dart';
import '../repositories/collaboration_requests_repository.dart';

class CollaborationRequestsState {
  final bool isLoading;
  final List<CollaborationRequestModel> pendingList;
  final List<CollaborationRequestModel> approvedList;
  final List<CollaborationRequestModel> confirmationList;
  final String? error;

  const CollaborationRequestsState({
    this.isLoading = false,
    this.pendingList = const [],
    this.approvedList = const [],
    this.confirmationList = const [],
    this.error,
  });

  CollaborationRequestsState copyWith({
    bool? isLoading,
    List<CollaborationRequestModel>? pendingList,
    List<CollaborationRequestModel>? approvedList,
    List<CollaborationRequestModel>? confirmationList,
    String? error,
  }) {
    return CollaborationRequestsState(
      isLoading: isLoading ?? this.isLoading,
      pendingList: pendingList ?? this.pendingList,
      approvedList: approvedList ?? this.approvedList,
      confirmationList: confirmationList ?? this.confirmationList,
      error: error,
    );
  }
}

class CollaborationRequestsNotifier
    extends Notifier<CollaborationRequestsState> {
  late final CollaborationRequestsRepository _repository;

  @override
  CollaborationRequestsState build() {
    _repository = ref.watch(collaborationRequestsRepositoryProvider);
    _loadRequests();
    return const CollaborationRequestsState(isLoading: true);
  }

  Future<void> _loadRequests() async {
    try {
      final pending = await _repository.fetchPendingRequests();
      final approved = await _repository.fetchApprovedRequests();
      final confirmations = await _repository.fetchConfirmationRequests();
      state = state.copyWith(
        isLoading: false,
        pendingList: pending,
        approvedList: approved,
        confirmationList: confirmations,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void approvePendingRequest(CollaborationRequestModel item) {
    final pending = List<CollaborationRequestModel>.from(state.pendingList)
      ..removeWhere((req) => req.id == item.id);

    final approved = List<CollaborationRequestModel>.from(state.approvedList)
      ..insert(
        0,
        CollaborationRequestModel(
          id: item.id,
          investorName: item.investorName,
          investorType: item.investorType,
          avatarUrl: item.avatarUrl,
          badgeText: 'Approved',
          isApprovedBadge: true,
          projectName: item.projectName,
          proposedBudget: item.proposedBudget,
          proposalText: item.proposalText,
          isHistory: true,
        ),
      );

    state = state.copyWith(
      pendingList: pending,
      approvedList: approved,
    );
  }

  void rejectPendingRequest(String id) {
    state = state.copyWith(
      pendingList:
          state.pendingList.where((req) => req.id != id).toList(),
    );
  }
}

final collaborationRequestsProvider = NotifierProvider<
    CollaborationRequestsNotifier, CollaborationRequestsState>(
  CollaborationRequestsNotifier.new,
);
