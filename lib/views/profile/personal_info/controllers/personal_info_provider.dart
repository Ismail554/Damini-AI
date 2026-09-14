import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/personal_info_model.dart';
import '../repositories/personal_info_repository.dart';

final personalInfoRepositoryProvider = Provider<PersonalInfoRepository>((ref) {
  return PersonalInfoRepositoryImpl();
});

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
  @override
  PersonalInfoState build() {
    return const PersonalInfoState(
      info: PersonalInfoModel(
        fullName: 'John Doe',
        email: 'john@apexventures.com',
        phone: '+1 (415) 555-0142',
        country: 'United States',
        location: 'San Francisco, CA',
        companyName: 'Apex Ventures Ltd.',
        position: 'CEO & Co-Founder',
        website: 'apexventures.com',
        bio: 'Venture capitalist focused on tech innovation and sustainable energy.',
        profilePhotoUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop',
      ),
    );
  }

  void updateInfo(PersonalInfoModel newInfo) {
    state = state.copyWith(info: newInfo);
  }

  Future<bool> saveProfile(PersonalInfoModel updated) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(info: updated, isLoading: false);
    return true;
  }
}

final personalInfoProvider =
    NotifierProvider.autoDispose<PersonalInfoNotifier, PersonalInfoState>(
  PersonalInfoNotifier.new,
);
