import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/common_background.dart';
import '../../shared/screens/choose_type_screen.dart';
import '../../shared/screens/company_verification_screen.dart';
import '../../shared/screens/complete_profile_screen.dart';
import '../../shared/screens/interests_screen.dart';
import '../../shared/screens/role_feature_slides_screen.dart';
import '../../shared/screens/verification_pending_screen.dart';

class RoleOnboardingView extends StatefulWidget {
  final String role;
  const RoleOnboardingView({super.key, required this.role});

  @override
  State<RoleOnboardingView> createState() => _RoleOnboardingViewState();
}

class _RoleOnboardingViewState extends State<RoleOnboardingView> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;
  String _selectedAccountType = 'Individual';

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onTypeSelected(String type) {
    setState(() {
      _selectedAccountType = type;
    });
    _nextPage();
  }

  void _onInterestsCompleted() {
    if (_selectedAccountType == 'Individual') {
      // Individual users skip company verification and complete onboarding
      context.go('/home');
    } else {
      // Corporate users proceed to Company Verification
      _nextPage();
    }
  }

  void _nextPage() {
    if (_currentStep < 5) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      if (Navigator.of(context).canPop()) {
        context.pop();
      } else {
        context.go('/role-selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            RoleFeatureSlidesScreen(
              role: widget.role,
              onCompleted: _nextPage,
              onBack: _prevPage,
            ),
            ChooseTypeScreen(
              role: widget.role,
              onNext: _onTypeSelected,
              onBack: _prevPage,
            ),
            CompleteProfileScreen(
              role: widget.role,
              onSaved: _nextPage,
              onBack: _prevPage,
            ),
            InterestsScreen(
              role: widget.role,
              onNext: _onInterestsCompleted,
              onBack: _prevPage,
            ),
            CompanyVerificationScreen(
              role: widget.role,
              onSubmit: _nextPage,
              onBack: _prevPage,
            ),
            VerificationPendingScreen(
              role: widget.role,
            ),
          ],
        ),
      ),
    );
  }
}
