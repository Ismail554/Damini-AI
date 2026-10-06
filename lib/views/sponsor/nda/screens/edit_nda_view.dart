import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import 'package:Braintech/core/widgets/custom_button.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import 'package:Braintech/core/widgets/custom_text_field.dart';
import '../../../profile/company_verification/widgets/document_upload_card.dart';
import '../controllers/nda_provider.dart';

class EditNdaView extends ConsumerStatefulWidget {
  const EditNdaView({super.key});

  @override
  ConsumerState<EditNdaView> createState() => _EditNdaViewState();
}

class _EditNdaViewState extends ConsumerState<EditNdaView> {
  late final TextEditingController _explanationController;
  String? _uploadedDocName;
  String? _uploadedDocPath;

  @override
  void initState() {
    super.initState();
    final initialAgreement = ref.read(ndaProvider).agreement;
    _explanationController = TextEditingController(
      text: initialAgreement?.confidentialityTerms.isNotEmpty == true
          ? initialAgreement!.confidentialityTerms
          : "Detailed explanation....",
    );
    if (initialAgreement?.documentTitle.isNotEmpty == true) {
      _uploadedDocName = initialAgreement!.documentTitle;
    }
  }

  @override
  void dispose() {
    _explanationController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        setState(() {
          _uploadedDocName = file.name;
          _uploadedDocPath = file.path;
        });
        if (mounted) {
          CustomSnackBar.success(context, "Pitch Deck & Financials attached: ${file.name}");
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, "Could not select document: $e");
      }
    }
  }

  Future<void> _handleSave() async {
    final terms = _explanationController.text.trim();
    if (terms.isEmpty) {
      CustomSnackBar.error(context, "Please provide confidentiality explanation.");
      return;
    }

    final success = await ref.read(ndaProvider.notifier).updateSponsorNda(
      confidentialityTerms: terms,
      pitchDeckPath: _uploadedDocPath,
    );

    if (!mounted) return;

    if (success) {
      CustomSnackBar.success(context, "NDA details updated successfully!");
      context.pop(true);
    } else {
      final error = ref.read(ndaProvider).error ?? "Failed to update NDA terms";
      CustomSnackBar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final ndaState = ref.watch(ndaProvider);

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
                SizedBox(height: 16.h),
                DocumentUploadCard(
                  label: "Upload Pitch Deck & Financials",
                  icon: Icons.cloud_upload_outlined,
                  uploadedFileName: _uploadedDocName,
                  onTap: _pickDocument,
                ),
                SizedBox(height: 28.h),
                CustomButton(
                  text: "Update",
                  height: 52.h,
                  isLoading: ndaState.isSubmitting,
                  variant: CustomButtonVariant.gradient,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
