import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_error_handler.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../sponsor/public_view/widgets/circle_action_button.dart';
import '../controllers/public_profile_provider.dart';

class PublicProfileSaveButton extends ConsumerStatefulWidget {
  final String userId;
  final bool? initialIsSaved;

  const PublicProfileSaveButton({
    super.key,
    required this.userId,
    this.initialIsSaved,
  });

  @override
  ConsumerState<PublicProfileSaveButton> createState() =>
      _PublicProfileSaveButtonState();
}

class _PublicProfileSaveButtonState
    extends ConsumerState<PublicProfileSaveButton> {
  @override
  void initState() {
    super.initState();
    if (widget.initialIsSaved != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(profileBookmarkProvider(widget.userId).notifier)
              .setInitial(widget.initialIsSaved!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final bookmarkState = ref.watch(profileBookmarkProvider(widget.userId));
    final isSaved = bookmarkState.isSaved;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: CircleActionButton(
        icon: isSaved
            ? Icons.bookmark_rounded
            : Icons.bookmark_border_rounded,
        background: tc.cardInner,
        borderColor: isSaved
            ? const Color(0xFFE53935).withValues(alpha: 0.3)
            : tc.borderColor,
        iconColor: isSaved ? const Color(0xFFE53935) : tc.textPrimary,
        onTap: () async {
          if (bookmarkState.isLoading) return;
          try {
            final result = await ref
                .read(profileBookmarkProvider(widget.userId).notifier)
                .toggleBookmark();

            if (context.mounted) {
              if (result) {
                CustomSnackBar.success(
                  context,
                  "Profile saved to bookmarks.",
                );
              } else {
                CustomSnackBar.info(
                  context,
                  "Profile removed from saved items.",
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              final msg = e is AppException
                  ? e.message
                  : "Unable to update bookmark. Please try again.";
              CustomSnackBar.error(context, msg);
            }
          }
        },
      ),
    );
  }
}
