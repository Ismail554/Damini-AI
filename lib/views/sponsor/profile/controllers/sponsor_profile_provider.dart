import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_profile_model.dart';
import '../repositories/sponsor_profile_repository.dart';

class SponsorProfileState {
  final bool isLoading;
  final SponsorProfileData? profile;
  final String? error;

  const SponsorProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  SponsorProfileState copyWith({
    bool? isLoading,
    SponsorProfileData? profile,
    String? error,
  }) {
    return SponsorProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

class SponsorProfileNotifier extends Notifier<SponsorProfileState> {
  late final SponsorProfileRepository _repository;

  @override
  SponsorProfileState build() {
    _repository = ref.watch(sponsorProfileRepositoryProvider);
    _loadProfile();
    return const SponsorProfileState(isLoading: true);
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _repository.fetchProfile();
      state = state.copyWith(isLoading: false, profile: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadProfile();
  }
}

final sponsorProfileProvider =
    NotifierProvider<SponsorProfileNotifier, SponsorProfileState>(
  SponsorProfileNotifier.new,
);
