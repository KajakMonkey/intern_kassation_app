import 'package:dart_mappable/dart_mappable.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_order_preview.dart';

part 'discarded_orders_data.mapper.dart';

@MappableClass()
class DiscardedOrdersData with DiscardedOrdersDataMappable {
  final List<DiscardedOrderPreview> items;
  final int? pageSize;
  final String? previousCursor;
  final String? nextCursor;

  DiscardedOrdersData({
    required this.items,
    this.pageSize,
    this.previousCursor,
    this.nextCursor,
  });

  static const fromMap = DiscardedOrdersDataMapper.fromMap;
  static const fromJson = DiscardedOrdersDataMapper.fromJson;
}
