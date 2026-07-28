import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../profile/company_verification/widgets/document_upload_card.dart';

class EditNdaView extends StatefulWidget {
  const EditNdaView({super.key});

  @override
  State<EditNdaView> createState() => _EditNdaViewState();
}

class _EditNdaViewState extends State<EditNdaView> {
  final _explanationController = TextEditingController(
    text: "Detailed explanation....",
  );
  String? _uploadedDocName;

  @override
  void dispose() {
    _explanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: tc.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "Non-Disclosure Agreement",
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: "Confidentiality Agreement (Requires NDA)",
                  hint: "Detailed explanation....",
                  controller: _explanationController,
                  maxLines: 4,
                ),
                SizedBox(height: 8.h),
                DocumentUploadCard(
                  label: "Upload Pitch Deck & Financials",
                  icon: Icons.cloud_upload_outlined,
                  uploadedFileName: _uploadedDocName,
                  onTap: () {
                    setState(() => _uploadedDocName = "Pitch_Deck_Financials_v2.pdf");
                    CustomSnackBar.success(context, "Pitch Deck & Financials attached!");
                  },
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  text: "Update",
                  height: 52.h,
                  variant: CustomButtonVariant.gradient,
                  onPressed: () {
                    CustomSnackBar.success(context, "NDA details updated successfully!");
                    context.pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
