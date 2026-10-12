import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import 'package:Braintech/core/widgets/custom_button.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import '../controllers/create_project_provider.dart';
import '../controllers/project_draft_provider.dart';
import '../models/create_project_models.dart';
import '../models/project_draft_model.dart';
import '../../../role_selection/provider/onboarding_provider.dart';
import '../widgets/additional_images_section.dart';
import '../widgets/financials_section.dart';
import '../widgets/project_details_section.dart';
import '../widgets/project_dropdown_field.dart';
import '../widgets/project_form_field.dart';
import '../widgets/upload_box.dart';
import '../../../../core/widgets/country_picker_field.dart';
import '../../../profile/personal_info/controllers/personal_info_provider.dart';
import '../../dashboard/controllers/sponsor_dashboard_provider.dart';

class CreateProjectView extends ConsumerStatefulWidget {
  final ProjectDraftModel? initialDraft;

  const CreateProjectView({
    super.key,
    this.initialDraft,
  });

  @override
  ConsumerState<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends ConsumerState<CreateProjectView> {
  final _formKey = GlobalKey<FormState>();
  String? _draftId;

  // Basic Info Controllers
  late final TextEditingController _titleController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _fullDescController;
  late final TextEditingController _minInvestmentController;
  late final TextEditingController _fundingGoalController;
  late final TextEditingController _targetRoiController;
  late final TextEditingController _locationController;

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
  // File Upload States
  String? _coverImagePath;
  String? _confidentialDocPath;
  String? _confidentialDocName;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _coverImagePath = image.path;
        });
        if (mounted) {
          CustomSnackBar.success(context, "Cover image selected!");
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, "Could not select image: $e");
      }
    }
  }

  Future<void> _pickConfidentialDoc() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _confidentialDocPath = result.files.first.path;
          _confidentialDocName = result.files.first.name;
        });
        if (mounted) {
          CustomSnackBar.success(context, "Document selected: $_confidentialDocName");
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, "Could not select document: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final d = widget.initialDraft;
    _draftId = d?.id;

    _titleController = TextEditingController(text: d?.title ?? '');
    _shortDescController = TextEditingController(text: d?.shortDesc ?? '');
    _fullDescController = TextEditingController(text: d?.fullDesc ?? '');
    _minInvestmentController = TextEditingController(
      text: d?.minInvestment ?? '',
    );
    _fundingGoalController = TextEditingController(
      text: d?.fundingGoal ?? '5000000',
    );
    _targetRoiController = TextEditingController(text: d?.targetRoi ?? '18');
    final initialCountry = d?.country;
    _locationController = TextEditingController(
      text: (d?.location != null && d!.location.isNotEmpty)
          ? d.location
          : ((initialCountry != null && initialCountry.isNotEmpty)
              ? initialCountry
              : 'Austin, TX'),
    );

    _statusController = TextEditingController(text: d?.status ?? '');
    _milestonesController = TextEditingController(text: d?.milestones ?? '');
    _useOfFundsController = TextEditingController(text: d?.useOfFunds ?? '');
    _sponsorInvestmentController = TextEditingController(
      text: d?.sponsorInvestment ?? '',
    );

    _minContributionController = TextEditingController(
      text: d?.minContribution ?? '',
    );
    _expectedRoiController = TextEditingController(text: d?.expectedRoi ?? '');
    _monthlyRevenueController = TextEditingController(
      text: d?.monthlyRevenue ?? '',
    );
    _holdPeriodController = TextEditingController(text: d?.holdPeriod ?? '');
    _timelineOpsController = TextEditingController(text: d?.timelineOps ?? '');

    _teamMembersController = TextEditingController(text: d?.teamMembers ?? '');
    _ndaAgreementController = TextEditingController(
      text: d?.ndaAgreement ?? '',
    );

    _selectedIndustry = d?.industry;
    _selectedCountry = d?.country;
    _selectedFundingStage = _normalizeFundingStage(d?.fundingStage);
    _selectedTimeline = _normalizeTimeline(d?.timeline);
    _coverImagePath = d?.coverImagePath;

    if (d != null) {
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

  String _normalizeFundingStage(String? stage) {
    if (stage == null || stage.trim().isEmpty) return 'Seed';
    final trimmed = stage.trim();
    final lower = trimmed.toLowerCase();
    if (lower == 'pre-seed' || lower.contains('pre-seed') || lower.contains('pre seed')) {
      return 'Pre-Seed';
    }
    if (lower == 'seed' || lower.contains('seed')) {
      return 'Seed';
    }
    if (lower.contains('series a')) {
      return 'Series A';
    }
    if (lower.contains('series b')) {
      return 'Series B';
    }
    if (lower.contains('growth')) {
      return 'Growth';
    }
    return trimmed;
  }

  String _normalizeTimeline(String? timeline) {
    if (timeline == null || timeline.trim().isEmpty) return '36 months';
    final trimmed = timeline.trim();
    final lower = trimmed.toLowerCase();
    if (lower.contains('12')) return '12 months';
    if (lower.contains('24')) return '24 months';
    if (lower.contains('36')) return '36 months';
    if (lower.contains('48')) return '48 months';
    return trimmed;
  }


  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _fullDescController.dispose();
    _minInvestmentController.dispose();
    _fundingGoalController.dispose();
    _targetRoiController.dispose();
    _locationController.dispose();
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
      location: _locationController.text,
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
      coverImagePath: _coverImagePath,
      lastEditedMs: DateTime.now().millisecondsSinceEpoch,
    );

    await ref.read(projectDraftProvider.notifier).saveDraft(draft);
    if (!mounted) return;
    CustomSnackBar.success(context, "Draft saved to Sponsor Dashboard!");
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
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
      location: _locationController.text,
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
      coverImagePath: _coverImagePath,
      lastEdited: 'Preview Mode',
    );

    context.push('/public-view', extra: draft);
  }

  double _parseNumber(String text, [double fallback = 0.0]) {
    final clean = text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? fallback;
  }

  int _parseIntMonths(String text, [int fallback = 12]) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? fallback;
  }

  void _onPublish() async {
    final personal = ref.read(personalInfoProvider).info;
    final dashboardProfile = ref.read(sponsorDashboardProvider).userProfile;
    final rawStatus = (personal.verificationStatus ?? dashboardProfile?.verificationStatus ?? 'PENDING').trim().toUpperCase();

    if (rawStatus != 'APPROVED') {
      if (kDebugMode) {
        debugPrint('⚠️ [DEBUG] Sponsor verification status is "$rawStatus". Proceeding with publish in debug mode...');
      } else {
        final msg = rawStatus == 'REJECTED'
            ? "Your verification documents were rejected. Please update your documents to publish projects."
            : "Your verification is currently pending. A Sponsor cannot publish projects until status hits APPROVED.";
        CustomSnackBar.error(context, msg);
        return;
      }
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (kDebugMode) {
        debugPrint('╔═══════════════════════════════════════════════════════════');
        debugPrint('║ ❌ VALIDATION FAILED: Title is required');
        debugPrint('╚═══════════════════════════════════════════════════════════');
      }
      CustomSnackBar.error(context, "Please enter a project title");
      return;
    }
    final fundingGoal = _parseNumber(_fundingGoalController.text);
    if (fundingGoal <= 0) {
      if (kDebugMode) {
        debugPrint('╔═══════════════════════════════════════════════════════════');
        debugPrint('║ ❌ VALIDATION FAILED: Funding goal must be > 0');
        debugPrint('╚═══════════════════════════════════════════════════════════');
      }
      CustomSnackBar.error(context, "Please enter a valid funding goal");
      return;
    }

    final industriesList =
        ref.read(industriesProvider).whenOrNull(data: (d) => d) ?? [];
    String? industryId;
    if (_selectedIndustry != null && _selectedIndustry!.trim().isNotEmpty) {
      for (final ind in industriesList) {
        if (ind.name.toLowerCase() == _selectedIndustry!.trim().toLowerCase()) {
          industryId = ind.id.toString();
          break;
        }
      }
      industryId ??= widget.initialDraft?.industryId?.toString();
      industryId ??=
          industriesList.isNotEmpty ? industriesList.first.id.toString() : null;
    } else if (widget.initialDraft?.industryId != null) {
      industryId = widget.initialDraft!.industryId.toString();
    }

    final rawTeam = _teamMembersController.text.trim();
    final cleanTeam = rawTeam
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(', ');
    final teamMembersText = cleanTeam.isNotEmpty
        ? cleanTeam
        : "Core Founding & Executive Team";

    final request = CreateProjectRequestModel(
      title: title,
      shortDescription: _shortDescController.text.trim().isNotEmpty
          ? _shortDescController.text.trim()
          : title,
      businessDescription: _fullDescController.text.trim().isNotEmpty
          ? _fullDescController.text.trim()
          : (_shortDescController.text.trim().isNotEmpty
              ? _shortDescController.text.trim()
              : title),
      fundingGoal: fundingGoal,
      minimumInvestment: _parseNumber(_minInvestmentController.text, 1000.0),
      targetRoi: _parseNumber(_targetRoiController.text, 18.0),
      country: _selectedCountry ?? "United States",
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : (_selectedCountry ?? "Austin, TX"),
      industry: industryId,
      categoryIds: null,
      fundingStage: _selectedFundingStage ?? "Seed",
      timelineMonths: _parseIntMonths(_selectedTimeline ?? "36 months", 36),
      currentStatus: _statusController.text.trim().isNotEmpty
          ? _statusController.text.trim()
          : "Permits secured, planning phase",
      nextMilestones: _milestonesController.text.trim().isNotEmpty
          ? _milestonesController.text.trim()
          : "Initial architectural setup and capital deployment",
      useOfFunds: _useOfFundsController.text.trim().isNotEmpty
          ? _useOfFundsController.text.trim()
          : "Capital expenditure, operations, and scaling",
      skinInTheGame: _parseNumber(_sponsorInvestmentController.text, 0.0),
      potentialMonthlyRevenue:
          _parseNumber(_monthlyRevenueController.text, 0.0),
      holdPeriodMonths: _parseIntMonths(_holdPeriodController.text, 36),
      timelineToOperationsMonths:
          _parseIntMonths(_timelineOpsController.text, 6),
      teamMembersText: teamMembersText,
      confidentialityAgreementText:
          _ndaAgreementController.text.trim().isNotEmpty
              ? _ndaAgreementController.text.trim()
              : "Standard bilateral non-disclosure agreement required prior to accessing proprietary financials.",
      coverImagePath: _coverImagePath,
      status: 'ACTIVE',
    );

    // Print API call specifications and full body payload
    if (kDebugMode) {
      final payloadMap = request.toMap();
      final prettyJson = const JsonEncoder.withIndent('  ').convert(payloadMap);

      debugPrint('╔═══════════════════════════════════════════════════════════');
      debugPrint('║ 🚀 PUBLISH PROJECT — API REQUEST SPECIFICATION');
      debugPrint('╠═══════════════════════════════════════════════════════════');
      debugPrint('║ Method        : POST');
      debugPrint('║ Endpoint      : /api/v1/projects/sponsor/');
      debugPrint('║ Content-Type  : multipart/form-data');
      debugPrint('║ Auth Required : Yes (Bearer Token)');
      debugPrint('║ Verification  : $rawStatus');
      debugPrint('╠═══════════════════════════════════════════════════════════');
      debugPrint('║ Body Payload (Map / Form Fields):');
      for (final line in prettyJson.split('\n')) {
        debugPrint('║   $line');
      }
      if (_coverImagePath != null && _coverImagePath!.isNotEmpty) {
        debugPrint('║ Files         : cover_image -> $_coverImagePath');
      } else {
        debugPrint('║ Files         : cover_image -> None');
      }
      debugPrint('╚═══════════════════════════════════════════════════════════');
    }

    final result =
        await ref.read(createProjectProvider.notifier).submitProject(request);

    if (!mounted) return;

    if (result.success) {
      if (kDebugMode) {
        debugPrint('✅ [PUBLISH PROJECT] Success! Created Project ID: ${result.projectId}');
      }
      await ref.read(projectDraftProvider.notifier).deleteDraftIfExists(_draftId);
      if (!mounted) return;
      CustomSnackBar.success(context, "Project published successfully!");
      context.pop();
    } else {
      if (kDebugMode) {
        debugPrint('❌ [PUBLISH PROJECT] Failed: ${result.message}');
      }
      CustomSnackBar.error(context, result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final createProjectState = ref.watch(createProjectProvider);
    final industriesAsync = ref.watch(industriesProvider);
    final industriesList =
        industriesAsync.whenOrNull(data: (d) => d) ?? [];
    final industryNames = industriesList.map((e) => e.name).toList();

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
                        selectedFilePath: _coverImagePath,
                        onTap: _pickCoverImage,
                        onRemove: _coverImagePath != null
                            ? () => setState(() => _coverImagePath = null)
                            : null,
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
                        hint: "Detailed explanation of the business model...",
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
                      ProjectFormField(
                        label: "Location (City, State)",
                        hint: "e.g. Austin, TX",
                        controller: _locationController,
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      SizedBox(height: AppDimens.spaceMd),
                      _buildDropdownRow(industryNames),
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
                        selectedFilePath: _confidentialDocPath,
                        selectedFileName: _confidentialDocName,
                        onTap: _pickConfidentialDoc,
                        onRemove: _confidentialDocPath != null
                            ? () => setState(() {
                                  _confidentialDocPath = null;
                                  _confidentialDocName = null;
                                })
                            : null,
                      ),
                      SizedBox(height: AppDimens.spaceXxl),
                      _buildActionButtons(createProjectState.isLoading),
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
    final titleText = widget.initialDraft != null
        ? "Edit Draft"
        : "Create Project";

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
        ],
      ),
    );
  }

  Widget _buildDropdownRow(List<String> industries) {
    final industryList = industries.isNotEmpty
        ? industries
        : const [
            "Technology",
            "Clean Energy",
            "Real Estate",
            "Healthcare",
            "Fintech",
          ];
    return Row(
      children: [
        Expanded(
          child: ProjectDropdownField(
            label: "Industry",
            hint: "Select....",
            value: _selectedIndustry,
            items: industryList,
            onChanged: (val) => setState(() => _selectedIndustry = val),
          ),
        ),
        SizedBox(width: AppDimens.spaceSm),
        Expanded(
          child: CountryPickerField(
            label: "Country",
            hint: "Select....",
            initialValue: _selectedCountry,
            onChanged: (val) => setState(() => _selectedCountry = val.name),
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

  Widget _buildActionButtons(bool isPublishing) {
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
          textColor: Colors.white,
          variant: CustomButtonVariant.primary,
          isLoading: isPublishing,
          onPressed: _onPublish,
        ),
      ],
    );
  }
}
