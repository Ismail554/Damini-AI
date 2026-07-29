import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';

class BannerItem {
  final String title;
  final String location;
  final String targetRaise;
  final String imageUrl;

  const BannerItem({
    required this.title,
    required this.location,
    required this.targetRaise,
    required this.imageUrl,
  });
}

class InvestorBannerCarousel extends StatefulWidget {
  const InvestorBannerCarousel({super.key});

  @override
  State<InvestorBannerCarousel> createState() => _InvestorBannerCarouselState();
}

class _InvestorBannerCarouselState extends State<InvestorBannerCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  final List<BannerItem> _banners = const [
    BannerItem(
      title: "Downtown Tech Hub",
      location: "United States",
      targetRaise: "Target Raise: \$5.0M",
      imageUrl:
          "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop",
    ),
    BannerItem(
      title: "Solar Energy Park",
      location: "Spain",
      targetRaise: "Target Raise: \$12.5M",
      imageUrl:
          "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=400&auto=format&fit=crop",
    ),
    BannerItem(
      title: "Green Logistics Hub",
      location: "Germany",
      targetRaise: "Target Raise: \$8.2M",
      imageUrl:
          "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?q=80&w=400&auto=format&fit=crop",
    ),
    BannerItem(
      title: "Biotech Center",
      location: "United Kingdom",
      targetRaise: "Target Raise: \$15.0M",
      imageUrl:
          "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=400&auto=format&fit=crop",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentIndex + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _resetAutoPlay() {
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Column(
      children: [
        SizedBox(
          height: 145.h,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _resetAutoPlay();
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.hasClients &&
                      _pageController.position.haveDimensions) {
                    final page = _pageController.page ?? _currentIndex.toDouble();
                    value = (1 - ((page - index).abs() * 0.12)).clamp(0.88, 1.0);
                  }
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value.clamp(0.6, 1.0),
                      child: child,
                    ),
                  );
                },
                child: _buildBannerCard(context, tc, _banners[index]),
              );
            },
          ),
        ),
        SizedBox(height: AppDimens.spaceMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (idx) {
            final isSelected = idx == _currentIndex;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  idx,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: isSelected ? 22.w : 6.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : tc.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerCard(
    BuildContext context,
    AppThemeColors tc,
    BannerItem item,
  ) {
    return Container(
      width: double.infinity,
      height: 145.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        color: tc.cardHero,
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.paddingMd,
                vertical: AppDimens.paddingSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(19.r),
                  bottomLeft: Radius.circular(19.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 12.r,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              item.location,
                              style: GoogleFonts.outfit(
                                fontSize: 11.sp,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.targetRaise,
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        height: 26.h,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimens.paddingMd,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusMd),
                            ),
                          ),
                          child: Text(
                            "Request",
                            style: GoogleFonts.outfit(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(19.r),
                bottomRight: Radius.circular(19.r),
              ),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
