import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/app_state_widgets.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import 'package:go_router/go_router.dart';
import '../controllers/investor_saved_provider.dart';
import '../widgets/investor_saved_filter_modal.dart';
import '../widgets/investor_saved_project_card.dart';
import '../widgets/investor_saved_stats_header.dart';

class InvestorSavedView extends ConsumerWidget {
  const InvestorSavedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(investorSavedProvider);
    final items = state.items;

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Saved Items",
                style: GoogleFonts.outfit(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              SizedBox(height: 20.h),
              InvestorSavedStatsHeader(
                totalCommitted: state.totalCommitted,
                activeProjects: state.activeProjectsCount,
                pendingNdas: state.pendingNdasCount,
              ),
              SizedBox(height: 24.h),

              // Section Title & Filter Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Active projects",
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  _buildFilterButton(context, tc, ref, state),
                ],
              ),
              SizedBox(height: 16.h),

              // Project Cards List
              if (items.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: AppEmptyView.saved(
                    title: "No Saved Projects",
                    subtitle: state.filterSelected != 'Newest'
                        ? "No saved projects match the '${state.filterSelected}' filter."
                        : "You haven't bookmarked any opportunities yet. Discover projects to invest in.",
                    actionLabel: "Discover Projects",
                    onAction: () => context.push('/discover'),
                  ),
                )
              else
                ...items.map(
                  (item) => InvestorSavedProjectCard(item: item),
                ),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    AppThemeColors tc,
    WidgetRef ref,
    InvestorSavedState state,
  ) {
    final isFiltered = state.filterSelected != 'Newest';
    final label = isFiltered ? state.filterSelected : "Filter";
    final isDark = tc.isDark;

    return GestureDetector(
      onTap: () async {
        final selected = await InvestorSavedFilterModal.show(
          context,
          currentFilter: state.filterSelected,
        );
        if (selected != null) {
          ref.read(investorSavedProvider.notifier).setFilter(selected);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
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
              size: 14.r,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: isFiltered ? FontWeight.bold : FontWeight.w600,
                color: isFiltered
                    ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                    : tc.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
