import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final _categories = const [
    {"label": "All", "icon": Icons.grid_view_rounded},
    {"label": "Tech", "icon": Icons.memory_rounded},
    {"label": "Real Estate", "icon": Icons.home_work_outlined},
    {"label": "Health", "icon": Icons.favorite_outline_rounded},
    {"label": "Energy", "icon": Icons.bolt_rounded},
  ];

  final List<Map<String, dynamic>> _featuredOpportunities = const [
    {
      "title": "Downtown Tech Hub",
      "location": "United States",
      "category": "Real Estate",
      "imageUrl":
          "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop",
      "targetRaise": "\$5.0M",
      "targetRoi": "~ 18%",
    },
    {
      "title": "AI Logistics Platform",
      "location": "United Kingdom",
      "category": "Tech",
      "imageUrl":
          "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=400&auto=format&fit=crop",
      "targetRaise": "\$1.2M",
      "targetRoi": "~ 24%",
    },
    {
      "title": "Cyber Security Infra",
      "location": "United States",
      "category": "Tech",
      "imageUrl":
          "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?q=80&w=400&auto=format&fit=crop",
      "targetRaise": "\$3.5M",
      "targetRoi": "~ 22%",
    },
    {
      "title": "Skyline Luxury Towers",
      "location": "United States",
      "category": "Real Estate",
      "imageUrl":
          "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=400&auto=format&fit=crop",
      "targetRaise": "\$20.0M",
      "targetRoi": "~ 16%",
    },
    {
      "title": "Solar Energy Park",
      "location": "Spain",
      "category": "Energy",
      "imageUrl":
          "https://images.unsplash.com/photo-1785990137771-1cb6d4a63637?q=80&w=1632&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "targetRaise": "\$12.5M",
      "targetRoi": "~ 15%",
    },
    {
      "title": "Wind Power Grid",
      "location": "Denmark",
      "category": "Energy",
      "imageUrl":
          "https://images.unsplash.com/photo-1466611653911-95081537e5b7?q=80&w=400&auto=format&fit=crop",
      "targetRaise": "\$9.0M",
      "targetRoi": "~ 17%",
    },
    {
      "title": "Biotech Health Lab",
      "location": "Germany",
      "category": "Health",
      "imageUrl":
          "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=400&auto=format&fit=crop",
      "targetRaise": "\$8.0M",
      "targetRoi": "~ 20%",
    },
    {
      "title": "Genomic Care Center",
      "location": "Switzerland",
      "category": "Health",
      "imageUrl":
          "https://images.unsplash.com/photo-1579684385127-1ef15d508118?q=80&w=400&auto=format&fit=crop",
      "targetRaise": "\$6.5M",
      "targetRoi": "~ 21%",
    },
  ];

  final List<Map<String, dynamic>> _trendingOpportunities = const [
    {
      "title": "Downtown Tech Hub",
      "category": "Tech",
      "location": "United States",
      "description":
          "A state-of-the-art technology hub located in the heart of downtown Austin.",
      "imageUrl":
          "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop",
      "raisedAmount": "1.2M",
      "goalAmount": "5.0M",
      "progress": 0.24,
    },
    {
      "title": "Metro Commercial Center",
      "category": "Real Estate",
      "location": "Canada",
      "description":
          "Prime urban commercial real estate with multi-tenant long-term leases.",
      "imageUrl":
          "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=600&auto=format&fit=crop",
      "raisedAmount": "8.0M",
      "goalAmount": "15.0M",
      "progress": 0.53,
    },
    {
      "title": "Eco Hydro Energy Grid",
      "category": "Energy",
      "location": "Spain",
      "description":
          "Clean hydro-electric power plant project powering over 50,000 households.",
      "imageUrl":
          "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?q=80&w=600&auto=format&fit=crop",
      "raisedAmount": "4.5M",
      "goalAmount": "10.0M",
      "progress": 0.45,
    },
    {
      "title": "Smart Healthcare Network",
      "category": "Health",
      "location": "Germany",
      "description":
          "AI-assisted diagnostics platform expanding to 120 hospitals nationwide.",
      "imageUrl":
          "https://images.unsplash.com/photo-1516549655169-df83a0774514?q=80&w=600&auto=format&fit=crop",
      "raisedAmount": "3.2M",
      "goalAmount": "8.0M",
      "progress": 0.40,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesQuery(Map<String, dynamic> item, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    final title = (item["title"] as String? ?? '').toLowerCase();
    final category = (item["category"] as String? ?? '').toLowerCase();
    final location = (item["location"] as String? ?? '').toLowerCase();
    final description = (item["description"] as String? ?? '').toLowerCase();
    return title.contains(q) ||
        category.contains(q) ||
        location.contains(q) ||
        description.contains(q);
  }

  bool _matchesCategory(Map<String, dynamic> item, String category) {
    if (category == "All") return true;
    final itemCategory = (item["category"] as String? ?? '');
    return itemCategory.toLowerCase() == category.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isSearching = _searchQuery.trim().isNotEmpty;
    final selectedCategory = _categories[_selectedCategoryIndex]["label"] as String;

    final filteredFeatured = _featuredOpportunities
        .where((item) =>
            _matchesCategory(item, selectedCategory) &&
            _matchesQuery(item, _searchQuery))
        .toList();

    final filteredTrending = _trendingOpportunities
        .where((item) =>
            _matchesCategory(item, selectedCategory) &&
            _matchesQuery(item, _searchQuery))
        .toList();

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
          if (isSearching) ...[
            _buildSearchResultsHeader(tc, filteredFeatured.length + filteredTrending.length),
            SizedBox(height: AppDimens.paddingMd),
            if (filteredFeatured.isEmpty && filteredTrending.isEmpty)
              _buildEmptySearchState(tc)
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
                ...filteredTrending.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: AppDimens.paddingMd),
                      child: TrendingOpportunityCard(
                        title: item["title"] as String,
                        description: item["description"] as String,
                        imageUrl: item["imageUrl"] as String,
                        raisedAmount: item["raisedAmount"] as String,
                        goalAmount: item["goalAmount"] as String,
                        progress: (item["progress"] as num).toDouble(),
                      ),
                    )),
              ],
            ],
          ] else ...[
            const InvestorBannerCarousel(),
            SizedBox(height: AppDimens.spaceXl),
            _buildCategoryChips(),
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
            _buildTrendingHeader(tc),
            SizedBox(height: AppDimens.paddingMd),
            if (filteredTrending.isNotEmpty)
              ...filteredTrending.map((item) => Padding(
                    padding: EdgeInsets.only(bottom: AppDimens.paddingMd),
                    child: TrendingOpportunityCard(
                      title: item["title"] as String,
                      description: item["description"] as String,
                      imageUrl: item["imageUrl"] as String,
                      raisedAmount: item["raisedAmount"] as String,
                      goalAmount: item["goalAmount"] as String,
                      progress: (item["progress"] as num).toDouble(),
                    ),
                  ))
            else
              _buildEmptyCategoryState(tc, selectedCategory),
          ],
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
        GestureDetector(
          onTap: () => context.push('/notifications'),
          child: Stack(
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
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
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
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
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
            setState(() {
              _searchQuery = '';
            });
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

  Widget _buildEmptySearchState(AppThemeColors tc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: tc.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48.r,
            color: tc.textTertiary,
          ),
          SizedBox(height: 12.h),
          Text(
            "No results found for \"$_searchQuery\"",
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: tc.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            "Try searching for another keyword or category.",
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: tc.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoryState(AppThemeColors tc, String category) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: tc.borderColor),
      ),
      child: Center(
        child: Text(
          "No trending opportunities found in $category.",
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            color: tc.textTertiary,
          ),
        ),
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

  Widget _buildFeaturedList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return SizedBox(
        height: 100.h,
        child: Center(
          child: Text(
            "No featured opportunities available in this category.",
            style: GoogleFonts.outfit(fontSize: 13.sp, color: Colors.grey),
          ),
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
            title: item["title"] as String,
            location: item["location"] as String,
            category: item["category"] as String,
            imageUrl: item["imageUrl"] as String,
            targetRaise: item["targetRaise"] as String,
            targetRoi: item["targetRoi"] as String,
          );
        },
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
        GestureDetector(
          onTap: () => context.push('/discover'),
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
