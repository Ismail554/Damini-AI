import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Braintech/views/auth/session/controllers/session_provider.dart';
import 'package:Braintech/core/utils/asset_manager.dart';
import '../../core/services/storage_service.dart';
import '../../core/widgets/common_background.dart';
import '../../shared/global_key.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView>
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
          final hasToken =
              await ref.read(authProvider.notifier).checkAuthStatus();
          final auth = ref.read(authProvider);

          if (hasToken && auth.isAuthenticated) {
            nextRoute =
                GlobalKeys.isValidRole(auth.userRole) ? '/home' : '/role-selection';
          } else {
            final hasSeen = await StorageService.hasSeenOnboarding();
            nextRoute = hasSeen ? '/login' : '/onboarding';
          }
        } catch (_) {
          nextRoute = '/login';
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
                      IconAssets.appLogo,
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
