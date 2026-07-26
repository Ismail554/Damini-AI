import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

class CommonBackground extends StatelessWidget {
  final Widget child;
  final bool showGrid;
  final bool topSafeArea;
  final bool bottomSafeArea;

  const CommonBackground({
    super.key,
    required this.child,
    this.showGrid = false,
    this.topSafeArea = true,
    this.bottomSafeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          );

    final gradientColors = isDark
        ? const [
            AppColors.darkBgStart,
            AppColors.darkBgCenter,
            AppColors.darkBgEnd,
          ]
        : const [
            AppColors.lightBgStart,
            AppColors.lightBgCenter,
            AppColors.lightBgEnd,
          ];

    final scaffoldBg = isDark ? AppColors.darkBgStart : AppColors.lightBgStart;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: Stack(
          children: [
            // Dynamic Gradient Background
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Ambient Neon Glow (Top Right)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                      blurRadius: 120,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

            // Ambient Neon Glow (Bottom Left)
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentCyan.withValues(
                        alpha: isDark ? 0.08 : 0.04,
                      ),
                      blurRadius: 100,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),

            // Optional Grid Overlay
            if (showGrid)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: CustomPaint(
                    painter: GridPainter(isDark: isDark),
                  ),
                ),
              ),

            // Screen Content
            SafeArea(
              top: topSafeArea,
              bottom: bottomSafeArea,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final bool isDark;

  GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF00C6FF) : const Color(0xFF006EDB)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double spacing = 40.0;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
