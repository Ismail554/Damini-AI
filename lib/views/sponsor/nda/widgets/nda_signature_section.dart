import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../auth/widgets/labeled_text_field.dart';

class NdaSignatureSection extends StatelessWidget {
  final bool isAgreed;
  final ValueChanged<bool?> onAgreementChanged;
  final TextEditingController signatureController;
  final String? uploadedFileName;
  final VoidCallback onUploadSignature;
  final VoidCallback? onRemoveSignature;

  const NdaSignatureSection({
    super.key,
    required this.isAgreed,
    required this.onAgreementChanged,
    required this.signatureController,
    this.uploadedFileName,
    required this.onUploadSignature,
    this.onRemoveSignature,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Agreement Checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24.r,
              height: 24.r,
              child: Checkbox(
                value: isAgreed,
                onChanged: onAgreementChanged,
                activeColor: AppColors.primaryColor,
                side: BorderSide(color: tc.borderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: GestureDetector(
                onTap: () => onAgreementChanged(!isAgreed),
                child: Text(
                  "I have read and agree to the terms of this Non-Disclosure Agreement. I understand that I am legally bound by these terms.",
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: tc.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimens.spaceLg),

        // Typed Digital Signature Input Field
        LabeledTextField(
          label: "Digital Signature (Type your full name)",
          controller: signatureController,
          hint: "Enter your full legal name",
        ),
        SizedBox(height: AppDimens.spaceLg),

        // Upload Signature Header
        Text(
          "Upload Signature ( Optional )",
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: tc.textPrimary,
          ),
        ),
        SizedBox(height: AppDimens.spaceSm),

        // Show uploaded file card or upload dropzone
        if (uploadedFileName != null)
          Container(
            padding: EdgeInsets.all(AppDimens.paddingMd),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: AppColors.successGreen.withValues(alpha: 0.4),
                width: AppDimens.borderThin,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.successGreen,
                  size: 22.r,
                ),
                SizedBox(width: AppDimens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        uploadedFileName!,
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Signature image attached",
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRemoveSignature != null)
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: tc.textTertiary,
                      size: 18.r,
                    ),
                    onPressed: onRemoveSignature,
                  ),
              ],
            ),
          )
        else
          Material(
            color: tc.cardBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: InkWell(
              onTap: onUploadSignature,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                    color: tc.borderColor,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        color: AppColors.primaryColor,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Upload Your Signature",
                      style: GoogleFonts.outfit(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: tc.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "PDF, JPG or PNG (Max 5MB)",
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        color: tc.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
