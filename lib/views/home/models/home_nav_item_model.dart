import 'package:flutter/widgets.dart';

class HomeNavItemModel {
  final String label;
  final IconData icon;
  final String? cnSymbol;

  const HomeNavItemModel({
    required this.label,
    required this.icon,
    this.cnSymbol,
  });
}
