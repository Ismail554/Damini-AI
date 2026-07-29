import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import 'controllers/direct_chat_provider.dart';
import 'models/chat_item_model.dart';
import 'widgets/direct_chat_app_bar.dart';
import 'widgets/direct_chat_bubble.dart';
import 'widgets/direct_chat_input_bar.dart';

class DirectChatView extends StatelessWidget {
  final ChatItemModel chatItem;

  const DirectChatView({super.key, required this.chatItem});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ChangeNotifierProvider(
      create: (_) => DirectChatProvider()..init(chatItem),
      child: Consumer<DirectChatProvider>(
        builder: (context, provider, _) {
          return CommonBackground(
            showGrid: false,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: DirectChatAppBar(chatItem: provider.chatItem),
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
                            child: provider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF2563EB),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: provider.scrollController,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    itemCount: provider.messages.length,
                                    itemBuilder: (context, index) {
                                      final message = provider.messages[index];
                                      return DirectChatBubble(message: message);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                    DirectChatInputBar(
                      controller: provider.textController,
                      onSend: provider.sendMessage,
                      onSendImage: provider.sendImageMessage,
                      onSendVoice: provider.sendVoiceMessage,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
