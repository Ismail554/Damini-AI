import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:Braintech/controllers/auth_provider.dart';
import 'package:Braintech/core/utils/asset_manager.dart';
import '../../core/widgets/common_background.dart';
import '../../shared/global_key.dart';

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

    _ctrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        String nextRoute = '/onboarding';
        try {
          final auth = context.read<AuthProvider>();
          final hasToken = await auth.checkAuthStatus();

          if (hasToken && auth.isAuthenticated) {
            nextRoute =
                GlobalKeys.isValidRole(auth.userRole) ? '/home' : '/role-selection';
          } else {
            nextRoute = '/onboarding';
          }
        } catch (_) {
          nextRoute = '/onboarding';
        }

        if (mounted) {
          context.go(nextRoute);
        }
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      child:
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
                    AppSpacing.h20,
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
