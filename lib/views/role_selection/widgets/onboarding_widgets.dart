import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class OnboardingWidgets {
  static Widget buildStepLayout({
    required String title,
    required String desc,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Text(title, style: GoogleFonts.outfit(fontSize: 26.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8.h),
          Text(desc, style: GoogleFonts.outfit(fontSize: 14.sp, color: AppColors.grey)),
          SizedBox(height: 28.h),
          child,
        ],
      ),
    );
  }

  static Widget buildSelectOption({
    required String type,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        backgroundOpacity: isSelected ? 0.08 : 0.03,
        borderOpacity: isSelected ? 0.5 : 0.08,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.h),
                  Text(desc, style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 12.sp)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  static Widget buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    TextInputType kType, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: kType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14.sp),
        prefixIcon: Icon(icon, color: AppColors.grey, size: 20.r),
        filled: true,
        fillColor: const Color(0xFF0F1E2E).withOpacity(0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}
