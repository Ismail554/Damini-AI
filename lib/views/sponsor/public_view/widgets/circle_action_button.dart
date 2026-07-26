import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_dimens.dart';

/// Small rounded icon button used by the compact app bar.
class CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback onTap;

  const CircleActionButton({
    super.key,
    required this.icon,
    required this.background,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: CircleBorder(
        side: BorderSide(color: borderColor, width: AppDimens.borderThin),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 38.r,
          height: 38.r,
          child: Icon(icon, color: iconColor, size: AppDimens.iconSm + 2),
        ),
      ),
    );
  }
}
