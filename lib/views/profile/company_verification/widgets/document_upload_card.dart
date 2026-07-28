import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class DocumentUploadCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? uploadedFileName;
  final VoidCallback onTap;

  const DocumentUploadCard({
    super.key,
    required this.label,
    required this.icon,
    this.uploadedFileName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isUploaded = uploadedFileName != null;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Required Documents",
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: isUploaded
                    ? const Color(0xFF10B981)
                    : (tc.isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFF94A3B8)),
                radius: 12.r,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: tc.isDark
                      ? const Color(0xFF07172A).withValues(alpha: 0.6)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: isUploaded
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : (tc.isDark
                                ? const Color(0xFF122C4A)
                                : const Color(0xFFE2E8F0)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isUploaded ? Icons.check_circle_outline_rounded : icon,
                        color: isUploaded
                            ? const Color(0xFF10B981)
                            : const Color(0xFF2563EB),
                        size: 22.r,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      isUploaded ? uploadedFileName! : label,
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: tc.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isUploaded ? "Uploaded" : "PDF, JPG or PNG (Max 5MB)",
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: tc.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    const double dashWidth = 6;
    const double dashSpace = 4;
    double distance = 0.0;

    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
