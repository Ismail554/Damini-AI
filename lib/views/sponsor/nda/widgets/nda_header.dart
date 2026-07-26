import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class NdaHeader extends StatelessWidget {
  final String disclosingParty;

  const NdaHeader({
    super.key,
    required this.disclosingParty,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Column(
      children: [
        // Shield Icon Container
        Container(
          width: 64.r,
          height: 64.r,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              width: AppDimens.borderThin,
            ),
          ),
          child: Icon(
            Icons.shield_outlined,
            color: AppColors.primaryColor,
            size: 32.r,
          ),
        ),
        SizedBox(height: AppDimens.spaceLg),

        // Title
        Text(
          "Confidentiality Agreement",
          style: GoogleFonts.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),

        // Subtitle
        Text(
          "Between $disclosingParty (\"Disclosing Party\") and You (\"Receiving Party\")",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            color: tc.textSecondary,
          ),
        ),
      ],
    );
  }
}
