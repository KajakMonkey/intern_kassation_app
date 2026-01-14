import 'package:intern_kassation_app/config/constants/product_type.dart';

class DiscardOrder {
  // * Form data
  final String salesId;
  final String productionOrder;
  final String errorCode;
  final String note;
  final DateTime reportDate;
  final String worktop;
  final ProductType productType;
  final String machine;

  // * Employee data
  final String employeeId;

  // * Image data
  final List<String> imagePaths;

  DiscardOrder({
    required this.productionOrder,
    required this.errorCode,
    required this.note,
    required this.employeeId,
    required this.reportDate,
    required this.salesId,
    required this.worktop,
    required this.productType,
    required this.machine,
    this.imagePaths = const [],
  });
}
