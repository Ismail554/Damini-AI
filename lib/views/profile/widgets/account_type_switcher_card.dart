import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountTypeSwitcherCard extends StatelessWidget {
  final String activeRole;
  final ValueChanged<String> onSwitchRole;

  const AccountTypeSwitcherCard({
    super.key,
    required this.activeRole,
    required this.onSwitchRole,
  });

  @override
  Widget build(BuildContext context) {
    final isInvestor = activeRole == 'investor';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2238).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF132B47),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.sync_alt_rounded,
                  color: Colors.white,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Account Type",
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Switch your active experience at any time",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Sponsor Card Option
          _buildRoleOption(
            title: "Sponsor",
            subtitle: "Publish projects & raise capital",
            icon: Icons.business_center_outlined,
            isActive: !isInvestor,
            onTap: () => onSwitchRole('sponsor'),
          ),
          SizedBox(height: 12.h),

          // Investor Card Option
          _buildRoleOption(
            title: "Investor",
            subtitle: "Discover & fund opportunities",
            icon: Icons.trending_up_rounded,
            isActive: isInvestor,
            onTap: () => onSwitchRole('investor'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: const Color(0xFF091626),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive
                ? const Color(0xFF10B981)
                : Colors.white.withValues(alpha: 0.08),
            width: isActive ? 1.5.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFF132B47),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF10B981) : Colors.white,
                size: 20.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            if (isActive)
              Row(
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: const Color(0xFF10B981),
                    size: 16.r,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "Active",
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              Text(
                "Switch",
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
