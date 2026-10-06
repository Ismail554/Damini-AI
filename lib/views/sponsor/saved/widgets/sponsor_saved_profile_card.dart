import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/sponsor_saved_profile_model.dart';

class SponsorSavedProfileCard extends StatelessWidget {
  final SponsorSavedProfileModel item;
  final VoidCallback? onBookmarkTap;

  const SponsorSavedProfileCard({
    super.key,
    required this.item,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final hasValidAvatar = item.avatarUrl.isNotEmpty &&
        (item.avatarUrl.startsWith('http://') ||
            item.avatarUrl.startsWith('https://'));

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: tc.isDark ? const Color(0xFF092444) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: tc.isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(
                  '/public-profile',
                  extra: {
                    'userId': item.userId,
                    'name': item.name,
                    'title': item.title,
                    'company': item.company,
                    'avatarUrl': item.avatarUrl,
                    'location': item.location,
                    'role': item.role,
                    'isSaved': true,
                  },
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28.r,
                      backgroundColor: tc.cardInner,
                      backgroundImage:
                          hasValidAvatar ? NetworkImage(item.avatarUrl) : null,
                      child: !hasValidAvatar
                          ? Text(
                              item.name.trim().isNotEmpty
                                  ? item.name.trim()[0].toUpperCase()
                                  : 'U',
                              style: GoogleFonts.outfit(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: tc.textPrimary,
                              ),
                            )
                          : null,
                    ),
                    AppSpacing.w14,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.outfit(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: tc.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item.company.isNotEmpty
                                ? "${item.title} • ${item.company}"
                                : item.title,
                            style: GoogleFonts.outfit(
                              fontSize: 13.sp,
                              color: tc.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: tc.textTertiary,
                                size: 13.r,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  item.location,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.sp,
                                    color: tc.textTertiary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBookmarkTap,
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
