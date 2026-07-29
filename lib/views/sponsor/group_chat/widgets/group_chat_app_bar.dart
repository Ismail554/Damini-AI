import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final int activeMemberCount;
  final Function(String action)? onMenuSelected;

  const GroupChatAppBar({
    super.key,
    this.title,
    this.activeMemberCount = 3,
    this.onMenuSelected,
  });

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? 'Downtown Tech Hub || Group Chat with Ai';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      color: const Color(0xFF071B33),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 54.w,
              height: 32.h,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: _buildAvatarCircle(
                      bg: const Color(0xFF9333EA),
                      child: Text(
                        '☡',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14.w,
                    child: _buildAvatarCircle(
                      bg: const Color(0xFFC026D3),
                      child: Text(
                        'A',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 28.w,
                    child: _buildAvatarCircle(
                      bg: const Color(0xFF006EDB),
                      child: Text(
                        'DC',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '$activeMemberCount members active',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF6B8A9D),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
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
                PopupMenuItem(
                  value: 'confirm_investor',
                  child: Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: const Color(0xFF006EDB), size: 18.r),
                      SizedBox(width: 10.w),
                      Text("Confirm Investors", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.sp)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'remove_participant',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove_outlined, color: Colors.orangeAccent, size: 18.r),
                      SizedBox(width: 10.w),
                      Text("Remove Participant (Owner)", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.sp)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.flag_outlined, color: Colors.amberAccent, size: 18.r),
                      SizedBox(width: 10.w),
                      Text("Report Group", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.sp)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app_rounded, color: Colors.redAccent, size: 18.r),
                      SizedBox(width: 10.w),
                      Text("Leave Group", style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCircle({required Color bg, required Widget child}) {
    return Container(
      width: 26.w,
      height: 26.w,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF071B33), width: 1.5),
      ),
      child: Center(child: child),
    );
  }
}
