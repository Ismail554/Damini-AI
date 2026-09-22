import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/app_colors.dart';
import '../../views/auth/widgets/labeled_text_field.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String role;
  final bool isCompany;
  final bool isLoading;
  final void Function(Map<String, dynamic> fields, String? photoPath) onSaved;
  final VoidCallback? onBack;

  const CompleteProfileScreen({
    super.key,
    required this.role,
    this.isCompany = false,
    this.isLoading = false,
    required this.onSaved,
    this.onBack,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _regNumberCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  String? _photoPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    _locationCtrl.dispose();
    _positionCtrl.dispose();
    _companyNameCtrl.dispose();
    _regNumberCtrl.dispose();
    _addressCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _photoPath = picked.path);
      }
    } catch (_) {}
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final fields = <String, dynamic>{
      'phone': _phoneCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
    };

    if (widget.isCompany) {
      if (_companyNameCtrl.text.trim().isNotEmpty) {
        fields['legal_company_name'] = _companyNameCtrl.text.trim();
      }
      if (_regNumberCtrl.text.trim().isNotEmpty) {
        fields['registration_number'] = _regNumberCtrl.text.trim();
      }
      if (_addressCtrl.text.trim().isNotEmpty) {
        fields['business_address'] = _addressCtrl.text.trim();
      }
      if (_websiteCtrl.text.trim().isNotEmpty) {
        fields['company_website'] = _websiteCtrl.text.trim();
      }
      if (_positionCtrl.text.trim().isNotEmpty) {
        fields['position_title'] = _positionCtrl.text.trim();
      }
    } else {
      if (_positionCtrl.text.trim().isNotEmpty) {
        fields['position_title'] = _positionCtrl.text.trim();
      }
    }

    widget.onSaved(fields, _photoPath);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top App Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30),
                onPressed: widget.onBack,
              ),
              SizedBox(width: 4.w),
              Text(
                widget.isCompany ? "Company Profile Details" : "Complete Your Profile",
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Scrollable Form
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _buildPhotoPicker()),
                  SizedBox(height: 24.h),

                  if (widget.isCompany) ...[
                    _buildSectionHeader("Company Information"),
                    SizedBox(height: 12.h),
                    LabeledTextField(
                      label: "Legal Company Name",
                      hint: "Acme Corp",
                      controller: _companyNameCtrl,
                      prefixIcon: const Icon(Icons.business_rounded, color: AppColors.grey, size: 20),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Enter company name" : null,
                    ),
                    SizedBox(height: 16.h),
                    LabeledTextField(
                      label: "Registration Number",
                      hint: "12345678",
                      controller: _regNumberCtrl,
                      prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.grey, size: 20),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Enter registration number" : null,
                    ),
                    SizedBox(height: 16.h),
                    LabeledTextField(
                      label: "Business Address",
                      hint: "123 Wall St",
                      controller: _addressCtrl,
                      prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.grey, size: 20),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Enter business address" : null,
                    ),
                    SizedBox(height: 16.h),
                    LabeledTextField(
                      label: "Company Website",
                      hint: "https://acme.com",
                      controller: _websiteCtrl,
                      keyboardType: TextInputType.url,
                      prefixIcon: const Icon(Icons.language_rounded, color: AppColors.grey, size: 20),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),
                    LabeledTextField(
                      label: "Position / Title",
                      hint: "CEO",
                      controller: _positionCtrl,
                      prefixIcon: const Icon(Icons.work_outline_rounded, color: AppColors.grey, size: 20),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 24.h),
                    _buildSectionHeader("Contact Details"),
                    SizedBox(height: 12.h),
                  ],

                  LabeledTextField(
                    label: "Phone Number",
                    hint: "+1234567890",
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.grey, size: 20),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Enter phone number" : null,
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: LabeledTextField(
                          label: "Country",
                          hint: "USA",
                          controller: _countryCtrl,
                          prefixIcon: const Icon(Icons.public_rounded, color: AppColors.grey, size: 20),
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty) ? "Enter country" : null,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: LabeledTextField(
                          label: "Location / City",
                          hint: "New York",
                          controller: _locationCtrl,
                          prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.grey, size: 20),
                          textInputAction: TextInputAction.done,
                          validator: (v) => (v == null || v.trim().isEmpty) ? "Enter location" : null,
                        ),
                      ),
                    ],
                  ),

                  if (!widget.isCompany) ...[
                    SizedBox(height: 16.h),
                    LabeledTextField(
                      label: "Position / Title (Optional)",
                      hint: "e.g. Angel Investor",
                      controller: _positionCtrl,
                      prefixIcon: const Icon(Icons.work_outline_rounded, color: AppColors.grey, size: 20),
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),

        // Bottom CTA Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.r)),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      "Save & Continue",
                      style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 92.r,
                height: 92.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F2238),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.45),
                    width: 2.w,
                  ),
                  image: _photoPath != null
                      ? DecorationImage(image: FileImage(File(_photoPath!)), fit: BoxFit.cover)
                      : null,
                ),
                child: _photoPath == null
                    ? Icon(Icons.person_outline_rounded, color: AppColors.grey, size: 46.r)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            _photoPath != null ? "Change Profile Photo" : "Upload Profile Photo",
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
