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
import '../widgets/group_member_card.dart';
import '../../../auth/session/controllers/session_provider.dart';
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
    final userRole = ref.watch(authProvider).userRole?.toLowerCase() ?? 'sponsor';
    final isOwner = userRole == 'sponsor';

    return Scaffold(
      backgroundColor: const Color(0xFF061427),
      appBar: GroupChatAppBar(
        title: widget.projectTitle,
        activeMemberCount: state.participants.length,
        participants: state.participants,
        isOwner: isOwner,
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
                  : state.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64.w,
                                height: 64.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF006EDB).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: const Color(0xFF006EDB),
                                  size: 30.sp,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                "No messages yet",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.w),
                                child: Text(
                                  "Start the conversation with your investors and project team.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF6B8A9D),
                                    fontSize: 12.5.sp,
                                  ),
                                ),
                              ),
                            ],
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
            if (state.suggestions.isNotEmpty)
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
    final projectState = ref.read(sponsorProjectProvider);
    final chatState = ref.read(groupChatProvider);

    final availableInvestors = <GroupMemberCardItem>[];
    final colors = [
      const Color(0xFF006EDB),
      const Color(0xFF7C3AED),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
    ];

    int colorIdx = 0;
    for (final req in projectState.approvedList) {
      if (req.investorName.isNotEmpty) {
        availableInvestors.add(
          GroupMemberCardItem(
            id: req.id,
            name: req.investorName,
            role: req.investorType.isNotEmpty ? req.investorType : 'Investor',
            offeredBudget: req.proposedBudget.isNotEmpty ? req.proposedBudget : '\$0',
            initials: _getInitials(req.investorName),
            avatarBg: colors[(colorIdx++) % colors.length],
          ),
        );
      }
    }

    for (final p in chatState.participants) {
      if (!availableInvestors.any((inv) => inv.name.toLowerCase() == p.toLowerCase())) {
        availableInvestors.add(
          GroupMemberCardItem(
            id: 'participant_${p.hashCode}',
            name: p,
            role: 'Participant',
            offeredBudget: '\$0',
            initials: _getInitials(p),
            avatarBg: colors[(colorIdx++) % colors.length],
          ),
        );
      }
    }

    ConfirmInvestorModal.show(
      context,
      availableInvestors: availableInvestors,
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

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }
}
