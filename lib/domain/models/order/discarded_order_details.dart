import 'package:dart_mappable/dart_mappable.dart';

part 'discarded_order_details.mapper.dart';

@MappableClass()
class DiscardedOrderDetails with DiscardedOrderDetailsMappable {
  final int id;
  final String errorCode;
  final String worktop;
  final String productType;
  @MappableField(key: 'discardDateUtc')
  final DateTime discardedAtUtc;
  final String prodId;
  final String salesId;
  @MappableField(key: 'notes')
  final String note;
  final String employeeId;
  final String? machineName;
  final String? errorDescription;

  DiscardedOrderDetails({
    required this.id,
    required this.errorCode,
    required this.worktop,
    required this.productType,
    required this.discardedAtUtc,
    required this.prodId,
    required this.salesId,
    required this.note,
    required this.employeeId,
    this.machineName,
    this.errorDescription,
  });

  static const fromMap = DiscardedOrderDetailsMapper.fromMap;
  static const fromJson = DiscardedOrderDetailsMapper.fromJson;
}
