import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_dimens.dart';
import '../../core/utils/app_theme_colors.dart';
import '../../core/widgets/common_background.dart';
import '../sponsor/public_view/models/project_public_view_model.dart';

class DiscoverDealItem {
  final String id;
  final String title;
  final String location;
  final String category;
  final String imageUrl;
  final String targetRaise;
  final String minInvestment;
  final String targetRoi;
  final double roiValue;
  final double raiseValue;
  final DateTime createdAt;

  const DiscoverDealItem({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.targetRaise,
    required this.minInvestment,
    required this.targetRoi,
    required this.roiValue,
    required this.raiseValue,
    required this.createdAt,
  });
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _selectedCategoryIndex = 0;
  String _selectedSort = "Newest";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _bookmarkedIds = {};

  final List<String> _categories = const [
    "All",
    "Real Estate",
    "Tech",
    "Health",
    "Energy",
  ];

  final List<DiscoverDealItem> _allDeals = [
    DiscoverDealItem(
      id: "deal_1",
      title: "Downtown Tech Hub",
      location: "United States",
      category: "Real Estate",
      imageUrl:
          "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop",
      targetRaise: "\$5.0M",
      minInvestment: "\$1000",
      targetRoi: "~ 18%",
      roiValue: 18.0,
      raiseValue: 5000000,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    DiscoverDealItem(
      id: "deal_2",
      title: "AI Logistics Platform",
      location: "United Kingdom",
      category: "Tech",
      imageUrl:
          "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=600&auto=format&fit=crop",
      targetRaise: "\$1.2M",
      minInvestment: "\$1000",
      targetRoi: "~ 25%",
      roiValue: 25.0,
      raiseValue: 1200000,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    DiscoverDealItem(
      id: "deal_3",
      title: "EcoTech Solar Farm",
      location: "Australia",
      category: "Energy",
      imageUrl:
          "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=600&auto=format&fit=crop",
      targetRaise: "\$2.5M",
      minInvestment: "\$1000",
      targetRoi: "~ 12%",
      roiValue: 12.0,
      raiseValue: 2500000,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    DiscoverDealItem(
      id: "deal_4",
      title: "Genomic Care Center",
      location: "Switzerland",
      category: "Health",
      imageUrl:
          "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=600&auto=format&fit=crop",
      targetRaise: "\$6.5M",
      minInvestment: "\$2500",
      targetRoi: "~ 21%",
      roiValue: 21.0,
      raiseValue: 6500000,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    DiscoverDealItem(
      id: "deal_5",
      title: "Skyline Luxury Towers",
      location: "United States",
      category: "Real Estate",
      imageUrl:
          "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=600&auto=format&fit=crop",
      targetRaise: "\$20.0M",
      minInvestment: "\$5000",
      targetRoi: "~ 16%",
      roiValue: 16.0,
      raiseValue: 20000000,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DiscoverDealItem> get _filteredAndSortedDeals {
    final selectedCategory = _categories[_selectedCategoryIndex];

    var deals = _allDeals.where((deal) {
      final matchesCat =
          selectedCategory == "All" || deal.category == selectedCategory;
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          deal.title.toLowerCase().contains(q) ||
          deal.location.toLowerCase().contains(q) ||
          deal.category.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();

    if (_selectedSort == "Highest ROI") {
      deals.sort((a, b) => b.roiValue.compareTo(a.roiValue));
    } else if (_selectedSort == "Target Raise") {
      deals.sort((a, b) => b.raiseValue.compareTo(a.raiseValue));
    } else {
      deals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return deals;
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final deals = _filteredAndSortedDeals;

    return CommonBackground(
      showGrid: false,
      topSafeArea: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildTopGlassCard(context, tc),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenHorizontal),
              child: _buildSubHeader(tc, deals.length),
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
                        final isBookmarked =
                            _bookmarkedIds.contains(item.id);
                        return _buildDealCard(context, tc, item, isBookmarked);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGlassCard(BuildContext context, AppThemeColors tc) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topInset + 4.h,
        bottom: 18.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF07295F),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B3A82),
            Color(0xFF052152),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, tc),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenHorizontal),
            child: _buildSearchBar(tc),
          ),
          SizedBox(height: 16.h),
          _buildTagChips(tc),
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
              color: Colors.white,
              size: 20.r,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            "Discover",
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppThemeColors tc) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.8),
            size: AppDimens.iconMd,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                hintText: "Search deals near you...",
                hintStyle: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.5),
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
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: AppDimens.iconSm,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTagChips(AppThemeColors tc) {
    return SizedBox(
      height: 38.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          final catLabel = _categories[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentRed
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(19.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentRed
                      : Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  catLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubHeader(AppThemeColors tc, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$count results",
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            color: tc.textTertiary,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (val) {
            setState(() {
              _selectedSort = val;
            });
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
                "Sort by: $_selectedSort",
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
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
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
                      setState(() {
                        if (isBookmarked) {
                          _bookmarkedIds.remove(item.id);
                        } else {
                          _bookmarkedIds.add(item.id);
                        }
                      });
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
                        color: isBookmarked ? AppColors.accentRed : Colors.white,
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
            Icon(
              Icons.search_off_rounded,
              size: 48.r,
              color: tc.textTertiary,
            ),
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
