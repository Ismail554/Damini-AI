import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          textInputAction: textInputAction,
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14.sp),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF0F1E2E).withValues(alpha: 0.6),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
