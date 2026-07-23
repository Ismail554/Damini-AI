import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import 'featured_opportunity_card.dart';
import 'investor_banner_carousel.dart';
import 'investor_category_chip.dart';
import 'trending_opportunity_card.dart';

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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundImage: const NetworkImage(
                      "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop",
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, John Doe",
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Find your next project",
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                      color: const Color(0xFF132B47),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22.r,
                    ),
                  ),
                  Positioned(
                    top: 10.h,
                    right: 12.w,
                    child: Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5252),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Search Bar
          Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2238).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.w,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 20.r,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search projects, industries...",
                      hintStyle: GoogleFonts.outfit(
                        color: AppColors.grey,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Hero Banner Carousel
          const InvestorBannerCarousel(),
          SizedBox(height: 20.h),

          // Category Quick-Filters
          SizedBox(
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
          ),
          SizedBox(height: 28.h),

          // Featured Opportunity Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Featured Opportunity",
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF132B47),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: const Color(0xFFFF5252),
                  size: 16.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 235.h,
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
          ),
          SizedBox(height: 28.h),

          // Trending Now Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trending Now",
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "View All",
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: const Color(0xFFFF5252),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
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
}
