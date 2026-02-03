import 'package:flutter/material.dart';
import 'package:intern_kassation_app/ui/core/themes/colors.dart';

abstract final class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,

    elevatedButtonTheme: elevatedButtonTheme,
    filledButtonTheme: filledButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
  );

  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,

    elevatedButtonTheme: elevatedButtonTheme,
    filledButtonTheme: filledButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
  );

  static final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(0, 48)),
    ),
  );

  static final filledButtonTheme = FilledButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(0, 48)),
    ),
  );

  static final outlinedButtonTheme = OutlinedButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(0, 48)),
    ),
  );
}
