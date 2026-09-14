import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../auth/session/controllers/session_provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/asset_manager.dart';
import '../../core/widgets/common_background.dart';
import '../../shared/global_key.dart';
import '../../shared/widgets/role_selection_card.dart';

class RoleSelectionView extends ConsumerStatefulWidget {
  const RoleSelectionView({super.key});

  @override
  ConsumerState<RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends ConsumerState<RoleSelectionView> {
  String _selectedRole = GlobalKeys.sponsorRole;

  Future<void> _handleContinue() async {
    if (!GlobalKeys.isValidRole(_selectedRole)) return;
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.setRole(_selectedRole);
    if (mounted && authNotifier.validateCurrentRole()) {
      context.go('/role-onboarding', extra: {'role': _selectedRole});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(IconAssets.rawLogo, width: 60.r, height: 60.r),
              SizedBox(height: 12.h),
              Text(
                "Choose Your Role",
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "Choose how you'll use Synvest.",
                style: GoogleFonts.outfit(
                  fontSize: 15.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 24.h),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      RoleSelectionCard(
                        isSelected: _selectedRole == GlobalKeys.sponsorRole,
                        onTap: () => setState(
                          () => _selectedRole = GlobalKeys.sponsorRole,
                        ),
                        title: "Sponsor",
                        description:
                            "I want to publish projects and find strategic investors for my business.",
                        bulletPoints: const [
                          "Publish new projects",
                          "Review investor proposals",
                          "Secure NDA workflow",
                        ],
                        icon: Icons.business_center_rounded,
                      ),
                      SizedBox(height: 16.h),
                      RoleSelectionCard(
                        isSelected: _selectedRole == GlobalKeys.investorRole,
                        onTap: () => setState(
                          () => _selectedRole = GlobalKeys.investorRole,
                        ),
                        title: "Investor",
                        description:
                            "I want to discover and invest in high-potential business opportunities.",
                        bulletPoints: const [
                          "Browse vetted projects",
                          "Send proposals directly",
                          "Chat with professionals worldwide",
                        ],
                        icon: Icons.trending_up_rounded,
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
