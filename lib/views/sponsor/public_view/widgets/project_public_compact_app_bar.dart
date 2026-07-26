import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import 'circle_action_button.dart';

/// Compact top app bar that fades in when the sheet is expanded.
class ProjectPublicCompactAppBar extends StatelessWidget {
  final String title;
  final double appBarOpacity;
  final double statusBarHeight;
  final Color backgroundColor;
  final VoidCallback onBackTap;
  final VoidCallback onBookmarkTap;

  const ProjectPublicCompactAppBar({
    super.key,
    required this.title,
    required this.appBarOpacity,
    required this.statusBarHeight,
    required this.backgroundColor,
    required this.onBackTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    if (appBarOpacity <= 0) return const SizedBox.shrink();

    final tc = AppThemeColors.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: appBarOpacity < 0.5,
        child: Opacity(
          opacity: appBarOpacity,
          child: Container(
            padding: EdgeInsets.only(
              top: statusBarHeight + 6.h,
              bottom: 10.h,
              left: AppDimens.screenHorizontal,
              right: AppDimens.screenHorizontal,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: tc.borderColor,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleActionButton(
                  icon: Icons.arrow_back_rounded,
                  background: tc.cardInner,
                  borderColor: tc.borderColor,
                  iconColor: tc.textPrimary,
                  onTap: onBackTap,
                ),
                SizedBox(width: AppDimens.spaceMd),
                Expanded(
                  child: Text(
                    title.isNotEmpty ? title : "Untitled Project",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: AppDimens.spaceMd),
                CircleActionButton(
                  icon: Icons.bookmark_border_rounded,
                  background: tc.cardInner,
                  borderColor: tc.borderColor,
                  iconColor: tc.textPrimary,
                  onTap: onBookmarkTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
