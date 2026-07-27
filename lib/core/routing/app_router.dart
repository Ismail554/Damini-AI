import 'package:go_router/go_router.dart';
import '../../views/splash/splash_view.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/signup_view.dart';
import '../../views/auth/forgot_password_view.dart';
import '../../views/auth/otp_verification_view.dart';
import '../../views/auth/reset_password_view.dart';
import '../../views/auth/success_view.dart';
import '../../views/role_selection/role_selection_view.dart';
import '../../views/role_selection/role_onboarding_view.dart';
import '../../views/home/home_view.dart';
import '../../views/sponsor/all_projects/sponsor_projects_view.dart';
import '../../views/sponsor/create_project/create_project_view.dart';
import '../../views/sponsor/project_details/sponsor_project_details_view.dart';
import '../../views/sponsor/collaboration_requests/collaboration_requests_view.dart';
import '../../views/sponsor/public_view/project_public_view.dart';
import '../../views/sponsor/nda/nda_view.dart';
import '../../views/sponsor/group_chat/group_chat_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] as String? ?? '';
          final isRecovery = extra['isRecovery'] as bool? ?? false;
          return OtpVerificationView(email: email, isRecovery: isRecovery);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordView(),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => const SuccessView(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionView(),
      ),
      GoRoute(
        path: '/role-onboarding',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final role = extra['role'] as String? ?? 'investor';
          return RoleOnboardingView(role: role);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/create-project',
        builder: (context, state) => const CreateProjectView(),
      ),
      GoRoute(
        path: '/sponsor-projects',
        builder: (context, state) => const SponsorProjectsView(),
      ),
      GoRoute(
        path: '/sponsor-project-details',
        builder: (context, state) => const SponsorProjectDetailsView(),
      ),
      GoRoute(
        path: '/collaboration-requests',
        builder: (context, state) => const CollaborationRequestsView(),
      ),
      GoRoute(
        path: '/public-view',
        builder: (context, state) => const ProjectPublicView(),
      ),
      GoRoute(
        path: '/nda',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final disclosingParty =
              extra['disclosingParty'] as String? ?? 'Acme Corp';
          return NdaView(disclosingParty: disclosingParty);
        },
      ),
      GoRoute(
        path: '/group-chat',
        builder: (context, state) => const GroupChatView(),
      ),
    ],
  );
}
