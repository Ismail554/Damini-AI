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

    if (_positionCtrl.text.trim().isNotEmpty) {
      fields['position_title'] = _positionCtrl.text.trim();
    }

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
    }

    widget.onSaved(fields, _photoPath);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
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
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPhotoPicker(),
                  SizedBox(height: 24.h),
                  LabeledTextField(
                    label: "Phone Number",
                    hint: "+1 234 567 8900",
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Enter phone number" : null,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: LabeledTextField(
                          label: "Country",
                          hint: "e.g. USA",
                          controller: _countryCtrl,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty) ? "Enter country" : null,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: LabeledTextField(
                          label: "City / Location",
                          hint: "e.g. New York",
                          controller: _locationCtrl,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty) ? "Enter location" : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  LabeledTextField(
                    label: "Position / Title",
                    hint: "e.g. CEO / Investor",
                    controller: _positionCtrl,
                    textInputAction: widget.isCompany ? TextInputAction.next : TextInputAction.done,
                  ),
                  if (widget.isCompany) ...[
                    SizedBox(height: 16.h),
                    LabeledTextField(
                      label: "Legal Company Name",
                      hint: "e.g. Acme Corp LLC",
                      controller: _companyNameCtrl,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Enter company name" : null,
                    ),
                    SizedBox(height: 16.h),
                    LabeledTextField(
                      label: "Registration Number",
                      hint: "e.g. 12345678",
                      controller: _regNumberCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),
                    LabeledTextField(
                      label: "Business Address",
                      hint: "e.g. 123 Wall St",
                      controller: _addressCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),
                    LabeledTextField(
                      label: "Company Website",
                      hint: "https://acme.com",
                      controller: _websiteCtrl,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _pickImage,
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
                  border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.4), width: 1.5.w),
                  image: _photoPath != null
                      ? DecorationImage(image: FileImage(File(_photoPath!)), fit: BoxFit.cover)
                      : null,
                ),
                child: _photoPath == null
                    ? Icon(Icons.person_outline_rounded, color: AppColors.grey, size: 44.r)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                  child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _photoPath != null ? "Change Profile Photo" : "Upload Profile Photo",
            style: GoogleFonts.outfit(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
