import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
export '../models/settings_model.dart';
import '../repositories/settings_repository.dart';

class SettingsState {
  final bool isLoading;
  final bool notificationsEnabled;
  final UserSettingsModel? userSettings;

  const SettingsState({
    this.isLoading = false,
    this.notificationsEnabled = true,
    this.userSettings,
  });

  String get displayName => userSettings?.fullName ?? 'Member';
  String get email => userSettings?.email ?? '';
  String? get profilePhoto => userSettings?.profilePhoto;
  String get subscriptionTier => userSettings?.subscriptionTier ?? 'FREE';
  String get verificationStatus => userSettings?.verificationStatus ?? 'PENDING';
  String get role => userSettings?.role ?? '';

  SettingsState copyWith({
    bool? isLoading,
    bool? notificationsEnabled,
    UserSettingsModel? userSettings,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      userSettings: userSettings ?? this.userSettings,
    );
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(
        SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  late final SettingsRepository _repository;

  @override
  SettingsState build() {
    _repository = ref.watch(settingsRepositoryProvider);
    _loadUserSettings();
    return const SettingsState(isLoading: true);
  }

  Future<void> _loadUserSettings() async {
    try {
      final user = await _repository.getUserSettings();
      state = state.copyWith(
        isLoading: false,
        userSettings: user,
        notificationsEnabled: user.pushNotificationsEnabled,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await _loadUserSettings();
  }

  Future<void> toggleNotifications(bool value) async {
    // Optimistic UI update
    state = state.copyWith(notificationsEnabled: value);
    final success = await _repository.updateNotificationPreference(value);
    if (!success) {
      // Revert if failed
      state = state.copyWith(notificationsEnabled: !value);
    }
  }

  Future<bool> deleteAccount([String? password]) async {
    return await _repository.deleteAccount(password);
  }
}
