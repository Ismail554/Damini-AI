import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'widgets/financials_section.dart';
import 'widgets/project_details_section.dart';
import 'widgets/project_dropdown_field.dart';
import 'widgets/project_form_field.dart';
import 'widgets/upload_box.dart';

class CreateProjectView extends StatefulWidget {
  const CreateProjectView({super.key});

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info Controllers
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _fullDescController = TextEditingController();
  final _minInvestmentController = TextEditingController();
  final _fundingGoalController = TextEditingController(text: '5000000');
  final _targetRoiController = TextEditingController(text: '18');

  // Details Controllers
  final _statusController = TextEditingController();
  final _milestonesController = TextEditingController();
  final _useOfFundsController = TextEditingController();
  final _sponsorInvestmentController = TextEditingController();

  // Financials Controllers
  final _minContributionController = TextEditingController();
  final _expectedRoiController = TextEditingController();
  final _monthlyRevenueController = TextEditingController();
  final _holdPeriodController = TextEditingController();
  final _timelineOpsController = TextEditingController();

  // Team & NDA Controllers
  final _teamMembersController = TextEditingController();
  final _ndaAgreementController = TextEditingController();

  // Dropdown States
  String? _selectedIndustry;
  String? _selectedCountry;
  String? _selectedFundingStage = 'Seed';
  String? _selectedTimeline = '36 months';

  bool _isPublishing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _fullDescController.dispose();
    _minInvestmentController.dispose();
    _fundingGoalController.dispose();
    _targetRoiController.dispose();
    _statusController.dispose();
    _milestonesController.dispose();
    _useOfFundsController.dispose();
    _sponsorInvestmentController.dispose();
    _minContributionController.dispose();
    _expectedRoiController.dispose();
    _monthlyRevenueController.dispose();
    _holdPeriodController.dispose();
    _timelineOpsController.dispose();
    _teamMembersController.dispose();
    _ndaAgreementController.dispose();
    super.dispose();
  }

  void _onPublish() async {
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isPublishing = false);
    CustomSnackBar.success(context, "Project published successfully!");
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(context, tc),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenHorizontal,
                  vertical: AppDimens.paddingSm,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UploadBox(
                        label: "Cover Image",
                        title: "Tap to upload cover",
                        subtitle: "16:9 recommended",
                        icon: Icons.image_outlined,
                        onTap: () {},
                      ),
                      SizedBox(height: AppDimens.spaceMd),
                      ProjectFormField(
                        label: "Project Title",
                        hint: "e.g. Downtown Tech Hub",
                        controller: _titleController,
                      ),
                      SizedBox(height: AppDimens.spaceMd),
                      ProjectFormField(
                        label: "Short Description",
                        hint: "One-line pitch (max 120 chars)",
                        controller: _shortDescController,
                      ),
                      SizedBox(height: AppDimens.spaceMd),
                      ProjectFormField(
                        label: "Full Description",
                        hint:
                            "Detailed explanation of the business model, market opportunity, and use of funds...",
                        controller: _fullDescController,
                        maxLines: 4,
                      ),
                      SizedBox(height: AppDimens.spaceMd),
                      ProjectFormField(
                        label: "Minimum Investment Amt",
                        hint: "e.g. 1000",
                        controller: _minInvestmentController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: AppDimens.spaceMd),
                      _buildDropdownRow(),
                      SizedBox(height: AppDimens.spaceMd),
                      _buildGoalRoiRow(),
                      SizedBox(height: AppDimens.spaceMd),
                      _buildStageTimelineRow(),
                      SizedBox(height: AppDimens.spaceLg),
                      ProjectDetailsSection(
                        statusController: _statusController,
                        milestonesController: _milestonesController,
                        useOfFundsController: _useOfFundsController,
                        sponsorInvestmentController:
                            _sponsorInvestmentController,
                      ),
                      SizedBox(height: AppDimens.spaceLg),
                      FinancialsSection(
                        minContributionController: _minContributionController,
                        expectedRoiController: _expectedRoiController,
                        monthlyRevenueController: _monthlyRevenueController,
                        holdPeriodController: _holdPeriodController,
                        timelineOpsController: _timelineOpsController,
                      ),
                      SizedBox(height: AppDimens.spaceLg),
                      ProjectFormField(
                        label: "Team members",
                        hint: "Names, comma separated",
                        controller: _teamMembersController,
                        prefixIcon: Icons.people_outline_rounded,
                      ),
                      SizedBox(height: AppDimens.spaceMd),
                      ProjectFormField(
                        label: "Confidentiality Agreement (Requires NDA)",
                        hint: "Detailed explanation...",
                        controller: _ndaAgreementController,
                        maxLines: 3,
                      ),
                      SizedBox(height: AppDimens.spaceMd),
                      UploadBox(
                        label: "Confidential Documents (Requires NDA)",
                        title: "Upload Pitch Deck & Financials",
                        icon: Icons.cloud_upload_outlined,
                        onTap: () {},
                      ),
                      SizedBox(height: AppDimens.spaceXxl),
                      _buildActionButtons(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, AppThemeColors tc) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.screenVertical,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: tc.buttonSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tc.borderColor,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: tc.textPrimary,
                    size: AppDimens.iconMd,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: AppDimens.spaceMd),
          Text(
            "Create Project",
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow() {
    return Row(
      children: [
        Expanded(
          child: ProjectDropdownField(
            label: "Industry",
            hint: "Select....",
            value: _selectedIndustry,
            items: const [
              "Technology",
              "Clean Energy",
              "Real Estate",
              "Healthcare",
              "Fintech"
            ],
            onChanged: (val) => setState(() => _selectedIndustry = val),
          ),
        ),
        SizedBox(width: AppDimens.spaceSm),
        Expanded(
          child: ProjectDropdownField(
            label: "Country",
            hint: "Select....",
            value: _selectedCountry,
            items: const [
              "United States",
              "United Kingdom",
              "Germany",
              "Canada",
              "Australia"
            ],
            onChanged: (val) => setState(() => _selectedCountry = val),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalRoiRow() {
    return Row(
      children: [
        Expanded(
          child: ProjectFormField(
            label: "Funding Goal (\$)",
            hint: "5000000",
            controller: _fundingGoalController,
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(width: AppDimens.spaceSm),
        Expanded(
          child: ProjectFormField(
            label: "Target ROI (%)",
            hint: "18",
            controller: _targetRoiController,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildStageTimelineRow() {
    return Row(
      children: [
        Expanded(
          child: ProjectDropdownField(
            label: "Funding Stage",
            hint: "Seed",
            value: _selectedFundingStage,
            items: const ["Pre-Seed", "Seed", "Series A", "Series B", "Growth"],
            onChanged: (val) => setState(() => _selectedFundingStage = val),
          ),
        ),
        SizedBox(width: AppDimens.spaceSm),
        Expanded(
          child: ProjectDropdownField(
            label: "Timeline",
            hint: "36 months",
            value: _selectedTimeline,
            items: const ["12 months", "24 months", "36 months", "48 months"],
            onChanged: (val) => setState(() => _selectedTimeline = val),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Save Draft",
                variant: CustomButtonVariant.outlined,
                onPressed: () {
                  CustomSnackBar.info(context, "Draft saved");
                },
              ),
            ),
            SizedBox(width: AppDimens.spaceSm),
            Expanded(
              child: CustomButton(
                text: "Preview",
                variant: CustomButtonVariant.outlined,
                onPressed: () {
                  context.push('/public-view');
                },
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimens.spaceMd),
        CustomButton(
          text: "Publish project",
          variant: CustomButtonVariant.primary,
          isLoading: _isPublishing,
          onPressed: _onPublish,
        ),
      ],
    );
  }
}
