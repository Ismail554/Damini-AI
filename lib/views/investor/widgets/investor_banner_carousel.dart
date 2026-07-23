import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';

class InvestorBannerCarousel extends StatefulWidget {
  const InvestorBannerCarousel({super.key});

  @override
  State<InvestorBannerCarousel> createState() => _InvestorBannerCarouselState();
}

class _InvestorBannerCarouselState extends State<InvestorBannerCarousel> {
  final int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Column(
      children: [
        Container(
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
                  padding: EdgeInsets.all(AppDimens.paddingMd),
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
                            "Downtown Tech Hub",
                            style: GoogleFonts.outfit(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppDimens.spaceXxs),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 12.r,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "United States",
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  color: Colors.white.withValues(alpha: 0.8),
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
                            "Target Raise: \$5.0M",
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: AppDimens.spaceSm),
                          SizedBox(
                            height: AppDimens.buttonSm - 4,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0052CC),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimens.paddingLg - 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppDimens.radiusMd),
                                ),
                              ),
                              child: Text(
                                "Request",
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
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
                    "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimens.spaceMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (idx) {
            final isSelected = idx == _currentIndex;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: isSelected ? 20.w : 6.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : tc.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}
