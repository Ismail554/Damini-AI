import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/group_chat_header_model.dart';

class GroupChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final int activeMemberCount;
  final List<String> participants;
  final List<GroupChatParticipant>? participantDetails;
  final Function(String action)? onMenuSelected;
  final bool isOwner;

  const GroupChatAppBar({
    super.key,
    this.title,
    this.activeMemberCount = 0,
    this.participants = const [],
    this.participantDetails,
    this.onMenuSelected,
    this.isOwner = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final displayTitle = (title != null && title!.trim().isNotEmpty)
        ? title!.trim()
        : 'Project Group Chat';

    return AppBar(
      backgroundColor: const Color(0xFF071B33),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64.h,
      leadingWidth: 44.w,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 22.sp,
        ),
        padding: EdgeInsets.only(left: 12.w),
      ),
      titleSpacing: 8.w,
      title: Row(
        children: [
          _buildAvatarStack(),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  activeMemberCount > 0
                      ? '$activeMemberCount ${activeMemberCount == 1 ? "member" : "members"} active'
                      : 'Group Discussion',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF6B8A9D),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (action) {
            if (onMenuSelected != null) {
              onMenuSelected!(action);
            }
          },
          color: const Color(0xFF0C1D2F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          icon: Icon(
            Icons.more_vert_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
          itemBuilder: (context) => [
            if (isOwner) ...[
              PopupMenuItem(
                value: 'confirm_investor',
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: const Color(0xFF006EDB),
                      size: 18.r,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "Confirm Investors",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove_participant',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_remove_outlined,
                      color: Colors.orangeAccent,
                      size: 18.r,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "Remove Participant (Owner)",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: Colors.amberAccent,
                    size: 18.r,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    "Report Group",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (!isOwner)
              PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(
                      Icons.exit_to_app_rounded,
                      color: Colors.redAccent,
                      size: 18.r,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "Leave Group",
                      style: GoogleFonts.outfit(
                        color: Colors.redAccent,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(width: 6.w),
      ],
    );
  }

  Widget _buildAvatarStack() {
    final colors = [
      const Color(0xFF9333EA),
      const Color(0xFF006EDB),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];

    final double avatarSize = 36.w;
    final double overlap = 20.w;

    if (participantDetails != null && participantDetails!.isNotEmpty) {
      final displayItems = participantDetails!.take(3).toList();
      final stackWidth = avatarSize + (displayItems.length - 1) * overlap;

      return SizedBox(
        width: stackWidth,
        height: avatarSize,
        child: Stack(
          children: [
            for (int i = 0; i < displayItems.length; i++)
              Positioned(
                left: i * overlap,
                child: _buildAvatarCircle(
                  size: avatarSize,
                  bg: colors[i % colors.length],
                  avatarUrl: displayItems[i].avatarUrl,
                  child: Text(
                    displayItems[i].initials.isNotEmpty
                        ? displayItems[i].initials
                        : _getInitials(displayItems[i].name),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (participants.isEmpty) {
      return Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: const Color(0xFF006EDB).withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF006EDB), width: 1.5),
        ),
        child: Center(
          child: Icon(
            Icons.groups_rounded,
            color: const Color(0xFF00C6FF),
            size: 20.sp,
          ),
        ),
      );
    }

    final displayItems = participants.take(3).toList();
    final stackWidth = avatarSize + (displayItems.length - 1) * overlap;

    return SizedBox(
      width: stackWidth,
      height: avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < displayItems.length; i++)
            Positioned(
              left: i * overlap,
              child: _buildAvatarCircle(
                size: avatarSize,
                bg: colors[i % colors.length],
                child: Text(
                  _getInitials(displayItems[i]),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
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

  Widget _buildAvatarCircle({
    required double size,
    required Color bg,
    required Widget child,
    String? avatarUrl,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF071B33), width: 1.5),
        image: avatarUrl != null && avatarUrl.isNotEmpty
            ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
            : null,
      ),
      child: (avatarUrl == null || avatarUrl.isEmpty)
          ? Center(child: child)
          : null,
    );
  }
}
