import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/custom_button.dart';

class LockedDocumentsCard extends StatelessWidget {
  final VoidCallback? onSignNda;
  final bool isTerminated;

  const LockedDocumentsCard({
    super.key,
    this.onSignNda,
    this.isTerminated = false,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppDimens.paddingXl),
          decoration: BoxDecoration(
            color: tc.cardBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: tc.borderColor,
              width: AppDimens.borderThin,
            ),
            boxShadow: [
              BoxShadow(
                color: tc.shadowColor,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: isTerminated
                      ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                      : tc.cardInner,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isTerminated
                        ? const Color(0xFFDC2626).withValues(alpha: 0.3)
                        : tc.borderColor,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Icon(
                  isTerminated
                      ? Icons.block_rounded
                      : Icons.lock_outline_rounded,
                  color: isTerminated
                      ? const Color(0xFFDC2626)
                      : tc.textPrimary,
                  size: 26.r,
                ),
              ),
              SizedBox(height: AppDimens.spaceLg),
              Text(
                isTerminated
                    ? "Project Terminated"
                    : "Confidential Documents",
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              SizedBox(height: AppDimens.spaceSm),
              Text(
                isTerminated
                    ? "This project has been terminated by the sponsor. Non-disclosure agreements and confidential files are no longer accessible."
                    : "You must sign a Non-Disclosure Agreement (NDA) to view the pitch deck, financials, and legal documents.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: tc.textSecondary,
                  height: 1.45,
                ),
              ),
              if (!isTerminated) ...[
                SizedBox(height: AppDimens.spaceXl),
                CustomButton(
                  text: "Sign NDA to Unlock",
                  variant: CustomButtonVariant.gradient,
                  width: 220.w,
                  height: 48.h,
                  onPressed: onSignNda ?? () {},
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
