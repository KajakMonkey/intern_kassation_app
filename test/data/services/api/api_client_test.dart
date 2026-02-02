import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/data/services/api/api_client.dart';
import 'package:intern_kassation_app/data/services/api/models/orders/discarded_order_query_request.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/validation_error_codes.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../testing/mocks.dart';

void main() {
  late MockDio dio;
  late BaseOptions baseOptions;
  late ApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(FormData.fromMap({}));
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() {
    dio = MockDio();
    baseOptions = BaseOptions(headers: {});
    when(() => dio.options).thenReturn(baseOptions);

    apiClient = ApiClient(
      client: dio,
      authHeaderProvider: () async => 'Bearer token',
    );
  });

  Response<String> okResponse(String data, {int statusCode = 200}) => Response<String>(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(path: '/'),
  );

  group('ApiClient', () {
    test('getEmployeeDetails returns Employee on 200', () async {
      when(() => dio.get<String>(any())).thenAnswer(
        (_) async => okResponse('{"employeeId":"E1","name":"Jane"}'),
      );

      final result = await apiClient.getEmployeeDetails('E1');

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) {
          expect(r.id, 'E1');
          expect(r.name, 'Jane');
        },
      );
      expect(baseOptions.headers[HttpHeaders.authorizationHeader], 'Bearer token');
    });

    test('getUserDetails returns User on 200', () async {
      when(() => dio.get<String>(any())).thenAnswer(
        (_) async => okResponse('{"username":"user","sessionId":"S1"}'),
      );

      final result = await apiClient.getUserDetails();

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) {
          expect(r.username, 'user');
          expect(r.sessionId, 'S1');
        },
      );
    });

    test('getOrderDetails returns OrderDetailsResponse on 200', () async {
      when(() => dio.get<String>(any())).thenAnswer(
        (_) async => okResponse(
          '{"salesId":"S1","worktop":"W1","productType":"STD","produktionsOrder":"P1"}',
        ),
      );

      final result = await apiClient.getOrderDetails('P1');

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) {
          expect(r.salesId, 'S1');
          expect(r.productionOrder, 'P1');
        },
      );
    });

    test('submitDiscardOrder returns void on 200', () async {
      when(
        () => dio.post<String>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => okResponse(''));

      final result = await apiClient.submitDiscardOrder(FormData.fromMap({}), 'P1');

      result.match(
        (l) => fail('Expected right, got $l'),
        (_) => expect(true, isTrue),
      );
    });

    test('getDiscardedOrders returns DiscardedOrdersData on 200', () async {
      when(
        () => dio.post<String>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse(
          '''
        {
          "items": [
            {
              "id": 1,
              "errorCode": "E1",
              "productType": "STD",
              "discardDateUtc": "2024-01-01T00:00:00.000Z",
              "prodId": "P1",
              "salesId": "S1"
            },
            {
              "id": 2,
              "errorCode": "E2",
              "productType": "STD",
              "discardDateUtc": "2024-01-01T00:00:00.000Z",
              "prodId": "P2",
              "salesId": "S2"
            }
          ],
          "pageSize": 10,
          "previousCursor": null,
          "nextCursor": "next"
        }
        ''',
        ),
      );

      final request = DiscardedOrderQueryRequest(query: 'q');
      final result = await apiClient.getDiscardedOrders(request);

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) {
          expect(r.items.length, 2);
          expect(r.items.first.id, 1);
          expect(r.nextCursor, 'next');
          expect(r.pageSize, 10);
        },
      );
    });

    test('getDiscardedOrderDetails returns DiscardedOrderDetails on 200', () async {
      when(() => dio.get<String>(any())).thenAnswer(
        (_) async => okResponse(
          '''
        {
          "id": 1,
          "errorCode": "E1",
          "worktop": "W1",
          "productType": "STD",
          "discardDateUtc": "2024-01-01T00:00:00.000Z",
          "prodId": "P1",
          "salesId": "S1",
          "notes": "note",
          "employeeId": "E1",
          "machineName": "M1",
          "errorText": "desc"
        }
        ''',
        ),
      );

      final result = await apiClient.getDiscardedOrderDetails(1);

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) {
          expect(r.id, 1);
          expect(r.errorCode, 'E1');
          expect(r.worktop, 'W1');
          expect(r.productType, 'STD');
          expect(r.discardedAtUtc, DateTime.utc(2024, 1, 1));
          expect(r.prodId, 'P1');
          expect(r.salesId, 'S1');
          expect(r.note, 'note');
          expect(r.employeeId, 'E1');
          expect(r.machineName, 'M1');
          expect(r.errorDescription, 'desc');
        },
      );
    });

    test('getDiscardReasons returns list on 200', () async {
      when(() => dio.get<String>(any())).thenAnswer(
        (_) async => okResponse(
          '''
        [
          {
            "errorCode": "E1",
            "description": "Reason 1",
            "displayCategory": "Cat",
            "dropdown": "Drop"
          }
        ]
        ''',
        ),
      );

      final result = await apiClient.getDiscardReasons('STD');

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) {
          expect(r.length, 1);
          expect(r.first.errorCode, 'E1');
        },
      );
    });

    test('getDropdownValues returns parsing error on invalid json', () async {
      when(() => dio.get<String>(any())).thenAnswer(
        (_) async => okResponse('not-json'),
      );

      final result = await apiClient.getDropdownValues('any');

      result.match(
        (l) => expect(l.code, ValidationErrorCodes.parsingError),
        (_) => fail('Expected left'),
      );
    });

    test('DioException with problem details becomes AppFailure', () async {
      final response = Response<String>(
        data: '{"errorCode":"VALIDATION_PARSING_ERROR","detail":"Bad"}',
        statusCode: 400,
        requestOptions: RequestOptions(path: '/dropdown'),
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/dropdown'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      when(() => dio.get<String>(any())).thenThrow(error);

      final result = await apiClient.getDropdownValues('any');

      result.match(
        (l) => expect(l.problemDetails?.errorCode, 'VALIDATION_PARSING_ERROR'),
        (_) => fail('Expected left'),
      );
    });
  });
}
