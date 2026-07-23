import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';

class RoleSelectionCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String title;
  final String description;
  final List<String> bulletPoints;
  final IconData icon;
  final Color accentColor;

  const RoleSelectionCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.title,
    required this.description,
    required this.bulletPoints,
    required this.icon,
    this.accentColor = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1C2E).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: accentColor, size: 24.r),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.white.withValues(alpha: 0.2),
                  size: 22.r,
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              description,
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.35,
              ),
            ),
            SizedBox(height: 12.h),
            Column(
              children: bulletPoints.map((point) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          point,
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
