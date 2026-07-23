import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_dimens.dart';
import '../../core/utils/app_theme_colors.dart';
import 'widgets/featured_opportunity_card.dart';

class InvestorSavedView extends StatelessWidget {
  const InvestorSavedView({super.key});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Saved Projects",
                style: GoogleFonts.outfit(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.all(AppDimens.paddingSm),
                decoration: BoxDecoration(
                  color: tc.buttonSecondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_outlined,
                  color: AppColors.accentRed,
                  size: AppDimens.iconMd,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceSm),
          Text(
            "Your bookmarked opportunities & projects.",
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: tc.textTertiary,
            ),
          ),
          SizedBox(height: AppDimens.spaceXl),

          // Saved items grid/list
          const FeaturedOpportunityCard(
            title: "Downtown Tech Hub",
            location: "United States",
            category: "Real Estate",
            imageUrl:
                "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop",
            targetRaise: "\$5.0M",
            targetRoi: "~ 18%",
          ),
          SizedBox(height: AppDimens.spaceLg),
          const FeaturedOpportunityCard(
            title: "AI Logistics Network",
            location: "United Kingdom",
            category: "Tech",
            imageUrl:
                "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=400&auto=format&fit=crop",
            targetRaise: "\$1.2M",
            targetRoi: "~ 24%",
          ),
          SizedBox(height: 90.h),
        ],
      ),
    );
  }
}
