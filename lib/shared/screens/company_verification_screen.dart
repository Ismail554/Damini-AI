import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';
import '../../views/auth/widgets/labeled_text_field.dart';
import '../widgets/dashed_upload_card.dart';

class CompanyVerificationScreen extends StatefulWidget {
  final String role;
  final VoidCallback onSubmit;
  final VoidCallback? onBack;

  const CompanyVerificationScreen({
    super.key,
    required this.role,
    required this.onSubmit,
    this.onBack,
  });

  @override
  State<CompanyVerificationScreen> createState() =>
      _CompanyVerificationScreenState();
}

class _CompanyVerificationScreenState
    extends State<CompanyVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _legalNameCtrl = TextEditingController();
  final _regNumCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  @override
  void dispose() {
    _legalNameCtrl.dispose();
    _regNumCtrl.dispose();
    _addressCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSponsor = widget.role == 'sponsor';

    return Column(
      children: [
        // Header Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: widget.onBack,
              ),
              SizedBox(width: 8.w),
              Text(
                isSponsor ? "Company Verification" : "Investor Verification",
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Form & Upload Section
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSponsor
                        ? "Please provide your company details to verify your sponsor account. This helps maintain a secure environment for our investors."
                        : "Please provide your verification documents to complete your investor account setup.",
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  LabeledTextField(
                    label: isSponsor ? "Legal Company Name" : "Entity / Investor Name",
                    hint: isSponsor ? "e.g. Acme Corporation LLC" : "e.g. Apex Global Ventures",
                    controller: _legalNameCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Enter name" : null,
                  ),
                  SizedBox(height: 16.h),

                  LabeledTextField(
                    label: "Registration Number",
                    hint: "e.g. 12345678",
                    controller: _regNumCtrl,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 16.h),

                  LabeledTextField(
                    label: "Business Address",
                    hint: "e.g. 100 Innovation Way, Suite 400, Austin, TX",
                    controller: _addressCtrl,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 16.h),

                  LabeledTextField(
                    label: "Company Website",
                    hint: "https://www.example.com",
                    controller: _websiteCtrl,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    "Required Documents",
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  DashedUploadCard(
                    title: isSponsor
                        ? "Upload Business License"
                        : "Upload Government ID / Passport",
                    subtitle: "PDF, JPG or PNG (Max 5MB)",
                    icon: Icons.description_outlined,
                    onTap: () {},
                  ),
                  SizedBox(height: 12.h),

                  DashedUploadCard(
                    title: "Upload Tax Document",
                    subtitle: "PDF, JPG or PNG (Max 5MB)",
                    icon: Icons.cloud_upload_outlined,
                    onTap: () {},
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),

        // Submit Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.r),
                ),
              ),
              child: Text(
                "Submit Verification",
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
