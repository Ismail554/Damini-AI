import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import 'sponsor_active_project_card.dart';
import 'sponsor_draft_card.dart';
import 'sponsor_metric_card.dart';
import 'sponsor_request_card.dart';

class SponsorDashboard extends StatelessWidget {
  const SponsorDashboard({super.key});

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back",
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Shawn Blake",
                    style: GoogleFonts.outfit(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
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
                  SizedBox(width: 12.w),
                  CircleAvatar(
                    radius: 22.r,
                    backgroundImage: const NetworkImage(
                      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop",
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Top Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SponsorMetricCard(
                label: "Total Views",
                value: "1,248",
                icon: Icons.remove_red_eye_outlined,
              ),
              SponsorMetricCard(
                label: "Active Projects",
                value: "2",
                icon: Icons.layers_outlined,
              ),
              SponsorMetricCard(
                label: "Requests",
                value: "2",
                icon: Icons.group_outlined,
              ),
            ],
          ),
          SizedBox(height: 28.h),

          // Active Projects Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Active Projects",
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
          const SponsorActiveProjectCard(
            title: "Downtown Tech Hub",
            description:
                "A state-of-the-art technology hub located in the heart of downtown Austin.",
            badgeText: "Funding Active",
            raisedAmount: "1.2M",
            goalAmount: "5.0M",
            progress: 0.24,
          ),
          SizedBox(height: 28.h),

          // Recent Requests Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Requests",
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
          SponsorRequestCard(
            name: "Venture Partners LLC",
            subtitle: "Requested NDA access for Downtown Tech Hub",
            avatarUrl:
                "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop",
            onReview: () {},
          ),
          SponsorRequestCard(
            name: "Sarah Jenkins",
            subtitle: "Interested in the EcoTech Solar Farm",
            avatarUrl:
                "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop",
            onReview: () {},
          ),
          SizedBox(height: 24.h),

          // Drafts Section
          Text(
            "Drafts",
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 14.h),
          const SponsorDraftCard(
            title: "Urban Logistics Hub",
            lastEdited: "Last edited 2 days ago",
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
