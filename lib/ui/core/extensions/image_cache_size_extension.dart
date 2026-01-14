import 'package:flutter/material.dart';

extension ImageCacheSizeExtension on num {
  int cacheSize(BuildContext context) {
    return (this * MediaQuery.devicePixelRatioOf(context)).round();
  }

  double cacheSizeDouble(BuildContext context) {
    return this * MediaQuery.devicePixelRatioOf(context);
  }
}
