import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../sponsor/public_view/models/project_public_view_model.dart';

class RequestCollaborationScreen extends StatefulWidget {
  final ProjectPublicViewModel? project;

  const RequestCollaborationScreen({super.key, this.project});

  @override
  State<RequestCollaborationScreen> createState() =>
      _RequestCollaborationScreenState();
}

class _RequestCollaborationScreenState
    extends State<RequestCollaborationScreen> {
  late final ProjectPublicViewModel _project;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project ?? ProjectPublicViewModel.mockData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_amountController.text.trim().isEmpty) {
      CustomSnackBar.error(
        context,
        "Please enter your intended investment amount.",
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
    });

    CustomSnackBar.success(
      context,
      "Your collaboration request has been submitted to the sponsor!",
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return CommonBackground(
      showGrid: false,
      topSafeArea: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              _buildAppBar(context, topInset),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: AppDimens.screenHorizontal,
                    right: AppDimens.screenHorizontal,
                    top: AppDimens.spaceLg,
                    bottom: bottomInset > 0 ? bottomInset + 20.h : 36.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let's finalize your request",
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      _buildProjectCard(tc),
                      SizedBox(height: 24.h),
                      Text(
                        "How much are you willing to invest into this project?",
                        style: GoogleFonts.outfit(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildAmountInputField(tc),
                      SizedBox(height: 24.h),
                      Text(
                        "Leave a note for the sponsor",
                        style: GoogleFonts.outfit(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildNoteInputField(tc),
                      SizedBox(height: 32.h),
                      _buildSubmitButton(),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double topInset) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topInset + 6.h,
        bottom: 14.h,
        left: 8.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF062248),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 22.r,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            "Request Collaboration",
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(AppThemeColors tc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2240),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundImage: NetworkImage(
                  _project.imageUrls.isNotEmpty
                      ? _project.imageUrls.first
                      : "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop",
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _project.title,
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Sponsor: ${_project.sponsorName}",
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 13.r,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    _project.location,
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "I am a dedicated sponsor focused on identifying and supporting high-potential investment opportunities.",
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.35,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Target Raise",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _project.targetRaise,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "MIA",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _project.minContribution,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Target ROI",
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _project.targetRoi,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInputField(AppThemeColors tc) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF091F38),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 15.sp,
          ),
          decoration: InputDecoration(
            hintText: "e.g. 500000",
            hintStyle: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14.sp,
            ),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteInputField(AppThemeColors tc) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFF091F38),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 5,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          hintText: "Briefly describe your investment thesis for this project...",
          hintStyle: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14.sp,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF0066FF), Color(0xFF0044CC)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0066FF).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ),
          ),
          child: Text(
            _isSubmitted ? "Request Submitted!" : "Submit Request",
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
