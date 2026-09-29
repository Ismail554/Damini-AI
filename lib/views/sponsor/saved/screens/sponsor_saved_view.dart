import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import '../../../../core/services/api_error_handler.dart';
import '../../../../core/widgets/app_state_widgets.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../controllers/sponsor_saved_provider.dart';
import '../widgets/saved_filter_modal.dart';
import '../widgets/saved_search_bar.dart';
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
        child: RefreshIndicator(
          color: tc.buttonPrimary,
          backgroundColor: tc.cardBg,
          onRefresh: () => ref.read(sponsorSavedProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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
                AppSpacing.h16,
                SavedSearchBar(
                  initialValue: state.searchQuery,
                  hintText: state.currentTab == SavedTab.projects
                      ? "Search saved projects..."
                      : "Search saved profiles...",
                  onChanged: (val) => ref
                      .read(sponsorSavedProvider.notifier)
                      .onSearchChanged(val),
                  onClear: () =>
                      ref.read(sponsorSavedProvider.notifier).clearSearch(),
                ),
                AppSpacing.h16,
                _buildSortRow(context, tc, ref, state),
                AppSpacing.h16,
                _buildContentList(context, ref, state),
                AppSpacing.h80,
              ],
            ),
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
    final isFiltered = isProjects && state.selectedFilter.toLowerCase() != "all";

    final count = state.resultsCount;
    final countLabel = "$count ${count == 1 ? 'result' : 'results'}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            countLabel,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: tc.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProjects) ...[
              _buildFilterButton(context, tc, ref, state, isFiltered, isDark),
              SizedBox(width: 8.w),
            ],
            _buildSortButton(
              context,
              tc,
              ref,
              state,
              sortOptions,
              isSorted,
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    AppThemeColors tc,
    WidgetRef ref,
    SponsorSavedState state,
    bool isFiltered,
    bool isDark,
  ) {
    final filterLabel = isFiltered ? state.selectedFilter : "Filter";

    return GestureDetector(
      onTap: () async {
        final selected = await SavedFilterModal.show(
          context,
          currentFilter: state.selectedFilter,
        );
        if (selected != null) {
          ref.read(sponsorSavedProvider.notifier).setFilter(selected);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isFiltered
              ? (isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                  : const Color(0xFFD1FAE5))
              : (isDark ? const Color(0xFF092444) : Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isFiltered
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))
                : (isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              color: isFiltered
                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                  : tc.textPrimary,
              size: 15.sp,
            ),
            AppSpacing.w6,
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 75.w),
              child: Text(
                filterLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: isFiltered ? FontWeight.bold : FontWeight.w600,
                  color: isFiltered
                      ? (isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669))
                      : tc.textPrimary,
                ),
              ),
            ),
            if (isFiltered) ...[
              SizedBox(width: 4.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    ref.read(sponsorSavedProvider.notifier).setFilter('All'),
                child: Padding(
                  padding: EdgeInsets.all(2.r),
                  child: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? const Color(0xFF34D399)
                        : const Color(0xFF059669),
                    size: 14.sp,
                  ),
                ),
              ),
            ] else ...[
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: tc.textSecondary,
                size: 16.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(
    BuildContext context,
    AppThemeColors tc,
    WidgetRef ref,
    SponsorSavedState state,
    List<String> sortOptions,
    bool isSorted,
    bool isDark,
  ) {
    return PopupMenuButton<String>(
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSorted
              ? (isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                  : const Color(0xFFD1FAE5))
              : (isDark ? const Color(0xFF092444) : Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSorted
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))
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
                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                  : tc.textPrimary,
              size: 15.sp,
            ),
            AppSpacing.w6,
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 85.w),
              child: Text(
                isSorted ? _getSortDisplayLabel(state.selectedSort) : "Sort",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isSorted
                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                  : tc.textSecondary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  String _getSortDisplayLabel(String sort) {
    switch (sort) {
      case 'Target Raise: High to Low':
        return 'Raise: High';
      case 'Target Raise: Low to High':
        return 'Raise: Low';
      case 'Highest ROI':
        return 'ROI';
      case 'Name: A to Z':
        return 'A-Z';
      case 'Name: Z to A':
        return 'Z-A';
      default:
        return sort;
    }
  }

  Widget _buildContentList(
    BuildContext context,
    WidgetRef ref,
    SponsorSavedState state,
  ) {
    final tc = AppThemeColors.of(context);

    if (state.currentTab == SavedTab.projects) {
      if (state.isLoadingProjects && state.projects.isEmpty) {
        return Column(
          children: List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: const AppShimmer(
                shape: ShimmerShape.card,
                height: 280,
              ),
            ),
          ),
        );
      }

      if (state.projectsError != null && state.projects.isEmpty) {
        return AppErrorView(
          message: state.projectsError!,
          onRetry: () => ref.read(sponsorSavedProvider.notifier).refresh(),
        );
      }

      if (state.projects.isEmpty) {
        String emptyMsg = "No saved projects yet";
        if (state.searchQuery.isNotEmpty) {
          emptyMsg = 'No saved projects found for "${state.searchQuery}"';
        } else if (state.selectedFilter.toLowerCase() != 'all') {
          emptyMsg = 'No ${state.selectedFilter.toLowerCase()} projects found';
        }
        return AppEmptyView(
          message: emptyMsg,
          icon: Icons.bookmark_border_rounded,
        );
      }

      return Column(
        children: state.projects.map((item) {
          return SponsorSavedProjectCard(
            item: item,
            onBookmarkTap: () => _confirmRemoveProject(context, ref, tc, item.id),
          );
        }).toList(),
      );
    } else {
      // Saved Profiles tab
      var profiles = state.profiles;
      if (state.searchQuery.isNotEmpty) {
        final q = state.searchQuery.toLowerCase();
        profiles = profiles
            .where(
              (p) =>
                  p.name.toLowerCase().contains(q) ||
                  p.title.toLowerCase().contains(q) ||
                  p.company.toLowerCase().contains(q),
            )
            .toList();
      }

      if (profiles.isEmpty) {
        return AppEmptyView(
          message: state.searchQuery.isNotEmpty
              ? 'No saved profiles found for "${state.searchQuery}"'
              : "No saved profiles yet",
          icon: Icons.person_outline_rounded,
        );
      }

      return Column(
        children: profiles.map((item) {
          return SponsorSavedProfileCard(
            item: item,
            onBookmarkTap: () =>
                ref.read(sponsorSavedProvider.notifier).removeProfile(item.id),
          );
        }).toList(),
      );
    }
  }

  void _confirmRemoveProject(
    BuildContext context,
    WidgetRef ref,
    AppThemeColors tc,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tc.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Remove Project?",
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        content: Text(
          "Are you sure you want to remove this project from your saved items?",
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            color: tc.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel",
              style: GoogleFonts.outfit(
                color: tc.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(sponsorSavedProvider.notifier).removeProject(id);
                if (context.mounted) {
                  CustomSnackBar.info(context, "Project removed from saved list.");
                }
              } catch (e) {
                if (context.mounted) {
                  CustomSnackBar.error(
                    context,
                    e is AppException
                        ? e.message
                        : "Failed to remove project. Please try again.",
                  );
                }
              }
            },
            child: Text(
              "Remove",
              style: GoogleFonts.outfit(
                color: const Color(0xFFE53935),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
