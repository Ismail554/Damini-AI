import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';
import '../../views/auth/widgets/labeled_text_field.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String role;
  final VoidCallback onSaved;
  final VoidCallback? onBack;

  const CompleteProfileScreen({
    super.key,
    required this.role,
    required this.onSaved,
    this.onBack,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _companyCtrl.dispose();
    _countryCtrl.dispose();
    _positionCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: widget.onBack,
              ),
              SizedBox(width: 8.w),
              Text(
                "Complete Profile",
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Form Fields
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Photo Upload Circle
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 90.r,
                              height: 90.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0F2238),
                                border: Border.all(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 1.5.w,
                                ),
                              ),
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.grey,
                                size: 44.r,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 16.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Upload Profile Photo",
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  LabeledTextField(
                    label: "Full Name",
                    hint: "Enter name",
                    controller: _fullNameCtrl,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Enter full name"
                        : null,
                  ),
                  SizedBox(height: 16.h),

                  LabeledTextField(
                    label: "Company Name",
                    hint: "e.g. Apex Ventures Ltd.",
                    controller: _companyCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Enter company name"
                        : null,
                  ),
                  SizedBox(height: 16.h),

                  LabeledTextField(
                    label: "Country",
                    hint: "Select country",
                    controller: _countryCtrl,
                    textInputAction: TextInputAction.next,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.grey,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  LabeledTextField(
                    label: "Position / Title",
                    hint: "e.g. CEO & Co-Founder",
                    controller: _positionCtrl,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 16.h),

                  LabeledTextField(
                    label: "Bio",
                    hint: "Tell us a bit about yourself and your experience...",
                    controller: _bioCtrl,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),

        // CTA Button
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
                "Save & Continue",
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
