import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/app_colors.dart';
import '../widgets/dashed_upload_card.dart';

class CompanyVerificationScreen extends StatefulWidget {
  final String role;
  final bool isLoading;
  final void Function(Map<String, String> documents) onSubmit;
  final VoidCallback? onBack;

  const CompanyVerificationScreen({
    super.key,
    required this.role,
    this.isLoading = false,
    required this.onSubmit,
    this.onBack,
  });

  @override
  State<CompanyVerificationScreen> createState() => _CompanyVerificationScreenState();
}

class _CompanyVerificationScreenState extends State<CompanyVerificationScreen> {
  String? _licensePath;
  String? _taxDocPath;

  Future<void> _pickFile(bool isLicense) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          if (isLicense) {
            _licensePath = result.files.single.path;
          } else {
            _taxDocPath = result.files.single.path;
          }
        });
        return;
      }
    } catch (_) {
      // Fallback to ImagePicker if FilePicker had platform limitation
      try {
        final img = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (img != null) {
          setState(() {
            if (isLicense) {
              _licensePath = img.path;
            } else {
              _taxDocPath = img.path;
            }
          });
        }
      } catch (_) {}
    }
  }

  void _handleSubmit() {
    final docs = <String, String>{};
    if (_licensePath != null) docs['BUSINESS_LICENSE'] = _licensePath!;
    if (_taxDocPath != null) docs['TAX_DOCUMENT'] = _taxDocPath!;
    widget.onSubmit(docs);
  }

  String _getFileName(String? path) {
    if (path == null) return '';
    return path.split(RegExp(r'[\\/]')).last;
  }

  @override
  Widget build(BuildContext context) {
    final isSponsor = widget.role == 'sponsor';
    final hasAtLeastOneDoc = _licensePath != null || _taxDocPath != null;

    return Column(
      children: [
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
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSponsor
                      ? "Please upload your business verification documents to complete your sponsor onboarding."
                      : "Please provide company documentation to complete your corporate investor verification.",
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: AppColors.grey,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "Required Documents",
                  style: GoogleFonts.outfit(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                DashedUploadCard(
                  title: _licensePath != null
                      ? "Business License Selected"
                      : (isSponsor ? "Upload Business License" : "Upload Registration License"),
                  subtitle: _licensePath != null
                      ? _getFileName(_licensePath)
                      : "PDF, JPG or PNG (Max 5MB)",
                  icon: _licensePath != null ? Icons.check_circle_rounded : Icons.description_outlined,
                  onTap: () => _pickFile(true),
                ),
                SizedBox(height: 16.h),
                DashedUploadCard(
                  title: _taxDocPath != null ? "Tax Document Selected" : "Upload Tax Document",
                  subtitle: _taxDocPath != null
                      ? _getFileName(_taxDocPath)
                      : "PDF, JPG or PNG (Max 5MB)",
                  icon: _taxDocPath != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                  onTap: () => _pickFile(false),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: (!hasAtLeastOneDoc || widget.isLoading) ? null : _handleSubmit,
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
                      "Submit Verification",
                      style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
