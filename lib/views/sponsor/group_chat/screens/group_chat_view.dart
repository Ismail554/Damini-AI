import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../project_details/controllers/sponsor_project_details_provider.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import '../../chat/widgets/direct_chat_input_bar.dart';
import '../controllers/group_chat_provider.dart';
import '../widgets/confirm_investor_modal.dart';
import '../widgets/group_chat_ai_suggestions.dart';
import '../widgets/group_chat_app_bar.dart';
import '../widgets/group_chat_message_bubble.dart';
import '../widgets/remove_participant_modal.dart';

class GroupChatView extends ConsumerStatefulWidget {
  final String? projectTitle;
  final int? conversationId;
  final int? projectId;

  const GroupChatView({
    super.key,
    this.projectTitle,
    this.conversationId,
    this.projectId,
  });

  @override
  ConsumerState<GroupChatView> createState() => _GroupChatViewState();
}

class _GroupChatViewState extends ConsumerState<GroupChatView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupChatProvider.notifier).init(
            conversationId: widget.conversationId?.toString(),
            projectId: widget.projectId,
            projectTitle: widget.projectTitle,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupChatProvider);
    final notifier = ref.read(groupChatProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF061427),
      appBar: GroupChatAppBar(
        title: widget.projectTitle,
        activeMemberCount: state.participants.length,
        onMenuSelected: (action) =>
            _handleMenuAction(context, ref, action),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF006EDB),
                      ),
                    )
                  : ListView.builder(
                      controller: notifier.scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        return GroupChatMessageBubble(message: message);
                      },
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
                      color: const Color(0xFF006EDB),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            GroupChatAiSuggestions(
              suggestions: state.suggestions,
              onSelect: notifier.onSuggestionTap,
            ),
            DirectChatInputBar(
              controller: notifier.messageController,
              onSend: notifier.sendMessage,
              onSendImage: notifier.sendImageMessage,
              onSendVoice: notifier.sendVoiceMessage,
              onTyping: notifier.onTyping,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) {
    switch (action) {
      case 'confirm_investor':
        _openConfirmModal(context, ref);
        break;
      case 'remove_participant':
        _openRemoveParticipantModal(context, ref);
        break;
      case 'report':
        _openReportModal(context);
        break;
      case 'leave':
        _openLeaveModal(context);
        break;
    }
  }

  void _openRemoveParticipantModal(BuildContext context, WidgetRef ref) {
    final participants = ref.read(groupChatProvider).participants;
    RemoveParticipantModal.show(
      context,
      participants: participants,
      onRemove: (name) {
        ref.read(groupChatProvider.notifier).removeParticipant(name);
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

  void _openConfirmModal(
    BuildContext context,
    WidgetRef ref,
  ) {
    ConfirmInvestorModal.show(
      context,
      onConfirm: (contributions) {
        if (contributions.isEmpty) return;
        final sponsorNotifier = ref.read(sponsorProjectProvider.notifier);
        for (final item in contributions) {
          sponsorNotifier.addContribution(item);
        }

        final names = contributions.map((c) => c.name).join(', ');
        final amount = contributions.first.amount;

        ref.read(groupChatProvider.notifier).addSystemMessage(
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
