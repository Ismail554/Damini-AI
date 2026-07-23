import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F2238).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            title: "Personal Information",
            icon: Icons.person_outline_rounded,
            onTap: () {},
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          _buildMenuItem(
            title: "Saved Projects",
            icon: Icons.bookmark_border_rounded,
            onTap: () {},
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          _buildMenuItem(
            title: "Investment History",
            icon: Icons.trending_up_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: const Color(0xFF132B47),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20.r,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white.withValues(alpha: 0.4),
        size: 14.r,
      ),
    );
  }
}
