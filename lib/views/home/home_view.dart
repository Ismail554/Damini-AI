import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_theme_colors.dart';
import '../../core/utils/platform_utils.dart';
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
import 'widgets/bubble_fab.dart';
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
    CustomNavItemData(label: "Profile", icon: Icons.person_outline_rounded),
  ];

  static const _investorNavItems = [
    CustomNavItemData(label: "Explore", icon: Icons.home_filled),
    CustomNavItemData(label: "Saved", icon: Icons.favorite_border_rounded),
    CustomNavItemData(label: "Chat", icon: Icons.chat_bubble_outline_rounded),
    CustomNavItemData(label: "Profile", icon: Icons.person_outline_rounded),
    // CustomNavItemData(
    //   label: "Explore",
    //   icon: CupertinoIcons.compass,
    //   activeIcon: CupertinoIcons.compass_fill,
    // ),
    // CustomNavItemData(
    //   label: "Saved",
    //   icon: CupertinoIcons.heart,
    //   activeIcon: CupertinoIcons.heart_fill,
    // ),
    // CustomNavItemData(
    //   label: "Chat",
    //   icon: CupertinoIcons.chat_bubble_2,
    //   activeIcon: CupertinoIcons.chat_bubble_2_fill,
    // ),
    // CustomNavItemData(
    //   label: "Profile",
    //   icon: CupertinoIcons.person,
    //   activeIcon: CupertinoIcons.person_fill,
    // ),
  ];

  static const _sponsorCNItems = [
    CNTabBarItem(label: "Dashboard", icon: CNSymbol("house.fill")),
    CNTabBarItem(label: "Saved", icon: CNSymbol("heart.fill")),
    CNTabBarItem(
      label: "Chat",
      icon: CNSymbol("bubble.left.and.bubble.right.fill"),
    ),
    CNTabBarItem(label: "Profile", icon: CNSymbol("person.fill")),
  ];

  static const _investorCNItems = [
    CNTabBarItem(label: "Explore", icon: CNSymbol("compass.drawing")),
    CNTabBarItem(label: "Saved", icon: CNSymbol("heart.fill")),
    CNTabBarItem(
      label: "Chat",
      icon: CNSymbol("bubble.left.and.bubble.right.fill"),
    ),
    CNTabBarItem(label: "Profile", icon: CNSymbol("person.fill")),
  ];

  Widget _buildBody(bool isSponsor) {
    final pages = isSponsor
        ? const [
            SponsorDashboard(),
            SponsorSavedView(),
            SponsorChatView(),
            SponsorProfileView(),
          ]
        : const [
            InvestorDashboard(),
            InvestorSavedView(),
            InvestorChatView(),
            InvestorProfileView(),
          ];

    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
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
    final cnItems = isSponsor ? _sponsorCNItems : _investorCNItems;
    final isIOS = PlatformUtils.isIOS;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handlePopInvoked(didPop),
      child: CommonBackground(
        showGrid: false,
        child: SafeArea(
          child: Stack(
            children: [
              // Body Content with Material 3 Fade-Through transition for Android & native switching for iOS
              Positioned.fill(
                child: isIOS
                    ? _buildBody(isSponsor)
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.fastOutSlowIn,
                        switchOutCurve: Curves.fastOutSlowIn,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.0)
                                  .animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.fastOutSlowIn,
                                ),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<int>(_currentIndex),
                          child: _buildBody(isSponsor),
                        ),
                      ),
              ),

              // Floating Action Buttons (Right) - Smooth fade & scale when switching tabs
              Positioned(
                right: 20.w,
                bottom: 100.h,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _currentIndex != 3 ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    scale: _currentIndex != 3 ? 1.0 : 0.8,
                    child: IgnorePointer(
                      ignoring: _currentIndex == 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Orange AI Robot Button
                          GestureDetector(
                            onTap: () => context.push('/ai-chat'),
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD34E27),
                                shape: BoxShape.circle,
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

                          // Blue + Add Button (Sponsor role) with Horizontal Expansion
                          if (isSponsor)
                            BubbleFab(
                              items: [
                                BubbleMenuItem(
                                  icon: Icons.auto_awesome,
                                  label: "Create with AI",
                                  color: const Color(0xFF9333EA),
                                  onTap: () {
                                    context.push(
                                      '/create-project',
                                      extra: {'isAiMode': true},
                                    );
                                  },
                                ),
                                BubbleMenuItem(
                                  icon: Icons.edit_note_rounded,
                                  label: "Create Myself",
                                  color: const Color(0xFF006EDB),
                                  onTap: () {
                                    context.push('/create-project');
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: isIOS
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                        child: CNTabBar(
                          items: cnItems,
                          currentIndex: _currentIndex,
                          tint: AppColors.primaryColor,
                          onTap: (index) =>
                              setState(() => _currentIndex = index),
                        ),
                      )
                    : CustomBottomNavBar(
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
