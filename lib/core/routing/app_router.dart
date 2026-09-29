import 'package:go_router/go_router.dart';
import '../../views/splash/splash_view.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/auth/login/screens/login_view.dart';
import '../../views/auth/signup/screens/signup_view.dart';
import '../../views/auth/forgot_password/screens/forgot_password_view.dart';
import '../../views/auth/otp/screens/otp_verification_view.dart';
import '../../views/auth/reset_password/screens/reset_password_view.dart';
import '../../views/auth/success/screens/success_view.dart';
import '../../views/role_selection/role_selection_view.dart';
import '../../views/role_selection/role_onboarding_view.dart';
import '../../views/home/screens/home_view.dart';
import '../../views/sponsor/all_projects/screens/sponsor_projects_view.dart';
import '../../views/sponsor/create_project/screens/create_project_view.dart';
import '../../views/sponsor/create_project/screens/project_creation_ai_chat_view.dart';
import '../../views/sponsor/project_details/screens/sponsor_project_details_view.dart';
import '../../views/sponsor/collaboration_requests/screens/collaboration_requests_view.dart';
import '../../views/sponsor/public_view/screens/project_public_view.dart';
import '../../views/sponsor/public_view/models/project_public_view_model.dart';
import '../../views/sponsor/nda/screens/nda_view.dart';
import '../../views/sponsor/group_chat/screens/group_chat_view.dart';
import '../../views/sponsor/chat/screens/direct_chat_view.dart';
import '../../views/sponsor/chat/models/chat_item_model.dart';
import '../../views/sponsor/project_details/screens/all_contributors_view.dart';
import '../../views/sponsor/project_details/models/sponsor_project_details_model.dart';
import '../../views/sponsor/create_project/models/project_draft_model.dart';
import '../../shared/screens/notifications/notifications_screen.dart';
import '../../views/settings/screens/settings_view.dart';
import '../../views/auth/change_password/screens/change_password_view.dart';
import '../../views/profile/personal_info/screens/personal_info_view.dart';
import '../../views/profile/personal_info/screens/edit_profile_view.dart';
import '../../views/profile/company_verification/screens/company_verification_view.dart';
import '../../views/sponsor/nda/screens/edit_nda_view.dart';
import '../../views/subscription/subscription_view.dart';
import '../../views/profile/public_profile/screens/public_profile_view.dart';
import '../../views/ai_chat/ai_chat_view.dart';
import '../../views/investor/discover/screens/discover_screen.dart';
import '../../views/investor/investment_history/screens/investment_history_screen.dart';
import '../../views/investor/request_collaboration/screens/request_collaboration_screen.dart';
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
          final extra = state.extra is Map ? (state.extra as Map) : const {};
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
          final extra = state.extra is Map ? (state.extra as Map) : const {};
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
          final draft = state.extra is ProjectDraftModel
              ? state.extra as ProjectDraftModel
              : (state.extra is Map
                  ? (state.extra as Map)['draft'] as ProjectDraftModel?
                  : null);

          return buildNativePage(
            context: context,
            state: state,
            child: CreateProjectView(
              initialDraft: draft,
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
          String? projectId;
          SponsorProjectDetailsModel? project;
          if (state.extra is SponsorProjectDetailsModel) {
            project = state.extra as SponsorProjectDetailsModel;
            projectId = project.id;
          } else if (state.extra is String) {
            projectId = state.extra as String;
          } else if (state.extra is int) {
            projectId = (state.extra as int).toString();
          } else if (state.extra is Map) {
            final map = state.extra as Map;
            if (map['project'] is SponsorProjectDetailsModel) {
              project = map['project'] as SponsorProjectDetailsModel;
              projectId = project.id;
            } else if (map['id'] != null) {
              projectId = map['id'].toString();
            }
          }
          return buildNativePage(
            context: context,
            state: state,
            child: SponsorProjectDetailsView(
              projectId: projectId,
              initialProject: project,
            ),
          );
        },
      ),
      GoRoute(
        path: '/collaboration-requests',
        pageBuilder: (context, state) {
          String? projectId;
          String? projectTitle;
          String? heroTag;
          if (state.extra is Map) {
            final map = state.extra as Map;
            projectId = map['projectId']?.toString();
            projectTitle = map['projectTitle']?.toString();
            heroTag = map['heroTag']?.toString();
          } else if (state.extra is String) {
            projectId = state.extra as String;
          } else if (state.uri.queryParameters.containsKey('projectId')) {
            projectId = state.uri.queryParameters['projectId'];
            projectTitle = state.uri.queryParameters['projectTitle'];
            heroTag = state.uri.queryParameters['heroTag'];
          }
          return buildNativePage(
            context: context,
            state: state,
            child: CollaborationRequestsView(
              projectId: projectId,
              projectTitle: projectTitle,
              heroTag: heroTag ?? 'collaboration_requests_hero',
            ),
          );
        },
      ),
      GoRoute(
        path: '/public-view',
        pageBuilder: (context, state) {
          ProjectPublicViewModel? project;
          String? projectId;
          if (state.extra is ProjectPublicViewModel) {
            project = state.extra as ProjectPublicViewModel;
            projectId = project.id;
          } else if (state.extra is SponsorProjectDetailsModel) {
            final details = state.extra as SponsorProjectDetailsModel;
            project = details.toPublicViewModel();
            projectId = details.id;
          } else if (state.extra is ProjectDraftModel) {
            project = ProjectPublicViewModel.fromDraft(
              state.extra as ProjectDraftModel,
            );
            projectId = project.id;
          } else if (state.extra is String) {
            projectId = state.extra as String;
          } else if (state.extra is int) {
            projectId = (state.extra as int).toString();
          } else if (state.extra is Map) {
            final extraMap = state.extra as Map;
            if (extraMap['project'] is ProjectPublicViewModel) {
              project = extraMap['project'] as ProjectPublicViewModel;
            } else if (extraMap['project'] is SponsorProjectDetailsModel) {
              project = (extraMap['project'] as SponsorProjectDetailsModel)
                  .toPublicViewModel();
            } else if (extraMap['project'] is ProjectDraftModel) {
              project = ProjectPublicViewModel.fromDraft(
                extraMap['project'] as ProjectDraftModel,
              );
            }
            if (extraMap['id'] != null) {
              projectId = extraMap['id'].toString();
            }
          }
          return buildNativePage(
            context: context,
            state: state,
            child: ProjectPublicView(
              projectId: projectId,
              project: project,
            ),
          );
        },
      ),
      GoRoute(
        path: '/public-profile',
        pageBuilder: (context, state) {
          final extra = state.extra is Map ? (state.extra as Map) : null;
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
              email: extra?['email'] as String?,
              location: extra?['location'] as String?,
              website: extra?['website'] as String?,
              bio: extra?['bio'] as String?,
              role: extra?['role'] as String?,
              isVerified: extra?['isVerified'] as bool?,
              isOwnProfile: (extra?['isOwnProfile'] as bool?) ?? false,
              heroTag: extra?['heroTag'] as String?,
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
        path: '/project-creation-ai-chat',
        pageBuilder: (context, state) => buildNativePage(
          context: context,
          state: state,
          child: const ProjectCreationAiChatView(),
        ),
      ),
      GoRoute(
        path: '/nda',
        pageBuilder: (context, state) {
          final extra = state.extra is Map ? (state.extra as Map) : const {};
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
          String? title;
          int? conversationId;
          int? projectId;
          if (state.extra is String) {
            title = state.extra as String;
          } else if (state.extra is Map) {
            final map = state.extra as Map;
            title = map['title'] as String?;
            conversationId = map['conversationId'] is int
                ? map['conversationId'] as int
                : int.tryParse(map['conversationId']?.toString() ?? '');
            projectId = map['projectId'] is int
                ? map['projectId'] as int
                : int.tryParse(map['projectId']?.toString() ?? '');
          }
          return buildNativePage(
            context: context,
            state: state,
            child: GroupChatView(
              projectTitle: title,
              conversationId: conversationId,
              projectId: projectId,
            ),
          );
        },
      ),
      GoRoute(
        path: '/direct-chat',
        pageBuilder: (context, state) {
          final item = state.extra is ChatItemModel
              ? state.extra as ChatItemModel
              : const ChatItemModel(
                  id: 'chat_default',
                  name: 'Chat',
                  initials: 'CH',
                  lastMessage: '',
                  time: '',
                );
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
