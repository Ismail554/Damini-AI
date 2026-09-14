import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/asset_manager.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(IconAssets.rawLogo, height: 60.h, width: 60.w),
        SizedBox(height: 16.h),
        Text(
          "Welcome Back",
          style: GoogleFonts.outfit(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Sign in to continue to Nexus.",
          style: GoogleFonts.outfit(
            fontSize: 15.sp,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
