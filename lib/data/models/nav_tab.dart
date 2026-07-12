import 'package:flutter/widgets.dart';

class NavTab {
  const NavTab({
    required this.label,
    required this.iconName,
    required this.fallbackIcon,
  });

  final String label;

  /// SF Symbol name, rendered by cupertino_native on iOS/macOS.
  final String iconName;

  /// Icon used on platforms without SF Symbols (Android, web, desktop).
  final IconData fallbackIcon;
}
