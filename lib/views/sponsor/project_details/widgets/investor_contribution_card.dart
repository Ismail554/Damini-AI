import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/sponsor_project_details_model.dart';

class InvestorContributionCard extends StatelessWidget {
  final InvestorContributionModel contribution;
  final VoidCallback? onTap;

  const InvestorContributionCard({
    super.key,
    required this.contribution,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return GestureDetector(
      onTap: onTap ?? () => context.push('/public-view'),
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimens.spaceMd),
        padding: EdgeInsets.all(AppDimens.paddingMd),
        decoration: BoxDecoration(
          color: tc.cardBg,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: tc.borderColor,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: AppDimens.avatarMd,
              backgroundImage: NetworkImage(contribution.avatarUrl),
            ),
            SizedBox(width: AppDimens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contribution.name,
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
                    contribution.type,
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  if (contribution.isFunded)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: tc.greenPillBg,
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.successGreen,
                            size: 11.r,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Funded",
                            style: GoogleFonts.outfit(
                              fontSize: 10.sp,
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: AppDimens.spaceSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  contribution.amount,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                SizedBox(height: AppDimens.spaceXxs),
                Text(
                  contribution.date,
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp,
                    color: tc.textTertiary,
                  ),
                ),
              ],
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.chevron_right_rounded,
              color: tc.textTertiary,
              size: AppDimens.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}
