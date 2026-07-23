import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class SponsorProjectHeader extends StatelessWidget {
  final String title;
  final String location;
  final String badgeText;

  const SponsorProjectHeader({
    super.key,
    required this.title,
    required this.location,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Back button
        GestureDetector(
          onTap: () => context.pop(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: tc.buttonSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tc.borderColor,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: tc.textPrimary,
                  size: AppDimens.iconMd,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppDimens.spaceLg),

        // Title and Status Badge Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceXs),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: tc.textTertiary,
                        size: 14.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        location,
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          color: tc.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppDimens.spaceMd),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: tc.pillBg,
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                border: Border.all(
                  color: tc.borderColor,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: tc.pillText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
