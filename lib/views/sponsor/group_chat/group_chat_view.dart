import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sponsor_project_provider.dart';
import 'controllers/group_chat_provider.dart';
import 'widgets/confirm_investor_modal.dart';
import 'widgets/group_chat_ai_suggestions.dart';
import 'widgets/group_chat_app_bar.dart';
import 'widgets/group_chat_input_bar.dart';
import 'widgets/group_chat_message_bubble.dart';

class GroupChatView extends StatelessWidget {
  const GroupChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupChatProvider()..init(),
      child: Consumer<GroupChatProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF061427),
            appBar: GroupChatAppBar(
              onMenuPressed: () => _openConfirmModal(context, provider),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF006EDB),
                            ),
                          )
                        : ListView.builder(
                            controller: provider.scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            itemCount: provider.messages.length,
                            itemBuilder: (context, index) {
                              final message = provider.messages[index];
                              return GroupChatMessageBubble(message: message);
                            },
                          ),
                  ),
                  GroupChatAiSuggestions(
                    suggestions: provider.suggestions,
                    onSelect: provider.onSuggestionTap,
                  ),
                  GroupChatInputBar(
                    controller: provider.messageController,
                    onSend: provider.sendMessage,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openConfirmModal(BuildContext context, GroupChatProvider provider) {
    ConfirmInvestorModal.show(
      context,
      onConfirm: (contribution) {
        context.read<SponsorProjectProvider>().addContribution(contribution);
        provider.addSystemMessage(
          '🎉 ${contribution.name} was confirmed as an investor with ${contribution.amount} contribution!',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(
              '${contribution.name} added to project contributions!',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
