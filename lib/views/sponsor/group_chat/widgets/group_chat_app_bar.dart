import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;

  const GroupChatAppBar({
    super.key,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
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
            // Avatar Stack
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
            // Title & Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Downtown Tech Hub || Group Chat with Ai',
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
                    '3 members active',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF6B8A9D),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onMenuPressed,
              icon: Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
