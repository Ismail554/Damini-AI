import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_button.dart';
import 'widgets/nda_agreement_card.dart';
import 'widgets/nda_document_attachment_card.dart';
import 'widgets/nda_header.dart';
import 'widgets/nda_signature_section.dart';

class NdaView extends StatefulWidget {
  final String disclosingParty;

  const NdaView({
    super.key,
    this.disclosingParty = "Acme Corp",
  });

  @override
  State<NdaView> createState() => _NdaViewState();
}

class _NdaViewState extends State<NdaView> {
  final _signatureController = TextEditingController();
  bool _isAgreed = false;

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

  bool get _canSubmit =>
      _isAgreed && _signatureController.text.trim().isNotEmpty;

  void _handleSubmit() {
    if (!_canSubmit) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "NDA successfully signed!",
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    context.pop(true);
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
                      onDownload: () {},
                    ),
                    SizedBox(height: AppDimens.spaceXl),
                    NdaSignatureSection(
                      isAgreed: _isAgreed,
                      onAgreementChanged: (val) {
                        setState(() => _isAgreed = val ?? false);
                      },
                      signatureController: _signatureController,
                      onUploadSignature: () {},
                    ),
                    SizedBox(height: AppDimens.spaceXl),
                  ],
                ),
              ),
            ),

            // Bottom Submit Button
            Container(
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
              child: Opacity(
                opacity: _canSubmit ? 1.0 : 0.5,
                child: CustomButton(
                  text: "Submit & Sign NDA",
                  variant: CustomButtonVariant.gradient,
                  width: double.infinity,
                  onPressed: _canSubmit ? _handleSubmit : () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
