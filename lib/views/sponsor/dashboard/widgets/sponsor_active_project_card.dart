import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class SponsorActiveProjectCard extends StatelessWidget {
  final String? id;
  final String title;
  final String description;
  final String badgeText;
  final String raisedAmount;
  final String goalAmount;
  final double progress;
  final String? imageUrl;
  final VoidCallback? onTap;
  final String? category;

  const SponsorActiveProjectCard({
    super.key,
    this.id,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.raisedAmount,
    required this.goalAmount,
    required this.progress,
    this.imageUrl,
    this.onTap,
    this.category,
  });

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else if (id != null && id!.isNotEmpty) {
      context.push('/sponsor-project-details', extra: id);
    } else {
      context.push('/sponsor-project-details');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: imageUrl != null
                ? EdgeInsets.zero
                : EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: tc.cardBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(
                color: tc.borderColor,
                width: AppDimens.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: tc.shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppDimens.radiusLg - 1),
                        ),
                        child: Image.network(
                          imageUrl!,
                          height: 160.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 160.h,
                            width: double.infinity,
                            color: tc.cardInner,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: tc.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12.h,
                        left: 12.w,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: tc.pillBg,
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusMd),
                              ),
                              child: Text(
                                badgeText,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  color: tc.pillText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (category != null && category!.isNotEmpty) ...[
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: tc.cardInner.withValues(alpha: 0.85),
                                  borderRadius:
                                      BorderRadius.circular(AppDimens.radiusMd),
                                  border: Border.all(
                                    color: tc.borderColor.withValues(alpha: 0.5),
                                    width: AppDimens.borderThin,
                                  ),
                                ),
                                child: Text(
                                  category!,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.sp,
                                    color: tc.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: GestureDetector(
                          onTap: () => _handleTap(context),
                          child: Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: tc.cardHeader,
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusSm),
                            ),
                            child: Icon(
                              Icons.trending_up_rounded,
                              color: tc.textPrimary,
                              size: AppDimens.iconMd,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(18.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: tc.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppDimens.spaceSm),
                        Text(
                          description,
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            color: tc.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: AppDimens.spaceLg),
                        _buildMetricsBox(tc),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: tc.pillBg,
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusMd),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.outfit(
                                fontSize: 12.sp,
                                color: tc.pillText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (category != null && category!.isNotEmpty) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: tc.cardInner,
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusMd),
                                border: Border.all(
                                  color: tc.borderColor.withValues(alpha: 0.5),
                                  width: AppDimens.borderThin,
                                ),
                              ),
                              child: Text(
                                category!,
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  color: tc.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _handleTap(context),
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: tc.cardHeader,
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusSm),
                          ),
                          child: Icon(
                            Icons.trending_up_rounded,
                            color: tc.textPrimary,
                            size: AppDimens.iconMd,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimens.spaceMd),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceSm),
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      color: tc.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceLg),
                  _buildMetricsBox(tc),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsBox(AppThemeColors tc) {
    return Container(
      padding: EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: tc.cardInner,
        borderRadius: BorderRadius.circular(AppDimens.paddingMd),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Raised",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceXxs),
                  Text(
                    raisedAmount,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: AppColors.thirdColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Goal",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceXxs),
                  Text(
                    goalAmount,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: tc.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: tc.shadowColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.thirdColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
