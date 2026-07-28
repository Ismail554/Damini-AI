import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_dimens.dart';
import '../../core/utils/app_theme_colors.dart';
import 'chat/controllers/sponsor_chat_provider.dart';
import 'chat/widgets/chat_list_item_card.dart';
import 'chat/widgets/chat_search_bar.dart';

class SponsorChatView extends StatelessWidget {
  const SponsorChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ChangeNotifierProvider(
      create: (_) => SponsorChatProvider()..init(),
      child: Consumer<SponsorChatProvider>(
        builder: (context, provider, _) {
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
                  "Messages",
                  style: GoogleFonts.outfit(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                SizedBox(height: AppDimens.spaceMd),
                ChatSearchBar(
                  onChanged: provider.updateSearchQuery,
                  hintText: "Search deals near you...",
                ),
                SizedBox(height: AppDimens.spaceLg),
                if (provider.isLoading)
                  Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF006EDB),
                      ),
                    ),
                  )
                else if (provider.chats.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: Center(
                      child: Text(
                        "No messages found",
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: tc.textTertiary,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.chats.length,
                    separatorBuilder: (context, index) => Divider(
                      color: tc.isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final chatItem = provider.chats[index];
                      return ChatListItemCard(
                        item: chatItem,
                        onTap: () {
                          provider.clearUnread(chatItem.id);
                          if (chatItem.isGroupChat) {
                            context.push(
                              '/group-chat',
                              extra: chatItem.name,
                            );
                          } else {
                            context.push(
                              '/direct-chat',
                              extra: chatItem,
                            );
                          }
                        },
                      );
                    },
                  ),
                SizedBox(height: 90.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
