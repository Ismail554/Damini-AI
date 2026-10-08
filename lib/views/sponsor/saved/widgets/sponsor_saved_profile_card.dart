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

  String _formatDisplayName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Member';
    return trimmed.split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + (word.length > 1 ? word.substring(1).toLowerCase() : '');
    }).join(' ');
  }

  String _getInitials(String name, String email) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && trimmed.toLowerCase() != 'member') {
      final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        return parts[0][0].toUpperCase();
      }
    }
    if (email.trim().isNotEmpty) {
      return email.trim()[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final hasValidAvatar = item.avatarUrl.isNotEmpty &&
        (item.avatarUrl.startsWith('http://') ||
            item.avatarUrl.startsWith('https://'));

    final displayName = _formatDisplayName(item.name);
    final initials = _getInitials(item.name, item.email);

    final hasTitle = item.title.trim().isNotEmpty;
    final hasCompany = item.company.trim().isNotEmpty;
    final hasEmail = item.email.trim().isNotEmpty;
    final hasLocation = item.location.trim().isNotEmpty;
    final hasValidRole = item.role.trim().isNotEmpty &&
        item.role.trim().toUpperCase() != 'NONE';

    // Subtitle logic
    String subtitle = '';
    if (hasTitle && hasCompany) {
      subtitle = '${item.title.trim()} • ${item.company.trim()}';
    } else if (hasTitle) {
      subtitle = item.title.trim();
    } else if (hasCompany) {
      subtitle = item.company.trim();
    } else if (hasValidRole) {
      subtitle = item.role.trim();
    } else if (hasEmail) {
      subtitle = item.email.trim();
    }

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
                    'name': displayName,
                    'email': item.email,
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
                              initials,
                              style: GoogleFonts.outfit(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: tc.buttonPrimary,
                              ),
                            )
                          : null,
                    ),
                    AppSpacing.w14,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: tc.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.isIncompleteProfile) ...[
                                AppSpacing.w6,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'Incomplete',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (subtitle.isNotEmpty) ...[
                            AppSpacing.h2,
                            Text(
                              subtitle,
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp,
                                color: tc.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (hasLocation) ...[
                            AppSpacing.h4,
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: tc.textTertiary,
                                  size: 13.sp,
                                ),
                                AppSpacing.w4,
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
                          ] else if (hasEmail && subtitle != item.email.trim()) ...[
                            AppSpacing.h4,
                            Row(
                              children: [
                                Icon(
                                  Icons.mail_outline_rounded,
                                  color: tc.textTertiary,
                                  size: 13.sp,
                                ),
                                AppSpacing.w4,
                                Expanded(
                                  child: Text(
                                    item.email,
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
