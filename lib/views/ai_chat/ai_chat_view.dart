import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import 'controllers/ai_chat_provider.dart';
import 'widgets/ai_chat_app_bar.dart';
import 'widgets/ai_chat_input_field.dart';
import 'widgets/ai_message_bubble.dart';
import 'widgets/ai_quick_prompt_chips.dart';

class AiChatView extends StatelessWidget {
  const AiChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ChangeNotifierProvider(
      create: (_) => AiChatProvider(),
      child: CommonBackground(
        showGrid: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: Consumer<AiChatProvider>(
              builder: (context, provider, _) => AiChatAppBar(
                onClearChat: () => provider.clearChat(),
              ),
            ),
          ),
          body: Consumer<AiChatProvider>(
            builder: (context, provider, _) {
              final messages = provider.messages;
              return Column(
                children: [
                  // Message list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      itemCount: messages.length + (provider.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && provider.isTyping) {
                          return _buildTypingIndicator(tc);
                        }
                        final msg = messages[index];
                        return AiMessageBubble(
                          message: msg,
                          onSuggestionTap: (prompt) =>
                              provider.sendMessage(prompt),
                        );
                      },
                    ),
                  ),

                  // Quick Prompts list
                  AiQuickPromptChips(
                    prompts: provider.quickPrompts,
                    onPromptTap: (prompt) => provider.sendMessage(prompt),
                  ),
                  SizedBox(height: 10.h),

                  // Input field
                  AiChatInputField(
                    onSend: (text) => provider.sendMessage(text),
                  ),
                ],
              );
            },
          ),
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
