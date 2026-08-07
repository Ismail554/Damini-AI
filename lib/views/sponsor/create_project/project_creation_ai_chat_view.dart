import 'package:Braintech/views/ai_chat/widgets/ai_chat_app_bar.dart';
import 'package:Braintech/views/ai_chat/widgets/ai_chat_input_field.dart';
import 'package:Braintech/views/ai_chat/widgets/ai_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';

import 'controllers/project_creation_ai_provider.dart';

class ProjectCreationAiChatView extends StatelessWidget {
  const ProjectCreationAiChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectCreationAiProvider(),
      child: const _ProjectCreationAiChatBody(),
    );
  }
}

class _ProjectCreationAiChatBody extends StatelessWidget {
  const _ProjectCreationAiChatBody();

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final provider = context.watch<ProjectCreationAiProvider>();

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: AiChatAppBar(
            onClearChat: () => context.read<ProjectCreationAiProvider>().clearChat(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == provider.messages.length && provider.isTyping) {
                    return _buildTypingIndicator(tc);
                  }
                  final msg = provider.messages[index];
                  return AiMessageBubble(
                    message: msg,
                    onSuggestionTap: (prompt) {
                      if (prompt == "Apply to Project") {
                        if (provider.generatedDraft != null) {
                          context.pushReplacement(
                            '/create-project',
                            extra: {'draft': provider.generatedDraft},
                          );
                        }
                      } else {
                        provider.sendMessage(prompt);
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
            AiChatInputField(
              onSend: (text) => provider.sendMessage(text),
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
                  "Damini Advisor is thinking...",
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
