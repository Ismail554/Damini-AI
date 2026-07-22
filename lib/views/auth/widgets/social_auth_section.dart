import 'package:Braintech/core/utils/asset_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import 'social_auth_button.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SocialAuthButton(
          label: "Continue with Google",
          icon: SvgPicture.asset(SvgAssets.google, height: 18.r, width: 18.r),
          onPressed: () {},
        ),
        SizedBox(height: 12.h),
        SocialAuthButton(
          label: "Continue with Apple",
          icon: Icon(Icons.apple, color: Colors.white, size: 22.r),
          onPressed: () {},
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.white.withValues(alpha: 0.1)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "or continue with",
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: AppColors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ],
    );
  }
}
