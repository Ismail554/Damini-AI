import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import '../controllers/investor_dashboard_provider.dart';
import '../models/investor_dashboard_models.dart';
import '../widgets/featured_opportunity_card.dart';
import '../widgets/investor_banner_carousel.dart';
import '../widgets/investor_category_chip.dart';
import '../widgets/trending_opportunity_card.dart';
import '../../../profile/widgets/profile_quick_view_sheet.dart';
import 'package:Braintech/core/widgets/app_avatar.dart';
import 'package:Braintech/core/widgets/app_state_widgets.dart';

class InvestorDashboard extends ConsumerStatefulWidget {
  const InvestorDashboard({super.key});

  @override
  ConsumerState<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends ConsumerState<InvestorDashboard> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final dashboardState = ref.watch(investorDashboardProvider);
    final isSearching = dashboardState.searchQuery.trim().isNotEmpty;
    final selectedCategory = dashboardState.selectedCategoryLabel;
    final filteredFeatured = dashboardState.filteredFeatured;
    final filteredTrending = dashboardState.filteredTrending;

    return RefreshIndicator(
      onRefresh: () => ref.read(investorDashboardProvider.notifier).refresh(),
      color: AppColors.primaryColor,
      backgroundColor: tc.cardBg,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.screenHorizontal,
          vertical: AppDimens.screenVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingRow(tc, dashboardState),
            AppSpacing.h18, 
            _buildSearchBar(tc),
            SizedBox(height: AppDimens.spaceXl),
          if (isSearching) ...[
            _buildSearchResultsHeader(
              tc,
              filteredFeatured.length + filteredTrending.length,
            ),
            SizedBox(height: AppDimens.paddingMd),
            if (filteredFeatured.isEmpty && filteredTrending.isEmpty)
              _buildEmptySearchState(tc, dashboardState.searchQuery)
            else ...[
              if (filteredFeatured.isNotEmpty) ...[
                _buildSectionHeader(tc, "Featured Matches"),
                SizedBox(height: AppDimens.paddingMd),
                _buildFeaturedList(filteredFeatured),
                SizedBox(height: AppDimens.spaceXxl),
              ],
              if (filteredTrending.isNotEmpty) ...[
                _buildSectionHeader(tc, "Trending Matches"),
                SizedBox(height: AppDimens.paddingMd),
                ...filteredTrending.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: AppDimens.paddingMd),
                    child: TrendingOpportunityCard(
                      title: item.title,
                      description: "${item.category} • ${item.location} • ${item.daysLeft} days left",
                      imageUrl: item.imageUrl,
                      raisedAmount: item.minInvestment,
                      goalAmount: item.location,
                      progress: item.fundedPercent,
                    ),
                  ),
                ),
              ],
            ],
          ] else ...[
            const InvestorBannerCarousel(),
            SizedBox(height: AppDimens.spaceXl),
            _buildCategoryChips(dashboardState),
            SizedBox(height: AppDimens.spaceXxl),
            _buildSectionHeader(
              tc,
              selectedCategory == "All"
                  ? "Featured Opportunity"
                  : "Featured $selectedCategory Opportunities",
            ),
            SizedBox(height: AppDimens.paddingMd),
            _buildFeaturedList(filteredFeatured),
            SizedBox(height: AppDimens.spaceXxl),
            _buildTrendingHeader(tc, selectedCategory),
            SizedBox(height: AppDimens.paddingMd),
            if (filteredTrending.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: AppDimens.paddingMd),
                child: TrendingOpportunityCard(
                  title: filteredTrending.first.title,
                  description:
                      "${filteredTrending.first.category} • ${filteredTrending.first.location} • ${filteredTrending.first.daysLeft} days left",
                  imageUrl: filteredTrending.first.imageUrl,
                  raisedAmount: filteredTrending.first.minInvestment,
                  raisedLabel: "Min Indicative Amt",
                  goalAmount: filteredTrending.first.location,
                  goalLabel: "Location",
                  progress: filteredTrending.first.fundedPercent,
                  onTap: () => context.push(
                    '/discover',
                    extra: {
                      'category': selectedCategory,
                      'sort': 'Trending',
                    },
                  ),
                ),
              )
            else
              _buildEmptyCategoryState(tc, selectedCategory),
          ],
          SizedBox(height: 80.h),
        ],
      ),
    ),
  );
}

  Widget _buildGreetingRow(AppThemeColors tc, InvestorDashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => ProfileQuickViewSheet.show(context),
              child: AppAvatar(
                imageUrl: state.profilePhoto,
                name: state.greetingName,
                radius: AppDimens.avatarSm,
              ),
            ),
            SizedBox(width: AppDimens.spaceMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, ${state.greetingName}",
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: tc.textTertiary,
                  ),
                ),
                SizedBox(height: AppDimens.spaceXxs),
                Text(
                  "Find your next project",
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/notifications'),
          child: Stack(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: tc.buttonSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: tc.borderColor),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: tc.textPrimary,
                  size: AppDimens.iconLg,
                ),
              ),
              Positioned(
                top: 10.h,
                right: 12.w,
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: AppColors.accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppThemeColors tc) {
    return Container(
      height: AppDimens.buttonMd,
      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingLg),
      decoration: BoxDecoration(
        color: tc.cardInner,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: tc.textTertiary,
            size: AppDimens.iconMd,
          ),
           AppSpacing.w10, 
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref
                    .read(investorDashboardProvider.notifier)
                    .setSearchQuery(value);
              },
              style: GoogleFonts.outfit(
                color: tc.textPrimary,
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                hintText: "Search projects, industries...",
                hintStyle: GoogleFonts.outfit(
                  color: tc.textTertiary,
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref
                    .read(investorDashboardProvider.notifier)
                    .setSearchQuery('');
              },
              child: Padding(
                padding: EdgeInsets.only(left: 6.w),
                child: Icon(
                  Icons.close_rounded,
                  color: tc.textTertiary,
                  size: AppDimens.iconSm,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsHeader(AppThemeColors tc, int totalCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Search Results ($totalCount)",
          style: GoogleFonts.outfit(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () {
            _searchController.clear();
            ref.read(investorDashboardProvider.notifier).setSearchQuery('');
          },
          child: Text(
            "Clear Search",
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: AppColors.accentRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySearchState(AppThemeColors tc, String query) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: tc.borderColor),
      ),
      child: AppEmptyView.search(
        query: query,
        onClear: () {
          _searchController.clear();
          ref.read(investorDashboardProvider.notifier).setSearchQuery('');
        },
      ),
    );
  }

  Widget _buildEmptyCategoryState(AppThemeColors tc, String category) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: tc.borderColor),
      ),
      child: AppEmptyView(
        isCompact: true,
        title: "No $category Opportunities",
        subtitle: "There are currently no trending deals listed in the $category category.",
        icon: Icons.category_outlined,
      ),
    );
  }

  Widget _buildCategoryChips(InvestorDashboardState state) {
    return SizedBox(
      height: 75.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final cat = state.categories[index];
          return InvestorCategoryChip(
            label: cat.label,
            icon: cat.icon,
            isSelected: index == state.selectedCategoryIndex,
            onTap: () {
              ref
                  .read(investorDashboardProvider.notifier)
                  .selectCategory(index);
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(AppThemeColors tc, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/discover'),
          child: Container(
            padding: EdgeInsets.all(AppDimens.paddingSm),
            decoration: BoxDecoration(
              color: tc.buttonSecondary,
              shape: BoxShape.circle,
              border: Border.all(color: tc.borderColor),
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.accentRed,
              size: AppDimens.iconSm,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedList(List<FeaturedOpportunityModel> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: const AppEmptyView(
          isCompact: true,
          title: "No Featured Opportunities",
          subtitle: "No featured opportunities available in this category.",
          icon: Icons.star_border_rounded,
        ),
      );
    }

    return SizedBox(
      height: 270.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return FeaturedOpportunityCard(
            title: item.title,
            location: item.location,
            category: item.category,
            imageUrl: item.imageUrl,
            targetRaise: item.targetRaise,
            targetRoi: item.targetRoi,
          );
        },
      ),
    );
  }

  Widget _buildTrendingHeader(AppThemeColors tc, [String selectedCategory = "All"]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Trending Now",
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () => context.push(
            '/discover',
            extra: {
              'category': selectedCategory,
              'sort': 'Trending',
            },
          ),
          child: Text(
            "View All",
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.accentRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
