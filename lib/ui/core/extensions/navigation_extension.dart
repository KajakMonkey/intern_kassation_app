import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension NavigationExtensionX on BuildContext {
  // Defer to the next frame to avoid navigator lock exceptions
  void maybePop() {
    if (canPop()) pop();
  }

  void maybePopElse(String routeName) {
    if (canPop()) {
      pop();
    } else {
      goNamed(routeName);
    }
  }
}
