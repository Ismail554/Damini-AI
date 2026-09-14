class SessionState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userRole;
  final bool isApiConnected;

  const SessionState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userRole,
    this.isApiConnected = true,
  });

  SessionState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userRole,
    bool? isApiConnected,
    bool clearRole = false,
  }) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userRole: clearRole ? null : (userRole ?? this.userRole),
      isApiConnected: isApiConnected ?? this.isApiConnected,
    );
  }
}
