import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_snackbar.dart';
import 'widgets/nda_agreement_card.dart';
import 'widgets/nda_document_attachment_card.dart';
import 'widgets/nda_header.dart';
import 'widgets/nda_signature_section.dart';

class NdaView extends StatefulWidget {
  final String disclosingParty;

  const NdaView({super.key, this.disclosingParty = "Acme Corp"});

  @override
  State<NdaView> createState() => _NdaViewState();
}

class _NdaViewState extends State<NdaView> {
  final _signatureController = TextEditingController();
  bool _isAgreed = false;
  String? _signatureFileName;

  @override
  void initState() {
    super.initState();
    _signatureController.addListener(_onSignatureChanged);
  }

  @override
  void dispose() {
    _signatureController.removeListener(_onSignatureChanged);
    _signatureController.dispose();
    super.dispose();
  }

  void _onSignatureChanged() {
    setState(() {});
  }

  Future<void> _pickSignatureImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final tc = AppThemeColors.of(context);
          final isDark = tc.isDark;

          return Container(
            padding: EdgeInsets.all(AppDimens.screenHorizontal),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F2238) : Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusXl),
              ),
              border: Border(
                top: BorderSide(
                  color: tc.borderColor,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: AppDimens.spaceMd),
                    decoration: BoxDecoration(
                      color: tc.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  Text(
                    "Upload Signature",
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceLg),
                  ListTile(
                    leading: Icon(
                      Icons.photo_library_outlined,
                      color: tc.textPrimary,
                    ),
                    title: Text(
                      "Choose Image from Gallery",
                      style: GoogleFonts.outfit(
                        color: tc.textPrimary,
                        fontSize: 14.sp,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.camera_alt_outlined,
                      color: tc.textPrimary,
                    ),
                    title: Text(
                      "Take Photo with Camera",
                      style: GoogleFonts.outfit(
                        color: tc.textPrimary,
                        fontSize: 14.sp,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (source == null) return;

      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _signatureFileName = image.name);
        if (mounted) {
          CustomSnackBar.success(context, "Attached: ${image.name}");
        }
      }
    } catch (e) {
      debugPrint("Picker error: $e");
      if (mounted) {
        CustomSnackBar.error(context, "Failed to select signature file");
      }
    }
  }

  void _removeSignatureImage() {
    setState(() => _signatureFileName = null);
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return CommonBackground(
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
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenHorizontal,
                  vertical: AppDimens.spaceLg,
                ),
                child: Column(
                  children: [
                    NdaHeader(disclosingParty: widget.disclosingParty),
                    SizedBox(height: AppDimens.spaceXl),
                    const NdaAgreementCard(),
                    SizedBox(height: AppDimens.spaceLg),
                    NdaDocumentAttachmentCard(
                      onDownload: () {
                        CustomSnackBar.success(
                          context,
                          "Downloading NDA overview!",
                        );
                      },
                    ),
                    SizedBox(height: AppDimens.spaceXl),
                    NdaSignatureSection(
                      isAgreed: _isAgreed,
                      onAgreementChanged: (val) {
                        setState(() => _isAgreed = val ?? false);
                      },
                      signatureController: _signatureController,
                      uploadedFileName: _signatureFileName,
                      onUploadSignature: _pickSignatureImage,
                      onRemoveSignature: _removeSignatureImage,
                    ),
                    SizedBox(height: AppDimens.spaceXl),
                  ],
                ),
              ),
            ),

            // Bottom Edit / Submit Button
            SafeArea(
              child: Container(
                padding: EdgeInsets.all(AppDimens.screenHorizontal),
                decoration: BoxDecoration(
                  color: tc.cardBg,
                  border: Border(
                    top: BorderSide(
                      color: tc.borderColor,
                      width: AppDimens.borderThin,
                    ),
                  ),
                ),
                child: CustomButton(
                  text: "Edit",
                  icon: Icons.edit_outlined,
                  variant: CustomButtonVariant.gradient,
                  width: double.infinity,
                  height: 42.h,
                  onPressed: () => context.push('/edit-nda'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
