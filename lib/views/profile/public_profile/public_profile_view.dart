import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../sponsor/chat/models/chat_item_model.dart';
import '../personal_info/widgets/info_section_card.dart';
import 'widgets/public_profile_hero_card.dart';

class PublicProfileView extends StatelessWidget {
  final String? name;
  final String? title;
  final String? company;
  final String? avatarUrl;
  final String? country;
  final String? phone;

  const PublicProfileView({
    super.key,
    this.name,
    this.title,
    this.company,
    this.avatarUrl,
    this.country,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    final displayName = name ?? "John Doe";
    final displayTitle = title ?? "CEO at Acme Corp";
    final displayCompany = company ?? "Apex Ventures Ltd.";
    final displayCountry = country ?? "United States";
    final displayPhone = phone ?? "000001111444455";
    final displayAvatar = avatarUrl ??
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop";

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
            "Profile",
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              children: [
                PublicProfileHeroCard(
                  name: displayName,
                  title: displayTitle,
                  avatarUrl: displayAvatar,
                ),
                SizedBox(height: 20.h),
                InfoSectionCard(
                  title: "Personal Information",
                  rows: [
                    InfoRowData("Full Name", displayName),
                    InfoRowData("Country", displayCountry),
                  ],
                ),
                SizedBox(height: 20.h),
                InfoSectionCard(
                  title: "Company",
                  rows: [
                    InfoRowData("Company", displayCompany),
                    InfoRowData("Phone", displayPhone),
                  ],
                ),
                SizedBox(height: 28.h),
                CustomButton(
                  text: "Send message",
                  height: 52.h,
                  variant: CustomButtonVariant.gradient,
                  onPressed: () {
                    final chatItem = ChatItemModel(
                      id: "chat_${displayName.hashCode}",
                      name: displayName,
                      initials: displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : "U",
                      lastMessage: "Hello!",
                      time: "Just now",
                      isOnline: true,
                      avatarUrl: displayAvatar,
                    );
                    context.push('/direct-chat', extra: chatItem);
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
}
