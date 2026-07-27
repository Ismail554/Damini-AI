import 'dart:ui';
import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/custom_button.dart';

class SponsorProjectBottomBar extends StatelessWidget {
  final VoidCallback onViewRequests;
  final VoidCallback onPublicView;
  final VoidCallback? onGroupChatWithAi;

  const SponsorProjectBottomBar({
    super.key,
    required this.onViewRequests,
    required this.onPublicView,
    this.onGroupChatWithAi,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenHorizontal,
            vertical: AppDimens.paddingMd,
          ),
          decoration: BoxDecoration(
            color: tc.navBg,
            border: Border(
              top: BorderSide(
                color: tc.borderColor,
                width: AppDimens.borderThin,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "View Requests",
                      icon: Icons.chat_bubble_outline_rounded,
                      variant: CustomButtonVariant.outlined,
                      backgroundColor: tc.cardInner,
                      borderColor: tc.borderColor,
                      textColor: tc.textPrimary,
                      onPressed: onViewRequests,
                    ),
                  ),
                  SizedBox(width: AppDimens.spaceMd),
                  Expanded(
                    child: CustomButton(
                      text: "Public View",
                      variant: CustomButtonVariant.outlined,
                      borderColor: tc.borderColor,
                      backgroundColor: tc.cardInner,
                      textColor: tc.textPrimary,
                      onPressed: onPublicView,
                    ),
                  ),
                ],
              ),
              AppSpacing.h8,
              CustomButton(
                text: "Group Chat with AI",
                variant: CustomButtonVariant.gradient,
                onPressed: onGroupChatWithAi ?? onPublicView,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

