import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../core/services/revenue_cat_service.dart';
import 'controllers/subscription_provider.dart';
import 'widgets/subscription_feature_table.dart';
import 'widgets/subscription_plan_card.dart';
import 'widgets/subscription_status_banner.dart';

class SubscriptionView extends ConsumerWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(subscriptionProvider);
    final showStatus = state.status.isPro || state.status.hasBillingIssue;

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: tc.textPrimary, size: 22.r),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "Subscription Plan",
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              children: [
                _buildHeader(tc),
                SizedBox(height: 20.h),
                if (showStatus) SubscriptionStatusBanner(status: state.status),
                SubscriptionFeatureTable(features: state.features),
                SizedBox(height: 20.h),
                _buildPlanSelectionRow(context, ref, state),
                SizedBox(height: 28.h),
                CustomButton(
                  text: state.status.isPro ? "Renew / Upgrade Pro" : "Get Pro",
                  height: 52.h,
                  isLoading: state.isLoading,
                  variant: CustomButtonVariant.gradient,
                  onPressed: () async {
                    if (!state.hasPlans) {
                      CustomSnackBar.info(
                        context,
                        "Plans are not loaded yet. Please retry.",
                      );
                      return;
                    }
                    try {
                      final success = await ref
                          .read(subscriptionProvider.notifier)
                          .subscribe();
                      if (!context.mounted) return;
                      if (success) {
                        CustomSnackBar.success(
                          context,
                          "Upgraded to Pro Plan successfully!",
                        );
                        context.pop();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        final msg = e.toString().replaceFirst('Exception: ', '');
                        CustomSnackBar.error(context, msg);
                      }
                    }
                  },
                ),
                TextButton(
                  onPressed: () async {
                    final ok = await RevenueCatService.presentPaywall();
                    if (!context.mounted) return;
                    if (ok) {
                      await ref
                          .read(subscriptionProvider.notifier)
                          .refreshAfterExternalPurchase();
                      if (context.mounted) {
                        CustomSnackBar.success(context, "Welcome to Pro!");
                        context.pop();
                      }
                    }
                  },
                  child: Text(
                    "See all plans (incl. Lifetime)",
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      color: tc.textSecondary,
                    ),
                  ),
                ),
                if (state.status.isPro)
                  TextButton(
                    onPressed: RevenueCatService.presentCustomerCenter,
                    child: Text(
                      "Manage subscription",
                      style: GoogleFonts.outfit(
                        fontSize: 13.sp,
                        color: tc.textSecondary,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () async {
                    try {
                      final ok = await ref
                          .read(subscriptionProvider.notifier)
                          .restore();
                      if (!context.mounted) return;
                      if (ok) {
                        CustomSnackBar.success(context, "Purchases restored.");
                        context.pop();
                      } else {
                        CustomSnackBar.info(
                          context,
                          "No active subscription found to restore.",
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        final msg = e.toString().replaceFirst('Exception: ', '');
                        CustomSnackBar.error(context, msg);
                      }
                    }
                  },
                  child: Text(
                    "Restore Purchases",
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      color: tc.textTertiary,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors tc) {
    return Column(
      children: [
        Container(
          width: 72.r,
          height: 72.r,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          "Subscription Plan",
          style: GoogleFonts.outfit(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Choose the plan that works best for you",
          style: GoogleFonts.outfit(fontSize: 14.sp, color: tc.textTertiary),
        ),
      ],
    );
  }

  Widget _buildPlanSelectionRow(
    BuildContext context,
    WidgetRef ref,
    SubscriptionState state,
  ) {
    final tc = AppThemeColors.of(context);

    if (state.plansLoading && !state.hasPlans) {
      return Row(
        children: [
          Expanded(child: _planSkeleton(tc)),
          SizedBox(width: 14.w),
          Expanded(child: _planSkeleton(tc)),
        ],
      );
    }

    if (!state.hasPlans) {
      return Column(
        children: [
          Text(
            state.plansError ?? "No plans available right now.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 13.sp, color: tc.textTertiary),
          ),
          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: () => ref.read(subscriptionProvider.notifier).loadPlans(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Retry"),
          ),
        ],
      );
    }

    final yearly = state.yearlyPlan;
    final monthly = state.monthlyPlan;
    final notifier = ref.read(subscriptionProvider.notifier);

    return Row(
      children: [
        if (yearly != null)
          Expanded(
            child: SubscriptionPlanCard(
              title: "Yearly",
              badgeText: yearly.badgeText,
              mainPrice: yearly.mainPriceText,
              priceSuffix: yearly.priceSuffix,
              subPrice: yearly.subPriceText ?? '',
              isSelected: state.selectedCycle == BillingCycle.yearly,
              onTap: () => notifier.selectCycle(BillingCycle.yearly),
            ),
          ),
        if (yearly != null && monthly != null) SizedBox(width: 14.w),
        if (monthly != null)
          Expanded(
            child: SubscriptionPlanCard(
              title: "Monthly",
              mainPrice: monthly.mainPriceText,
              priceSuffix: monthly.priceSuffix,
              subPrice: monthly.subPriceText ?? '',
              isSelected: state.selectedCycle == BillingCycle.monthly,
              onTap: () => notifier.selectCycle(BillingCycle.monthly),
            ),
          ),
      ],
    );
  }

  Widget _planSkeleton(AppThemeColors tc) {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: tc.borderColor),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
