import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_theme_colors.dart';

class DaminiAiInteractiveHeader extends StatefulWidget implements PreferredSizeWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;
  final bool isTyping;
  final VoidCallback onReset;

  const DaminiAiInteractiveHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
    required this.isTyping,
    required this.onReset,
  });

  @override
  Size get preferredSize => Size.fromHeight(115.h);

  @override
  State<DaminiAiInteractiveHeader> createState() => _DaminiAiInteractiveHeaderState();
}

class _DaminiAiInteractiveHeaderState extends State<DaminiAiInteractiveHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final progress = (widget.currentStep / widget.totalSteps).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: tc.isDark
            ? const Color(0xFF07192F).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: tc.borderColor.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: tc.textPrimary,
                      size: 22.r,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  
                  // Animated Pulsing Avatar
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.08);
                      final glowOpacity = 0.2 + (_pulseController.value * 0.3);

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 44.r * scale,
                            height: 44.r * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF9333EA).withValues(alpha: glowOpacity * 0.5),
                            ),
                          ),
                          // Inner glow ring
                          Container(
                            width: 38.r * (1.0 + (_pulseController.value * 0.04)),
                            height: 38.r * (1.0 + (_pulseController.value * 0.04)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFC026D3).withValues(alpha: glowOpacity),
                                  const Color(0xFF9333EA).withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          // Core Avatar Icon
                          Container(
                            width: 36.r,
                            height: 36.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9333EA), Color(0xFFC026D3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9333EA).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 20.r,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(width: 12.w),

                  // Info Title & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Damini Advisor",
                              style: GoogleFonts.outfit(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: tc.textPrimary,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9333EA).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: const Color(0xFFC026D3).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                "PRO AI",
                                style: GoogleFonts.outfit(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFC026D3),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            _buildSoundWaveIndicator(widget.isTyping),
                            SizedBox(width: 6.w),
                            Text(
                              widget.isTyping ? "Generating proposal..." : widget.stepTitle,
                              style: GoogleFonts.outfit(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: widget.isTyping
                                    ? const Color(0xFFC026D3)
                                    : tc.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Reset Button
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: tc.textSecondary,
                      size: 20.r,
                    ),
                    tooltip: "Reset Advisor",
                    onPressed: widget.onReset,
                  ),
                ],
              ),
            ),

            // Step Progress Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "STEP ${widget.currentStep} OF ${widget.totalSteps}",
                        style: GoogleFonts.outfit(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9333EA),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        "${(progress * 100).toInt()}% Complete",
                        style: GoogleFonts.outfit(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: tc.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Stack(
                      children: [
                        Container(
                          height: 4.h,
                          width: double.infinity,
                          color: tc.borderColor.withValues(alpha: 0.2),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          height: 4.h,
                          width: MediaQuery.of(context).size.width * progress,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF006EDB), Color(0xFF9333EA), Color(0xFFC026D3)],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSoundWaveIndicator(bool isActive) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isActive
          ? SizedBox(
              width: 14.w,
              height: 12.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (i) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final waveHeight = 4.h +
                          (math.sin((_pulseController.value * math.pi * 2) + (i * 1.5)) + 1) *
                              4.h;
                      return Container(
                        width: 2.5.w,
                        height: waveHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC026D3),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      );
                    },
                  );
                }),
              ),
            )
          : Container(
              width: 7.r,
              height: 7.r,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}
