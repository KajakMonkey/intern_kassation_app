import 'package:intern_kassation_app/domain/errors/problem_details.dart';

String getProblemDetailsJson({required String errorCode, required String instance, required int status}) {
  return '''
{
  "type": "https://example.com/probs/out-of-credit",
  "title": "You do not have enough credit.",
  "status": $status,
  "detail": "Your current balance is 30, but that costs 50.",
  "instance": "$instance",
  "errorCode": "$errorCode",
  "errors": {
    "balance": [
      "Your current balance is 30, but that costs 50."
    ],
    "accounts": [
      "/account/12345",
      "/account/67890"
    ]
  }
}
''';
}

const kProblemDetailsJson = '''
{
  "type": "https://example.com/probs/out-of-credit",
  "title": "You do not have enough credit.",
  "status": 403,
  "detail": "Your current balance is 30, but that costs 50.",
  "instance": "/account/12345/transactions/abc",
  "errorCode": "BALANCE_INSUFFICIENT",
  "errors": {
    "balance": [
      "Your current balance is 30, but that costs 50."
    ],
    "accounts": [
      "/account/12345",
      "/account/67890"
    ]
  }
}
''';

final kProblemDetails = ProblemDetails(
  type: 'https://example.com/probs/out-of-credit',
  title: 'You do not have enough credit.',
  status: 403,
  detail: 'Your current balance is 30, but that costs 50.',
  instance: '/account/12345/transactions/abc',
  errorCode: 'BALANCE_INSUFFICIENT',
  errors: {
    'balance': ['Your current balance is 30, but that costs 50.'],
    'accounts': ['/account/12345', '/account/67890'],
  },
);


/*
factory ProblemDetails.fromMap(Map<String, dynamic> map) {
    Map<String, List<String>>? parsedErrors;

    final rawErrors = map['errors'];
    if (rawErrors is Map) {
      parsedErrors = rawErrors.map<String, List<String>>((key, value) {
        final list = (value is List) ? value.map((e) => e.toString()).toList() : <String>[];
        return MapEntry(key.toString(), list);
      });
    }

    return ProblemDetails(
      type: map['type']?.toString(),
      title: map['title']?.toString(),
      status: map['status'] is int ? map['status'] as int : int.tryParse(map['status']?.toString() ?? ''),
      instance: map['instance']?.toString(),
      detail: map['detail']?.toString(),
      errors: parsedErrors,
      errorCode: map['errorCode']?.toString(),
    );
  }
*/