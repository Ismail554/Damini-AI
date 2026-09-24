import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:Braintech/views/auth/session/controllers/session_provider.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/logout_dialog.dart';
import '../../../profile/widgets/account_type_switcher_card.dart';
import '../../../profile/widgets/profile_hero_card.dart';
import '../../../profile/widgets/profile_menu_card.dart';
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.screenVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sponsor Profile",
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
                  size: AppDimens.iconLg,
                ),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceLg),

          ProfileHeroCard(
            name: profile?.name ,
            title: profile?.title ?? "Managing Director at Austin Tech Capital",
            avatarUrl: profile?.avatarUrl ??
                "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop",
            investedAmount: profile?.investedAmount ?? "\$1.2M",
            projectsCount: profile?.projectsCount ?? "2",
          ),
          SizedBox(height: AppDimens.spaceLg),

          AccountTypeSwitcherCard(
            activeRole: currentRole,
            onSwitchRole: (newRole) async {
              await ref.read(authProvider.notifier).setRole(newRole);
            },
          ),
          SizedBox(height: AppDimens.spaceLg),

          const ProfileMenuCard(),
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
    );
  }
}
