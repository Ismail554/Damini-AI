import '../models/settings_model.dart';

abstract class SettingsRepository {
  Future<SettingsModel> getSettings();
  Future<bool> saveSettings(SettingsModel settings);
}

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<SettingsModel> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const SettingsModel();
  }

  @override
  Future<bool> saveSettings(SettingsModel settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
