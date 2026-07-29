class GlobalKeys {
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String uuidKey = 'uuid';
  static const String userRoleKey = 'user_role';
  static const String isRoleSelectedKey = 'is_role_selected';
  static const String isApiConnectedKey = 'is_api_connected';
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';

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
