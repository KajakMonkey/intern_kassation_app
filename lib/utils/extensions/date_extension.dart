import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// formats a DateTime to a string with the given pattern
  /// default pattern is 'dd-MM-yyyy HH:mm'
  String format([String pattern = 'dd-MM-yyyy HH:mm']) {
    return DateFormat(pattern).format(this);
  }

  String formatFromUtc([String pattern = 'dd-MM-yyyy HH:mm']) {
    return DateFormat(pattern).format(toLocal());
  }

  /// formats a DateTime to a string with the given pattern
  /// default pattern is 'dd-MM-yyyy'
  String formatDate([String pattern = 'dd-MM-yyyy']) {
    return DateFormat(pattern).format(this);
  }
}
