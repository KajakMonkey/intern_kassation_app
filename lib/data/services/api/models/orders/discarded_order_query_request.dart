import 'package:dart_mappable/dart_mappable.dart';
import 'package:intern_kassation_app/config/app_config.dart';

part 'discarded_order_query_request.mapper.dart';

@MappableClass()
class DiscardedOrderQueryRequest with DiscardedOrderQueryRequestMappable {
  final String query;
  final String? cursor;
  final int pageSize;

  DiscardedOrderQueryRequest({
    required this.query,
    this.cursor,
    this.pageSize = AppConfig.discardedOrdersPageSize,
  });
}
