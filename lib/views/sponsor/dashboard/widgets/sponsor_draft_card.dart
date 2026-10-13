import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class SponsorDraftCard extends StatelessWidget {
  final String title;
  final String lastEdited;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Key? dismissKey;

  const SponsorDraftCard({
    super.key,
    required this.title,
    required this.lastEdited,
    this.onTap,
    this.onDelete,
    this.dismissKey,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    final cardContent = GestureDetector(
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
            if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent.withValues(alpha: 0.8),
                  size: 20.sp,
                ),
                onPressed: onDelete,
                tooltip: 'Delete Draft',
              ),
          ],
        ),
      ),
    );

    if (dismissKey == null || onDelete == null) {
      return cardContent;
    }

    return Dismissible(
      key: dismissKey!,
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Delete",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            AppSpacing.w8,
            Icon(
              Icons.delete_forever_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ],
        ),
      ),
      child: cardContent,
    );
  }
}
