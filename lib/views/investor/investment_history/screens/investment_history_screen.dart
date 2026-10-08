import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/investment_history_provider.dart';
import '../models/investment_record_model.dart';

class InvestmentHistoryScreen extends ConsumerWidget {
  const InvestmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final historyState = ref.watch(investmentHistoryProvider);
    final records = historyState.filteredRecords;

    return CommonBackground(
      showGrid: false,
      topSafeArea: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              _buildTopHeader(context, tc, topInset),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: AppDimens.screenHorizontal,
                    right: AppDimens.screenHorizontal,
                    top: AppDimens.spaceLg,
                    bottom: bottomInset > 0 ? bottomInset + 20.h : 36.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(tc, historyState.summary),
                      AppSpacing.h20,
                      _buildFilterChips(tc, ref, historyState.selectedFilter),
                      AppSpacing.h16,
                      if (records.isEmpty)
                        _buildEmptyState(tc)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: records.length,
                          separatorBuilder: (context, index) =>
                              AppSpacing.h14,
                          itemBuilder: (context, index) {
                            return _buildRecordCard(context, tc, records[index]);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    AppThemeColors tc,
    double topInset,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topInset + 6.h,
        bottom: 14.h,
        left: 8.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF062248) : tc.cardBg,
        border: Border(
          bottom: BorderSide(
            color: tc.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: tc.textPrimary, size: 22.sp),
          ),
          AppSpacing.w4,
          Text(
            "Investment History",
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AppThemeColors tc, InvestmentPortfolioSummary summary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF0C2240) : tc.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: tc.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: tc.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PORTFOLIO OVERVIEW",
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: tc.textTertiary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: tc.greenPillBg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.successGreen.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  "${summary.activeDealsCount} Active Deals",
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            summary.totalInvested,
            style: GoogleFonts.outfit(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Total Capital Deployed",
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: tc.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: tc.borderColor, height: 1),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Value",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    summary.totalCurrentValue,
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
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
                    "Total Profit / Return",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    summary.totalProfitLoss,
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    AppThemeColors tc,
    WidgetRef ref,
    String selectedFilter,
  ) {
    final filters = ["All", "Active", "Completed", "Pending"];

    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return GestureDetector(
            onTap: () => ref
                .read(investmentHistoryProvider.notifier)
                .setFilter(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0066FF)
                    : tc.isDark
                    ? const Color(0xFF0A1D36)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0066FF) : tc.borderColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : tc.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    AppThemeColors tc,
    InvestmentRecordModel item,
  ) {
    Color statusColor;
    switch (item.status.toLowerCase()) {
      case "active":
        statusColor = Colors.green;
        break;
      case "completed":
        statusColor = const Color(0xFF0066FF);
        break;
      default:
        statusColor = Colors.amber;
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF0A1D36) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: tc.borderColor, width: AppDimens.borderThin),
        boxShadow: [
          BoxShadow(
            color: tc.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  item.imageUrl,
                  width: 48.r,
                  height: 48.r,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 48.r,
                    height: 48.r,
                    color: tc.cardInner,
                    child: Icon(Icons.business, color: tc.textTertiary),
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
                      "Sponsor: ${item.sponsor} • ${item.date}",
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: tc.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  item.status,
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(color: tc.borderColor, height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Invested",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.invested,
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
                    "Current Value",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.currentValue,
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
                    "Return",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.roi,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 38.h,
            child: OutlinedButton(
              onPressed: () {
                if (item.projectId.isNotEmpty) {
                  context.push('/public-view', extra: {'id': item.projectId});
                } else {
                  context.push('/public-view');
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: tc.borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                "View Deal Details",
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: tc.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColors tc) {
    return Padding(
      padding: EdgeInsets.only(top: 40.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.trending_up_rounded, size: 48.r, color: tc.textTertiary),
            SizedBox(height: 12.h),
            Text(
              "No investment records found",
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: tc.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
