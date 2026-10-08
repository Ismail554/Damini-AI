import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import '../../../sponsor/chat/models/chat_item_model.dart';
import '../../../sponsor/chat/widgets/chat_search_bar.dart';
import '../controllers/investor_chat_provider.dart';

class InvestorChatView extends ConsumerWidget {
  const InvestorChatView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(investorChatProvider);

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
            onChanged: (query) =>
                ref.read(investorChatProvider.notifier).updateSearchQuery(query),
            hintText: "Search conversations...",
          ),
          SizedBox(height: AppDimens.spaceLg),
          if (state.isLoading)
            Padding(
              padding: EdgeInsets.only(top: 40.h),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF006EDB),
                ),
              ),
            )
          else if (state.chats.isEmpty)
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
              itemCount: state.chats.length,
              separatorBuilder: (context, index) => Divider(
                color: tc.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                  leading: CircleAvatar(
                    radius: 24.r,
                    backgroundImage: NetworkImage(chat.avatarUrl),
                  ),
                  title: Text(
                    chat.name,
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      color: tc.textSecondary,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat.time,
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          color: tc.textTertiary,
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${chat.unreadCount}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    ref.read(investorChatProvider.notifier).clearUnread(chat.id);
                    if (chat.isGroupChat) {
                      context.push(
                        '/group-chat',
                        extra: {
                          'title': chat.name,
                          'conversationId': int.tryParse(chat.id),
                          'projectId': chat.projectId,
                        },
                      );
                    } else {
                      context.push(
                        '/direct-chat',
                        extra: ChatItemModel(
                          id: chat.id,
                          name: chat.name,
                          initials: chat.name.isNotEmpty ? chat.name[0] : "",
                          lastMessage: chat.lastMessage,
                          time: chat.time,
                          avatarUrl: chat.avatarUrl,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          AppSpacing.h24,
        ],
      ),
    );
  }
}
