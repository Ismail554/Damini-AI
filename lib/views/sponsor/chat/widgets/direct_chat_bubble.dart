import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/chat_message_model.dart';

class DirectChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const DirectChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12.h,
          left: isMe ? 48.w : 0,
          right: isMe ? 0 : 48.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF2563EB)
              : (tc.isDark ? const Color(0xFF3B4D63) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: isMe
                    ? Colors.white
                    : (tc.isDark ? Colors.white : const Color(0xFF0F172A)),
                height: 1.35,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message.timestamp,
              style: GoogleFonts.outfit(
                fontSize: 10.sp,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : (tc.isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
