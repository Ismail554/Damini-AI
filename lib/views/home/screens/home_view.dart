import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Braintech/views/auth/session/controllers/session_provider.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/utils/platform_utils.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import 'package:Braintech/shared/global_key.dart';
import '../../investor/chat/screens/investor_chat_view.dart';
import '../../investor/dashboard/screens/investor_dashboard.dart';
import '../../investor/saved/screens/investor_saved_view.dart';
import '../../profile/screens/investor_profile_view.dart';
import '../../sponsor/chat/screens/sponsor_chat_view.dart';
import '../../sponsor/dashboard/screens/sponsor_dashboard.dart';
import '../../sponsor/profile/screens/sponsor_profile_view.dart';
import '../../sponsor/saved/screens/sponsor_saved_view.dart';
import '../controllers/home_provider.dart';
import '../widgets/bubble_fab.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
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

  Widget _buildBody(bool isSponsor, int currentIndex) {
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
      index: currentIndex,
      children: pages,
    );
  }

  void _handlePopInvoked(bool didPop, int currentIndex) {
    if (didPop) return;

    if (currentIndex != 0) {
      ref.read(homeProvider.notifier).setTabIndex(0);
      return;
    }

    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;

      final tc = AppThemeColors.of(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
          margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 90.h),
          backgroundColor: tc.cardHero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: tc.borderColor),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final homeState = ref.watch(homeProvider);
    final currentIndex = homeState.currentIndex;
    final isSponsor = auth.userRole == GlobalKeys.sponsorRole;
    final navItems = isSponsor ? _sponsorNavItems : _investorNavItems;
    final isIOS = PlatformUtils.isIOS;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final navBarBottomOffset = bottomInset > 0 ? (bottomInset + 4.h) : 14.h;
    final fabBottomOffset = navBarBottomOffset + AppDimens.navBarHeight + 12.h;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) =>
          _handlePopInvoked(didPop, currentIndex),
      child: CommonBackground(
        showGrid: false,
        topSafeArea: false,
        child: SafeArea(
          top: currentIndex != 3,
          bottom: false,
          child: Stack(
            children: [
              // Body Content with Material 3 Fade-Through transition for Android & native switching for iOS
              Positioned.fill(
                child: isIOS
                    ? _buildBody(isSponsor, currentIndex)
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
                          key: ValueKey<int>(currentIndex),
                          child: _buildBody(isSponsor, currentIndex),
                        ),
                      ),
              ),

              // Floating Action Buttons (Right) - Smooth fade & scale when switching tabs
              Positioned(
                right: 20.w,
                bottom: fabBottomOffset,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: currentIndex != 3 ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    scale: currentIndex != 3 ? 1.0 : 0.8,
                    child: IgnorePointer(
                      ignoring: currentIndex == 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Orange AI Robot Button (Only visible in Chat View)
                          if (currentIndex == 2) ...[
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
                                  size: 22.sp,
                                ),
                              ),
                            ),
                            if (isSponsor) AppSpacing.h12, 
                          ],

                          // Blue + Add Button (Sponsor role) with Horizontal Expansion
                          if (isSponsor)
                            BubbleFab(
                              items: [
                                BubbleMenuItem(
                                  icon: Icons.auto_awesome,
                                  label: "Create with AI",
                                  color: const Color(0xFF9333EA),
                                  onTap: () {
                                    context.push('/project-creation-ai-chat');
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

              // Bottom Navigation Bar (Liquid Glass UI on iOS, Material 3 floating on Android)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNavBar(
                  currentIndex: currentIndex,
                  items: navItems,
                  onTap: (index) =>
                      ref.read(homeProvider.notifier).setTabIndex(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
