import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class ChatSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;

  const ChatSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = "Search deals near you...",
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: tc.isDark
            ? const Color(0xFF0D233A).withValues(alpha: 0.7)
            : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: tc.textTertiary,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: tc.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: tc.textTertiary,
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
