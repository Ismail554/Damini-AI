import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../chat/models/chat_message_model.dart';
import '../models/group_chat_model.dart';

class GroupChatMessageBubble extends StatefulWidget {
  final GroupChatMessage message;

  const GroupChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  State<GroupChatMessageBubble> createState() => _GroupChatMessageBubbleState();
}

class _GroupChatMessageBubbleState extends State<GroupChatMessageBubble> {
  bool _isPlayingVoice = false;

  @override
  Widget build(BuildContext context) {
    if (widget.message.isMe) {
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
              '${widget.message.senderName}${widget.message.senderRole != null ? ' · ${widget.message.senderRole}' : ''}',
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
              child: _buildBubbleContent(isMe: true),
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Text(
              widget.message.time,
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
              '${widget.message.senderName}${widget.message.senderRole != null ? ' · ${widget.message.senderRole}' : ''}',
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
                  child: _buildBubbleContent(isMe: false),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 36.w),
            child: Text(
              widget.message.time,
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

  Widget _buildBubbleContent({required bool isMe}) {
    if (widget.message.type == ChatMessageType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: _buildImageWidget(),
      );
    }

    if (widget.message.type == ChatMessageType.voice) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isPlayingVoice = !_isPlayingVoice),
            child: CircleAvatar(
              radius: 16.r,
              backgroundColor: isMe
                  ? Colors.white.withValues(alpha: 0.25)
                  : const Color(0xFF006EDB),
              child: Icon(
                _isPlayingVoice ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 18.r,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          _buildWaveformUI(isMe),
          SizedBox(width: 8.w),
          Text(
            widget.message.voiceDuration ?? "0:15",
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.message.text,
      style: GoogleFonts.outfit(
        color: isMe ? Colors.white : const Color(0xFFE2E8F0),
        fontSize: 13.5.sp,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageWidget() {
    final path = widget.message.mediaUrl ?? '';
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: 190.w,
        height: 130.h,
        fit: BoxFit.cover,
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 190.w,
        height: 130.h,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      'assets/images/onboarding1.png',
      width: 190.w,
      height: 130.h,
      fit: BoxFit.cover,
    );
  }

  Widget _buildWaveformUI(bool isMe) {
    final heights = [10.h, 18.h, 6.h, 22.h, 14.h, 26.h, 12.h, 20.h, 8.h, 16.h];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: heights.map((h) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 1.5.w),
          width: 3.w,
          height: h,
          decoration: BoxDecoration(
            color: isMe
                ? Colors.white.withValues(alpha: _isPlayingVoice ? 0.9 : 0.6)
                : const Color(0xFF006EDB).withValues(alpha: _isPlayingVoice ? 0.9 : 0.6),
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvatar() {
    if (widget.message.isAi) {
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
          widget.message.avatarInitials,
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
