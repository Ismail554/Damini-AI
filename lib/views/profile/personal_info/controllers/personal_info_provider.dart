import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/personal_info_model.dart';
import '../repositories/personal_info_repository.dart';

class PersonalInfoState {
  final PersonalInfoModel info;
  final bool isLoading;

  const PersonalInfoState({
    required this.info,
    this.isLoading = false,
  });

  PersonalInfoState copyWith({
    PersonalInfoModel? info,
    bool? isLoading,
  }) {
    return PersonalInfoState(
      info: info ?? this.info,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PersonalInfoNotifier extends Notifier<PersonalInfoState> {
  late final PersonalInfoRepository _repository;

  @override
  PersonalInfoState build() {
    _repository = ref.watch(personalInfoRepositoryProvider);
    _loadProfile();
    return const PersonalInfoState(
      isLoading: true,
      info: PersonalInfoModel(
        fullName: 'Loading...',
        email: '',
        phone: '',
        country: '',
        location: '',
        companyName: '',
        position: '',
        website: '',
        bio: '',
      ),
    );
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(info: profile, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await _loadProfile();
  }

  void updateInfo(PersonalInfoModel newInfo) {
    state = state.copyWith(info: newInfo);
  }

  Future<bool> saveProfile(PersonalInfoModel updated) async {
    state = state.copyWith(isLoading: true);
    final success = await _repository.updateProfile(updated);
    if (success) {
      state = state.copyWith(info: updated, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
    return success;
  }
}

final personalInfoProvider =
    NotifierProvider<PersonalInfoNotifier, PersonalInfoState>(
  PersonalInfoNotifier.new,
);
