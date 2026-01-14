import 'package:flutter/material.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

extension AppLocalizationsL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension StringHardcodedExtension on String {
  String get hardcoded => this;
}
