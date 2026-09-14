import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class InvestorCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const InvestorCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        height: 80.h,
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.all(AppDimens.paddingSm + 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : tc.cardBg,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.4)
                : tc.borderColor,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : tc.textPrimary,
              size: AppDimens.iconXl - 4,
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : tc.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
