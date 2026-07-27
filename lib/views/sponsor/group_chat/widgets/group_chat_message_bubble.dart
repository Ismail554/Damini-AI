import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/group_chat_model.dart';

class GroupChatMessageBubble extends StatelessWidget {
  final GroupChatMessage message;

  const GroupChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isMe) {
      return _buildMyMessage();
    }
    return _buildOtherMessage();
  }

  Widget _buildMyMessage() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 4.w, bottom: 4.h),
            child: Text(
              '${message.senderName}${message.senderRole != null ? ' · ${message.senderRole}' : ''}',
              style: GoogleFonts.outfit(
                color: const Color(0xFF6B8A9D),
                fontSize: 11.sp,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 0.78.sw),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E60FF), Color(0xFF0052CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(4.r),
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13.5.sp,
                  height: 1.4,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Text(
              message.time,
              style: GoogleFonts.outfit(
                color: const Color(0xFF6B8A9D),
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMessage() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
            child: Text(
              '${message.senderName}${message.senderRole != null ? ' · ${message.senderRole}' : ''}',
              style: GoogleFonts.outfit(
                color: const Color(0xFF6B8A9D),
                fontSize: 11.sp,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildAvatar(),
              SizedBox(width: 8.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 0.72.sw),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16253C),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(4.r),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFE2E8F0),
                      fontSize: 13.5.sp,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 36.w),
            child: Text(
              message.time,
              style: GoogleFonts.outfit(
                color: const Color(0xFF6B8A9D),
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (message.isAi) {
      return Container(
        width: 26.w,
        height: 26.w,
        decoration: const BoxDecoration(
          color: Color(0xFF7C3AED),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 14.sp,
        ),
      );
    }
    return Container(
      width: 26.w,
      height: 26.w,
      decoration: const BoxDecoration(
        color: Color(0xFF006EDB),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          message.avatarInitials,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 9.5.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
