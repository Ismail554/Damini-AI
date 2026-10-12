import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:Braintech/views/auth/session/controllers/session_provider.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/logout_dialog.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import 'package:Braintech/core/widgets/switch_role_dialog.dart';
import '../../../home/controllers/home_provider.dart';
import '../../../profile/widgets/account_type_switcher_card.dart';
import '../../../profile/widgets/profile_hero_card.dart';
import '../../../profile/widgets/profile_menu_card.dart';
import '../../../profile/personal_info/controllers/personal_info_provider.dart';
import '../controllers/sponsor_profile_provider.dart';

class SponsorProfileView extends ConsumerWidget {
  const SponsorProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final auth = ref.watch(authProvider);
    final currentRole = auth.userRole ?? 'sponsor';
    final profileState = ref.watch(sponsorProfileProvider);
    final profile = profileState.profile;
    final personal = ref.watch(personalInfoProvider).info;

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
          onRefresh: () => ref.read(sponsorProfileProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              AppDimens.screenHorizontal,
              topInset + 12.h,
              AppDimens.screenHorizontal,
              AppDimens.screenVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    width: 24.w,
                    height: 24.h,
                    child: Center(
                      child: Icon(
                        Icons.settings_outlined,
                        color: tc.textPrimary,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

          ProfileHeroCard(
            name: (profile?.name != null &&
                    profile!.name.isNotEmpty &&
                    profile.name != 'Member')
                ? profile.name
                : (personal.fullName.isNotEmpty ? personal.fullName : 'Member'),
            title: (profile?.title != null && profile!.title.isNotEmpty)
                ? profile.title
                : (personal.position.isNotEmpty
                    ? personal.position
                    : (personal.companyName.isNotEmpty
                        ? personal.companyName
                        : 'Sponsor Partner')),
            avatarUrl:
                (profile?.avatarUrl != null && profile!.avatarUrl.isNotEmpty)
                    ? profile.avatarUrl
                    : personal.profilePhotoUrl,
            investedAmount: profile?.investedAmount ?? "\$0.00",
            projectsCount: profile?.projectsCount ?? "0",
            role: currentRole,
            verificationStatus:
                personal.verificationStatus ?? profile?.verificationStatus,
            isCompany: personal.isCompany,
            location: personal.location.isNotEmpty
                ? (personal.country.isNotEmpty
                    ? '${personal.location}, ${personal.country}'
                    : personal.location)
                : personal.country,
            companyName: personal.companyName,
            bio: personal.bio,
            email: personal.email,
            stat1Label: "TOTAL RAISED",
            stat2Label: "PROJECTS",
          ),
          SizedBox(height: AppDimens.spaceLg),

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
          SizedBox(height: AppDimens.spaceLg),

          ProfileMenuCard(isCompany: personal.isCompany),
          SizedBox(height: AppDimens.spaceXl),

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
              height: AppDimens.buttonLg,
              decoration: BoxDecoration(
                color: tc.logoutBg,
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                border: Border.all(
                  color: tc.logoutText.withValues(alpha: 0.3),
                  width: AppDimens.borderThin,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: tc.logoutText,
                    size: AppDimens.iconMd,
                  ),
                  SizedBox(width: AppDimens.spaceSm),
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
