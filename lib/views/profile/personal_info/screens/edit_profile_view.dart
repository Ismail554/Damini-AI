import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _nameController = TextEditingController(text: "John Doe");
  final _emailController = TextEditingController(text: "john@apexventures.com");
  final _phoneController = TextEditingController(text: "+1 (415) 555-0142");
  final _countryController = TextEditingController(text: "United States");
  final _locationController = TextEditingController(text: "San Francisco, CA");
  final _companyController = TextEditingController(text: "Apex Ventures Ltd.");
  final _titleController = TextEditingController(text: "CEO & Co-Founder");
  final _bioController = TextEditingController(
    text: "Tell us a bit about yourself and your experience...",
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _locationController.dispose();
    _companyController.dispose();
    _titleController.dispose();
    _bioController.dispose();
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
            "Complete Profile",
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
              children: [
                _buildPhotoUploadHeader(tc),
                SizedBox(height: 24.h),
                CustomTextField(
                  label: "Full Name",
                  hint: "e.g. John Doe",
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),
                CustomTextField(
                  label: "Email",
                  hint: "e.g. john@example.com",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                CustomTextField(
                  label: "Phone",
                  hint: "e.g. +1 (415) 555-0142",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                CustomTextField(
                  label: "Country",
                  hint: "Select country",
                  controller: _countryController,
                  isDropdown: true,
                  dropdownItems: const [
                    "United States",
                    "United Kingdom",
                    "Canada",
                    "Australia",
                    "Germany",
                    "United Arab Emirates",
                    "Singapore",
                  ],
                  onChanged: (_) => setState(() {}),
                ),
                CustomTextField(
                  label: "Location",
                  hint: "e.g. San Francisco, CA",
                  controller: _locationController,
                  textInputAction: TextInputAction.next,
                ),
                CustomTextField(
                  label: "Company Name",
                  hint: "e.g. Apex Ventures Ltd.",
                  controller: _companyController,
                  textInputAction: TextInputAction.next,
                ),
                CustomTextField(
                  label: "Position / Title",
                  hint: "e.g. CEO & Co-Founder",
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                ),
                CustomTextField(
                  label: "Bio",
                  hint: "Tell us a bit about yourself and your experience...",
                  controller: _bioController,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  text: "Save & Continue",
                  height: 52.h,
                  variant: CustomButtonVariant.gradient,
                  onPressed: () {
                    CustomSnackBar.success(context, "Profile updated successfully!");
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

  Widget _buildPhotoUploadHeader(AppThemeColors tc) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: tc.textTertiary.withValues(alpha: 0.4),
                  width: 1.5.w,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: tc.textTertiary,
                  size: 32.r,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14.r,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          "Upload Profile Photo",
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            color: tc.textTertiary,
          ),
        ),
      ],
    );
  }
}
