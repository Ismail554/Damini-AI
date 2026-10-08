import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class TrendingOpportunityCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String raisedAmount;
  final String raisedLabel;
  final String goalAmount;
  final String goalLabel;
  final double progress;
  final VoidCallback? onTap;

  const TrendingOpportunityCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.raisedAmount,
    this.raisedLabel = "Min Investment",
    required this.goalAmount,
    this.goalLabel = "Location",
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: tc.cardBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: tc.borderColor, width: AppDimens.borderThin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(19.r),
                  topRight: Radius.circular(19.r),
                ),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 160.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12.h,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: tc.pillBg,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: Text(
                    "Ongoing",
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: tc.pillBg,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: tc.textPrimary,
                    size: AppDimens.iconMd,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(AppDimens.paddingLg - 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                raisedLabel,
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
                                  color: AppColors.accentRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                goalLabel,
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
                          backgroundColor: tc.progressBg,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            tc.progressFill,
                          ),
                        ),
                      ),
                    ],
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
}
