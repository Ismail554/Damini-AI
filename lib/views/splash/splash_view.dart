import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Braintech/controllers/auth_provider.dart';
import 'package:Braintech/core/services/storage_service.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import '../../core/widgets/common_background.dart';
import '../onboarding/onboarding_view.dart';
import '../auth/login_view.dart';
import '../home/home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeText;
  late Animation<double> _scaleText;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeText = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );

    _scaleText = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)),
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
            nextScreen = const HomeView();
          } else if (hasSeenOnboarding) {
            nextScreen = const LoginView();
          } else {
            nextScreen = const OnboardingView();
          }

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
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
      showGrid: true,
      child: Stack(
        children: [
          // Screen 0 Design: Left Side Large Rotated Vertical Text "DiasporaVest"
          Positioned(
            left: -80.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  "DiasporaVest",
                  style: TextStyle(
                    fontSize: 84.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.025),
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),
          
          // Centered Brand Name
          Center(
            child: FadeTransition(
              opacity: _fadeText,
              child: ScaleTransition(
                scale: _scaleText,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      fontFamily: 'Outfit',
                    ),
                    children: const [
                      TextSpan(
                        text: "Diaspora",
                        style: TextStyle(color: AppColors.white),
                      ),
                      TextSpan(
                        text: "Vest",
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
