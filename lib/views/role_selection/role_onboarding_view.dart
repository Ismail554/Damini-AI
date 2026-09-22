import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/common_background.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../shared/screens/choose_type_screen.dart';
import '../../shared/screens/company_verification_screen.dart';
import '../../shared/screens/complete_profile_screen.dart';
import '../../shared/screens/interests_screen.dart';
import '../../shared/screens/verification_pending_screen.dart';
import 'provider/onboarding_provider.dart';

class RoleOnboardingView extends ConsumerStatefulWidget {
  final String role;
  const RoleOnboardingView({super.key, required this.role});

  @override
  ConsumerState<RoleOnboardingView> createState() => _RoleOnboardingViewState();
}

class _RoleOnboardingViewState extends ConsumerState<RoleOnboardingView> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;
  String _selectedAccountType = 'INDIVIDUAL';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(onboardingProvider.notifier).initRole(widget.role);
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTypeSelected(String type) async {
    final success = await ref.read(onboardingProvider.notifier).setAccountType(type);
    if (!mounted) return;
    if (success) {
      setState(() => _selectedAccountType = type);
      _nextPage();
    } else {
      final error = ref.read(onboardingProvider).errorMessage ?? "Failed to set account type";
      CustomSnackBar.show(context, error, isError: true);
    }
  }

  Future<void> _onProfileSaved(Map<String, dynamic> fields, String? photoPath) async {
    final success = await ref.read(onboardingProvider.notifier).saveProfileDetails(
          phone: fields['phone']?.toString() ?? '',
          country: fields['country']?.toString() ?? '',
          location: fields['location']?.toString() ?? '',
          photoPath: photoPath,
          positionTitle: fields['position_title']?.toString(),
          legalCompanyName: fields['legal_company_name']?.toString(),
          registrationNumber: fields['registration_number']?.toString(),
          businessAddress: fields['business_address']?.toString(),
          companyWebsite: fields['company_website']?.toString(),
        );

    if (!mounted) return;
    if (success) {
      _nextPage();
    } else {
      final error = ref.read(onboardingProvider).errorMessage ?? "Failed to save profile";
      CustomSnackBar.show(context, error, isError: true);
    }
  }

  Future<void> _onInterestsCompleted(List<int> industryIds) async {
    final success = await ref.read(onboardingProvider.notifier).setInterests(industryIds);
    if (!mounted) return;
    if (success) {
      if (_selectedAccountType.toUpperCase() == 'INDIVIDUAL') {
        _pageCtrl.jumpToPage(4);
        setState(() => _currentStep = 4);
      } else {
        _nextPage();
      }
    } else {
      final error = ref.read(onboardingProvider).errorMessage ?? "Failed to set interests";
      CustomSnackBar.show(context, error, isError: true);
    }
  }

  Future<void> _onCompanyDocsSubmitted(Map<String, String> documents) async {
    bool allSuccess = true;
    for (final entry in documents.entries) {
      final ok = await ref.read(onboardingProvider.notifier).uploadDocument(entry.key, entry.value);
      if (!ok) {
        allSuccess = false;
        break;
      }
    }

    if (!mounted) return;
    if (allSuccess) {
      _nextPage();
    } else {
      final error = ref.read(onboardingProvider).errorMessage ?? "Failed to upload document";
      CustomSnackBar.show(context, error, isError: true);
    }
  }

  void _nextPage() {
    if (_currentStep < 4) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      if (_currentStep == 4 && _selectedAccountType.toUpperCase() == 'INDIVIDUAL') {
        _pageCtrl.jumpToPage(2);
        setState(() => _currentStep = 2);
        return;
      }
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
    final onboardingState = ref.watch(onboardingProvider);
    final isCompany = _selectedAccountType.toUpperCase() == 'COMPANY';

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ChooseTypeScreen(
              role: widget.role,
              isLoading: onboardingState.isLoading,
              onNext: _onTypeSelected,
              onBack: _prevPage,
            ),
            CompleteProfileScreen(
              role: widget.role,
              isCompany: isCompany,
              isLoading: onboardingState.isLoading,
              onSaved: _onProfileSaved,
              onBack: _prevPage,
            ),
            InterestsScreen(
              role: widget.role,
              isLoading: onboardingState.isLoading,
              onNext: _onInterestsCompleted,
              onBack: _prevPage,
            ),
            CompanyVerificationScreen(
              role: widget.role,
              isLoading: onboardingState.isLoading,
              onSubmit: _onCompanyDocsSubmitted,
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
