import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project_draft_model.dart';
import 'ai_templates_data.dart';

class AiPromptModal extends StatefulWidget {
  const AiPromptModal({super.key});

  static Future<ProjectDraftModel?> show(BuildContext context) {
    return showModalBottomSheet<ProjectDraftModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => const AiPromptModal(),
    );
  }

  @override
  State<AiPromptModal> createState() => _AiPromptModalState();
}

class _AiPromptModalState extends State<AiPromptModal> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;

  final List<Map<String, String>> _templates = AiTemplatesData.templates;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _generateDraft([Map<String, String>? template]) async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final userIdea = _promptController.text.trim();
    final tmpl = template ?? _templates[0];

    final title = userIdea.isNotEmpty
        ? "AI Project: $userIdea"
        : tmpl['title']!;

    final draft = ProjectDraftModel(
      id: 'ai_draft_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      shortDesc: userIdea.isNotEmpty
          ? "AI-assisted business opportunity focusing on $userIdea."
          : tmpl['shortDesc']!,
      fullDesc: userIdea.isNotEmpty
          ? "Comprehensive operational blueprint for $userIdea with projected revenue streams, key milestones, and verified financial forecasting."
          : tmpl['fullDesc']!,
      fundingGoal: tmpl['goal']!,
      minInvestment: tmpl['minInv']!,
      targetRoi: tmpl['roi']!,
      industry: tmpl['category']!,
      country: 'United States',
      fundingStage: tmpl['stage']!,
      timeline: '36 months',
      status: 'Ready for investment pipeline',
      milestones:
          'Q1: Prototype & MVP\nQ2: Pilot Customers\nQ3: Scale Operations',
      useOfFunds: '40% R&D, 30% Sales & Marketing, 20% Ops, 10% Reserve',
      sponsorInvestment: '250000',
      minContribution: tmpl['minInv']!,
      expectedRoi: '${tmpl['roi']}% annually',
      monthlyRevenue: '45000',
      holdPeriod: '3-5 years',
      timelineOps: 'Immediate deployment',
      teamMembers: 'Alex Vance (CEO), Maria Santos (CTO), David Chen (CFO)',
      ndaAgreement:
          'Standard confidential disclosure agreement required for detailed cap table and audit documents.',
      lastEdited: 'Just now',
    );

    Navigator.pop(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9333EA).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: const Color(0xFFC026D3),
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        "Create with AI Assistant",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            "Describe your business idea or pick a preset template. AI will generate suggested project field data which you can edit freely.",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF07192F),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: _promptController,
              maxLines: 3,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText:
                    "e.g. A renewable energy solar farm project in Texas seeking \$5M Series A funding...",
                hintStyle: GoogleFonts.outfit(
                  color: Colors.grey,
                  fontSize: 13.sp,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Or pick a quick template:",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Column(
            children: _templates.map((tmpl) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: GestureDetector(
                  onTap: () => _generateDraft(tmpl),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07192F),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFF006EDB).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: const Color(0xFF006EDB),
                          size: 20.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tmpl['title']!,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${tmpl['category']} · Goal \$${tmpl['goal']} · ${tmpl['roi']}% ROI",
                                style: GoogleFonts.outfit(
                                  color: Colors.grey,
                                  fontSize: 11.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey,
                          size: 14.r,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : () => _generateDraft(),
              icon: _isGenerating
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.auto_awesome, color: Colors.white, size: 20.r),
              label: Text(
                _isGenerating
                    ? "Generating Suggestions..."
                    : "Autofill Fields with AI",
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
