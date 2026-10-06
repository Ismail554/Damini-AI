import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/utils/file_downloader.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../public_view/models/project_public_view_model.dart';
import '../controllers/sign_nda_provider.dart';
import '../widgets/nda_agreement_card.dart';
import '../widgets/nda_collaboration_warning_card.dart';
import '../widgets/nda_document_attachment_card.dart';
import '../widgets/nda_header.dart';
import '../widgets/nda_signature_section.dart';
import '../widgets/sign_nda_bottom_bar.dart';
import '../widgets/signature_source_sheet.dart';

class SignNdaView extends ConsumerStatefulWidget {
  final String projectId;
  final String disclosingParty;
  final ProjectPublicViewModel? project;

  const SignNdaView({
    super.key,
    required this.projectId,
    this.disclosingParty = "Acme Corp",
    this.project,
  });

  @override
  ConsumerState<SignNdaView> createState() => _SignNdaViewState();
}

class _SignNdaViewState extends ConsumerState<SignNdaView> {
  final _signatureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _signatureController.addListener(() {
      ref.read(signNdaProvider.notifier).setSignatureText(_signatureController.text);
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _pickSignatureImage() async {
    try {
      final source = await SignatureSourceSheet.show(context);
      if (source == null) return;
      final XFile? image = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (image != null && mounted) {
        ref.read(signNdaProvider.notifier).setSignatureImage(imagePath: image.path, fileName: image.name);
        CustomSnackBar.success(context, "Attached: ${image.name}");
      }
    } catch (_) {
      if (mounted) CustomSnackBar.error(context, "Failed to select signature file");
    }
  }

  Future<void> _handleSubmit() async {
    final result = await ref.read(signNdaProvider.notifier).submit(widget.projectId);
    if (!mounted) return;
    if (result.isSuccess) {
      CustomSnackBar.success(context, result.message);
      context.pop(true);
    } else {
      CustomSnackBar.error(context, result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(signNdaProvider);
    final isTerminated = widget.project?.stage.toLowerCase().contains('terminated') == true;

    return CommonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: tc.textPrimary),
            onPressed: () => context.pop(false),
          ),
          title: Text("Sign NDA",
              style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold, color: tc.textPrimary)),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: AppDimens.screenHorizontal, vertical: AppDimens.spaceLg),
                child: Column(
                  children: [
                    if (isTerminated) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppDimens.paddingMd),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          "⚠️ This project has been terminated. Non-disclosure agreements can no longer be signed.",
                          style: GoogleFonts.outfit(fontSize: 13.sp, color: const Color(0xFFDC2626), height: 1.35),
                        ),
                      ),
                      SizedBox(height: AppDimens.spaceMd),
                    ],
                    NdaHeader(disclosingParty: widget.disclosingParty),
                    SizedBox(height: AppDimens.spaceXl),
                    const NdaAgreementCard(),
                    SizedBox(height: AppDimens.spaceLg),
                    NdaDocumentAttachmentCard(
                      onDownload: () {
                        FileDownloader.downloadFile(
                          context,
                          url: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
                          suggestedName: "NDA_Overview_${widget.disclosingParty.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf",
                          extension: "pdf",
                        );
                      },
                    ),
                    SizedBox(height: AppDimens.spaceXl),
                    NdaSignatureSection(
                      isAgreed: state.isAgreed,
                      onAgreementChanged: (val) {
                        ref.read(signNdaProvider.notifier).toggleAgreement(val ?? false);
                      },
                      signatureController: _signatureController,
                      uploadedFileName: state.signatureFileName,
                      onUploadSignature: _pickSignatureImage,
                      onRemoveSignature: () {
                        ref.read(signNdaProvider.notifier).removeSignatureImage();
                      },
                    ),
                    SizedBox(height: AppDimens.spaceLg),
                    if (state.needsCollaborationRequest)
                      NdaCollaborationWarningCard(
                        message: state.errorMessage ?? "You must submit a collaboration request before signing the NDA.",
                        project: widget.project,
                        onCollaborationSubmitted: () {
                          ref.read(signNdaProvider.notifier).clearCollaborationPrecondition();
                          CustomSnackBar.success(context, "Collaboration request submitted! You can now sign the NDA.");
                        },
                      ),
                  ],
                ),
              ),
            ),
            SignNdaBottomBar(
              canSubmit: state.canSubmit && !isTerminated,
              isSubmitting: state.isSubmitting,
              onSubmit: _handleSubmit,
              onDisabledTap: () {
                if (isTerminated) {
                  CustomSnackBar.error(context, "This project is terminated and cannot accept NDAs.");
                } else if (!state.isAgreed) {
                  CustomSnackBar.warning(context, "Please check the agreement box to accept terms.");
                } else if (!state.canSubmit) {
                  CustomSnackBar.warning(context, "Please provide a signature or attach a signature image.");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
