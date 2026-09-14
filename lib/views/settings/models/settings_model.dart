class SettingsModel {
  final bool notificationsEnabled;
  final String currentLanguage;

  const SettingsModel({
    this.notificationsEnabled = true,
    this.currentLanguage = 'English',
  });

  SettingsModel copyWith({
    bool? notificationsEnabled,
    String? currentLanguage,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }
}
