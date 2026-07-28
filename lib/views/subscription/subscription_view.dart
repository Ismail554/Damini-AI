import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_snackbar.dart';
import 'controllers/subscription_provider.dart';
import 'widgets/subscription_feature_table.dart';
import 'widgets/subscription_plan_card.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ChangeNotifierProvider(
      create: (_) => SubscriptionProvider(),
      child: CommonBackground(
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
            child: Consumer<SubscriptionProvider>(
              builder: (context, provider, _) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(tc),
                      SizedBox(height: 24.h),
                      SubscriptionFeatureTable(features: provider.features),
                      SizedBox(height: 20.h),
                      _buildPlanSelectionRow(provider),
                      SizedBox(height: 28.h),
                      CustomButton(
                        text: "Get Pro",
                        height: 52.h,
                        isLoading: provider.isLoading,
                        variant: CustomButtonVariant.gradient,
                        onPressed: () async {
                          final success = await provider.subscribe();
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
                );
              },
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
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 32.r,
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

  Widget _buildPlanSelectionRow(SubscriptionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: SubscriptionPlanCard(
            title: "Yearly",
            badgeText: "-14%",
            mainPrice: "229 \$",
            priceSuffix: "/yr",
            subPrice: "19 \$/mo",
            isSelected: provider.selectedCycle == BillingCycle.yearly,
            onTap: () => provider.selectCycle(BillingCycle.yearly),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: SubscriptionPlanCard(
            title: "Monthly",
            mainPrice: "22 \$",
            priceSuffix: "/mo",
            subPrice: "264 \$/yr",
            isSelected: provider.selectedCycle == BillingCycle.monthly,
            onTap: () => provider.selectCycle(BillingCycle.monthly),
          ),
        ),
      ],
    );
  }
}
