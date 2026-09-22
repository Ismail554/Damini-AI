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
  String _selectedType = 'INDIVIDUAL';

  @override
  Widget build(BuildContext context) {
    final isSponsor = widget.role.toLowerCase() == 'sponsor';

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
            size: 20,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Account Type",
              style: GoogleFonts.outfit(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "Choose whether you will operate as an Individual or a Company.",
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            SizedBox(height: 32.h),

            // Individual Option Card
            _buildOptionCard(
              title: "Individual",
              subtitle: isSponsor
                  ? "Personal sponsor profile for individual projects and ventures."
                  : "Personal investor account for individual direct funding.",
              icon: Icons.person_outline_rounded,
              value: "INDIVIDUAL",
            ),
            SizedBox(height: 18.h),

            // Company Option Card
            _buildOptionCard(
              title: "Company",
              subtitle: isSponsor
                  ? "Registered business, enterprise, or corporate entity seeking investment."
                  : "Registered fund, family office, VC, or institutional investor.",
              icon: Icons.business_rounded,
              value: "COMPANY",
            ),

            const Spacer(),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: widget.isLoading
                    ? null
                    : () => widget.onNext?.call(_selectedType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006EDB),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27.r),
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF006EDB).withValues(alpha: 0.12)
              : const Color(0xFF0C1B2C).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF006EDB)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF006EDB).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF006EDB)
                    : const Color(0xFF132B47),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, color: Colors.white, size: 26.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5.sp,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF006EDB)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF006EDB)
                      : Colors.white.withValues(alpha: 0.3),
                  width: 2.w,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
