import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/sponsor_project_details_model.dart';

class SponsorProjectStatsCard extends StatelessWidget {
  final SponsorProjectDetailsModel project;

  const SponsorProjectStatsCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppDimens.paddingLg),
          decoration: BoxDecoration(
            color: tc.cardBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
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
              // Raised so far header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Capital Committed",
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "of ${project.goalAmount}\n",
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: tc.textTertiary,
                          ),
                        ),
                        TextSpan(
                          text: project.percentage,
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Raised Big Text
              Text(
                project.raisedAmount,
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              SizedBox(height: AppDimens.spaceMd),

              // Progress Indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: project.progress,
                  minHeight: 6.h,
                  backgroundColor: tc.shadowColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: AppDimens.spaceXl),

              // 3 Stat Boxes Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      tc: tc,
                      icon: Icons.adjust_rounded,
                      value: project.remainingAmount,
                      label: "Remaining",
                    ),
                  ),
                  SizedBox(width: AppDimens.spaceSm),
                  Expanded(
                    child: _buildStatBox(
                      tc: tc,
                      icon: Icons.groups_outlined,
                      value: "${project.investorsCount}",
                      label: "Investors",
                    ),
                  ),
                  SizedBox(width: AppDimens.spaceSm),
                  Expanded(
                    child: _buildStatBox(
                      tc: tc,
                      icon: Icons.trending_up_rounded,
                      value: project.targetRoi,
                      label: "Target ROI",
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimens.spaceMd),

              // Pending Review Banner
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingMd,
                  vertical: AppDimens.paddingSm + 2,
                ),
                decoration: BoxDecoration(
                  color: tc.logoutBg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                    color: tc.logoutText.withValues(alpha: 0.3),
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: AppColors.accentOrange,
                          size: AppDimens.iconSm,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Pending review",
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      project.pendingReviewAmount,
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required AppThemeColors tc,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: tc.cardInner,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: tc.borderColor, width: AppDimens.borderThin),
      ),
      child: Column(
        children: [
          Icon(icon, color: tc.textPrimary, size: AppDimens.iconMd),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 10.sp, color: tc.textTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
