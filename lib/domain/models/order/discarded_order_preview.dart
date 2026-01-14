import 'package:dart_mappable/dart_mappable.dart';

part 'discarded_order_preview.mapper.dart';

@MappableClass()
class DiscardedOrderPreview with DiscardedOrderPreviewMappable {
  final int id;
  final String errorCode;
  final String productType;
  @MappableField(key: 'discardDateUtc')
  final DateTime discardedAtUtc;
  final String prodId;
  final String salesId;

  DiscardedOrderPreview({
    required this.id,
    required this.errorCode,
    required this.productType,
    required this.discardedAtUtc,
    required this.prodId,
    required this.salesId,
  });

  static const fromMap = DiscardedOrderPreviewMapper.fromMap;
  static const fromJson = DiscardedOrderPreviewMapper.fromJson;
}
