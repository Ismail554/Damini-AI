import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import '../../../sponsor/public_view/models/project_public_view_model.dart';
import '../controllers/discover_provider.dart';
import '../models/discover_deal_model.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final String? initialSort;

  const DiscoverScreen({
    super.key,
    this.initialCategory,
    this.initialSort,
  });

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
        ref
            .read(discoverProvider.notifier)
            .selectCategoryByName(widget.initialCategory!);
      }
      if (widget.initialSort != null && widget.initialSort!.isNotEmpty) {
        ref.read(discoverProvider.notifier).selectSort(widget.initialSort!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final discoverState = ref.watch(discoverProvider);
    final deals = discoverState.filteredAndSortedDeals;

    return CommonBackground(
      showGrid: false,
      topSafeArea: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildTopGlassCard(context, tc, discoverState),
            AppSpacing.h14,
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenHorizontal,
              ),
              child: _buildSubHeader(
                tc,
                deals.length,
                discoverState.selectedSort,
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: deals.isEmpty
                  ? _buildEmptyState(tc)
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.screenHorizontal,
                        vertical: 6.h,
                      ),
                      itemCount: deals.length,
                      itemBuilder: (context, index) {
                        final item = deals[index];
                        final isBookmarked = discoverState.bookmarkedIds
                            .contains(item.id);
                        return _buildDealCard(context, tc, item, isBookmarked);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGlassCard(
    BuildContext context,
    AppThemeColors tc,
    DiscoverState state,
  ) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topInset + 4.h, bottom: 18.h),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF07295F) : Colors.white,
        gradient: tc.isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B3A82), Color(0xFF052152)],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
              ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: tc.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border(bottom: BorderSide(color: tc.borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, tc),
          AppSpacing.h10,
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenHorizontal,
            ),
            child: _buildSearchBar(tc, state.searchQuery),
          ),
          AppSpacing.h16,
          _buildTagChips(tc, state),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppThemeColors tc) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal - 8,
        vertical: 4.h,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: tc.textPrimary,
              size: 20.sp,
            ),
          ),
          AppSpacing.w4,
          Text(
            "Discover",
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppThemeColors tc, String currentSearch) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: tc.isDark ? Colors.white.withValues(alpha: 0.08) : tc.cardInner,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: tc.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: tc.textSecondary,
            size: AppDimens.iconMd,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(discoverProvider.notifier).setSearchQuery(val);
              },
              style: GoogleFonts.outfit(color: tc.textPrimary, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: "Search deals near you...",
                hintStyle: GoogleFonts.outfit(
                  color: tc.textTertiary,
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (currentSearch.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref.read(discoverProvider.notifier).setSearchQuery('');
              },
              child: Icon(
                Icons.close_rounded,
                color: tc.textSecondary,
                size: AppDimens.iconSm,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTagChips(AppThemeColors tc, DiscoverState state) {
    return SizedBox(
      height: 38.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == state.selectedCategoryIndex;
          final catLabel = state.categories[index];

          return GestureDetector(
            onTap: () {
              ref.read(discoverProvider.notifier).selectCategory(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentRed
                    : (tc.isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : tc.cardInner),
                borderRadius: BorderRadius.circular(19.r),
                border: Border.all(
                  color: isSelected ? AppColors.accentRed : tc.borderColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  catLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : tc.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubHeader(AppThemeColors tc, int count, String selectedSort) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$count results",
          style: GoogleFonts.outfit(fontSize: 13.sp, color: tc.textTertiary),
        ),
        PopupMenuButton<String>(
          onSelected: (val) {
            ref.read(discoverProvider.notifier).selectSort(val);
          },
          color: tc.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            side: BorderSide(color: tc.borderColor),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: "Newest",
              child: Text(
                "Newest",
                style: GoogleFonts.outfit(color: tc.textPrimary),
              ),
            ),
            PopupMenuItem(
              value: "Trending",
              child: Text(
                "Trending",
                style: GoogleFonts.outfit(color: tc.textPrimary),
              ),
            ),
            PopupMenuItem(
              value: "Highest ROI",
              child: Text(
                "Highest ROI",
                style: GoogleFonts.outfit(color: tc.textPrimary),
              ),
            ),
            PopupMenuItem(
              value: "Target Raise",
              child: Text(
                "Target Raise",
                style: GoogleFonts.outfit(color: tc.textPrimary),
              ),
            ),
          ],
          child: Row(
            children: [
              Text(
                "Sort by: $selectedSort",
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: tc.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: tc.textSecondary,
                size: 18.r,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDealCard(
    BuildContext context,
    AppThemeColors tc,
    DiscoverDealItem item,
    bool isBookmarked,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: tc.borderColor, width: AppDimens.borderThin),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          final publicProject = ProjectPublicViewModel(
            id: item.id,
            title: item.title,
            location: item.location,
            category: item.category,
            stage: "Discover Opportunity",
            targetRaise: item.targetRaise,
            targetRoi: item.targetRoi,
            sponsorName: "Acme Investments",
            sponsorTagline: "Verified Sponsor · Discover Project",
            imageUrls: [item.imageUrl],
            overviewText:
                "${item.title} is an active investment opportunity in ${item.category} located in ${item.location}. Target raise is ${item.targetRaise} with an expected ROI of ${item.targetRoi}.",
            timeline: "24 Months",
            teamSize: "5 Members",
            teamMembers: ProjectPublicViewModel.mockData().teamMembers,
            businessDescription:
                "Detailed investment proposal for ${item.title} (${item.category}). Target raise: ${item.targetRaise}, Min investment: ${item.minInvestment}.",
            minContribution: item.minInvestment,
            expectedRoi: item.targetRoi,
          );
          context.push('/public-view', extra: publicProject);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.r),
                    topRight: Radius.circular(15.r),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    height: 180.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 180.h,
                      color: tc.cardInner,
                      child: Icon(
                        Icons.image_outlined,
                        color: tc.textTertiary,
                        size: 32.r,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      item.category,
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(discoverProvider.notifier)
                          .toggleBookmark(item.id);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isBookmarked
                            ? AppColors.accentRed
                            : Colors.white,
                        size: AppDimens.iconSm,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: tc.textTertiary,
                        size: 13.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item.location,
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: tc.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Divider(
                      color: tc.borderColor.withValues(alpha: 0.4),
                      height: 1,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Target Raise",
                            style: GoogleFonts.outfit(
                              fontSize: 11.sp,
                              color: tc.textTertiary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item.targetRaise,
                            style: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: tc.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Minimum Investment Amt",
                            style: GoogleFonts.outfit(
                              fontSize: 11.sp,
                              color: tc.textTertiary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item.minInvestment,
                            style: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: tc.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Target ROI",
                            style: GoogleFonts.outfit(
                              fontSize: 11.sp,
                              color: tc.textTertiary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item.targetRoi,
                            style: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColors tc) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 48.r, color: tc.textTertiary),
            SizedBox(height: 12.h),
            Text(
              "No deals found",
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: tc.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "Try selecting another category or clearing search filters.",
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                color: tc.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
