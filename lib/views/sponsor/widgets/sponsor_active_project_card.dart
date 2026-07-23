import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';

class SponsorActiveProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final String badgeText;
  final String raisedAmount;
  final String goalAmount;
  final double progress;
  final VoidCallback? onTap;

  const SponsorActiveProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.raisedAmount,
    required this.goalAmount,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return GestureDetector(
      onTap: onTap ?? () => context.push('/sponsor-project-details'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: tc.cardBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(
                color: tc.borderColor,
                width: AppDimens.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: tc.shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: tc.pillBg,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: tc.pillText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: tc.cardHeader,
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: tc.textPrimary,
                        size: AppDimens.iconMd,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimens.spaceMd),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                SizedBox(height: AppDimens.spaceSm),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: tc.textSecondary,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: AppDimens.spaceLg),
                Container(
                  padding: EdgeInsets.all(AppDimens.paddingMd),
                  decoration: BoxDecoration(
                    color: tc.cardInner,
                    borderRadius: BorderRadius.circular(AppDimens.paddingMd),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Raised",
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  color: tc.textTertiary,
                                ),
                              ),
                              SizedBox(height: AppDimens.spaceXxs),
                              Text(
                                raisedAmount,
                                style: GoogleFonts.outfit(
                                  fontSize: 14.sp,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Goal",
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  color: tc.textTertiary,
                                ),
                              ),
                              SizedBox(height: AppDimens.spaceXxs),
                              Text(
                                goalAmount,
                                style: GoogleFonts.outfit(
                                  fontSize: 14.sp,
                                  color: tc.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6.h,
                          backgroundColor: tc.shadowColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.thirdColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
