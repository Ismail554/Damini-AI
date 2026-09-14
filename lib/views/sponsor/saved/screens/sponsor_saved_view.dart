import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import '../controllers/sponsor_saved_provider.dart';
import '../widgets/sponsor_saved_profile_card.dart';
import '../widgets/sponsor_saved_project_card.dart';

class SponsorSavedView extends ConsumerWidget {
  const SponsorSavedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(sponsorSavedProvider);

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saved",
                style: GoogleFonts.outfit(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              AppSpacing.h16,
              _buildTabPills(ref, state, tc),
              AppSpacing.h20,
              _buildSortRow(context, tc, ref, state),
              AppSpacing.h16,
              _buildContentList(ref, state),
              AppSpacing.h80,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPills(
    WidgetRef ref,
    SponsorSavedState state,
    AppThemeColors tc,
  ) {
    final isProjects = state.currentTab == SavedTab.projects;

    return Row(
      children: [
        GestureDetector(
          onTap: () => ref
              .read(sponsorSavedProvider.notifier)
              .selectTab(SavedTab.projects),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isProjects
                  ? tc.buttonPrimary
                  : (tc.isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : tc.cardInner),
              borderRadius: BorderRadius.circular(22.r),
              border: isProjects
                  ? null
                  : Border.all(color: tc.borderColor, width: 1.w),
            ),
            child: Text(
              "Saved Projects",
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: isProjects ? FontWeight.bold : FontWeight.w500,
                color: isProjects ? Colors.white : tc.textSecondary,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () => ref
              .read(sponsorSavedProvider.notifier)
              .selectTab(SavedTab.profiles),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: !isProjects
                  ? tc.buttonPrimary
                  : (tc.isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : tc.cardInner),
              borderRadius: BorderRadius.circular(22.r),
              border: !isProjects
                  ? null
                  : Border.all(color: tc.borderColor, width: 1.w),
            ),
            child: Text(
              "Saved Profile",
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: !isProjects ? FontWeight.bold : FontWeight.w500,
                color: !isProjects ? Colors.white : tc.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortRow(
    BuildContext context,
    AppThemeColors tc,
    WidgetRef ref,
    SponsorSavedState state,
  ) {
    final isProjects = state.currentTab == SavedTab.projects;
    final isDark = tc.isDark;

    final sortOptions = isProjects
        ? [
            "Newest",
            "Oldest",
            "Highest ROI",
            "Target Raise: High to Low",
            "Target Raise: Low to High",
          ]
        : ["Newest", "Oldest", "Name: A to Z", "Name: Z to A"];

    final isSorted = state.selectedSort != "Newest";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${state.resultsCount} results",
          style: GoogleFonts.outfit(fontSize: 14.sp, color: tc.textSecondary),
        ),
        PopupMenuButton<String>(
          initialValue: state.selectedSort,
          onSelected: (val) =>
              ref.read(sponsorSavedProvider.notifier).setSortOption(val),
          color: isDark ? const Color(0xFF092444) : Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          itemBuilder: (context) => sortOptions
              .map(
                (option) => PopupMenuItem(
                  value: option,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option,
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: state.selectedSort == option
                              ? (isDark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF059669))
                              : tc.textPrimary,
                          fontWeight: state.selectedSort == option
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (state.selectedSort == option)
                        Icon(
                          Icons.check_rounded,
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669),
                          size: 18.r,
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSorted
                  ? (isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                        : const Color(0xFFD1FAE5))
                  : (isDark ? const Color(0xFF092444) : Colors.white),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSorted
                    ? (isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF10B981))
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : const Color(0xFFCBD5E1)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort_rounded,
                  color: isSorted
                      ? (isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669))
                      : tc.textPrimary,
                  size: 16.sp,
                ),
                AppSpacing.w6,
                Text(
                  isSorted ? state.selectedSort : "Sort",
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: isSorted ? FontWeight.bold : FontWeight.w600,
                    color: isSorted
                        ? (isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669))
                        : tc.textPrimary,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isSorted
                      ? (isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669))
                      : tc.textSecondary,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentList(WidgetRef ref, SponsorSavedState state) {
    if (state.currentTab == SavedTab.projects) {
      if (state.projects.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Text(
              "No saved projects",
              style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey),
            ),
          ),
        );
      }
      return Column(
        children: state.projects.map((item) {
          return SponsorSavedProjectCard(
            item: item,
            onBookmarkTap: () =>
                ref.read(sponsorSavedProvider.notifier).removeProject(item.id),
          );
        }).toList(),
      );
    } else {
      if (state.profiles.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Text(
              "No saved profiles",
              style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey),
            ),
          ),
        );
      }
      return Column(
        children: state.profiles.map((item) {
          return SponsorSavedProfileCard(
            item: item,
            onBookmarkTap: () =>
                ref.read(sponsorSavedProvider.notifier).removeProfile(item.id),
          );
        }).toList(),
      );
    }
  }
}
