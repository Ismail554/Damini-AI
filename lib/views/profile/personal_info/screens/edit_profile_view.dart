import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/country_picker_field.dart';
import '../controllers/sponsor_edit_profile_provider.dart';
import '../models/sponsor_edit_profile_model.dart';
import '../widgets/profile_photo_uploader.dart';
import '../../../auth/session/controllers/session_provider.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  File? _profileImage;
  bool _isInitialized = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _locationController = TextEditingController();
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();

  // Company-only controllers
  final _companyController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _locationController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _companyController.dispose();
    _registrationNumberController.dispose();
    _businessAddressController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _populateFields(SponsorEditProfileModel profile) {
    if (_isInitialized) return;
    _nameController.text = profile.fullName == 'Member' ? '' : profile.fullName;
    _emailController.text = profile.email ?? '';
    _phoneController.text = profile.phone ?? '';
    _countryController.text = profile.country ?? '';
    _locationController.text = profile.location ?? '';
    _titleController.text = profile.positionTitle ?? '';
    _bioController.text = profile.bio ?? '';
    _companyController.text = profile.legalCompanyName ?? '';
    _registrationNumberController.text = profile.registrationNumber ?? '';
    _businessAddressController.text = profile.businessAddress ?? '';
    _websiteController.text = profile.companyWebsite ?? '';
    _isInitialized = true;
  }

  Future<void> _handleSave() async {
    final state = ref.read(sponsorEditProfileProvider);
    final profile = state.profile ?? const SponsorEditProfileModel();
    final isCompany = profile.isCompany;

    final updated = profile.copyWith(
      phone: _phoneController.text.trim(),
      country: _countryController.text.trim(),
      location: _locationController.text.trim(),
      positionTitle: _titleController.text.trim(),
      bio: _bioController.text.trim(),
      legalCompanyName: isCompany ? _companyController.text.trim() : null,
      registrationNumber:
          isCompany ? _registrationNumberController.text.trim() : null,
      businessAddress:
          isCompany ? _businessAddressController.text.trim() : null,
      companyWebsite: isCompany ? _websiteController.text.trim() : null,
    );

    final success =
        await ref.read(sponsorEditProfileProvider.notifier).saveProfile(
              updatedProfile: updated,
              fullName: _nameController.text.trim(),
              photoFile: _profileImage,
            );

    if (!mounted) return;

    if (success) {
      CustomSnackBar.success(context, "Profile updated successfully!");
      context.pop();
    } else {
      final err = ref.read(sponsorEditProfileProvider).error ??
          "Failed to update profile";
      CustomSnackBar.show(context, err, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(sponsorEditProfileProvider);

    ref.listen<SponsorEditProfileState>(sponsorEditProfileProvider,
        (prev, next) {
      if (next.profile != null && !_isInitialized) {
        _populateFields(next.profile!);
      }
    });

    if (state.profile != null && !_isInitialized) {
      _populateFields(state.profile!);
    }

    if (state.isLoading && !_isInitialized) {
      return CommonBackground(
        showGrid: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(tc),
          body: const Center(
            child: CircularProgressIndicator(color: Color(0xFF006EDB)),
          ),
        ),
      );
    }

    if (state.error != null && state.profile == null) {
      return CommonBackground(
        showGrid: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(tc),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48.r,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Failed to load profile",
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    state.error ?? "An unexpected error occurred",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      color: tc.textSecondary,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  CustomButton(
                    text: "Retry",
                    height: 44.h,
                    onPressed: () => ref
                        .read(sponsorEditProfileProvider.notifier)
                        .refresh(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final profile = state.profile ?? const SponsorEditProfileModel();
    final isCompany = profile.isCompany;

    final userRole = ref.watch(authProvider).userRole?.toLowerCase() ?? 'sponsor';
    final isInvestor = userRole == 'investor';

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(tc),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountBadge(profile, tc, isInvestor),
                Center(
                  child: ProfilePhotoUploader(
                    imageFile: _profileImage,
                    networkImageUrl: profile.profilePhotoUrl,
                    onImageChanged: (file) =>
                        setState(() => _profileImage = file),
                  ),
                ),
                SizedBox(height: 24.h),
                CustomTextField(
                  label: "Full Name",
                  hint: "e.g. John Doe",
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),
                CustomTextField(
                  label: "Email Address",
                  hint: "e.g. john@example.com",
                  controller: _emailController,
                  readOnly: true,
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
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: CountryPickerField(
                    label: "Country",
                    hint: "Select country",
                    controller: _countryController,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                CustomTextField(
                  label: "Location / City",
                  hint: "e.g. San Francisco, CA",
                  controller: _locationController,
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
                  textInputAction: isCompany
                      ? TextInputAction.next
                      : TextInputAction.done,
                ),
                if (isCompany) ...[
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.business_center_rounded,
                        size: 18.sp,
                        color: tc.textPrimary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Company Information",
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  CustomTextField(
                    label: "Legal Company Name",
                    hint: "e.g. Apex Ventures Ltd.",
                    controller: _companyController,
                    textInputAction: TextInputAction.next,
                  ),
                  CustomTextField(
                    label: "Registration Number",
                    hint: "e.g. RC-12345678",
                    controller: _registrationNumberController,
                    textInputAction: TextInputAction.next,
                  ),
                  CustomTextField(
                    label: "Business Address",
                    hint: "e.g. 100 Financial Way, Suite 400",
                    controller: _businessAddressController,
                    textInputAction: TextInputAction.next,
                  ),
                  CustomTextField(
                    label: "Company Website",
                    hint: "e.g. https://apexventures.com",
                    controller: _websiteController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                  ),
                ],
                SizedBox(height: 24.h),
                CustomButton(
                  text: "Save & Continue",
                  height: 52.h,
                  isLoading: state.isSaving,
                  variant: CustomButtonVariant.gradient,
                  onPressed: _handleSave,
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(AppThemeColors tc) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: tc.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        "Edit Profile",
        style: GoogleFonts.outfit(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: tc.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAccountBadge(
      SponsorEditProfileModel profile, AppThemeColors tc, bool isInvestor) {
    final isCompany = profile.isCompany;
    final status = profile.verificationStatus;
    Color statusColor;
    switch (status) {
      case 'APPROVED':
        statusColor = const Color(0xFF10B981);
        break;
      case 'REJECTED':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
    }

    final title = isInvestor
        ? (isCompany ? "Company Investor" : "Individual Investor")
        : (isCompany ? "Company Account" : "Individual Account");
    final subtitle = isInvestor
        ? (isCompany
            ? "Investing as a registered business entity"
            : "Investing as an individual investor")
        : (isCompany
            ? "Sponsoring as a registered business entity"
            : "Sponsoring as an individual member");

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF092444) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: isCompany
                  ? const Color(0xFF006EDB).withValues(alpha: 0.15)
                  : const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompany ? Icons.business_rounded : Icons.person_rounded,
              color:
                  isCompany ? const Color(0xFF006EDB) : const Color(0xFF10B981),
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: tc.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: tc.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              status,
              style: GoogleFonts.outfit(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
