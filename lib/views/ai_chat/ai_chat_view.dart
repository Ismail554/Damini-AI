import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import 'controllers/ai_chat_provider.dart';
import 'widgets/ai_chat_app_bar.dart';
import 'widgets/ai_chat_input_field.dart';
import 'widgets/ai_message_bubble.dart';
import 'widgets/ai_quick_prompt_chips.dart';

class AiChatView extends ConsumerWidget {
  const AiChatView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(aiChatProvider);
    final notifier = ref.read(aiChatProvider.notifier);
    final messages = state.messages;

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: AiChatAppBar(
            onClearChat: () => notifier.clearChat(),
          ),
        ),
        body: Column(
          children: [
            // Message list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                itemCount: messages.length + (state.isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && state.isTyping) {
                    return _buildTypingIndicator(tc);
                  }
                  final msg = messages[index];
                  return AiMessageBubble(
                    message: msg,
                    onSuggestionTap: (prompt) =>
                        notifier.sendMessage(prompt),
                  );
                },
              ),
            ),

            // Quick Prompts list
            AiQuickPromptChips(
              prompts: state.quickPrompts,
              onPromptTap: (prompt) => notifier.sendMessage(prompt),
            ),
            SizedBox(height: 10.h),

            // Input field
            AiChatInputField(
              onSend: (text) => notifier.sendMessage(text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(AppThemeColors tc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: tc.isDark
                  ? const Color(0xFF092444)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12.r,
                  height: 12.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFD34E27),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  "AI is thinking...",
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: tc.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
