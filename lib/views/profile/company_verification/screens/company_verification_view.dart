import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../widgets/document_upload_card.dart';

class CompanyVerificationView extends StatefulWidget {
  const CompanyVerificationView({super.key});

  @override
  State<CompanyVerificationView> createState() =>
      _CompanyVerificationViewState();
}

class _CompanyVerificationViewState extends State<CompanyVerificationView> {
  final _companyNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _businessLicenseFile;
  String? _taxDocumentFile;

  @override
  void dispose() {
    _companyNameController.dispose();
    _registrationNumberController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
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
            "Company Verification",
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
                Text(
                  "Please provide your company details to verify your sponsor account. This helps maintain a secure environment for our investors.",
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: tc.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20.h),
                CustomTextField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  label: "Legal Company Name",
                  hint: "e.g. Acme Corporation LLC",
                  controller: _companyNameController,
                ),
                CustomTextField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  label: "Registration Number",
                  hint: "e.g. REG-98765432",
                  controller: _registrationNumberController,
                ),
                CustomTextField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.streetAddress,
                  label: "Business Address",
                  hint: "e.g. 100 Innovation Way, Suite 400, Austin, TX",
                  controller: _addressController,
                  maxLines: 2,
                ),
                CustomTextField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.url,
                  label: "Company Website",
                  hint: "https://www.example.com",
                  controller: _websiteController,
                ),
                SizedBox(height: 8.h),
                DocumentUploadCard(
                  label: "Upload Business License",
                  icon: Icons.description_outlined,
                  uploadedFileName: _businessLicenseFile,
                  onTap: () {
                    setState(() => _businessLicenseFile = "business_license_doc.pdf");
                    CustomSnackBar.success(context, "Business License attached!");
                  },
                ),
                DocumentUploadCard(
                  label: "Upload Tax Document",
                  icon: Icons.cloud_upload_outlined,
                  uploadedFileName: _taxDocumentFile,
                  onTap: () {
                    setState(() => _taxDocumentFile = "tax_document_2025.pdf");
                    CustomSnackBar.success(context, "Tax Document attached!");
                  },
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  text: "Submit Verification",
                  height: 52.h,
                  variant: CustomButtonVariant.gradient,
                  onPressed: () {
                    CustomSnackBar.success(context, "Company verification submitted successfully!");
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
