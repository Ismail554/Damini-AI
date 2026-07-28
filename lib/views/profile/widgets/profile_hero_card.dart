import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';

class ProfileHeroCard extends StatelessWidget {
  final String name;
  final String title;
  final String avatarUrl;
  final String investedAmount;
  final String projectsCount;

  const ProfileHeroCard({
    super.key,
    required this.name,
    required this.title,
    required this.avatarUrl,
    required this.investedAmount,
    required this.projectsCount,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.paddingLg),
      decoration: BoxDecoration(
        color: tc.cardHero,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: tc.borderColor, width: AppDimens.borderThin),
      ),
      child: Column(
        children: [
          // Avatar & Info (Tap opens Personal Info)
          GestureDetector(
            onTap: () => context.push('/personal-info'),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: tc.textPrimary,
                          width: AppDimens.borderMedium,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 40.r,
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                    ),
                    Positioned(
                      right: 2.w,
                      bottom: 2.h,
                      child: Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: const BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12.r,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimens.spaceMd),
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                SizedBox(height: AppDimens.spaceXxs),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: tc.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimens.spaceMd),

          // Pill Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: tc.pillBg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Text(
                  "Sponsor",
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    color: tc.pillText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => context.push('/company-verification'),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: tc.greenPillBg,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: tc.greenPillText,
                        size: 12.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "Verified",
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          color: tc.greenPillText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Free Member Pill
          GestureDetector(
            onTap: () => context.push('/subscription'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: tc.textPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: tc.textSecondary,
                    size: 14.r,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    "Free Member",
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      color: tc.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppDimens.spaceXl),

          // Stats Boxes Row
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  tc: tc,
                  value: investedAmount,
                  label: "INVESTED",
                ),
              ),
              SizedBox(width: AppDimens.spaceMd),
              Expanded(
                child: _buildStatBox(
                  tc: tc,
                  value: projectsCount,
                  label: "PROJECTS",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required AppThemeColors tc,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: tc.cardInner,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: tc.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: AppDimens.spaceXxs),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: tc.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
