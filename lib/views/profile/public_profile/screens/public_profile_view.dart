import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../sponsor/chat/models/chat_item_model.dart';
import '../../personal_info/widgets/info_section_card.dart';
import '../controllers/public_profile_provider.dart';
import '../widgets/public_profile_hero_card.dart';

class PublicProfileView extends ConsumerWidget {
  final String? name;
  final String? title;
  final String? company;
  final String? avatarUrl;
  final String? country;
  final String? phone;
  final String? email;
  final String? location;
  final String? website;
  final String? bio;
  final String? role;
  final bool? isVerified;
  final bool isOwnProfile;
  final String? heroTag;

  const PublicProfileView({
    super.key,
    this.name,
    this.title,
    this.company,
    this.avatarUrl,
    this.country,
    this.phone,
    this.email,
    this.location,
    this.website,
    this.bio,
    this.role,
    this.isVerified,
    this.isOwnProfile = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final fallbackProfile = ref.watch(publicProfileProvider).profile;

    final displayName = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()
        : (fallbackProfile.name.trim().isNotEmpty
            ? fallbackProfile.name.trim()
            : "Member");

    final displayTitle = (title != null && title!.trim().isNotEmpty)
        ? title!.trim()
        : fallbackProfile.title.trim();

    final displayCompany = (company != null && company!.trim().isNotEmpty)
        ? company!.trim()
        : fallbackProfile.company.trim();

    final displayCountry = (country != null && country!.trim().isNotEmpty)
        ? country!.trim()
        : fallbackProfile.country.trim();

    final displayPhone = (phone != null && phone!.trim().isNotEmpty)
        ? phone!.trim()
        : fallbackProfile.phone.trim();

    final displayEmail = (email != null && email!.trim().isNotEmpty)
        ? email!.trim()
        : fallbackProfile.email.trim();

    final displayLocation = (location != null && location!.trim().isNotEmpty)
        ? location!.trim()
        : fallbackProfile.location.trim();

    final displayWebsite = (website != null && website!.trim().isNotEmpty)
        ? website!.trim()
        : fallbackProfile.website.trim();

    final displayBio = (bio != null && bio!.trim().isNotEmpty)
        ? bio!.trim()
        : fallbackProfile.bio.trim();

    final displayAvatar = (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
        ? avatarUrl!.trim()
        : (fallbackProfile.avatarUrl.trim().isNotEmpty
            ? fallbackProfile.avatarUrl.trim()
            : null);

    final effectiveRole = (role != null && role!.trim().isNotEmpty)
        ? role!.trim()
        : (displayTitle.toLowerCase().contains('investor')
            ? 'Investor'
            : (displayCompany.isNotEmpty ? 'Sponsor' : 'Member'));

    final effectiveVerified = isVerified ?? true;

    // Build personal info rows
    final personalRows = <InfoRowData>[
      InfoRowData("Full Name", displayName),
      InfoRowData(
        "Country",
        displayCountry.isNotEmpty
            ? displayCountry
            : (displayLocation.isNotEmpty ? displayLocation : "Not specified"),
      ),
      if (displayEmail.isNotEmpty) InfoRowData("Email", displayEmail),
    ];

    // Build professional info rows
    final professionalRows = <InfoRowData>[
      if (displayCompany.isNotEmpty) InfoRowData("Company", displayCompany),
      if (displayTitle.isNotEmpty) InfoRowData("Position", displayTitle),
      if (displayPhone.isNotEmpty) InfoRowData("Phone", displayPhone),
      if (displayWebsite.isNotEmpty) InfoRowData("Website", displayWebsite),
    ];

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: tc.textPrimary,
              size: AppDimens.iconLg,
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
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenHorizontal,
              vertical: AppDimens.screenVertical,
            ),
            child: Column(
              children: [
                PublicProfileHeroCard(
                  name: displayName,
                  title: displayTitle,
                  avatarUrl: displayAvatar,
                  role: effectiveRole,
                  isVerified: effectiveVerified,
                  heroTag: heroTag,
                ),
                AppSpacing.h20,
                InfoSectionCard(
                  title: "Personal Information",
                  rows: personalRows,
                ),
                if (professionalRows.isNotEmpty) ...[
                  AppSpacing.h20,
                  InfoSectionCard(
                    title: displayCompany.isNotEmpty
                        ? "Company"
                        : "Professional Information",
                    rows: professionalRows,
                  ),
                ],
                if (displayBio.isNotEmpty) ...[
                  AppSpacing.h20,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppDimens.paddingLg),
                    decoration: BoxDecoration(
                      color: tc.isDark ? const Color(0xFF091E36) : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(
                        color: tc.borderColor,
                        width: AppDimens.borderThin,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ABOUT",
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: tc.textPrimary,
                          ),
                        ),
                        AppSpacing.h12,
                        Text(
                          displayBio,
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            color: tc.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                AppSpacing.h24,
                if (isOwnProfile)
                  CustomButton(
                    text: "Edit profile",
                    height: 52.h,
                    variant: CustomButtonVariant.gradient,
                    onPressed: () => context.push('/personal-info'),
                  )
                else
                  CustomButton(
                    text: "Send message",
                    height: 52.h,
                    variant: CustomButtonVariant.gradient,
                    onPressed: () {
                      final initials = displayName
                          .split(' ')
                          .where((w) => w.isNotEmpty)
                          .map((e) => e[0])
                          .take(2)
                          .join()
                          .toUpperCase();
                      final chatItem = ChatItemModel(
                        id: "chat_${displayName.hashCode.abs()}",
                        name: displayName,
                        initials: initials.isNotEmpty ? initials : "U",
                        lastMessage: "Hello!",
                        time: "Just now",
                        isOnline: true,
                        avatarUrl: displayAvatar,
                      );
                      context.push('/direct-chat', extra: chatItem);
                    },
                  ),
                AppSpacing.h16,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
