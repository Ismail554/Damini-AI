import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/custom_button.dart';

class SignNdaBottomBar extends StatelessWidget {
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const SignNdaBottomBar({
    super.key,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(AppDimens.screenHorizontal),
        decoration: BoxDecoration(
          color: tc.cardBg,
          border: Border(
            top: BorderSide(
              color: tc.borderColor,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Opacity(
          opacity: canSubmit ? 1.0 : 0.6,
          child: CustomButton(
            text: "Sign NDA",
            icon: Icons.draw_rounded,
            variant: CustomButtonVariant.gradient,
            width: double.infinity,
            height: 48.h,
            isLoading: isSubmitting,
            onPressed: () {
              if (canSubmit) {
                onSubmit();
              }
            },
          ),
        ),
      ),
    );
  }
}
