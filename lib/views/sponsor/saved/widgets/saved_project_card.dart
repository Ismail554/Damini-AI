import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../project_details/models/sponsor_project_details_model.dart';
import '../models/saved_item_model.dart';

class SavedProjectCard extends StatelessWidget {
  final SavedItemModel item;

  const SavedProjectCard({
    super.key,
    required this.item,
  });

  SponsorProjectDetailsModel get _projectDetails => SponsorProjectDetailsModel(
        id: item.id,
        title: item.title,
        location: "${item.category} • ${item.date}",
        badgeText:
            item.statusText == 'Active' ? 'Funding Active' : item.statusText,
        raisedAmount: item.investedAmount,
        goalAmount: item.valueAmount,
        percentage: item.fundingProgressText,
        progress: item.fundingProgressValue,
        remainingAmount: '\$500k',
        investorsCount: 3,
        targetRoi: item.targetRoi,
        pendingReviewAmount: '\$0',
        contributions: SponsorProjectDetailsModel.mockData().contributions,
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/sponsor-project-details', extra: _projectDetails),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1D3A),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(context),
            SizedBox(height: 14.h),
            _buildMetricsRow(),
            SizedBox(height: 14.h),
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(
            item.imageUrl,
            width: 46.r,
            height: 46.r,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 46.r,
              height: 46.r,
              color: const Color(0xFF172A46),
              child: Icon(Icons.business_rounded,
                  color: Colors.white, size: 24.r),
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
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                "${item.category} • ${item.date}",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF8DA3B5),
                  fontSize: 11.5.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.h),
              _buildStatusBadge(),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () => context.push(
            '/group-chat',
            extra: "${item.title} || Group Chat with Ai",
          ),
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFF0A332C),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: const Color(0xFF10B981),
              size: 18.r,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isPending = item.isPendingStatus;
    final bgColor =
        isPending ? const Color(0xFF3D2E12) : const Color(0xFF0F3B2E);
    final textColor =
        isPending ? const Color(0xFFF59E0B) : const Color(0xFF10B981);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending ? Icons.access_time_rounded : Icons.check_circle_rounded,
            color: textColor,
            size: 11.sp,
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              item.statusText,
              style: GoogleFonts.outfit(
                color: textColor,
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            "Invested",
            item.investedAmount,
            Colors.white,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: _buildMetricTile("Value", item.valueAmount, Colors.white),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: _buildMetricTile(
            "Target ROI",
            item.targetRoi,
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, Color valColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF071426),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: const Color(0xFF6B8A9D),
              fontSize: 11.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: valColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Project funding",
              style: GoogleFonts.outfit(
                color: const Color(0xFF8DA3B5),
                fontSize: 11.5.sp,
              ),
            ),
            Text(
              item.fundingProgressText,
              style: GoogleFonts.outfit(
                color: AppColors.thirdColor,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: item.fundingProgressValue,
            minHeight: 6.h,
            backgroundColor: const Color(0xFF172A46),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.thirdColor,
            ),
          ),
        ),
      ],
    );
  }
}
