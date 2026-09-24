import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investor_profile_model.dart';
import '../repositories/investor_profile_repository.dart';

class InvestorProfileState {
  final InvestorProfileModel profile;
  final bool isLoading;

  const InvestorProfileState({
    this.profile = const InvestorProfileModel(),
    this.isLoading = false,
  });

  InvestorProfileState copyWith({
    InvestorProfileModel? profile,
    bool? isLoading,
  }) {
    return InvestorProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class InvestorProfileNotifier extends Notifier<InvestorProfileState> {
  late final InvestorProfileRepository _repo;

  @override
  InvestorProfileState build() {
    _repo = ref.read(investorProfileRepositoryProvider);
    Future.microtask(() => _loadProfile());
    return const InvestorProfileState();
  }

  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true);
    final data = await _repo.getProfile();
    state = state.copyWith(profile: data, isLoading: false);
  }

  Future<void> refreshProfile() async {
    // Pull-to-refresh: update without blanking existing data (Workflow 7.3)
    final data = await _repo.getProfile();
    state = state.copyWith(profile: data);
  }

  void updateProfile(InvestorProfileModel model) {
    state = state.copyWith(profile: model);
  }
}

final investorProfileProvider =
    NotifierProvider<InvestorProfileNotifier, InvestorProfileState>(
  InvestorProfileNotifier.new,
);
