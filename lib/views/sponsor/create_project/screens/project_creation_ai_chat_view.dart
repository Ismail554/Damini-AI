import '../../../ai_chat/widgets/ai_chat_input_field.dart';
import '../../../ai_chat/widgets/ai_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectCreationAiProvider.notifier).initConversation();
    });
  }

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

    // Listen to error notifications
    ref.listen<ProjectCreationAiState>(projectCreationAiProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage!.isNotEmpty &&
          next.errorMessage != prev?.errorMessage) {
        CustomSnackBar.error(context, next.errorMessage!);
      }
    });

    _scrollToBottom();

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: DaminiAiInteractiveHeader(
          currentStep: state.currentStepIndex,
          totalSteps: state.totalSteps,
          stepTitle: state.stepTitle,
          isTyping: state.isTyping || state.isInitializing,
          onReset: () => notifier.clearChat(),
        ),
        body: Column(
          children: [
            // Subtly show initializing indicator
            if (state.isInitializing)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC026D3)),
              ),

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

            // Retry countdown banner if rate-limited or 503
            if (state.retryAfterSeconds != null &&
                state.retryAfterSeconds! > 0)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                  border:
                      Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_top_rounded,
                        color: Colors.amber, size: 14.r),
                    SizedBox(width: 6.w),
                    Text(
                      "AI advisor is busy. You can send in ${state.retryAfterSeconds}s...",
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: Colors.amber[800] ?? Colors.amber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Text Input Field
            AbsorbPointer(
              absorbing: (state.retryAfterSeconds != null &&
                      state.retryAfterSeconds! > 0) ||
                  state.isTyping ||
                  state.isInitializing,
              child: Opacity(
                opacity: (state.retryAfterSeconds != null &&
                            state.retryAfterSeconds! > 0) ||
                        state.isTyping ||
                        state.isInitializing
                    ? 0.6
                    : 1.0,
                child: AiChatInputField(
                  onSend: (text) => notifier.sendMessage(text),
                ),
              ),
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
