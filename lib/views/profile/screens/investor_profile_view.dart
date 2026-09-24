import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:Braintech/views/auth/session/controllers/session_provider.dart';
import 'package:Braintech/core/widgets/logout_dialog.dart';
import '../controllers/investor_profile_provider.dart';
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

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(investorProfileProvider.notifier).refreshProfile(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: tc.textPrimary,
                  size: 22.r,
                ),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Profile Hero Card
          ProfileHeroCard(
            name: profile.name,
            title: profile.title,
            avatarUrl: profile.avatarUrl,
            investedAmount: profile.investedAmount,
            projectsCount: profile.projectsCount,
          ),
          SizedBox(height: 18.h),

          // Account Type Switcher Card
          AccountTypeSwitcherCard(
            activeRole: currentRole,
            onSwitchRole: (newRole) async {
              await ref.read(authProvider.notifier).setRole(newRole);
            },
          ),
          SizedBox(height: 18.h),

          // Profile Menu Card
          const ProfileMenuCard(),
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
  );
  }
}
