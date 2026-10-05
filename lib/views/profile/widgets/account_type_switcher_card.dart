import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';

class AccountTypeSwitcherCard extends StatelessWidget {
  final String activeRole;
  final ValueChanged<String> onSwitchRole;
  final bool isLoading;

  const AccountTypeSwitcherCard({
    super.key,
    required this.activeRole,
    required this.onSwitchRole,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isInvestor = activeRole == 'investor';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.paddingLg),
      decoration: BoxDecoration(
        color: tc.cardHero,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppDimens.paddingSm),
                decoration: BoxDecoration(
                  color: tc.cardHeader,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Icon(
                  Icons.sync_alt_rounded,
                  color: tc.textPrimary,
                  size: AppDimens.iconSm + 2,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Type",
                      style: GoogleFonts.outfit(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: tc.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppDimens.spaceXxs),
                    Text(
                      "Switch your active experience at any time",
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        color: tc.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceLg),

          // Sponsor Card Option
          _buildRoleOption(
            tc: tc,
            title: "Sponsor",
            subtitle: "Publish projects & raise capital",
            icon: Icons.business_center_outlined,
            isActive: !isInvestor,
            isOptionLoading: isLoading && isInvestor,
            onTap: () => onSwitchRole('sponsor'),
          ),
          SizedBox(height: AppDimens.spaceMd),

          // Investor Card Option
          _buildRoleOption(
            tc: tc,
            title: "Investor",
            subtitle: "Discover & fund opportunities",
            icon: Icons.trending_up_rounded,
            isActive: isInvestor,
            isOptionLoading: isLoading && !isInvestor,
            onTap: () => onSwitchRole('investor'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required AppThemeColors tc,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isOptionLoading = false,
  }) {
    return GestureDetector(
      onTap: (isLoading || isActive) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppDimens.paddingMd),
        decoration: BoxDecoration(
          color: tc.cardInner,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isActive
                ? AppColors.successGreen
                : tc.borderColor,
            width: isActive ? 1.5.w : AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: tc.cardHeader,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(
                icon,
                color: isActive ? AppColors.successGreen : tc.textPrimary,
                size: AppDimens.iconMd,
              ),
            ),
            SizedBox(width: AppDimens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceXxs),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppDimens.paddingSm),
            if (isActive)
              Row(
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: AppColors.successGreen,
                    size: AppDimens.iconSm,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "Active",
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else if (isOptionLoading)
              SizedBox(
                width: 14.r,
                height: 14.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(tc.textSecondary),
                ),
              )
            else
              Text(
                "Switch",
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: tc.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
