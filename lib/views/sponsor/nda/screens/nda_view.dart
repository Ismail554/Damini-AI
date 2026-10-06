import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import 'package:Braintech/core/widgets/custom_button.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import '../../../../core/utils/file_downloader.dart';
import '../controllers/nda_provider.dart';
import '../widgets/nda_agreement_card.dart';
import '../widgets/nda_document_attachment_card.dart';
import '../widgets/nda_header.dart';
import '../widgets/nda_signature_section.dart';

class NdaView extends ConsumerStatefulWidget {
  final String disclosingParty;

  const NdaView({super.key, this.disclosingParty = "Acme Corp"});

  @override
  ConsumerState<NdaView> createState() => _NdaViewState();
}

class _NdaViewState extends ConsumerState<NdaView> {
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
    final ndaState = ref.watch(ndaProvider);
    final agreement = ndaState.agreement;

    final effectiveDisclosingParty = (agreement?.disclosingParty.isNotEmpty == true &&
            agreement!.disclosingParty != "Acme Corp")
        ? agreement.disclosingParty
        : widget.disclosingParty;

    final docTitle = agreement?.documentTitle ?? "Pitch_Deck_Financials.pdf";
    final docSize = agreement?.fileSize ?? "4.1 MB";
    final docUrl = (agreement?.documentUrl != null && agreement!.documentUrl!.isNotEmpty)
        ? agreement.documentUrl!
        : "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";

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
                    NdaHeader(disclosingParty: effectiveDisclosingParty),
                    SizedBox(height: AppDimens.spaceXl),
                    const NdaAgreementCard(),
                    SizedBox(height: AppDimens.spaceLg),
                    NdaDocumentAttachmentCard(
                      fileName: docTitle,
                      fileSize: "$docSize · Confidential",
                      onDownload: () {
                        FileDownloader.downloadFile(
                          context,
                          url: docUrl,
                          suggestedName:
                              "NDA_${effectiveDisclosingParty.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf",
                          extension: "pdf",
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
                  onPressed: () async {
                    final updated = await context.push<bool>('/edit-nda');
                    if (updated == true && mounted) {
                      ref.read(ndaProvider.notifier).refresh();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
