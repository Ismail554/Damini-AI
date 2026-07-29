import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../sponsor/public_view/models/project_public_view_model.dart';

class FeaturedOpportunityCard extends StatelessWidget {
  final String title;
  final String location;
  final String category;
  final String imageUrl;
  final String targetRaise;
  final String targetRoi;
  final VoidCallback? onTap;

  const FeaturedOpportunityCard({
    super.key,
    required this.title,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.targetRaise,
    required this.targetRoi,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return GestureDetector(
      onTap: onTap ??
          () {
            final publicProject = ProjectPublicViewModel(
              id: "feat_${title.toLowerCase().replaceAll(' ', '_')}",
              title: title,
              location: location,
              category: category,
              stage: "Featured Opportunity",
              targetRaise: targetRaise,
              targetRoi: targetRoi,
              sponsorName: "Acme Corp",
              sponsorTagline: "Verified Sponsor · Featured Project",
              imageUrls: [
                imageUrl,
                "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop",
              ],
              overviewText:
                  "$title is a featured investment opportunity in $category located in $location. Target raise is $targetRaise with an expected ROI of $targetRoi.",
              timeline: "24 Months",
              teamSize: "4 Members",
              teamMembers: ProjectPublicViewModel.mockData().teamMembers,
              businessDescription:
                  "Comprehensive investment package for $title in $category. Target raise is $targetRaise with $targetRoi projected return.",
              minContribution: "\$50,000",
              expectedRoi: targetRoi,
            );
            context.push('/public-view', extra: publicProject);
          },
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
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
                    height: 120.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 120.h,
                      color: tc.cardInner,
                      child: Icon(
                        Icons.image_outlined,
                        color: tc.textTertiary,
                        size: 24.r,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
              padding: EdgeInsets.all(12.r),
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
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: tc.textTertiary,
                        size: 12.r,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.outfit(
                            fontSize: 11.sp,
                            color: tc.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.r),
                    child: LinearProgressIndicator(
                      value: 0.45,
                      minHeight: 4.h,
                      backgroundColor: tc.progressBg,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(tc.progressFill),
                    ),
                  ),
                  SizedBox(height: 8.h),
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
      ),
    );
  }
}
