import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class InvestorSavedFilterModal extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  static const List<String> filterOptions = [
    'Newest',
    'Low to High',
    'High to Low',
    'Active Only',
    'Pending Only',
  ];

  const InvestorSavedFilterModal({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String currentFilter,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => InvestorSavedFilterModal(
        selectedFilter: currentFilter,
        onFilterSelected: (val) => Navigator.pop(context, val),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isDark = tc.isDark;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF07192F) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sort & Filter Projects",
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  if (selectedFilter != 'Newest')
                    GestureDetector(
                      onTap: () => onFilterSelected('Newest'),
                      child: Text(
                        "Reset",
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF97316),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              ...filterOptions.map((option) {
                final isSelected =
                    selectedFilter.toLowerCase() == option.toLowerCase();
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14.r),
                    child: InkWell(
                      onTap: () => onFilterSelected(option),
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                    ? const Color(
                                        0xFF064E3B,
                                      ).withValues(alpha: 0.4)
                                    : const Color(0xFFD1FAE5))
                              : (isDark
                                    ? const Color(0xFF0C1D3A)
                                    : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected
                                ? (isDark
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFF10B981))
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : const Color(0xFFE2E8F0)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: GoogleFonts.outfit(
                                fontSize: 14.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? (isDark
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFF059669))
                                    : tc.textPrimary,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: isDark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF059669),
                                size: 18.r,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
