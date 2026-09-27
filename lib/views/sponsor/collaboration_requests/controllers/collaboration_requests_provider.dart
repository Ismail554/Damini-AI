import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collaboration_request_model.dart';
import '../repositories/collaboration_requests_repository.dart';

class CollaborationRequestsState {
  final bool isLoading;
  final bool isRefreshing;
  final List<CollaborationRequestModel> pendingList;
  final List<CollaborationRequestModel> approvedList;
  final List<CollaborationRequestModel> confirmationList;
  final String? error;

  const CollaborationRequestsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.pendingList = const [],
    this.approvedList = const [],
    this.confirmationList = const [],
    this.error,
  });

  CollaborationRequestsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<CollaborationRequestModel>? pendingList,
    List<CollaborationRequestModel>? approvedList,
    List<CollaborationRequestModel>? confirmationList,
    String? error,
  }) {
    return CollaborationRequestsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
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
    Future.microtask(() => _loadRequests());
    return const CollaborationRequestsState(isLoading: true);
  }

  Future<void> _loadRequests({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final all = await _repository.fetchCollaborationRequests();

      final pending =
          all.where((r) => r.status.toUpperCase() == 'PENDING').toList();
      final approved = all
          .where((r) =>
              r.status.toUpperCase() == 'APPROVED' ||
              r.status.toUpperCase() == 'ACCEPTED')
          .toList();
      final confirmations = all
          .where((r) =>
              r.status.toUpperCase() == 'CONFIRMED' ||
              r.status.toUpperCase() == 'RECEIVED')
          .toList();

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        pendingList: pending,
        approvedList: approved,
        confirmationList: confirmations,
        error: null,
      );
    } catch (e) {
      // If error occurs, keep previous data if available, otherwise set error
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: state.pendingList.isEmpty &&
                state.approvedList.isEmpty &&
                state.confirmationList.isEmpty
            ? 'Failed to load requests: $e'
            : null,
      );
    }
  }

  Future<void> refresh() async {
    await _loadRequests(isRefresh: true);
  }

  void approvePendingRequest(CollaborationRequestModel item) {
    final pending = List<CollaborationRequestModel>.from(state.pendingList)
      ..removeWhere((req) => req.id == item.id);

    final approvedItem = item.copyWith(
      badgeText: 'Approved',
      isApprovedBadge: true,
      isHistory: true,
      status: 'APPROVED',
    );

    final approved = List<CollaborationRequestModel>.from(state.approvedList)
      ..insert(0, approvedItem);

    state = state.copyWith(
      pendingList: pending,
      approvedList: approved,
    );
  }

  void rejectPendingRequest(String id) {
    state = state.copyWith(
      pendingList: state.pendingList.where((req) => req.id != id).toList(),
    );
  }

  void removeApprovedRequest(String id) {
    state = state.copyWith(
      approvedList: state.approvedList.where((req) => req.id != id).toList(),
    );
  }

  void markFundReceived(String confirmationId) {
    final confirmations =
        List<CollaborationRequestModel>.from(state.confirmationList);
    final index =
        confirmations.indexWhere((item) => item.id == confirmationId);
    if (index == -1) return;

    confirmations[index] = confirmations[index].copyWith(
      badgeText: 'Received',
      isApprovedBadge: true,
      hasFundReceivedButton: false,
      status: 'RECEIVED',
    );

    state = state.copyWith(confirmationList: confirmations);
  }
}

final collaborationRequestsProvider = NotifierProvider<
    CollaborationRequestsNotifier, CollaborationRequestsState>(
  CollaborationRequestsNotifier.new,
);
