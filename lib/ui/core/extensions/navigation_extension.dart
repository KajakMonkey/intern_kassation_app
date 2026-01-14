import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension NavigationExtensionX on BuildContext {
  // maybe pop
  void maybePop() {
    if (canPop()) {
      pop();
    }
  }
}
