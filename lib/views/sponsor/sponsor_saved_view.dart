import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';
import 'widgets/sponsor_request_card.dart';

class SponsorSavedView extends StatelessWidget {
  const SponsorSavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Saved Investors & Templates",
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Bookmarked investor profiles & pitch templates.",
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 20.h),

          SponsorRequestCard(
            name: "Venture Partners LLC",
            subtitle: "Institutional Investor - High Tech Focus",
            avatarUrl:
                "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop",
            onReview: () {},
          ),
          SponsorRequestCard(
            name: "Sarah Jenkins",
            subtitle: "Angel Investor - Renewable Energy",
            avatarUrl:
                "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop",
            onReview: () {},
          ),
          SizedBox(height: 90.h),
        ],
      ),
    );
  }
}
