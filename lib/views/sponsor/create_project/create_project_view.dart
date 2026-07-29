import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'controllers/project_draft_provider.dart';
import 'models/project_draft_model.dart';
import 'widgets/additional_images_section.dart';
import 'widgets/ai_prompt_modal.dart';
import 'widgets/financials_section.dart';
import 'widgets/project_details_section.dart';
import 'widgets/project_dropdown_field.dart';
import 'widgets/project_form_field.dart';
import 'widgets/upload_box.dart';

class CreateProjectView extends StatefulWidget {
  final ProjectDraftModel? initialDraft;
  final bool autoOpenAiModal;

  const CreateProjectView({
    super.key,
    this.initialDraft,
    this.autoOpenAiModal = false,
  });

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final _formKey = GlobalKey<FormState>();
  String? _draftId;

  // Basic Info Controllers
  late final TextEditingController _titleController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _fullDescController;
  late final TextEditingController _minInvestmentController;
  late final TextEditingController _fundingGoalController;
  late final TextEditingController _targetRoiController;

  // Details Controllers
  late final TextEditingController _statusController;
  late final TextEditingController _milestonesController;
  late final TextEditingController _useOfFundsController;
  late final TextEditingController _sponsorInvestmentController;

  // Financials Controllers
  late final TextEditingController _minContributionController;
  late final TextEditingController _expectedRoiController;
  late final TextEditingController _monthlyRevenueController;
  late final TextEditingController _holdPeriodController;
  late final TextEditingController _timelineOpsController;

  // Team & NDA Controllers
  late final TextEditingController _teamMembersController;
  late final TextEditingController _ndaAgreementController;

  // Dropdown States
  String? _selectedIndustry;
  String? _selectedCountry;
  String? _selectedFundingStage;
  String? _selectedTimeline;

  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDraft;
    _draftId = d?.id;

    _titleController = TextEditingController(text: d?.title ?? '');
    _shortDescController = TextEditingController(text: d?.shortDesc ?? '');
    _fullDescController = TextEditingController(text: d?.fullDesc ?? '');
    _minInvestmentController =
        TextEditingController(text: d?.minInvestment ?? '');
    _fundingGoalController =
        TextEditingController(text: d?.fundingGoal ?? '5000000');
    _targetRoiController = TextEditingController(text: d?.targetRoi ?? '18');

    _statusController = TextEditingController(text: d?.status ?? '');
    _milestonesController = TextEditingController(text: d?.milestones ?? '');
    _useOfFundsController = TextEditingController(text: d?.useOfFunds ?? '');
    _sponsorInvestmentController =
        TextEditingController(text: d?.sponsorInvestment ?? '');

    _minContributionController =
        TextEditingController(text: d?.minContribution ?? '');
    _expectedRoiController = TextEditingController(text: d?.expectedRoi ?? '');
    _monthlyRevenueController =
        TextEditingController(text: d?.monthlyRevenue ?? '');
    _holdPeriodController = TextEditingController(text: d?.holdPeriod ?? '');
    _timelineOpsController = TextEditingController(text: d?.timelineOps ?? '');

    _teamMembersController = TextEditingController(text: d?.teamMembers ?? '');
    _ndaAgreementController =
        TextEditingController(text: d?.ndaAgreement ?? '');

    _selectedIndustry = d?.industry;
    _selectedCountry = d?.country;
    _selectedFundingStage = d?.fundingStage ?? 'Seed';
    _selectedTimeline = d?.timeline ?? '36 months';

    if (widget.autoOpenAiModal) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final aiDraft = await AiPromptModal.show(context);
        if (aiDraft != null && mounted) {
          _applyAiDraft(aiDraft);
        }
      });
    } else if (d != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          CustomSnackBar.success(
            context,
            "AI suggested field data loaded! You can edit any details below.",
          );
        }
      });
    }
  }

  void _applyAiDraft(ProjectDraftModel d) {
    setState(() {
      _titleController.text = d.title;
      _shortDescController.text = d.shortDesc;
      _fullDescController.text = d.fullDesc;
      _minInvestmentController.text = d.minInvestment;
      _fundingGoalController.text = d.fundingGoal;
      _targetRoiController.text = d.targetRoi;
      _statusController.text = d.status;
      _milestonesController.text = d.milestones;
      _useOfFundsController.text = d.useOfFunds;
      _sponsorInvestmentController.text = d.sponsorInvestment;
      _minContributionController.text = d.minContribution;
      _expectedRoiController.text = d.expectedRoi;
      _monthlyRevenueController.text = d.monthlyRevenue;
      _holdPeriodController.text = d.holdPeriod;
      _timelineOpsController.text = d.timelineOps;
      _teamMembersController.text = d.teamMembers;
      _ndaAgreementController.text = d.ndaAgreement;

      _selectedIndustry = d.industry;
      _selectedCountry = d.country;
      _selectedFundingStage = d.fundingStage;
      _selectedTimeline = d.timeline;
    });
    CustomSnackBar.success(
      context,
      "AI suggested field data populated! You can edit any details.",
    );
  }

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

  void _onSaveDraft() async {
    final title = _titleController.text.trim().isEmpty
        ? "Untitled Project Draft"
        : _titleController.text.trim();

    final draft = ProjectDraftModel(
      id: _draftId ?? 'draft_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      shortDesc: _shortDescController.text,
      fullDesc: _fullDescController.text,
      minInvestment: _minInvestmentController.text,
      fundingGoal: _fundingGoalController.text,
      targetRoi: _targetRoiController.text,
      industry: _selectedIndustry,
      country: _selectedCountry,
      fundingStage: _selectedFundingStage ?? 'Seed',
      timeline: _selectedTimeline ?? '36 months',
      status: _statusController.text,
      milestones: _milestonesController.text,
      useOfFunds: _useOfFundsController.text,
      sponsorInvestment: _sponsorInvestmentController.text,
      minContribution: _minContributionController.text,
      expectedRoi: _expectedRoiController.text,
      monthlyRevenue: _monthlyRevenueController.text,
      holdPeriod: _holdPeriodController.text,
      timelineOps: _timelineOpsController.text,
      teamMembers: _teamMembersController.text,
      ndaAgreement: _ndaAgreementController.text,
      lastEdited: 'Last edited just now',
    );

    await context.read<ProjectDraftProvider>().saveDraft(draft);
    if (!mounted) return;
    CustomSnackBar.success(context, "Draft saved to Sponsor Dashboard!");
    context.go('/home');
  }

  void _onPreview() {
    final title = _titleController.text.trim().isEmpty
        ? "Untitled Project Preview"
        : _titleController.text.trim();

    final draft = ProjectDraftModel(
      id: _draftId ?? 'preview_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      shortDesc: _shortDescController.text,
      fullDesc: _fullDescController.text,
      minInvestment: _minInvestmentController.text,
      fundingGoal: _fundingGoalController.text,
      targetRoi: _targetRoiController.text,
      industry: _selectedIndustry,
      country: _selectedCountry,
      fundingStage: _selectedFundingStage ?? 'Seed',
      timeline: _selectedTimeline ?? '36 months',
      status: _statusController.text,
      milestones: _milestonesController.text,
      useOfFunds: _useOfFundsController.text,
      sponsorInvestment: _sponsorInvestmentController.text,
      minContribution: _minContributionController.text,
      expectedRoi: _expectedRoiController.text,
      monthlyRevenue: _monthlyRevenueController.text,
      holdPeriod: _holdPeriodController.text,
      timelineOps: _timelineOpsController.text,
      teamMembers: _teamMembersController.text,
      ndaAgreement: _ndaAgreementController.text,
      lastEdited: 'Preview Mode',
    );

    context.push('/public-view', extra: draft);
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
                      const AdditionalImagesSection(),
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
                            "Detailed explanation of the business model...",
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
    final titleText =
        widget.initialDraft != null ? "Edit Draft" : "Create Project";

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
            titleText,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final aiDraft = await AiPromptModal.show(context);
              if (aiDraft != null && mounted) {
                _applyAiDraft(aiDraft);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF9333EA).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFC026D3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: const Color(0xFFC026D3), size: 16.r),
                  SizedBox(width: 4.w),
                  Text(
                    "AI Fill",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
                onPressed: _onSaveDraft,
              ),
            ),
            SizedBox(width: AppDimens.spaceSm),
            Expanded(
              child: CustomButton(
                text: "Preview",
                variant: CustomButtonVariant.outlined,
                onPressed: _onPreview,
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
