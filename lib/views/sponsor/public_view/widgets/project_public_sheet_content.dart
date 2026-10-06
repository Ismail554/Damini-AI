import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/project_public_view_model.dart';
import 'details_tab_content.dart';
import 'documents_tab_content.dart';
import 'financials_tab_content.dart';
import 'overview_tab_content.dart';
import 'public_view_stats_card.dart';
import 'public_view_tab_bar.dart';
import 'sticky_tab_bar_delegate.dart';

/// Scrollable sliver content hosted inside the DraggableScrollableSheet.
class ProjectPublicSheetContent extends StatelessWidget {
  final ProjectPublicViewModel project;
  final ScrollController scrollController;
  final double expand;
  final int selectedTabIndex;
  final PageController pageController;
  final VoidCallback onToggleSheet;
  final ValueChanged<int> onTabSelected;
  final Color sheetSolidBg;
  final bool isInvestor;
  final bool isRefreshingDocs;
  final VoidCallback? onSignNda;
  final VoidCallback? onRefreshDocs;

  const ProjectPublicSheetContent({
    super.key,
    required this.project,
    required this.scrollController,
    required this.expand,
    required this.selectedTabIndex,
    required this.pageController,
    required this.onToggleSheet,
    required this.onTabSelected,
    required this.sheetSolidBg,
    this.isInvestor = false,
    this.isRefreshingDocs = false,
    this.onSignNda,
    this.onRefreshDocs,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Drag pill + stats header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppDimens.screenHorizontal,
              right: AppDimens.screenHorizontal,
              top: 8.h,
              bottom: AppDimens.spaceLg,
            ),
            child: Column(
              children: [
                // Tappable drag pill (larger hit area)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggleSheet,
                  child: SizedBox(
                    height: 28.h,
                    width: double.infinity,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: 44.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: tc.textTertiary.withValues(
                            alpha: 0.30 + (0.25 * expand),
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),

                // Stats card header
                PublicViewStatsCard(project: project),
              ],
            ),
          ),
        ),

        // Sticky tab bar — stays visible while scrolling
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyTabBarDelegate(
            height: 62.h,
            backgroundColor: sheetSolidBg,
            dividerColor: tc.borderColor,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenHorizontal,
                vertical: 6.h,
              ),
              child: PublicViewTabBar(
                selectedIndex: selectedTabIndex,
                onTabSelected: onTabSelected,
              ),
            ),
          ),
        ),

        // Swipeable tab content
        SliverFillRemaining(
          hasScrollBody: true,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppDimens.screenHorizontal,
              right: AppDimens.screenHorizontal,
              top: AppDimens.spaceMd,
            ),
            child: PageView(
              controller: pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: onTabSelected,
              children: [
                OverviewTabContent(project: project),
                DetailsTabContent(project: project),
                DocumentsTabContent(
                  project: project,
                  isInvestor: isInvestor,
                  isRefreshingDocs: isRefreshingDocs,
                  onSignNda: onSignNda,
                  onRefresh: onRefreshDocs,
                ),
                FinancialsTabContent(project: project),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
