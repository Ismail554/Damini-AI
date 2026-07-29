import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_dimens.dart';
import '../../core/utils/app_theme_colors.dart';
import 'widgets/featured_opportunity_card.dart';
import 'widgets/investor_banner_carousel.dart';
import 'widgets/investor_category_chip.dart';
import 'widgets/trending_opportunity_card.dart';

class InvestorDashboard extends StatefulWidget {
  const InvestorDashboard({super.key});

  @override
  State<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends State<InvestorDashboard> {
  int _selectedCategoryIndex = 0;

  final _categories = const [
    {"label": "Tech", "icon": Icons.memory_rounded},
    {"label": "Real Estate", "icon": Icons.home_work_outlined},
    {"label": "Health", "icon": Icons.favorite_outline_rounded},
    {"label": "Energy", "icon": Icons.bolt_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.screenVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingRow(tc),
          SizedBox(height: 18.h),
          _buildSearchBar(tc),
          SizedBox(height: AppDimens.spaceXl),
          const InvestorBannerCarousel(),
          SizedBox(height: AppDimens.spaceXl),
          _buildCategoryChips(),
          SizedBox(height: AppDimens.spaceXxl),
          _buildSectionHeader(tc, "Featured Opportunity"),
          SizedBox(height: AppDimens.paddingMd),
          _buildFeaturedList(),
          SizedBox(height: AppDimens.spaceXxl),
          _buildTrendingHeader(tc),
          SizedBox(height: AppDimens.paddingMd),
          const TrendingOpportunityCard(
            title: "Downtown Tech Hub",
            description:
                "A state-of-the-art technology hub located in the heart of downtown Austin.",
            imageUrl:
                "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=600&auto=format&fit=crop",
            raisedAmount: "1.2M",
            goalAmount: "5.0M",
            progress: 0.24,
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildGreetingRow(AppThemeColors tc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: AppDimens.avatarSm,
              backgroundImage: const NetworkImage(
                "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop",
              ),
            ),
            SizedBox(width: AppDimens.spaceMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, John Doe",
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
        Stack(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
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
                width: 8.r,
                height: 8.r,
                decoration: const BoxDecoration(
                  color: AppColors.accentRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
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
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
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
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 75.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return InvestorCategoryChip(
            label: cat["label"] as String,
            icon: cat["icon"] as IconData,
            isSelected: index == _selectedCategoryIndex,
            onTap: () => setState(() => _selectedCategoryIndex = index),
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
        Container(
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
      ],
    );
  }

  Widget _buildFeaturedList() {
    return SizedBox(
      height: 270.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: const [
          FeaturedOpportunityCard(
            title: "Downtown Tech Hub",
            location: "United States",
            category: "Real Estate",
            imageUrl:
                "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop",
            targetRaise: "\$5.0M",
            targetRoi: "~ 18%",
          ),
          FeaturedOpportunityCard(
            title: "AI Logistics",
            location: "United Kingdom",
            category: "Tech",
            imageUrl:
                "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=400&auto=format&fit=crop",
            targetRaise: "\$1.2M",
            targetRoi: "~ 24%",
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingHeader(AppThemeColors tc) {
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
        Text(
          "View All",
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            color: AppColors.accentRed,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
