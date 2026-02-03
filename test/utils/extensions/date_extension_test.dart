import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/utils/extensions/date_extension.dart';
import 'package:intl/intl.dart';

void main() {
  group('DateTimeExtension', () {
    test('format() uses default pattern', () {
      final date = DateTime(2026, 1, 2, 15, 4, 5);

      final result = date.format();

      expect(result, DateFormat('dd-MM-yyyy HH:mm').format(date));
    });

    test('format() uses custom pattern', () {
      final date = DateTime(2026, 1, 2, 15, 4, 5);

      final result = date.format('yyyy/MM/dd');

      expect(result, DateFormat('yyyy/MM/dd').format(date));
    });

    test('formatFromUtc() formats local time derived from UTC', () {
      final utcDate = DateTime.utc(2026, 1, 2, 12, 0, 0);

      final result = utcDate.formatFromUtc();

      expect(result, DateFormat('dd-MM-yyyy HH:mm').format(utcDate.toLocal()));
    });

    test('formatFromUtc() uses custom pattern', () {
      final utcDate = DateTime.utc(2026, 1, 2, 12, 0, 0);

      final result = utcDate.formatFromUtc('yyyy-MM-dd');

      expect(result, DateFormat('yyyy-MM-dd').format(utcDate.toLocal()));
    });

    test('formatDate() uses default pattern', () {
      final date = DateTime(2026, 1, 2, 15, 4, 5);

      final result = date.formatDate();

      expect(result, DateFormat('dd-MM-yyyy').format(date));
    });

    test('formatDate() uses custom pattern', () {
      final date = DateTime(2026, 1, 2, 15, 4, 5);

      final result = date.formatDate('yyyy-MM');

      expect(result, DateFormat('yyyy-MM').format(date));
    });
  });
}
