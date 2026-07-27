import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class ProjectsTabBar extends StatefulWidget {
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
  State<ProjectsTabBar> createState() => _ProjectsTabBarState();
}

class _ProjectsTabBarState extends State<ProjectsTabBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant ProjectsTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToTab(widget.selectedIndex);
    }
  }

  void _scrollToTab(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final targetOffset = (index * 120.w).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: 6.h,
      ),
      child: Row(
        children: List.generate(widget.tabs.length, (index) {
          final isSelected = widget.selectedIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              child: InkWell(
                onTap: () => widget.onTabSelected(index),
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 11.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.thirdColor
                        : tc.cardInner.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.thirdColor
                          : tc.borderColor.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.thirdColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    widget.tabs[index],
                    style: GoogleFonts.outfit(
                      fontSize: 13.5.sp,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : tc.textPrimary,
                    ),
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
