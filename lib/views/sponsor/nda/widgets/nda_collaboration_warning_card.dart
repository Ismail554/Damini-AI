import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../public_view/models/project_public_view_model.dart';

class NdaCollaborationWarningCard extends StatelessWidget {
  final String message;
  final ProjectPublicViewModel? project;
  final VoidCallback? onCollaborationSubmitted;

  const NdaCollaborationWarningCard({
    super.key,
    required this.message,
    this.project,
    this.onCollaborationSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppDimens.spaceLg),
      padding: EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withValues(alpha: tc.isDark ? 0.15 : 0.9),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: tc.isDark ? Colors.amber[200] : const Color(0xFF92400E),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceMd),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: "Request Collaboration",
              variant: CustomButtonVariant.gradient,
              height: 38.h,
              onPressed: () async {
                final res = await context.push<bool>(
                  '/request-collaboration',
                  extra: project,
                );
                if (res == true && onCollaborationSubmitted != null) {
                  onCollaborationSubmitted!();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
