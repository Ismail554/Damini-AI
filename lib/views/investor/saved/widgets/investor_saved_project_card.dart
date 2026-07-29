import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../sponsor/chat/models/chat_item_model.dart';
import '../../../sponsor/public_view/models/project_public_view_model.dart';
import '../models/investor_saved_item_model.dart';

class InvestorSavedProjectCard extends StatelessWidget {
  final InvestorSavedItemModel item;
  final VoidCallback? onTap;

  const InvestorSavedProjectCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isDark = tc.isDark;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF092444) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            // Top Row: Image, Info, Status, Chat Button
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onTap ??
                        () {
                          final publicProject = ProjectPublicViewModel(
                            id: item.id,
                            title: item.title,
                            location: "United States",
                            category: item.category,
                            stage: item.isActive ? "Active" : "Pending",
                            targetRaise: item.invested,
                            targetRoi: item.targetRoi,
                            sponsorName: "Acme Corp",
                            sponsorTagline: "Verified Sponsor · Active Project",
                            imageUrls: [
                              item.imageUrl,
                              "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop",
                            ],
                            overviewText:
                                "${item.title} is an active project in ${item.category}. Total current value is ${item.value} with target ROI of ${item.targetRoi}.",
                            timeline: "24 Months",
                            teamSize: "4 Members",
                            teamMembers:
                                ProjectPublicViewModel.mockData().teamMembers,
                            businessDescription:
                                "Project ${item.title} operating in ${item.category} with current funding progress of ${(item.fundingProgress * 100).toInt()}%.",
                            minContribution: item.invested,
                            expectedRoi: item.targetRoi,
                            monthlyRevenue: item.value,
                          );
                          context.push('/public-view', extra: publicProject);
                        },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 54.w,
                          height: 54.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.network(
                              item.imageUrl,
                              width: 54.w,
                              height: 54.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 54.w,
                                height: 54.h,
                                color: tc.isDark
                                    ? const Color(0xFF07192E)
                                    : const Color(0xFFE2E8F0),
                                child: Icon(
                                  Icons.image_outlined,
                                  color: tc.textTertiary,
                                  size: 24.r,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: tc.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "${item.category} • ${item.date}",
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  color: tc.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6.h),
                              _buildStatusBadge(item.isActive),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    final chatItem = ChatItemModel(
                      id: "chat_${item.id}",
                      name: item.title,
                      initials: item.title.isNotEmpty ? item.title[0] : "P",
                      lastMessage: "Inquiry about ${item.title}",
                      time: "Just now",
                      isOnline: true,
                    );
                    context.push('/direct-chat', extra: chatItem);
                  },
                  child: Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: const Color(0xFF10B981),
                      size: 18.r,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 3-Column Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(tc, "Invested", item.invested),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildMetricBox(tc, "Value", item.value),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildMetricBox(
                    tc,
                    "Target ROI",
                    item.targetRoi,
                    valueColor: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Progress Bar Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Project funding",
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: tc.textSecondary,
                  ),
                ),
                Text(
                  "${(item.fundingProgress * 100).toInt()}%",
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF97316),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: item.fundingProgress,
                minHeight: 6.h,
                backgroundColor: isDark
                    ? const Color(0xFF07192E)
                    : const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFF97316),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final bg = isActive ? const Color(0xFF064E3B) : const Color(0xFF3B1E19);
    final fg = isActive ? const Color(0xFF10B981) : const Color(0xFFF97316);
    final icon = isActive ? Icons.check_circle_outline : Icons.access_time;
    final text = isActive ? "Active" : "Pending";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 12.r),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(
    AppThemeColors tc,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF07192E) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11.sp,
              color: tc.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? tc.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
