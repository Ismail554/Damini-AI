import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseTypeScreen extends StatefulWidget {
  final String role;
  final ValueChanged<String>? onNext;
  final VoidCallback onBack;
  final bool isLoading;

  const ChooseTypeScreen({
    super.key,
    required this.role,
    this.onNext,
    required this.onBack,
    this.isLoading = false,
  });

  @override
  State<ChooseTypeScreen> createState() => _ChooseTypeScreenState();
}

class _ChooseTypeScreenState extends State<ChooseTypeScreen> {
  String _selectedType = 'Individual';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Account Type",
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "Select how you plan to operate as a ${widget.role.toUpperCase()}.",
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 32.h),

            // Individual Option Card
            _buildOptionCard(
              title: "Individual",
              subtitle: "Personal investor account for individual funding.",
              icon: Icons.person_outline_rounded,
              value: "Individual",
            ),
            SizedBox(height: 16.h),

            // Corporate / Entity Option Card
            _buildOptionCard(
              title: "Corporate Entity",
              subtitle: "Registered business, fund, or institutional investor.",
              icon: Icons.business_outlined,
              value: "Corporate",
            ),

            const Spacer(),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : () => widget.onNext?.call(_selectedType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006EDB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                ),
                child: widget.isLoading
                    ? SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        "Continue",
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedType == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1B2C).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF006EDB)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF006EDB)
                    : const Color(0xFF132B47),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: Colors.white, size: 24.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF006EDB),
                size: 22.r,
              ),
          ],
        ),
      ),
    );
  }
}
