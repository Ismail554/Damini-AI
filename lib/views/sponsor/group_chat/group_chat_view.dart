import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sponsor_project_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import 'controllers/group_chat_provider.dart';
import 'widgets/confirm_investor_modal.dart';
import 'widgets/group_chat_ai_suggestions.dart';
import 'widgets/group_chat_app_bar.dart';
import 'widgets/group_chat_input_bar.dart';
import 'widgets/group_chat_message_bubble.dart';

class GroupChatView extends StatelessWidget {
  final String? projectTitle;

  const GroupChatView({
    super.key,
    this.projectTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupChatProvider()..init(),
      child: Consumer<GroupChatProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF061427),
            appBar: GroupChatAppBar(
              title: projectTitle,
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
      onConfirm: (contributions) {
        if (contributions.isEmpty) return;
        final sponsorProvider = context.read<SponsorProjectProvider>();
        for (final item in contributions) {
          sponsorProvider.addContribution(item);
        }

        final names = contributions.map((c) => c.name).join(', ');
        final amount = contributions.first.amount;

        provider.addSystemMessage(
          '🎉 Confirmed investor${contributions.length > 1 ? 's' : ''}: $names with $amount budget each!',
        );

        CustomSnackBar.success(
          context,
          'Added ${contributions.length} investor${contributions.length > 1 ? 's' : ''} to project contributions!',
        );
      },
    );
  }
}
