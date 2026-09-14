import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_snackbar.dart';
import 'controllers/subscription_provider.dart';
import 'widgets/subscription_feature_table.dart';
import 'widgets/subscription_plan_card.dart';

class SubscriptionView extends ConsumerWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(subscriptionProvider);

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: tc.textPrimary,
              size: 22.r,
            ),
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
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 12.h,
            ),
            child: Column(
              children: [
                _buildHeader(tc),
                SizedBox(height: 24.h),
                SubscriptionFeatureTable(features: state.features),
                SizedBox(height: 20.h),
                _buildPlanSelectionRow(ref, state),
                SizedBox(height: 28.h),
                CustomButton(
                  text: "Get Pro",
                  height: 52.h,
                  isLoading: state.isLoading,
                  variant: CustomButtonVariant.gradient,
                  onPressed: () async {
                    final success = await ref
                        .read(subscriptionProvider.notifier)
                        .subscribe();
                    if (success && context.mounted) {
                      CustomSnackBar.success(
                        context,
                        "Upgraded to Pro Plan successfully!",
                      );
                      context.pop();
                    }
                  },
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
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            color: tc.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSelectionRow(WidgetRef ref, SubscriptionState state) {
    return Row(
      children: [
        Expanded(
          child: SubscriptionPlanCard(
            title: "Yearly",
            badgeText: "-14%",
            mainPrice: "229 \$",
            priceSuffix: "/yr",
            subPrice: "19 \$/mo",
            isSelected: state.selectedCycle == BillingCycle.yearly,
            onTap: () => ref
                .read(subscriptionProvider.notifier)
                .selectCycle(BillingCycle.yearly),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: SubscriptionPlanCard(
            title: "Monthly",
            mainPrice: "22 \$",
            priceSuffix: "/mo",
            subPrice: "264 \$/yr",
            isSelected: state.selectedCycle == BillingCycle.monthly,
            onTap: () => ref
                .read(subscriptionProvider.notifier)
                .selectCycle(BillingCycle.monthly),
          ),
        ),
      ],
    );
  }
}
