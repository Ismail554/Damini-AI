import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../sponsor/saved/controllers/sponsor_saved_provider.dart';
import '../../../sponsor/saved/repositories/sponsor_saved_repository.dart';
import '../models/public_profile_model.dart';
import '../repositories/public_profile_repository.dart';

final publicProfileRepositoryProvider = Provider<PublicProfileRepository>((ref) {
  return PublicProfileRepositoryImpl(ref.watch(apiServiceProvider));
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
    return const PublicProfileState();
  }

  Future<void> loadProfile([String? userId]) async {
    if (userId == null || userId.trim().isEmpty) return;
    state = state.copyWith(isLoading: true);
    final data = await _repo.getPublicProfile(userId.trim());
    state = state.copyWith(profile: data, isLoading: false);
  }
}

final publicProfileProvider =
    NotifierProvider.autoDispose<PublicProfileNotifier, PublicProfileState>(
  PublicProfileNotifier.new,
);

class ProfileBookmarkState {
  final bool isSaved;
  final bool isLoading;

  const ProfileBookmarkState({
    this.isSaved = false,
    this.isLoading = false,
  });

  ProfileBookmarkState copyWith({
    bool? isSaved,
    bool? isLoading,
  }) {
    return ProfileBookmarkState(
      isSaved: isSaved ?? this.isSaved,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileBookmarkNotifier extends Notifier<ProfileBookmarkState> {
  final String userId;
  ProfileBookmarkNotifier(this.userId);

  late final SponsorSavedRepository _savedRepo;

  @override
  ProfileBookmarkState build() {
    _savedRepo = ref.watch(sponsorSavedRepositoryProvider);
    final savedState = ref.watch(sponsorSavedProvider);
    final isAlreadySaved = savedState.rawProfiles
        .any((p) => p.userId == userId || p.id == userId);

    // Also fetch live is_saved flag from GET /api/v1/profiles/<userId>/
    Future.microtask(() async {
      final liveProfile =
          await ref.read(publicProfileRepositoryProvider).getPublicProfile(userId);
      if (liveProfile.id.isNotEmpty) {
        setInitial(liveProfile.isSaved);
      }
    });

    return ProfileBookmarkState(isSaved: isAlreadySaved);
  }

  void setInitial(bool isSaved) {
    if (state.isSaved != isSaved && !state.isLoading) {
      state = state.copyWith(isSaved: isSaved);
    }
  }

  Future<bool> toggleBookmark() async {
    if (state.isLoading) return state.isSaved;

    final targetUserId = userId;
    final previousSaved = state.isSaved;
    final newSaved = !previousSaved;

    // Optimistic UI update
    state = state.copyWith(isSaved: newSaved, isLoading: true);

    try {
      final backendSaved = await _savedRepo.toggleSaveProfile(targetUserId);
      final finalSaved = backendSaved ?? newSaved;

      state = state.copyWith(isSaved: finalSaved, isLoading: false);

      // Notify the saved provider to update saved lists seamlessly
      ref.read(sponsorSavedProvider.notifier).onProfileBookmarkToggled(
            userId: targetUserId,
            isSaved: finalSaved,
          );

      return finalSaved;
    } catch (e) {
      // Revert optimistic update on failure
      state = state.copyWith(isSaved: previousSaved, isLoading: false);
      rethrow;
    }
  }
}

final profileBookmarkProvider = NotifierProvider.autoDispose
    .family<ProfileBookmarkNotifier, ProfileBookmarkState, String>(
  ProfileBookmarkNotifier.new,
);
