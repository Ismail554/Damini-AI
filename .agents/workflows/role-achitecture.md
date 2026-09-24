---
description: Workflow 3 — Role-Based Architecture (Investor / Sponsor)
---

Goal: the two roles share infrastructure but never share feature code by accident. A bug fix in Sponsor's project list should never risk breaking Investor's portfolio view because they happened to reuse the same widget with a role flag threaded through it.

3.1 Folder split
lib/
  core/                    # shared managers, network, routing, services
  features/
    auth/                  # login/register, role resolved from token
    investor/
      dashboard/
      portfolio/
      browse_projects/
    sponsor/
      dashboard/
      my_projects/
      create_project/
    shared/                # ONLY things genuinely identical: profile, settings, notifications

If a screen looks 80% identical between roles, that's still two screens composed from shared widgets in core/widgets/ — not one screen with if (role == Role.sponsor) branches. The 20% difference is usually exactly where a role-specific bug hides.

3.2 Role resolution

Resolve the role once, at login, from the token/response — never re-derive it from local state that could drift:

dart
enum UserRole { investor, sponsor }

extension UserRoleParsing on String {
  UserRole toUserRole() => switch (this.toLowerCase()) {
        'investor' => UserRole.investor,
        'sponsor' => UserRole.sponsor,
        _ => throw ParsingException('Unknown role: $this'),
      };
}

Store it in the auth/session provider, not in SharedPreferences read ad-hoc from feature code — every role check should go through one source: context.read<SessionProvider>().role.

3.3 Route guarding
dart
GoRoute(
  path: '/sponsor/dashboard',
  redirect: (context, state) {
    final role = context.read<SessionProvider>().role;
    if (role != UserRole.sponsor) return '/investor/dashboard';
    return null;
  },
  builder: (context, state) => const SponsorDashboardScreen(),
),

Apply the same redirect at the shell/router level (a top-level redirect in GoRouter) so a deep link or a stale bookmark can't land an Investor session on a Sponsor-only screen.

3.4 API-level role separation

If the backend already scopes endpoints by role (like /api/v1/projects/sponsor/ vs /api/v1/projects/investor/), mirror that in the repository layer — one repository method per role-scoped endpoint, not one method with a role parameter that branches internally:

dart
// Good — explicit, testable independently
Future<Result<List<Project>>> getSponsorProjects();
Future<Result<List<Project>>> getInvestorOpportunities();

// Avoid — hides which contract each role actually depends on
Future<Result<List<Project>>> getProjects(UserRole role);