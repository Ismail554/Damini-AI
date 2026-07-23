import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      width: 250.w,
      margin: EdgeInsets.only(right: 14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192D),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Banner Image with Badges
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
              // Category Tag
              Positioned(
                top: 10.h,
                left: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
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
              // Bookmark Button
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
                    size: 16.r,
                  ),
                ),
              ),
            ],
          ),

          // Bottom Content Panel
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 12.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      location,
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Orange Progress Bar Line
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.r),
                  child: LinearProgressIndicator(
                    value: 0.45,
                    minHeight: 4.h,
                    backgroundColor: const Color(0xFF1E334D),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF5252),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Metrics Row
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
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          targetRaise,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: Colors.white,
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
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          targetRoi,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: const Color(0xFFFF5252),
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
