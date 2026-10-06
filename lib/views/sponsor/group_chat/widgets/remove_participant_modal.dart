import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/group_chat_header_model.dart';

class RemoveParticipantModal extends StatelessWidget {
  final List<GroupChatParticipant> participants;
  final Function(GroupChatParticipant participant) onRemove;

  const RemoveParticipantModal({
    super.key,
    required this.participants,
    required this.onRemove,
  });

  static Future<void> show(
    BuildContext context, {
    required List<GroupChatParticipant> participants,
    required Function(GroupChatParticipant participant) onRemove,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => RemoveParticipantModal(
        participants: participants,
        onRemove: onRemove,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Manage Participants (Owner)",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              "As the group owner, you can remove non-owner members from this project chat.",
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 16.h),
            if (participants.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text(
                    "No removable participants in this chat.",
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14.sp),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: participants.length,
                  separatorBuilder: (_, _) => Divider(
                    color: Colors.white.withValues(alpha: 0.08),
                    height: 16.h,
                  ),
                  itemBuilder: (context, index) {
                    final item = participants[index];
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: const Color(0xFF006EDB),
                          backgroundImage: item.avatarUrl != null &&
                                  item.avatarUrl!.isNotEmpty
                              ? NetworkImage(item.avatarUrl!)
                              : null,
                          child: (item.avatarUrl == null ||
                                  item.avatarUrl!.isEmpty)
                              ? Text(
                                  item.initials.isNotEmpty
                                      ? item.initials
                                      : (item.name.isNotEmpty
                                          ? item.name[0]
                                          : 'U'),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                item.role.isNotEmpty ? item.role : "Member",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF6B8A9D),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            onRemove(item);
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.person_remove_rounded, size: 16.r),
                          label: const Text("Remove"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.redAccent.withValues(alpha: 0.85),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
