class GlobalKeys {
  // Storage Keys
  static const String access = 'access';
  static const String refresh = 'refresh';
  static const String uuid = 'uuid';
  static const String userEmail = 'user_email';
  static const String userName = 'user_full_name';
  static const String userRole = 'user_role';
  static const String isRoleSelected = 'is_role_selected';
  static const String isApiConnected = 'is_api_connected';
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';

  // Push Notification Keys
  static const String deviceToken = 'device_token';
  static const String deviceName = 'device_name';
  static const String registeredDeviceToken = 'registered_device_token';

  // Role Constants
  static const String investorRole = 'investor';
  static const String sponsorRole = 'sponsor';

  // Demo Accounts
  static const String demoInvestorEmail = 'investor@gmail.com';
  static const String demoSponsorEmail = 'sponsor@gmail.com';

  // Validation Helpers
  static bool isValidRole(String? role) {
    return role == investorRole || role == sponsorRole;
  }

  static bool validateKeyResponse({
    required bool isApiConnected,
    String? role,
  }) {
    return isApiConnected && isValidRole(role);
  }
}
