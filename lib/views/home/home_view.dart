import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/views/onboarding/onboarding_view.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:Braintech/data/models/nav_tab.dart';
import 'package:Braintech/views/home/fallback_tab_bar.dart';
import '../../controllers/navigation_provider.dart';
import '../../controllers/opportunity_provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/common_background.dart';
import '../../core/widgets/network_info_bar.dart';
import '../../data/models/opportunity_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Fetch opportunities on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OpportunityProvider>().loadOpportunities();
    });

    // Reactive Connectivity Monitoring
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (!mounted) return;
      setState(() {
        _isConnected = !results.contains(ConnectivityResult.none);
      });
      // Auto-reload when connection restored
      if (_isConnected && mounted) {
        context.read<OpportunityProvider>().loadOpportunities();
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = !result.contains(ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final oppProvider = context.watch<OpportunityProvider>();

    return CommonBackground(
      showGrid: false, // Cleaner bg for home screen
      child: Column(
        children: [
          // Persistent top offline banner
          if (!_isConnected) const NetworkInfoBar(),
          Lottie.asset(
            'assets/lottie/success.json',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            animate: true,
          ),
          Expanded(
            child: IndexedStack(
              index: navProvider.currentIndex,
              children: [
                _buildDashboard(oppProvider),
                const _PlaceholderPage(
                  title: "Analytics / Trends",
                  icon: Icons.analytics_outlined,
                ),
                const _PlaceholderPage(
                  title: "Wallet / Payments",
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const _PlaceholderPage(
                  title: "User Profile",
                  icon: Icons.person_outline,
                ),
              ],
            ),
          ),

          // Bottom Navigation Bar matching mockup
          _buildBottomNavBar(navProvider),
        ],
      ),
    );
  }

  Widget _buildDashboard(OpportunityProvider oppProvider) {
    return RefreshIndicator(
      onRefresh: () => oppProvider.loadOpportunities(),
      color: AppColors.primaryColor,
      backgroundColor: AppColors.cardDark,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Avatar, Greeting, Notifications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: const Color(0xFF1E2D3D),
                      backgroundImage: const NetworkImage(
                        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop",
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello,",
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Abdullah!",
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Notification Icon with Badge
                Stack(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1.w,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 22.r,
                      ),
                    ),
                    Positioned(
                      top: 12.h,
                      right: 14.w,
                      child: Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Horizontal Stats List Card
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildStatCard(
                    "Active Interests",
                    "05",
                    Icons.interests_outlined,
                  ),
                  SizedBox(width: 12.w),
                  _buildStatCard(
                    "Opportunities Live",
                    "15",
                    Icons.explore_outlined,
                  ),
                  SizedBox(width: 12.w),
                  _buildStatCard(
                    "Avg. Return",
                    "19%",
                    Icons.trending_up_rounded,
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),

            // Opportunities List Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Opportunities",
                  style: GoogleFonts.outfit(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "View All",
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Filters Tabs Chips
            _buildCategoryFilters(oppProvider),
            SizedBox(height: 20.h),

            // Opportunities dynamic rendering
            _buildOpportunityList(oppProvider),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 120.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, color: AppColors.primaryColor, size: 20.r)],
          ),
          SizedBox(height: 16.h),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11.sp,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(OpportunityProvider provider) {
    final categories = ["All", "Real Estate", "Tech", "Agri"];
    return SizedBox(
      height: 38.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = provider.selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: GestureDetector(
              onTap: () => provider.setCategory(cat),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : const Color(0xFF1E2D3D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.08),
                    width: 1.w,
                  ),
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      color: isSelected ? Colors.white : AppColors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOpportunityList(OpportunityProvider provider) {
    if (provider.isLoading) {
      return _buildShimmerLoader();
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 40.r),
              SizedBox(height: 12.h),
              Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => provider.loadOpportunities(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final list = provider.opportunities;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Text(
            "No opportunities available in this category.",
            style: TextStyle(color: AppColors.grey, fontSize: 14.sp),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildOpportunityCard(list[index], provider);
      },
    );
  }

  Widget _buildOpportunityCard(
    OpportunityModel item,
    OpportunityProvider provider,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo, title, location, and Hot/New tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mock Logo Box
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: item.logoText == 'N'
                      ? Colors.black
                      : Colors.orangeAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: item.logoText == 'N'
                      ? Text(
                          "N",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : Text(
                          item.logoText,
                          style: TextStyle(
                            color: item.logoText == 'a'
                                ? Colors.orange
                                : Colors.greenAccent,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.location,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Hot/New Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: item.badgeText.toLowerCase() == 'hot'
                      ? Colors.redAccent.withOpacity(0.15)
                      : Colors.blueAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.badgeText,
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp,
                    color: item.badgeText.toLowerCase() == 'hot'
                        ? Colors.redAccent
                        : Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Metrics grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn("Min. Entry", "\$${item.minEntry.toInt()}"),
              _buildMetricColumn("Target Return", item.targetReturn),
              _buildMetricColumn("Duration", "${item.durationMonths} mo"),
            ],
          ),
          SizedBox(height: 20.h),

          // Funded progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Funded",
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${item.fundedPercentage.toInt()}%",
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: item.fundedPercentage / 100.0,
              minHeight: 6.h,
              backgroundColor: const Color(0xFF1E2D3D).withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Express Interest Button (Changes state based on hasExpressedInterest)
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton(
              onPressed: () {
                provider.toggleInterest(item.id);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(
                      item.hasExpressedInterest
                          ? "Removed interest from ${item.title}"
                          : "Expressed interest in ${item.title}!",
                    ),
                    backgroundColor: item.hasExpressedInterest
                        ? Colors.orangeAccent
                        : AppColors.success,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: item.hasExpressedInterest
                      ? AppColors.success
                      : Colors.white.withOpacity(0.1),
                  width: 1.w,
                ),
                backgroundColor: item.hasExpressedInterest
                    ? AppColors.success.withOpacity(0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                item.hasExpressedInterest
                    ? "Expressed Interest"
                    : "Express Interest",
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: item.hasExpressedInterest
                      ? AppColors.success
                      : AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 11.sp, color: AppColors.grey),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          height: 230.h,
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: SizedBox(
              width: 32.r,
              height: 32.r,
              child: const CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _useNativeTabBar =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static const _tabs = [
    NavTab(
      label: "Home",
      iconName: "house.fill",
      fallbackIcon: Icons.home_rounded,
    ),
    NavTab(
      label: "Analytics",
      iconName: "chart.bar.fill",
      fallbackIcon: Icons.bar_chart_rounded,
    ),
    NavTab(
      label: "Wallet",
      iconName: "creditcard.fill",
      fallbackIcon: Icons.account_balance_wallet_rounded,
    ),
    NavTab(
      label: "Profile",
      iconName: "person.fill",
      fallbackIcon: Icons.person_rounded,
    ),
  ];

  Widget _buildBottomNavBar(NavigationProvider navProvider) {
    if (_useNativeTabBar) {
      return CNTabBar(
        items: [
          for (final tab in _tabs)
            CNTabBarItem(label: tab.label, icon: CNSymbol(tab.iconName)),
        ],
        currentIndex: navProvider.currentIndex,
        tint: AppColors.primaryColor,
        height: 85,
        onTap: navProvider.setIndex,
      );
    }
    return FallbackTabBar(
      tabs: _tabs,
      currentIndex: navProvider.currentIndex,
      onTap: navProvider.setIndex,
      tint: AppColors.primaryColor,
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderPage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.r, color: AppColors.grey),
          SizedBox(height: 16.h),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Feature screen mock content",
            style: GoogleFonts.outfit(fontSize: 14.sp, color: AppColors.grey),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const OnboardingView()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text("Logout", style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}
