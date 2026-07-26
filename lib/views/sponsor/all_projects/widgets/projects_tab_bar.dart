import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class ProjectsTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<String> tabs;

  const ProjectsTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.tabs = const ["Active Projects", "Completed", "Terminated"],
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.thirdColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: tc.borderColor,
                          width: AppDimens.borderThin,
                        ),
                ),
                child: Text(
                  tabs[index],
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : tc.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
