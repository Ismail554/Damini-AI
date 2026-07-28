import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/ai_chat_message_model.dart';

class AiMessageBubble extends StatelessWidget {
  final AiChatMessageModel message;
  final Function(String)? onSuggestionTap;

  const AiMessageBubble({
    super.key,
    required this.message,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD34E27),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.white,
                    size: 16.r,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF006EDB)
                        : (tc.isDark
                            ? const Color(0xFF092444)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.r),
                      topRight: Radius.circular(18.r),
                      bottomLeft: Radius.circular(isUser ? 18.r : 4.r),
                      bottomRight: Radius.circular(isUser ? 4.r : 18.r),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: tc.isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFE2E8F0),
                          ),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      height: 1.4,
                      color: isUser ? Colors.white : tc.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Optional Follow-up Suggestion Chips below AI Message
          if (!isUser &&
              message.suggestions != null &&
              message.suggestions!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 32.w),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: message.suggestions!.map((suggestion) {
                  return ActionChip(
                    label: Text(
                      suggestion,
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        color: const Color(0xFFD34E27),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor:
                        const Color(0xFFD34E27).withValues(alpha: 0.1),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    onPressed: () => onSuggestionTap?.call(suggestion),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
