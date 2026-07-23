import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';

class FeaturedOpportunityCard extends StatelessWidget {
  final String title;
  final String location;
  final String category;
  final String imageUrl;
  final String targetRaise;
  final String targetRoi;

  const FeaturedOpportunityCard({
    super.key,
    required this.title,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.targetRaise,
    required this.targetRoi,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      width: 250.w,
      margin: EdgeInsets.only(right: AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
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
                  height: 130.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10.h,
                left: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bookmark_border_rounded,
                    color: Colors.white,
                    size: AppDimens.iconSm,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(AppDimens.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDimens.spaceXxs),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: tc.textTertiary,
                      size: 12.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      location,
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        color: tc.textTertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.r),
                  child: LinearProgressIndicator(
                    value: 0.45,
                    minHeight: 4.h,
                    backgroundColor: tc.progressBg,
                    valueColor: AlwaysStoppedAnimation<Color>(tc.progressFill),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Target Raise",
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
                            color: tc.textTertiary,
                          ),
                        ),
                        Text(
                          targetRaise,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: tc.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Target ROI",
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
                            color: tc.textTertiary,
                          ),
                        ),
                        Text(
                          targetRoi,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.accentRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
