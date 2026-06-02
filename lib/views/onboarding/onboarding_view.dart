import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/common_background.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late AnimationController _hoverCtrl;

  late Animation<double> _slideBlueCard;
  late Animation<double> _slideDarkCard;
  late Animation<double> _fadeContent;
  late Animation<double> _fadeCards;

  @override
  void initState() {
    super.initState();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _slideBlueCard = Tween<double>(
      begin: -320.w,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutBack));

    _slideDarkCard = Tween<double>(
      begin: 320.w,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutBack));

    _fadeCards = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _fadeContent = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _hoverCtrl.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    await StorageService.saveUuid("completed_onboarding");
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Standard credit card ratio: 85.6 × 53.98 mm = 1.5858 : 1
    // On 375 design width: 265 wide, 167 tall
    final double cardW = 265.w;
    final double cardH = 167.h;

    // Stack height = card height + 72h vertical offset between the two cards
    final double stackH = cardH + 72.h;

    return CommonBackground(
      showGrid: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top spacer — roughly 10% of screen
          SizedBox(height: 60.h),

          // ── Card Stack ─────────────────────────────────────────────
          SizedBox(
            height: stackH,
            width: double.infinity,
            child: FadeTransition(
              opacity: _fadeCards,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Dark card: top-right, +8°
                  AnimatedBuilder(
                    animation: Listenable.merge([_slideCtrl, _hoverCtrl]),
                    builder: (context, _) {
                      final hover =
                          math.sin(_hoverCtrl.value * 2 * math.pi) * 5.h;
                      return Positioned(
                        // Bleeds ~20px off right edge so card feels full-width
                        right: -18.w + _slideDarkCard.value,
                        top: hover,
                        child: Transform.rotate(
                          angle: 8.0 * math.pi / 180,
                          child: _buildDarkCard(cardW, cardH),
                        ),
                      );
                    },
                  ),

                  // Blue card: bottom-left, -12°
                  AnimatedBuilder(
                    animation: Listenable.merge([_slideCtrl, _hoverCtrl]),
                    builder: (context, _) {
                      final hover =
                          math.cos(_hoverCtrl.value * 2 * math.pi) * 5.h;
                      return Positioned(
                        // Bleeds ~20px off left edge
                        left: -18.w + _slideBlueCard.value,
                        bottom: hover,
                        child: Transform.rotate(
                          angle: -12.0 * math.pi / 180,
                          child: _buildBlueCard(cardW, cardH),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // ── Bottom brand + CTA ──────────────────────────────────────
          FadeTransition(
            opacity: _fadeContent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      children: const [
                        TextSpan(
                          text: "Diaspora",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: "Vest",
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "A smart investment networking platform connecting sponsors and diaspora investors through project discovery.",
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      color: AppColors.grey,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 36.h),

                  // CTA
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _onGetStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.r),
                          ),
                        ),
                        child: Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BLUE SOLID CARD ───────────────────────────────────────────────
  Widget _buildBlueCard(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E85FF), Color(0xFF0048D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A7FFF).withOpacity(0.5),
            blurRadius: 30.r,
            spreadRadius: 0,
            offset: Offset(0, 14.h),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 14.r,
            offset: Offset(5.w, 7.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
      child: _buildCardContent(
        label: "Debit Card",
        amount: "\$3,826.90",
        cardNumber: "**** 7341",
        isGold: true,
        labelOpacity: 0.8,
        numberOpacity: 0.62,
        visaOpacity: 1.0,
      ),
    );
  }

  // ── DARK GLASSMORPHIC CARD ────────────────────────────────────────
  Widget _buildDarkCard(double w, double h) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        // Subtle blur — keeps text crisp but shows glass depth
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            // Solid-ish dark navy — matches reference (not transparent)
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1D3045).withOpacity(0.92),
                const Color(0xFF0C1A28).withOpacity(0.97),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.09),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 24.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
          child: _buildCardContent(
            label: "Debit Card",
            amount: "\$2,328.50",
            cardNumber: "**** 8543",
            isGold: false,
            labelOpacity: 0.72,
            numberOpacity: 0.50,
            visaOpacity: 0.88,
          ),
        ),
      ),
    );
  }

  // ── SHARED CARD CONTENT LAYOUT ────────────────────────────────────
  Widget _buildCardContent({
    required String label,
    required String amount,
    required String cardNumber,
    required bool isGold,
    required double labelOpacity,
    required double numberOpacity,
    required double visaOpacity,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            color: Colors.white.withOpacity(labelOpacity),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 5.h),
        // Amount — key info, must be crisp
        Text(
          amount,
          style: TextStyle(
            fontSize: 25.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        // Push chip + number to bottom
        const Spacer(),
        // EMV Chip
        _buildChip(isGold: isGold),
        SizedBox(height: 10.h),
        // Card number + VISA
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              cardNumber,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(numberOpacity),
                letterSpacing: 1.4,
              ),
            ),
            Text(
              "VISA",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(visaOpacity),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── EMV CHIP ──────────────────────────────────────────────────────
  Widget _buildChip({required bool isGold}) {
    return Container(
      width: 36.w,
      height: 26.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        gradient: isGold
            ? const LinearGradient(
                colors: [Color(0xFFECC96E), Color(0xFFB5882C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  const Color(0xFF8098AE).withOpacity(0.55),
                  const Color(0xFF4C6470).withOpacity(0.55),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: CustomPaint(painter: _ChipPainter()),
    );
  }
}

// ── CHIP GRID LINES ───────────────────────────────────────────────────
class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.28)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // 2 vertical dividers → 3 columns
    for (int i = 1; i <= 2; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 2), Offset(x, size.height - 2), paint);
    }
    // 1 horizontal divider → 2 rows
    final midY = size.height / 2;
    canvas.drawLine(Offset(2, midY), Offset(size.width - 2, midY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
