import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import 'package:Braintech/shared/global_key.dart';
import 'package:Braintech/views/auth/login/models/login_request_model.dart';
import 'package:Braintech/views/auth/providers/social_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import 'social_auth_button.dart';

/// Social authentication section containing Google and Apple Sign-In buttons
/// and an optional divider.
///
/// Features:
/// - Works out of the box with zero parameters configured: clicks trigger
///   full Google or Apple authentication, state management, and navigation.
/// - Supports custom [onGooglePressed] and [onApplePressed] callbacks if parents
///   need bespoke behavior.
/// - Allows overriding loading states via [isGoogleLoading] / [isAppleLoading].
/// - Disables both buttons while any authentication is in progress to prevent races.
/// - Provides optional [onAuthSuccess] and [onAuthError] callbacks.
class SocialAuthSection extends ConsumerWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final bool? isGoogleLoading;
  final bool? isAppleLoading;
  final bool enabled;
  final bool showDivider;
  final bool dividerAtTop;
  final String dividerText;
  final void Function(LoginResponseModel response)? onAuthSuccess;
  final void Function(String error)? onAuthError;

  const SocialAuthSection({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
    this.isGoogleLoading,
    this.isAppleLoading,
    this.enabled = true,
    this.showDivider = true,
    this.dividerAtTop = false,
    this.dividerText = "or continue with",
    this.onAuthSuccess,
    this.onAuthError,
  });

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final response =
        await ref.read(socialAuthProvider.notifier).signInWithGoogle();
    if (!context.mounted) return;

    if (response != null) {
      if (response.success) {
        if (onAuthSuccess != null) {
          onAuthSuccess!(response);
        } else {
          _handleNavigation(context, response);
        }
      } else {
        final error = response.message ?? "Google sign-in failed";
        if (onAuthError != null) {
          onAuthError!(error);
        } else {
          CustomSnackBar.show(context, error, isError: true);
        }
      }
    } else {
      // User cancelled sign-in prompt
      if (onAuthError == null) {
        CustomSnackBar.show(
          context,
          "Google sign-in was cancelled.",
          isError: false,
        );
      }
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context, WidgetRef ref) async {
    final response =
        await ref.read(socialAuthProvider.notifier).signInWithApple();
    if (!context.mounted) return;

    if (response != null) {
      if (response.success) {
        if (onAuthSuccess != null) {
          onAuthSuccess!(response);
        } else {
          _handleNavigation(context, response);
        }
      } else {
        final error = response.message ?? "Apple sign-in failed";
        if (onAuthError != null) {
          onAuthError!(error);
        } else {
          CustomSnackBar.show(context, error, isError: true);
        }
      }
    } else {
      // User cancelled sign-in prompt
      if (onAuthError == null) {
        CustomSnackBar.show(
          context,
          "Apple sign-in was cancelled.",
          isError: false,
        );
      }
    }
  }

  void _handleNavigation(BuildContext context, LoginResponseModel response) {
    if (response.message != null && response.message!.isNotEmpty) {
      CustomSnackBar.show(context, response.message!);
    }

    final rawRole = response.role?.trim().toUpperCase();
    final normalizedRole = response.role?.trim().toLowerCase();

    if (rawRole == 'NONE' ||
        rawRole == null ||
        !GlobalKeys.isValidRole(normalizedRole)) {
      context.go('/role-selection');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemeColors.of(context);
    final socialState = ref.watch(socialAuthProvider);

    final effectiveGoogleLoading =
        isGoogleLoading ?? socialState.isGoogleLoading;
    final effectiveAppleLoading = isAppleLoading ?? socialState.isAppleLoading;
    final isAnyLoading = effectiveGoogleLoading || effectiveAppleLoading;
    final canInteract = enabled && !isAnyLoading;

    final VoidCallback? googleCallback = canInteract
        ? (onGooglePressed ?? () => _handleGoogleSignIn(context, ref))
        : null;

    final VoidCallback? appleCallback = canInteract
        ? (onApplePressed ?? () => _handleAppleSignIn(context, ref))
        : null;

    final dividerWidget = Row(
      children: [
        Expanded(child: Divider(color: colors.greenPillBg)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            dividerText,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: AppColors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.greenPillBg)),
      ],
    );

    return Column(
      children: [
        if (showDivider && dividerAtTop) ...[
          dividerWidget,
          AppSpacing.h16,
        ],
        SocialAuthButton.google(
          onPressed: googleCallback,
          isLoading: effectiveGoogleLoading,
        ),
        AppSpacing.h12,
        SocialAuthButton.apple(
          onPressed: appleCallback,
          isLoading: effectiveAppleLoading,
        ),
        if (showDivider && !dividerAtTop) ...[
          AppSpacing.h12,
          dividerWidget,
        ],
      ],
    );
  }
}
