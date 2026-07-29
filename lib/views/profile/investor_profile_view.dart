import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_provider.dart';
import '../../core/widgets/logout_dialog.dart';
import 'widgets/account_type_switcher_card.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_menu_card.dart';

class InvestorProfileView extends StatelessWidget {
  const InvestorProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentRole = auth.userRole ?? 'investor';
    final tc = AppThemeColors.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
          const ProfileHeroCard(
            name: "John Doe",
            title: "CEO at Acme Corp",
            avatarUrl:
                "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop",
            investedAmount: "\$450K",
            projectsCount: "3",
          ),
          SizedBox(height: 18.h),

          // Account Type Switcher Card
          AccountTypeSwitcherCard(
            activeRole: currentRole,
            onSwitchRole: (newRole) async {
              await context.read<AuthProvider>().setRole(newRole);
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
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
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
    );
  }
}
