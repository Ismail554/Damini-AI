import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/app_avatar.dart';

class ProfileHeroCard extends StatelessWidget {
  final String? name;
  final String? title;
  final String? avatarUrl;
  final String investedAmount;
  final String projectsCount;
  final String? role;
  final String? verificationStatus;
  final bool isCompany;

  // Enriched profile data
  final String? location;
  final String? companyName;
  final String? bio;
  final String? email;
  final String? stat1Label;
  final String? stat2Label;
  final String? stat3Value;
  final String? stat3Label;
  final VoidCallback? onEdit;

  const ProfileHeroCard({
    super.key,
    required this.name,
    this.title,
    this.avatarUrl,
    required this.investedAmount,
    required this.projectsCount,
    this.role,
    this.verificationStatus,
    this.isCompany = false,
    this.location,
    this.companyName,
    this.bio,
    this.email,
    this.stat1Label,
    this.stat2Label,
    this.stat3Value,
    this.stat3Label,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final status = (verificationStatus ?? '').trim().toUpperCase();
    final isApproved = status == 'APPROVED';
    final isRejected = status == 'REJECTED';
    final isSponsor = role?.toLowerCase() == 'sponsor';

    Color avatarBadgeColor;
    IconData avatarBadgeIcon;
    Color verificationPillBg;
    Color verificationPillColor;
    String verificationPillLabel;
    IconData verificationPillIcon;

    if (isApproved) {
      avatarBadgeColor = AppColors.successGreen;
      avatarBadgeIcon = Icons.shield;
      verificationPillBg = AppColors.successGreen.withValues(alpha: 0.15);
      verificationPillColor = AppColors.successGreen;
      verificationPillLabel = "Verified";
      verificationPillIcon = Icons.shield;
    } else if (isRejected) {
      avatarBadgeColor = AppColors.error;
      avatarBadgeIcon = Icons.cancel_rounded;
      verificationPillBg = AppColors.error.withValues(alpha: 0.15);
      verificationPillColor = AppColors.error;
      verificationPillLabel = "Rejected";
      verificationPillIcon = Icons.cancel_outlined;
    } else {
      avatarBadgeColor = const Color(0xFFF59E0B);
      avatarBadgeIcon = Icons.hourglass_top_rounded;
      verificationPillBg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      verificationPillColor = const Color(0xFFF59E0B);
      verificationPillLabel = "Pending";
      verificationPillIcon = Icons.hourglass_top_rounded;
    }

    final effectiveRole = (role != null && role!.isNotEmpty)
        ? '${role![0].toUpperCase()}${role!.substring(1).toLowerCase()}'
        : 'Member';

    final resolvedTitle = (title != null && title!.trim().isNotEmpty)
        ? title!.trim()
        : (companyName != null && companyName!.trim().isNotEmpty
              ? companyName!.trim()
              : (isCompany
                    ? (isSponsor
                          ? "Corporate Sponsor"
                          : "Institutional Investor")
                    : (isSponsor ? "Sponsor Partner" : "Angel Investor")));

    final defaultStat1Label = isSponsor ? "TOTAL RAISED" : "INVESTED";
    final defaultStat2Label = "PROJECTS";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: tc.cardHero,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: tc.borderColor, width: AppDimens.borderThin),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: tc.isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with status badge
          GestureDetector(
            onTap: onEdit ?? () => context.push('/personal-info'),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tc.isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : const Color(0xFFE2E8F0),
                      width: 2.5.r,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AppAvatar(
                    imageUrl: avatarUrl,
                    name: name ?? "Member",
                    radius: 40,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(3.5.r),
                    decoration: BoxDecoration(
                      color: avatarBadgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: tc.cardHero, width: 2.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      avatarBadgeIcon,
                      color: Colors.white,
                      size: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.h16,

          // Name, Title, Location, Bio
          GestureDetector(
            onTap: onEdit ?? () => context.push('/personal-info'),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Text(
                  name ?? "Member",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  resolvedTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: tc.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                    if (location != null && location!.trim().isNotEmpty) ...[
                      AppSpacing.h4,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: tc.textTertiary,
                          ),
                          SizedBox(width: 3.w),
                          Flexible(
                            child: Text(
                              location!.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 11.5.sp,
                                color: tc.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (bio != null && bio!.trim().isNotEmpty) ...[
                      AppSpacing.h6,
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 300.w),
                        child: Text(
                          bio!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 11.5.sp,
                            color: tc.textSecondary.withValues(alpha: 0.85),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.h10,

              // Unified Badges & Tier Bar (Integrated into a single tight Wrap)
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6.w,
                runSpacing: 6.h,
                children: [
                  // Role Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
                    decoration: BoxDecoration(
                      color: tc.pillBg,
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    ),
                    child: Text(
                      effectiveRole.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        color: tc.pillText,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),

                  // Account Type Badge (Company vs Individual)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
                    decoration: BoxDecoration(
                      color: isCompany
                          ? const Color(0xFF006EDB).withValues(alpha: 0.12)
                          : tc.cardInner,
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      border: Border.all(
                        color: isCompany
                            ? const Color(0xFF006EDB).withValues(alpha: 0.3)
                            : tc.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompany
                              ? Icons.business_rounded
                              : Icons.person_outline_rounded,
                          size: 11.sp,
                          color: isCompany
                              ? const Color(0xFF006EDB)
                              : tc.textSecondary,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          isCompany ? "Company" : "Individual",
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
                            color: isCompany
                                ? const Color(0xFF006EDB)
                                : tc.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subscription Tier Pill (Integrated directly)
                  GestureDetector(
                    onTap: () => context.push('/subscription'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
                      decoration: BoxDecoration(
                        color: tc.textPrimary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                        border: Border.all(
                          color: tc.borderSubtle,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: const Color(0xFF9333EA),
                            size: 11.sp,
                          ),
                          SizedBox(width: 3.5.w),
                          Text(
                            "Free Member",
                            style: GoogleFonts.outfit(
                              fontSize: 10.sp,
                              color: tc.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Verification Pill (interactive if not approved)
                  if (!isApproved)
                    GestureDetector(
                      onTap: () {
                        if (isCompany) {
                          context.push('/company-verification');
                        } else {
                          context.push('/personal-info');
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: verificationPillBg,
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          border: Border.all(
                            color: verificationPillColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              verificationPillIcon,
                              color: verificationPillColor,
                              size: 11.sp,
                            ),
                            SizedBox(width: 3.5.w),
                            Text(
                              verificationPillLabel,
                              style: GoogleFonts.outfit(
                                fontSize: 10.sp,
                                color: verificationPillColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.h12,

              // Segmented Stats Row (Clean, connected surface with subtle dividers)
              Container(
                decoration: BoxDecoration(
                  color: tc.cardInner,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                    color: tc.borderSubtle,
                    width: AppDimens.borderThin,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        tc: tc,
                        icon: isSponsor
                            ? Icons.payments_outlined
                            : Icons.account_balance_wallet_outlined,
                        value: investedAmount,
                        label: stat1Label ?? defaultStat1Label,
                      ),
                    ),
                    _buildStatDivider(tc),
                    Expanded(
                      child: _buildStatItem(
                        tc: tc,
                        icon: Icons.folder_open_rounded,
                        value: projectsCount,
                        label: stat2Label ?? defaultStat2Label,
                      ),
                    ),
                    if (stat3Value != null && stat3Value!.isNotEmpty) ...[
                      _buildStatDivider(tc),
                      Expanded(
                        child: _buildStatItem(
                          tc: tc,
                          icon: Icons.auto_graph_rounded,
                          value: stat3Value!,
                          label: stat3Label ?? "ACTIVE",
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildStatDivider(AppThemeColors tc) {
    return Container(
      width: 1.w,
      height: 24.h,
      color: tc.borderColor.withValues(alpha: tc.isDark ? 0.3 : 0.6),
    );
  }

  Widget _buildStatItem({
    required AppThemeColors tc,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        AppSpacing.h4,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11.sp, color: tc.textTertiary),
            SizedBox(width: 3.5.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textTertiary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
