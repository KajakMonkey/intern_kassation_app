import 'package:intern_kassation_app/common_index.dart';

extension BuildcontextExtension on BuildContext {
  /// Returns the current locale of the app.
  Locale get locale => Localizations.localeOf(this);

  /// Returns a Shimmer instance for this context
  ShimmerColors get shimmer => ShimmerColors(this);

  //void hideKeyboard() => FocusScope.of(this).unfocus();
  void unfocus() => FocusScope.of(this).unfocus();
}

class ShimmerColors {
  ShimmerColors(this.context);

  final BuildContext context;

  Color get baseColor => context.colorScheme.surfaceContainer;
  Color get highlightColor => context.colorScheme.surfaceContainerHighest;
}
