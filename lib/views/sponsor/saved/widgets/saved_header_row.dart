import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';

class SavedHeaderRow extends StatelessWidget {
  final String title;
  final String currentFilter;
  final VoidCallback onFilterTap;

  const SavedHeaderRow({
    super.key,
    required this.title,
    required this.currentFilter,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1D3A),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.thirdColor.withValues(alpha: 0.6),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color: AppColors.thirdColor,
                  size: 14.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  currentFilter,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
