import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';

class SponsorDraftCard extends StatelessWidget {
  final String title;
  final String lastEdited;
  final VoidCallback? onTap;

  const SponsorDraftCard({
    super.key,
    required this.title,
    required this.lastEdited,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppDimens.paddingMd),
        decoration: BoxDecoration(
          color: tc.cardBg,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: tc.borderColor,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: tc.cardHeader,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: tc.textPrimary,
                size: AppDimens.iconMd,
              ),
            ),
            SizedBox(width: AppDimens.paddingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceXxs),
                  Text(
                    lastEdited,
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
