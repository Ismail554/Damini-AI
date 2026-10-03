import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import 'package:Braintech/core/widgets/app_state_widgets.dart';
import '../controllers/sponsor_chat_provider.dart';
import '../widgets/chat_list_item_card.dart';
import '../widgets/chat_search_bar.dart';

class SponsorChatView extends ConsumerWidget {
  const SponsorChatView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(sponsorChatProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(sponsorChatProvider.notifier).refresh(),
      color: AppColors.primaryColor,
      backgroundColor: tc.cardBg,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
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
                  ref.read(sponsorChatProvider.notifier).updateSearchQuery(query),
              hintText: "Search conversations...",
            ),
            SizedBox(height: AppDimens.spaceLg),
            if (state.isLoading && state.allChats.isEmpty)
              Column(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: const AppShimmer.card(height: 72),
                  ),
                ),
              )
            else if (state.chats.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 80.h),
                child: const Center(
                  child: AppEmptyView(
                    message: "No conversations found",
                    icon: Icons.chat_bubble_outline_rounded,
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
                  final chatItem = state.chats[index];
                  return ChatListItemCard(
                    item: chatItem,
                    onTap: () {
                      ref
                          .read(sponsorChatProvider.notifier)
                          .clearUnread(chatItem.id);
                      if (chatItem.isGroupChat) {
                        context.push(
                          '/group-chat',
                          extra: {
                            'title': chatItem.name,
                            'conversationId': int.tryParse(chatItem.id),
                            'projectId': chatItem.projectId,
                          },
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
      ),
    );
  }
}
