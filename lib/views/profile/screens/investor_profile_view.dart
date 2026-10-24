import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:Braintech/views/auth/session/controllers/session_provider.dart';
import 'package:Braintech/core/widgets/logout_dialog.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import 'package:Braintech/core/widgets/switch_role_dialog.dart';
import '../../home/controllers/home_provider.dart';
import '../controllers/investor_profile_provider.dart';
import '../personal_info/controllers/personal_info_provider.dart';
import '../widgets/account_type_switcher_card.dart';
import '../widgets/profile_hero_card.dart';
import '../widgets/profile_menu_card.dart';

class InvestorProfileView extends ConsumerWidget {
  const InvestorProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final currentRole = auth.userRole ?? 'investor';
    final tc = AppThemeColors.of(context);
    final profile = ref.watch(investorProfileProvider).profile;
    final personalInfo = ref.watch(personalInfoProvider).info;

    final topInset = MediaQuery.of(context).padding.top;
    final headerBgHeight = topInset > 0 ? (topInset + 130.h) : 175.h;

    return Stack(
      children: [
        // Top Background Gradient Container (matching previous UI implementation & theme)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerBgHeight,
          child: Container(
            decoration: BoxDecoration(
              gradient: tc.isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0B3A82),
                        Color(0xFF052152),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF1F5F9),
                      ],
                    ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
              border: Border(
                bottom: BorderSide(
                  color: tc.borderColor,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: tc.shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
        ),

        // Scrollable Profile Content
        RefreshIndicator(
          onRefresh: () =>
              ref.read(investorProfileProvider.notifier).refreshProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              20.w,
              topInset + 12.h,
              20.w,
              16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Header Row: Profile Title & Settings Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Profile",
                  style: GoogleFonts.outfit(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: Center(
                      child: Icon(
                        Icons.settings_outlined,
                        color: tc.textPrimary,
                        size: 24.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

          // Profile Hero Card
          ProfileHeroCard(
            name: profile.name != 'Member'
                ? profile.name
                : (personalInfo.fullName.isNotEmpty
                    ? personalInfo.fullName
                    : 'Member'),
            title: profile.title.isNotEmpty && profile.title != 'Member'
                ? profile.title
                : (personalInfo.position.isNotEmpty
                    ? personalInfo.position
                    : 'Angel Investor'),
            avatarUrl: profile.avatarUrl.isNotEmpty
                ? profile.avatarUrl
                : personalInfo.profilePhotoUrl,
            investedAmount: profile.investedAmount,
            projectsCount: profile.projectsCount,
            role: currentRole,
            verificationStatus:
                personalInfo.verificationStatus ?? profile.verificationStatus,
            isCompany: personalInfo.isCompany,
            location: personalInfo.location.isNotEmpty
                ? (personalInfo.country.isNotEmpty
                    ? '${personalInfo.location}, ${personalInfo.country}'
                    : personalInfo.location)
                : personalInfo.country,
            companyName: personalInfo.companyName,
            bio: personalInfo.bio,
            email: personalInfo.email,
            stat1Label: "COMMITTED",
            stat2Label: "PROJECTS",
          ),
          SizedBox(height: 18.h),

          // Account Type Switcher Card
          AccountTypeSwitcherCard(
            activeRole: currentRole,
            isLoading: auth.isLoading,
            onSwitchRole: (newRole) async {
              if (newRole == currentRole) return;
              final confirm = await SwitchRoleDialog.show(context, newRole);
              if (confirm != true || !context.mounted) return;
              final result =
                  await ref.read(authProvider.notifier).switchRole(newRole);
              if (!context.mounted) return;
              if (result.success) {
                if (result.isOnboarded) {
                  ref.read(homeProvider.notifier).setTabIndex(0);
                  CustomSnackBar.success(
                    context,
                    'Switched to ${newRole == 'sponsor' ? 'Sponsor' : 'Investor'} mode',
                  );
                } else {
                  CustomSnackBar.info(
                    context,
                    'Please complete ${newRole == 'sponsor' ? 'Sponsor' : 'Investor'} onboarding.',
                  );
                  context.push('/role-onboarding', extra: {'role': newRole});
                }
              } else if (result.isProfileMissing) {
                CustomSnackBar.info(
                  context,
                  result.message ??
                      'Please complete ${newRole == 'sponsor' ? 'Sponsor' : 'Investor'} onboarding.',
                );
                context.push('/role-onboarding', extra: {'role': newRole});
              } else {
                CustomSnackBar.error(
                  context,
                  result.message ?? 'Failed to switch role',
                );
              }
            },
          ),
          SizedBox(height: 18.h),

          // Profile Menu Card
          ProfileMenuCard(isCompany: personalInfo.isCompany),
          SizedBox(height: 24.h),

          // Log Out Button
          GestureDetector(
            onTap: () async {
              final confirm = await LogoutDialog.show(context);
              if (confirm != true) return;
              if (!context.mounted) return;
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                color: tc.logoutBg,
                borderRadius: BorderRadius.circular(26.r),
                border: Border.all(
                  color: tc.logoutText.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: tc.logoutText, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    "Log Out",
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.logoutText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 90.h),
        ],
      ),
    ),
  ),
  ],
);
  }
}
