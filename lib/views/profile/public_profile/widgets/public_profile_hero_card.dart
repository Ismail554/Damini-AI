import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/app_theme_colors.dart';

class PublicProfileHeroCard extends StatelessWidget {
  final String name;
  final String title;
  final String? avatarUrl;
  final String role;
  final bool isVerified;
  final String? heroTag;

  const PublicProfileHeroCard({
    super.key,
    required this.name,
    required this.title,
    this.avatarUrl,
    this.role = "Sponsor",
    this.isVerified = true,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final cleanName = name.trim().isEmpty ? 'Member' : name.trim();
    final initials = cleanName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    final hasValidAvatar = avatarUrl != null &&
        avatarUrl!.trim().isNotEmpty &&
        (avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://'));

    Widget avatarWidget = CircleAvatar(
      radius: 44.r,
      backgroundColor: tc.cardInner,
      backgroundImage: hasValidAvatar ? NetworkImage(avatarUrl!.trim()) : null,
      onBackgroundImageError:
          hasValidAvatar ? (exception, stackTrace) {} : null,
      child: !hasValidAvatar
          ? Text(
              initials.isNotEmpty ? initials : 'U',
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: tc.textPrimary,
              ),
            )
          : null,
    );

    if (heroTag != null && heroTag!.isNotEmpty) {
      avatarWidget = Hero(tag: heroTag!, child: avatarWidget);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.paddingXl),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF092444) : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          // Avatar with Green Verified Badge Overlay
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tc.isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppColors.primaryColor.withValues(alpha: 0.2),
                    width: AppDimens.borderMedium,
                  ),
                ),
                child: avatarWidget,
              ),
              if (isVerified)
                Positioned(
                  right: 2.w,
                  bottom: 2.h,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 13.r,
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.h14,
          Text(
            cleanName,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          if (title.trim().isNotEmpty) ...[
            AppSpacing.h4,
            Text(
              title.trim(),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: tc.textSecondary,
              ),
            ),
          ],

          // Badges Row
          if (role.trim().isNotEmpty || isVerified)
            Padding(
              padding: EdgeInsets.only(top: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (role.trim().isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        role.trim(),
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (isVerified) ...[
                    if (role.trim().isNotEmpty) AppSpacing.w8,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: tc.greenPillBg,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: AppColors.successGreen,
                            size: 13.r,
                          ),
                          AppSpacing.w4,
                          Text(
                            "Verified",
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ],
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
}
