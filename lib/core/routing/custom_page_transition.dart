import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Page<T> buildNativePage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  if (isIOS) {
    return CupertinoPage<T>(
      key: state.pageKey,
      child: child,
    );
  }
  return MaterialPage<T>(
    key: state.pageKey,
    child: child,
  );
}
