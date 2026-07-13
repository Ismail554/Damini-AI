import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/common_background.dart';
import '../../core/widgets/glass_card.dart';
import 'widgets/onboarding_widgets.dart';

class RoleOnboardingView extends StatefulWidget {
  final String role;
  const RoleOnboardingView({super.key, required this.role});

  @override
  State<RoleOnboardingView> createState() => _RoleOnboardingViewState();
}

class _RoleOnboardingViewState extends State<RoleOnboardingView> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;

  // Form Fields
  String? _selectedType;
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final List<String> _interests = [];
  final _compNameCtrl = TextEditingController();
  final _compWebCtrl = TextEditingController();
  final _compRegCtrl = TextEditingController();

  final _allInterests = ["Technology", "Real Estate", "Healthcare", "Energy", "Agriculture", "Finance"];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _bioCtrl.dispose();
    _compNameCtrl.dispose();
    _compWebCtrl.dispose();
    _compRegCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 6) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      showGrid: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentStep < 6) _buildHeader(),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildIntroStep(),
                _buildTypeStep(),
                _buildProfileStep(),
                _buildInterestsStep(),
                _buildVerifyStep(),
                _buildCompanyProfileStep(),
                _buildPendingStep(),
              ],
            ),
          ),
          if (_currentStep < 6) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Step ${_currentStep + 1} of 6", style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.bold)),
          Text(widget.role.toUpperCase(), style: GoogleFonts.outfit(color: AppColors.primaryColor, fontSize: 13.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  Widget _buildIntroStep() {
    return OnboardingWidgets.buildStepLayout(
      title: "Welcome, ${widget.role == 'investor' ? 'Investor' : 'Sponsor'}!",
      desc: widget.role == 'investor' 
        ? "Discover premium opportunities matching your criteria."
        : "Start pitching your investment opportunities to verified global backers.",
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32.r),
          decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.05), shape: BoxShape.circle),
          child: Icon(widget.role == 'investor' ? Icons.explore_rounded : Icons.rocket_launch_rounded, color: AppColors.primaryColor, size: 84.r),
        ),
      ),
    );
  }

  Widget _buildTypeStep() {
    return OnboardingWidgets.buildStepLayout(
      title: "Select Entity Type",
      desc: "Specify if you participate as an individual or on behalf of an institution.",
      child: Column(
        children: [
          OnboardingWidgets.buildSelectOption(
            type: "Individual",
            desc: "Participate as a single private entity",
            isSelected: _selectedType == "Individual",
            onTap: () => setState(() => _selectedType = "Individual"),
          ),
          SizedBox(height: 16.h),
          OnboardingWidgets.buildSelectOption(
            type: "Institutional",
            desc: "Participate as a registered fund or company",
            isSelected: _selectedType == "Institutional",
            onTap: () => setState(() => _selectedType = "Institutional"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStep() {
    return OnboardingWidgets.buildStepLayout(
      title: "Complete Profile",
      desc: "Enter your contact details and a short description.",
      child: GlassCard(
        child: Column(
          children: [
            OnboardingWidgets.buildTextField(_phoneCtrl, "Phone Number", Icons.phone, TextInputType.phone),
            SizedBox(height: 16.h),
            OnboardingWidgets.buildTextField(_locationCtrl, "Location (City, Country)", Icons.location_on_outlined, TextInputType.text),
            SizedBox(height: 16.h),
            OnboardingWidgets.buildTextField(_bioCtrl, "Bio / Short Description", Icons.info_outline_rounded, TextInputType.multiline, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsStep() {
    return OnboardingWidgets.buildStepLayout(
      title: "Areas of Interest",
      desc: "Choose industries that you want to target.",
      child: Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: _allInterests.map((interest) {
          final isSelected = _interests.contains(interest);
          return FilterChip(
            label: Text(interest, style: TextStyle(color: isSelected ? Colors.white : AppColors.grey)),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _interests.add(interest);
                } else {
                  _interests.remove(interest);
                }
              });
            },
            selectedColor: AppColors.primaryColor,
            backgroundColor: AppColors.secondaryColor.withOpacity(0.3),
            checkmarkColor: Colors.white,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVerifyStep() {
    return OnboardingWidgets.buildStepLayout(
      title: "Submit Documents",
      desc: "Upload official identification or business certificate to verify your account.",
      child: GlassCard(
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, color: AppColors.primaryColor, size: 48.r),
            SizedBox(height: 12.h),
            Text("Upload PDF or Image", style: GoogleFonts.outfit(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text("Maximum size: 10MB", style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyProfileStep() {
    return OnboardingWidgets.buildStepLayout(
      title: "Company Profile",
      desc: "Configure the public-facing organization profile.",
      child: GlassCard(
        child: Column(
          children: [
            OnboardingWidgets.buildTextField(_compNameCtrl, "Company Name", Icons.business_rounded, TextInputType.text),
            SizedBox(height: 16.h),
            OnboardingWidgets.buildTextField(_compWebCtrl, "Company Website", Icons.language_rounded, TextInputType.url),
            SizedBox(height: 16.h),
            OnboardingWidgets.buildTextField(_compRegCtrl, "Business Registration Number", Icons.description_rounded, TextInputType.text),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty_rounded, color: Colors.orangeAccent, size: 80.r),
          SizedBox(height: 24.h),
          Text("Verification Pending", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Text(
            "Our compliance team is currently reviewing your documents. You can browse the platform in the meantime.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14.sp, height: 1.5),
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
              ),
              child: Text("Skip to App", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
            ),
            child: Text("Continue", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
