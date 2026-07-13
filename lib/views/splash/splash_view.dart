import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Braintech/controllers/auth_provider.dart';
import 'package:Braintech/core/services/storage_service.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import 'package:Braintech/core/utils/asset_manager.dart';
import '../../core/widgets/common_background.dart';
import '../onboarding/onboarding_view.dart';
import '../auth/login_view.dart';
import '../home/home_view.dart';
import '../role_selection/role_selection_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _ctrl.forward();

    _ctrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final auth = context.read<AuthProvider>();
        final hasToken = await auth.checkAuthStatus();
        final hasSeenOnboarding = (await StorageService.getUuid()) != null;

        if (mounted) {
          Widget nextScreen;
          if (hasToken) {
            if (auth.userRole == null) {
              nextScreen = const RoleSelectionView();
            } else {
              nextScreen = const HomeView();
            }
          } else if (hasSeenOnboarding) {
            nextScreen = const LoginView();
          } else {
            nextScreen = const OnboardingView();
          }

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  nextScreen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      child: Stack(
        children: [
          // Background Label
          Positioned(
            left: -80.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  "Damini AI",
                  style: TextStyle(
                    fontSize: 84.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.02),
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),

          // Centered Brand Svg Logo & Text
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      IconAssets.app_logo,
                      width: 160.r,
                      height: 160.r,
                    ),
                    SizedBox(height: 20.h),
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
