import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class DirectChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const DirectChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              decoration: BoxDecoration(
                color: tc.isDark
                    ? const Color(0xFF0C1D2F).withValues(alpha: 0.9)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: tc.isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: Center(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSend(),
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: tc.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: tc.textTertiary,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 48.r,
              height: 48.r,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
