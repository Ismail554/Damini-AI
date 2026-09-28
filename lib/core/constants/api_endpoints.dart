import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? "https://clubby-andy-irksomely.ngrok-free.dev";
  static const String register = "/api/v1/auth/register/";
  static const String verifyOtp = "/api/v1/auth/verify-otp/";
  static const String resendOtp = "/api/v1/auth/resend-otp/";
  static const String refreshToken = "/api/v1/auth/token/refresh/";
  static const String login = "/api/v1/auth/login/";
  static const String logout = "/api/v1/auth/logout/";

  // Onboarding & Profiles
  static const String setRole = "/api/v1/profiles/set-role/";
  static String onboarding(String role) =>
      "/api/v1/profiles/${role.toLowerCase()}/onboarding/";
  static const String verificationDocuments =
      "/api/v1/profiles/verification-documents/";
  static const String industries = "/api/v1/profiles/industries/";
  static const String verificationStatus =
      "/api/v1/profiles/verification-status/";

  // User & Projects
  static const String currentUser = "/api/v1/users/me/";
  static const String sponsorProjects = "/api/v1/projects/sponsor/";
  static const String sponsorCollaborationRequests =
      "/api/v1/projects/sponsor/requests/";
  static String approveCollaborationRequest(String id) =>
      "/api/v1/projects/sponsor/requests/$id/approve/";
  static String rejectCollaborationRequest(String id) =>
      "/api/v1/projects/sponsor/requests/$id/reject/";
  static String fundReceivedCollaborationRequest(String id) =>
      "/api/v1/projects/sponsor/requests/$id/fund-received/";
  static const String projects = "/api/v1/projects/";
  static String projectDetails(String id) => "/api/v1/projects/$id/";
}
