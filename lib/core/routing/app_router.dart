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
import '../../views/sponsor/public_view/models/project_public_view_model.dart';
import '../../views/sponsor/nda/nda_view.dart';
import '../../views/sponsor/group_chat/group_chat_view.dart';
import '../../views/sponsor/chat/direct_chat_view.dart';
import '../../views/sponsor/chat/models/chat_item_model.dart';
import '../../views/sponsor/project_details/all_contributors_view.dart';
import '../../views/sponsor/project_details/models/sponsor_project_details_model.dart';
import '../../views/sponsor/create_project/models/project_draft_model.dart';
import '../../shared/screens/notifications/notifications_screen.dart';
import '../../views/settings/settings_view.dart';
import '../../views/settings/change_password/change_password_view.dart';
import '../../views/profile/personal_info/personal_info_view.dart';
import '../../views/profile/personal_info/edit_profile_view.dart';
import '../../views/profile/company_verification/company_verification_view.dart';
import '../../views/sponsor/nda/edit_nda_view.dart';
import '../../views/subscription/subscription_view.dart';
import '../../views/profile/public_profile/public_profile_view.dart';
import '../../views/ai_chat/ai_chat_view.dart';
import '../../views/investor/discover_screen.dart';
import '../../views/investor/investment_history/investment_history_screen.dart';
import '../../views/investor/request_collaboration/request_collaboration_screen.dart';
import 'custom_page_transition.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const SplashView(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const OnboardingView(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const LoginView(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const SignUpView(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const ForgotPasswordView(),
        ),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] as String? ?? '';
          final isRecovery = extra['isRecovery'] as bool? ?? false;
          return buildNativePage(
            context: context,
            state: state,
            child: OtpVerificationView(email: email, isRecovery: isRecovery),
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const ResetPasswordView(),
        ),
      ),
      GoRoute(
        path: '/success',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const SuccessView(),
        ),
      ),
      GoRoute(
        path: '/role-selection',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const RoleSelectionView(),
        ),
      ),
      GoRoute(
        path: '/role-onboarding',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final role = extra['role'] as String? ?? 'investor';
          return buildNativePage(
            context: context,
            state: state,
            child: RoleOnboardingView(role: role),
          );
        },
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const HomeView(),
        ),
      ),
      GoRoute(
        path: '/create-project',
        pageBuilder: (context, state) {
          final extraMap = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          final draft = state.extra is ProjectDraftModel
              ? state.extra as ProjectDraftModel
              : extraMap?['draft'] as ProjectDraftModel?;
          final autoOpenAi = extraMap?['isAiMode'] == true;

          return buildNativePage(
            context: context,
            state: state,
            child: CreateProjectView(
              initialDraft: draft,
              autoOpenAiModal: autoOpenAi,
            ),
          );
        },
      ),
      GoRoute(
        path: '/sponsor-projects',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const SponsorProjectsView(),
        ),
      ),
      GoRoute(
        path: '/sponsor-project-details',
        pageBuilder: (context, state) {
          final project = state.extra is SponsorProjectDetailsModel
              ? state.extra as SponsorProjectDetailsModel
              : (state.extra as Map<String, dynamic>?)?['project']
                  as SponsorProjectDetailsModel?;
          return buildNativePage(
            context: context,
            state: state,
            child: SponsorProjectDetailsView(initialProject: project),
          );
        },
      ),
      GoRoute(
        path: '/collaboration-requests',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const CollaborationRequestsView(),
        ),
      ),
      GoRoute(
        path: '/public-view',
        pageBuilder: (context, state) {
          final project = state.extra is ProjectPublicViewModel
              ? state.extra as ProjectPublicViewModel
              : (state.extra as Map<String, dynamic>?)?['project']
                  as ProjectPublicViewModel?;
          return buildNativePage(
            context: context,
            state: state,
            child: ProjectPublicView(project: project),
          );
        },
      ),
      GoRoute(
        path: '/public-profile',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return buildNativePage(
            context: context,
            state: state,
            child: PublicProfileView(
              name: extra?['name'] as String?,
              title: extra?['title'] as String?,
              company: extra?['company'] as String?,
              avatarUrl: extra?['avatarUrl'] as String?,
              country: extra?['country'] as String?,
              phone: extra?['phone'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/ai-chat',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const AiChatView(),
        ),
      ),
      GoRoute(
        path: '/nda',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final disclosingParty =
              extra['disclosingParty'] as String? ?? 'Acme Corp';
          return buildNativePage(
            context: context,
            state: state,
            child: NdaView(disclosingParty: disclosingParty),
          );
        },
      ),
      GoRoute(
        path: '/group-chat',
        pageBuilder: (context, state) {
          final title = state.extra is String
              ? state.extra as String
              : (state.extra as Map<String, dynamic>?)?['title'] as String?;
          return buildNativePage(
            context: context,
            state: state,
            child: GroupChatView(projectTitle: title),
          );
        },
      ),
      GoRoute(
        path: '/direct-chat',
        pageBuilder: (context, state) {
          final item = state.extra as ChatItemModel;
          return buildNativePage(
            context: context,
            state: state,
            child: DirectChatView(chatItem: item),
          );
        },
      ),
      GoRoute(
        path: '/all-contributors',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const AllContributorsView(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/discover',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const DiscoverScreen(),
        ),
      ),
      GoRoute(
        path: '/request-collaboration',
        pageBuilder: (context, state) {
          final project = state.extra is ProjectPublicViewModel
              ? state.extra as ProjectPublicViewModel
              : null;
          return buildNativePage(
            context: context,
            state: state,
            child: RequestCollaborationScreen(project: project),
          );
        },
      ),
      GoRoute(
        path: '/investment-history',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const InvestmentHistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const SettingsView(),
        ),
      ),
      GoRoute(
        path: '/change-password',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const ChangePasswordView(),
        ),
      ),
      GoRoute(
        path: '/personal-info',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const PersonalInformationView(),
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const EditProfileView(),
        ),
      ),
      GoRoute(
        path: '/company-verification',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const CompanyVerificationView(),
        ),
      ),
      GoRoute(
        path: '/edit-nda',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const EditNdaView(),
        ),
      ),
      GoRoute(
        path: '/subscription',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const SubscriptionView(),
        ),
      ),
    ],
  );
}
