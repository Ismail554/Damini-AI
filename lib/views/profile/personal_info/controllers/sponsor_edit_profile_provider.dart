import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../sponsor/profile/controllers/sponsor_profile_provider.dart';
import '../models/sponsor_edit_profile_model.dart';
import '../repositories/sponsor_edit_profile_repository.dart';
import 'personal_info_provider.dart';

class SponsorEditProfileState {
  final SponsorEditProfileModel? profile;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const SponsorEditProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  SponsorEditProfileState copyWith({
    SponsorEditProfileModel? profile,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return SponsorEditProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class SponsorEditProfileNotifier extends Notifier<SponsorEditProfileState> {
  late final SponsorEditProfileRepository _repository;

  @override
  SponsorEditProfileState build() {
    _repository = ref.watch(sponsorEditProfileRepositoryProvider);
    _loadProfile();
    return const SponsorEditProfileState(isLoading: true);
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(
        isLoading: false,
        profile: profile,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _loadProfile();
  }

  Future<bool> saveProfile({
    required SponsorEditProfileModel updatedProfile,
    String? fullName,
    File? photoFile,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      // 1. Update Name if provided and changed
      if (fullName != null && fullName.trim().isNotEmpty) {
        final parts = fullName.trim().split(' ');
        final firstName = parts.first;
        final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        final currentFirst = state.profile?.firstName ?? '';
        final currentLast = state.profile?.lastName ?? '';

        if (firstName != currentFirst || lastName != currentLast) {
          final nameSuccess = await _repository.updateName(firstName, lastName);
          if (!nameSuccess) {
            state = state.copyWith(
              isSaving: false,
              error: 'Failed to update name',
            );
            return false;
          }
        }
      }

      // 2. Update Profile Fields (and optional photo)
      final profileSuccess = await _repository.updateProfile(
        updatedProfile,
        photoFile: photoFile,
      );

      if (!profileSuccess) {
        state = state.copyWith(
          isSaving: false,
          error: 'Failed to update profile details',
        );
        return false;
      }

      // 3. Refresh related profile providers
      try {
        await ref.read(personalInfoProvider.notifier).refresh();
      } catch (_) {}

      try {
        await ref.read(sponsorProfileProvider.notifier).refresh();
      } catch (_) {}

      // Re-fetch to get latest server values
      await _loadProfile();

      state = state.copyWith(isSaving: false, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

final sponsorEditProfileProvider = NotifierProvider.autoDispose<
    SponsorEditProfileNotifier, SponsorEditProfileState>(
  SponsorEditProfileNotifier.new,
);
