import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get baseUrl {
    if (dotenv.isInitialized) {
      try {
        final url = dotenv.env['BASE_URL'];
        if (url != null && url.isNotEmpty) return url;
      } catch (_) {}
    }
    return "https://clubby-andy-irksomely.ngrok-free.dev";
  }
  static const String register = "/api/v1/auth/register/";
  static const String verifyOtp = "/api/v1/auth/verify-otp/";
  static const String resendOtp = "/api/v1/auth/resend-otp/";
  static const String refreshToken = "/api/v1/auth/token/refresh/";
  static const String login = "/api/v1/auth/login/";
  static const String logout = "/api/v1/auth/logout/";
  static const String googleLogin = "/api/v1/auth/google/";
  static const String appleLogin = "/api/v1/auth/apple/";
  static const String forgotPassword = "/api/v1/auth/forgot-password/";
  static const String resetPassword = "/api/v1/auth/reset-password/";
  static const String changePassword = "/api/v1/users/change-password/";

  // Onboarding & Profiles
  static const String setRole = "/api/v1/profiles/set-role/";
  static const String switchRole = "/api/v1/users/switch-role/";
  static String onboarding(String role) =>
      "/api/v1/profiles/${role.toLowerCase()}/onboarding/";
  static const String verificationDocuments =
      "/api/v1/profiles/verification-documents/";
  static const String industries = "/api/v1/profiles/industries/";
  static const String verificationStatus =
      "/api/v1/profiles/verification-status/";

  // Profile GET/PATCH
  static String profileByRole(String role) =>
      "/api/v1/profiles/${role.toLowerCase()}/";

  // User & Projects
  static const String currentUser = "/api/v1/users/me/";
  static const String deleteAccount = "/api/v1/users/delete-account/";
  static const String sponsorNda = "/api/v1/profiles/sponsor/nda/";
  static const String sponsorProjects = "/api/v1/projects/sponsor/";
  static const String savedProjects = "/api/v1/projects/saved/";
  static const String savedProfiles = "/api/v1/profiles/saved/";
  static String saveProfile(String userId) => "/api/v1/profiles/$userId/save/";
  static String userPublicProfile(String userId) => "/api/v1/profiles/$userId/";
  static const String sponsorCollaborationRequests =
      "/api/v1/projects/sponsor/requests/";
  static String sponsorProjectRequests(String id) =>
      "/api/v1/projects/sponsor/$id/requests/";
  static String approveCollaborationRequest(String id) =>
      "/api/v1/projects/sponsor/requests/$id/approve/";
  static String rejectCollaborationRequest(String id) =>
      "/api/v1/projects/sponsor/requests/$id/reject/";
  static String fundReceivedCollaborationRequest(String id) =>
      "/api/v1/projects/sponsor/requests/$id/fund-received/";
  static const String banners = "/api/v1/banners/";
  static const String projects = "/api/v1/projects/";
  static const String discoverProjects = "/api/v1/projects/discover/";
  static const String investorInvestments = "/api/v1/investor/investments/";
  static const String investorPortfolioSummary =
      "/api/v1/investor/portfolio-summary/";
  static const String investorDashboard = "/api/v1/investor/dashboard/";
  static const String investorMyRequests =
      "/api/v1/projects/investor/my-requests/";
  static String projectDetails(String id) => "/api/v1/projects/$id/";
  static String sponsorProject(String id) => "/api/v1/projects/sponsor/$id/";
  static String saveProject(String id) => "/api/v1/projects/$id/save/";
  static String signNda(String id) => "/api/v1/projects/$id/sign-nda/";
  static String createCollaborationRequest(String id) =>
      "/api/v1/projects/$id/requests/";
  static String confirmInvestors(String projectId) =>
      "/api/v1/projects/$projectId/confirm-investors/";
  static String terminateProject(String id) => "/api/v1/projects/$id/terminate/";

  // AI Project Creation (Damini Advisor)
  static const String aiProjectConversations =
      "/api/v1/ai/projects/conversations/";
  static String aiProjectMessages(String conversationId) =>
      "/api/v1/ai/projects/conversations/$conversationId/messages/";
  static String aiProjectConversation(String conversationId) =>
      "/api/v1/ai/projects/conversations/$conversationId/";

  // AI Investment Copilot Chat
  static const String aiChatInitial = "/api/v1/ai/chat/initial/";
  static String aiChatMessages(String conversationId) =>
      "/api/v1/ai/chat/conversations/$conversationId/messages/";
  static String aiChatClear(String conversationId) =>
      "/api/v1/ai/chat/conversations/$conversationId/clear/";

  // Chat & Notifications
  static const String startConversation =
      "/api/v1/notifications/chat/conversations/start/";
  static const String conversations =
      "/api/v1/notifications/chat/conversations/";
  static String conversationMessages(String conversationId) =>
      "/api/v1/notifications/chat/conversations/$conversationId/messages/";
  static String sendChatMessage(String conversationId) =>
      "/api/v1/chat/conversations/$conversationId/messages/send/";
  static const String chatUpload =
      "/api/v1/notifications/chat/upload/";
  static String markConversationRead(String conversationId) =>
      "/api/v1/notifications/chat/conversations/$conversationId/read/";
  static String removeParticipant(String conversationId, String userId) =>
      "/api/v1/notifications/chat/conversations/$conversationId/participants/$userId/";
  static String conversationHeader(String conversationId) =>
      "/api/v1/notifications/chat/conversations/$conversationId/header/";
  static String conversationConfirmInvestors(String conversationId) =>
      "/api/v1/notifications/chat/conversations/$conversationId/confirm-investors/";
  static String leaveConversation(String conversationId) =>
      "/api/v1/notifications/chat/conversations/$conversationId/leave/";
  static String reportConversation(String conversationId) =>
      "/api/v1/notifications/chat/conversations/$conversationId/report/";

  static String chatWebSocket(String conversationId, String token) {
    final wsBase = baseUrl
        .replaceFirst(RegExp(r'^http://'), 'ws://')
        .replaceFirst(RegExp(r'^https://'), 'wss://');
    return "$wsBase/ws/chat/$conversationId/?token=$token";
  }
  static const String getNotifications = "/api/v1/notifications/";
  static String markRead(String id) => "/api/v1/notifications/$id/read/";
  static const String markAllRead = "/api/v1/notifications/mark-all-read/";
  static const String deviceToken = "/api/v1/notifications/device-token/";
  static String deleteNotification(String id) => "/api/v1/notifications/$id/";
  static const String clearAllNotifications = "/api/v1/notifications/clear-all/";
}
