import 'package:dio/dio.dart';
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
    final isOwner = state.participantDetails.isNotEmpty ? state.isOwner : (userRole == 'sponsor');

    return Scaffold(
      backgroundColor: const Color(0xFF061427),
      appBar: GroupChatAppBar(
        title: (state.projectTitle != null && state.projectTitle!.isNotEmpty)
            ? state.projectTitle
            : widget.projectTitle,
        activeMemberCount: state.activeMemberCount > 0
            ? state.activeMemberCount
            : (state.participantDetails.isNotEmpty
                ? state.participantDetails.length
                : state.participants.length),
        participants: state.participantDetails.isNotEmpty
            ? state.participantDetails.map((p) => p.name).toList()
            : state.participants,
        participantDetails: state.participantDetails,
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
            if (state.isKicked)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E2E),
                  border: Border(
                    top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Colors.orangeAccent, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "You are no longer a participant in this conversation.",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF8EB2C7),
                        fontSize: 12.5.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
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
    final participantDetails = ref.read(groupChatProvider).participantDetails;
    final removable = participantDetails.where((p) => !p.isOwner).toList();

    RemoveParticipantModal.show(
      context,
      participants: removable,
      onRemove: (participant) async {
        try {
          await ref.read(groupChatProvider.notifier).removeParticipant(
                participant.name,
                userId: participant.userId.toString(),
              );
          if (context.mounted) {
            CustomSnackBar.success(
              context,
              '${participant.name} has been removed from the group.',
            );
          }
        } catch (e) {
          if (context.mounted) {
            CustomSnackBar.error(
              context,
              _extractErrorMessage(e) ??
                  'Failed to remove ${participant.name}.',
            );
          }
        }
      },
    );
  }

  void _openReportModal(BuildContext context) {
    String selectedReason = 'SPAM';
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F1E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            "Report Group Chat",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select a reason for reporting:",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16253C),
                    borderRadius: BorderRadius.circular(10.r),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReason,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF16253C),
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 13.sp),
                      items: const [
                        DropdownMenuItem(value: 'SPAM', child: Text('Spam')),
                        DropdownMenuItem(
                            value: 'HARASSMENT', child: Text('Harassment')),
                        DropdownMenuItem(
                            value: 'SUSPICIOUS_ACTIVITY',
                            child: Text('Suspicious Activity')),
                        DropdownMenuItem(
                            value: 'FRAUD', child: Text('Fraud / Scam')),
                        DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedReason = val);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  "Description (optional):",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  style:
                      GoogleFonts.outfit(color: Colors.white, fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: "Add details about the issue...",
                    hintStyle: GoogleFonts.outfit(
                        color: const Color(0xFF6B8A9D), fontSize: 12.sp),
                    filled: true,
                    fillColor: const Color(0xFF16253C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: Color(0xFF006EDB)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child:
                  Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = selectedReason;
                final desc = descController.text.trim();
                Navigator.pop(dialogCtx);
                try {
                  await ref
                      .read(groupChatProvider.notifier)
                      .reportConversation(
                        reason: reason,
                        description: desc.isNotEmpty ? desc : null,
                      );
                  if (context.mounted) {
                    CustomSnackBar.success(
                      context,
                      "Report submitted successfully. Our team will review this chat.",
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    CustomSnackBar.error(
                      context,
                      _extractErrorMessage(e) ?? "Failed to submit report.",
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text("Report",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openLeaveModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Leave Group Chat",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          "Are you sure you want to leave this project group chat? You will no longer receive messages or updates.",
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13.5.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child:
                Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await ref.read(groupChatProvider.notifier).leaveConversation();
                if (context.mounted) {
                  CustomSnackBar.success(context, "You left the group chat.");
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  CustomSnackBar.error(
                    context,
                    _extractErrorMessage(e) ?? "Failed to leave group chat.",
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text("Leave",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
            offeredBudget:
                req.proposedBudget.isNotEmpty ? req.proposedBudget : '\$0',
            initials: _getInitials(req.investorName),
            avatarBg: colors[(colorIdx++) % colors.length],
          ),
        );
      }
    }

    for (final p in chatState.participantDetails) {
      if (!p.isOwner &&
          !availableInvestors.any(
              (inv) => inv.name.toLowerCase() == p.name.toLowerCase())) {
        availableInvestors.add(
          GroupMemberCardItem(
            id: p.userId.toString(),
            name: p.name,
            role: p.role.isNotEmpty ? p.role : 'Investor',
            offeredBudget: '\$0',
            initials: p.initials.isNotEmpty ? p.initials : _getInitials(p.name),
            avatarBg: colors[(colorIdx++) % colors.length],
          ),
        );
      }
    }

    if (chatState.participantDetails.isEmpty) {
      for (final p in chatState.participants) {
        if (!availableInvestors
            .any((inv) => inv.name.toLowerCase() == p.toLowerCase())) {
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
    }

    ConfirmInvestorModal.show(
      context,
      availableInvestors: availableInvestors,
      onConfirm: (contributions) async {
        if (contributions.isEmpty) return;

        // Synchronize with local project state
        final sponsorNotifier = ref.read(sponsorProjectProvider.notifier);
        for (final item in contributions) {
          sponsorNotifier.addContribution(item);
        }

        // Prepare backend payload
        final investorPayloads = contributions.map((c) {
          int invId = int.tryParse(c.id.split('_').first) ?? 0;
          if (invId == 0) {
            final match = chatState.participantDetails
                .where((p) => p.name.toLowerCase() == c.name.toLowerCase())
                .firstOrNull;
            invId = match?.userId ?? 0;
          }
          final cleanAmount = double.tryParse(
                  c.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              0.0;
          return {
            'investor_id': invId,
            'name': c.name,
            'confirmed_amount': cleanAmount,
            'share_percentage': 0.0,
            'notes': 'Confirmed via Group Chat',
          };
        }).toList();

        final effectiveProjectId = widget.projectId ?? chatState.projectId ?? 0;

        try {
          await ref.read(groupChatProvider.notifier).confirmInvestors(
                projectId: effectiveProjectId,
                investors: investorPayloads,
              );
          if (context.mounted) {
            CustomSnackBar.success(
              context,
              'Confirmed ${contributions.length} investor${contributions.length > 1 ? 's' : ''} successfully!',
            );
          }
        } catch (e) {
          if (context.mounted) {
            CustomSnackBar.error(
              context,
              _extractErrorMessage(e) ??
                  'Failed to confirm investors on server.',
            );
          }
        }
      },
    );
  }

  String? _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final resData = e.response?.data;
      if (resData is Map) {
        if (resData['message'] != null) return resData['message'].toString();
        if (resData['detail'] != null) return resData['detail'].toString();
        if (resData['error'] != null) return resData['error'].toString();
      }
      if (e.message != null && e.message!.isNotEmpty) return e.message;
    }
    return null;
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
