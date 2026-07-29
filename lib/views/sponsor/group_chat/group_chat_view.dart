import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sponsor_project_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../chat/widgets/direct_chat_input_bar.dart';
import 'controllers/group_chat_provider.dart';
import 'widgets/confirm_investor_modal.dart';
import 'widgets/group_chat_ai_suggestions.dart';
import 'widgets/group_chat_app_bar.dart';
import 'widgets/group_chat_message_bubble.dart';
import 'widgets/remove_participant_modal.dart';

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
              activeMemberCount: provider.participants.length,
              onMenuSelected: (action) => _handleMenuAction(context, provider, action),
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
                  DirectChatInputBar(
                    controller: provider.messageController,
                    onSend: provider.sendMessage,
                    onSendImage: provider.sendImageMessage,
                    onSendVoice: provider.sendVoiceMessage,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleMenuAction(BuildContext context, GroupChatProvider provider, String action) {
    switch (action) {
      case 'confirm_investor':
        _openConfirmModal(context, provider);
        break;
      case 'remove_participant':
        _openRemoveParticipantModal(context, provider);
        break;
      case 'report':
        _openReportModal(context);
        break;
      case 'leave':
        _openLeaveModal(context);
        break;
    }
  }

  void _openRemoveParticipantModal(BuildContext context, GroupChatProvider provider) {
    RemoveParticipantModal.show(
      context,
      participants: provider.participants,
      onRemove: (name) {
        provider.removeParticipant(name);
        CustomSnackBar.success(context, '$name has been removed from the group.');
      },
    );
  }

  void _openReportModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1E2E),
        title: Text("Report Group Chat", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to report this group chat for review?", style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              CustomSnackBar.success(context, "Report submitted successfully. Our team will review this chat.");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent, foregroundColor: Colors.black),
            child: Text("Report", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openLeaveModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1E2E),
        title: Text("Leave Group Chat", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to leave this project group chat?", style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (context.mounted) {
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: Text("Leave", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
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
