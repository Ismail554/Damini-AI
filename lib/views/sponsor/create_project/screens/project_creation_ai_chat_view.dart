import '../../../ai_chat/widgets/ai_chat_input_field.dart';
import '../../../ai_chat/widgets/ai_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';

import '../controllers/project_creation_ai_provider.dart';
import '../widgets/damini_ai_interactive_header.dart';
import '../widgets/damini_blueprint_card.dart';
import '../widgets/damini_interactive_chips.dart';

class ProjectCreationAiChatView extends ConsumerStatefulWidget {
  const ProjectCreationAiChatView({super.key});

  @override
  ConsumerState<ProjectCreationAiChatView> createState() =>
      _ProjectCreationAiChatViewState();
}

class _ProjectCreationAiChatViewState
    extends ConsumerState<ProjectCreationAiChatView> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(projectCreationAiProvider);
    final notifier = ref.read(projectCreationAiProvider.notifier);

    _scrollToBottom();

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: DaminiAiInteractiveHeader(
          currentStep: state.currentStepIndex,
          totalSteps: state.totalSteps,
          stepTitle: state.stepTitle,
          isTyping: state.isTyping,
          onReset: () => notifier.clearChat(),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: state.messages.length +
                    (state.isTyping ? 1 : 0) +
                    (state.generatedDraft != null ? 1 : 0),
                itemBuilder: (context, index) {
                  // Typing indicator
                  if (index == state.messages.length && state.isTyping) {
                    return _buildTypingIndicator(tc);
                  }

                  // Generated Blueprint Card
                  if (state.generatedDraft != null &&
                      index ==
                          state.messages.length + (state.isTyping ? 1 : 0)) {
                    return DaminiBlueprintCard(
                      draft: state.generatedDraft!,
                      onApply: () {
                        context.pushReplacement(
                          '/create-project',
                          extra: {'draft': state.generatedDraft},
                        );
                      },
                    );
                  }

                  // Chat Message Bubbles
                  final msg = state.messages[index];
                  return AiMessageBubble(
                    message: msg,
                    onSuggestionTap: (prompt) {
                      if (prompt == "Apply to Project") {
                        if (state.generatedDraft != null) {
                          context.pushReplacement(
                            '/create-project',
                            extra: {'draft': state.generatedDraft},
                          );
                        }
                      } else {
                        notifier.sendMessage(prompt);
                      }
                    },
                  );
                },
              ),
            ),

            // Animated Interactive Suggestion Chips
            DaminiInteractiveChips(
              suggestions: state.currentSuggestions,
              onSelect: (selected) {
                if (selected == "Apply to Project") {
                  if (state.generatedDraft != null) {
                    context.pushReplacement(
                      '/create-project',
                      extra: {'draft': state.generatedDraft},
                    );
                  }
                } else {
                  notifier.sendMessage(selected);
                }
              },
            ),
            SizedBox(height: 6.h),

            // Text Input Field
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
              gradient: LinearGradient(
                colors: [Color(0xFF9333EA), Color(0xFFC026D3)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
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
              border: Border.all(
                color: const Color(0xFF9333EA).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14.r,
                  height: 14.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFC026D3),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  "Damini Advisor is analyzing & drafting...",
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
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
