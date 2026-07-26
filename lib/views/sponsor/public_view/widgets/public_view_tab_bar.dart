import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class PublicViewTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const PublicViewTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const _tabs = ["Overview", "Details", "Documents", "Financials"];

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: tc.borderColor,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = selectedIndex == index;
          final label = _tabs[index];

          return GestureDetector(
            onTap: () => onTabSelected(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: EdgeInsets.only(right: AppDimens.spaceLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? tc.textPrimary : tc.textTertiary,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3.h,
                    width: isSelected ? 48.w : 0,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentOrange
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
