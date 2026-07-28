import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../models/collaboration_request_model.dart';

class CollaborationCard extends StatelessWidget {
  final CollaborationRequestModel item;
  final VoidCallback? onLeftAction;
  final VoidCallback? onRightAction;

  const CollaborationCard({
    super.key,
    required this.item,
    this.onLeftAction,
    this.onRightAction,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          margin: EdgeInsets.only(bottom: AppDimens.spaceLg),
          padding: EdgeInsets.all(AppDimens.paddingMd + 2),
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
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar, Info, Badge
              Row(
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
                            radius: AppDimens.avatarMd,
                            backgroundImage: NetworkImage(item.avatarUrl),
                          ),
                          SizedBox(width: AppDimens.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.investorName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: tc.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: AppDimens.spaceXxs),
                                Text(
                                  item.investorType,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.sp,
                                    color: tc.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildBadge(tc),
                ],
              ),
              SizedBox(height: AppDimens.spaceMd),

              // Inner Details Container
              Container(
                padding: EdgeInsets.all(AppDimens.paddingMd),
                decoration: BoxDecoration(
                  color: tc.cardInner,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                    color: tc.borderSubtle,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            SizedBox(height: AppDimens.spaceXxs),
                            Text(
                              item.projectName,
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp,
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
                            SizedBox(height: AppDimens.spaceXxs),
                            Text(
                              item.proposedBudget,
                              style: GoogleFonts.outfit(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Proposal",
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        color: tc.textTertiary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.proposalText,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                        color: tc.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimens.spaceMd),

              // Action Buttons Row using Reusable CustomButton
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: item.isHistory ? "Remove" : "Reject",
                      icon: Icons.close_rounded,
                      variant: CustomButtonVariant.destructive,
                      height: 42.h,
                      onPressed: onLeftAction ?? () {},
                    ),
                  ),
                  SizedBox(width: AppDimens.spaceMd),
                  Expanded(
                    child: CustomButton(
                      text: item.isHistory ? "Open Chat" : "Approve",
                      icon: item.isHistory ? null : Icons.check_rounded,
                      variant: item.isHistory
                          ? CustomButtonVariant.outlined
                          : CustomButtonVariant.gradient,
                      backgroundColor: item.isHistory ? tc.cardInner : null,
                      borderColor: item.isHistory ? tc.borderColor : null,
                      textColor: item.isHistory ? tc.textPrimary : Colors.white,
                      height: 42.h,
                      onPressed: onRightAction ?? () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(AppThemeColors tc) {
    if (item.badgeText == null) return const SizedBox.shrink();

    if (item.isApprovedBadge) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: tc.greenPillBg,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        ),
        child: Text(
          item.badgeText!,
          style: GoogleFonts.outfit(
            fontSize: 11.sp,
            color: AppColors.successGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF3B1E19).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(
          color: AppColors.accentOrange.withValues(alpha: 0.3),
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove_red_eye_outlined,
            color: AppColors.accentOrange,
            size: 12.r,
          ),
          SizedBox(width: 4.w),
          Text(
            item.badgeText!,
            style: GoogleFonts.outfit(
              fontSize: 11.sp,
              color: AppColors.accentOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
