import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class PasswordInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback? onToggleObscure;

  const PasswordInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.obscureText,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: tc.textPrimary,
              size: 18.r,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: tc.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: tc.isDark
                ? const Color(0xFF091E36)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: tc.isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: tc.textPrimary,
                    letterSpacing: obscureText ? 2.0 : 0.0,
                  ),
                  decoration: InputDecoration(
                    hintText: "*************",
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: tc.textTertiary,
                      letterSpacing: 2.0,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              if (onToggleObscure != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: tc.textTertiary,
                    size: 18.r,
                  ),
                  onPressed: onToggleObscure,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
