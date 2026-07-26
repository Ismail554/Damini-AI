import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';

class CustomNavItemData {
  final String label;
  final IconData icon;

  const CustomNavItemData({required this.label, required this.icon});
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomNavItemData> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.navBarMarginH,
        vertical: AppDimens.navBarMarginV,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: AppDimens.navBarHeight,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: tc.navBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: Border.all(
                color: tc.navBorder,
                width: AppDimens.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: tc.shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final isSelected = index == currentIndex;
                final item = items[index];

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            transform: Matrix4.translationValues(
                              0,
                              isSelected ? -6.h : 0,
                              0,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimens.paddingLg,
                              vertical: AppDimens.paddingSm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? tc.navSelectedPill
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusLg,
                              ),
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected
                                  ? tc.navSelectedIcon
                                  : tc.navIcon,
                              size: AppDimens.iconLg,
                            ),
                          ),
                          // if (isSelected)
                          Transform.translate(
                            offset: Offset(0, -4.h),
                            child: Text(
                              item.label,
                              style: GoogleFonts.outfit(
                                fontSize: 10.sp,
                                color: tc.navSelectedText,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
