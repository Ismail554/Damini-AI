import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';

class InvestmentRecordModel {
  final String id;
  final String title;
  final String category;
  final String sponsor;
  final String date;
  final String status;
  final String invested;
  final String currentValue;
  final String roi;
  final String imageUrl;

  const InvestmentRecordModel({
    required this.id,
    required this.title,
    required this.category,
    required this.sponsor,
    required this.date,
    required this.status,
    required this.invested,
    required this.currentValue,
    required this.roi,
    required this.imageUrl,
  });

  static List<InvestmentRecordModel> mockData() {
    return const [
      InvestmentRecordModel(
        id: "inv_hist_1",
        title: "Downtown Tech Hub",
        category: "Real Estate",
        sponsor: "Acme Corp",
        date: "Mar 14, 2026",
        status: "Active",
        invested: "\$250,000",
        currentValue: "\$288,000",
        roi: "+15.2%",
        imageUrl:
            "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=300&auto=format&fit=crop",
      ),
      InvestmentRecordModel(
        id: "inv_hist_2",
        title: "AI Logistics Platform",
        category: "Tech",
        sponsor: "Nexus AI",
        date: "Feb 22, 2026",
        status: "Active",
        invested: "\$150,000",
        currentValue: "\$173,000",
        roi: "+15.3%",
        imageUrl:
            "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=300&auto=format&fit=crop",
      ),
      InvestmentRecordModel(
        id: "inv_hist_3",
        title: "EcoTech Solar Farm",
        category: "Energy",
        sponsor: "Green Grid Ltd",
        date: "Jan 10, 2026",
        status: "Completed",
        invested: "\$100,000",
        currentValue: "\$118,500",
        roi: "+18.5%",
        imageUrl:
            "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=300&auto=format&fit=crop",
      ),
      InvestmentRecordModel(
        id: "inv_hist_4",
        title: "AeroDynamics Drone Fleet",
        category: "Aviation",
        sponsor: "Sky Tech Ventures",
        date: "Nov 05, 2025",
        status: "Pending",
        invested: "\$60,000",
        currentValue: "\$64,700",
        roi: "+7.8%",
        imageUrl:
            "https://images.unsplash.com/photo-1508614589041-895b88991e3e?q=80&w=300&auto=format&fit=crop",
      ),
    ];
  }
}

class InvestmentHistoryScreen extends StatefulWidget {
  const InvestmentHistoryScreen({super.key});

  @override
  State<InvestmentHistoryScreen> createState() =>
      _InvestmentHistoryScreenState();
}

class _InvestmentHistoryScreenState extends State<InvestmentHistoryScreen> {
  String _selectedFilter = "All";
  final List<InvestmentRecordModel> _allRecords =
      InvestmentRecordModel.mockData();

  List<InvestmentRecordModel> get _filteredRecords {
    if (_selectedFilter == "All") return _allRecords;
    return _allRecords
        .where((item) =>
            item.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final records = _filteredRecords;

    return CommonBackground(
      showGrid: false,
      topSafeArea: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              _buildTopHeader(context, topInset),
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
                      _buildSummaryCard(tc),
                      SizedBox(height: 20.h),
                      _buildFilterChips(tc),
                      SizedBox(height: 16.h),
                      if (records.isEmpty)
                        _buildEmptyState(tc)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: records.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 14.h),
                          itemBuilder: (context, index) {
                            return _buildRecordCard(tc, records[index]);
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

  Widget _buildTopHeader(BuildContext context, double topInset) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topInset + 6.h,
        bottom: 14.h,
        left: 8.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF062248),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 22.r,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            "Investment History",
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AppThemeColors tc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2240),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
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
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  "4 Active Deals",
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "\$560,000",
            style: GoogleFonts.outfit(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Total Capital Deployed",
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
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
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "\$644,200",
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "+\$84,200 (+15.0%)",
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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

  Widget _buildFilterChips(AppThemeColors tc) {
    final filters = ["All", "Active", "Completed", "Pending"];

    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == _selectedFilter;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
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
                  color: isSelected
                      ? const Color(0xFF0066FF)
                      : tc.borderColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
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

  Widget _buildRecordCard(AppThemeColors tc, InvestmentRecordModel item) {
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
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
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
              onPressed: () => context.push('/public-view'),
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
            Icon(
              Icons.trending_up_rounded,
              size: 48.r,
              color: tc.textTertiary,
            ),
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
