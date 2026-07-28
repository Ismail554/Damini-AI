import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class AiChatInputField extends StatefulWidget {
  final Function(String) onSend;

  const AiChatInputField({
    super.key,
    required this.onSend,
  });

  @override
  State<AiChatInputField> createState() => _AiChatInputFieldState();
}

class _AiChatInputFieldState extends State<AiChatInputField> {
  final _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF07172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: tc.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: tc.isDark
                      ? const Color(0xFF0D2847)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: tc.isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: tc.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: "Ask AI Copilot anything...",
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: tc.textTertiary,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFD34E27),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
