import 'dart:io';
import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/chat_message_model.dart';

class DirectChatBubble extends StatefulWidget {
  final ChatMessageModel message;

  const DirectChatBubble({super.key, required this.message});

  @override
  State<DirectChatBubble> createState() => _DirectChatBubbleState();
}

class _DirectChatBubbleState extends State<DirectChatBubble> {
  bool _isPlayingVoice = false;

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isMe = widget.message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12.h,
          left: isMe ? 48.w : 0,
          right: isMe ? 0 : 48.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe
              ? tc.buttonPrimary
              : (tc.isDark
                    ? const Color(0xFF1E2D3D)
                    : const Color.fromARGB(255, 162, 196, 240)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContent(tc),
            AppSpacing.h6,
            Text(
              widget.message.timestamp,
              style: GoogleFonts.outfit(
                fontSize: 10.sp,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : tc.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppThemeColors tc) {
    final isMe = widget.message.isMe;

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
              radius: 18.r,
              backgroundColor: isMe
                  ? Colors.white.withValues(alpha: 0.2)
                  : (tc.isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : tc.buttonPrimary),
              child: Icon(
                _isPlayingVoice
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),

          AppSpacing.w10,
          _buildWaveformUI(isMe),

          AppSpacing.w8,
          Text(
            widget.message.voiceDuration ?? "0:15",
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: isMe ? Colors.white : tc.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.message.text,
      style: GoogleFonts.outfit(
        fontSize: 14.sp,
        color: isMe ? Colors.white : tc.textPrimary,
        height: 1.35,
      ),
    );
  }

  Widget _buildImageWidget() {
    final path = widget.message.mediaUrl ?? '';
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: 200.w, height: 140.h, fit: BoxFit.cover);
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, width: 200.w, height: 140.h, fit: BoxFit.cover);
    }
    return Image.asset(
      'assets/images/onboarding1.png',
      width: 200.w,
      height: 140.h,
      fit: BoxFit.cover,
    );
  }

  Widget _buildWaveformUI(bool isMe) {
    final heights = [12.h, 20.h, 8.h, 24.h, 16.h, 28.h, 14.h, 22.h, 10.h, 18.h];
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
                : Colors.blueAccent.withValues(
                    alpha: _isPlayingVoice ? 0.9 : 0.6,
                  ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      }).toList(),
    );
  }
}
