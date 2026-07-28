import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class AiChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClearChat;

  const AiChatAppBar({
    super.key,
    required this.onClearChat,
  });

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: tc.textPrimary,
          size: 22.r,
        ),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFFD34E27),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD34E27).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "AI Assistant",
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "AI Copilot • Online",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: tc.textSecondary,
            size: 22.r,
          ),
          tooltip: "Reset Chat",
          onPressed: onClearChat,
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
