import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/project_draft_model.dart';

class DaminiBlueprintCard extends StatefulWidget {
  final ProjectDraftModel draft;
  final VoidCallback onApply;

  const DaminiBlueprintCard({
    super.key,
    required this.draft,
    required this.onApply,
  });

  @override
  State<DaminiBlueprintCard> createState() => _DaminiBlueprintCardState();
}

class _DaminiBlueprintCardState extends State<DaminiBlueprintCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final d = widget.draft;

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: EdgeInsets.only(left: 32.w, top: 12.h, bottom: 16.h, right: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              colors: tc.isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E1035)]
                  : [const Color(0xFFF8FAFC), const Color(0xFFF3E8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFFC026D3).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9333EA).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9333EA), Color(0xFFC026D3)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18.r),
                      SizedBox(width: 8.w),
                      Text(
                        "AI Blueprint Generated",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          "Ready",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Body
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.title,
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        d.shortDesc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5.sp,
                          color: tc.textSecondary,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Metric Grid
                      Row(
                        children: [
                          _buildMetricItem(
                            tc,
                            icon: Icons.account_balance_wallet_outlined,
                            label: "Target Goal",
                            value: "\$${d.fundingGoal}",
                          ),
                          SizedBox(width: 8.w),
                          _buildMetricItem(
                            tc,
                            icon: Icons.trending_up_rounded,
                            label: "Target ROI",
                            value: "${d.targetRoi}%",
                          ),
                          SizedBox(width: 8.w),
                          _buildMetricItem(
                            tc,
                            icon: Icons.category_outlined,
                            label: "Industry",
                            value: d.industry ?? "General",
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 44.h,
                        child: ElevatedButton.icon(
                          onPressed: widget.onApply,
                          icon: Icon(Icons.bolt_rounded, color: Colors.white, size: 18.r),
                          label: Text(
                            "Apply Blueprint to Project",
                            style: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006EDB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF006EDB).withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    AppThemeColors tc, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: tc.isDark ? const Color(0xFF092444) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: tc.borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16.r, color: const Color(0xFFC026D3)),
            SizedBox(height: 4.h),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: tc.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 9.5.sp,
                color: tc.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
