import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupMemberCardItem {
  final String id;
  final String name;
  final String role;
  final String offeredBudget;
  final String initials;
  final Color avatarBg;

  const GroupMemberCardItem({
    required this.id,
    required this.name,
    required this.role,
    required this.offeredBudget,
    required this.initials,
    required this.avatarBg,
  });
}

class GroupMemberCard extends StatelessWidget {
  final GroupMemberCardItem member;
  final bool isSelected;
  final VoidCallback onTap;

  const GroupMemberCard({
    super.key,
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF006EDB).withValues(alpha: 0.15)
              : const Color(0xFF071424),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF006EDB)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF006EDB) : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF006EDB)
                      : Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15.sp,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            // Avatar
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: member.avatarBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  member.initials,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Member Name & Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    member.role,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF6B8A9D),
                      fontSize: 11.5.sp,
                    ),
                  ),
                ],
              ),
            ),
            // Offered Budget Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3326),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Offered',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF6B8A9D),
                      fontSize: 9.sp,
                    ),
                  ),
                  Text(
                    member.offeredBudget,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF10B981),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
