import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/company_verification_provider.dart';
import '../widgets/document_upload_card.dart';

class CompanyVerificationView extends ConsumerStatefulWidget {
  const CompanyVerificationView({super.key});

  @override
  ConsumerState<CompanyVerificationView> createState() =>
      _CompanyVerificationViewState();
}

class _CompanyVerificationViewState
    extends ConsumerState<CompanyVerificationView> {
  final _companyNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _businessLicenseFileName;
  String? _taxDocumentFileName;
  bool _hasInitialized = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _registrationNumberController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _populateFromState(CompanyVerificationState state) {
    if (_hasInitialized || state.isLoading) return;
    final v = state.verification;
    if (v.companyName.isNotEmpty) _companyNameController.text = v.companyName;
    if (v.registrationNumber.isNotEmpty) {
      _registrationNumberController.text = v.registrationNumber;
    }
    if (v.address.isNotEmpty) _addressController.text = v.address;
    if (v.website.isNotEmpty) _websiteController.text = v.website;

    if (v.businessLicensePath != null) {
      _businessLicenseFileName = v.businessLicensePath;
    }
    if (v.taxDocumentPath != null) {
      _taxDocumentFileName = v.taxDocumentPath;
    }
    _hasInitialized = true;
  }

  Future<void> _pickFile({required bool isLicense}) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        setState(() {
          if (isLicense) {
            _businessLicenseFileName = file.name;
          } else {
            _taxDocumentFileName = file.name;
          }
        });

        final notifier = ref.read(companyVerificationProvider.notifier);
        if (isLicense) {
          notifier.setBusinessLicense(file.path);
        } else {
          notifier.setTaxDocument(file.path);
        }

        if (mounted) {
          CustomSnackBar.success(
            context,
            "${isLicense ? 'Business License' : 'Tax Document'} selected: ${file.name}",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, "Could not select file: $e");
      }
    }
  }

  Future<void> _handleSubmit() async {
    final vState = ref.read(companyVerificationProvider);
    final hasLicense = vState.verification.businessLicensePath != null &&
        vState.verification.businessLicensePath!.isNotEmpty;
    final hasTax = vState.verification.taxDocumentPath != null &&
        vState.verification.taxDocumentPath!.isNotEmpty;

    if (!hasLicense && !hasTax) {
      CustomSnackBar.error(
        context,
        "Please select at least one verification document to upload.",
      );
      return;
    }

    final success = await ref
        .read(companyVerificationProvider.notifier)
        .submitVerification();

    if (!mounted) return;

    if (success) {
      CustomSnackBar.success(
        context,
        "Company verification submitted successfully!",
      );
      context.pop();
    } else {
      final error = ref.read(companyVerificationProvider).errorMessage ??
          "Failed to submit verification.";
      CustomSnackBar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(companyVerificationProvider);
    _populateFromState(state);

    final status = state.verification.status.toUpperCase();
    final isApproved = status == 'APPROVED';
    final isPending = status == 'PENDING';

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
                if (status.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isApproved
                            ? const Color(0xFF10B981).withValues(alpha: 0.4)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isApproved
                              ? Icons.verified_user_rounded
                              : Icons.hourglass_top_rounded,
                          color: isApproved
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            isApproved
                                ? "Your company is verified."
                                : "Verification Status: $status",
                            style: GoogleFonts.outfit(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: tc.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
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
                SizedBox(height: 12.h),
                DocumentUploadCard(
                  label: "Upload Business License",
                  icon: Icons.description_outlined,
                  uploadedFileName: _businessLicenseFileName,
                  onTap: () => _pickFile(isLicense: true),
                ),
                SizedBox(height: 8.h),
                DocumentUploadCard(
                  label: "Upload Tax Document",
                  icon: Icons.cloud_upload_outlined,
                  uploadedFileName: _taxDocumentFileName,
                  onTap: () => _pickFile(isLicense: false),
                ),
                SizedBox(height: 24.h),
                CustomButton(
                  text: "Submit Verification",
                  height: 52.h,
                  isLoading: state.isLoading,
                  variant: CustomButtonVariant.gradient,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
