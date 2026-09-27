import 'dart:ui';
import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/collaboration_request_model.dart';

class CollaborationConfirmationCard extends StatelessWidget {
  final CollaborationRequestModel item;
  final VoidCallback? onFundReceived;

  const CollaborationConfirmationCard({
    super.key,
    required this.item,
    this.onFundReceived,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          margin: EdgeInsets.only(bottom: AppDimens.spaceLg),
          decoration: BoxDecoration(
            color: tc.cardBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: tc.borderColor,
              width: AppDimens.borderThin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(tc, context),
              SizedBox(height: AppDimens.spaceMd),
              _buildInnerDetailsBox(tc),
              if (item.hasFundReceivedButton) ...[
                SizedBox(height: AppDimens.spaceMd),
                _buildFundReceivedButton(tc),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(AppThemeColors tc, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push(
              '/public-profile',
              extra: {
                'name': item.investorName,
                'title': item.investorType,
                'avatarUrl': item.avatarUrl,
              },
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: tc.cardInner,
                  backgroundImage: item.avatarUrl.isNotEmpty
                      ? NetworkImage(item.avatarUrl)
                      : null,
                  child: item.avatarUrl.isEmpty
                      ? Icon(Icons.person,
                          color: tc.textSecondary, size: 20.r)
                      : null,
                ),
                AppSpacing.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.investorName,
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                      ),

                      AppSpacing.h2, 
                      Text(
                        item.investorType,
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: tc.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (item.badgeText != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: tc.greenPillBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: tc.greenPillText.withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            child: Text(
              item.badgeText!,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: tc.greenPillText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInnerDetailsBox(AppThemeColors tc) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: tc.cardInner,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
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
                    "Project",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    item.projectName,
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
                    "Proposed Budget",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    item.proposedBudget,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.thirdColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.h12,
          Divider(color: tc.borderColor.withValues(alpha: 0.2), height: 1),
          AppSpacing.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.confirmedDate ?? "Confirmed Apr 10, 2026",
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: tc.textSecondary,
                ),
              ),
              Text(
                item.projectStatusText ?? "Project in progress",
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.thirdColor.withAlpha(160),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFundReceivedButton(AppThemeColors tc) {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: OutlinedButton.icon(
        onPressed: onFundReceived ?? () {},
        icon: Container(
          padding: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: tc.textPrimary, width: 1.2),
          ),
          child: Icon(
            Icons.attach_money_rounded,
            color: tc.textPrimary,
            size: 14.r,
          ),
        ),
        label: Text(
          "Fund Received",
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: tc.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: tc.buttonSecondaryText.withValues(alpha: 0.5),
            width: AppDimens.borderThin,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
        ),
      ),
    );
  }
}
