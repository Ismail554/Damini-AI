import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/public_profile_model.dart';
import '../repositories/public_profile_repository.dart';

final publicProfileRepositoryProvider = Provider<PublicProfileRepository>((ref) {
  return PublicProfileRepositoryImpl();
});

class PublicProfileState {
  final PublicProfileModel profile;
  final bool isLoading;

  const PublicProfileState({
    this.profile = const PublicProfileModel(),
    this.isLoading = false,
  });

  PublicProfileState copyWith({
    PublicProfileModel? profile,
    bool? isLoading,
  }) {
    return PublicProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PublicProfileNotifier extends Notifier<PublicProfileState> {
  late final PublicProfileRepository _repo;

  @override
  PublicProfileState build() {
    _repo = ref.read(publicProfileRepositoryProvider);
    _loadProfile();
    return const PublicProfileState();
  }

  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true);
    final data = await _repo.getPublicProfile();
    state = state.copyWith(profile: data, isLoading: false);
  }
}

final publicProfileProvider =
    NotifierProvider.autoDispose<PublicProfileNotifier, PublicProfileState>(
  PublicProfileNotifier.new,
);
