import 'package:flutter_riverpod/flutter_riverpod.dart';
export '../models/settings_model.dart';
import '../repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

class SettingsState {
  final bool notificationsEnabled;

  const SettingsState({this.notificationsEnabled = true});

  SettingsState copyWith({bool? notificationsEnabled}) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final settingsProvider =
    NotifierProvider.autoDispose<SettingsNotifier, SettingsState>(
        SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }
}
