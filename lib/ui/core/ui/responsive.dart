import 'package:flutter/material.dart';

/// {@template responsive}
/// A Widget that helps to make the app responsive
///
/// contains methods that checks if the screen is a mobile or tablet
/// and determines the current orientation
/// {@endtemplate}
class Responsive extends StatelessWidget {
  /// {@macro responsive}
  const Responsive({
    required this.mobile,
    required this.tablet,
    super.key,
  });

  static const double screenMaxWidth = 800;
  static const double dialogMaxWidth = 400;

  /// Widget to display on mobile
  final Widget mobile;

  /// Widget to display on tablet
  final Widget tablet;

  /// Checks if the screen is a mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 904;
  }

  /// Checks if the screen is a tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 904;
  }

  /// Checks if the screen is a desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Checks if the device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Checks if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Returns the width of the menu based on the device type
  static double menuWidth(BuildContext context) {
    if (isMobile(context)) {
      return 240;
    } else if (isTablet(context)) {
      return 300;
    } else {
      return 350;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isTablet(context)) {
      return tablet;
    } else {
      return mobile;
    }
  }
}
