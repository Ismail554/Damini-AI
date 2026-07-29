import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/utils/platform_utils.dart';

class CustomNavItemData {
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  const CustomNavItemData({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}

class CustomBottomNavBar extends StatefulWidget {
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
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  double? _dragX;

  int _indexAt(double x, double barWidth) {
    final itemWidth = barWidth / widget.items.length;
    return (x ~/ itemWidth).clamp(0, widget.items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAndroid = PlatformUtils.isAndroid;

    // Platform & Theme-adaptive colors
    final glassColor = isDark
        ? (isAndroid ? const Color(0xE60D1F30) : const Color(0x730D1F30))
        : (isAndroid ? const Color(0xF2FFFFFF) : const Color(0x99F5F7FA));

    final glassBorder = isDark
        ? Colors.white.withValues(alpha: isAndroid ? 0.12 : 0.18)
        : (isAndroid ? const Color(0xFFE2E8F0) : Colors.white.withValues(alpha: 0.65));

    final glassGlow = isDark
        ? AppColors.primaryColor.withValues(alpha: 0.25)
        : AppColors.primaryColor.withValues(alpha: 0.12);

    final pillColor = isDark
        ? tc.navSelectedPill
        : AppColors.primaryColor.withValues(alpha: 0.15);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.navBarMarginH,
        vertical: AppDimens.navBarMarginV,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: AppDimens.navBarHeight,
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: Border.all(
                color: glassBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: tc.shadowColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: glassGlow,
                  blurRadius: 15,
                  spreadRadius: -2,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                final itemWidth = barWidth / widget.items.length;
                final dragging = _dragX != null;
                final activeIndex = dragging
                    ? _indexAt(_dragX!, barWidth)
                    : widget.currentIndex;
                final capsuleLeft = dragging
                    ? (_dragX! - itemWidth / 2)
                        .clamp(0.0, barWidth - itemWidth)
                    : widget.currentIndex * itemWidth;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) =>
                      widget.onTap(_indexAt(details.localPosition.dx, barWidth)),
                  onHorizontalDragStart: (details) =>
                      setState(() => _dragX = details.localPosition.dx),
                  onHorizontalDragUpdate: (details) => setState(
                    () => _dragX = details.localPosition.dx.clamp(0.0, barWidth),
                  ),
                  onHorizontalDragEnd: (_) {
                    final index = _indexAt(_dragX!, barWidth);
                    setState(() => _dragX = null);
                    widget.onTap(index);
                  },
                  onHorizontalDragCancel: () => setState(() => _dragX = null),
                  child: Stack(
                    children: [
                      // Smooth fluid capsule indicator slider
                      AnimatedPositioned(
                        duration: dragging
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        left: capsuleLeft + 4.w,
                        top: 6.h,
                        bottom: 6.h,
                        width: itemWidth - 8.w,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: pillColor,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(widget.items.length, (index) {
                          final isSelected = index == activeIndex;
                          final item = widget.items[index];
                          final iconData = (isSelected && item.activeIcon != null)
                              ? item.activeIcon!
                              : item.icon;

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: isSelected ? 1.15 : 1.0,
                                  child: Icon(
                                    iconData,
                                    color: isSelected
                                        ? tc.navSelectedIcon
                                        : tc.navIcon.withValues(alpha: 0.7),
                                    size: 22.r,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  item.label,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.sp,
                                    color: isSelected
                                        ? tc.navSelectedText
                                        : tc.navIcon.withValues(alpha: 0.7),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
