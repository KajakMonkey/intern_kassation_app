import 'dart:convert';

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

extension DiscardedOrdersDataX on DiscardedOrdersData {
  static DiscardedOrdersData parseFromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return DiscardedOrdersData(
      items: (map['items'] as List)
          .map<DiscardedOrderPreview>(
            (x) => DiscardedOrderPreview.fromMap(x as Map<String, dynamic>),
          )
          .toList(),
      pageSize: map['pageSize'] != null ? map['pageSize'] as int : null,
      previousCursor: map['previousCursor'] != null ? map['previousCursor'] as String : null,
      nextCursor: map['nextCursor'] != null ? map['nextCursor'] as String : null,
    );
  }
}
