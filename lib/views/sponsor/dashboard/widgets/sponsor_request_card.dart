import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class SponsorRequestCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String avatarUrl;
  final VoidCallback onReview;
  final String heroTag;

  const SponsorRequestCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    required this.onReview,
    this.heroTag = 'collaboration_requests_hero',
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Hero(
      tag: heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: EdgeInsets.only(bottom: AppDimens.spaceMd),
          padding: EdgeInsets.all(AppDimens.paddingMd),
          decoration: BoxDecoration(
            color: tc.cardBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: tc.borderColor, width: AppDimens.borderThin),
          ),
          child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(
                '/public-profile',
                extra: {
                  'name': name,
                  'title': subtitle,
                  'avatarUrl': avatarUrl,
                },
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AppDimens.avatarSm,
                    backgroundColor: tc.chatAvatarBg,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? Icon(Icons.person, color: tc.textSecondary, size: 18.r)
                        : null,
                  ),
                  SizedBox(width: AppDimens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
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
                          subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: tc.textTertiary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppDimens.paddingSm),
          SizedBox(
            height: AppDimens.buttonSm,
            child: ElevatedButton(
              onPressed: onReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: tc.buttonSecondary,
                foregroundColor: tc.buttonSecondaryText,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingLg - 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              child: Text(
                "Review",
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
