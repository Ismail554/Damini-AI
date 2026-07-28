import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/sponsor_saved_project_model.dart';

class SponsorSavedProjectCard extends StatelessWidget {
  final SponsorSavedProjectModel item;
  final VoidCallback? onBookmarkTap;

  const SponsorSavedProjectCard({
    super.key,
    required this.item,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Container(
        decoration: BoxDecoration(
          color: tc.isDark ? const Color(0xFF092444) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: tc.isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header with Category Badge & Bookmark Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    height: 165.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Top Left Category Badge
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      item.category,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Top Right Orange Bookmark Badge
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: onBookmarkTap,
                    child: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_rounded,
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body Content
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: tc.textTertiary,
                        size: 14.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item.location,
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          color: tc.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(
                    height: 1,
                    color: tc.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE2E8F0),
                  ),
                  SizedBox(height: 12.h),

                  // 3-Column Financial Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Target Raise",
                              style: GoogleFonts.outfit(
                                fontSize: 11.sp,
                                color: tc.textTertiary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.targetRaise,
                              style: GoogleFonts.outfit(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: tc.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Minimum Investment Amt",
                              style: GoogleFonts.outfit(
                                fontSize: 11.sp,
                                color: tc.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.minInvestmentAmt,
                              style: GoogleFonts.outfit(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: tc.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Target ROI",
                              style: GoogleFonts.outfit(
                                fontSize: 11.sp,
                                color: tc.textTertiary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.north_east_rounded,
                                  color: const Color(0xFFFF7043),
                                  size: 14.r,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  item.targetRoi,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFF7043),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
