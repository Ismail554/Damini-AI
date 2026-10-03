import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import '../controllers/direct_chat_provider.dart';
import '../models/chat_item_model.dart';
import '../widgets/direct_chat_app_bar.dart';
import '../widgets/direct_chat_bubble.dart';
import '../widgets/direct_chat_input_bar.dart';

class DirectChatView extends ConsumerWidget {
  final ChatItemModel chatItem;

  const DirectChatView({super.key, required this.chatItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(directChatProvider(chatItem));
    final notifier = ref.read(directChatProvider(chatItem).notifier);

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: DirectChatAppBar(chatItem: state.chatItem),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    _buildDateChip(tc),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: state.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2563EB),
                              ),
                            )
                          : ListView.builder(
                              controller: notifier.scrollController,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                final message = state.messages[index];
                                return DirectChatBubble(message: message);
                              },
                            ),
                    ),
                  ],
                ),
              ),
              if (state.typingUser != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${state.typingUser} is typing...",
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: const Color(0xFF2563EB),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              DirectChatInputBar(
                controller: notifier.textController,
                onSend: notifier.sendMessage,
                onSendImage: notifier.sendImageMessage,
                onSendVoice: notifier.sendVoiceMessage,
                onTyping: notifier.onTyping,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(AppThemeColors tc) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: tc.isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        "Today",
        style: GoogleFonts.outfit(
          fontSize: 11.sp,
          color: tc.textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
