import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_dimens.dart';
import '../../core/utils/app_theme_colors.dart';

class SponsorChatView extends StatelessWidget {
  const SponsorChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.screenVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Investor Messages",
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: AppDimens.spaceSm),
          Text(
            "Inquiries and discussions with potential investors.",
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: tc.textTertiary,
            ),
          ),
          SizedBox(height: AppDimens.spaceXl),

          _buildChatItem(
            tc: tc,
            name: "John Doe (Investor)",
            message: "We'd like to schedule a call regarding the Tech Hub deal.",
            time: "11:15 AM",
            unreadCount: 1,
            avatarUrl:
                "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop",
          ),
          _buildChatItem(
            tc: tc,
            name: "Venture Partners LLC",
            message: "NDA signed. Sent over company documents.",
            time: "Yesterday",
            unreadCount: 0,
            avatarUrl:
                "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop",
          ),
          SizedBox(height: 90.h),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required AppThemeColors tc,
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    required String avatarUrl,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimens.spaceMd),
      padding: EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppDimens.avatarMd,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        color: tc.textTertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimens.spaceXs),
                Text(
                  message,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: tc.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (unreadCount > 0) ...[
            SizedBox(width: AppDimens.paddingSm),
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: tc.unreadBadge,
                shape: BoxShape.circle,
              ),
              child: Text(
                "$unreadCount",
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
