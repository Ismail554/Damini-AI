import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/asset_manager.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(IconAssets.rawLogo, height: 60.h, width: 60.w),
        AppSpacing.h8,
        Text(
          "Create Account",
          style: GoogleFonts.outfit(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        AppSpacing.h8,
        Text(
          "Join Nexus to start collaborating.",
          style: GoogleFonts.outfit(
            fontSize: 15.sp,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
