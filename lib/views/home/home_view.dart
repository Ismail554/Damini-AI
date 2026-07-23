import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_provider.dart';
import '../../core/utils/app_theme_colors.dart';
import '../../core/widgets/common_background.dart';
import '../../shared/global_key.dart';
import '../investor/investor_chat_view.dart';
import '../investor/investor_dashboard.dart';
import '../investor/investor_saved_view.dart';
import '../profile/investor_profile_view.dart';
import '../sponsor/sponsor_chat_view.dart';
import '../sponsor/sponsor_dashboard.dart';
import '../sponsor/sponsor_profile_view.dart';
import '../sponsor/sponsor_saved_view.dart';
import 'widgets/custom_bottom_nav_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  DateTime? _lastPressedAt;

  static const _sponsorNavItems = [
    CustomNavItemData(label: "Dashboard", icon: Icons.home_rounded),
    CustomNavItemData(label: "Saved", icon: Icons.favorite_border_rounded),
    CustomNavItemData(label: "Chat", icon: Icons.chat_bubble_outline_rounded),
    CustomNavItemData(label: "Person", icon: Icons.person_outline_rounded),
  ];

  static const _investorNavItems = [
    CustomNavItemData(label: "Explore", icon: Icons.home_rounded),
    CustomNavItemData(label: "Saved", icon: Icons.favorite_border_rounded),
    CustomNavItemData(label: "Chat", icon: Icons.chat_bubble_outline_rounded),
    CustomNavItemData(label: "Person", icon: Icons.person_outline_rounded),
  ];

  Widget _buildBody(bool isSponsor) {
    if (isSponsor) {
      switch (_currentIndex) {
        case 0:
          return const SponsorDashboard();
        case 1:
          return const SponsorSavedView();
        case 2:
          return const SponsorChatView();
        case 3:
          return const SponsorProfileView();
        default:
          return const SponsorDashboard();
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return const InvestorDashboard();
        case 1:
          return const InvestorSavedView();
        case 2:
          return const InvestorChatView();
        case 3:
          return const InvestorProfileView();
        default:
          return const InvestorDashboard();
      }
    }
  }

  void _handlePopInvoked(bool didPop) {
    if (didPop) return;

    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return;
    }

    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;

      final tc = AppThemeColors.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Press back again to exit',
            style: GoogleFonts.outfit(
              color: tc.textPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: tc.cardHero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: tc.borderColor),
          ),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSponsor = auth.userRole == GlobalKeys.sponsorRole;
    final navItems = isSponsor ? _sponsorNavItems : _investorNavItems;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handlePopInvoked(didPop),
      child: CommonBackground(
        showGrid: false,
        child: SafeArea(
          child: Stack(
            children: [
              // Body Content
              Positioned.fill(child: _buildBody(isSponsor)),

              // Floating Action Buttons (Right)
              Positioned(
                right: 20.w,
                bottom: 100.h,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Orange AI Robot Button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD34E27),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFD34E27,
                              ).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.smart_toy_outlined,
                          color: Colors.white,
                          size: 22.r,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Blue + Add Button (Sponsor role)
                    if (isSponsor)
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006EDB),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF006EDB,
                                ).withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 26.r,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNavBar(
                  currentIndex: _currentIndex,
                  items: navItems,
                  onTap: (index) => setState(() => _currentIndex = index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
