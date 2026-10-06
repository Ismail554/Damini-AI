import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/chat_item_model.dart';

class DirectChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatItemModel chatItem;

  const DirectChatAppBar({super.key, required this.chatItem});

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: tc.textPrimary, size: 22.r),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: GestureDetector(
        onTap: () => context.push(
          '/public-profile',
          extra: {
            'userId': chatItem.otherUserId,
            'name': chatItem.name,
            'avatarUrl': chatItem.avatarUrl,
          },
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: chatItem.avatarColor,
                    shape: BoxShape.circle,
                    image: chatItem.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(chatItem.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: chatItem.avatarUrl == null
                      ? Center(
                          child: Text(
                            chatItem.initials,
                            style: GoogleFonts.outfit(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                if (chatItem.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF061427),
                          width: 1.5.r,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    chatItem.name,
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    chatItem.isOnline ? "Online" : "Offline",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: tc.textPrimary,
            size: 22.r,
          ),
          color: tc.cardHero,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'info',
              child: Text(
                'View Info',
                style: GoogleFonts.outfit(color: tc.textPrimary),
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Text(
                'Clear Chat',
                style: GoogleFonts.outfit(color: tc.textPrimary),
              ),
            ),
          ],
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
