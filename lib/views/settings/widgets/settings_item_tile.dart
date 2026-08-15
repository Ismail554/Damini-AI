import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class SettingsItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;
  final Color? iconBgColor;

  const SettingsItemTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.textColor,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.white.withValues(alpha: 0.05),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: iconBgColor ??
                    (tc.isDark
                        ? const Color(0xFF132B47).withValues(alpha: 0.7)
                        : const Color(0xFFE2E8F0)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? tc.textPrimary,
                size: 20.r,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? tc.textPrimary,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: tc.textTertiary,
                  size: 22.r,
                ),
          ],
        ),
      ),
    );
  }
}
