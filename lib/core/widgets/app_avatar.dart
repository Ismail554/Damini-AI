import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/api_endpoints.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme_colors.dart';

class AppAvatar extends StatefulWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final String? heroTag;
  final BoxBorder? border;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.heroTag,
    this.border,
  });

  @override
  State<AppAvatar> createState() => _AppAvatarState();
}

class _AppAvatarState extends State<AppAvatar> {
  bool _imageFailed = false;

  @override
  void didUpdateWidget(covariant AppAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() => _imageFailed = false);
    }
  }

  String _computeInitials(String? rawName) {
    if (rawName == null || rawName.trim().isEmpty) return 'M';
    final parts = rawName
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String? _resolveUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty || trimmed == 'null') return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final base = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final resolvedUrl = _resolveUrl(widget.imageUrl);
    final hasValidPhoto = resolvedUrl != null && !_imageFailed;
    final initials = _computeInitials(widget.name);
    final effectiveRadius = widget.radius.r;
    final effectiveFontSize = widget.fontSize ?? (effectiveRadius * 0.68);
    final bgColor = widget.backgroundColor ??
        (tc.isDark ? const Color(0xFF092444) : tc.buttonSecondary);
    final txtColor = widget.textColor ?? AppColors.primaryColor;

    Widget avatar = CircleAvatar(
      radius: effectiveRadius,
      backgroundColor: bgColor,
      backgroundImage: hasValidPhoto ? NetworkImage(resolvedUrl) : null,
      onBackgroundImageError: hasValidPhoto
          ? (exception, stackTrace) {
              if (mounted) {
                setState(() => _imageFailed = true);
              }
            }
          : null,
      child: !hasValidPhoto
          ? Text(
              initials,
              style: GoogleFonts.outfit(
                fontSize: effectiveFontSize,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            )
          : null,
    );

    if (widget.border != null) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: widget.border,
        ),
        child: avatar,
      );
    }

    if (widget.heroTag != null && widget.heroTag!.isNotEmpty) {
      avatar = Hero(tag: widget.heroTag!, child: avatar);
    }

    return avatar;
  }
}
