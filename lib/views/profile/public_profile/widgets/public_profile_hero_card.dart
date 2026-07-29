import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class PublicProfileHeroCard extends StatelessWidget {
  final String name;
  final String title;
  final String avatarUrl;
  final String role;
  final bool isVerified;

  const PublicProfileHeroCard({
    super.key,
    required this.name,
    required this.title,
    required this.avatarUrl,
    this.role = "Sponsor",
    this.isVerified = true,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF092444) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          // Avatar with Green Verified Badge Overlay
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: CircleAvatar(
                  radius: 44.r,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
              if (isVerified)
                Positioned(
                  right: 2.w,
                  bottom: 2.h,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 13.r,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 14.sp, color: tc.textSecondary),
          ),
          SizedBox(height: 14.h),

          // Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  role,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isVerified) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: tc.greenPillBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: const Color(0xFF10B981),
                        size: 13.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "Verified",
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
