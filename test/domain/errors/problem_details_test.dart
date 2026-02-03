import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/domain/errors/problem_details.dart';

void main() {
  group('ProblemDetails', () {
    test('fromMap parses errors and status string', () {
      final map = {
        'type': 't',
        'title': 'title',
        'status': '400',
        'instance': 'i',
        'detail': 'd',
        'errors': {
          'field': ['err1', 2],
          'otherField': 'singleError',
        },
        'errorCode': 'E1',
      };

      final result = ProblemDetailsMapper.fromMap(map);

      expect(result.type, 't');
      expect(result.title, 'title');
      expect(result.status, 400);
      expect(result.instance, 'i');
      expect(result.detail, 'd');
      expect(result.errorCode, 'E1');
      expect(result.errors, {
        'field': ['err1', '2'],
        'otherField': <String>[],
      });
    });

    test('fromMap allows missing errors', () {
      final map = {
        'type': 't',
        'status': 500,
      };

      final result = ProblemDetailsMapper.fromMap(map);

      expect(result.type, 't');
      expect(result.status, 500);
      expect(result.errors, isNull);
    });

    test('toMap and toJson round-trip', () {
      const model = ProblemDetails(
        type: 't',
        title: 'title',
        status: 400,
        instance: 'i',
        detail: 'd',
        errors: {
          'field': ['err1', 'err2'],
        },
        errorCode: 'E1',
      );

      final map = model.toMap();
      expect(map['status'], 400);
      expect(map['errors'], {
        'field': ['err1', 'err2'],
      });

      final decoded = ProblemDetailsMapper.fromJson(model.toJson());
      expect(decoded, model);
    });
  });
}
